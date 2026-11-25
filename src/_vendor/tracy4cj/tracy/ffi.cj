/**
 * @file tracy4cj.tracy C FFI 函数声明（TracyC.h 全量）
 * @brief TracyC.h 全部公开 API 的 foreign 函数声明
 * @explain 本文件包含 TracyC.h 中全部 TRACY_API 函数的 foreign 声明。
 *         - TracyCZoneCtx 按值传递/返回（@C 结构体，C ABI 兼容）；
 *         - TracyCLockCtx / TracyCSharedLockCtx 为不透明指针（CPointer<Unit>）；
 *         - const char* 用 CPointer<UInt8>；size_t 用 UIntNative；
 *         - 可变参数函数（zone_text_fmt 等 printf 形态）无法在仓颉侧声明，
 *           以 CStr 结尾的 _fmt 变体不绑定。
 * @note 本文件的函数是包级私有，外部调用请使用 ffi_exports.cj 中的 _cj 包装。
 */
protected package three._vendor.tracy4cj.tracy

// =============================================================================
// 线程与探针生命周期
// =============================================================================

@FastNative
foreign func ___tracy_set_thread_name(name: CPointer<UInt8>): Unit

@FastNative
foreign func ___tracy_connected(): Int32

@FastNative
foreign func ___tracy_get_time(): Int64

foreign func ___tracy_begin_sampling_profiling(): Int32

foreign func ___tracy_end_sampling_profiling(): Unit

// =============================================================================
// 源位置分配
// =============================================================================

@FastNative
foreign func ___tracy_alloc_srcloc(line: UInt32, source: CPointer<UInt8>, sourceSz: UIntNative,
                                   function: CPointer<UInt8>, functionSz: UIntNative,
                                   color: UInt32): UInt64

@FastNative
foreign func ___tracy_alloc_srcloc_name(line: UInt32, source: CPointer<UInt8>, sourceSz: UIntNative,
                                        function: CPointer<UInt8>, functionSz: UIntNative,
                                        name: CPointer<UInt8>, nameSz: UIntNative,
                                        color: UInt32): UInt64

// =============================================================================
// Zone（CPU 代码段计时）
// =============================================================================

@FastNative
foreign func ___tracy_emit_zone_begin(srcloc: CPointer<TracySourceLocationData>, active: Int32): TracyCZoneCtx

foreign func ___tracy_emit_zone_begin_callstack(srcloc: CPointer<TracySourceLocationData>,
                                                depth: Int32, active: Int32): TracyCZoneCtx

@FastNative
foreign func ___tracy_emit_zone_begin_alloc(srcloc: UInt64, active: Int32): TracyCZoneCtx

foreign func ___tracy_emit_zone_begin_alloc_callstack(srcloc: UInt64, depth: Int32, active: Int32): TracyCZoneCtx

@FastNative
foreign func ___tracy_emit_zone_end(ctx: TracyCZoneCtx): Unit

@FastNative
foreign func ___tracy_emit_zone_text(ctx: TracyCZoneCtx, txt: CPointer<UInt8>, size: UIntNative): Unit

@FastNative
foreign func ___tracy_emit_zone_name(ctx: TracyCZoneCtx, txt: CPointer<UInt8>, size: UIntNative): Unit

@FastNative
foreign func ___tracy_emit_zone_color(ctx: TracyCZoneCtx, color: UInt32): Unit

@FastNative
foreign func ___tracy_emit_zone_value(ctx: TracyCZoneCtx, value: UInt64): Unit

// =============================================================================
// GPU 事件（立即提交）
// =============================================================================

@FastNative
foreign func ___tracy_emit_gpu_zone_begin(data: TracyGpuZoneBeginData): Unit

foreign func ___tracy_emit_gpu_zone_begin_callstack(data: TracyGpuZoneBeginCallstackData): Unit

@FastNative
foreign func ___tracy_emit_gpu_zone_begin_alloc(data: TracyGpuZoneBeginData): Unit

foreign func ___tracy_emit_gpu_zone_begin_alloc_callstack(data: TracyGpuZoneBeginCallstackData): Unit

@FastNative
foreign func ___tracy_emit_gpu_zone_end(data: TracyGpuZoneEndData): Unit

