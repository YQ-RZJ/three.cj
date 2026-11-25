/**
 * @file tracy4cj.tracy 公共函数包装（第 1 部分：线程/源位置/Zone）
 * @brief TracyC.h 核心 API 的仓颉安全包装函数
 * @explain 本文件为每个 foreign 函数提供 `_cj` 后缀的公共包装，所有 foreign
 *         调用被包裹在 unsafe 块中以满足仓颉 FFI 要求。字符串参数统一使用
 *         CString（C 字符串指针），由调用方保证其生命周期与有效性。
 * @note TracyC.h 中的 *_fmt 可变参数变体（printf 形态）不提供绑定；如需格式化
 *       请在仓颉侧先拼接字符串再调用对应非 fmt 版本。
 */
protected package three._vendor.tracy4cj.tracy

import std.convert.*
import std.core.*

// =============================================================================
// 线程与探针状态
// =============================================================================

/**
 * @brief 设置当前线程在 profiler 中显示的名称
 * @param name 线程名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCSetThreadName。
 */
public func setThreadName_cj(name: CString): Unit {
    unsafe { ___tracy_set_thread_name(name.getChars()) }
}

/**
 * @brief profiler 是否已连接到服务器
 * @return 1 = 已连接，0 = 未连接
 * @note C 宏 TracyCIsConnected。
 */
public func isConnected_cj(): Bool {
    return unsafe { ___tracy_connected() } != 0
}

/**
 * @brief 获取 Tracy 高精度时间基准当前值
 * @return 当前时间戳（Tracy 时钟域）
 */
public func getTime_cj(): Int64 {
    return unsafe { ___tracy_get_time() }
}

/**
 * @brief 开始采样分析（sampling profiling）
 * @return 非 0 表示成功启动
 */
public func beginSamplingProfiling_cj(): Bool {
    return unsafe { ___tracy_begin_sampling_profiling() } != 0
}

/**
 * @brief 结束采样分析
 */
public func endSamplingProfiling_cj(): Unit {
    unsafe { ___tracy_end_sampling_profiling() }
}

// =============================================================================
// 源位置分配
// =============================================================================

/**
 * @brief 分配一个源位置（zone 用，返回句柄）
 * @param line 行号
 * @param source 文件名（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @param function 函数名（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @param color 颜色（0xAABBGGRR，0 = 默认）
 * @return 源位置句柄（emit_zone_begin_alloc 系列使用）
 */
public func allocSrcloc_cj(line: UInt32, source: CString, function: CString, color: UInt32): UInt64 {
    return unsafe { ___tracy_alloc_srcloc(line, source.getChars(), UIntNative(source.size()), function.getChars(), UIntNative(function.size()), color) }
}

/**
 * @brief 分配一个带自定义名称的源位置（zone 用，返回句柄）
 * @param line 行号
 * @param source 文件名（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @param function 函数名（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @param name zone 自定义名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @param color 颜色（0xAABBGGRR，0 = 默认）
 * @return 源位置句柄
 */
public func allocSrclocName_cj(line: UInt32, source: CString, function: CString,
                               name: CString, color: UInt32): UInt64 {
    return unsafe { ___tracy_alloc_srcloc_name(line, source.getChars(), UIntNative(source.size()), function.getChars(), UIntNative(function.size()),
                                                name.getChars(), UIntNative(name.size()), color) }
}

// =============================================================================
// Zone（CPU 代码段计时）
// =============================================================================

/**
 * @brief 开始一个 zone（静态源位置，无调用栈）
 * @param srcloc 源位置指针。C 侧仅保存指针而不拷贝数据，srcloc 必须由调用方
 *               保证生命周期（通常为 static 或其他长生命周期存储），
 *               且在 profiler 运行期间保持有效。
 * @param active 是否记录（0 可跳过采集开销）
 * @return zone 上下文（传给 end/text/name/color/value 与 emitZoneEnd_cj）
 * @note C 宏 TracyCZone 底层调用。
 */
