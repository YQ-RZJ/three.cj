/**
 * @file openalsoft4cj.alc 常量定义
 * @brief OpenAL Context 管理 API（alc.h）的常量
 * @explain 本文件包含 alc.h 中全部 #define 常量的仓颉版本（过滤编译宏）。
 */
protected package three._vendor.openalsoft4cj.alc

// =============================================================================
// 通用常量
// =============================================================================

/** @brief 布尔假（ALC_FALSE = 0） */
public const ALC_FALSE: UInt32 = 0
/** @brief 布尔真（ALC_TRUE = 1） */
public const ALC_TRUE: UInt32 = 1

// =============================================================================
// 上下文属性（alcCreateContext attrlist 参数）
// =============================================================================

/** @brief 上下文属性：采样率 Hz（ALC_FREQUENCY = 0x1007） */
public const ALC_FREQUENCY: UInt32 = 0x1007
/** @brief 上下文属性：更新频率（ALC_REFRESH = 0x1008） */
public const ALC_REFRESH: UInt32 = 0x1008
/** @brief 上下文属性：是否同步（ALC_SYNC = 0x1009） */
public const ALC_SYNC: UInt32 = 0x1009
/** @brief 上下文属性：请求的单声道（3D）源数（ALC_MONO_SOURCES = 0x1010） */
public const ALC_MONO_SOURCES: UInt32 = 0x1010
/** @brief 上下文属性：请求的立体声源数（ALC_STEREO_SOURCES = 0x1011） */
public const ALC_STEREO_SOURCES: UInt32 = 0x1011

// =============================================================================
// 错误码（alcGetError）
// =============================================================================

/** @brief 无错误（ALC_NO_ERROR = 0） */
public const ALC_NO_ERROR: UInt32 = 0
/** @brief 无效设备句柄（ALC_INVALID_DEVICE = 0xA001） */
public const ALC_INVALID_DEVICE: UInt32 = 0xA001
/** @brief 无效上下文句柄（ALC_INVALID_CONTEXT = 0xA002） */
public const ALC_INVALID_CONTEXT: UInt32 = 0xA002
/** @brief 无效枚举（ALC_INVALID_ENUM = 0xA003） */
public const ALC_INVALID_ENUM: UInt32 = 0xA003
/** @brief 无效值（ALC_INVALID_VALUE = 0xA004） */
public const ALC_INVALID_VALUE: UInt32 = 0xA004
/** @brief 内存不足（ALC_OUT_OF_MEMORY = 0xA005） */
public const ALC_OUT_OF_MEMORY: UInt32 = 0xA005

// =============================================================================
// 查询参数（alcGetString / alcGetIntegerv）
// =============================================================================

/** @brief 运行时 ALC 主版本（ALC_MAJOR_VERSION = 0x1000） */
public const ALC_MAJOR_VERSION: UInt32 = 0x1000
/** @brief 运行时 ALC 次版本（ALC_MINOR_VERSION = 0x1001） */
public const ALC_MINOR_VERSION: UInt32 = 0x1001
/** @brief 上下文属性列表大小（ALC_ATTRIBUTES_SIZE = 0x1002） */
public const ALC_ATTRIBUTES_SIZE: UInt32 = 0x1002
/** @brief 上下文全部属性（ALC_ALL_ATTRIBUTES = 0x1003） */
public const ALC_ALL_ATTRIBUTES: UInt32 = 0x1003
/** @brief 默认设备说明符（ALC_DEFAULT_DEVICE_SPECIFIER = 0x1004） */
public const ALC_DEFAULT_DEVICE_SPECIFIER: UInt32 = 0x1004
/** @brief 设备说明符列表（ALC_DEVICE_SPECIFIER = 0x1005） */
public const ALC_DEVICE_SPECIFIER: UInt32 = 0x1005
/** @brief 扩展列表（ALC_EXTENSIONS = 0x1006） */
public const ALC_EXTENSIONS: UInt32 = 0x1006

// =============================================================================
// 1.1 API
// =============================================================================

