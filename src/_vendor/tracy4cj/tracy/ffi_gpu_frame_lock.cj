/**
 * @file tracy4cj.tracy 公共函数包装（第 2 部分：GPU/内存/日志/帧/Plot/锁）
 * @brief TracyC.h 其余 API 的仓颉安全包装函数
 * @explain 与 ffi_exports.cj（第 1 部分）同属公开包装层；本文件覆盖 GPU 事件、
 *         内存分配跟踪、日志消息、帧标记、Plot 曲线、锁跟踪与纤程。
 */
protected package three._vendor.tracy4cj.tracy

// =============================================================================
// GPU 事件（立即提交）
// =============================================================================

/**
 * @brief 开始一个 GPU zone（立即提交）
 * @note C 宏 TracyCGPUZone 底层调用；srcloc 为 allocSrcloc_cj 句柄。
 */
public func emitGpuZoneBegin_cj(data: TracyGpuZoneBeginData): Unit {
    unsafe { ___tracy_emit_gpu_zone_begin(data) }
}

/**
 * @brief 开始一个 GPU zone（带调用栈，立即提交）
 */
public func emitGpuZoneBeginCallstack_cj(data: TracyGpuZoneBeginCallstackData): Unit {
    unsafe { ___tracy_emit_gpu_zone_begin_callstack(data) }
}

/**
 * @brief 开始一个 GPU zone（立即提交，srcloc 由 C 侧拷贝）
 */
public func emitGpuZoneBeginAlloc_cj(data: TracyGpuZoneBeginData): Unit {
    unsafe { ___tracy_emit_gpu_zone_begin_alloc(data) }
}

/**
 * @brief 开始一个 GPU zone（带调用栈，立即提交，srcloc 由 C 侧拷贝）
 */
public func emitGpuZoneBeginAllocCallstack_cj(data: TracyGpuZoneBeginCallstackData): Unit {
    unsafe { ___tracy_emit_gpu_zone_begin_alloc_callstack(data) }
}

/**
 * @brief 结束一个 GPU zone（立即提交）
 */
public func emitGpuZoneEnd_cj(data: TracyGpuZoneEndData): Unit {
    unsafe { ___tracy_emit_gpu_zone_end(data) }
}

/**
 * @brief 提交 GPU 时间戳（立即提交）
 */
public func emitGpuTime_cj(data: TracyGpuTimeData): Unit {
    unsafe { ___tracy_emit_gpu_time(data) }
}

/**
 * @brief 注册 GPU 上下文（立即提交）
 */
public func emitGpuNewContext_cj(data: TracyGpuNewContextData): Unit {
    unsafe { ___tracy_emit_gpu_new_context(data) }
}

/**
 * @brief 命名 GPU 上下文（立即提交）
 */
public func emitGpuContextName_cj(data: TracyGpuContextNameData): Unit {
    unsafe { ___tracy_emit_gpu_context_name(data) }
}

/**
 * @brief 校准 GPU/CPU 时钟（立即提交）
 */
public func emitGpuCalibration_cj(data: TracyGpuCalibrationData): Unit {
    unsafe { ___tracy_emit_gpu_calibration(data) }
}

/**
 * @brief 同步 GPU 时间（立即提交）
 */
public func emitGpuTimeSync_cj(data: TracyGpuTimeSyncData): Unit {
    unsafe { ___tracy_emit_gpu_time_sync(data) }
}

// =============================================================================
// GPU 事件（串行化提交，serial 语义：命令队列按序提交场景）
// =============================================================================

/** @brief 开始一个 GPU zone（串行提交） */
public func emitGpuZoneBeginSerial_cj(data: TracyGpuZoneBeginData): Unit {
    unsafe { ___tracy_emit_gpu_zone_begin_serial(data) }
}

