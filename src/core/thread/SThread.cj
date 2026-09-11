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
 * @file[zh-cn] SThread
 * @brief[zh-cn] 系统线程：基于 SDL_CreateThread 的线程封装
 * @explain[zh-cn] 提供与 rycj.system.SThread 相同的能力：回调执行 + 返回值捕获；get() / get(timeoutMS) / tryGet() 结果获取；线程内异常安全捕获并在 get() 时重新抛出。内部通过全局线程池（key → 对象）在 SDL 线程入口中还原对象引用，与 rycj 的实现方式一致。
 *
 * @file[en] SThread
 * @brief[en] System thread: SDL_CreateThread-based thread wrapper
 * @explain[en] Provides the same capabilities as rycj.system.SThread: callback execution + return value capture; get() / get(timeoutMS) / tryGet() result retrieval; safe exception capture within threads and re-throw on get(). Internally uses a global thread pool (key → object) to restore object references in the SDL thread entry, consistent with the rycj implementation.
 */
package three.core.thread

import std.core.*
import std.collection.concurrent.{ ConcurrentHashMap, ConcurrentLinkedQueue }
import std.sync.*
import sdl4cj.sdl.*

// =============================================================================
// 全局线程池（key → _SysThread 对象）
// =============================================================================

/**
 * @brief[zh-cn] 全局线程池（key → _SysThread 对象）
 *
 * @brief[en] Global thread pool (key → _SysThread object)
 */
let GLB_THREAD_POOL: ConcurrentHashMap<Int64, Any> = ConcurrentHashMap()
/**
 * @brief[zh-cn] 全局自增键
 *
 * @brief[en] Global auto-increment key
 */
var GLB_INCREMENT_KEY: AtomicInt64 = AtomicInt64(Int64.Min)
/**
 * @brief[zh-cn] 全局回收键队列
 *
 * @brief[en] Global recycled-key queue
 */
let GLB_RECYCLE_KEY: ConcurrentLinkedQueue<Int64> = ConcurrentLinkedQueue()

/**
 * @brief[zh-cn] 获取唯一键（优先复用回收键）
 *
 * @brief[en] Get a unique key (recycled keys are reused first)
 */
func getOnlyKey(): Int64 {
    if (GLB_RECYCLE_KEY.isEmpty()) {
        return GLB_INCREMENT_KEY.fetchAdd(1)
    } else {
        return GLB_RECYCLE_KEY.remove().getOrThrow()
    }
}

/**
 * @brief[zh-cn] 回收键并从线程池移除
 *
 * @brief[en] Recycle the key and remove it from the thread pool
 */
func recycleKey(key: Int64): Unit {
    GLB_RECYCLE_KEY.add(key)
    GLB_THREAD_POOL.remove(key)
}

/**
 * @brief[zh-cn] 从指针还原 _SysThread 对象
 *
 * @brief[en] Restore the _SysThread object from a pointer
 */
func getObjFromPtr(p: CPointer<Unit>): Option<_SysThread> {
    let keyVal = unsafe { CPointer<Int64>(p).read() }
    let obj = if (GLB_THREAD_POOL.contains(keyVal)) {
        (GLB_THREAD_POOL.get(keyVal).getOrThrow() as _SysThread)
    } else {
        Option<_SysThread>.None
    }
    return obj
}

/**
 * @brief[zh-cn] SDL 线程入口：执行回调 → 保存结果 → 通知 → 释放入参并归还键
 *
 * @brief[en] SDL thread entry: execute callback → save result → notify → release input params and return key
 */
@C
func threadEntry(p: CPointer<Unit>): Int32 {
    let obj = getObjFromPtr(p).getOrThrow()
    // 若指定了线程优先级，在回调执行前应用 SDL 线程优先级
    if (obj._priority >= 0) {
        SDL_SetCurrentThreadPriority_cj(obj._priority)
    }
    // 注意：仓颉异常体系中 Error 与 Exception 并列（无共同 Throwable 基类）。
    // OverflowException / RuntimeException 等都继承 Exception，而非 Error；
    // 若只 catch (e: Error)，这些异常会逃逸到 MRT_EndForeignCJThread 触发 abort。
    // 故 Exception 与 Error 都需捕获，统一存入 error（Exception）供 get() 重抛。
    let retv = try {
        obj._function()
    } catch (e: Exception) {
        obj.error = Some(e)
    } catch (e: Error) {
        obj.error = Some(Exception(e.toString()))
    }
    obj._resultMtx.lock()
    obj._result = retv
    obj._resultCnd.signal()
    obj._resultMtx.unlock()
    // 释放入参（key 指针）并归还 key
    unsafe { LibC.free(CPointer<Int64>(p)) }
    recycleKey(obj._key)
    return 0
}

