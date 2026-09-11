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
 * @file[zh-cn] Sync
 * @brief[zh-cn] 同步原语：互斥锁 / 条件变量 / 信号量 / 读写锁 / 延时
 * @explain[zh-cn] 基于 sdl4cj 库做高级封装（对应 SDL_mutex.h / SDL_thread.h 的延时）。全部为对象式封装，内部持有 SDL 原生句柄，~init 自动释放。
 *
 * @file[en] Sync
 * @brief[en] Synchronization primitives: mutex / condition variable / semaphore / read-write lock / sleep
 * @explain[en] High-level wrappers based on the sdl4cj library (corresponding to SDL_mutex.h / SDL_thread.h sleep). All are object-style wrappers holding native SDL handles, with automatic release in ~init.
 */
package three.core.thread

import std.core.*
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] 互斥锁
 * @explain[zh-cn] 基于 SDL_CreateMutex 的互斥锁封装。内部持有 SDL_Mutex 句柄，~init 自动释放。
 *
 * @brief[en] Mutex
 * @explain[en] Mutex wrapper based on SDL_CreateMutex. Holds an SDL_Mutex handle internally, automatically released in ~init.
 */
public class Mutex {
    /**
     * @brief[zh-cn] SDL 互斥锁句柄
     *
     * @brief[en] SDL mutex handle
     */
    private var _mtx: SDL_Mutex = CPointer<Unit>()

    /**
     * @brief[zh-cn] 构造器：创建互斥锁
     *
     * @brief[en] Constructor: create a mutex
     */
    public init() {
        this._mtx = SDL_CreateMutex_cj()
    }

    /**
     * @brief[zh-cn] 锁定（阻塞）
     *
     * @brief[en] Lock (blocking)
     */
    public func lock(): Unit {
        if (!this._mtx.isNull()) { SDL_LockMutex_cj(this._mtx) }
    }

    /**
     * @brief[zh-cn] 尝试锁定（非阻塞）
     * @return[zh-cn] 成功返回 true
     *
     * @brief[en] Try to lock (non-blocking)
     * @return[en] true if successful
     */
    public func tryLock(): Bool {
        if (this._mtx.isNull()) { return false }
        return SDL_TryLockMutex_cj(this._mtx)
    }

    /**
     * @brief[zh-cn] 解锁
     *
     * @brief[en] Unlock
     */
    public func unlock(): Unit {
        if (!this._mtx.isNull()) { SDL_UnlockMutex_cj(this._mtx) }
    }

    /**
     * @brief[zh-cn] 销毁互斥锁
     *
     * @brief[en] Destroy the mutex
     */
    public func dispose(): Unit {
        if (!this._mtx.isNull()) {
            SDL_DestroyMutex_cj(this._mtx)
            this._mtx = CPointer<Unit>()
        }
    }

    /**
     * @brief[zh-cn] 内部句柄（供 Condition.wait 使用）
     *
     * @brief[en] Internal handle (used by Condition.wait)
     */
    internal func getHandle(): SDL_Mutex {
        return this._mtx
    }

    ~init() {
        if (!this._mtx.isNull()) {
            SDL_DestroyMutex_cj(this._mtx)
            this._mtx = CPointer<Unit>()
        }
    }
}

/**
 * @brief[zh-cn] 条件变量
 * @explain[zh-cn] 基于 SDL_CreateCondition 的条件变量封装。内部持有 SDL_Condition 句柄，~init 自动释放。
 *
 * @brief[en] Condition variable
 * @explain[en] Condition variable wrapper based on SDL_CreateCondition. Holds an SDL_Condition handle internally, automatically released in ~init.
 */
public class Condition {
    /**
     * @brief[zh-cn] SDL 条件变量句柄
     *
     * @brief[en] SDL condition variable handle
     */
    private var _cnd: SDL_Condition = CPointer<Unit>()

    /**
     * @brief[zh-cn] 构造器：创建条件变量
     *
     * @brief[en] Constructor: create a condition variable
     */
    public init() {
        this._cnd = SDL_CreateCondition_cj()
    }

    /**
     * @brief[zh-cn] 等待条件（阻塞，需先持有 mutex；等待期间自动释放 mutex，唤醒后重新持有）
     * @param[zh-cn] mutex 关联的互斥锁
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Wait for condition (blocking, must hold mutex first; mutex is automatically released during wait and re-acquired on wakeup)
     * @param[en] mutex Associated mutex
     * @return[en] Whether successful
     */
    public func wait(mutex: Mutex): Bool {
        if (this._cnd.isNull()) { return false }
        return SDL_WaitCondition_cj(this._cnd, mutex.getHandle())
    }