@FastNative
foreign func ___tracy_emit_gpu_time(data: TracyGpuTimeData): Unit

@FastNative
foreign func ___tracy_emit_gpu_new_context(data: TracyGpuNewContextData): Unit

@FastNative
foreign func ___tracy_emit_gpu_context_name(data: TracyGpuContextNameData): Unit

@FastNative
foreign func ___tracy_emit_gpu_calibration(data: TracyGpuCalibrationData): Unit

@FastNative
foreign func ___tracy_emit_gpu_time_sync(data: TracyGpuTimeSyncData): Unit

// =============================================================================
// GPU 事件（串行化提交，serial 语义）
// =============================================================================

@FastNative
foreign func ___tracy_emit_gpu_zone_begin_serial(data: TracyGpuZoneBeginData): Unit

foreign func ___tracy_emit_gpu_zone_begin_callstack_serial(data: TracyGpuZoneBeginCallstackData): Unit

@FastNative
foreign func ___tracy_emit_gpu_zone_begin_alloc_serial(data: TracyGpuZoneBeginData): Unit

foreign func ___tracy_emit_gpu_zone_begin_alloc_callstack_serial(data: TracyGpuZoneBeginCallstackData): Unit

@FastNative
foreign func ___tracy_emit_gpu_zone_end_serial(data: TracyGpuZoneEndData): Unit

@FastNative
foreign func ___tracy_emit_gpu_time_serial(data: TracyGpuTimeData): Unit

@FastNative
foreign func ___tracy_emit_gpu_new_context_serial(data: TracyGpuNewContextData): Unit

@FastNative
foreign func ___tracy_emit_gpu_context_name_serial(data: TracyGpuContextNameData): Unit

@FastNative
foreign func ___tracy_emit_gpu_calibration_serial(data: TracyGpuCalibrationData): Unit

@FastNative
foreign func ___tracy_emit_gpu_time_sync_serial(data: TracyGpuTimeSyncData): Unit

// =============================================================================
// 内存分配跟踪
// =============================================================================

@FastNative
foreign func ___tracy_emit_memory_alloc(ptr: CPointer<Unit>, size: UIntNative): Unit

foreign func ___tracy_emit_memory_alloc_callstack(ptr: CPointer<Unit>, size: UIntNative, depth: Int32): Unit

@FastNative
foreign func ___tracy_emit_memory_free(ptr: CPointer<Unit>): Unit

foreign func ___tracy_emit_memory_free_callstack(ptr: CPointer<Unit>, depth: Int32): Unit

@FastNative
foreign func ___tracy_emit_memory_alloc_named(ptr: CPointer<Unit>, size: UIntNative, name: CPointer<UInt8>): Unit

foreign func ___tracy_emit_memory_alloc_callstack_named(ptr: CPointer<Unit>, size: UIntNative,
                                                        depth: Int32, name: CPointer<UInt8>): Unit

@FastNative
foreign func ___tracy_emit_memory_free_named(ptr: CPointer<Unit>, name: CPointer<UInt8>): Unit

foreign func ___tracy_emit_memory_free_callstack_named(ptr: CPointer<Unit>, depth: Int32,
                                                       name: CPointer<UInt8>): Unit

@FastNative
foreign func ___tracy_emit_memory_discard(name: CPointer<UInt8>): Unit

foreign func ___tracy_emit_memory_discard_callstack(name: CPointer<UInt8>, depth: Int32): Unit

// =============================================================================
// 日志消息
// =============================================================================

foreign func ___tracy_emit_logString(severity: Int8, color: Int32, callstack_depth: Int32,
                                     size: UIntNative, txt: CPointer<UInt8>): Unit

foreign func ___tracy_emit_logStringL(severity: Int8, color: Int32, callstack_depth: Int32,
                                      txt: CPointer<UInt8>): Unit

// =============================================================================
// 帧标记
// =============================================================================

@FastNative
foreign func ___tracy_emit_frame_mark(name: CPointer<UInt8>): Unit

@FastNative
foreign func ___tracy_emit_frame_mark_start(name: CPointer<UInt8>): Unit

@FastNative
foreign func ___tracy_emit_frame_mark_end(name: CPointer<UInt8>): Unit

foreign func ___tracy_emit_frame_image(image: CPointer<Unit>, w: UInt16, h: UInt16,
                                       offset: UInt8, flip: Int32): Unit

