/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] LuaDeferredCallbackQueue 跨线程延迟回调队列（three.script.vm 子包）
 * @brief[zh-cn] 线程安全的 Lua 回调投递队列：任意线程 post，Lua 线程 drain 执行
 * @explain[zh-cn] 用于把「工作线程产生的事件」安全地送回 Lua 侧执行。
 * LuaJIT 的 lua_State 不是线程安全的：任何 Lua 调用都必须在拥有该 VM 的 Lua 线程上执行，
 * 因此工作线程（音频线程、物理线程、渲染线程等）**不得**直接调用 LuaCallback.call，
 * 只能把 LuaCallback 投递到本队列；由 Lua 线程在安全点调用 drain 逐条执行。
 * 队列本身只做入队/出队（Mutex 保护 ArrayList），调用 Lua 只发生在 drain 内。
 * @note[zh-cn] drain 必须在 Lua 线程调用；执行前已把整批回调摘出锁区，
 * 因此回调内部再次 post 不会死锁。单条回调出错不中断整批，全部执行完后抛首个错误。
 *
 * @file[en] LuaDeferredCallbackQueue cross-thread deferred callback queue
 * (three.script.vm sub-package)
 * @brief[en] A thread-safe Lua callback mailbox: any thread posts, the Lua thread drains
 * @explain[en] Used to hand events produced on worker threads back to Lua safely.
 * The LuaJIT lua_State is not thread-safe: every Lua call must run on the Lua thread that
 * owns the VM, so worker threads (audio/physics/render, ...) must **never** invoke
 * LuaCallback.call directly; they post the callback here, and the Lua thread drains it at
 * a safe point. The queue itself only enqueues/dequeues under a Mutex; Lua is called
 * exclusively inside drain.
 * @note[en] drain must be called on the Lua thread. The whole batch is detached from the
 * lock before execution, so a callback may post again without deadlocking. A failing
 * callback does not abort the batch; the first error is rethrown after all have run.
 */
package three.script.vm

import std.collection.*
import std.sync.*

/**
 * @brief[zh-cn] 跨线程 Lua 回调队列
 * @explain[zh-cn] post 可从任意线程调用（只入队，不触碰 lua_State）；
 * drain/clear 只能在 Lua 线程调用（会执行/释放 Lua 注册表引用）。
 *
 * @brief[en] Cross-thread Lua callback queue
 * @explain[en] post is safe from any thread (enqueue only, never touches lua_State);
 * drain/clear must be called on the Lua thread (they execute callbacks / free registry refs).
 */
public class LuaDeferredCallbackQueue {
    /// 队列锁（仅保护 _pending 的增删）
    private let _mtx: Mutex = Mutex()

    /// 待执行回调（Lua 线程消费）
    private var _pending: ArrayList<LuaCallback>

    public init() {
        this._pending = ArrayList<LuaCallback>()
    }

    /**
     * @brief[zh-cn] 当前待执行回调数量（任意线程可读）
     *
     * @brief[en] The number of pending callbacks (readable from any thread)
     */
    public prop size: Int64 {
        get() {
            this._mtx.lock()
            let n = this._pending.size
            this._mtx.unlock()
            return n
        }
    }

    /**
     * @brief[zh-cn] 投递一个回调（任意线程，只入队不执行）
     * @param[zh-cn] cb 目标回调（所有权转移给队列，由 drain/clear 负责 release）
     *
     * @brief[en] Posts a callback (any thread; enqueue only, never executes)
     * @param[en] cb The callback (ownership transfers to the queue; drain/clear releases it)
     */
    public func post(cb: LuaCallback): Unit {
        this._mtx.lock()
        this._pending.add(cb)
        this._mtx.unlock()
    }

    /**
     * @brief[zh-cn] 从 LuaValue 构造并投递回调（任意线程）
     * @param[zh-cn] vm 所属虚拟机
     * @param[zh-cn] v 目标值（须为 LuaValue.Function(ref)）
     * @return[zh-cn] true = 已入队；false = 不是函数引用或 VM 已关闭
     *
     * @brief[en] Builds a callback from a LuaValue and posts it (any thread)
     * @param[en] vm The owning virtual machine
     * @param[en] v  The target value (must be LuaValue.Function(ref))
     * @return[en] true if enqueued; false if it is not a function reference or the VM is closed
     */
    public func postValue(vm: LuaVM, v: LuaValue): Bool {
        if (let Some(cb) <- LuaCallback.fromValue(vm, v)) {
            this.post(cb)
            return true
        }
        return false
    }

    /**
     * @brief[zh-cn] 在 Lua 线程执行全部待处理回调
     * @explain[zh-cn] 先把整批摘出锁区再逐条执行：回调内部可安全再次 post。
     * 单条出错**不中断整批**，也不向上抛异常——绑定层调用本方法时若抛异常，
     * 分派层会执行 lua_error 的 longjmp，跨过仓颉栈帧导致运行时状态失配
     * （实测表现为后续随机位置访问冲突）。出错条目跳过并释放其注册表引用，
     * 仅计入"未成功"，由返回值体现。
     * @return[zh-cn] 实际成功执行的条数（失败条目不计入）
     *
     * @brief[en] Executes all pending callbacks on the Lua thread
     * @explain[en] The whole batch is detached from the lock before running, so callbacks may
     * post again safely. A failing callback neither aborts the batch nor propagates an exception:
     * throwing out of this method while the binding layer runs it would make the dispatch layer
     * perform lua_error's longjmp across Cangjie stack frames and corrupt runtime state (observed
     * as random later access violations). Failing entries are skipped with their registry
     * reference released and simply do not count as successful.
     * @return[en] The number of callbacks that completed successfully (failing ones excluded)
     */
    public func drain(): Int64 {
        // 1. 锁内整批摘出（回调执行不持锁，允许回调内再次 post）
        this._mtx.lock()
        let batch = this._pending
        this._pending = ArrayList<LuaCallback>()
        this._mtx.unlock()
        // 2. 逐条执行并释放引用（失败不中断、不抛出）
        var done: Int64 = 0
        for (cb in batch) {
            try {
                cb.call()
                done += 1
            } catch (_) {
                // 回调自身出错：跳过，不向调用方抛出
            }
            cb.release()
        }
        return done
    }

    /**
     * @brief[zh-cn] 清空队列（Lua 线程调用）：释放全部回调引用但不执行
     * @return[zh-cn] 被丢弃的条数
     *
     * @brief[en] Clears the queue (Lua thread): releases every callback without executing it
     * @return[en] The number of discarded callbacks
     */
    public func clear(): Int64 {
        this._mtx.lock()
        let batch = this._pending
        this._pending = ArrayList<LuaCallback>()
        this._mtx.unlock()
        var n: Int64 = 0
        for (cb in batch) {
            cb.release()
            n += 1
        }
        return n
    }
}