    /**
     * @brief[zh-cn] 带超时等待条件
     * @param[zh-cn] mutex 关联的互斥锁
     * timeoutMS 超时毫秒数
     * @return[zh-cn] 成功（被唤醒）返回 true；超时返回 false
     *
     * @brief[en] Wait for condition with timeout
     * @param[en] mutex Associated mutex
     * timeoutMS Timeout in milliseconds
     * @return[en] true if signaled (woken up); false if timed out
     */
    public func wait(mutex: Mutex, timeoutMS: Int32): Bool {
        if (this._cnd.isNull()) { return false }
        return SDL_WaitConditionTimeout_cj(this._cnd, mutex.getHandle(), timeoutMS)
    }

    /**
     * @brief[zh-cn] 唤醒一个等待线程
     *
     * @brief[en] Signal one waiting thread
     */
    public func signal(): Unit {
        if (!this._cnd.isNull()) { SDL_SignalCondition_cj(this._cnd) }
    }

    /**
     * @brief[zh-cn] 唤醒所有等待线程
     *
     * @brief[en] Broadcast to all waiting threads
     */
    public func broadcast(): Unit {
        if (!this._cnd.isNull()) { SDL_BroadcastCondition_cj(this._cnd) }
    }

    /**
     * @brief[zh-cn] 销毁条件变量
     *
     * @brief[en] Destroy the condition variable
     */
    public func dispose(): Unit {
        if (!this._cnd.isNull()) {
            SDL_DestroyCondition_cj(this._cnd)
            this._cnd = CPointer<Unit>()
        }
    }

    ~init() {
        if (!this._cnd.isNull()) {
            SDL_DestroyCondition_cj(this._cnd)
            this._cnd = CPointer<Unit>()
        }
    }
}

/**
 * @brief[zh-cn] 信号量
 * @explain[zh-cn] 基于 SDL_CreateSemaphore 的信号量封装。内部持有 SDL_Semaphore 句柄，~init 自动释放。
 *
 * @brief[en] Semaphore
 * @explain[en] Semaphore wrapper based on SDL_CreateSemaphore. Holds an SDL_Semaphore handle internally, automatically released in ~init.
 */
public class Semaphore {
    /**
     * @brief[zh-cn] SDL 信号量句柄
     *
     * @brief[en] SDL semaphore handle
     */
    private var _sem: SDL_Semaphore = CPointer<Unit>()

    /**
     * @brief[zh-cn] 构造器：创建信号量
     * @param[zh-cn] initialValue 初始计数值
     *
     * @brief[en] Constructor: create a semaphore
     * @param[en] initialValue Initial count value
     */
    public init(initialValue!: UInt32 = 0) {
        this._sem = SDL_CreateSemaphore_cj(initialValue)
    }

    /**
     * @brief[zh-cn] 等待信号量（阻塞，计数值减一）
     *
     * @brief[en] Wait for semaphore (blocking, decrements count)
     */
    public func wait(): Unit {
        if (!this._sem.isNull()) { SDL_WaitSemaphore_cj(this._sem) }
    }

    /**
     * @brief[zh-cn] 尝试等待信号量（非阻塞）
     * @return[zh-cn] 成功返回 true
     *
     * @brief[en] Try to wait for semaphore (non-blocking)
     * @return[en] true if successful
     */
    public func tryWait(): Bool {
        if (this._sem.isNull()) { return false }
        return SDL_TryWaitSemaphore_cj(this._sem)
    }

    /**
     * @brief[zh-cn] 带超时等待信号量
     * @param[zh-cn] timeoutMS 超时毫秒数
     * @return[zh-cn] 成功返回 true；超时返回 false
     *
     * @brief[en] Wait for semaphore with timeout
     * @param[en] timeoutMS Timeout in milliseconds
     * @return[en] true if successful; false if timed out
     */
    public func wait(timeoutMS: Int32): Bool {
        if (this._sem.isNull()) { return false }
        return SDL_WaitSemaphoreTimeout_cj(this._sem, timeoutMS)
    }