public func emitZoneBegin_cj(srcloc: CPointer<TracySourceLocationData>, active: Bool): TracyCZoneCtx {
    return unsafe { ___tracy_emit_zone_begin(srcloc, if (active) { 1 } else { 0 }) }
}

/**
 * @brief 开始一个 zone（静态源位置，采集调用栈）
 * @param srcloc 源位置指针。C 侧仅保存指针而不拷贝数据，srcloc 必须由调用方
 *               保证生命周期（通常为 static 或其他长生命周期存储），
 *               且在 profiler 运行期间保持有效。
 * @param depth 调用栈采集深度（<=0 等价无调用栈）
 * @param active 是否记录
 * @return zone 上下文
 */
public func emitZoneBeginCallstack_cj(srcloc: CPointer<TracySourceLocationData>, depth: Int32, active: Bool): TracyCZoneCtx {
    return unsafe { ___tracy_emit_zone_begin_callstack(srcloc, depth, if (active) { 1 } else { 0 }) }
}

/**
 * @brief 开始一个 zone（动态源位置句柄，无调用栈）
 * @param srcloc allocSrcloc_cj / allocSrclocName_cj 返回的句柄
 * @param active 是否记录
 * @return zone 上下文
 */
public func emitZoneBeginAlloc_cj(srcloc: UInt64, active: Bool): TracyCZoneCtx {
    return unsafe { ___tracy_emit_zone_begin_alloc(srcloc, if (active) { 1 } else { 0 }) }
}

/**
 * @brief 开始一个 zone（动态源位置句柄，采集调用栈）
 * @param srcloc 源位置句柄
 * @param depth 调用栈采集深度
 * @param active 是否记录
 * @return zone 上下文
 */
public func emitZoneBeginAllocCallstack_cj(srcloc: UInt64, depth: Int32, active: Bool): TracyCZoneCtx {
    return unsafe { ___tracy_emit_zone_begin_alloc_callstack(srcloc, depth, if (active) { 1 } else { 0 }) }
}

/**
 * @brief 结束一个 zone（与 begin 配对）
 * @param ctx emitZoneBegin* 返回的上下文
 * @note C 宏 TracyCZoneEnd。
 */
public func emitZoneEnd_cj(ctx: TracyCZoneCtx): Unit {
    unsafe { ___tracy_emit_zone_end(ctx) }
}

/**
 * @brief 为 zone 附加文本说明
 * @param ctx zone 上下文
 * @param txt 文本内容（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCZoneText。
 */
public func emitZoneText_cj(ctx: TracyCZoneCtx, txt: CString): Unit {
    unsafe { ___tracy_emit_zone_text(ctx, txt.getChars(), UIntNative(txt.size())) }
}

/**
 * @brief 重命名 zone（覆盖源位置默认名称）
 * @param ctx zone 上下文
 * @param txt zone 名称（NUL 结尾的 C 字符串，须由调用方保证生命周期）
 * @note C 宏 TracyCZoneName。
 */
public func emitZoneName_cj(ctx: TracyCZoneCtx, txt: CString): Unit {
    unsafe { ___tracy_emit_zone_name(ctx, txt.getChars(), UIntNative(txt.size())) }
}

/**
 * @brief 设置 zone 颜色
 * @param ctx zone 上下文
 * @param color 颜色（0xAABBGGRR）
 * @note C 宏 TracyCZoneColor。
 */
public func emitZoneColor_cj(ctx: TracyCZoneCtx, color: UInt32): Unit {
    unsafe { ___tracy_emit_zone_color(ctx, color) }
}

/**
 * @brief 为 zone 附加数值（可绘制 mini 图）
 * @param ctx zone 上下文
 * @param value 数值
 * @note C 宏 TracyCZoneValue。
 */
public func emitZoneValue_cj(ctx: TracyCZoneCtx, value: UInt64): Unit {
    unsafe { ___tracy_emit_zone_value(ctx, value) }
}