// =============================================================================
// 线程优先级
// =============================================================================

/**
 * @brief[zh-cn] 线程优先级（对应 SDL_ThreadPriority）
 * @explain[zh-cn] 优先级在子线程启动时通过 SDL_SetCurrentThreadPriority 应用；
 *                 部分平台对实际生效的优先级可能有限制。
 *
 * @brief[en] Thread priority (corresponds to SDL_ThreadPriority)
 * @explain[en] Applied via SDL_SetCurrentThreadPriority at child thread start;
 *              some platforms may restrict which priorities take effect.
 */
public enum ThreadPriority {
    /**
     * @brief[zh-cn] 低优先级
     *
     * @brief[en] Low priority
     */
    | Low
    /**
     * @brief[zh-cn] 正常优先级
     *
     * @brief[en] Normal priority
     */
    | Normal
    /**
     * @brief[zh-cn] 高优先级
     *
     * @brief[en] High priority
     */
    | High
    /**
     * @brief[zh-cn] 时间关键（最高）优先级
     *
     * @brief[en] Time-critical (highest) priority
     */
    | TimeCritical

    /**
     * @brief[zh-cn] 转换为 SDL 线程优先级数值
     * @return[zh-cn] SDL_ThreadPriority 枚举值
     *
     * @brief[en] Convert to SDL thread priority value
     * @return[en] SDL_ThreadPriority enum value
     */
    public func toSDLPriority(): Int32 {
        match (this) {
            case Low => 0
            case Normal => 1
            case High => 2
            case TimeCritical => 3
        }
    }
}

// =============================================================================
// 内部线程对象
// =============================================================================

/**
 * @brief[zh-cn] 内部线程对象
 *
 * @brief[en] Internal thread object
 */
internal class _SysThread {
    /**
     * @brief[zh-cn] 全局唯一键
     *
     * @brief[en] Globally unique key
     */
    internal let _key: Int64
    /**
     * @brief[zh-cn] 键值指针
     *
     * @brief[en] Pointer to the key value
     */
    private let _pKeyVal: CPointer<Int64>
    /**
     * @brief[zh-cn] 回调函数
     *
     * @brief[en] Callback function
     */
    internal let _function: () -> Any
    /**
     * @brief[zh-cn] 执行结果
     *
     * @brief[en] Execution result
     */
    internal var _result: Option<Any> = None
    /**
     * @brief[zh-cn] 结果互斥锁
     *
     * @brief[en] Result mutex
     */
    internal let _resultMtx = Mutex()
    /**
     * @brief[zh-cn] 结果条件变量
     *
     * @brief[en] Result condition variable
     */
    internal let _resultCnd = Condition()
    /**
     * @brief[zh-cn] 线程内异常（Exception；Error 被包装为 Exception(message)）
     *
     * @brief[en] Exception captured inside the thread (Exception; Error is wrapped as Exception(message))
     */
    internal var error: Option<Exception> = None
    /**
     * @brief[zh-cn] SDL 线程句柄
     *
     * @brief[en] SDL thread handle
     */
    private var _thread: SDL_Thread = CPointer<Unit>()
    /**
     * @brief[zh-cn] 是否已 join
     *
     * @brief[en] Whether the thread has been joined
     */
    private var _joined: Bool = false
    /**
     * @brief[zh-cn] SDL 线程优先级（Int32），负数表示不设置（使用系统默认）
     *
     * @brief[en] SDL thread priority (Int32); negative means not set (use system default)
     */
    internal var _priority: Int32 = -1

    /**
     * @brief[zh-cn] 构造器（默认线程属性）
     * @param[zh-cn] callback 线程回调函数
     *
     * @brief[en] Constructor (default thread attributes)
     * @param[en] callback Thread callback function
     */
    public init(callback: () -> Any) {
        this._function = callback
        this._pKeyVal = unsafe { LibC.malloc<Int64>() }
        this._key = getOnlyKey()
        this._registerAndStart("three-sdl-thread", 0)
    }