/** @brief 开始一个 GPU zone（带调用栈，串行提交） */
public func emitGpuZoneBeginCallstackSerial_cj(data: TracyGpuZoneBeginCallstackData): Unit {
    unsafe { ___tracy_emit_gpu_zone_begin_callstack_serial(data) }
}

/** @brief 开始一个 GPU zone（串行提交，srcloc 由 C 侧拷贝） */
public func emitGpuZoneBeginAllocSerial_cj(data: TracyGpuZoneBeginData): Unit {
    unsafe { ___tracy_emit_gpu_zone_begin_alloc_serial(data) }
}

/** @brief 开始一个 GPU zone（带调用栈，串行提交，srcloc 由 C 侧拷贝） */
public func emitGpuZoneBeginAllocCallstackSerial_cj(data: TracyGpuZoneBeginCallstackData): Unit {
    unsafe { ___tracy_emit_gpu_zone_begin_alloc_callstack_serial(data) }
}

/** @brief 结束一个 GPU zone（串行提交） */
public func emitGpuZoneEndSerial_cj(data: TracyGpuZoneEndData): Unit {
    unsafe { ___tracy_emit_gpu_zone_end_serial(data) }
}

/** @brief 提交 GPU 时间戳（串行提交） */
public func emitGpuTimeSerial_cj(data: TracyGpuTimeData): Unit {
    unsafe { ___tracy_emit_gpu_time_serial(data) }
}

/** @brief 注册 GPU 上下文（串行提交） */
public func emitGpuNewContextSerial_cj(data: TracyGpuNewContextData): Unit {
    unsafe { ___tracy_emit_gpu_new_context_serial(data) }
}

/** @brief 命名 GPU 上下文（串行提交） */
public func emitGpuContextNameSerial_cj(data: TracyGpuContextNameData): Unit {
    unsafe { ___tracy_emit_gpu_context_name_serial(data) }
}

/** @brief 校准 GPU/CPU 时钟（串行提交） */
public func emitGpuCalibrationSerial_cj(data: TracyGpuCalibrationData): Unit {
    unsafe { ___tracy_emit_gpu_calibration_serial(data) }
}

/** @brief 同步 GPU 时间（串行提交） */
public func emitGpuTimeSyncSerial_cj(data: TracyGpuTimeSyncData): Unit {
    unsafe { ___tracy_emit_gpu_time_sync_serial(data) }
}

// =============================================================================
// 内存分配跟踪
// =============================================================================

/**
 * @brief 报告一次内存分配
 * @param ptr 内存指针
 * @param size 字节数
 * @note C 宏 TracyCAlloc（无调用栈版）。
 */
public func emitMemoryAlloc_cj(ptr: CPointer<Unit>, size: UIntNative): Unit {
    unsafe { ___tracy_emit_memory_alloc(ptr, size) }
}

/**
 * @brief 报告一次内存分配（采集调用栈）
 * @param depth 调用栈深度
 * @note C 宏 TracyCAllocS。
 */
public func emitMemoryAllocCallstack_cj(ptr: CPointer<Unit>, size: UIntNative, depth: Int32): Unit {
    unsafe { ___tracy_emit_memory_alloc_callstack(ptr, size, depth) }
}

/**
 * @brief 报告一次内存释放
 * @note C 宏 TracyCFree（无调用栈版）。
 */
public func emitMemoryFree_cj(ptr: CPointer<Unit>): Unit {
    unsafe { ___tracy_emit_memory_free(ptr) }
}

/**
 * @brief 报告一次内存释放（采集调用栈）
 * @note C 宏 TracyCFreeS。
 */
public func emitMemoryFreeCallstack_cj(ptr: CPointer<Unit>, depth: Int32): Unit {
    unsafe { ___tracy_emit_memory_free_callstack(ptr, depth) }
}

/**
 * @brief 报告一次命名内存池的分配
 * @param name 内存池名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 */
public func emitMemoryAllocNamed_cj(ptr: CPointer<Unit>, size: UIntNative, name: CString): Unit {
    unsafe { ___tracy_emit_memory_alloc_named(ptr, size, name.getChars()) }
}

