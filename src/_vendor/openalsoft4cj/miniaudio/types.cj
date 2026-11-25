/**
 * @file openalsoft4cj.miniaudio 类型定义
 * @brief miniaudio 解码库（0.11.x）的枚举与结构体类型定义
 * @explain 本文件包含 miniaudio 的核心枚举（错误码/采样格式/抖动模式/
 *         声道混合模式/编码格式）与 ma_decoder_config 不透明结构体。
 *         仓颉枚举是引用类型，不满足 CType 约束，foreign 函数使用 Int32/
 *         UInt32（底层 C 枚举表示），调用方通过 `EnumType.value()` 与
 *         `EnumType.fromValue(v)` 转换。
 * @note ma_decoder_config 内部包含 resampler/回调等复杂嵌套，完整 C 布局
 *         不适合在仓颉侧展开，故定义为不透明类型（@C 空结构体），FFI 层
 *         使用 CPointer<Unit> 表示；传 NULL 即使用 miniaudio 默认配置。
 */
protected package three._vendor.openalsoft4cj.miniaudio

/**
 * @brief miniaudio 返回码（ma_result）
 * @explain 对应 miniaudio.h 中 ma_result 枚举；0 表示成功，负值表示错误。
 */
public enum MaResult {
    /** @brief 成功（MA_SUCCESS = 0） */
    | Success
    /** @brief 通用错误（MA_ERROR = -1） */
    | Error
    /** @brief 参数无效（MA_INVALID_ARGS = -2） */
    | InvalidArgs
    /** @brief 非法操作（MA_INVALID_OPERATION = -3） */
    | InvalidOperation
    /** @brief 内存不足（MA_OUT_OF_MEMORY = -4） */
    | OutOfMemory
    /** @brief 越界（MA_OUT_OF_RANGE = -5） */
    | OutOfRange
    /** @brief 访问被拒绝（MA_ACCESS_DENIED = -6） */
    | AccessDenied
    /** @brief 文件/设备不存在（MA_DOES_NOT_EXIST = -7） */
    | DoesNotExist
    /** @brief 已存在（MA_ALREADY_EXISTS = -8） */
    | AlreadyExists
    /** @brief 打开文件过多（MA_TOO_MANY_OPEN_FILES = -9） */
    | TooManyOpenFiles
    /** @brief 文件无效（MA_INVALID_FILE = -10） */
    | InvalidFile
    /** @brief 过大（MA_TOO_BIG = -11） */
    | TooBig
    /** @brief 路径过长（MA_PATH_TOO_LONG = -12） */
    | PathTooLong
    /** @brief 名称过长（MA_NAME_TOO_LONG = -13） */
    | NameTooLong
    /** @brief 不是目录（MA_NOT_DIRECTORY = -14） */
    | NotDirectory
    /** @brief 是目录（MA_IS_DIRECTORY = -15） */
    | IsDirectory
    /** @brief 目录非空（MA_DIRECTORY_NOT_EMPTY = -16） */
    | DirectoryNotEmpty
    /** @brief 已到末尾（MA_AT_END = -17） */
    | AtEnd
    /** @brief 无空间（MA_NO_SPACE = -18） */
    | NoSpace
    /** @brief 忙（MA_BUSY = -19） */
    | Busy
    /** @brief IO 错误（MA_IO_ERROR = -20） */
    | IoError
    /** @brief 中断（MA_INTERRUPT = -21） */
    | Interrupt
    /** @brief 不可用（MA_UNAVAILABLE = -22） */
    | Unavailable
    /** @brief 已在使用（MA_ALREADY_IN_USE = -23） */
    | AlreadyInUse
    /** @brief 地址无效（MA_BAD_ADDRESS = -24） */
    | BadAddress
    /** @brief 非法寻址（MA_BAD_SEEK = -25） */
    | BadSeek
    /** @brief 管道损坏（MA_BAD_PIPE = -26） */
    | BadPipe
    /** @brief 死锁（MA_DEADLOCK = -27） */
    | Deadlock
    /** @brief 链接过多（MA_TOO_MANY_LINKS = -28） */
    | TooManyLinks
    /** @brief 未实现（MA_NOT_IMPLEMENTED = -29） */
    | NotImplemented
    /** @brief 无消息（MA_NO_MESSAGE = -30） */
    | NoMessage
    /** @brief 消息错误（MA_BAD_MESSAGE = -31） */
    | BadMessage
    /** @brief 无可用数据（MA_NO_DATA_AVAILABLE = -32） */
    | NoDataAvailable
    /** @brief 数据无效/损坏（MA_INVALID_DATA = -33） */
    | InvalidData
    /** @brief 超时（MA_TIMEOUT = -34） */
    | Timeout
    /** @brief 无网络（MA_NO_NETWORK = -35） */
    | NoNetwork
    /** @brief 不唯一（MA_NOT_UNIQUE = -36） */
    | NotUnique
    /** @brief 不是套接字（MA_NOT_SOCKET = -37） */
    | NotSocket
    /** @brief 无地址（MA_NO_ADDRESS = -38） */
    | NoAddress
    /** @brief 协议错误（MA_BAD_PROTOCOL = -39） */
    | BadProtocol
    /** @brief 协议不可用（MA_PROTOCOL_UNAVAILABLE = -40） */
    | ProtocolUnavailable
    /** @brief 协议不支持（MA_PROTOCOL_NOT_SUPPORTED = -41） */
    | ProtocolNotSupported
    /** @brief 协议族不支持（MA_PROTOCOL_FAMILY_NOT_SUPPORTED = -42） */
    | ProtocolFamilyNotSupported
    /** @brief 地址族不支持（MA_ADDRESS_FAMILY_NOT_SUPPORTED = -43） */
    | AddressFamilyNotSupported
    /** @brief 套接字不支持（MA_SOCKET_NOT_SUPPORTED = -44） */
    | SocketNotSupported
    /** @brief 连接重置（MA_CONNECTION_RESET = -45） */
    | ConnectionReset
    /** @brief 已连接（MA_ALREADY_CONNECTED = -46） */
    | AlreadyConnected
    /** @brief 未连接（MA_NOT_CONNECTED = -47） */
    | NotConnected
    /** @brief 连接被拒绝（MA_CONNECTION_REFUSED = -48） */
    | ConnectionRefused
    /** @brief 无主机（MA_NO_HOST = -49） */
    | NoHost
    /** @brief 进行中（MA_IN_PROGRESS = -50） */
    | InProgress
    /** @brief 已取消（MA_CANCELLED = -51） */
    | Cancelled
    /** @brief 内存已映射（MA_MEMORY_ALREADY_MAPPED = -52） */
    | MemoryAlreadyMapped
    /** @brief CRC 不匹配（MA_CRC_MISMATCH = -100） */
    | CrcMismatch
    /** @brief 格式不支持（MA_FORMAT_NOT_SUPPORTED = -200） */
    | FormatNotSupported
    /** @brief 设备类型不支持（MA_DEVICE_TYPE_NOT_SUPPORTED = -201） */
    | DeviceTypeNotSupported
    /** @brief 共享模式不支持（MA_SHARE_MODE_NOT_SUPPORTED = -202） */
    | ShareModeNotSupported
    /** @brief 无后端（MA_NO_BACKEND = -203） */
    | NoBackend
    /** @brief 无设备（MA_NO_DEVICE = -204） */
    | NoDevice
    /** @brief API 未找到（MA_API_NOT_FOUND = -205） */
    | ApiNotFound
    /** @brief 设备配置无效（MA_INVALID_DEVICE_CONFIG = -206） */
    | InvalidDeviceConfig
    /** @brief 循环（MA_LOOP = -207） */
    | Loop
    /** @brief 后端未启用（MA_BACKEND_NOT_ENABLED = -208） */
    | BackendNotEnabled
    /** @brief 其他未知错误 */
    | Other

