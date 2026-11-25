/**
 * @file openalsoft4cj.al 类型定义
 * @brief OpenAL 核心 API（al.h）的枚举类型定义
 * @explain 本文件包含 al.h 中的枚举类型。仓颉枚举是引用类型，不满足 CType
 *         约束，不能直接用作 foreign 函数参数/返回值类型。foreign 函数使用
 *         UInt32（底层 C 枚举表示），调用方通过 `EnumType.value()` 与
 *         `EnumType.fromValue(u32)` 转换。
 * @note 参数标识符（如 AL_POSITION、AL_GAIN 等）为普通常量，见 constants.cj。
 */
protected package three._vendor.openalsoft4cj.al

/**
 * @brief 源状态（AL_SOURCE_STATE 查询结果）
 * @explain 对应 al.h 中 AL_INITIAL/AL_PLAYING/AL_PAUSED/AL_STOPPED。
 */
public enum SourceState {
    /** @brief 初始状态（AL_INITIAL = 0x1011） */
    | Initial
    /** @brief 播放中（AL_PLAYING = 0x1012） */
    | Playing
    /** @brief 暂停（AL_PAUSED = 0x1013） */
    | Paused
    /** @brief 停止（AL_STOPPED = 0x1014） */
    | Stopped

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容） */
    public func value(): UInt32 {
        match (this) {
            case Initial => 0x1011
            case Playing => 0x1012
            case Paused => 0x1013
            case Stopped => 0x1014
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): SourceState {
        match (v) {
            case 0x1011 => Initial
            case 0x1012 => Playing
            case 0x1013 => Paused
            case _ => Stopped
        }
    }
}

/**
 * @brief 源类型（AL_SOURCE_TYPE 查询结果）
 * @explain 对应 al.h 中 AL_STATIC/AL_STREAMING/AL_UNDETERMINED。
 */
public enum SourceType {
    /** @brief 静态源：通过 AL_BUFFER 绑定缓冲（AL_STATIC = 0x1028） */
    | Static
    /** @brief 流式源：通过 alSourceQueueBuffers 排队缓冲（AL_STREAMING = 0x1029） */
    | Streaming
    /** @brief 未确定：绑定 NULL 缓冲（AL_UNDETERMINED = 0x1030） */
    | Undetermined

    public func value(): UInt32 {
        match (this) {
            case Static => 0x1028
            case Streaming => 0x1029
            case Undetermined => 0x1030
        }
    }

    public static func fromValue(v: UInt32): SourceType {
        match (v) {
            case 0x1028 => Static
            case 0x1029 => Streaming
            case _ => Undetermined
        }
    }
}

/**
 * @brief 缓冲采样格式（alBufferData 的 format 参数）
 * @explain 对应 al.h 中 AL_FORMAT_MONO8/16、AL_FORMAT_STEREO8/16。
 */
public enum BufferFormat {
    /** @brief 单声道 8 位无符号（AL_FORMAT_MONO8 = 0x1100） */
    | Mono8
    /** @brief 单声道 16 位有符号（AL_FORMAT_MONO16 = 0x1101） */
    | Mono16
    /** @brief 立体声 8 位无符号（AL_FORMAT_STEREO8 = 0x1102） */
    | Stereo8
    /** @brief 立体声 16 位有符号（AL_FORMAT_STEREO16 = 0x1103） */
    | Stereo16

    public func value(): UInt32 {
        match (this) {
            case Mono8 => 0x1100
            case Mono16 => 0x1101
            case Stereo8 => 0x1102
            case Stereo16 => 0x1103
        }
    }

    public static func fromValue(v: UInt32): BufferFormat {
        match (v) {
            case 0x1100 => Mono8
            case 0x1101 => Mono16
            case 0x1102 => Stereo8
            case _ => Stereo16
        }
    }
}

/**
 * @brief OpenAL 错误码（alGetError 返回值）
 * @explain 对应 al.h 中 AL_NO_ERROR 至 AL_OUT_OF_MEMORY。
 */
public enum ErrorCode {
    /** @brief 无错误（AL_NO_ERROR = 0） */
    | NoError
    /** @brief 无效名称/ID（AL_INVALID_NAME = 0xA001） */
    | InvalidName
    /** @brief 无效枚举（AL_INVALID_ENUM = 0xA002） */
    | InvalidEnum
    /** @brief 无效值（AL_INVALID_VALUE = 0xA003） */
    | InvalidValue
    /** @brief 非法调用（AL_INVALID_OPERATION = 0xA004） */
    | InvalidOperation
    /** @brief 内存不足（AL_OUT_OF_MEMORY = 0xA005） */
    | OutOfMemory

    public func value(): UInt32 {
        match (this) {
            case NoError => 0
            case InvalidName => 0xA001
            case InvalidEnum => 0xA002
            case InvalidValue => 0xA003
            case InvalidOperation => 0xA004
            case OutOfMemory => 0xA005
        }
    }

    public static func fromValue(v: UInt32): ErrorCode {
        match (v) {
            case 0 => NoError
            case 0xA001 => InvalidName
            case 0xA002 => InvalidEnum
            case 0xA003 => InvalidValue
            case 0xA004 => InvalidOperation
            case _ => OutOfMemory
        }
    }
}

/**
 * @brief 距离衰减模型（AL_DISTANCE_MODEL 参数）
 * @explain 对应 al.h 中 AL_NONE/AL_INVERSE_DISTANCE 等 7 种模型。
 */
public enum DistanceModel {
    /** @brief 无距离衰减（AL_NONE = 0） */
    | None
    /** @brief 反比距离（AL_INVERSE_DISTANCE = 0xD001） */
    | InverseDistance
    /** @brief 反比距离（钳制）（AL_INVERSE_DISTANCE_CLAMPED = 0xD002） */
    | InverseDistanceClamped
    /** @brief 线性距离（AL_LINEAR_DISTANCE = 0xD003） */
    | LinearDistance
    /** @brief 线性距离（钳制）（AL_LINEAR_DISTANCE_CLAMPED = 0xD004） */
    | LinearDistanceClamped
    /** @brief 指数距离（AL_EXPONENT_DISTANCE = 0xD005） */
    | ExponentDistance
    /** @brief 指数距离（钳制）（AL_EXPONENT_DISTANCE_CLAMPED = 0xD006） */
    | ExponentDistanceClamped

    public func value(): UInt32 {
        match (this) {
            case None => 0
            case InverseDistance => 0xD001
            case InverseDistanceClamped => 0xD002
            case LinearDistance => 0xD003
            case LinearDistanceClamped => 0xD004
            case ExponentDistance => 0xD005
            case ExponentDistanceClamped => 0xD006
        }
    }

    public static func fromValue(v: UInt32): DistanceModel {
        match (v) {
            case 0 => None
            case 0xD001 => InverseDistance
            case 0xD002 => InverseDistanceClamped
            case 0xD003 => LinearDistance
            case 0xD004 => LinearDistanceClamped
            case 0xD005 => ExponentDistance
            case _ => ExponentDistanceClamped
        }
    }
}