/**
 * @brief 报告一次命名内存池的分配（采集调用栈）
 * @param name 内存池名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 */
public func emitMemoryAllocCallstackNamed_cj(ptr: CPointer<Unit>, size: UIntNative,
                                             depth: Int32, name: CString): Unit {
    unsafe { ___tracy_emit_memory_alloc_callstack_named(ptr, size, depth, name.getChars()) }
}

/**
 * @brief 报告一次命名内存池的释放
 * @param name 内存池名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 */
public func emitMemoryFreeNamed_cj(ptr: CPointer<Unit>, name: CString): Unit {
    unsafe { ___tracy_emit_memory_free_named(ptr, name.getChars()) }
}

/**
 * @brief 报告一次命名内存池的释放（采集调用栈）
 * @param name 内存池名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 */
public func emitMemoryFreeCallstackNamed_cj(ptr: CPointer<Unit>, depth: Int32, name: CString): Unit {
    unsafe { ___tracy_emit_memory_free_callstack_named(ptr, depth, name.getChars()) }
}

/**
 * @brief 丢弃命名内存池（该池所有未释放分配标记为泄漏结束）
 * @param name 内存池名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 */
public func emitMemoryDiscard_cj(name: CString): Unit {
    unsafe { ___tracy_emit_memory_discard(name.getChars()) }
}

/**
 * @brief 丢弃命名内存池（采集调用栈）
 * @param name 内存池名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 */
public func emitMemoryDiscardCallstack_cj(name: CString, depth: Int32): Unit {
    unsafe { ___tracy_emit_memory_discard_callstack(name.getChars(), depth) }
}

// =============================================================================
// 日志消息
// =============================================================================

/**
 * @brief 发送一条日志消息（完整参数版）
 * @param severity 消息级别
 * @param color 消息颜色（0 = 默认）
 * @param callstackDepth 调用栈采集深度（0 = 不采集）
 * @param txt 消息内容（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCMessage/TracyCMessageC 底层调用。
 */
public func emitLogString_cj(severity: TracyMessageSeverity, color: Int32,
                             callstackDepth: Int32, txt: CString): Unit {
    unsafe { ___tracy_emit_logString(Int8(severity.value()), color, callstackDepth, UIntNative(txt.size()), txt.getChars()) }
}

/**
 * @brief 发送一条日志消息（C 字符串版，长度自动取 NUL 前缀）
 * @param txt 消息内容（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCMessageL/TracyCMessageLC 底层调用。
 */
public func emitLogStringL_cj(severity: TracyMessageSeverity, color: Int32, txt: CString): Unit {
    unsafe { ___tracy_emit_logStringL(Int8(severity.value()), color, TRACY_CALLSTACK, txt.getChars()) }
}

// =============================================================================
// 帧标记
// =============================================================================

/**
 * @brief 标记一帧结束（主帧，name 为空）
 * @note C 宏 TracyCFrameMark。
 */
public func frameMark_cj(): Unit {
    unsafe { ___tracy_emit_frame_mark(CPointer<UInt8>()) }
}

/**
 * @brief 标记一帧结束（命名帧）
 * @param name 帧名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCFrameMarkNamed。
 */
public func frameMarkNamed_cj(name: CString): Unit {
    unsafe { ___tracy_emit_frame_mark(name.getChars()) }
}

/**
 * @brief 标记命名帧开始（与 frameMarkEnd_cj 配对，可嵌套多帧流）
 * @param name 帧名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCFrameMarkStart。
 */
public func frameMarkStart_cj(name: CString): Unit {
    unsafe { ___tracy_emit_frame_mark_start(name.getChars()) }
}

/**
 * @brief 标记命名帧结束
 * @param name 帧名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCFrameMarkEnd。
 */
