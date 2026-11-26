/**
 * @file openalsoft4cj.al 常量定义
 * @brief OpenAL 核心 API（al.h）的参数标识符与常量
 * @explain 本文件包含 al.h 中全部 #define 常量的仓颉版本（过滤编译宏），
 *         直接映射自 C 头文件 al.h。
 * @note 枚举值（源状态/格式/错误码/距离模型）见 types.cj。
 */
protected package three._vendor.openalsoft4cj.al

// =============================================================================
// 通用常量
// =============================================================================

/** @brief 无对象 / 无距离模型（AL_NONE = 0） */
public const AL_NONE: UInt32 = 0
/** @brief 布尔假（AL_FALSE = 0） */
public const AL_FALSE: UInt32 = 0
/** @brief 布尔真（AL_TRUE = 1） */
public const AL_TRUE: UInt32 = 1

// =============================================================================
// 源 / 监听器参数标识符
// =============================================================================

/** @brief 相对坐标源（AL_SOURCE_RELATIVE = 0x202） */
public const AL_SOURCE_RELATIVE: UInt32 = 0x202
/** @brief 内锥角（度）（AL_CONE_INNER_ANGLE = 0x1001） */
public const AL_CONE_INNER_ANGLE: UInt32 = 0x1001
/** @brief 外锥角（度）（AL_CONE_OUTER_ANGLE = 0x1002） */
public const AL_CONE_OUTER_ANGLE: UInt32 = 0x1002
/** @brief 源音高（AL_PITCH = 0x1003） */
public const AL_PITCH: UInt32 = 0x1003
/** @brief 源/监听器位置（AL_POSITION = 0x1004） */
public const AL_POSITION: UInt32 = 0x1004
/** @brief 源方向（AL_DIRECTION = 0x1005） */
public const AL_DIRECTION: UInt32 = 0x1005
/** @brief 源/监听器速度（AL_VELOCITY = 0x1006） */
public const AL_VELOCITY: UInt32 = 0x1006
/** @brief 源循环播放（AL_LOOPING = 0x1007） */
public const AL_LOOPING: UInt32 = 0x1007
/** @brief 源缓冲（AL_BUFFER = 0x1009） */
public const AL_BUFFER: UInt32 = 0x1009
/** @brief 源/监听器增益（AL_GAIN = 0x100A） */
public const AL_GAIN: UInt32 = 0x100A
/** @brief 源最小增益（AL_MIN_GAIN = 0x100D） */
public const AL_MIN_GAIN: UInt32 = 0x100D
/** @brief 源最大增益（AL_MAX_GAIN = 0x100E） */
public const AL_MAX_GAIN: UInt32 = 0x100E
/** @brief 监听器朝向（AL_ORIENTATION = 0x100F） */
public const AL_ORIENTATION: UInt32 = 0x100F
/** @brief 源状态（查询）（AL_SOURCE_STATE = 0x1010） */
public const AL_SOURCE_STATE: UInt32 = 0x1010
/** @brief 排队缓冲数（查询）（AL_BUFFERS_QUEUED = 0x1015） */
public const AL_BUFFERS_QUEUED: UInt32 = 0x1015
/** @brief 已处理排队缓冲数（查询）（AL_BUFFERS_PROCESSED = 0x1016） */
public const AL_BUFFERS_PROCESSED: UInt32 = 0x1016
/** @brief 源参考距离（AL_REFERENCE_DISTANCE = 0x1020） */
public const AL_REFERENCE_DISTANCE: UInt32 = 0x1020
/** @brief 源滚降因子（AL_ROLLOFF_FACTOR = 0x1021） */
public const AL_ROLLOFF_FACTOR: UInt32 = 0x1021
/** @brief 外锥增益（AL_CONE_OUTER_GAIN = 0x1022） */
public const AL_CONE_OUTER_GAIN: UInt32 = 0x1022
/** @brief 源最大距离（AL_MAX_DISTANCE = 0x1023） */
public const AL_MAX_DISTANCE: UInt32 = 0x1023

// =============================================================================
// 缓冲格式
// =============================================================================

/** @brief 单声道 8 位（AL_FORMAT_MONO8 = 0x1100） */
public const AL_FORMAT_MONO8: UInt32 = 0x1100
/** @brief 单声道 16 位（AL_FORMAT_MONO16 = 0x1101） */
public const AL_FORMAT_MONO16: UInt32 = 0x1101
/** @brief 立体声 8 位（AL_FORMAT_STEREO8 = 0x1102） */
public const AL_FORMAT_STEREO8: UInt32 = 0x1102
/** @brief 立体声 16 位（AL_FORMAT_STEREO16 = 0x1103） */
public const AL_FORMAT_STEREO16: UInt32 = 0x1103

// =============================================================================
// 缓冲参数（查询）
// =============================================================================

/** @brief 缓冲频率/采样率（AL_FREQUENCY = 0x2001） */
public const AL_FREQUENCY: UInt32 = 0x2001
/** @brief 缓冲数据字节数（AL_SIZE = 0x2004） */
public const AL_SIZE: UInt32 = 0x2004
/** @brief 缓冲每样本位数（AL_BITS = 0x2002） */
public const AL_BITS: UInt32 = 0x2002
/** @brief 缓冲声道数（AL_CHANNELS = 0x2003） */
public const AL_CHANNELS: UInt32 = 0x2003

// =============================================================================
// 错误码（alGetError）
// =============================================================================

/** @brief 无错误（AL_NO_ERROR = 0） */
public const AL_NO_ERROR: UInt32 = 0
/** @brief 无效名称（AL_INVALID_NAME = 0xA001） */
public const AL_INVALID_NAME: UInt32 = 0xA001
/** @brief 无效枚举（AL_INVALID_ENUM = 0xA002） */
public const AL_INVALID_ENUM: UInt32 = 0xA002
/** @brief 无效值（AL_INVALID_VALUE = 0xA003） */
public const AL_INVALID_VALUE: UInt32 = 0xA003
/** @brief 非法调用（AL_INVALID_OPERATION = 0xA004） */
public const AL_INVALID_OPERATION: UInt32 = 0xA004
/** @brief 内存不足（AL_OUT_OF_MEMORY = 0xA005） */
public const AL_OUT_OF_MEMORY: UInt32 = 0xA005

// =============================================================================
// 上下文字符串（alGetString）
// =============================================================================

/** @brief 厂商名（AL_VENDOR = 0xB001） */
public const AL_VENDOR: UInt32 = 0xB001
/** @brief 版本（AL_VERSION = 0xB002） */
public const AL_VERSION: UInt32 = 0xB002
/** @brief 渲染器名（AL_RENDERER = 0xB003） */
public const AL_RENDERER: UInt32 = 0xB003
/** @brief 扩展列表（AL_EXTENSIONS = 0xB004） */
public const AL_EXTENSIONS: UInt32 = 0xB004

// =============================================================================
// 渲染器设置
// =============================================================================