/** @brief 捕获扩展标记（ALC_EXT_CAPTURE = 1） */
public const ALC_EXT_CAPTURE: UInt32 = 1
/** @brief 捕获设备说明符列表（ALC_CAPTURE_DEVICE_SPECIFIER = 0x310） */
public const ALC_CAPTURE_DEVICE_SPECIFIER: UInt32 = 0x310
/** @brief 默认捕获设备说明符（ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = 0x311） */
public const ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER: UInt32 = 0x311
/** @brief 可捕获采样帧数（ALC_CAPTURE_SAMPLES = 0x312） */
public const ALC_CAPTURE_SAMPLES: UInt32 = 0x312
/** @brief 枚举全部扩展标记（ALC_ENUMERATE_ALL_EXT = 1） */
public const ALC_ENUMERATE_ALL_EXT: UInt32 = 1
/** @brief 默认扩展设备说明符（ALC_DEFAULT_ALL_DEVICES_SPECIFIER = 0x1012） */
public const ALC_DEFAULT_ALL_DEVICES_SPECIFIER: UInt32 = 0x1012
/** @brief 扩展设备说明符列表（ALC_ALL_DEVICES_SPECIFIER = 0x1013） */
public const ALC_ALL_DEVICES_SPECIFIER: UInt32 = 0x1013

// =============================================================================
// 版本与废弃常量
// =============================================================================

/** @brief ALC 0.1 版本标记（ALC_VERSION_0_1 = 1） */
public const ALC_VERSION_0_1: UInt32 = 1
/** @brief 无效值（废弃，ALC_INVALID = 0） */
public const ALC_INVALID: UInt32 = 0

// =============================================================================
// alext.h 扩展：ALC 音频通道 / 断开 / 线程局部上下文
// =============================================================================

/** @brief 音频通道扩展标记（ALC_LOKI_audio_channel = 1） */
public const ALC_LOKI_audio_channel: UInt32 = 1
/** @brief 主声道（ALC_CHAN_MAIN_LOKI = 0x500001） */
public const ALC_CHAN_MAIN_LOKI: UInt32 = 0x500001
/** @brief PCM 声道（ALC_CHAN_PCM_LOKI = 0x500002） */
public const ALC_CHAN_PCM_LOKI: UInt32 = 0x500002
/** @brief CD 声道（ALC_CHAN_CD_LOKI = 0x500003） */
public const ALC_CHAN_CD_LOKI: UInt32 = 0x500003
/** @brief EFX 扩展标记（ALC_EXT_EFX = 1） */
public const ALC_EXT_EFX: UInt32 = 1
/** @brief 断开扩展标记（ALC_EXT_disconnect = 1） */
public const ALC_EXT_disconnect: UInt32 = 1
/** @brief 连接状态（ALC_CONNECTED = 0x313） */
public const ALC_CONNECTED: UInt32 = 0x313
/** @brief 线程局部上下文扩展标记（ALC_EXT_thread_local_context = 1） */
public const ALC_EXT_thread_local_context: UInt32 = 1
/** @brief 专用扩展标记（ALC_EXT_DEDICATED = 1） */
public const ALC_EXT_DEDICATED: UInt32 = 1

// =============================================================================
// alext.h 扩展：ALC_SOFT_loopback（回环设备）
// =============================================================================

