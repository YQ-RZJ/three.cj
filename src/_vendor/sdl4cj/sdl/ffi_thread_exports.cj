/**
 * @file sdl4cj 并发模块公共函数包装
 * @brief SDL3 线程 / 互斥锁 / 信号量 / 条件变量 / 读写锁 的仓颉安全包装
 * @explain 本文件为并发模块的每个 foreign 函数提供 `_cj` 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中。
 *
 * @see https://github.com/libsdl-org/SDL
 */
protected package three._vendor.sdl4cj.sdl

// =============================================================================
// 线程（SDL_thread.h）
// =============================================================================

/**
 * @brief 创建线程（对应 C 端 SDL_CreateThread 宏展开的 SDL_CreateThreadRuntime）
 * @param fn 线程函数（返回 Int32 退出码）
 * @param name 线程名称
 * @param data 传给线程函数的用户数据指针
 * @return SDL_Thread 线程指针（null 表示失败）
 * @note 后两个线程回调参数传 null（SDL_CreateThread 宏内部使用，仓颉侧无需提供）
 */
public func SDL_CreateThread_cj(fn: SDL_ThreadFunction, name: CString, data: CPointer<Unit>): SDL_Thread {
    return unsafe {
        SDL_CreateThreadRuntime(fn, name, data, CPointer<Unit>(), CPointer<Unit>())
    }
}

/**
 * @brief 通过属性集合创建线程（对应 SDL_CreateThreadWithProperties 宏展开的 SDL_CreateThreadWithPropertiesRuntime）
 * @param props 属性集合 ID，含 SDL_PROP_THREAD_CREATE_* 属性
 * @return SDL_Thread 线程指针（null 表示失败）
 * @note 支持通过属性指定线程名（SDL_PROP_THREAD_CREATE_NAME_STRING）、
 *       栈大小（SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER）等，创建后需 SDL_DestroyProperties 释放属性集合
 */
public func SDL_CreateThreadWithProperties_cj(props: UInt32): SDL_Thread {
    return unsafe {
        SDL_CreateThreadWithPropertiesRuntime(props, CPointer<Unit>(), CPointer<Unit>())
    }
}

/**
 * @brief 获取线程名称
 * @param thread 线程指针
 * @return CString 名称（可用 .toString() 转 String）
 */
public func SDL_GetThreadName_cj(thread: SDL_Thread): CString {
    return unsafe {
        SDL_GetThreadName(thread)
    }
}

/**
 * @brief 获取当前线程 ID
 * @return UInt64 线程 ID
 */
public func SDL_GetCurrentThreadID_cj(): UInt64 {
    return unsafe {
        SDL_GetCurrentThreadID()
    }
}

/**
 * @brief 获取指定线程 ID
 * @param thread 线程指针
 * @return UInt64 线程 ID
 */
public func SDL_GetThreadID_cj(thread: SDL_Thread): UInt64 {
    return unsafe {
        SDL_GetThreadID(thread)
    }
}

/**
 * @brief 等待线程结束
 * @param thread 线程指针
 * @param status 输出线程退出码指针（可为 null）
 */
public func SDL_WaitThread_cj(thread: SDL_Thread, status: CPointer<Int32>): Unit {
    unsafe {
        SDL_WaitThread(thread, status)
    }
}

/**
 * @brief 分离线程（自动回收资源）
 * @param thread 线程指针
 */
public func SDL_DetachThread_cj(thread: SDL_Thread): Unit {
    unsafe {
        SDL_DetachThread(thread)
    }
}

// =============================================================================
// 互斥锁（SDL_mutex.h）
// =============================================================================

/**
 * @brief 创建互斥锁
 * @return SDL_Mutex 互斥锁指针（null 表示失败）
 */
public func SDL_CreateMutex_cj(): SDL_Mutex {
    return unsafe {
        SDL_CreateMutex()
    }
}

/**
 * @brief 锁定互斥锁（阻塞）
 * @param mutex 互斥锁指针
 */
public func SDL_LockMutex_cj(mutex: SDL_Mutex): Unit {
    unsafe {
        SDL_LockMutex(mutex)
    }
}

/**
 * @brief 尝试锁定互斥锁（非阻塞）
 * @param mutex 互斥锁指针
 * @return Bool 成功返回 true
 */