/** @brief 多普勒因子（AL_DOPPLER_FACTOR = 0xC000） */
public const AL_DOPPLER_FACTOR: UInt32 = 0xC000
/** @brief 多普勒速度（已废弃）（AL_DOPPLER_VELOCITY = 0xC001） */
public const AL_DOPPLER_VELOCITY: UInt32 = 0xC001
/** @brief 声速（AL_SPEED_OF_SOUND = 0xC003） */
public const AL_SPEED_OF_SOUND: UInt32 = 0xC003
/** @brief 距离衰减模型（AL_DISTANCE_MODEL = 0xD000） */
public const AL_DISTANCE_MODEL: UInt32 = 0xD000

// =============================================================================
// 距离模型取值（alDistanceModel / AL_DISTANCE_MODEL 参数）
// =============================================================================

/** @brief 反比距离（AL_INVERSE_DISTANCE = 0xD001） */
public const AL_INVERSE_DISTANCE: UInt32 = 0xD001
/** @brief 反比距离（钳制）（AL_INVERSE_DISTANCE_CLAMPED = 0xD002） */
public const AL_INVERSE_DISTANCE_CLAMPED: UInt32 = 0xD002
/** @brief 线性距离（AL_LINEAR_DISTANCE = 0xD003） */
public const AL_LINEAR_DISTANCE: UInt32 = 0xD003
/** @brief 线性距离（钳制）（AL_LINEAR_DISTANCE_CLAMPED = 0xD004） */
public const AL_LINEAR_DISTANCE_CLAMPED: UInt32 = 0xD004
/** @brief 指数距离（AL_EXPONENT_DISTANCE = 0xD005） */
public const AL_EXPONENT_DISTANCE: UInt32 = 0xD005
/** @brief 指数距离（钳制）（AL_EXPONENT_DISTANCE_CLAMPED = 0xD006） */
public const AL_EXPONENT_DISTANCE_CLAMPED: UInt32 = 0xD006

// =============================================================================
// 1.1 API
// =============================================================================

/** @brief 源缓冲偏移（秒）（AL_SEC_OFFSET = 0x1024） */
public const AL_SEC_OFFSET: UInt32 = 0x1024
/** @brief 源缓冲偏移（采样帧）（AL_SAMPLE_OFFSET = 0x1025） */
public const AL_SAMPLE_OFFSET: UInt32 = 0x1025
/** @brief 源缓冲偏移（字节）（AL_BYTE_OFFSET = 0x1026） */
public const AL_BYTE_OFFSET: UInt32 = 0x1026
/** @brief 源类型（查询）（AL_SOURCE_TYPE = 0x1027） */
public const AL_SOURCE_TYPE: UInt32 = 0x1027
/** @brief 静态源（AL_STATIC = 0x1028） */
public const AL_STATIC: UInt32 = 0x1028
/** @brief 流式源（AL_STREAMING = 0x1029） */
public const AL_STREAMING: UInt32 = 0x1029
/** @brief 未确定源（AL_UNDETERMINED = 0x1030） */
public const AL_UNDETERMINED: UInt32 = 0x1030

// =============================================================================
// 缓冲状态（内部使用）
// =============================================================================

/** @brief 未使用（AL_UNUSED = 0x2010） */
public const AL_UNUSED: UInt32 = 0x2010
/** @brief 等待中（AL_PENDING = 0x2011） */
public const AL_PENDING: UInt32 = 0x2011
/** @brief 已处理（AL_PROCESSED = 0x2012） */
public const AL_PROCESSED: UInt32 = 0x2012

// =============================================================================
// 源状态取值（AL_SOURCE_STATE 查询结果，与 types.cj SourceState 对应）
// =============================================================================

/** @brief 源状态：初始（AL_INITIAL = 0x1011） */
public const AL_INITIAL: UInt32 = 0x1011
/** @brief 源状态：播放中（AL_PLAYING = 0x1012） */
public const AL_PLAYING: UInt32 = 0x1012
/** @brief 源状态：暂停（AL_PAUSED = 0x1013） */
public const AL_PAUSED: UInt32 = 0x1013
/** @brief 源状态：停止（AL_STOPPED = 0x1014） */
public const AL_STOPPED: UInt32 = 0x1014

// =============================================================================
// 废弃宏（兼容旧代码）
// =============================================================================

/** @brief 无效值（废弃，AL_INVALID = -1） */
public const AL_INVALID: Int32 = -1
/** @brief 非法枚举别名（AL_ILLEGAL_ENUM = AL_INVALID_ENUM = 0xA002） */
public const AL_ILLEGAL_ENUM: UInt32 = 0xA002
/** @brief 非法调用别名（AL_ILLEGAL_COMMAND = AL_INVALID_OPERATION = 0xA004） */
public const AL_ILLEGAL_COMMAND: UInt32 = 0xA004

// =============================================================================
// alext.h 扩展：编解码格式
// =============================================================================