public func frameMarkEnd_cj(name: CString): Unit {
    unsafe { ___tracy_emit_frame_mark_end(name.getChars()) }
}

/**
 * @brief 提交一帧画面缩略图（显示在帧时间轴上）
 * @param image 像素数据（RGBA 8bit，按行排列）
 * @param width 图像宽
 * @param height 图像高
 * @param offset 像素数据起始偏移字节数
 * @param flip 是否垂直翻转（0/1）
 * @note C 宏 TracyCFrameImage。
 */
public func frameImage_cj(image: CPointer<Unit>, width: UInt16, height: UInt16,
                          offset: UInt8, flip: Bool): Unit {
    unsafe { ___tracy_emit_frame_image(image, width, height, offset, if (flip) { 1 } else { 0 }) }
}

// =============================================================================
// Plot 曲线图
// =============================================================================

/**
 * @brief 绘制一个浮点数据点
 * @param name 曲线名称（同名聚为一条曲线；NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCPlot。
 */
public func plot_cj(name: CString, value: Float64): Unit {
    unsafe { ___tracy_emit_plot(name.getChars(), value) }
}

/**
 * @brief 绘制一个单精度浮点数据点
 * @param name 曲线名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCPlotF。
 */
public func plotFloat_cj(name: CString, value: Float32): Unit {
    unsafe { ___tracy_emit_plot_float(name.getChars(), value) }
}

/**
 * @brief 绘制一个整数数据点
 * @param name 曲线名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCPlotI。
 */
public func plotInt_cj(name: CString, value: Int64): Unit {
    unsafe { ___tracy_emit_plot_int(name.getChars(), value) }
}

/**
 * @brief 配置曲线显示属性
 * @param name 曲线名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @param format 数值格式（TracyPlotFormat）
 * @param step 是否阶梯状连线（false = 平滑）
 * @param fill 是否填充（false = 仅线）
 * @param color 颜色（0 = 默认配色）
 * @note C 宏 TracyCPlotConfig。
 */
public func plotConfig_cj(name: CString, format: TracyPlotFormat, step: Bool,
                          fill: Bool, color: UInt32): Unit {
    unsafe { ___tracy_emit_plot_config(name.getChars(), format.value(),
                                       if (step) { 1 } else { 0 },
                                       if (fill) { 1 } else { 0 }, color) }
}

/**
 * @brief 设置应用程序信息（profiler 窗口标题旁显示）
 * @param txt 应用信息（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCAppInfo。
 */
public func messageAppInfo_cj(txt: CString): Unit {
    unsafe { ___tracy_emit_message_appinfo(txt.getChars(), UIntNative(txt.size())) }
}

// =============================================================================
// 可锁定上下文（Lockable，互斥锁跟踪）
// =============================================================================

/**
 * @brief 注册一个互斥锁跟踪上下文
 * @param srcloc 源位置指针。C 侧仅保存指针而不拷贝数据，srcloc 必须由调用方
 *               保证生命周期（通常为 static 或其他长生命周期存储），
 *               且在 profiler 运行期间保持有效。
 * @return 锁上下文句柄（传给其余 lockable API）
 * @note C 宏 TracyCLockAnnounce。
 */
public func announceLockableCtx_cj(srcloc: CPointer<TracySourceLocationData>): CPointer<Unit> {
    return unsafe { ___tracy_announce_lockable_ctx(srcloc) }
}

/**
 * @brief 注销互斥锁跟踪上下文
 * @note C 宏 TracyCLockTerminate。
 */
public func terminateLockableCtx_cj(lockdata: CPointer<Unit>): Unit {
    unsafe { ___tracy_terminate_lockable_ctx(lockdata) }
}

/**
 * @brief 加锁前调用（记录等待开始）
 * @return 1 = 锁不可用（进入等待），0 = 锁空闲
 * @note C 宏 TracyCLockBeforeLock。
 */
