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
 * @file[zh-cn] FrameFence 帧栅栏
 * @brief[zh-cn] 原子提交/完成序号 + 条件变量，语义对齐 UE FRenderCommandFence
 * @explain[zh-cn] 依据《多线程改造计划》阶段 0 设计：
 * - 高频路径（提交/推进序号）仅原子操作，无锁；
 * - 仅"必须等渲染完成"的低频等待路径使用 Mutex + Condition（谓词在锁内重查，
 *   防孤儿唤醒，与 ThreeRenderer 原 broadcast 注释一致）。
 * - 消费线程每**批**执行完 `advanceBy(n)` 一次，等待者按自己的序号被释放，
 *   把唤醒次数由"每命令一次"降为"每批一次"。
 *
 * @file[en] FrameFence frame fence
 * @brief[en] Atomic submit/done sequence + condition variable, aligned with UE FRenderCommandFence
 * @explain[en] Per Phase 0 of the multi-threading refactoring plan:
 * - hot paths (submit / advance the sequence) are pure atomics, lock-free;
 * - only the low-frequency "must wait for render" path uses Mutex + Condition
 *   (the predicate is re-checked inside the lock, preventing orphan wakeups,
 *   consistent with ThreeRenderer's original broadcast comment).
 * - the consumer calls `advanceBy(n)` once per *batch*; waiters are released by their
 *   own sequence, reducing wakeups from once-per-command to once-per-batch.
 */
package three.core.thread

import std.sync.AtomicInt64

/**
 * @brief[zh-cn] 帧栅栏：提交者记忆序号，消费者推进完成序号，等待者按序号等待
 * @explain[zh-cn] 典型流程（渲染线程命令路径）：
 * ```
 * // 生产者（逻辑线程）
 * let seq = fence.submit()      // 取一个唯一序号
 * queue.push(cmd)
 * fence.waitUntil(seq)          // 高频检查为原子读；未完成才进条件变量
 *
 * // 消费者（渲染线程）
 * batch = drain(queue)          // 批量排空
 * fence.advanceBy(batch.size)   // 整批完成后一次性推进 + 唤醒
 * ```
 * 与 ThreeRenderer 旧模型（每命令 lock + broadcast）相比，唤醒次数由命令数降为批次数。
 *
 * @brief[en] Frame fence: the submitter remembers a sequence, the consumer advances
 * the done sequence, and waiters block until their sequence
 * @explain[en] Typical flow (render command path):
 * ```
 * // Producer (logic thread)
 * let seq = fence.submit()     // grab a unique sequence
 * queue.push(cmd)
 * fence.waitUntil(seq)         // hot check is an atomic read; block only if unmet
 *
 * // Consumer (render thread)
 * batch = drain(queue)         // batch drain
 * fence.advanceBy(batch.size)  // advance once + wake once per batch
 * ```
 * Compared with ThreeRenderer's old model (lock + broadcast per command),
 * wakeups drop from command-count to batch-count.
 */
public class FrameFence {
    /**
     * @brief[zh-cn] 提交序号（已提交命令总数，仅增）
     *
     * @brief[en] Submit sequence (total submitted commands, monotonic)
     */
    private let _submitSeq = AtomicInt64(0)

    /**
     * @brief[zh-cn] 完成序号（已执行命令总数，仅增）
     *
     * @brief[en] Done sequence (total executed commands, monotonic)
     */
    private let _doneSeq = AtomicInt64(0)

    /**
     * @brief[zh-cn] 等待路径互斥锁（仅 waitUntil 阻塞时使用）
     *
     * @brief[en] Wait-path mutex (used only when waitUntil blocks)
     */
    private let _mtx = Mutex()

    /**
     * @brief[zh-cn] 等待路径条件变量（advanceBy 时 broadcast）
     *
     * @brief[en] Wait-path condition variable (broadcast on advanceBy)
     */
    private let _cnd = Condition()

    /**
     * @brief[zh-cn] 构造器
     *
     * @brief[en] Constructor
     */
    public init() {}

    /**
     * @brief[zh-cn] 提交一条命令，返回其完成序号（从 1 开始单调递增）
     * @return[zh-cn] 新提交序号，供后续 waitUntil 使用
     *
     * @brief[en] Submit one command and return its completion sequence (monotonic from 1)
     * @return[en] New submit sequence, to be passed to waitUntil later
     */
    public func submit(): Int64 {
        return this._submitSeq.fetchAdd(1) + 1
    }

    /**
     * @brief[zh-cn] 完成一条命令（advanceBy(1) 的便捷封装）
     *
     * @brief[en] Mark one command done (convenience for advanceBy(1))
     */
    public func advance(): Unit {
        this.advanceBy(1)
    }

    /**
     * @brief[zh-cn] 完成一批命令：推进完成序号并唤醒所有等待者
     * @param[zh-cn] n 本批执行完成的命令数（≤0 时直接返回）
     *
     * @brief[en] Mark a batch of commands done: advance the done sequence and wake all waiters
     * @param[en] n Number of commands executed in this batch (no-op when <= 0)
     */
    public func advanceBy(n: Int64): Unit {
        if (n <= 0) { return }
        this._doneSeq.fetchAdd(n)
        // 唤醒在条件变量上睡眠的等待者；已醒或尚未睡眠的等待者由谓词重查兜底
        this._mtx.lock()
        this._cnd.broadcast()
        this._mtx.unlock()
    }

    /**
     * @brief[zh-cn] 等待完成序号 ≥ seq
     * @explain[zh-cn] 锁外先做一次原子检查（高频路径无系统调用）；
     * 未满足才进条件变量，且锁内必须重查谓词（防孤儿唤醒）。
     * @param[zh-cn] seq 待等待的提交序号
     *
     * @brief[en] Block until the done sequence is >= seq
     * @explain[en] One atomic check outside the lock first (no syscall on the hot path);
     * only then enter the condition variable, re-checking the predicate inside the lock
     * (prevents orphan wakeups).
     * @param[en] seq Submit sequence to wait for
     */
    public func waitUntil(seq: Int64): Unit {
        if (this._doneSeq.load() >= seq) { return }
        this._mtx.lock()
        while (this._doneSeq.load() < seq) {
            this._cnd.wait(this._mtx)
        }
        this._mtx.unlock()
    }

    /**
     * @brief[zh-cn] 当前完成序号（已执行命令总数）
     * @return[zh-cn] 完成序号
     *
     * @brief[en] Current done sequence (total executed commands)
     * @return[en] Done sequence
     */
    public func done(): Int64 {
        return this._doneSeq.load()
    }

    /**
     * @brief[zh-cn] 当前提交序号（已提交命令总数）
     * @return[zh-cn] 提交序号
     *
     * @brief[en] Current submit sequence (total submitted commands)
     * @return[en] Submit sequence
     */
    public func submitted(): Int64 {
        return this._submitSeq.load()
    }

    /**
     * @brief[zh-cn] 仅唤醒所有等待者（不推进序号）
     * @explain[zh-cn] 供退出/重置路径使用：先 advanceBy 补齐缺口，再调用本方法
     * 兜底唤醒（即使 advanceBy(n<=0) 提前返回也能把睡眠中的等待者全部拉起）。
     *
     * @brief[en] Wake all waiters without advancing the sequence
     * @explain[en] For exit/reset paths: advance the gap via advanceBy first, then call
     * this to wake anyone still asleep (even if advanceBy(n<=0) returned early).
     */
    public func broadcastAll(): Unit {
        this._mtx.lock()
        this._cnd.broadcast()
        this._mtx.unlock()
    }
}