/** @brief IMA ADPCM 扩展标记（AL_LOKI_IMA_ADPCM_format = 1） */
public const AL_LOKI_IMA_ADPCM_format: UInt32 = 1
/** @brief IMA ADPCM 单声道 16 位（AL_FORMAT_IMA_ADPCM_MONO16_EXT = 0x10000） */
public const AL_FORMAT_IMA_ADPCM_MONO16_EXT: UInt32 = 0x10000
/** @brief IMA ADPCM 立体声 16 位（AL_FORMAT_IMA_ADPCM_STEREO16_EXT = 0x10001） */
public const AL_FORMAT_IMA_ADPCM_STEREO16_EXT: UInt32 = 0x10001
/** @brief WAVE 扩展标记（AL_LOKI_WAVE_format = 1） */
public const AL_LOKI_WAVE_format: UInt32 = 1
/** @brief WAVE 格式（AL_FORMAT_WAVE_EXT = 0x10002） */
public const AL_FORMAT_WAVE_EXT: UInt32 = 0x10002
/** @brief Vorbis 扩展标记（AL_EXT_vorbis = 1） */
public const AL_EXT_vorbis: UInt32 = 1
/** @brief Vorbis 格式（AL_FORMAT_VORBIS_EXT = 0x10003） */
public const AL_FORMAT_VORBIS_EXT: UInt32 = 0x10003
/** @brief 四声道扩展标记（AL_LOKI_quadriphonic = 1） */
public const AL_LOKI_quadriphonic: UInt32 = 1
/** @brief 四声道 8 位（AL_FORMAT_QUAD8_LOKI = 0x10004） */
public const AL_FORMAT_QUAD8_LOKI: UInt32 = 0x10004
/** @brief 四声道 16 位（AL_FORMAT_QUAD16_LOKI = 0x10005） */
public const AL_FORMAT_QUAD16_LOKI: UInt32 = 0x10005
/** @brief float32 扩展标记（AL_EXT_float32 = 1） */
public const AL_EXT_float32: UInt32 = 1
/** @brief 单声道 32 位浮点（AL_FORMAT_MONO_FLOAT32 = 0x10010） */
public const AL_FORMAT_MONO_FLOAT32: UInt32 = 0x10010
/** @brief 立体声 32 位浮点（AL_FORMAT_STEREO_FLOAT32 = 0x10011） */
public const AL_FORMAT_STEREO_FLOAT32: UInt32 = 0x10011
/** @brief double 扩展标记（AL_EXT_double = 1） */
public const AL_EXT_double: UInt32 = 1
/** @brief 单声道 64 位双精度（AL_FORMAT_MONO_DOUBLE_EXT = 0x10012） */
public const AL_FORMAT_MONO_DOUBLE_EXT: UInt32 = 0x10012
/** @brief 立体声 64 位双精度（AL_FORMAT_STEREO_DOUBLE_EXT = 0x10013） */
public const AL_FORMAT_STEREO_DOUBLE_EXT: UInt32 = 0x10013
/** @brief Mulaw 扩展标记（AL_EXT_MULAW = 1） */
public const AL_EXT_MULAW: UInt32 = 1
/** @brief 单声道 Mulaw（AL_FORMAT_MONO_MULAW_EXT = 0x10014） */
public const AL_FORMAT_MONO_MULAW_EXT: UInt32 = 0x10014
/** @brief 立体声 Mulaw（AL_FORMAT_STEREO_MULAW_EXT = 0x10015） */
public const AL_FORMAT_STEREO_MULAW_EXT: UInt32 = 0x10015
/** @brief Alaw 扩展标记（AL_EXT_ALAW = 1） */
public const AL_EXT_ALAW: UInt32 = 1
/** @brief 单声道 Alaw（AL_FORMAT_MONO_ALAW_EXT = 0x10016） */
public const AL_FORMAT_MONO_ALAW_EXT: UInt32 = 0x10016
/** @brief 立体声 Alaw（AL_FORMAT_STEREO_ALAW_EXT = 0x10017） */
public const AL_FORMAT_STEREO_ALAW_EXT: UInt32 = 0x10017
/** @brief 多声道格式扩展标记（AL_EXT_MCFORMATS = 1） */
public const AL_EXT_MCFORMATS: UInt32 = 1
/** @brief 四声道 8 位（AL_FORMAT_QUAD8 = 0x1204） */
public const AL_FORMAT_QUAD8: UInt32 = 0x1204
/** @brief 四声道 16 位（AL_FORMAT_QUAD16 = 0x1205） */
public const AL_FORMAT_QUAD16: UInt32 = 0x1205
/** @brief 四声道 32 位（AL_FORMAT_QUAD32 = 0x1206） */
public const AL_FORMAT_QUAD32: UInt32 = 0x1206
/** @brief 后声道 8 位（AL_FORMAT_REAR8 = 0x1207） */
public const AL_FORMAT_REAR8: UInt32 = 0x1207
/** @brief 后声道 16 位（AL_FORMAT_REAR16 = 0x1208） */
public const AL_FORMAT_REAR16: UInt32 = 0x1208
/** @brief 后声道 32 位（AL_FORMAT_REAR32 = 0x1209） */
public const AL_FORMAT_REAR32: UInt32 = 0x1209
/** @brief 5.1 声道 8 位（AL_FORMAT_51CHN8 = 0x120A） */
public const AL_FORMAT_51CHN8: UInt32 = 0x120A
/** @brief 5.1 声道 16 位（AL_FORMAT_51CHN16 = 0x120B） */
public const AL_FORMAT_51CHN16: UInt32 = 0x120B
/** @brief 5.1 声道 32 位（AL_FORMAT_51CHN32 = 0x120C） */
public const AL_FORMAT_51CHN32: UInt32 = 0x120C
/** @brief 6.1 声道 8 位（AL_FORMAT_61CHN8 = 0x120D） */
public const AL_FORMAT_61CHN8: UInt32 = 0x120D
/** @brief 6.1 声道 16 位（AL_FORMAT_61CHN16 = 0x120E） */
public const AL_FORMAT_61CHN16: UInt32 = 0x120E
/** @brief 6.1 声道 32 位（AL_FORMAT_61CHN32 = 0x120F） */
public const AL_FORMAT_61CHN32: UInt32 = 0x120F
/** @brief 7.1 声道 8 位（AL_FORMAT_71CHN8 = 0x1210） */
public const AL_FORMAT_71CHN8: UInt32 = 0x1210
/** @brief 7.1 声道 16 位（AL_FORMAT_71CHN16 = 0x1211） */
public const AL_FORMAT_71CHN16: UInt32 = 0x1211
/** @brief 7.1 声道 32 位（AL_FORMAT_71CHN32 = 0x1212） */
public const AL_FORMAT_71CHN32: UInt32 = 0x1212
/** @brief 多声道 Mulaw 扩展标记（AL_EXT_MULAW_MCFORMATS = 1） */
public const AL_EXT_MULAW_MCFORMATS: UInt32 = 1
/** @brief 单声道 Mulaw（AL_FORMAT_MONO_MULAW = 0x10014） */
public const AL_FORMAT_MONO_MULAW: UInt32 = 0x10014
/** @brief 立体声 Mulaw（AL_FORMAT_STEREO_MULAW = 0x10015） */
public const AL_FORMAT_STEREO_MULAW: UInt32 = 0x10015
/** @brief 四声道 Mulaw（AL_FORMAT_QUAD_MULAW = 0x10021） */
public const AL_FORMAT_QUAD_MULAW: UInt32 = 0x10021
/** @brief 后声道 Mulaw（AL_FORMAT_REAR_MULAW = 0x10022） */
public const AL_FORMAT_REAR_MULAW: UInt32 = 0x10022
/** @brief 5.1 声道 Mulaw（AL_FORMAT_51CHN_MULAW = 0x10023） */
public const AL_FORMAT_51CHN_MULAW: UInt32 = 0x10023
/** @brief 6.1 声道 Mulaw（AL_FORMAT_61CHN_MULAW = 0x10024） */
public const AL_FORMAT_61CHN_MULAW: UInt32 = 0x10024
/** @brief 7.1 声道 Mulaw（AL_FORMAT_71CHN_MULAW = 0x10025） */
public const AL_FORMAT_71CHN_MULAW: UInt32 = 0x10025
/** @brief IMA4 扩展标记（AL_EXT_IMA4 = 1） */
public const AL_EXT_IMA4: UInt32 = 1
/** @brief 单声道 IMA4（AL_FORMAT_MONO_IMA4 = 0x1300） */
public const AL_FORMAT_MONO_IMA4: UInt32 = 0x1300
/** @brief 立体声 IMA4（AL_FORMAT_STEREO_IMA4 = 0x1301） */
public const AL_FORMAT_STEREO_IMA4: UInt32 = 0x1301
/** @brief 静态缓冲扩展标记（AL_EXT_STATIC_BUFFER = 1） */
public const AL_EXT_STATIC_BUFFER: UInt32 = 1
/** @brief 源距离模型扩展标记（AL_EXT_source_distance_model = 1） */
public const AL_EXT_source_distance_model: UInt32 = 1
/** @brief 源距离模型（AL_SOURCE_DISTANCE_MODEL = 0x200） */
public const AL_SOURCE_DISTANCE_MODEL: UInt32 = 0x200
/** @brief 缓冲子数据扩展标记（AL_SOFT_buffer_sub_data = 1） */
public const AL_SOFT_buffer_sub_data: UInt32 = 1
/** @brief 字节读写偏移（AL_BYTE_RW_OFFSETS_SOFT = 0x1031） */
public const AL_BYTE_RW_OFFSETS_SOFT: UInt32 = 0x1031
/** @brief 采样读写偏移（AL_SAMPLE_RW_OFFSETS_SOFT = 0x1032） */
public const AL_SAMPLE_RW_OFFSETS_SOFT: UInt32 = 0x1032
/** @brief 循环点扩展标记（AL_SOFT_loop_points = 1） */
public const AL_SOFT_loop_points: UInt32 = 1
/** @brief 循环点（AL_LOOP_POINTS_SOFT = 0x2015） */
public const AL_LOOP_POINTS_SOFT: UInt32 = 0x2015
/** @brief 折叠回放扩展标记（AL_EXT_FOLDBACK = 1） */
public const AL_EXT_FOLDBACK: UInt32 = 1
/** @brief 折叠回放扩展名（AL_EXT_FOLDBACK_NAME = "AL_EXT_FOLDBACK"） */
public const AL_EXT_FOLDBACK_NAME: String = "AL_EXT_FOLDBACK"
/** @brief 折叠回放事件块（AL_FOLDBACK_EVENT_BLOCK = 0x4112） */
public const AL_FOLDBACK_EVENT_BLOCK: UInt32 = 0x4112
/** @brief 折叠回放事件开始（AL_FOLDBACK_EVENT_START = 0x4111） */
public const AL_FOLDBACK_EVENT_START: UInt32 = 0x4111
/** @brief 折叠回放事件停止（AL_FOLDBACK_EVENT_STOP = 0x4113） */
public const AL_FOLDBACK_EVENT_STOP: UInt32 = 0x4113
/** @brief 折叠回放单声道模式（AL_FOLDBACK_MODE_MONO = 0x4101） */
public const AL_FOLDBACK_MODE_MONO: UInt32 = 0x4101
/** @brief 折叠回放立体声模式（AL_FOLDBACK_MODE_STEREO = 0x4102） */
public const AL_FOLDBACK_MODE_STEREO: UInt32 = 0x4102
/** @brief 专用增益（AL_DEDICATED_GAIN = 0x0001） */
public const AL_DEDICATED_GAIN: UInt32 = 0x0001
/** @brief 专用对话效果（AL_EFFECT_DEDICATED_DIALOGUE = 0x9001） */
public const AL_EFFECT_DEDICATED_DIALOGUE: UInt32 = 0x9001
/** @brief 专用低频效果（AL_EFFECT_DEDICATED_LOW_FREQUENCY_EFFECT = 0x9000） */
public const AL_EFFECT_DEDICATED_LOW_FREQUENCY_EFFECT: UInt32 = 0x9000

