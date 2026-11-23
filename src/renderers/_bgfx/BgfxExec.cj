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
 * @file[zh-cn] BgfxExec bgfx 后端命令执行器
 * @brief[zh-cn] 渲染线程命令路由设施（位于后端实现包）
 * @explain[zh-cn] 抽象层线程契约的落点：IRenderBackend 的"任意线程"方法经本执行器
 * 路由到唯一的 bgfx 命令线程，调用方无须关心后端的 API 线程/渲染线程之分。
 * 设施构成：
 * - 命令队列 → SPSCQueue（无锁环形缓冲）；
 * - 完成同步 → FrameFence（按批推进完成序号）；
 * - 唤醒 → Semaphore（一次性通知）；
 * - 渲染线程快路径 → SDL 系统线程 ID 比对，同线程直接执行（可重入）；
 * - 互斥 → 全局可重入锁 bgfxCallMtx（与引擎其余 bgfx 直调路径互斥）。
 * 线程约束：跨线程投递须来自同一外部线程（SPSC 单生产者）；渲染线程自身的
 * 调用走快路径直接执行。线程惰性启动：首次提交命令时才创建，本后端实现
 * 未被调用前不产生任何线程。
 *
 * @file[en] BgfxExec bgfx backend command executor
 * @brief[en] Render-thread command routing facility (in the backend package)
 * @explain[en] The landing point of the abstraction-layer threading contract: the
 * "any thread" methods of IRenderBackend route through this executor onto the single
 * bgfx command thread, so callers never care about the backend's API/render thread split.
 * The facility consists of:
 * - command queue → SPSCQueue (lock-free ring buffer);
 * - completion sync → FrameFence (done sequence advances per batch);
 * - wake-up → Semaphore (one-shot notify);
 * - render-thread fast path → SDL system thread ID comparison, direct execution
 *   on the same thread (reentrant);
 * - mutual exclusion → the global reentrant lock bgfxCallMtx (serialized against
 *   the engine's other direct bgfx call paths).
 * Threading constraints: cross-thread submission must come from one external thread
 * (SPSC single producer); calls from the render thread itself take the fast path.
 * The thread starts lazily on the first submitted command — no thread exists before
 * this backend implementation is ever called.
 *
 * @package three.renderers._bgfx
 */
protected package three.renderers._bgfx
import std.sync.{AtomicBool, AtomicUInt64}
import std.time.MonoTime
import three.core.thread.{FrameFence, SPSCQueue, Semaphore, SThread, bgfxCallMtx, getCurrentThreadId, sleepNS}
import three.profiler.*
import three.profiler.macros.*
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] bgfx 命令执行器
 * @explain[zh-cn] 持有唯一的 bgfx 命令线程与无锁命令队列；execSync 为同步等待
 * 语义（命令执行完毕才返回），execAsync 为单向投递语义（纯输出型调用免往返）。
 * stopThread 置退出标志并唤醒线程（线程退出路径放弃残留命令并推进完成序号，
 * 保证等待者不悬挂）。
 *
 * @brief[en] bgfx command executor
 * @explain[en] Holds the single bgfx command thread and the lock-free command queue;
 * execSync waits synchronously (returns only after the command completes), execAsync
 * is fire-and-forget (saves a round trip for output-only calls). stopThread sets the
 * exit flag and wakes the thread (the exit path drops residual commands and advances
 * the done sequence so waiters never hang).
 */
protected class BgfxCommandExecutor {
    private let queue = SPSCQueue<() -> Unit>(capacity: 4096)
    private let wake = Semaphore(initVal: 0)
    private let fence = FrameFence()
    private let exitFlag = AtomicBool(false)
    private var thread: Option<SThread<Unit>> = None

