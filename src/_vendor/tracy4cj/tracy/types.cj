/**
 * @file tracy4cj.tracy 类型定义
 * @brief TracyC.h 中的枚举与结构体的仓颉映射
 * @explain 本文件包含 TracyC.h 中全部公开枚举与结构体。仓颉枚举是引用类型，
 *         不满足 CType 约束，不能直接用作 foreign 函数参数/返回值类型；
 *         foreign 函数使用底层整数表示（Int32/UInt32），调用方通过
 *         `value()` / `fromValue()` 转换。结构体使用 @C 修饰以匹配 C ABI，
 *         字段布局与 TracyC.h 完全一致。
 * @note 不透明指针类型（TracyCLockCtx / TracyCSharedLockCtx 的底层
 *       __tracy_lockable_context_data 等）以 CPointer<Unit> 表示。
 */
protected package three._vendor.tracy4cj.tracy

// =============================================================================
// 枚举（foreign 层用 Int32 传递，通过 value()/fromValue() 转换）
// =============================================================================

/**
 * @brief Plot 曲线图的数值显示格式（TracyPlotFormatEnum）
 * @explain 对应 TracyC.h 中 TracyPlotFormatEnum，传给 ___tracy_emit_plot_config 的
 *         type 参数。
 */
public enum TracyPlotFormat {
    /** @brief 通用数值（TracyPlotFormatNumber = 0） */
    | Number
    /** @brief 内存字节数（自动 KB/MB/GB 格式化，TracyPlotFormatMemory = 1） */
    | Memory
    /** @brief 百分比（TracyPlotFormatPercentage = 2） */
    | Percentage
    /** @brief 功率（瓦特，TracyPlotFormatWatt = 3） */
    | Watt

    /** @brief 将枚举值转换为 Int32（C ABI 兼容） */
    public func value(): Int32 {
        match (this) {
            case Number => 0
            case Memory => 1
            case Percentage => 2
            case Watt => 3
        }
    }

    /** @brief 从 Int32 转换回枚举值（未知值回退 Number） */
    public static func fromValue(v: Int32): TracyPlotFormat {
        match (v) {
            case 1 => Memory
            case 2 => Percentage
            case 3 => Watt
            case _ => Number
        }
    }
}

/**
 * @brief 消息严重级别（TracyMessageSeverity）
 * @explain 对应 TracyC.h 中 TracyMessageSeverity，传给 logString 系列函数的
 *         severity 参数。
 */
public enum TracyMessageSeverity {
    /** @brief 广泛跟踪变量状态与事件（TracyMessageSeverityTrace = 0） */
    | Trace
    /** @brief 调查用内部细节（TracyMessageSeverityDebug = 1） */
    | Debug
    /** @brief 正常事件进度与状态（TracyMessageSeverityInfo = 2） */
    | Info
    /** @brief 意外事件导致的潜在危险（TracyMessageSeverityWarning = 3） */
    | Warning
    /** @brief 意外行为，不中断执行（TracyMessageSeverityError = 4） */
    | Error
    /** @brief 将导致软件失败/崩溃的严重事件（TracyMessageSeverityFatal = 5） */
    | Fatal

    /** @brief 将枚举值转换为 Int32（C ABI 兼容） */
    public func value(): Int32 {
        match (this) {
            case Trace => 0
            case Debug => 1
            case Info => 2
            case Warning => 3
            case Error => 4
            case Fatal => 5
        }
    }

    /** @brief 从 Int32 转换回枚举值（未知值回退 Trace） */
    public static func fromValue(v: Int32): TracyMessageSeverity {
        match (v) {
            case 1 => Debug
            case 2 => Info
            case 3 => Warning
            case 4 => Error
            case 5 => Fatal
            case _ => Trace
        }
    }
}

// =============================================================================
// 不透明句柄类型
// =============================================================================

/**
 * @brief Zone 上下文（TracyCZoneCtx）
 * @explain 对应 struct ___tracy_c_zone_context，用于 zone begin/end 配对。
 *         @C 结构体以满足 FFI 按值传递的 CType 约束。
 *         id 为 zone 内部标识，active 表示本 zone 是否被记录；
 *         connectionId 仅在 TRACY_ON_DEMAND 下有意义，本绑定固定为 0。
 */
@C
public struct TracyCZoneCtx {
    /** @brief zone 内部标识（___tracy_c_zone_context.id） */
    public var id: UInt32
    /** @brief zone 是否被记录（0 = 丢弃，1 = 记录） */
    public var active: Int32

    public init(id: UInt32, active: Int32) {
        this.id = id
        this.active = active
    }
}

// =============================================================================
// 源位置
// =============================================================================

/**
 * @brief 源位置描述（___tracy_source_location_data）
 * @explain zone 的静态源信息：函数名/文件/行号/颜色。name 为空指针表示
 *         使用函数名作为 zone 名称。可全局缓存复用（Tracy 官方推荐静态存储）。
 */
@C
public struct TracySourceLocationData {
    /** @brief zone 自定义名称（NULL = 用 function 名） */
    public var name: CPointer<UInt8>
    /** @brief 函数名（C 字符串） */
    public var function: CPointer<UInt8>
    /** @brief 文件名（C 字符串） */
    public var file: CPointer<UInt8>
    /** @brief 行号 */
    public var line: UInt32
    /** @brief 颜色（0xAABBGGRR；0 = 使用默认配色） */
    public var color: UInt32