public func beforeLockLockableCtx_cj(lockdata: CPointer<Unit>): Bool {
    return unsafe { ___tracy_before_lock_lockable_ctx(lockdata) } != 0
}

/**
 * @brief 加锁成功后调用
 * @note C 宏 TracyCLockAfterLock。
 */
public func afterLockLockableCtx_cj(lockdata: CPointer<Unit>): Unit {
    unsafe { ___tracy_after_lock_lockable_ctx(lockdata) }
}

/**
 * @brief 解锁后调用
 * @note C 宏 TracyCLockAfterUnlock。
 */
public func afterUnlockLockableCtx_cj(lockdata: CPointer<Unit>): Unit {
    unsafe { ___tracy_after_unlock_lockable_ctx(lockdata) }
}

/**
 * @brief try_lock 之后调用
 * @param acquired 是否获取成功
 * @note C 宏 TracyCLockAfterTryLock。
 */
public func afterTryLockLockableCtx_cj(lockdata: CPointer<Unit>, acquired: Bool): Unit {
    unsafe { ___tracy_after_try_lock_lockable_ctx(lockdata, if (acquired) { 1 } else { 0 }) }
}

/**
 * @brief 标记锁事件发生位置（记录竞争）
 * @param srcloc 源位置指针。C 侧仅保存指针而不拷贝数据，srcloc 必须由调用方
 *               保证生命周期（通常为 static 或其他长生命周期存储），
 *               且在 profiler 运行期间保持有效。
 * @note C 宏 TracyCLockMark。
 */
public func markLockableCtx_cj(lockdata: CPointer<Unit>, srcloc: CPointer<TracySourceLocationData>): Unit {
    unsafe { ___tracy_mark_lockable_ctx(lockdata, srcloc) }
}

/**
 * @brief 自定义锁名称（profiler 显示）
 * @param name 锁名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCLockCustomName。
 */
public func customNameLockableCtx_cj(lockdata: CPointer<Unit>, name: CString): Unit {
    unsafe { ___tracy_custom_name_lockable_ctx(lockdata, name.getChars(), UIntNative(name.size())) }
}

// =============================================================================
// 共享可锁定上下文（Shared Lockable，读写锁跟踪）
// =============================================================================

/**
 * @brief 注册一个读写锁跟踪上下文
 * @param srcloc 源位置指针。C 侧仅保存指针而不拷贝数据，srcloc 必须由调用方
 *               保证生命周期（通常为 static 或其他长生命周期存储），
 *               且在 profiler 运行期间保持有效。
 * @return 锁上下文句柄（传给其余 shared lockable API）
 * @note C 宏 TracyCSharedLockAnnounce。
 */
public func announceSharedLockableCtx_cj(srcloc: CPointer<TracySourceLocationData>): CPointer<Unit> {
    return unsafe { ___tracy_announce_shared_lockable_ctx(srcloc) }
}

/**
 * @brief 注销读写锁跟踪上下文
 * @note C 宏 TracyCSharedLockTerminate。
 */
public func terminateSharedLockableCtx_cj(lockdata: CPointer<Unit>): Unit {
    unsafe { ___tracy_terminate_shared_lockable_ctx(lockdata) }
}

/**
 * @brief 加锁（独占）前调用
 * @return 1 = 锁不可用，0 = 锁空闲
 * @note C 宏 TracyCSharedLockBeforeLock。
 */
public func beforeLockSharedLockableCtx_cj(lockdata: CPointer<Unit>): Bool {
    return unsafe { ___tracy_before_lock_shared_lockable_ctx(lockdata) } != 0
}

/**
 * @brief 加锁（独占）成功后调用
 * @note C 宏 TracyCSharedLockAfterLock。
 */
public func afterLockSharedLockableCtx_cj(lockdata: CPointer<Unit>): Unit {
    unsafe { ___tracy_after_lock_shared_lockable_ctx(lockdata) }
}

/**
 * @brief 解锁（独占）后调用
 * @note C 宏 TracyCSharedLockAfterUnlock。
 */