    /**
     * @brief[zh-cn] 命令线程的 SDL 系统线程 ID（快路径判定用）
     * @explain[zh-cn] 由命令线程在入口写入（原子存储）。execSync 用它与当前线程
     * ID 比对：相同即调用方已在命令线程上，直接执行闭包，省掉一次
     * "排队 + 条件变量等待 + 唤醒" 的线程往返。线程身份用 SDL 系统线程 ID
     * （本后端的命令线程是 SDL 系统线程；仓颉自带的用户态线程其承载系统
     * 线程不固定，不适用）。
     *
     * @brief[en] SDL system thread ID of the command thread (for the fast path)
     * @explain[en] Written by the command thread on entry (atomic store). execSync
     * compares it with the current thread ID: on a match the caller is already on
     * the command thread, so the closure runs directly, saving one queue +
     * condition-variable + wake round trip. Identity uses the SDL system thread ID
     * (this backend's command thread is an SDL system thread; Cangjie's own
     * user-mode threads are scheduled onto varying OS threads).
     */
    private let threadId = AtomicUInt64(0u64)

    private func initThread(): Unit {
        if (this.thread.isSome()) {
            return
        }
        this.thread = SThread {
            this.loop();
            ()
        }
    }

    private func loop(): Unit {
        this.threadId.store(getCurrentThreadId())
        while (!this.exitFlag.load()) {
            // 批量排空（无锁）：一次执行当前队列中的全部命令，整批完成后推进完成序号
            let n = this.drainAndExec()
            if (n > 0) {
                this.fence.advanceBy(n)
            } else {
                // 无命令：睡到有新命令投递（信号量唤醒，一次性通知无需谓词重查）
                if (!this.exitFlag.load()) {
                    this.wake.wait()
                }
            }
        }
        // 退出路径：bgfx 已 shutdown，残留命令不得再执行（执行将崩溃），
        // 但必须按"已提交-已完成"缺口推进完成序号，唤醒仍可能在等待的提交者。
        let outstanding = this.fence.submitted() - this.fence.done()
        if (outstanding > 0) {
            this.fence.advanceBy(outstanding)
        }
    }

    /**
     * @brief[zh-cn] 批量排空命令队列并在命令线程执行（无锁 pop）
     * @return[zh-cn] 本批实际执行的命令数
     * @explain[zh-cn] 循环 pop 直到队列空，逐条持全局可重入锁执行 bgfx 闭包。
     * 单条命令失败仅记录日志（异常隔离），不终止排空，保证其提交者的完成
     * 序号仍会被推进。
     *
     * @brief[en] Drain the command queue in batches and execute on the command thread (lock-free pop)
     * @return[en] Number of commands executed in this batch
     * @explain[en] Pops until empty, executing each bgfx closure while holding the
     * global reentrant lock. A single failing command is logged (isolation) and
     * does not stop the drain, so its submitter's done sequence still advances.
     */
    private func drainAndExec(): Int64 {
        var n: Int64 = 0
        while (true) {
            if (let Some(cmd) <- this.queue.pop()) {
                // 命令线程执行 bgfx 闭包：持全局可重入锁，与其他线程的直调互斥。
                // 闭包内部（如嵌套的 execSync）同线程重入，不会自我死锁。
                bgfxCallMtx.lock()
                let cmdStart = MonoTime.now()
                try {
                    cmd()
                } catch (e: Error) {
                    @LogError(["BgfxCommandExecutor", "bgfx cmd failed: ${e}"])
                }
                bgfxCallMtx.unlock()
                // 诊断日志（只记录、不解锁）：单条命令异常耗时说明原生层/管线异常
                let cmdCostMs = (MonoTime.now() - cmdStart).toMilliseconds()
                if (cmdCostMs > 200) {
                    @LogWarn(["BgfxCommandExecutor", "bgfx cmd cost ${cmdCostMs}ms (>200)"])
                }
                n += 1
            } else {
                break
            }
        }
        return n
    }