    /**
     * @brief[zh-cn] 发送信号量（计数值加一）
     *
     * @brief[en] Signal the semaphore (increments count)
     */
    public func signal(): Unit {
        if (!this._sem.isNull()) { SDL_SignalSemaphore_cj(this._sem) }
    }

    /**
     * @brief[zh-cn] 销毁信号量
     *
     * @brief[en] Destroy the semaphore
     */
    public func dispose(): Unit {
        if (!this._sem.isNull()) {
            SDL_DestroySemaphore_cj(this._sem)
            this._sem = CPointer<Unit>()
        }
    }

    ~init() {
        if (!this._sem.isNull()) {
            SDL_DestroySemaphore_cj(this._sem)
            this._sem = CPointer<Unit>()
        }
    }
}

/**
 * @brief[zh-cn] 读写锁（多读者单写者）
 * @explain[zh-cn] 基于 SDL_CreateRWLock 的读写锁封装。内部持有 SDL_RWLock 句柄，~init 自动释放。
 *
 * @brief[en] Read-write lock (multiple readers, single writer)
 * @explain[en] Read-write lock wrapper based on SDL_CreateRWLock. Holds an SDL_RWLock handle internally, automatically released in ~init.
 */
public class RWLock {
    /**
     * @brief[zh-cn] SDL 读写锁句柄
     *
     * @brief[en] SDL read-write lock handle
     */
    private var _lock: SDL_RWLock = CPointer<Unit>()

    /**
     * @brief[zh-cn] 构造器：创建读写锁
     *
     * @brief[en] Constructor: create a read-write lock
     */
    public init() {
        this._lock = SDL_CreateRWLock_cj()
    }

    /**
     * @brief[zh-cn] 以读模式锁定（阻塞，可多个读者）
     *
     * @brief[en] Lock for reading (blocking, multiple readers allowed)
     */
    public func lockRead(): Unit {
        if (!this._lock.isNull()) { SDL_LockRWLockForReading_cj(this._lock) }
    }

    /**
     * @brief[zh-cn] 以写模式锁定（阻塞，独占）
     *
     * @brief[en] Lock for writing (blocking, exclusive)
     */
    public func lockWrite(): Unit {
        if (!this._lock.isNull()) { SDL_LockRWLockForWriting_cj(this._lock) }
    }

    /**
     * @brief[zh-cn] 尝试以读模式锁定（非阻塞）
     * @return[zh-cn] 成功返回 true
     *
     * @brief[en] Try to lock for reading (non-blocking)
     * @return[en] true if successful
     */
    public func tryLockRead(): Bool {
        if (this._lock.isNull()) { return false }
        return SDL_TryLockRWLockForReading_cj(this._lock)
    }

    /**
     * @brief[zh-cn] 尝试以写模式锁定（非阻塞）
     * @return[zh-cn] 成功返回 true
     *
     * @brief[en] Try to lock for writing (non-blocking)
     * @return[en] true if successful
     */
    public func tryLockWrite(): Bool {
        if (this._lock.isNull()) { return false }
        return SDL_TryLockRWLockForWriting_cj(this._lock)
    }

    /**
     * @brief[zh-cn] 解锁
     *
     * @brief[en] Unlock
     */
    public func unlock(): Unit {
        if (!this._lock.isNull()) { SDL_UnlockRWLock_cj(this._lock) }
    }

    /**
     * @brief[zh-cn] 销毁读写锁
     *
     * @brief[en] Destroy the read-write lock
     */
    public func dispose(): Unit {
        if (!this._lock.isNull()) {
            SDL_DestroyRWLock_cj(this._lock)
            this._lock = CPointer<Unit>()
        }
    }

    ~init() {
        if (!this._lock.isNull()) {
            SDL_DestroyRWLock_cj(this._lock)
            this._lock = CPointer<Unit>()
        }
    }
}

/**
 * @brief[zh-cn] 延时指定毫秒数
 * @param[zh-cn] ms 毫秒数
 *
 * @brief[en] Sleep for the specified number of milliseconds
 * @param[en] ms Milliseconds
 */
public func sleep(ms: UInt32): Unit {
    SDL_Delay_cj(ms)
}

/**
 * @brief[zh-cn] 延时指定纳秒数
 * @param[zh-cn] ns 纳秒数
 *
 * @brief[en] Sleep for the specified number of nanoseconds
 * @param[en] ns Nanoseconds
 */
public func sleepNS(ns: UInt64): Unit {
    SDL_DelayNS_cj(ns)
}