    /** @brief 将枚举值转换为 Int32（C ABI 兼容） */
    public func value(): Int32 {
        match (this) {
            case Success => 0
            case Error => -1
            case InvalidArgs => -2
            case InvalidOperation => -3
            case OutOfMemory => -4
            case OutOfRange => -5
            case AccessDenied => -6
            case DoesNotExist => -7
            case AlreadyExists => -8
            case TooManyOpenFiles => -9
            case InvalidFile => -10
            case TooBig => -11
            case PathTooLong => -12
            case NameTooLong => -13
            case NotDirectory => -14
            case IsDirectory => -15
            case DirectoryNotEmpty => -16
            case AtEnd => -17
            case NoSpace => -18
            case Busy => -19
            case IoError => -20
            case Interrupt => -21
            case Unavailable => -22
            case AlreadyInUse => -23
            case BadAddress => -24
            case BadSeek => -25
            case BadPipe => -26
            case Deadlock => -27
            case TooManyLinks => -28
            case NotImplemented => -29
            case NoMessage => -30
            case BadMessage => -31
            case NoDataAvailable => -32
            case InvalidData => -33
            case Timeout => -34
            case NoNetwork => -35
            case NotUnique => -36
            case NotSocket => -37
            case NoAddress => -38
            case BadProtocol => -39
            case ProtocolUnavailable => -40
            case ProtocolNotSupported => -41
            case ProtocolFamilyNotSupported => -42
            case AddressFamilyNotSupported => -43
            case SocketNotSupported => -44
            case ConnectionReset => -45
            case AlreadyConnected => -46
            case NotConnected => -47
            case ConnectionRefused => -48
            case NoHost => -49
            case InProgress => -50
            case Cancelled => -51
            case MemoryAlreadyMapped => -52
            case CrcMismatch => -100
            case FormatNotSupported => -200
            case DeviceTypeNotSupported => -201
            case ShareModeNotSupported => -202
            case NoBackend => -203
            case NoDevice => -204
            case ApiNotFound => -205
            case InvalidDeviceConfig => -206
            case Loop => -207
            case BackendNotEnabled => -208
            case Other => -999
        }
    }