public func SDL_TryLockMutex_cj(mutex: SDL_Mutex): Bool {
    return unsafe {
        SDL_TryLockMutex(mutex)
    }
}

/**
 * @brief 解锁互斥锁
 * @param mutex 互斥锁指针
 */
public func SDL_UnlockMutex_cj(mutex: SDL_Mutex): Unit {
    unsafe {
        SDL_UnlockMutex(mutex)
    }
}

/**
 * @brief 销毁互斥锁
 * @param mutex 互斥锁指针
 */
public func SDL_DestroyMutex_cj(mutex: SDL_Mutex): Unit {
    unsafe {
        SDL_DestroyMutex(mutex)
    }
}

// =============================================================================
// 读写锁（SDL_mutex.h）
// =============================================================================

/**
 * @brief 创建读写锁
 * @return SDL_RWLock 读写锁指针（null 表示失败）
 */
public func SDL_CreateRWLock_cj(): SDL_RWLock {
    return unsafe {
        SDL_CreateRWLock()
    }
}

/**
 * @brief 以读模式锁定读写锁（阻塞，可多个读者）
 * @param rwlock 读写锁指针
 */
public func SDL_LockRWLockForReading_cj(rwlock: SDL_RWLock): Unit {
    unsafe {
        SDL_LockRWLockForReading(rwlock)
    }
}

/**
 * @brief 以写模式锁定读写锁（阻塞，独占）
 * @param rwlock 读写锁指针
 */
public func SDL_LockRWLockForWriting_cj(rwlock: SDL_RWLock): Unit {
    unsafe {
        SDL_LockRWLockForWriting(rwlock)
    }
}

/**
 * @brief 尝试以读模式锁定读写锁（非阻塞）
 * @param rwlock 读写锁指针
 * @return Bool 成功返回 true
 */
public func SDL_TryLockRWLockForReading_cj(rwlock: SDL_RWLock): Bool {
    return unsafe {
        SDL_TryLockRWLockForReading(rwlock)
    }
}

/**
 * @brief 尝试以写模式锁定读写锁（非阻塞）
 * @param rwlock 读写锁指针
 * @return Bool 成功返回 true
 */
public func SDL_TryLockRWLockForWriting_cj(rwlock: SDL_RWLock): Bool {
    return unsafe {
        SDL_TryLockRWLockForWriting(rwlock)
    }
}

/**
 * @brief 解锁读写锁
 * @param rwlock 读写锁指针
 */
public func SDL_UnlockRWLock_cj(rwlock: SDL_RWLock): Unit {
    unsafe {
        SDL_UnlockRWLock(rwlock)
    }
}

/**
 * @brief 销毁读写锁
 * @param rwlock 读写锁指针
 */
public func SDL_DestroyRWLock_cj(rwlock: SDL_RWLock): Unit {
    unsafe {
        SDL_DestroyRWLock(rwlock)
    }
}

// =============================================================================
// 信号量（SDL_mutex.h）
// =============================================================================

/**
 * @brief 创建信号量
 * @param initial_value 初始计数值
 * @return SDL_Semaphore 信号量指针（null 表示失败）
 */
public func SDL_CreateSemaphore_cj(initial_value: UInt32): SDL_Semaphore {
    return unsafe {
        SDL_CreateSemaphore(initial_value)
    }
}

/**
 * @brief 销毁信号量
 * @param sem 信号量指针
 */
public func SDL_DestroySemaphore_cj(sem: SDL_Semaphore): Unit {
    unsafe {
        SDL_DestroySemaphore(sem)
    }
}

/**
 * @brief 等待信号量（阻塞，计数值减一）
 * @param sem 信号量指针
 */
public func SDL_WaitSemaphore_cj(sem: SDL_Semaphore): Unit {
    unsafe {
        SDL_WaitSemaphore(sem)
    }
}

/**
 * @brief 尝试等待信号量（非阻塞）
 * @param sem 信号量指针
 * @return Bool 成功返回 true
 */
public func SDL_TryWaitSemaphore_cj(sem: SDL_Semaphore): Bool {
    return unsafe {
        SDL_TryWaitSemaphore(sem)
    }
}