    /**
     * @brief[zh-cn] 构造器（指定线程名称与栈大小）
     * @param[zh-cn] callback 线程回调函数
     * @param[zh-cn] name 线程名（用于调试，可空字符串）
     * @param[zh-cn] stackSizeBytes 线程栈大小（字节）。0 表示使用系统默认
     *
     * @brief[en] Constructor (with thread name and stack size)
     * @param[en] callback Thread callback function
     * @param[en] name Thread name (for debugging, may be empty)
     * @param[en] stackSizeBytes Thread stack size in bytes. 0 means system default
     */
    public init(callback: () -> Any, name: String, stackSizeBytes: Int64) {
        this._function = callback
        this._pKeyVal = unsafe { LibC.malloc<Int64>() }
        this._key = getOnlyKey()
        this._registerAndStart(name, stackSizeBytes)
    }

    /**
     * @brief[zh-cn] 构造器（指定线程名称、栈大小与优先级）
     * @param[zh-cn] callback 线程回调函数
     * @param[zh-cn] name 线程名（用于调试，可空字符串）
     * @param[zh-cn] stackSizeBytes 线程栈大小（字节）。0 表示使用系统默认
     * @param[zh-cn] priority 线程优先级
     *
     * @brief[en] Constructor (with thread name, stack size and priority)
     * @param[en] callback Thread callback function
     * @param[en] name Thread name (for debugging, may be empty)
     * @param[en] stackSizeBytes Thread stack size in bytes. 0 means system default
     * @param[en] priority Thread priority
     */
    public init(callback: () -> Any, name: String, stackSizeBytes: Int64, priority: ThreadPriority) {
        this._function = callback
        this._pKeyVal = unsafe { LibC.malloc<Int64>() }
        this._key = getOnlyKey()
        // 优先级在 threadEntry 启动时应用
        this._priority = priority.toSDLPriority()
        this._registerAndStart(name, stackSizeBytes)
    }

    /**
     * @brief[zh-cn] 注册到全局线程池并启动 SDL 线程
     * @param[zh-cn] name 线程名
     * @param[zh-cn] stackSizeBytes 线程栈大小（字节），0 表示系统默认
     *
     * @brief[en] Register into the global pool and start the SDL thread
     * @param[en] name Thread name
     * @param[en] stackSizeBytes Thread stack size in bytes, 0 means system default
     */
    private func _registerAndStart(name: String, stackSizeBytes: Int64): Unit {
        // 先注册到全局线程池，再创建线程，避免线程入口在池注册前启动
        GLB_THREAD_POOL.add(this._key, this)
        unsafe { this._pKeyVal.write(this._key) }

        if (stackSizeBytes > 0) {
            // 自定义栈大小：走 SDL 属性集合方式创建线程
            this._thread = this._createWithAttributes(name, stackSizeBytes)
        } else {
            let entryFunc: SDL_ThreadFunction = threadEntry
            let nameCs = unsafe { LibC.mallocCString(name) }
            this._thread = SDL_CreateThread_cj(entryFunc, nameCs, unsafe { CPointer<Unit>(this._pKeyVal) })
            unsafe { LibC.free(nameCs) }
        }
    }

    /**
     * @brief[zh-cn] 通过 SDL 属性集合创建线程，并指定线程名与栈大小
     * @param[zh-cn] name 线程名
     * @param[zh-cn] stackSizeBytes 线程栈大小（字节）
     * @return[zh-cn] SDL 线程句柄
     *
     * @brief[en] Create a thread via SDL properties with a custom name and stack size
     * @param[en] name Thread name
     * @param[en] stackSizeBytes Thread stack size in bytes
     * @return[en] SDL thread handle
     */
    private func _createWithAttributes(name: String, stackSizeBytes: Int64): SDL_Thread {
        let props = SDL_CreateProperties_cj()
        let keyEntryCs = unsafe { LibC.mallocCString("SDL.thread.create.entry_function") }
        let keyNameCs = unsafe { LibC.mallocCString("SDL.thread.create.name") }
        let keyUserdataCs = unsafe { LibC.mallocCString("SDL.thread.create.userdata") }
        let keyStacksizeCs = unsafe { LibC.mallocCString("SDL.thread.create.stacksize") }
        let nameCs = unsafe { LibC.mallocCString(name) }
        SDL_SetPointerProperty_cj(props, keyEntryCs, unsafe { CPointer<Unit>(threadEntry) })
        SDL_SetStringProperty_cj(props, keyNameCs, nameCs)
        SDL_SetPointerProperty_cj(props, keyUserdataCs, unsafe { CPointer<Unit>(this._pKeyVal) })
        SDL_SetNumberProperty_cj(props, keyStacksizeCs, stackSizeBytes)
        let thread = SDL_CreateThreadWithProperties_cj(props)
        SDL_DestroyProperties_cj(props)
        unsafe {
            LibC.free(keyEntryCs)
            LibC.free(keyNameCs)
            LibC.free(keyUserdataCs)
            LibC.free(keyStacksizeCs)
            LibC.free(nameCs)
        }
        return thread
    }