    /** @brief 从 Int32 转换回枚举值 */
    public static func fromValue(v: Int32): MaResult {
        match (v) {
            case 0 => Success
            case -1 => Error
            case -2 => InvalidArgs
            case -3 => InvalidOperation
            case -4 => OutOfMemory
            case -5 => OutOfRange
            case -6 => AccessDenied
            case -7 => DoesNotExist
            case -8 => AlreadyExists
            case -9 => TooManyOpenFiles
            case -10 => InvalidFile
            case -11 => TooBig
            case -12 => PathTooLong
            case -13 => NameTooLong
            case -14 => NotDirectory
            case -15 => IsDirectory
            case -16 => DirectoryNotEmpty
            case -17 => AtEnd
            case -18 => NoSpace
            case -19 => Busy
            case -20 => IoError
            case -21 => Interrupt
            case -22 => Unavailable
            case -23 => AlreadyInUse
            case -24 => BadAddress
            case -25 => BadSeek
            case -26 => BadPipe
            case -27 => Deadlock
            case -28 => TooManyLinks
            case -29 => NotImplemented
            case -30 => NoMessage
            case -31 => BadMessage
            case -32 => NoDataAvailable
            case -33 => InvalidData
            case -34 => Timeout
            case -35 => NoNetwork
            case -36 => NotUnique
            case -37 => NotSocket
            case -38 => NoAddress
            case -39 => BadProtocol
            case -40 => ProtocolUnavailable
            case -41 => ProtocolNotSupported
            case -42 => ProtocolFamilyNotSupported
            case -43 => AddressFamilyNotSupported
            case -44 => SocketNotSupported
            case -45 => ConnectionReset
            case -46 => AlreadyConnected
            case -47 => NotConnected
            case -48 => ConnectionRefused
            case -49 => NoHost
            case -50 => InProgress
            case -51 => Cancelled
            case -52 => MemoryAlreadyMapped
            case -100 => CrcMismatch
            case -200 => FormatNotSupported
            case -201 => DeviceTypeNotSupported
            case -202 => ShareModeNotSupported
            case -203 => NoBackend
            case -204 => NoDevice
            case -205 => ApiNotFound
            case -206 => InvalidDeviceConfig
            case -207 => Loop
            case -208 => BackendNotEnabled
            case _ => Other
        }
    }
}

/**
 * @brief miniaudio 采样格式（ma_format）
 * @explain 指定解码输出的样本类型；ma_format_unknown 表示使用源文件格式。
 */
public enum MaFormat {
    /** @brief 未知/自动（ma_format_unknown = 0） */
    | Unknown
    /** @brief 8 位无符号整数（ma_format_u8 = 1） */
    | U8
    /** @brief 16 位有符号整数（ma_format_s16 = 2） */
    | S16
    /** @brief 24 位有符号整数，紧密打包 3 字节/样本（ma_format_s24 = 3） */
    | S24
    /** @brief 32 位有符号整数（ma_format_s32 = 4） */
    | S32
    /** @brief 32 位浮点（ma_format_f32 = 5） */
    | F32

