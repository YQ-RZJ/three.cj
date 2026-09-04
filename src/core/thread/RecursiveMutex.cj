/**
 * @file[zh-cn] RecursiveMutex 可重入互斥锁
 * @brief[zh-cn] 通用可重入互斥锁（同线程可重复锁定，深度计数）
 * @explain[zh-cn] 基于 SDL 互斥锁封装实现。仓颉标准库 std.sync.Mutex 原生可重入，但仅面向
 * 用户态线程调度；本工程 bgfx 需跨系统线程（主线程 + SDL 渲染线程 + bgfx 内部渲染线程）
 * 同步，必须使用 sdl4cj 的互斥锁。SDL 锁本身不可重入（同线程二次 lock 会死锁），
 * 本类通过「持有者线程 ID + 深度计数」实现可重入语义：
 * - 快路径（当前线程已是持有者）：仅原子递增深度，无系统调用，性能开销≈一次原子加。
 * - 慢路径（竞争/首次获取）：走底层 SDL 锁阻塞。
 * 释放时深度递减，归零后才真正释放底层 SDL 锁。
 * 典型用途：渲染线程在执行多步 bgfx 调用序列期间，内部辅助函数（如 BgfxUniforms）
 * 仍需再次加锁的场景（避免自我死锁）。
 *
 * @note[zh-cn] 线程身份用 SDL 系统线程 ID 标识，适用于系统线程环境（本工程场景）。
 * 若在仓颉 N:M 用户态线程上复用：同一 OS 线程上被调度的不同用户线程共享同一系统线程 ID，
 * 会把「非重入的两次进入」误判为「同线程重入」。本类面向系统线程互斥用途，
 * 用户态线程场景请改用 std.sync.Mutex。
 *
 * @file[en] RecursiveMutex reentrant mutex
 * @brief[en] Generic reentrant mutex (same-thread re-lock allowed, depth counted)
 * @explain[en] Wraps an SDL mutex. Cangjie's std.sync.Mutex is natively reentrant but
 * targets user-mode thread scheduling; this project needs cross-system-thread sync for
 * bgfx (main thread + SDL render thread + bgfx internal render thread), so an sdl4cj
 * mutex is required. SDL mutexes are not reentrant (a second lock by the same thread
 * would deadlock). This class implements reentrancy via an owner thread ID plus a depth
 * counter:
 * - Fast path (caller already owns): only an atomic depth increment, no syscall.
 * - Slow path (contended/first acquire): blocks on the underlying SDL mutex.
 * unlock() decrements depth and releases the underlying lock only at depth zero.
 * Typical use: while the render thread holds a lock for a multi-step bgfx call sequence,
 * inner helpers (e.g. BgfxUniforms) still need to lock again without self-deadlocking.
 *
 * @note[en] Thread identity uses the SDL system thread ID, suitable for system-thread
 * environments (this project). If reused on Cangjie N:M user-mode threads, different
 * user threads scheduled on the same OS thread share one system thread ID, so two
 * non-reentrant entries could be misread as same-thread reentrancy. This class is
 * intended for system-thread mutual exclusion; use std.sync.Mutex for user threads.
 */
package three.core.thread

import std.core.*
import std.sync.AtomicInt64
import std.sync.AtomicUInt64
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] 可重入互斥锁
 * @explain[zh-cn] 与 Mutex 相同的接口（lock/unlock/tryLock/dispose），额外支持同线程重入。
 * 持有者 ID 与深度用原子字段维护（默认顺序一致性），快路径重入仅一次原子加，开销极小。
 *
 * @brief[en] Reentrant mutex
 * @explain[en] Same interface as Mutex (lock/unlock/tryLock/dispose), plus same-thread
 * reentrancy. Owner ID and depth are atomic fields (sequential consistency by default);
 * the fast-path reentry costs a single atomic add.
 */
public class RecursiveMutex {
    /**
     * @brief[zh-cn] 底层 SDL 互斥锁
     *
     * @brief[en] Underlying SDL mutex
     */
    private var _mtx: Mutex = Mutex()

    /**
     * @brief[zh-cn] 当前持有者线程 ID（无持有者为 UInt64.Max，等价于有符号 -1 的全 1 位形）
     * @explain[zh-cn] 用无符号原子存储 SDL 线程 ID（SThread.getCurrentId() 返回 UInt64），
     * 避免有符号/无符号转换（超出数据范围的转换在仓颉不安全）。
     *
     * @brief[en] Owner thread ID (UInt64.Max when unowned, the all-ones bit pattern of -1)
     * @explain[en] Stores the SDL thread ID (SThread.getCurrentId() returns UInt64) in an
     * unsigned atomic, avoiding signed/unsigned conversion (out-of-range conversions are
     * unsafe in Cangjie).
     */
    private var _owner = AtomicUInt64(UInt64.Max)