// =============================================================================
// alext.h 扩展：AL_SOFT_buffer_samples（缓冲样本采样）
// =============================================================================

/** @brief 缓冲样本扩展标记（AL_SOFT_buffer_samples = 1） */
public const AL_SOFT_buffer_samples: UInt32 = 1
/** @brief 单声道（AL_MONO_SOFT = 0x1500） */
public const AL_MONO_SOFT: UInt32 = 0x1500
/** @brief 立体声（AL_STEREO_SOFT = 0x1501） */
public const AL_STEREO_SOFT: UInt32 = 0x1501
/** @brief 后声道（AL_REAR_SOFT = 0x1502） */
public const AL_REAR_SOFT: UInt32 = 0x1502
/** @brief 四声道（AL_QUAD_SOFT = 0x1503） */
public const AL_QUAD_SOFT: UInt32 = 0x1503
/** @brief 5.1 声道（AL_5POINT1_SOFT = 0x1504） */
public const AL_5POINT1_SOFT: UInt32 = 0x1504
/** @brief 6.1 声道（AL_6POINT1_SOFT = 0x1505） */
public const AL_6POINT1_SOFT: UInt32 = 0x1505
/** @brief 7.1 声道（AL_7POINT1_SOFT = 0x1506） */
public const AL_7POINT1_SOFT: UInt32 = 0x1506
/** @brief 字节（AL_BYTE_SOFT = 0x1400） */
public const AL_BYTE_SOFT: UInt32 = 0x1400
/** @brief 无符号字节（AL_UNSIGNED_BYTE_SOFT = 0x1401） */
public const AL_UNSIGNED_BYTE_SOFT: UInt32 = 0x1401
/** @brief 短整型（AL_SHORT_SOFT = 0x1402） */
public const AL_SHORT_SOFT: UInt32 = 0x1402
/** @brief 无符号短整型（AL_UNSIGNED_SHORT_SOFT = 0x1403） */
public const AL_UNSIGNED_SHORT_SOFT: UInt32 = 0x1403
/** @brief 整型（AL_INT_SOFT = 0x1404） */
public const AL_INT_SOFT: UInt32 = 0x1404
/** @brief 无符号整型（AL_UNSIGNED_INT_SOFT = 0x1405） */
public const AL_UNSIGNED_INT_SOFT: UInt32 = 0x1405
/** @brief 浮点（AL_FLOAT_SOFT = 0x1406） */
public const AL_FLOAT_SOFT: UInt32 = 0x1406
/** @brief 双精度（AL_DOUBLE_SOFT = 0x1407） */
public const AL_DOUBLE_SOFT: UInt32 = 0x1407
/** @brief 3 通道字节（AL_BYTE3_SOFT = 0x1408） */
public const AL_BYTE3_SOFT: UInt32 = 0x1408
/** @brief 3 通道无符号字节（AL_UNSIGNED_BYTE3_SOFT = 0x1409） */
public const AL_UNSIGNED_BYTE3_SOFT: UInt32 = 0x1409
/** @brief 单声道 8 位（AL_MONO8_SOFT = 0x1100） */
public const AL_MONO8_SOFT: UInt32 = 0x1100
/** @brief 单声道 16 位（AL_MONO16_SOFT = 0x1101） */
public const AL_MONO16_SOFT: UInt32 = 0x1101
/** @brief 单声道 32 位浮点（AL_MONO32F_SOFT = 0x10010） */
public const AL_MONO32F_SOFT: UInt32 = 0x10010
/** @brief 立体声 8 位（AL_STEREO8_SOFT = 0x1102） */
public const AL_STEREO8_SOFT: UInt32 = 0x1102
/** @brief 立体声 16 位（AL_STEREO16_SOFT = 0x1103） */
public const AL_STEREO16_SOFT: UInt32 = 0x1103
/** @brief 立体声 32 位浮点（AL_STEREO32F_SOFT = 0x10011） */
public const AL_STEREO32F_SOFT: UInt32 = 0x10011
/** @brief 四声道 8 位（AL_QUAD8_SOFT = 0x1204） */
public const AL_QUAD8_SOFT: UInt32 = 0x1204
/** @brief 四声道 16 位（AL_QUAD16_SOFT = 0x1205） */
public const AL_QUAD16_SOFT: UInt32 = 0x1205
/** @brief 四声道 32 位浮点（AL_QUAD32F_SOFT = 0x1206） */
public const AL_QUAD32F_SOFT: UInt32 = 0x1206
/** @brief 后声道 8 位（AL_REAR8_SOFT = 0x1207） */
public const AL_REAR8_SOFT: UInt32 = 0x1207
/** @brief 后声道 16 位（AL_REAR16_SOFT = 0x1208） */
public const AL_REAR16_SOFT: UInt32 = 0x1208
/** @brief 后声道 32 位浮点（AL_REAR32F_SOFT = 0x1209） */
public const AL_REAR32F_SOFT: UInt32 = 0x1209
/** @brief 5.1 声道 8 位（AL_5POINT1_8_SOFT = 0x120A） */
public const AL_5POINT1_8_SOFT: UInt32 = 0x120A
/** @brief 5.1 声道 16 位（AL_5POINT1_16_SOFT = 0x120B） */
public const AL_5POINT1_16_SOFT: UInt32 = 0x120B
/** @brief 5.1 声道 32 位浮点（AL_5POINT1_32F_SOFT = 0x120C） */
public const AL_5POINT1_32F_SOFT: UInt32 = 0x120C
/** @brief 6.1 声道 8 位（AL_6POINT1_8_SOFT = 0x120D） */
public const AL_6POINT1_8_SOFT: UInt32 = 0x120D
/** @brief 6.1 声道 16 位（AL_6POINT1_16_SOFT = 0x120E） */
public const AL_6POINT1_16_SOFT: UInt32 = 0x120E
/** @brief 6.1 声道 32 位浮点（AL_6POINT1_32F_SOFT = 0x120F） */
public const AL_6POINT1_32F_SOFT: UInt32 = 0x120F
/** @brief 7.1 声道 8 位（AL_7POINT1_8_SOFT = 0x1210） */
public const AL_7POINT1_8_SOFT: UInt32 = 0x1210
/** @brief 7.1 声道 16 位（AL_7POINT1_16_SOFT = 0x1211） */
public const AL_7POINT1_16_SOFT: UInt32 = 0x1211
/** @brief 7.1 声道 32 位浮点（AL_7POINT1_32F_SOFT = 0x1212） */
public const AL_7POINT1_32F_SOFT: UInt32 = 0x1212
/** @brief 内部格式（AL_INTERNAL_FORMAT_SOFT = 0x2008） */
public const AL_INTERNAL_FORMAT_SOFT: UInt32 = 0x2008
/** @brief 字节长度（AL_BYTE_LENGTH_SOFT = 0x2009） */
public const AL_BYTE_LENGTH_SOFT: UInt32 = 0x2009
/** @brief 采样长度（AL_SAMPLE_LENGTH_SOFT = 0x200A） */
public const AL_SAMPLE_LENGTH_SOFT: UInt32 = 0x200A
/** @brief 秒长度（AL_SEC_LENGTH_SOFT = 0x200B） */
public const AL_SEC_LENGTH_SOFT: UInt32 = 0x200B

