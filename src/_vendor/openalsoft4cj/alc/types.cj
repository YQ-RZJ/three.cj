/**
 * @file openalsoft4cj.alc 类型定义
 * @brief OpenAL Context 管理 API（alc.h）的枚举类型定义
 * @explain 本文件包含 alc.h 中的枚举类型。foreign 函数使用 UInt32/UInt8
 *         表示 C 枚举/布尔，调用方通过 `EnumType.value()` 与
 *         `EnumType.fromValue(u32)` 转换。
 * @note ALCdevice / ALCcontext 为不透明句柄，FFI 层使用 CPointer<Unit>
 *         表示（见 ffi.cj），未定义公开结构体。
 */
protected package three._vendor.openalsoft4cj.alc

/**
 * @brief ALC 错误码（alcGetError 返回值）
 * @explain 对应 alc.h 中 ALC_NO_ERROR 至 ALC_OUT_OF_MEMORY。
 */
public enum AlcErrorCode {
    /** @brief 无错误（ALC_NO_ERROR = 0） */
    | NoError
    /** @brief 无效设备句柄（ALC_INVALID_DEVICE = 0xA001） */
    | InvalidDevice
    /** @brief 无效上下文句柄（ALC_INVALID_CONTEXT = 0xA002） */
    | InvalidContext
    /** @brief 无效枚举（ALC_INVALID_ENUM = 0xA003） */
    | InvalidEnum
    /** @brief 无效值（ALC_INVALID_VALUE = 0xA004） */
    | InvalidValue
    /** @brief 内存不足（ALC_OUT_OF_MEMORY = 0xA005） */
    | OutOfMemory

    public func value(): UInt32 {
        match (this) {
            case NoError => 0
            case InvalidDevice => 0xA001
            case InvalidContext => 0xA002
            case InvalidEnum => 0xA003
            case InvalidValue => 0xA004
            case OutOfMemory => 0xA005
        }
    }

    public static func fromValue(v: UInt32): AlcErrorCode {
        match (v) {
            case 0 => NoError
            case 0xA001 => InvalidDevice
            case 0xA002 => InvalidContext
            case 0xA003 => InvalidEnum
            case 0xA004 => InvalidValue
            case _ => OutOfMemory
        }
    }
}