    /**
     * @brief[zh-cn] 重入深度计数
     *
     * @brief[en] Reentrancy depth counter
     */
    private var _depth = AtomicInt64(0)

    /**
     * @brief[zh-cn] 构造器
     *
     * @brief[en] Constructor
     */
    public init() {}

    /**
     * @brief[zh-cn] 锁定（阻塞）。同一线程可重复调用，仅递增深度。
     *
     * @brief[en] Lock (blocking). The owning thread may call again; only depth increases.
     */
    public func lock(): Unit {
        // SThread<T> 为泛型类，其静态 getCurrentId() 无法在无类型实参下调用；
        // 此处直接调 SDL 当前线程 ID（返回 UInt64，与 _owner 原子类型匹配）。
        let tid = SDL_GetCurrentThreadID_cj()
        if (this._depth.load() > 0 && this._owner.load() == tid) {
            this._depth.fetchAdd(1)
        } else {
            this._mtx.lock()
            this._owner.store(tid)
            this._depth.store(1)
        }
    }

    /**
     * @brief[zh-cn] 尝试锁定（非阻塞）。同一线程可重复调用，仅递增深度。
     * @return[zh-cn] 成功返回 true
     *
     * @brief[en] Try to lock (non-blocking). The owning thread may call again; only depth increases.
     * @return[en] true if successful
     */
    public func tryLock(): Bool {
        let tid = SDL_GetCurrentThreadID_cj()
        if (this._depth.load() > 0 && this._owner.load() == tid) {
            this._depth.fetchAdd(1)
            return true
        }
        if (this._mtx.tryLock()) {
            this._owner.store(tid)
            this._depth.store(1)
            return true
        }
        return false
    }

    /**
     * @brief[zh-cn] 解锁。深度减一，归零后才真正释放底层锁。
     * @explain[zh-cn] 若当前线程并非持有者（逻辑错误），本方法静默忽略，避免破坏锁状态。
     *
     * @brief[en] Unlock. Decrements depth; the underlying lock is released only at depth zero.
     * @explain[en] If the caller is not the owner (logic error), this method silently ignores
     * the call to avoid corrupting the lock state.
     */
    public func unlock(): Unit {
        if (this._depth.load() > 0 && this._owner.load() == SDL_GetCurrentThreadID_cj()) {
            // fetchSub 返回减法前的旧值：旧值==1 说明归零，需真正释放底层锁
            let old = this._depth.fetchSub(1)
            if (old == 1) {
                this._owner.store(UInt64.Max)
                this._mtx.unlock()
            }
        }
    }

    /**
     * @brief[zh-cn] 销毁互斥锁（仅建议在无竞争时调用）
     *
     * @brief[en] Destroy the mutex (recommended only when uncontended)
     */
    public func dispose(): Unit {
        this._mtx.dispose()
        this._owner.store(UInt64.Max)
        this._depth.store(0)
    }

    /**
     * @brief[zh-cn] 执行回调函数并加锁，返回结果。回调结束后自动解锁。
     * @param[zh-cn] callback 回调函数
     * @return[zh-cn] 回调函数返回值
     *
     * @brief[en] Execute callback function while holding the lock, return result. Unlock
     * automatically after callback returns.
     * @param[en] callback Callback function
     * @return[en] Callback return value
     */
    public func withLock<T>(callback: () -> T): T {
        this.lock()
        try {
            return callback()
        } finally {
            this.unlock()
        }
    }
}

/**
 * @brief[zh-cn] 全局 bgfx 调用互斥锁（可重入）
 * @explain[zh-cn] 进程级单例：串行化所有线程对 bgfx FFI 的裸调用（主线程的
 * BgfxUniforms/ShaderLibs/EffectComposer 裸调，以及仓颉渲染线程 _renderLoop 闭包内的
 * bgfx_frame/bgfx_render_frame/场景提交等）。bgfx 官方线程模型要求单 API 线程，
 * 多线程并发裸调会导致数据竞争与堆损坏（他机随机崩溃）。用可重入锁保证：
 * 渲染线程持锁执行长序列期间，内部辅助函数再次加锁不自我死锁。
 *
 * @brief[en] Global reentrant mutex for bgfx calls
 * @explain[en] Process-wide singleton that serializes all raw bgfx FFI calls from every
 * thread (raw BgfxUniforms/ShaderLibs/EffectComposer calls on the main thread, as well as
 * bgfx_frame/bgfx_render_frame/scene submission inside the Cangjie render thread's
 * _renderLoop closures). bgfx's official threading model requires a single API thread;
 * concurrent raw calls across threads cause data races and heap corruption (random crashes
 * on other machines). The reentrant lock guarantees inner helpers can re-lock without
 * self-deadlock while the render thread executes a long call sequence.
 */
protected let bgfxCallMtx = RecursiveMutex()
