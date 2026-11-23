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
 * @file[zh-cn] LuaDeferredTaskQueue 跨线程延迟任务队列（three.script.vm 子包）
 * @brief[zh-cn] 线程安全的延迟任务队列：任意线程 post，Lua 线程 drain 执行
 * @explain[zh-cn] 与 LuaDeferredCallbackQueue 互补：后者只能投递"无参 Lua 回调"，
 * 而网络/传输模块的工作线程常需携带载荷（收到的字节、响应对象、断线原因等）回投
 * Lua 线程。此时由工作线程把「构造 LuaValue + 调用 LuaCallback」整体包成一个闭包
 * 任务投递，闭包在 Lua 线程执行时才触碰 lua_State，从而满足 LuaJIT 的线程约束。
 * @note[zh-cn] post 任意线程可用（只入队）；drain 必须在 Lua 线程调用。
 * 任务内部若需注册对象（LuaObjectRegistry）或构造 LuaValue，只能写在任务体内，
 * 不允许在 post 之前构造，否则会在工作线程访问 Lua 注册表。
 *
 * @file[en] LuaDeferredTaskQueue cross-thread deferred task queue
 * (three.script.vm sub-package)
 * @brief[en] A thread-safe deferred task queue: any thread posts, the Lua thread drains
 * @explain[en] Complements LuaDeferredCallbackQueue: the latter can only post a
 * "parameterless Lua callback", while network/transport worker threads usually need to
 * carry a payload (received bytes, a response object, a disconnect reason, ...) back to
 * the Lua thread. Here the worker thread posts one closure task bundling
 * "build LuaValues + invoke LuaCallback"; the closure touches lua_State only when it runs
 * on the Lua thread, satisfying LuaJIT's threading constraint.
 * @note[en] post is safe from any thread (enqueue only); drain must run on the Lua thread.
 * Anything touching Lua (registering objects via LuaObjectRegistry, building LuaValues)
 * must live inside the task body, never before post, or a worker thread would access the
 * Lua registry.
 */
package three.script.vm

import std.collection.*
import std.sync.*

/**
 * @brief[zh-cn] 跨线程延迟任务队列
 * @explain[zh-cn] post 只入队；drain 在 Lua 线程逐条执行。单条任务失败不中断整批、
 * 不向上抛异常（绑定层抛出会触发 lua_error 的 longjmp，跨过仓颉栈帧破坏运行时状态）。
 *
 * @brief[en] Cross-thread deferred task queue
 * @explain[en] post only enqueues; drain runs the tasks one by one on the Lua thread.
 * A failing task neither aborts the batch nor propagates an exception (throwing out of
 * the binding layer would trigger lua_error's longjmp across Cangjie stack frames and
 * corrupt runtime state).
 */
public class LuaDeferredTaskQueue {
    /// 队列锁（仅保护 _pending 的增删）
    private let _mtx: Mutex = Mutex()

    /// 待执行任务（Lua 线程消费）
    private var _pending: ArrayList<() -> Unit>

    public init() {
        this._pending = ArrayList<() -> Unit>()
    }

    /**
     * @brief[zh-cn] 当前待执行任务数量（任意线程可读）
     *
     * @brief[en] The number of pending tasks (readable from any thread)
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
     * @brief[zh-cn] 投递一个任务（任意线程，只入队不执行）
     * @param[zh-cn] task 目标任务（闭包体内可安全触碰 Lua）
     *
     * @brief[en] Posts a task (any thread; enqueue only, never executes)
     * @param[en] task The task (its body may safely touch Lua)
     */
    public func post(task: () -> Unit): Unit {
        this._mtx.lock()
        this._pending.add(task)
        this._mtx.unlock()
    }

    /**
     * @brief[zh-cn] 在 Lua 线程执行全部待处理任务
     * @explain[zh-cn] 先把整批摘出锁区再执行，因此任务体内可安全再次 post。
     * 单条失败仅跳过，不向上抛异常。
     * @return[zh-cn] 实际成功执行的条数（失败条目不计入）
     *
     * @brief[en] Executes all pending tasks on the Lua thread
     * @explain[en] The whole batch is detached from the lock before running, so a task may
     * post again safely. A failing task is skipped without propagating an exception.
     * @return[en] The number of tasks that completed successfully (failing ones excluded)
     */
    public func drain(): Int64 {
        this._mtx.lock()
        let batch = this._pending
        this._pending = ArrayList<() -> Unit>()
        this._mtx.unlock()
        var done: Int64 = 0
        for (task in batch) {
            try {
                task()
                done += 1
            } catch (_) {
                // 任务自身出错：跳过，不向调用方抛出
            }
        }
        return done
    }

    /**
     * @brief[zh-cn] 清空队列（Lua 线程调用）：丢弃全部任务但不执行
     * @return[zh-cn] 被丢弃的条数
     *
     * @brief[en] Clears the queue (Lua thread): discards every task without executing it
     * @return[en] The number of discarded tasks
     */
    public func clear(): Int64 {
        this._mtx.lock()
        let n = this._pending.size
        this._pending = ArrayList<() -> Unit>()
        this._mtx.unlock()
        return n
    }
}