    /**
     * @brief[zh-cn] 同步执行：把 bgfx 调用闭包路由到命令线程并等待完成
     * @param[zh-cn] cmd 待执行的 bgfx 调用闭包
     * @explain[zh-cn] 快路径：调用方已在命令线程上（SDL 系统线程 ID 相同）→ 直接
     * 执行闭包（持可重入锁），解除不可重入限制——闭包内再调 execSync 不会自我
     * 等待死锁，整条链路可一次性提交到命令线程执行。
     *
     * @brief[en] Synchronous execution: routes a bgfx closure onto the command thread and waits
     * @param[en] cmd The bgfx closure to execute
     * @explain[en] Fast path: the caller is already on the command thread (same SDL
     * system thread ID) → the closure runs directly (under the reentrant lock),
     * removing the non-reentrancy restriction — nested execSync calls inside the
     * closure never self-deadlock, so a whole chain can run on the command thread.
     */
    public func execSync(cmd: () -> Unit): Unit {
        if (this.thread.isNone()) {
            this.initThread()
        }
        let cmdTid = this.threadId.load()
        if (cmdTid != 0u64 && getCurrentThreadId() == cmdTid) {
            bgfxCallMtx.lock()
            try {
                cmd()
            } finally {
                bgfxCallMtx.unlock()
            }
            return
        }
        this.execQueued(cmd)
    }
    /**
     * @brief[zh-cn] 跨线程排队路径：把 bgfx 调用闭包排到命令线程并同步等待完成
     * @explain[zh-cn] 单独成方法以便只对"跨线程往返"插桩：快路径无同步开销，
     * 逐次插桩会让每帧产生数十个 zone 事件淹没采集端；跨线程往返（每次约
     * 数十微秒）才是需要观测的量。
     *
     * @brief[en] Cross-thread queueing path: enqueues a bgfx closure onto the command thread and waits
     * @explain[en] Split out so only the *cross-thread round trip* is instrumented:
     * the fast path has no synchronization cost and per-call zones would flood the
     * collector; the round trip is the quantity that actually needs observing.
     */
    @Zone[three.renderers._bgfx.BgfxCommandExecutor.execQueued]
    private func execQueued(cmd: () -> Unit): Unit {
        let seq = this.enqueue(cmd)
        if (seq == 0) {
            return
        }
        this.fence.waitUntil(seq)
    }

    /**
     * @brief[zh-cn] 无锁投递命令到命令队列（SPSC push + 信号量唤醒）
     * @return[zh-cn] 本次投递的完成序号（0 表示命令线程已退出，命令被丢弃）
     * @explain[zh-cn] 先检查退出标志（无锁原子读）：已退出则丢弃并返回 0；
     * 提交一个完成序号（占用序号空间，保证后续等待型提交的完成条件不被提前
     * 满足）；SPSC 入队（无锁），队列满时短暂自旋等待消费端排空；信号量唤醒
     * 命令线程（一次性通知，无需谓词重查）。
     *
     * @brief[en] Lock-free submission into the command queue (SPSC push + semaphore wake)
     * @return[en] Completion sequence of this submission (0 if the command thread exited and the command was dropped)
     * @explain[en] Checks the exit flag first (lock-free atomic read): drop and
     * return 0 when exiting; submits a completion sequence (reserving sequence space
     * so later waiting submissions cannot be satisfied early); enqueues via SPSC
     * (lock-free), briefly spinning on full; wakes the command thread via the
     * semaphore (one-shot, no predicate re-check).
     */
    private func enqueue(cmd: () -> Unit): Int64 {
        if (this.thread.isNone()) {
            this.initThread()
        }
        if (this.exitFlag.load()) {
            return 0
        }
        let seq = this.fence.submit()
        while (!this.queue.push(cmd)) {
            if (this.exitFlag.load()) {
                return 0
            }
            sleepNS(1000)
        }
        this.wake.signal()
        return seq
    }

    /**
     * @brief[zh-cn] 单向投递 bgfx 闭包到命令线程（不等待执行完成）
     * @explain[zh-cn] 适用于"纯输出型"调用（如画面内调试文本）：调用方不读取任何
     * 返回值，正确性只依赖命令按提交顺序执行——后续任何等待型提交都会等到本
     * 命令执行完毕。仍占用一个完成序号，否则后续等待者的完成条件会被提前满足。
     *
     * @brief[en] Fire-and-forget submission onto the command thread (does not wait)
     * @explain[en] Suitable for output-only calls (e.g. on-screen debug text): the
     * caller reads no result, so correctness only depends on in-order execution —
     * any later waiting submission waits past this command. A completion sequence
     * is still reserved, otherwise later waiters would be satisfied early.
     */
    public func execAsync(cmd: () -> Unit): Unit {
        if (this.thread.isNone()) {
            this.initThread()
        }
        let cmdTid = this.threadId.load()
        if (cmdTid != 0u64 && getCurrentThreadId() == cmdTid) {
            bgfxCallMtx.lock()
            try {
                cmd()
            } finally {
                bgfxCallMtx.unlock()
            }
            return
        }
        let _ = this.enqueue(cmd)
    }