/**
 * @brief 带超时等待信号量
 * @param sem 信号量指针
 * @param timeoutMS 超时毫秒数
 * @return Bool 成功返回 true
 */
public func SDL_WaitSemaphoreTimeout_cj(sem: SDL_Semaphore, timeoutMS: Int32): Bool {
    return unsafe {
        SDL_WaitSemaphoreTimeout(sem, timeoutMS)
    }
}

/**
 * @brief 发送信号量（计数值加一）
 * @param sem 信号量指针
 */
public func SDL_SignalSemaphore_cj(sem: SDL_Semaphore): Unit {
    unsafe {
        SDL_SignalSemaphore(sem)
    }
}

// =============================================================================
// 条件变量（SDL_mutex.h）
// =============================================================================

/**
 * @brief 创建条件变量
 * @return SDL_Condition 条件变量指针（null 表示失败）
 */
public func SDL_CreateCondition_cj(): SDL_Condition {
    return unsafe {
        SDL_CreateCondition()
    }
}

/**
 * @brief 销毁条件变量
 * @param cond 条件变量指针
 */
public func SDL_DestroyCondition_cj(cond: SDL_Condition): Unit {
    unsafe {
        SDL_DestroyCondition(cond)
    }
}

/**
 * @brief 唤醒一个等待线程
 * @param cond 条件变量指针
 */
public func SDL_SignalCondition_cj(cond: SDL_Condition): Unit {
    unsafe {
        SDL_SignalCondition(cond)
    }
}

/**
 * @brief 唤醒所有等待线程
 * @param cond 条件变量指针
 */
public func SDL_BroadcastCondition_cj(cond: SDL_Condition): Unit {
    unsafe {
        SDL_BroadcastCondition(cond)
    }
}

/**
 * @brief 等待条件变量（阻塞，自动释放并重新获取互斥锁）
 * @param cond 条件变量指针
 * @param mutex 互斥锁指针
 * @return Bool 成功返回 true
 */
public func SDL_WaitCondition_cj(cond: SDL_Condition, mutex: SDL_Mutex): Bool {
    return unsafe {
        SDL_WaitCondition(cond, mutex)
    }
}

/**
 * @brief 带超时等待条件变量
 * @param cond 条件变量指针
 * @param mutex 互斥锁指针
 * @param timeoutMS 超时毫秒数
 * @return Bool 成功返回 true
 */
public func SDL_WaitConditionTimeout_cj(cond: SDL_Condition, mutex: SDL_Mutex, timeoutMS: Int32): Bool {
    return unsafe {
        SDL_WaitConditionTimeout(cond, mutex, timeoutMS)
    }
}

/**
 * @brief 设置线程局部存储值
 * @param id TLS 键 ID
 * @param value 要存储的指针值
 * @param destructor 析构函数指针（暂以 CPointer<Unit> 占位，可传 null）
 * @return Bool 成功返回 true
 */
public func SDL_SetTLS_cj(id: UInt32, value: CPointer<Unit>, destructor: CPointer<Unit>): Bool {
    return unsafe {
        SDL_SetTLS(id, value, destructor)
    }
}

/**
 * @brief 获取线程局部存储值
 * @param id TLS 键 ID
 * @return CPointer<Unit> 存储的指针值（未设置返回 null）
 */
public func SDL_GetTLS_cj(id: UInt32): CPointer<Unit> {
    return unsafe {
        SDL_GetTLS(id)
    }
}

/**
 * @brief 清理当前线程的全部线程局部存储
 */
public func SDL_CleanupTLS_cj(): Unit {
    unsafe {
        SDL_CleanupTLS()
    }
}

/**
 * @brief 设置当前线程优先级
 * @param priority 线程优先级（SDL_THREAD_PRIORITY_*）
 * @return Bool 成功返回 true
 */
public func SDL_SetCurrentThreadPriority_cj(priority: Int32): Bool {
    return unsafe {
        SDL_SetCurrentThreadPriority(priority)
    }
}

/**
 * @brief 获取线程状态
 * @param thread 线程指针
 * @return Int32 线程状态（SDL_THREAD_*）
 */
public func SDL_GetThreadState_cj(thread: CPointer<Unit>): Int32 {
    return unsafe {
        SDL_GetThreadState(thread)
    }
}