/** @brief 回环设备扩展标记（ALC_SOFT_loopback = 1） */
public const ALC_SOFT_loopback: UInt32 = 1
/** @brief 格式声道（ALC_FORMAT_CHANNELS_SOFT = 0x1990） */
public const ALC_FORMAT_CHANNELS_SOFT: UInt32 = 0x1990
/** @brief 格式类型（ALC_FORMAT_TYPE_SOFT = 0x1991） */
public const ALC_FORMAT_TYPE_SOFT: UInt32 = 0x1991
/** @brief 字节（ALC_BYTE_SOFT = 0x1400） */
public const ALC_BYTE_SOFT: UInt32 = 0x1400
/** @brief 无符号字节（ALC_UNSIGNED_BYTE_SOFT = 0x1401） */
public const ALC_UNSIGNED_BYTE_SOFT: UInt32 = 0x1401
/** @brief 短整型（ALC_SHORT_SOFT = 0x1402） */
public const ALC_SHORT_SOFT: UInt32 = 0x1402
/** @brief 无符号短整型（ALC_UNSIGNED_SHORT_SOFT = 0x1403） */
public const ALC_UNSIGNED_SHORT_SOFT: UInt32 = 0x1403
/** @brief 整型（ALC_INT_SOFT = 0x1404） */
public const ALC_INT_SOFT: UInt32 = 0x1404
/** @brief 无符号整型（ALC_UNSIGNED_INT_SOFT = 0x1405） */
public const ALC_UNSIGNED_INT_SOFT: UInt32 = 0x1405
/** @brief 浮点（ALC_FLOAT_SOFT = 0x1406） */
public const ALC_FLOAT_SOFT: UInt32 = 0x1406
/** @brief 单声道（ALC_MONO_SOFT = 0x1500） */
public const ALC_MONO_SOFT: UInt32 = 0x1500
/** @brief 立体声（ALC_STEREO_SOFT = 0x1501） */
public const ALC_STEREO_SOFT: UInt32 = 0x1501
/** @brief 四声道（ALC_QUAD_SOFT = 0x1503） */
public const ALC_QUAD_SOFT: UInt32 = 0x1503
/** @brief 5.1 声道（ALC_5POINT1_SOFT = 0x1504） */
public const ALC_5POINT1_SOFT: UInt32 = 0x1504
/** @brief 6.1 声道（ALC_6POINT1_SOFT = 0x1505） */
public const ALC_6POINT1_SOFT: UInt32 = 0x1505
/** @brief 7.1 声道（ALC_7POINT1_SOFT = 0x1506） */
public const ALC_7POINT1_SOFT: UInt32 = 0x1506
/** @brief 默认滤波器顺序扩展标记（ALC_EXT_DEFAULT_FILTER_ORDER = 1） */
public const ALC_EXT_DEFAULT_FILTER_ORDER: UInt32 = 1
/** @brief 默认滤波器顺序（ALC_DEFAULT_FILTER_ORDER = 0x1100） */
public const ALC_DEFAULT_FILTER_ORDER: UInt32 = 0x1100
/** @brief 暂停设备扩展标记（ALC_SOFT_pause_device = 1） */
public const ALC_SOFT_pause_device: UInt32 = 1

// =============================================================================
// alext.h 扩展：ALC_SOFT_HRTF（头部相关传输函数）
// =============================================================================

/** @brief HRTF 扩展标记（ALC_SOFT_HRTF = 1） */
public const ALC_SOFT_HRTF: UInt32 = 1
/** @brief HRTF（ALC_HRTF_SOFT = 0x1992） */
public const ALC_HRTF_SOFT: UInt32 = 0x1992
/** @brief 不关心（ALC_DONT_CARE_SOFT = 0x0002） */
public const ALC_DONT_CARE_SOFT: UInt32 = 0x0002
/** @brief HRTF 状态（ALC_HRTF_STATUS_SOFT = 0x1993） */
public const ALC_HRTF_STATUS_SOFT: UInt32 = 0x1993
/** @brief HRTF 禁用（ALC_HRTF_DISABLED_SOFT = 0x0000） */
public const ALC_HRTF_DISABLED_SOFT: UInt32 = 0x0000
/** @brief HRTF 启用（ALC_HRTF_ENABLED_SOFT = 0x0001） */
public const ALC_HRTF_ENABLED_SOFT: UInt32 = 0x0001
/** @brief HRTF 拒绝（ALC_HRTF_DENIED_SOFT = 0x0002） */
public const ALC_HRTF_DENIED_SOFT: UInt32 = 0x0002
/** @brief HRTF 必需（ALC_HRTF_REQUIRED_SOFT = 0x0003） */
public const ALC_HRTF_REQUIRED_SOFT: UInt32 = 0x0003
/** @brief HRTF 检测到头戴耳机（ALC_HRTF_HEADPHONES_DETECTED_SOFT = 0x0004） */
public const ALC_HRTF_HEADPHONES_DETECTED_SOFT: UInt32 = 0x0004
/** @brief HRTF 不支持的格式（ALC_HRTF_UNSUPPORTED_FORMAT_SOFT = 0x0005） */
public const ALC_HRTF_UNSUPPORTED_FORMAT_SOFT: UInt32 = 0x0005
/** @brief HRTF 说明符数量（ALC_NUM_HRTF_SPECIFIERS_SOFT = 0x1994） */
public const ALC_NUM_HRTF_SPECIFIERS_SOFT: UInt32 = 0x1994
/** @brief HRTF 说明符（ALC_HRTF_SPECIFIER_SOFT = 0x1995） */
public const ALC_HRTF_SPECIFIER_SOFT: UInt32 = 0x1995
/** @brief HRTF ID（ALC_HRTF_ID_SOFT = 0x1996） */
public const ALC_HRTF_ID_SOFT: UInt32 = 0x1996
/** @brief 输出限制器扩展标记（ALC_SOFT_output_limiter = 1） */
public const ALC_SOFT_output_limiter: UInt32 = 1
/** @brief 输出限制器（ALC_OUTPUT_LIMITER_SOFT = 0x199A） */
public const ALC_OUTPUT_LIMITER_SOFT: UInt32 = 0x199A