public func afterUnlockSharedLockableCtx_cj(lockdata: CPointer<Unit>): Unit {
    unsafe { ___tracy_after_unlock_shared_lockable_ctx(lockdata) }
}

/**
 * @brief try_lock（独占）之后调用
 * @note C 宏 TracyCSharedLockAfterTryLock。
 */
public func afterTryLockSharedLockableCtx_cj(lockdata: CPointer<Unit>, acquired: Bool): Unit {
    unsafe { ___tracy_after_try_lock_shared_lockable_ctx(lockdata, if (acquired) { 1 } else { 0 }) }
}

/**
 * @brief 加共享锁前调用
 * @return 1 = 写锁占用，0 = 可共享
 * @note C 宏 TracyCSharedLockBeforeSharedLock。
 */
public func beforeLockSharedSharedLockableCtx_cj(lockdata: CPointer<Unit>): Bool {
    return unsafe { ___tracy_before_lock_shared_shared_lockable_ctx(lockdata) } != 0
}

/**
 * @brief 加共享锁成功后调用
 * @note C 宏 TracyCSharedLockAfterSharedLock。
 */
public func afterLockSharedSharedLockableCtx_cj(lockdata: CPointer<Unit>): Unit {
    unsafe { ___tracy_after_lock_shared_shared_lockable_ctx(lockdata) }
}

/**
 * @brief 解共享锁后调用
 * @note C 宏 TracyCSharedLockAfterSharedUnlock。
 */
public func afterUnlockSharedSharedLockableCtx_cj(lockdata: CPointer<Unit>): Unit {
    unsafe { ___tracy_after_unlock_shared_shared_lockable_ctx(lockdata) }
}

/**
 * @brief try 共享锁之后调用
 * @note C 宏 TracyCSharedLockAfterTrySharedLock。
 */
public func afterTryLockSharedSharedLockableCtx_cj(lockdata: CPointer<Unit>, acquired: Bool): Unit {
    unsafe { ___tracy_after_try_lock_shared_shared_lockable_ctx(lockdata, if (acquired) { 1 } else { 0 }) }
}

/**
 * @brief 标记读写锁事件发生位置
 * @param srcloc 源位置指针。C 侧仅保存指针而不拷贝数据，srcloc 必须由调用方
 *               保证生命周期（通常为 static 或其他长生命周期存储），
 *               且在 profiler 运行期间保持有效。
 * @note C 宏 TracyCSharedLockMark。
 */
public func markSharedLockableCtx_cj(lockdata: CPointer<Unit>, srcloc: CPointer<TracySourceLocationData>): Unit {
    unsafe { ___tracy_mark_shared_lockable_ctx(lockdata, srcloc) }
}

/**
 * @brief 自定义读写锁名称（profiler 显示）
 * @param name 锁名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCSharedLockCustomName。
 */
public func customNameSharedLockableCtx_cj(lockdata: CPointer<Unit>, name: CString): Unit {
    unsafe { ___tracy_custom_name_shared_lockable_ctx(lockdata, name.getChars(), UIntNative(name.size())) }
}

// =============================================================================
// 纤程（TRACY_FIBERS 构建选项启用时可用）
// =============================================================================

/**
 * @brief 通知 profiler 切换到指定纤程
 * @param fiber 纤程名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note 需要 C 侧以 TRACY_FIBERS 构建 libtracyc.a；C 宏 TracyCFiberEnter。
 */
public func fiberEnter_cj(fiber: CString): Unit {
    unsafe { ___tracy_fiber_enter(fiber.getChars()) }
}

/**
 * @brief 通知 profiler 离开当前纤程
 * @note 需要 C 侧以 TRACY_FIBERS 构建；C 宏 TracyCFiberLeave。
 */
public func fiberLeave_cj(): Unit {
    unsafe { ___tracy_fiber_leave() }
}
