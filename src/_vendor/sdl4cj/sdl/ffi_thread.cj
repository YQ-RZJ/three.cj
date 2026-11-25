/**
 * @file sdl4cj 并发模块 CFFI 函数声明
 * @brief SDL3 线程 / 互斥锁 / 信号量 / 条件变量 / 读写锁 / 原子操作 模块
 * @explain 本文件包含上述模块的 foreign 函数声明（包级私有）。
 *         外部调用请使用 `ffi_thread_exports.cj` 中的 `_cj` 包装。
 * @note SDL_ThreadFunction 是 C 回调函数指针，对应 `CFunc<(CPointer<Unit>) -> Int32>`。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 线程（SDL_thread.h）
// =============================================================================

/** @brief 线程函数类型（int (*)(void *data)） */
public type SDL_ThreadFunction = CFunc<(CPointer<Unit>) -> Int32>

foreign func SDL_CreateThreadRuntime(fn: SDL_ThreadFunction, name: CString, data: CPointer<Unit>, pfnBeginThread: CPointer<Unit>, pfnEndThread: CPointer<Unit>): SDL_Thread
// SDL3: SDL_CreateThreadWithProperties 宏展开的 SDL_CreateThreadWithPropertiesRuntime，可通过属性指定线程名/栈大小等
foreign func SDL_CreateThreadWithPropertiesRuntime(props: UInt32, pfnBeginThread: CPointer<Unit>, pfnEndThread: CPointer<Unit>): SDL_Thread
@FastNative
foreign func SDL_GetThreadName(thread: SDL_Thread): CString
@FastNative
foreign func SDL_GetCurrentThreadID(): UInt64
@FastNative
foreign func SDL_GetThreadID(thread: SDL_Thread): UInt64
foreign func SDL_WaitThread(thread: SDL_Thread, status: CPointer<Int32>): Unit
@FastNative
foreign func SDL_DetachThread(thread: SDL_Thread): Unit

// =============================================================================
// 互斥锁（SDL_mutex.h）
// =============================================================================

@FastNative
foreign func SDL_CreateMutex(): SDL_Mutex
@FastNative
foreign func SDL_LockMutex(mutex: SDL_Mutex): Unit
@FastNative
foreign func SDL_TryLockMutex(mutex: SDL_Mutex): Bool
@FastNative
foreign func SDL_UnlockMutex(mutex: SDL_Mutex): Unit
@FastNative
foreign func SDL_DestroyMutex(mutex: SDL_Mutex): Unit

// =============================================================================
// 读写锁（SDL_mutex.h）
// =============================================================================

@FastNative
foreign func SDL_CreateRWLock(): SDL_RWLock
@FastNative
foreign func SDL_LockRWLockForReading(rwlock: SDL_RWLock): Unit
@FastNative
foreign func SDL_LockRWLockForWriting(rwlock: SDL_RWLock): Unit
@FastNative
foreign func SDL_TryLockRWLockForReading(rwlock: SDL_RWLock): Bool
@FastNative
foreign func SDL_TryLockRWLockForWriting(rwlock: SDL_RWLock): Bool
@FastNative
foreign func SDL_UnlockRWLock(rwlock: SDL_RWLock): Unit
@FastNative
foreign func SDL_DestroyRWLock(rwlock: SDL_RWLock): Unit

// =============================================================================
// 信号量（SDL_mutex.h）
// =============================================================================

@FastNative
foreign func SDL_CreateSemaphore(initial_value: UInt32): SDL_Semaphore
@FastNative
foreign func SDL_DestroySemaphore(sem: SDL_Semaphore): Unit
foreign func SDL_WaitSemaphore(sem: SDL_Semaphore): Unit
@FastNative
foreign func SDL_TryWaitSemaphore(sem: SDL_Semaphore): Bool
foreign func SDL_WaitSemaphoreTimeout(sem: SDL_Semaphore, timeoutMS: Int32): Bool
@FastNative
foreign func SDL_SignalSemaphore(sem: SDL_Semaphore): Unit
@FastNative
foreign func SDL_SetTLS(id: UInt32, value: CPointer<Unit>, destructor: CPointer<Unit>): Bool
@FastNative
foreign func SDL_GetTLS(id: UInt32): CPointer<Unit>
@FastNative
foreign func SDL_CleanupTLS(): Unit
@FastNative
foreign func SDL_SetCurrentThreadPriority(priority: Int32): Bool
@FastNative
foreign func SDL_GetThreadState(thread: CPointer<Unit>): Int32

// =============================================================================
// 条件变量（SDL_mutex.h）
// =============================================================================

@FastNative
foreign func SDL_CreateCondition(): SDL_Condition
@FastNative
foreign func SDL_DestroyCondition(cond: SDL_Condition): Unit
@FastNative
foreign func SDL_SignalCondition(cond: SDL_Condition): Unit
@FastNative
foreign func SDL_BroadcastCondition(cond: SDL_Condition): Unit
foreign func SDL_WaitCondition(cond: SDL_Condition, mutex: SDL_Mutex): Bool
foreign func SDL_WaitConditionTimeout(cond: SDL_Condition, mutex: SDL_Mutex, timeoutMS: Int32): Bool