// =============================================================================
// alext.h 扩展：ALC_SOFT_device_clock / loopback_bformat / output_mode / debug / system_events
// =============================================================================

/** @brief 设备时钟扩展标记（ALC_SOFT_device_clock = 1） */
public const ALC_SOFT_device_clock: UInt32 = 1
/** @brief 设备时钟（ALC_DEVICE_CLOCK_SOFT = 0x1600） */
public const ALC_DEVICE_CLOCK_SOFT: UInt32 = 0x1600
/** @brief 设备延迟（ALC_DEVICE_LATENCY_SOFT = 0x1601） */
public const ALC_DEVICE_LATENCY_SOFT: UInt32 = 0x1601
/** @brief 设备时钟延迟（ALC_DEVICE_CLOCK_LATENCY_SOFT = 0x1602） */
public const ALC_DEVICE_CLOCK_LATENCY_SOFT: UInt32 = 0x1602
/** @brief 回环 B-Format 扩展标记（ALC_SOFT_loopback_bformat = 1） */
public const ALC_SOFT_loopback_bformat: UInt32 = 1
/** @brief 环境声布局（ALC_AMBISONIC_LAYOUT_SOFT = 0x1997） */
public const ALC_AMBISONIC_LAYOUT_SOFT: UInt32 = 0x1997
/** @brief 环境声缩放（ALC_AMBISONIC_SCALING_SOFT = 0x1998） */
public const ALC_AMBISONIC_SCALING_SOFT: UInt32 = 0x1998
/** @brief 环境声阶数（ALC_AMBISONIC_ORDER_SOFT = 0x1999） */
public const ALC_AMBISONIC_ORDER_SOFT: UInt32 = 0x1999
/** @brief 最大环境声阶数（ALC_MAX_AMBISONIC_ORDER_SOFT = 0x199B） */
public const ALC_MAX_AMBISONIC_ORDER_SOFT: UInt32 = 0x199B
/** @brief 3D B-Format（ALC_BFORMAT3D_SOFT = 0x1507） */
public const ALC_BFORMAT3D_SOFT: UInt32 = 0x1507
/** @brief FuMa（ALC_FUMA_SOFT = 0x0000） */
public const ALC_FUMA_SOFT: UInt32 = 0x0000
/** @brief ACN（ALC_ACN_SOFT = 0x0001） */
public const ALC_ACN_SOFT: UInt32 = 0x0001
/** @brief SN3D（ALC_SN3D_SOFT = 0x0001） */
public const ALC_SN3D_SOFT: UInt32 = 0x0001
/** @brief N3D（ALC_N3D_SOFT = 0x0002） */
public const ALC_N3D_SOFT: UInt32 = 0x0002
/** @brief 重开设备扩展标记（ALC_SOFT_reopen_device = 1） */
public const ALC_SOFT_reopen_device: UInt32 = 1
/** @brief 输出模式扩展标记（ALC_SOFT_output_mode = 1） */
public const ALC_SOFT_output_mode: UInt32 = 1
/** @brief 输出模式（ALC_OUTPUT_MODE_SOFT = 0x19AC） */
public const ALC_OUTPUT_MODE_SOFT: UInt32 = 0x19AC
/** @brief 任意（ALC_ANY_SOFT = 0x19AD） */
public const ALC_ANY_SOFT: UInt32 = 0x19AD
/** @brief 立体声基础（ALC_STEREO_BASIC_SOFT = 0x19AE） */
public const ALC_STEREO_BASIC_SOFT: UInt32 = 0x19AE
/** @brief 立体声 UHJ（ALC_STEREO_UHJ_SOFT = 0x19AF） */
public const ALC_STEREO_UHJ_SOFT: UInt32 = 0x19AF
/** @brief 立体声 HRTF（ALC_STEREO_HRTF_SOFT = 0x19B2） */
public const ALC_STEREO_HRTF_SOFT: UInt32 = 0x19B2
/** @brief 5.1 环绕（ALC_SURROUND_5_1_SOFT = 0x1504） */
public const ALC_SURROUND_5_1_SOFT: UInt32 = 0x1504
/** @brief 6.1 环绕（ALC_SURROUND_6_1_SOFT = 0x1505） */
public const ALC_SURROUND_6_1_SOFT: UInt32 = 0x1505
/** @brief 7.1 环绕（ALC_SURROUND_7_1_SOFT = 0x1506） */
public const ALC_SURROUND_7_1_SOFT: UInt32 = 0x1506
/** @brief 调试扩展标记（ALC_EXT_debug = 1） */
public const ALC_EXT_debug: UInt32 = 1
/** @brief 上下文标志（ALC_CONTEXT_FLAGS_EXT = 0x19CF） */
public const ALC_CONTEXT_FLAGS_EXT: UInt32 = 0x19CF
/** @brief 上下文调试位（ALC_CONTEXT_DEBUG_BIT_EXT = 0x0001） */
public const ALC_CONTEXT_DEBUG_BIT_EXT: UInt32 = 0x0001
/** @brief 系统事件扩展标记（ALC_SOFT_system_events = 1） */
public const ALC_SOFT_system_events: UInt32 = 1
/** @brief 播放设备（ALC_PLAYBACK_DEVICE_SOFT = 0x19D4） */
public const ALC_PLAYBACK_DEVICE_SOFT: UInt32 = 0x19D4
/** @brief 捕获设备（ALC_CAPTURE_DEVICE_SOFT = 0x19D5） */
public const ALC_CAPTURE_DEVICE_SOFT: UInt32 = 0x19D5
/** @brief 事件：默认设备变化（ALC_EVENT_TYPE_DEFAULT_DEVICE_CHANGED_SOFT = 0x19D6） */
public const ALC_EVENT_TYPE_DEFAULT_DEVICE_CHANGED_SOFT: UInt32 = 0x19D6
/** @brief 事件：设备添加（ALC_EVENT_TYPE_DEVICE_ADDED_SOFT = 0x19D7） */
public const ALC_EVENT_TYPE_DEVICE_ADDED_SOFT: UInt32 = 0x19D7
/** @brief 事件：设备移除（ALC_EVENT_TYPE_DEVICE_REMOVED_SOFT = 0x19D8） */
public const ALC_EVENT_TYPE_DEVICE_REMOVED_SOFT: UInt32 = 0x19D8
/** @brief 事件支持（ALC_EVENT_SUPPORTED_SOFT = 0x19D9） */
public const ALC_EVENT_SUPPORTED_SOFT: UInt32 = 0x19D9
/** @brief 事件不支持（ALC_EVENT_NOT_SUPPORTED_SOFT = 0x19DA） */
public const ALC_EVENT_NOT_SUPPORTED_SOFT: UInt32 = 0x19DA