// =============================================================================
// alext.h 扩展：direct_channels / stereo_angles / source_radius / latency
// =============================================================================

/** @brief 直通声道扩展标记（AL_SOFT_direct_channels = 1） */
public const AL_SOFT_direct_channels: UInt32 = 1
/** @brief 直通声道（AL_DIRECT_CHANNELS_SOFT = 0x1033） */
public const AL_DIRECT_CHANNELS_SOFT: UInt32 = 0x1033
/** @brief 立体声角度扩展标记（AL_EXT_STEREO_ANGLES = 1） */
public const AL_EXT_STEREO_ANGLES: UInt32 = 1
/** @brief 立体声角度（AL_STEREO_ANGLES = 0x1030） */
public const AL_STEREO_ANGLES: UInt32 = 0x1030
/** @brief 源半径扩展标记（AL_EXT_SOURCE_RADIUS = 1） */
public const AL_EXT_SOURCE_RADIUS: UInt32 = 1
/** @brief 源半径（AL_SOURCE_RADIUS = 0x1031） */
public const AL_SOURCE_RADIUS: UInt32 = 0x1031
/** @brief 源延迟扩展标记（AL_SOFT_source_latency = 1） */
public const AL_SOFT_source_latency: UInt32 = 1
/** @brief 采样偏移延迟（AL_SAMPLE_OFFSET_LATENCY_SOFT = 0x1200） */
public const AL_SAMPLE_OFFSET_LATENCY_SOFT: UInt32 = 0x1200
/** @brief 秒偏移延迟（AL_SEC_OFFSET_LATENCY_SOFT = 0x1201） */
public const AL_SEC_OFFSET_LATENCY_SOFT: UInt32 = 0x1201
/** @brief 延迟更新扩展标记（AL_SOFT_deferred_updates = 1） */
public const AL_SOFT_deferred_updates: UInt32 = 1
/** @brief 延迟更新（AL_DEFERRED_UPDATES_SOFT = 0xC002） */
public const AL_DEFERRED_UPDATES_SOFT: UInt32 = 0xC002
/** @brief 块对齐扩展标记（AL_SOFT_block_alignment = 1） */
public const AL_SOFT_block_alignment: UInt32 = 1
/** @brief 解包块对齐（AL_UNPACK_BLOCK_ALIGNMENT_SOFT = 0x200C） */
public const AL_UNPACK_BLOCK_ALIGNMENT_SOFT: UInt32 = 0x200C
/** @brief 打包块对齐（AL_PACK_BLOCK_ALIGNMENT_SOFT = 0x200D） */
public const AL_PACK_BLOCK_ALIGNMENT_SOFT: UInt32 = 0x200D
/** @brief MSADPCM 扩展标记（AL_SOFT_MSADPCM = 1） */
public const AL_SOFT_MSADPCM: UInt32 = 1
/** @brief 单声道 MSADPCM（AL_FORMAT_MONO_MSADPCM_SOFT = 0x1302） */
public const AL_FORMAT_MONO_MSADPCM_SOFT: UInt32 = 0x1302
/** @brief 立体声 MSADPCM（AL_FORMAT_STEREO_MSADPCM_SOFT = 0x1303） */
public const AL_FORMAT_STEREO_MSADPCM_SOFT: UInt32 = 0x1303
/** @brief 源长度扩展标记（AL_SOFT_source_length = 1） */
public const AL_SOFT_source_length: UInt32 = 1
/** @brief 缓冲长度查询扩展标记（AL_SOFT_buffer_length_query = 1） */
public const AL_SOFT_buffer_length_query: UInt32 = 1

// =============================================================================
// alext.h 扩展：B-Format 环绕声
// =============================================================================