    public func value(): UInt32 {
        match (this) {
            case Unknown => 0
            case U8 => 1
            case S16 => 2
            case S24 => 3
            case S32 => 4
            case F32 => 5
        }
    }

    public static func fromValue(v: UInt32): MaFormat {
        match (v) {
            case 0 => Unknown
            case 1 => U8
            case 2 => S16
            case 3 => S24
            case 4 => S32
            case _ => F32
        }
    }
}

/**
 * @brief miniaudio 抖动模式（ma_dither_mode）
 * @explain 用于降低位深的抖动算法。
 */
public enum MaDitherMode {
    /** @brief 无抖动（ma_dither_mode_none = 0） */
    | None
    /** @brief 矩形抖动（ma_dither_mode_rectangle = 1） */
    | Rectangle
    /** @brief 三角抖动（ma_dither_mode_triangle = 2） */
    | Triangle

    public func value(): UInt32 {
        match (this) {
            case None => 0
            case Rectangle => 1
            case Triangle => 2
        }
    }

    public static func fromValue(v: UInt32): MaDitherMode {
        match (v) {
            case 0 => None
            case 1 => Rectangle
            case _ => Triangle
        }
    }
}

/**
 * @brief miniaudio 声道混合模式（ma_channel_mix_mode）
 * @explain 声道数不匹配时的混合策略。
 */
public enum MaChannelMixMode {
    /** @brief 矩形平均混合（ma_channel_mix_mode_rectangular = 0，默认） */
    | Rectangular
    /** @brief 简单混合：丢弃多余声道，缺失声道置零（= 1） */
    | Simple
    /** @brief 自定义权重混合（= 2） */
    | CustomWeights

    public func value(): UInt32 {
        match (this) {
            case Rectangular => 0
            case Simple => 1
            case CustomWeights => 2
        }
    }

    public static func fromValue(v: UInt32): MaChannelMixMode {
        match (v) {
            case 0 => Rectangular
            case 1 => Simple
            case _ => CustomWeights
        }
    }
}

/**
 * @brief miniaudio 编码格式（ma_encoding_format）
 * @explain 文件编码类型，通常由解码器自动识别。
 */
public enum MaEncodingFormat {
    /** @brief 未知（ma_encoding_format_unknown = 0） */
    | Unknown
    /** @brief WAV（ma_encoding_format_wav = 1） */
    | Wav
    /** @brief FLAC（ma_encoding_format_flac = 2） */
    | Flac
    /** @brief MP3（ma_encoding_format_mp3 = 3） */
    | Mp3
    /** @brief Vorbis/OGG（ma_encoding_format_vorbis = 4） */
    | Vorbis

    public func value(): UInt32 {
        match (this) {
            case Unknown => 0
            case Wav => 1
            case Flac => 2
            case Mp3 => 3
            case Vorbis => 4
        }
    }

    public static func fromValue(v: UInt32): MaEncodingFormat {
        match (v) {
            case 0 => Unknown
            case 1 => Wav
            case 2 => Flac
            case 3 => Mp3
            case _ => Vorbis
        }
    }
}

/**
 * @brief miniaudio 寻址原点（ma_seek_origin）
 * @explain 用于解码器/编码器的 seek 操作。
 */
public enum MaSeekOrigin {
    /** @brief 从文件/流起始处（ma_seek_origin_start = 0） */
    | Start
    /** @brief 从当前位置（ma_seek_origin_current = 1） */
    | Current
    /** @brief 从末尾（ma_seek_origin_end = 2，解码器不使用） */
    | End

    public func value(): UInt32 {
        match (this) {
            case Start => 0
            case Current => 1
            case End => 2
        }
    }

    public static func fromValue(v: UInt32): MaSeekOrigin {
        match (v) {
            case 0 => Start
            case 1 => Current
            case _ => End
        }
    }
}

/**
 * @brief miniaudio 重采样算法（ma_resample_algorithm）
 * @explain 指定重采样器使用的算法。
 */
public enum MaResampleAlgorithm {
    /** @brief 线性重采样（ma_resample_algorithm_linear = 0，默认，最快） */
    | Linear
    /** @brief 自定义重采样（ma_resample_algorithm_custom = 1，使用 pBackendVTable） */
    | Custom

    public func value(): UInt32 {
        match (this) {
            case Linear => 0
            case Custom => 1
        }
    }

    public static func fromValue(v: UInt32): MaResampleAlgorithm {
        match (v) {
            case 0 => Linear
            case _ => Custom
        }
    }
}