    /**
     * @brief[zh-cn] 停止命令线程（置退出标志并唤醒，等待退出后复位为可重启态）
     * @explain[zh-cn] 须在 bgfx_shutdown 已经（经 execSync）执行完之后调用，
     * 与渲染器释放序列保持一致：先同步关机、后停线程。
     * 支持生命周期重启（先释放再重建渲染器的场景）：join 等待命令线程真正
     * 退出（loop 退出路径已放弃残留命令并推进完成序号），随后清空队列残留
     * （防止新线程误执行关机前的旧命令）并复位退出标志——此后首个 execSync
     * 会重新拉起命令线程。
     * 同线程调用防护：从命令线程自身调用时无法 join 自己，退化为仅置标志
     * （该场景线程随闭包返回自然退出，执行器不再可重启）。
     *
     * @brief[en] Stops the command thread (sets the exit flag, wakes it, and resets to a restartable state after it exits)
     * @explain[en] Must be called after bgfx_shutdown has (via execSync) completed,
     * matching the renderer release sequence: synchronous shutdown first, then
     * thread stop.
     * Supports lifecycle restart (release-then-recreate renderer scenarios): join
     * waits for the command thread to truly exit (the loop's exit path already
     * abandons leftover commands and advances the completion sequence); the queue
     * is then drained (so the new thread never executes pre-shutdown leftovers)
     * and the exit flag is reset — the first execSync afterwards starts a fresh
     * command thread.
     * Same-thread guard: joining oneself is impossible, so a call from the
     * command thread itself degrades to flag-setting only (the thread exits
     * naturally when the closure returns and the executor stays non-restartable).
     */
    public func stopThread(): Unit {
        if (this.thread.isNone()) {
            return
        }
        let stoppedTid = this.threadId.load()
        if (stoppedTid != 0u64 && getCurrentThreadId() == stoppedTid) {
            // 命令线程自身调用：不能 join 自己
            this.exitFlag.store(true)
            this.wake.signal()
            return
        }
        this.exitFlag.store(true)
        this.wake.signal()
        if (let Some(t) <- this.thread) {
            t.join()
        }
        this.thread = None
        this.threadId.store(0u64)
        // 丢弃队列残留（loop 退出路径已把完成序号补齐到 submitted，此处仅清实体）
        while (let Some(_) <- this.queue.pop()) {
            ()
        }
        this.exitFlag.store(false)
    }

    /**
     * @brief[zh-cn] 等待全部已投递命令执行完毕（含未完成的异步帧）
     * @explain[zh-cn] 与 renderAsync 配对使用：每帧开始修改场景前调用。线程未
     * 启动时直接返回；无未完成命令时仅一次原子读，无开销。
     *
     * @brief[en] Waits until all posted commands (including pending async frames) have executed
     * @explain[en] Paired with renderAsync: call at the start of a frame before mutating
     * the scene. Returns immediately when the thread never started; costs one atomic
     * read when nothing is pending.
     */
    public func waitIdle(): Unit {
        if (this.thread.isNone()) {
            return
        }
        this.fence.waitUntil(this.fence.submitted())
    }
}

/**
 * @brief[zh-cn] 后端全局命令执行器实例
 * @explain[zh-cn] bgfx 上下文是进程级单例，命令线程与其一一对应，故执行器为
 * 包内单例；后端实现的全部 IRenderBackend 方法经它路由。
 *
 * @brief[en] The backend-global command executor instance
 * @explain[en] The bgfx context is a process-level singleton and the command thread
 * corresponds to it one-to-one, hence a package-level singleton; all IRenderBackend
 * methods of the backend implementation route through it.
 */
protected let gfxBackendExec = BgfxCommandExecutor()