/** @brief B-Format 扩展标记（AL_EXT_BFORMAT = 1） */
public const AL_EXT_BFORMAT: UInt32 = 1
/** @brief 2D B-Format 8 位（AL_FORMAT_BFORMAT2D_8 = 0x20021） */
public const AL_FORMAT_BFORMAT2D_8: UInt32 = 0x20021
/** @brief 2D B-Format 16 位（AL_FORMAT_BFORMAT2D_16 = 0x20022） */
public const AL_FORMAT_BFORMAT2D_16: UInt32 = 0x20022
/** @brief 2D B-Format 32 位浮点（AL_FORMAT_BFORMAT2D_FLOAT32 = 0x20023） */
public const AL_FORMAT_BFORMAT2D_FLOAT32: UInt32 = 0x20023
/** @brief 3D B-Format 8 位（AL_FORMAT_BFORMAT3D_8 = 0x20031） */
public const AL_FORMAT_BFORMAT3D_8: UInt32 = 0x20031
/** @brief 3D B-Format 16 位（AL_FORMAT_BFORMAT3D_16 = 0x20032） */
public const AL_FORMAT_BFORMAT3D_16: UInt32 = 0x20032
/** @brief 3D B-Format 32 位浮点（AL_FORMAT_BFORMAT3D_FLOAT32 = 0x20033） */
public const AL_FORMAT_BFORMAT3D_FLOAT32: UInt32 = 0x20033
/** @brief B-Format Mulaw 扩展标记（AL_EXT_MULAW_BFORMAT = 1） */
public const AL_EXT_MULAW_BFORMAT: UInt32 = 1
/** @brief 2D B-Format Mulaw（AL_FORMAT_BFORMAT2D_MULAW = 0x10031） */
public const AL_FORMAT_BFORMAT2D_MULAW: UInt32 = 0x10031
/** @brief 3D B-Format Mulaw（AL_FORMAT_BFORMAT3D_MULAW = 0x10032） */
public const AL_FORMAT_BFORMAT3D_MULAW: UInt32 = 0x10032

// =============================================================================
// alext.h 扩展：gain_clamp / resampler / spatialize / bformat_ex / effect_target
// =============================================================================

/** @brief 增益钳制扩展标记（AL_SOFT_gain_clamp_ex = 1） */
public const AL_SOFT_gain_clamp_ex: UInt32 = 1
/** @brief 增益限制（AL_GAIN_LIMIT_SOFT = 0x200E） */
public const AL_GAIN_LIMIT_SOFT: UInt32 = 0x200E
/** @brief 源重采样器扩展标记（AL_SOFT_source_resampler = 1） */
public const AL_SOFT_source_resampler: UInt32 = 1
/** @brief 重采样器数量（AL_NUM_RESAMPLERS_SOFT = 0x1210） */
public const AL_NUM_RESAMPLERS_SOFT: UInt32 = 0x1210
/** @brief 默认重采样器（AL_DEFAULT_RESAMPLER_SOFT = 0x1211） */
public const AL_DEFAULT_RESAMPLER_SOFT: UInt32 = 0x1211
/** @brief 源重采样器（AL_SOURCE_RESAMPLER_SOFT = 0x1212） */
public const AL_SOURCE_RESAMPLER_SOFT: UInt32 = 0x1212
/** @brief 重采样器名称（AL_RESAMPLER_NAME_SOFT = 0x1213） */
public const AL_RESAMPLER_NAME_SOFT: UInt32 = 0x1213
/** @brief 源空间化扩展标记（AL_SOFT_source_spatialize = 1） */
public const AL_SOFT_source_spatialize: UInt32 = 1
/** @brief 源空间化（AL_SOURCE_SPATIALIZE_SOFT = 0x1214） */
public const AL_SOURCE_SPATIALIZE_SOFT: UInt32 = 0x1214
/** @brief 自动（AL_AUTO_SOFT = 0x0002） */
public const AL_AUTO_SOFT: UInt32 = 0x0002
/** @brief 采样偏移时钟（AL_SAMPLE_OFFSET_CLOCK_SOFT = 0x1202） */
public const AL_SAMPLE_OFFSET_CLOCK_SOFT: UInt32 = 0x1202
/** @brief 秒偏移时钟（AL_SEC_OFFSET_CLOCK_SOFT = 0x1203） */
public const AL_SEC_OFFSET_CLOCK_SOFT: UInt32 = 0x1203
/** @brief 直通声道混音扩展标记（AL_SOFT_direct_channels_remix = 1） */
public const AL_SOFT_direct_channels_remix: UInt32 = 1
/** @brief 丢弃不匹配（AL_DROP_UNMATCHED_SOFT = 0x0001） */
public const AL_DROP_UNMATCHED_SOFT: UInt32 = 0x0001
/** @brief 重混不匹配（AL_REMIX_UNMATCHED_SOFT = 0x0002） */
public const AL_REMIX_UNMATCHED_SOFT: UInt32 = 0x0002
/** @brief B-Format 扩展扩展标记（AL_SOFT_bformat_ex = 1） */
public const AL_SOFT_bformat_ex: UInt32 = 1
/** @brief 环境声布局（AL_AMBISONIC_LAYOUT_SOFT = 0x1997） */
public const AL_AMBISONIC_LAYOUT_SOFT: UInt32 = 0x1997
/** @brief 环境声缩放（AL_AMBISONIC_SCALING_SOFT = 0x1998） */
public const AL_AMBISONIC_SCALING_SOFT: UInt32 = 0x1998
/** @brief FuMa（AL_FUMA_SOFT = 0x0000） */
public const AL_FUMA_SOFT: UInt32 = 0x0000
/** @brief ACN（AL_ACN_SOFT = 0x0001） */
public const AL_ACN_SOFT: UInt32 = 0x0001
/** @brief SN3D（AL_SN3D_SOFT = 0x0001） */
public const AL_SN3D_SOFT: UInt32 = 0x0001
/** @brief N3D（AL_N3D_SOFT = 0x0002） */
public const AL_N3D_SOFT: UInt32 = 0x0002
/** @brief 效果目标扩展标记（AL_SOFT_effect_target = 1） */
public const AL_SOFT_effect_target: UInt32 = 1
/** @brief 效果槽目标（AL_EFFECTSLOT_TARGET_SOFT = 0x199C） */
public const AL_EFFECTSLOT_TARGET_SOFT: UInt32 = 0x199C

// =============================================================================
// alext.h 扩展：events / callback_buffer / UHJ / debug
// =============================================================================

