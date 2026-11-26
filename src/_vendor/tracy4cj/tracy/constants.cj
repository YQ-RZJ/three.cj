/**
 * @file tracy4cj.tracy 常量定义
 * @brief TracyC.h 中的宏常量的仓颉版本
 * @explain 本文件包含 TracyC.h 中有意义的 #define 常量（过滤纯 C 语法宏）。
 *         TRACY_CALLSTACK 默认 0（不采集调用栈），可按需传入更深的采集深度。
 * @note 枚举值见 types.cj（TracyPlotFormat / TracyMessageSeverity）。
 */
protected package three._vendor.tracy4cj.tracy

// =============================================================================
// 调用栈深度
// =============================================================================

/** @brief 默认调用栈采集深度（TRACY_CALLSTACK = 0，即不采集调用栈） */
public const TRACY_CALLSTACK: Int32 = 0

// =============================================================================
// GPU 上下文后端类型（___tracy_gpu_new_context_data.type 字段取值，
// 见 Tracy 官方 client/TracyProfiler.cpp 的 GpuContextType 定义）
// =============================================================================

/** @brief GPU 上下文类型：无效（GpuContextTypeInvalid = 0） */
public const TRACY_GPU_CONTEXT_INVALID: UInt8 = 0

/** @brief GPU 上下文类型：Direct3D 12（GpuContextTypeDirect3D12 = 1） */
public const TRACY_GPU_CONTEXT_DIRECT3D_12: UInt8 = 1

/** @brief GPU 上下文类型：Direct3D 11（GpuContextTypeDirect3D11 = 2） */
public const TRACY_GPU_CONTEXT_DIRECT3D_11: UInt8 = 2

/** @brief GPU 上下文类型：OpenGL（GpuContextTypeOpenGL = 3） */
public const TRACY_GPU_CONTEXT_OPENGL: UInt8 = 3

/** @brief GPU 上下文类型：Vulkan（GpuContextTypeVulkan = 4） */
public const TRACY_GPU_CONTEXT_VULKAN: UInt8 = 4

/** @brief GPU 上下文类型：Metal（GpuContextTypeMetal = 5） */
public const TRACY_GPU_CONTEXT_METAL: UInt8 = 5

// =============================================================================
// GPU 上下文标志位（___tracy_gpu_new_context_data.flags 字段取值）
// =============================================================================

/** @brief GPU 上下文标志：需要校准（GpuContextCalibration = 1<<0） */
public const TRACY_GPU_FLAG_CALIBRATION: UInt8 = 1

/** @brief GPU 上下文标志：命令队列无序提交（GpuContextFlagsNoEmphasis = 1<<1） */
public const TRACY_GPU_FLAG_NO_EMPHASIS: UInt8 = 2