// =============================================================================
// Plot 曲线图
// =============================================================================

@FastNative
foreign func ___tracy_emit_plot(name: CPointer<UInt8>, value: Float64): Unit

@FastNative
foreign func ___tracy_emit_plot_float(name: CPointer<UInt8>, value: Float32): Unit

@FastNative
foreign func ___tracy_emit_plot_int(name: CPointer<UInt8>, value: Int64): Unit

@FastNative
foreign func ___tracy_emit_plot_config(name: CPointer<UInt8>, kind: Int32, step: Int32,
                                       fill: Int32, color: UInt32): Unit

@FastNative
foreign func ___tracy_emit_message_appinfo(txt: CPointer<UInt8>, size: UIntNative): Unit

// =============================================================================
// 可锁定上下文（Lockable，互斥锁跟踪）
// =============================================================================

@FastNative
foreign func ___tracy_announce_lockable_ctx(srcloc: CPointer<TracySourceLocationData>): CPointer<Unit>

@FastNative
foreign func ___tracy_terminate_lockable_ctx(lockdata: CPointer<Unit>): Unit

@FastNative
foreign func ___tracy_before_lock_lockable_ctx(lockdata: CPointer<Unit>): Int32

@FastNative
foreign func ___tracy_after_lock_lockable_ctx(lockdata: CPointer<Unit>): Unit

@FastNative
foreign func ___tracy_after_unlock_lockable_ctx(lockdata: CPointer<Unit>): Unit

@FastNative
foreign func ___tracy_after_try_lock_lockable_ctx(lockdata: CPointer<Unit>, acquired: Int32): Unit

@FastNative
foreign func ___tracy_mark_lockable_ctx(lockdata: CPointer<Unit>,
                                       srcloc: CPointer<TracySourceLocationData>): Unit

@FastNative
foreign func ___tracy_custom_name_lockable_ctx(lockdata: CPointer<Unit>, name: CPointer<UInt8>,
                                               nameSz: UIntNative): Unit

// =============================================================================
// 共享可锁定上下文（Shared Lockable，读写锁跟踪）
// =============================================================================

@FastNative
foreign func ___tracy_announce_shared_lockable_ctx(srcloc: CPointer<TracySourceLocationData>): CPointer<Unit>

@FastNative
foreign func ___tracy_terminate_shared_lockable_ctx(lockdata: CPointer<Unit>): Unit

@FastNative
foreign func ___tracy_before_lock_shared_lockable_ctx(lockdata: CPointer<Unit>): Int32

@FastNative
foreign func ___tracy_after_lock_shared_lockable_ctx(lockdata: CPointer<Unit>): Unit

@FastNative
foreign func ___tracy_after_unlock_shared_lockable_ctx(lockdata: CPointer<Unit>): Unit

@FastNative
foreign func ___tracy_after_try_lock_shared_lockable_ctx(lockdata: CPointer<Unit>, acquired: Int32): Unit

@FastNative
foreign func ___tracy_before_lock_shared_shared_lockable_ctx(lockdata: CPointer<Unit>): Int32

@FastNative
foreign func ___tracy_after_lock_shared_shared_lockable_ctx(lockdata: CPointer<Unit>): Unit

@FastNative
foreign func ___tracy_after_unlock_shared_shared_lockable_ctx(lockdata: CPointer<Unit>): Unit

@FastNative
foreign func ___tracy_after_try_lock_shared_shared_lockable_ctx(lockdata: CPointer<Unit>,
                                                                acquired: Int32): Unit

@FastNative
foreign func ___tracy_mark_shared_lockable_ctx(lockdata: CPointer<Unit>,
                                               srcloc: CPointer<TracySourceLocationData>): Unit

@FastNative
foreign func ___tracy_custom_name_shared_lockable_ctx(lockdata: CPointer<Unit>, name: CPointer<UInt8>,
                                                      nameSz: UIntNative): Unit

// =============================================================================
// 纤程（TRACY_FIBERS 构建选项启用）
// =============================================================================

@FastNative
foreign func ___tracy_fiber_enter(fiber: CPointer<UInt8>): Unit

@FastNative
foreign func ___tracy_fiber_leave(): Unit