    /**
     * @brief[zh-cn] 阻塞获取线程结果（线程内异常在此重新抛出）
     * @return[zh-cn] 线程执行结果
     *
     * @brief[en] Blocking get thread result (thread exceptions are re-thrown here)
     * @return[en] Thread execution result
     */
    public func get(): Any {
        this._resultMtx.lock()
        while (this._result.isNone()) {
            this._resultCnd.wait(this._resultMtx)
        }
        this._resultMtx.unlock()
        if (let Some(e) <- this.error) { throw e }
        return this._result.getOrThrow()
    }

    /**
     * @brief[zh-cn] 带超时获取线程结果（毫秒）
     * @param[zh-cn] timeoutMS 最大等待毫秒数
     * @return[zh-cn] 线程结果；超时抛 TimeoutException
     *
     * @brief[en] Get thread result with timeout (milliseconds)
     * @param[en] timeoutMS Maximum wait time in milliseconds
     * @return[en] Thread result; throws TimeoutException on timeout
     */
    public func get(timeoutMS: Int32): Any {
        this._resultMtx.lock()
        if (this._result.isNone()) {
            this._resultCnd.wait(this._resultMtx, timeoutMS)
        }
        let r = this._result
        this._resultMtx.unlock()
        if (let Some(v) <- r) {
            if (let Some(e) <- this.error) { throw e }
            return v
        } else {
            throw TimeoutException()
        }
    }

    /**
     * @brief[zh-cn] 获取线程 ID（线程 ID）
     * @return[zh-cn] 线程 ID
     *
     * @brief[en] Get thread ID (thread ID)
     * @return[en] Thread ID
     */
    public func getId(): UInt64 {
        this._resultMtx.lock()
        let r = SDL_GetThreadID_cj(this._thread)
        this._resultMtx.unlock()
        return r
    }

    /**
     * @brief[zh-cn] 非阻塞获取线程结果
     * @return[zh-cn] 线程未结束返回 None
     *
     * @brief[en] Non-blocking get thread result
     * @return[en] Returns None if thread has not finished
     */
    public func tryGet(): Option<Any> {
        this._resultMtx.lock()
        let r = this._result
        this._resultMtx.unlock()
        return r
    }

    /**
     * @brief[zh-cn] 等待线程结束（阻塞）
     *
     * @brief[en] Wait for thread to finish (blocking)
     */
    public func join(): Unit {
        if (this._joined) { return }
        SDL_WaitThread_cj(this._thread, CPointer<Int32>())
        this._joined = true
    }

    /**
     * @brief[zh-cn] 分离线程（自动回收资源）
     *
     * @brief[en] Detach thread (automatically reclaim resources)
     */
    public func detach(): Unit {
        SDL_DetachThread_cj(this._thread)
    }

    ~init() {
        // 未 join 则分离，让线程自行结束并回收（threadEntry 负责释放入参/归还 key）
        if (!this._joined) {
            SDL_DetachThread_cj(this._thread)
        }
    }
}

// =============================================================================
// 对外 SThread
// =============================================================================

/**
 * @brief[zh-cn] 系统线程类
 * @explain[zh-cn] 用法示例：
 * ```
 * let t = SThread{ doWork(); 42 }
 * let result = t.get()          // 阻塞等待结果
 * let r2 = t.get(1000)          // 带超时（毫秒）
 * let r3 = t.tryGet()           // 非阻塞
 * ```
 * @param[zh-cn] T 线程回调返回类型
 *
 * @brief[en] System thread class
 * @explain[en] Usage example:
 * ```
 * let t = SThread{ doWork(); 42 }
 * let result = t.get()          // Blocking wait for result
 * let r2 = t.get(1000)          // With timeout (milliseconds)
 * let r3 = t.tryGet()           // Non-blocking
 * ```
 * @param[en] T Thread callback return type
 */
