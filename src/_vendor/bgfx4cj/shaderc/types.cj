/**
 * @file shaderc 类型定义
 * @brief shaderc C API 的枚举、不透明类型和结构体定义
 * @explain 本文件包含 shaderc shader 编译器的 CFFI 类型定义，
 *         包括着色器类型枚举、编译选项结构体、返回码和编译结果。
 * @note 值类型通过 @C 标注确保 C 内存布局兼容。
 */
protected package three._vendor.bgfx4cj.shaderc

// =============================================================================
// Enums
// =============================================================================

/**
 * @brief 着色器类型枚举
 * @explain 定义要编译的着色器阶段类型。
 */
public enum ScType {
    /** @brief 顶点着色器 */
    | Vertex
    /** @brief 片段着色器（像素着色器） */
    | Fragment
    /** @brief 计算着色器 */
    | Compute

    /** @brief 将枚举值转换为 UInt32（对应 C 层 'v'/'f'/'c' 字符） */
    public func value(): UInt32 {
        match (this) {
            case Vertex   => 0x76  // 'v'
            case Fragment => 0x66  // 'f'
            case Compute  => 0x63  // 'c'
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): ScType {
        match (v) {
            case 0x76 => Vertex
            case 0x66 => Fragment
            case 0x63 => Compute
            case _ => Vertex
        }
    }
}

/**
 * @brief 编译返回码枚举
 * @explain shaderc 编译操作的返回状态码。
 */
public enum ScResultCode {
    /** @brief 编译成功 */
    | Success
    /** @brief 未知错误 */
    | ErrorUnknown
    /** @brief 参数无效 */
    | ErrorInvalidParam
    /** @brief 编译失败 */
    | ErrorCompileFailed
    /** @brief 未知 profile */
    | ErrorUnknownProfile
    /** @brief 输入数据过大 */
    | ErrorInputTooLarge

    /** @brief 将枚举值转换为 Int32 */
    public func value(): Int32 {
        match (this) {
            case Success           => 0
            case ErrorUnknown      => -1
            case ErrorInvalidParam => -2
            case ErrorCompileFailed => -3
            case ErrorUnknownProfile => -4
            case ErrorInputTooLarge => -5
        }
    }

    /** @brief 从 Int32 转换回枚举值 */
    public static func fromValue(v: Int32): ScResultCode {
        match (v) {
            case 0 => Success
            case -1 => ErrorUnknown
            case -2 => ErrorInvalidParam
            case -3 => ErrorCompileFailed
            case -4 => ErrorUnknownProfile
            case -5 => ErrorInputTooLarge
            case _ => ErrorUnknown
        }
    }
}

// =============================================================================
// Value structs (C-compatible layout via @C annotation)
// =============================================================================

/**
 * @brief Shader 编译选项
 * @explain 控制 shader 编译的参数，包括目标平台、profile、预处理定义等。
 *         platform/profile 为 C 字符串指针，传入 NULL 时使用空字符串。
 */
@C
public struct ScOptions {
    /** @brief 着色器类型（'v'/'f'/'c'） */
    public var shaderType: UInt32 = 0x76
    /** @brief 目标平台字符串指针 */
    public var platform: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief profile 字符串指针 */
    public var profile: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 是否原始模式 */
    public var raw: Bool = false
    /** @brief 是否包含调试信息 */
    public var debug: Bool = false
    /** @brief 是否启用优化 */
    public var optimize: Bool = false
    /** @brief 优化等级（0-3） */
    public var optimizationLevel: UInt32 = 0
    /** @brief 仅预处理 */
    public var preprocessOnly: Bool = false
    /** @brief 反汇编输出 */
    public var disasm: Bool = false
    /** @brief include 目录数组指针 */
    public var includeDirs: CPointer<CPointer<UInt8>> = CPointer<CPointer<UInt8>>()
    /** @brief include 目录数量 */
    public var numIncludeDirs: UInt32 = 0
    /** @brief 宏定义数组指针（"NAME=VALUE" 格式） */
    public var defines: CPointer<CPointer<UInt8>> = CPointer<CPointer<UInt8>>()
    /** @brief 宏定义数量 */
    public var numDefines: UInt32 = 0
    public init() {}
}

/**
 * @brief 编译结果
 * @explain shaderc 编译操作的输出结果，包含二进制 shader 数据和编译日志。
 */
@C
public struct ScResult {
    /** @brief 返回状态码（0=成功，负数=错误） */
    public var status: Int32 = 0
    /** @brief 二进制 shader 数据指针 */
    public var data: CPointer<Unit> = CPointer<Unit>()
    /** @brief 数据大小（字节） */
    public var size: UInt32 = 0
    /** @brief 编译日志/错误消息指针 */
    public var message: CPointer<UInt8> = CPointer<UInt8>()
    public init() {}
}