/**
 * @brief miniaudio 重采样配置（ma_resampler_config）
 * @explain 与 C 结构体布局一致（@C），嵌套于 MaDecoderConfig.resampling。
 */
@C
public struct MaResamplerConfig {
    /** @brief 采样格式（MaFormat 值，须为 F32 或 S16） */
    public var format: UInt32 = 0
    /** @brief 声道数 */
    public var channels: UInt32 = 0
    /** @brief 输入采样率 */
    public var sampleRateIn: UInt32 = 0
    /** @brief 输出采样率 */
    public var sampleRateOut: UInt32 = 0
    /** @brief 重采样算法（MaResampleAlgorithm 值） */
    public var algorithm: UInt32 = 0
    /** @brief 自定义后端虚函数表（不透明，Custom 算法时使用） */
    public var pBackendVTable: CPointer<Unit> = CPointer<Unit>()
    /** @brief 后端用户数据 */
    public var pBackendUserData: CPointer<Unit> = CPointer<Unit>()
    /** @brief 线性重采样低通滤波器阶数 */
    public var lpfOrder: UInt32 = 0

    public init() {}
}

/**
 * @brief miniaudio 分配回调（ma_allocation_callbacks）
 * @explain 与 C 结构体布局一致（@C），用于自定义内存分配。
 * @note CFunc 空函数指针通过 `CFunc<...>(CPointer<Unit>())` 构造（仓颉
 *       CFunc 与 CPointer 互转规则）。
 */
@C
public struct MaAllocationCallbacks {
    /** @brief 用户数据 */
    public var pUserData: CPointer<Unit> = CPointer<Unit>()
    /** @brief 分配回调 onMalloc(sz, pUserData) -> void* */
    public var onMalloc: CFunc<(UInt64, CPointer<Unit>) -> CPointer<Unit>> =
        CFunc<(UInt64, CPointer<Unit>) -> CPointer<Unit>>(CPointer<Unit>())
    /** @brief 重分配回调 onRealloc(p, sz, pUserData) -> void* */
    public var onRealloc: CFunc<(CPointer<Unit>, UInt64, CPointer<Unit>) -> CPointer<Unit>> =
        CFunc<(CPointer<Unit>, UInt64, CPointer<Unit>) -> CPointer<Unit>>(CPointer<Unit>())
    /** @brief 释放回调 onFree(p, pUserData) */
    public var onFree: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>) -> Unit>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief miniaudio 解码器配置（ma_decoder_config）
 * @explain 与 C 结构体布局一致（@C），完整展开（含嵌套 resampling /
 *         allocationCallbacks 结构体），可直接作为 ma_decoder_config_init*
 *         的返回值，或用于 ma_decode_file / ma_decoder_init 的 pConfig 参数。
 */
@C
public struct MaDecoderConfig {
    /** @brief 输出采样格式（MaFormat 值，0=使用源格式） */
    public var format: UInt32 = 0
    /** @brief 输出声道数（0=使用源声道） */
    public var channels: UInt32 = 0
    /** @brief 输出采样率（0=使用源采样率） */
    public var sampleRate: UInt32 = 0
    /** @brief 声道映射（可传空指针） */
    public var pChannelMap: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 声道混合模式（MaChannelMixMode 值） */
    public var channelMixMode: UInt32 = 0
    /** @brief 抖动模式（MaDitherMode 值） */
    public var ditherMode: UInt32 = 0
    /** @brief 重采样配置 */
    public var resampling: MaResamplerConfig = MaResamplerConfig()
    /** @brief 分配回调 */
    public var allocationCallbacks: MaAllocationCallbacks = MaAllocationCallbacks()
    /** @brief 编码格式（MaEncodingFormat 值） */
    public var encodingFormat: UInt32 = 0
    /** @brief 生成 seek table 的 seek point 数量（0=不生成） */
    public var seekPointCount: UInt32 = 0
    /** @brief 自定义解码后端虚函数表数组（不透明，可传空指针） */
    public var ppCustomBackendVTables: CPointer<CPointer<Unit>> = CPointer<CPointer<Unit>>()
    /** @brief 自定义后端数量 */
    public var customBackendCount: UInt32 = 0
    /** @brief 自定义后端用户数据 */
    public var pCustomBackendUserData: CPointer<Unit> = CPointer<Unit>()

    public init() {}
}