/** @brief 事件扩展标记（AL_SOFT_events = 1） */
public const AL_SOFT_events: UInt32 = 1
/** @brief 事件回调函数（AL_EVENT_CALLBACK_FUNCTION_SOFT = 0x19A2） */
public const AL_EVENT_CALLBACK_FUNCTION_SOFT: UInt32 = 0x19A2
/** @brief 事件回调用户参数（AL_EVENT_CALLBACK_USER_PARAM_SOFT = 0x19A3） */
public const AL_EVENT_CALLBACK_USER_PARAM_SOFT: UInt32 = 0x19A3
/** @brief 事件：缓冲完成（AL_EVENT_TYPE_BUFFER_COMPLETED_SOFT = 0x19A4） */
public const AL_EVENT_TYPE_BUFFER_COMPLETED_SOFT: UInt32 = 0x19A4
/** @brief 事件：源状态变化（AL_EVENT_TYPE_SOURCE_STATE_CHANGED_SOFT = 0x19A5） */
public const AL_EVENT_TYPE_SOURCE_STATE_CHANGED_SOFT: UInt32 = 0x19A5
/** @brief 事件：设备断开（AL_EVENT_TYPE_DISCONNECTED_SOFT = 0x19A6） */
public const AL_EVENT_TYPE_DISCONNECTED_SOFT: UInt32 = 0x19A6
/** @brief 回调缓冲扩展标记（AL_SOFT_callback_buffer = 1） */
public const AL_SOFT_callback_buffer: UInt32 = 1
/** @brief 缓冲回调函数（AL_BUFFER_CALLBACK_FUNCTION_SOFT = 0x19A0） */
public const AL_BUFFER_CALLBACK_FUNCTION_SOFT: UInt32 = 0x19A0
/** @brief 缓冲回调用户参数（AL_BUFFER_CALLBACK_USER_PARAM_SOFT = 0x19A1） */
public const AL_BUFFER_CALLBACK_USER_PARAM_SOFT: UInt32 = 0x19A1
/** @brief UHJ 扩展标记（AL_SOFT_UHJ = 1） */
public const AL_SOFT_UHJ: UInt32 = 1
/** @brief UHJ 2 声道 8 位（AL_FORMAT_UHJ2CHN8_SOFT = 0x19A2） */
public const AL_FORMAT_UHJ2CHN8_SOFT: UInt32 = 0x19A2
/** @brief UHJ 2 声道 16 位（AL_FORMAT_UHJ2CHN16_SOFT = 0x19A3） */
public const AL_FORMAT_UHJ2CHN16_SOFT: UInt32 = 0x19A3
/** @brief UHJ 2 声道浮点（AL_FORMAT_UHJ2CHN_FLOAT32_SOFT = 0x19A4） */
public const AL_FORMAT_UHJ2CHN_FLOAT32_SOFT: UInt32 = 0x19A4
/** @brief UHJ 3 声道 8 位（AL_FORMAT_UHJ3CHN8_SOFT = 0x19A5） */
public const AL_FORMAT_UHJ3CHN8_SOFT: UInt32 = 0x19A5
/** @brief UHJ 3 声道 16 位（AL_FORMAT_UHJ3CHN16_SOFT = 0x19A6） */
public const AL_FORMAT_UHJ3CHN16_SOFT: UInt32 = 0x19A6
/** @brief UHJ 3 声道浮点（AL_FORMAT_UHJ3CHN_FLOAT32_SOFT = 0x19A7） */
public const AL_FORMAT_UHJ3CHN_FLOAT32_SOFT: UInt32 = 0x19A7
/** @brief UHJ 4 声道 8 位（AL_FORMAT_UHJ4CHN8_SOFT = 0x19A8） */
public const AL_FORMAT_UHJ4CHN8_SOFT: UInt32 = 0x19A8
/** @brief UHJ 4 声道 16 位（AL_FORMAT_UHJ4CHN16_SOFT = 0x19A9） */
public const AL_FORMAT_UHJ4CHN16_SOFT: UInt32 = 0x19A9
/** @brief UHJ 4 声道浮点（AL_FORMAT_UHJ4CHN_FLOAT32_SOFT = 0x19AA） */
public const AL_FORMAT_UHJ4CHN_FLOAT32_SOFT: UInt32 = 0x19AA
/** @brief 立体声模式（AL_STEREO_MODE_SOFT = 0x19B0） */
public const AL_STEREO_MODE_SOFT: UInt32 = 0x19B0
/** @brief 普通（AL_NORMAL_SOFT = 0x0000） */
public const AL_NORMAL_SOFT: UInt32 = 0x0000
/** @brief 超级立体声（AL_SUPER_STEREO_SOFT = 0x0001） */
public const AL_SUPER_STEREO_SOFT: UInt32 = 0x0001
/** @brief 超级立体声宽度（AL_SUPER_STEREO_WIDTH_SOFT = 0x19B1） */
public const AL_SUPER_STEREO_WIDTH_SOFT: UInt32 = 0x19B1
/** @brief UHJ 扩展扩展标记（AL_SOFT_UHJ_ex = 1） */
public const AL_SOFT_UHJ_ex: UInt32 = 1
/** @brief UHJ 2 声道 Mulaw（AL_FORMAT_UHJ2CHN_MULAW_SOFT = 0x19B3） */
public const AL_FORMAT_UHJ2CHN_MULAW_SOFT: UInt32 = 0x19B3
/** @brief UHJ 2 声道 Alaw（AL_FORMAT_UHJ2CHN_ALAW_SOFT = 0x19B4） */
public const AL_FORMAT_UHJ2CHN_ALAW_SOFT: UInt32 = 0x19B4
/** @brief UHJ 2 声道 IMA4（AL_FORMAT_UHJ2CHN_IMA4_SOFT = 0x19B5） */
public const AL_FORMAT_UHJ2CHN_IMA4_SOFT: UInt32 = 0x19B5
/** @brief UHJ 2 声道 MSADPCM（AL_FORMAT_UHJ2CHN_MSADPCM_SOFT = 0x19B6） */
public const AL_FORMAT_UHJ2CHN_MSADPCM_SOFT: UInt32 = 0x19B6
/** @brief UHJ 3 声道 Mulaw（AL_FORMAT_UHJ3CHN_MULAW_SOFT = 0x19B7） */
public const AL_FORMAT_UHJ3CHN_MULAW_SOFT: UInt32 = 0x19B7
/** @brief UHJ 3 声道 Alaw（AL_FORMAT_UHJ3CHN_ALAW_SOFT = 0x19B8） */
public const AL_FORMAT_UHJ3CHN_ALAW_SOFT: UInt32 = 0x19B8
/** @brief UHJ 4 声道 Mulaw（AL_FORMAT_UHJ4CHN_MULAW_SOFT = 0x19B9） */
public const AL_FORMAT_UHJ4CHN_MULAW_SOFT: UInt32 = 0x19B9
/** @brief UHJ 4 声道 Alaw（AL_FORMAT_UHJ4CHN_ALAW_SOFT = 0x19BA） */
public const AL_FORMAT_UHJ4CHN_ALAW_SOFT: UInt32 = 0x19BA
/** @brief 源启动延迟扩展标记（AL_SOFT_source_start_delay = 1） */
public const AL_SOFT_source_start_delay: UInt32 = 1
/** @brief 调试扩展标记（AL_EXT_debug = 1） */
public const AL_EXT_debug: UInt32 = 1
/** @brief 不关心（AL_DONT_CARE_EXT = 0x0002） */
public const AL_DONT_CARE_EXT: UInt32 = 0x0002
/** @brief 调试输出（AL_DEBUG_OUTPUT_EXT = 0x19B2） */
public const AL_DEBUG_OUTPUT_EXT: UInt32 = 0x19B2
/** @brief 调试回调函数（AL_DEBUG_CALLBACK_FUNCTION_EXT = 0x19B3） */
public const AL_DEBUG_CALLBACK_FUNCTION_EXT: UInt32 = 0x19B3
/** @brief 调试回调用户参数（AL_DEBUG_CALLBACK_USER_PARAM_EXT = 0x19B4） */
public const AL_DEBUG_CALLBACK_USER_PARAM_EXT: UInt32 = 0x19B4
/** @brief 调试来源：API（AL_DEBUG_SOURCE_API_EXT = 0x19B5） */
public const AL_DEBUG_SOURCE_API_EXT: UInt32 = 0x19B5
/** @brief 调试来源：音频系统（AL_DEBUG_SOURCE_AUDIO_SYSTEM_EXT = 0x19B6） */
public const AL_DEBUG_SOURCE_AUDIO_SYSTEM_EXT: UInt32 = 0x19B6
/** @brief 调试来源：第三方（AL_DEBUG_SOURCE_THIRD_PARTY_EXT = 0x19B7） */
public const AL_DEBUG_SOURCE_THIRD_PARTY_EXT: UInt32 = 0x19B7
/** @brief 调试来源：应用程序（AL_DEBUG_SOURCE_APPLICATION_EXT = 0x19B8） */
public const AL_DEBUG_SOURCE_APPLICATION_EXT: UInt32 = 0x19B8
/** @brief 调试来源：其他（AL_DEBUG_SOURCE_OTHER_EXT = 0x19B9） */
public const AL_DEBUG_SOURCE_OTHER_EXT: UInt32 = 0x19B9
/** @brief 调试类型：错误（AL_DEBUG_TYPE_ERROR_EXT = 0x19BA） */
public const AL_DEBUG_TYPE_ERROR_EXT: UInt32 = 0x19BA
/** @brief 调试类型：废弃行为（AL_DEBUG_TYPE_DEPRECATED_BEHAVIOR_EXT = 0x19BB） */
public const AL_DEBUG_TYPE_DEPRECATED_BEHAVIOR_EXT: UInt32 = 0x19BB
/** @brief 调试类型：未定义行为（AL_DEBUG_TYPE_UNDEFINED_BEHAVIOR_EXT = 0x19BC） */
public const AL_DEBUG_TYPE_UNDEFINED_BEHAVIOR_EXT: UInt32 = 0x19BC
/** @brief 调试类型：可移植性（AL_DEBUG_TYPE_PORTABILITY_EXT = 0x19BD） */
public const AL_DEBUG_TYPE_PORTABILITY_EXT: UInt32 = 0x19BD
/** @brief 调试类型：性能（AL_DEBUG_TYPE_PERFORMANCE_EXT = 0x19BE） */
public const AL_DEBUG_TYPE_PERFORMANCE_EXT: UInt32 = 0x19BE
/** @brief 调试类型：标记（AL_DEBUG_TYPE_MARKER_EXT = 0x19BF） */
public const AL_DEBUG_TYPE_MARKER_EXT: UInt32 = 0x19BF
/** @brief 调试类型：压栈组（AL_DEBUG_TYPE_PUSH_GROUP_EXT = 0x19C0） */
public const AL_DEBUG_TYPE_PUSH_GROUP_EXT: UInt32 = 0x19C0
/** @brief 调试类型：弹栈组（AL_DEBUG_TYPE_POP_GROUP_EXT = 0x19C1） */
public const AL_DEBUG_TYPE_POP_GROUP_EXT: UInt32 = 0x19C1
/** @brief 调试类型：其他（AL_DEBUG_TYPE_OTHER_EXT = 0x19C2） */
public const AL_DEBUG_TYPE_OTHER_EXT: UInt32 = 0x19C2
/** @brief 调试严重级：高（AL_DEBUG_SEVERITY_HIGH_EXT = 0x19C3） */
public const AL_DEBUG_SEVERITY_HIGH_EXT: UInt32 = 0x19C3
/** @brief 调试严重级：中（AL_DEBUG_SEVERITY_MEDIUM_EXT = 0x19C4） */
public const AL_DEBUG_SEVERITY_MEDIUM_EXT: UInt32 = 0x19C4
/** @brief 调试严重级：低（AL_DEBUG_SEVERITY_LOW_EXT = 0x19C5） */
public const AL_DEBUG_SEVERITY_LOW_EXT: UInt32 = 0x19C5
/** @brief 调试严重级：通知（AL_DEBUG_SEVERITY_NOTIFICATION_EXT = 0x19C6） */
public const AL_DEBUG_SEVERITY_NOTIFICATION_EXT: UInt32 = 0x19C6
/** @brief 已记录调试消息数（AL_DEBUG_LOGGED_MESSAGES_EXT = 0x19C7） */
public const AL_DEBUG_LOGGED_MESSAGES_EXT: UInt32 = 0x19C7
/** @brief 下一条记录消息长度（AL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH_EXT = 0x19C8） */
public const AL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH_EXT: UInt32 = 0x19C8
/** @brief 最大调试消息长度（AL_MAX_DEBUG_MESSAGE_LENGTH_EXT = 0x19C9） */
public const AL_MAX_DEBUG_MESSAGE_LENGTH_EXT: UInt32 = 0x19C9
/** @brief 最大调试记录消息数（AL_MAX_DEBUG_LOGGED_MESSAGES_EXT = 0x19CA） */
public const AL_MAX_DEBUG_LOGGED_MESSAGES_EXT: UInt32 = 0x19CA
/** @brief 最大调试组栈深度（AL_MAX_DEBUG_GROUP_STACK_DEPTH_EXT = 0x19CB） */
public const AL_MAX_DEBUG_GROUP_STACK_DEPTH_EXT: UInt32 = 0x19CB
/** @brief 最大标签长度（AL_MAX_LABEL_LENGTH_EXT = 0x19CC） */
public const AL_MAX_LABEL_LENGTH_EXT: UInt32 = 0x19CC
/** @brief 栈溢出（AL_STACK_OVERFLOW_EXT = 0x19CD） */
public const AL_STACK_OVERFLOW_EXT: UInt32 = 0x19CD
/** @brief 栈下溢（AL_STACK_UNDERFLOW_EXT = 0x19CE） */
public const AL_STACK_UNDERFLOW_EXT: UInt32 = 0x19CE
/** @brief 上下文标志（AL_CONTEXT_FLAGS_EXT = 0x19CF） */
public const AL_CONTEXT_FLAGS_EXT: UInt32 = 0x19CF
/** @brief 缓冲对象（AL_BUFFER_EXT = 0x1009） */
public const AL_BUFFER_EXT: UInt32 = 0x1009
/** @brief 源对象（AL_SOURCE_EXT = 0x19D0） */
public const AL_SOURCE_EXT: UInt32 = 0x19D0
/** @brief 滤波器对象（AL_FILTER_EXT = 0x19D1） */
public const AL_FILTER_EXT: UInt32 = 0x19D1
/** @brief 效果对象（AL_EFFECT_EXT = 0x19D2） */
public const AL_EFFECT_EXT: UInt32 = 0x19D2
/** @brief 辅助效果槽对象（AL_AUXILIARY_EFFECT_SLOT_EXT = 0x19D3） */
public const AL_AUXILIARY_EFFECT_SLOT_EXT: UInt32 = 0x19D3
/** @brief 直通上下文扩展标记（AL_EXT_direct_context = 1） */
public const AL_EXT_direct_context: UInt32 = 1
/** @brief 高阶环境声扩展标记（AL_SOFT_bformat_hoa = 1） */
public const AL_SOFT_bformat_hoa: UInt32 = 1
/** @brief 解包环境声阶数（AL_UNPACK_AMBISONIC_ORDER_SOFT = 0x199D） */
public const AL_UNPACK_AMBISONIC_ORDER_SOFT: UInt32 = 0x199D