public open class SThread<T> {
    /**
     * @brief[zh-cn] 内部线程对象
     *
     * @brief[en] Internal thread object
     */
    private let obj: _SysThread

    /**
     * @brief[zh-cn] 构造器：创建一条系统线程
     * @param[zh-cn] callback 线程回调函数
     *
     * @brief[en] Constructor: create a system thread
     * @param[en] callback Thread callback function
     */
    public init(callback: () -> T) {
        obj = _SysThread({ => return callback() })
    }

    /**
     * @brief[zh-cn] 构造器（指定线程名与栈大小）
     * @param[zh-cn] callback 线程回调函数
     * @param[zh-cn] name 线程名
     * @param[zh-cn] stackSizeBytes 线程栈大小（字节）
     *
     * @brief[en] Constructor (with thread name and stack size)
     * @param[en] callback Thread callback function
     * @param[en] name Thread name
     * @param[en] stackSizeBytes Thread stack size in bytes
     */
    public init(callback: () -> T, name: String, stackSizeBytes: Int64) {
        obj = _SysThread({ => return callback() }, name, stackSizeBytes)
    }

    /**
     * @brief[zh-cn] 构造器（指定线程名、栈大小与优先级）
     * @param[zh-cn] callback 线程回调函数
     * @param[zh-cn] name 线程名
     * @param[zh-cn] stackSizeBytes 线程栈大小（字节）
     * @param[zh-cn] priority 线程优先级
     *
     * @brief[en] Constructor (with thread name, stack size and priority)
     * @param[en] callback Thread callback function
     * @param[en] name Thread name
     * @param[en] stackSizeBytes Thread stack size in bytes
     * @param[en] priority Thread priority
     */
    public init(callback: () -> T, name: String, stackSizeBytes: Int64, priority: ThreadPriority) {
        obj = _SysThread({ => return callback() }, name, stackSizeBytes, priority)
    }

    /**
     * @brief[zh-cn] 阻塞获取线程执行结果
     * @return[zh-cn] 线程执行结果
     *
     * @brief[en] Blocking get thread execution result
     * @return[en] Thread execution result
     */
    public open func get(): T {
        (obj.get() as T).getOrThrow()
    }

    /**
     * @brief[zh-cn] 带超时获取线程执行结果
     * @param[zh-cn] timeoutMS 最大等待毫秒数
     * @return[zh-cn] 线程结果；超时抛 TimeoutException
     *
     * @brief[en] Get thread execution result with timeout
     * @param[en] timeoutMS Maximum wait time in milliseconds
     * @return[en] Thread result; throws TimeoutException on timeout
     */
    public open func get(timeoutMS: Int32): T {
        (obj.get(timeoutMS) as T).getOrThrow()
    }

    /**
     * @brief[zh-cn] 尝试获取线程执行结果（线程未结束返回 None）
     * @return[zh-cn] 线程结果，或 None
     *
     * @brief[en] Try to get thread execution result (returns None if thread has not finished)
     * @return[en] Thread result, or None
     */
    public open func tryGet(): Option<T> {
        if (let Some(v) <- obj.tryGet()) {
            return (v as T).getOrThrow()
        } else {
            return Option<T>.None
        }
    }

    /**
     * @brief[zh-cn] 等待线程结束（阻塞）
     *
     * @brief[en] Wait for thread to finish (blocking)
     */
    public open func join(): Unit {
        obj.join()
    }

    /**
     * @brief[zh-cn] 分离线程（自动回收资源）
     *
     * @brief[en] Detach thread (automatically reclaim resources)
     */
    public open func detach(): Unit {
        obj.detach()
    }

    /**
     * @brief[zh-cn] 获取线程 ID（线程 ID）
     * @return[zh-cn] 线程 ID
     *
     * @brief[en] Get thread ID (thread ID)
     * @return[en] Thread ID
     */
    public open func getId(): UInt64 {
        return obj.getId()
    }
}

/**
 * @brief[zh-cn] 获取当前线程 ID（调用者线程）
 * @return[zh-cn] 当前线程 ID
 *
 * @brief[en] Get current thread ID (caller thread)
 * @return[en] Current thread ID
 */
public func getCurrentThreadId(): UInt64 {
    return SDL_GetCurrentThreadID_cj()
}