    public init(name: CPointer<UInt8>, function: CPointer<UInt8>, file: CPointer<UInt8>,
                line: UInt32, color: UInt32) {
        this.name = name
        this.function = function
        this.file = file
        this.line = line
        this.color = color
    }
}

// =============================================================================
// GPU 事件数据（TracyC.h L170-218）
// =============================================================================

/**
 * @brief GPU 时间戳事件（___tracy_gpu_time_data）
 * @explain 提交一次 GPU 时间戳查询结果。
 */
@C
public struct TracyGpuTimeData {
    /** @brief GPU 时间戳（GPU 上下文时钟域，纳秒或周期数） */
    public var gpuTime: Int64
    /** @brief 查询 ID（与 zone begin 配对） */
    public var queryId: UInt16
    /** @brief GPU 上下文 ID（newContext 分配） */
    public var context: UInt8

    public init(gpuTime: Int64, queryId: UInt16, context: UInt8) {
        this.gpuTime = gpuTime
        this.queryId = queryId
        this.context = context
    }
}

/**
 * @brief GPU zone 开始事件（___tracy_gpu_zone_begin_data）
 * @explain 以已分配的 srcloc 启动一个 GPU zone。
 */
@C
public struct TracyGpuZoneBeginData {
    /** @brief 源位置（allocSrcloc 返回值） */
    public var srcloc: UInt64
    /** @brief 查询 ID */
    public var queryId: UInt16
    /** @brief GPU 上下文 ID */
    public var context: UInt8

    public init(srcloc: UInt64, queryId: UInt16, context: UInt8) {
        this.srcloc = srcloc
        this.queryId = queryId
        this.context = context
    }
}

/**
 * @brief GPU zone 开始事件（带调用栈，___tracy_gpu_zone_begin_callstack_data）
 */
@C
public struct TracyGpuZoneBeginCallstackData {
    /** @brief 源位置（allocSrcloc 返回值） */
    public var srcloc: UInt64
    /** @brief 调用栈采集深度 */
    public var depth: Int32
    /** @brief 查询 ID */
    public var queryId: UInt16
    /** @brief GPU 上下文 ID */
    public var context: UInt8

    public init(srcloc: UInt64, depth: Int32, queryId: UInt16, context: UInt8) {
        this.srcloc = srcloc
        this.depth = depth
        this.queryId = queryId
        this.context = context
    }
}

/**
 * @brief GPU zone 结束事件（___tracy_gpu_zone_end_data）
 */
@C
public struct TracyGpuZoneEndData {
    /** @brief 查询 ID */
    public var queryId: UInt16
    /** @brief GPU 上下文 ID */
    public var context: UInt8

    public init(queryId: UInt16, context: UInt8) {
        this.queryId = queryId
        this.context = context
    }
}

/**
 * @brief GPU 上下文注册事件（___tracy_gpu_new_context_data）
 * @explain 注册一个新的 GPU 上下文（图形 API 后端类型等）。
 */
@C
public struct TracyGpuNewContextData {
    /** @brief GPU 时间戳基准（与 CPU 时间对齐） */
    public var gpuTime: Int64
    /** @brief 时间戳周期（纳秒/周期；0 表示纳秒） */
    public var period: Float32
    /** @brief GPU 上下文 ID（0-255） */
    public var context: UInt8
    /** @brief 标志位（1 = 无序提交） */
    public var flags: UInt8
    /** @brief 后端类型（TracyGpuContextType：OpenGL=2/Vulkan=3/D3D11=4/D3D12=5 等） */
    public var kind: UInt8

    public init(gpuTime: Int64, period: Float32, context: UInt8, flags: UInt8, kind: UInt8) {
        this.gpuTime = gpuTime
        this.period = period
        this.context = context
        this.flags = flags
        this.kind = kind
    }
}

/**
 * @brief GPU 上下文命名事件（___tracy_gpu_context_name_data）
 */
@C
public struct TracyGpuContextNameData {
    /** @brief GPU 上下文 ID */
    public var context: UInt8
    /** @brief 名称（C 字符串，非 NUL 结尾） */
    public var name: CPointer<UInt8>
    /** @brief 名称字节长度 */
    public var len: UInt16

    public init(context: UInt8, name: CPointer<UInt8>, len: UInt16) {
        this.context = context
        this.name = name
        this.len = len
    }
}

/**
 * @brief GPU 时钟校准事件（___tracy_gpu_calibration_data）
 * @explain 校准 GPU 与 CPU 时钟偏差。
 */
@C
public struct TracyGpuCalibrationData {
    /** @brief GPU 时间戳 */
    public var gpuTime: Int64
    /** @brief CPU 侧对应差值（纳秒） */
    public var cpuDelta: Int64
    /** @brief GPU 上下文 ID */
    public var context: UInt8

    public init(gpuTime: Int64, cpuDelta: Int64, context: UInt8) {
        this.gpuTime = gpuTime
        this.cpuDelta = cpuDelta
        this.context = context
    }
}

/**
 * @brief GPU 时间同步事件（___tracy_gpu_time_sync_data）
 */
@C
public struct TracyGpuTimeSyncData {
    /** @brief GPU 时间戳 */
    public var gpuTime: Int64
    /** @brief GPU 上下文 ID */
    public var context: UInt8

    public init(gpuTime: Int64, context: UInt8) {
        this.gpuTime = gpuTime
        this.context = context
    }
}
