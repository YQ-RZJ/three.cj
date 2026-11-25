/**
 * @file bgfx4cj CFFI 类型定义
 * @brief bgfx C99 API 的枚举、句柄和结构体类型定义
 * 
 * 本文件包含所有 bgfx C API 的枚举、不透明句柄和 C 兼容结构体。
 * 
 * @note 仓颉枚举是引用类型，不满足 CType 约束，不能直接用作 foreign 函数
 *       参数/返回值类型。foreign 函数使用 UInt32（底层 C 枚举表示），
 *       调用方通过 `EnumType.value()` 和 `EnumType.fromValue(u32)` 转换。
 * 
 * @see https://github.com/bkaradzic/bgfx
 */
protected package three._vendor.bgfx4cj.bgfx

// =============================================================================
// Enums
// =============================================================================

/**
 * @brief bgfx 致命错误类型
 * @explain 当 bgfx 遇到不可恢复的错误时，通过回调函数报告此枚举值。
 */
public enum Fatal {
    /** @brief 调试检查失败 */
    | DebugCheck
    /** @brief 着色器无效或编译失败 */
    | InvalidShader
    /** @brief 无法初始化渲染后端 */
    | UnableToInitialize
    /** @brief 无法创建纹理 */
    | UnableToCreateTexture
    /** @brief GPU 设备丢失（如 TDR 或硬件移除） */
    | DeviceLost
    /** @brief 枚举成员总数，用于边界检查 */
    | Count

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容） */
    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case DebugCheck => 0
            case InvalidShader => 1
            case UnableToInitialize => 2
            case UnableToCreateTexture => 3
            case DeviceLost => 4
            case Count => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Fatal {
        match (v) {
            case 0 => DebugCheck
            case 1 => InvalidShader
            case 2 => UnableToInitialize
            case 3 => UnableToCreateTexture
            case 4 => DeviceLost
            case _ => Count
        }
    }
}

/**
 * @brief bgfx 渲染后端类型
 * @explain 指定使用哪个图形 API 进行渲染。
 * @note 并非所有平台都支持所有渲染器类型。
 */
public enum RendererType {
    /** @brief 空操作渲染器（不产生任何绘制调用） */
    | Noop
    /** @brief AGC (Android Graphics Compositor) */
    | Agc
    /** @brief Direct3D 11 */
    | Direct3D11
    /** @brief Direct3D 12 */
    | Direct3D12
    /** @brief GNM (PlayStation 4) */
    | Gnm
    /** @brief Metal (Apple) */
    | Metal
    /** @brief NVN (Nintendo Switch) */
    | Nvn
    /** @brief OpenGL ES（嵌入式系统） */
    | OpenGLES
    /** @brief OpenGL（桌面） */
    | OpenGL
    /** @brief Vulkan */
    | Vulkan
    /** @brief WebGPU */
    | WebGPU
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Noop => 0
            case Agc => 1
            case Direct3D11 => 2
            case Direct3D12 => 3
            case Gnm => 4
            case Metal => 5
            case Nvn => 6
            case OpenGLES => 7
            case OpenGL => 8
            case Vulkan => 9
            case WebGPU => 10
            case Count => 11
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): RendererType {
        match (v) {
            case 0 => Noop
            case 1 => Agc
            case 2 => Direct3D11
            case 3 => Direct3D12
            case 4 => Gnm
            case 5 => Metal
            case 6 => Nvn
            case 7 => OpenGLES
            case 8 => OpenGL
            case 9 => Vulkan
            case 10 => WebGPU
            case _ => Count
        }
    }
}

/**
 * @brief 计算资源访问权限
 * @explain 用于计算着色器中缓冲区的读写访问模式。
 */
public enum Access {
    /** @brief 只读访问 */
    | Read
    /** @brief 只写访问 */
    | Write
    /** @brief 读写访问 */
    | ReadWrite
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Read => 0
            case Write => 1
            case ReadWrite => 2
            case Count => 3
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Access {
        match (v) {
            case 0 => Read
            case 1 => Write
            case 2 => ReadWrite
            case _ => Count
        }
    }
}

/**
 * @brief 顶点属性类型
 * @explain 定义顶点布局中每个属性的语义类型。
 * @note 最多支持 18 个属性（Position ~ TexCoord7）。
 */
public enum Attrib {
    /** @brief 顶点位置（通常为 float3/float4） */
    | Position
    /** @brief 顶点法线 */
    | Normal
    /** @brief 顶点切线（用于法线贴图） */
    | Tangent
    /** @brief 顶点副切线 */
    | Bitangent
    /** @brief 顶点颜色 0 */
    | Color0
    /** @brief 顶点颜色 1 */
    | Color1
    /** @brief 顶点颜色 2 */
    | Color2
    /** @brief 顶点颜色 3 */
    | Color3
    /** @brief 骨骼索引（用于蒙皮） */
    | Indices
    /** @brief 骨骼权重（用于蒙皮） */
    | Weight
    /** @brief 纹理坐标 0 */
    | TexCoord0
    /** @brief 纹理坐标 1 */
    | TexCoord1
    /** @brief 纹理坐标 2 */
    | TexCoord2
    /** @brief 纹理坐标 3 */
    | TexCoord3
    /** @brief 纹理坐标 4 */
    | TexCoord4
    /** @brief 纹理坐标 5 */
    | TexCoord5
    /** @brief 纹理坐标 6 */
    | TexCoord6
    /** @brief 纹理坐标 7 */
    | TexCoord7
    /** @brief 纹理坐标 8（新版 bgfx 扩展至 16 组） */
    | TexCoord8
    /** @brief 纹理坐标 9 */
    | TexCoord9
    /** @brief 纹理坐标 10 */
    | TexCoord10
    /** @brief 纹理坐标 11 */
    | TexCoord11
    /** @brief 纹理坐标 12 */
    | TexCoord12
    /** @brief 纹理坐标 13 */
    | TexCoord13
    /** @brief 纹理坐标 14 */
    | TexCoord14
    /** @brief 纹理坐标 15 */
    | TexCoord15
    /** @brief 枚举成员总数（新版 bgfx BGFX_ATTRIB_COUNT=26） */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Position => 0
            case Normal => 1
            case Tangent => 2
            case Bitangent => 3
            case Color0 => 4
            case Color1 => 5
            case Color2 => 6
            case Color3 => 7
            case Indices => 8
            case Weight => 9
            case TexCoord0 => 10
            case TexCoord1 => 11
            case TexCoord2 => 12
            case TexCoord3 => 13
            case TexCoord4 => 14
            case TexCoord5 => 15
            case TexCoord6 => 16
            case TexCoord7 => 17
            case TexCoord8 => 18
            case TexCoord9 => 19
            case TexCoord10 => 20
            case TexCoord11 => 21
            case TexCoord12 => 22
            case TexCoord13 => 23
            case TexCoord14 => 24
            case TexCoord15 => 25
            case Count => 26
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Attrib {
        match (v) {
            case 0 => Position
            case 1 => Normal
            case 2 => Tangent
            case 3 => Bitangent
            case 4 => Color0
            case 5 => Color1
            case 6 => Color2
            case 7 => Color3
            case 8 => Indices
            case 9 => Weight
            case 10 => TexCoord0
            case 11 => TexCoord1
            case 12 => TexCoord2
            case 13 => TexCoord3
            case 14 => TexCoord4
            case 15 => TexCoord5
            case 16 => TexCoord6
            case 17 => TexCoord7
            case 18 => TexCoord8
            case 19 => TexCoord9
            case 20 => TexCoord10
            case 21 => TexCoord11
            case 22 => TexCoord12
            case 23 => TexCoord13
            case 24 => TexCoord14
            case 25 => TexCoord15
            case _ => Count
        }
    }
}

/**
 * @brief 顶点属性数据类型
 * @explain 定义顶点属性在内存中的存储格式。
 */
public enum AttribType {
    /** @brief 8 位有符号整数 */
    | `Int8`
    /** @brief 8 位无符号整数（归一化到 [0,1]） */
    | Uint8
    /** @brief 10 位无符号整数（归一化到 [0,1]） */
    | Uint10
    /** @brief 16 位有符号整数（归一化到 [-1,1]） */
    | `Int16`
    /** @brief 16 位无符号整数 */
    | Uint16
    /** @brief 16 位浮点数（半精度） */
    | Half
    /** @brief 32 位浮点数（单精度） */
    | Float
    /** @brief 32 位有符号整数 */
    | `Int32`
    /** @brief 32 位无符号整数 */
    | Uint32
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32（对齐新版 c99 bgfx_attrib_type_t） */
    public func value(): UInt32 {
        match (this) {
            case `Int8` => 0
            case Uint8 => 1
            case Uint10 => 2
            case `Int16` => 3
            case Uint16 => 4
            case Half => 5
            case Float => 6
            case `Int32` => 7
            case Uint32 => 8
            case Count => 9
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): AttribType {
        match (v) {
            case 0 => `Int8`
            case 1 => Uint8
            case 2 => Uint10
            case 3 => `Int16`
            case 4 => Uint16
            case 5 => Half
            case 6 => Float
            case 7 => `Int32`
            case 8 => Uint32
            case _ => Count
        }
    }
}

/**
 * @brief 纹理格式枚举
 * @explain 定义所有支持的纹理像素格式，包括压缩格式、未压缩格式、深度格式等。
 * @note 并非所有格式在所有平台上都受支持，请使用 `bgfx_is_texture_valid` 检查。
 */
public enum TextureFormat {
    // ---- 压缩格式 ----
    /** @brief BC1 (DXT1) 压缩，RGB，4bpp */
    | BC1
    /** @brief BC2 (DXT3) 压缩，RGBA，8bpp */
    | BC2
    /** @brief BC3 (DXT5) 压缩，RGBA，8bpp */
    | BC3
    /** @brief BC4 (ATI1) 压缩，单通道，4bpp */
    | BC4
    /** @brief BC4 有符号版本，单通道，4bpp（新版 bgfx 新增） */
    | BC4S
    /** @brief BC5 (ATI2) 压缩，双通道，8bpp */
    | BC5
    /** @brief BC5 有符号版本，双通道，8bpp（新版 bgfx 新增） */
    | BC5S
    /** @brief BC6H 压缩，HDR RGB，8bpp */
    | BC6H
    /** @brief BC6H 无符号浮点版本，HDR RGB，8bpp（新版 bgfx 新增） */
    | BC6HU
    /** @brief BC7 压缩，高质量 RGBA，8bpp */
    | BC7
    /** @brief ETC1 压缩，RGB，4bpp */
    | ETC1
    /** @brief ETC2 压缩，RGB，4bpp */
    | ETC2
    /** @brief ETC2A 压缩，RGBA，8bpp */
    | ETC2A
    /** @brief ETC2A1 压缩，RGBA（1 位 alpha），4bpp */
    | ETC2A1
    /** @brief ETC2 Alpha 压缩，单 11 位红通道，无符号归一化（新版 bgfx 新增） */
    | EACR11
    /** @brief EAC R11 有符号归一化版本（新版 bgfx 新增） */
    | EACR11S
    /** @brief EAC 双 11 位 RG 通道，无符号归一化（新版 bgfx 新增） */
    | EACRG11
    /** @brief EAC RG11 有符号归一化版本（新版 bgfx 新增） */
    | EACRG11S
    /** @brief PVRTC1 4bpp RGB */
    | PTC12
    /** @brief PVRTC1 4bpp RGBA */
    | PTC14
    /** @brief PVRTC1 2bpp RGB */
    | PTC12A
    /** @brief PVRTC1 2bpp RGBA */
    | PTC14A
    /** @brief PVRTC2 4bpp RGB */
    | PTC22
    /** @brief PVRTC2 4bpp RGBA */
    | PTC24
    /** @brief ATC RGB 压缩 */
    | ATC
    /** @brief ATCE RGBA 压缩（显式 alpha） */
    | ATCE
    /** @brief ATCI RGBA 压缩（插值 alpha） */
    | ATCI
    /** @brief ASTC 4x4 块，8bpp */
    | ASTC4X4
    /** @brief ASTC 5x4 块 */
    | ASTC5X4
    /** @brief ASTC 5x5 块 */
    | ASTC5X5
    /** @brief ASTC 6x5 块 */
    | ASTC6X5
    /** @brief ASTC 6x6 块 */
    | ASTC6X6
    /** @brief ASTC 8x5 块 */
    | ASTC8X5
    /** @brief ASTC 8x6 块 */
    | ASTC8X6
    /** @brief ASTC 8x8 块 */
    | ASTC8X8
    /** @brief ASTC 10x5 块 */
    | ASTC10X5
    /** @brief ASTC 10x6 块 */
    | ASTC10X6
    /** @brief ASTC 10x8 块 */
    | ASTC10X8
    /** @brief ASTC 10x10 块 */
    | ASTC10X10
    /** @brief ASTC 12x10 块 */
    | ASTC12X10
    /** @brief ASTC 12x12 块 */
    | ASTC12X12
    /** @brief 未知格式 */
    | Unknown
    // ---- 未压缩格式 ----
    /** @brief 1 位单色 */
    | R1
    /** @brief 8 位 alpha 通道 */
    | A8
    /** @brief 8 位红色通道（无符号归一化） */
    | R8
    /** @brief 8 位红色通道（有符号整数） */
    | R8I
    /** @brief 8 位红色通道（无符号整数） */
    | R8U
    /** @brief 8 位红色通道（有符号归一化） */
    | R8S
    /** @brief 16 位红色通道（无符号归一化） */
    | R16
    /** @brief 16 位红色通道（有符号整数） */
    | R16I
    /** @brief 16 位红色通道（无符号整数） */
    | R16U
    /** @brief 16 位红色通道（浮点） */
    | R16F
    /** @brief 16 位红色通道（有符号归一化） */
    | R16S
    /** @brief 32 位红色通道（有符号整数） */
    | R32I
    /** @brief 32 位红色通道（无符号整数） */
    | R32U
    /** @brief 32 位红色通道（浮点） */
    | R32F
    /** @brief 8+8 位 RG（无符号归一化） */
    | RG8
    /** @brief 8+8 位 RG（有符号整数） */
    | RG8I
    /** @brief 8+8 位 RG（无符号整数） */
    | RG8U
    /** @brief 8+8 位 RG（有符号归一化） */
    | RG8S
    /** @brief 16+16 位 RG（无符号归一化） */
    | RG16
    /** @brief 16+16 位 RG（有符号整数） */
    | RG16I
    /** @brief 16+16 位 RG（无符号整数） */
    | RG16U
    /** @brief 16+16 位 RG（浮点） */
    | RG16F
    /** @brief 16+16 位 RG（有符号归一化） */
    | RG16S
    /** @brief 32+32 位 RG（有符号整数） */
    | RG32I
    /** @brief 32+32 位 RG（无符号整数） */
    | RG32U
    /** @brief 32+32 位 RG（浮点） */
    | RG32F
    /** @brief 8+8+8 位 RGB（无符号归一化） */
    | RGB8
    /** @brief 8+8+8 位 RGB（有符号整数） */
    | RGB8I
    /** @brief 8+8+8 位 RGB（无符号整数） */
    | RGB8U
    /** @brief 8+8+8 位 RGB（有符号归一化） */
    | RGB8S
    /** @brief 9+9+9+5 位 RGB（共享指数浮点） */
    | RGB9E5F
    /** @brief 8+8+8+8 位 BGRA（无符号归一化） */
    | BGRA8
    /** @brief 8+8+8+8 位 RGBA（无符号归一化） */
    | RGBA8
    /** @brief 8+8+8+8 位 RGBA（有符号整数） */
    | RGBA8I
    /** @brief 8+8+8+8 位 RGBA（无符号整数） */
    | RGBA8U
    /** @brief 8+8+8+8 位 RGBA（有符号归一化） */
    | RGBA8S
    /** @brief 16+16+16+16 位 RGBA（无符号归一化） */
    | RGBA16
    /** @brief 16+16+16+16 位 RGBA（有符号整数） */
    | RGBA16I
    /** @brief 16+16+16+16 位 RGBA（无符号整数） */
    | RGBA16U
    /** @brief 16+16+16+16 位 RGBA（浮点） */
    | RGBA16F
    /** @brief 16+16+16+16 位 RGBA（有符号归一化） */
    | RGBA16S
    /** @brief 32+32+32+32 位 RGBA（有符号整数） */
    | RGBA32I
    /** @brief 32+32+32+32 位 RGBA（无符号整数） */
    | RGBA32U
    /** @brief 32+32+32+32 位 RGBA（浮点） */
    | RGBA32F
    /** @brief 5+6+5 位 BGR */
    | B5G6R5
    /** @brief 5+6+5 位 RGB */
    | R5G6B5
    /** @brief 4+4+4+4 位 BGRA */
    | BGRA4
    /** @brief 4+4+4+4 位 RGBA */
    | RGBA4
    /** @brief 5+5+5+1 位 BGR */
    | BGR5A1
    /** @brief 5+5+5+1 位 RGB */
    | RGB5A1
    /** @brief 10+10+10+2 位 RGB */
    | RGB10A2
    /** @brief 10+10+10+2 位 RGB 无符号整数（新版 bgfx 新增） */
    | RGB10A2U
    /** @brief 11+11+10 位 RG（浮点，无符号） */
    | RG11B10F
    // ---- 深度格式 ----
    /** @brief 未知深度格式 */
    | UnknownDepth
    /** @brief 16 位深度 */
    | D16
    /** @brief 24 位深度 */
    | D24
    /** @brief 24 位深度 + 8 位模板 */
    | D24S8
    /** @brief 32 位深度 */
    | D32
    /** @brief 16 位浮点深度 */
    | D16F
    /** @brief 24 位浮点深度 */
    | D24F
    /** @brief 32 位浮点深度 */
    | D32F
    /** @brief 32 位浮点深度 + 8 位模板（新版 bgfx 新增，64bpp） */
    | D32FS8
    /** @brief 8 位模板 */
    | D0S8
    /** @brief 枚举成员总数（新版 bgfx BGFX_TEXTURE_FORMAT_COUNT=105） */
    | Count

    /** @brief 将枚举值转换为 UInt32（数值对齐新版 bgfx c99 bgfx_texture_format_t） */
    public func value(): UInt32 {
        match (this) {
            case BC1 => 0
            case BC2 => 1
            case BC3 => 2
            case BC4 => 3
            case BC4S => 4
            case BC5 => 5
            case BC5S => 6
            case BC6H => 7
            case BC6HU => 8
            case BC7 => 9
            case ETC1 => 10
            case ETC2 => 11
            case ETC2A => 12
            case ETC2A1 => 13
            case EACR11 => 14
            case EACR11S => 15
            case EACRG11 => 16
            case EACRG11S => 17
            case PTC12 => 18
            case PTC14 => 19
            case PTC12A => 20
            case PTC14A => 21
            case PTC22 => 22
            case PTC24 => 23
            case ATC => 24
            case ATCE => 25
            case ATCI => 26
            case ASTC4X4 => 27
            case ASTC5X4 => 28
            case ASTC5X5 => 29
            case ASTC6X5 => 30
            case ASTC6X6 => 31
            case ASTC8X5 => 32
            case ASTC8X6 => 33
            case ASTC8X8 => 34
            case ASTC10X5 => 35
            case ASTC10X6 => 36
            case ASTC10X8 => 37
            case ASTC10X10 => 38
            case ASTC12X10 => 39
            case ASTC12X12 => 40
            case Unknown => 41
            case R1 => 42
            case A8 => 43
            case R8 => 44
            case R8I => 45
            case R8U => 46
            case R8S => 47
            case R16 => 48
            case R16I => 49
            case R16U => 50
            case R16F => 51
            case R16S => 52
            case R32I => 53
            case R32U => 54
            case R32F => 55
            case RG8 => 56
            case RG8I => 57
            case RG8U => 58
            case RG8S => 59
            case RG16 => 60
            case RG16I => 61
            case RG16U => 62
            case RG16F => 63
            case RG16S => 64
            case RG32I => 65
            case RG32U => 66
            case RG32F => 67
            case RGB8 => 68
            case RGB8I => 69
            case RGB8U => 70
            case RGB8S => 71
            case RGB9E5F => 72
            case BGRA8 => 73
            case RGBA8 => 74
            case RGBA8I => 75
            case RGBA8U => 76
            case RGBA8S => 77
            case RGBA16 => 78
            case RGBA16I => 79
            case RGBA16U => 80
            case RGBA16F => 81
            case RGBA16S => 82
            case RGBA32I => 83
            case RGBA32U => 84
            case RGBA32F => 85
            case B5G6R5 => 86
            case R5G6B5 => 87
            case BGRA4 => 88
            case RGBA4 => 89
            case BGR5A1 => 90
            case RGB5A1 => 91
            case RGB10A2 => 92
            case RGB10A2U => 93
            case RG11B10F => 94
            case UnknownDepth => 95
            case D16 => 96
            case D24 => 97
            case D24S8 => 98
            case D32 => 99
            case D16F => 100
            case D24F => 101
            case D32F => 102
            case D32FS8 => 103
            case D0S8 => 104
            case Count => 105
        }
    }

    /** @brief 从 UInt32 转换回枚举值（数值对齐新版 bgfx c99 bgfx_texture_format_t） */
    public static func fromValue(v: UInt32): TextureFormat {
        match (v) {
            case 0 => BC1
            case 1 => BC2
            case 2 => BC3
            case 3 => BC4
            case 4 => BC4S
            case 5 => BC5
            case 6 => BC5S
            case 7 => BC6H
            case 8 => BC6HU
            case 9 => BC7
            case 10 => ETC1
            case 11 => ETC2
            case 12 => ETC2A
            case 13 => ETC2A1
            case 14 => EACR11
            case 15 => EACR11S
            case 16 => EACRG11
            case 17 => EACRG11S
            case 18 => PTC12
            case 19 => PTC14
            case 20 => PTC12A
            case 21 => PTC14A
            case 22 => PTC22
            case 23 => PTC24
            case 24 => ATC
            case 25 => ATCE
            case 26 => ATCI
            case 27 => ASTC4X4
            case 28 => ASTC5X4
            case 29 => ASTC5X5
            case 30 => ASTC6X5
            case 31 => ASTC6X6
            case 32 => ASTC8X5
            case 33 => ASTC8X6
            case 34 => ASTC8X8
            case 35 => ASTC10X5
            case 36 => ASTC10X6
            case 37 => ASTC10X8
            case 38 => ASTC10X10
            case 39 => ASTC12X10
            case 40 => ASTC12X12
            case 41 => Unknown
            case 42 => R1
            case 43 => A8
            case 44 => R8
            case 45 => R8I
            case 46 => R8U
            case 47 => R8S
            case 48 => R16
            case 49 => R16I
            case 50 => R16U
            case 51 => R16F
            case 52 => R16S
            case 53 => R32I
            case 54 => R32U
            case 55 => R32F
            case 56 => RG8
            case 57 => RG8I
            case 58 => RG8U
            case 59 => RG8S
            case 60 => RG16
            case 61 => RG16I
            case 62 => RG16U
            case 63 => RG16F
            case 64 => RG16S
            case 65 => RG32I
            case 66 => RG32U
            case 67 => RG32F
            case 68 => RGB8
            case 69 => RGB8I
            case 70 => RGB8U
            case 71 => RGB8S
            case 72 => RGB9E5F
            case 73 => BGRA8
            case 74 => RGBA8
            case 75 => RGBA8I
            case 76 => RGBA8U
            case 77 => RGBA8S
            case 78 => RGBA16
            case 79 => RGBA16I
            case 80 => RGBA16U
            case 81 => RGBA16F
            case 82 => RGBA16S
            case 83 => RGBA32I
            case 84 => RGBA32U
            case 85 => RGBA32F
            case 86 => B5G6R5
            case 87 => R5G6B5
            case 88 => BGRA4
            case 89 => RGBA4
            case 90 => BGR5A1
            case 91 => RGB5A1
            case 92 => RGB10A2
            case 93 => RGB10A2U
            case 94 => RG11B10F
            case 95 => UnknownDepth
            case 96 => D16
            case 97 => D24
            case 98 => D24S8
            case 99 => D32
            case 100 => D16F
            case 101 => D24F
            case 102 => D32F
            case 103 => D32FS8
            case 104 => D0S8
            case _ => Count
        }
    }
}

/**
 * @brief 着色器 uniform 变量类型
 * @explain 定义着色器 uniform 变量的数据类型。
 */
public enum UniformType {
    /** @brief 纹理采样器 */
    | Sampler
    /** @brief uniform 列表结束标记 */
    | End
    /** @brief 4 分量浮点向量 */
    | Vec4
    /** @brief 3x3 浮点矩阵 */
    | Mat3
    /** @brief 4x4 浮点矩阵 */
    | Mat4
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Sampler => 0
            case End => 1
            case Vec4 => 2
            case Mat3 => 3
            case Mat4 => 4
            case Count => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): UniformType {
        match (v) {
            case 0 => Sampler
            case 1 => End
            case 2 => Vec4
            case 3 => Mat3
            case 4 => Mat4
            case _ => Count
        }
    }
}

/**
 * @brief 后缓冲比例枚举
 * @explain 用于创建与后缓冲成比例的帧缓冲。
 */
public enum BackbufferRatio {
    /** @brief 1:1 比例（与后缓冲相同大小） */
    | Equal
    /** @brief 1:2 比例（后缓冲的一半） */
    | Half
    /** @brief 1:4 比例 */
    | Quarter
    /** @brief 1:8 比例 */
    | Eighth
    /** @brief 1:16 比例 */
    | Sixteenth
    /** @brief 2:1 比例（后缓冲的两倍） */
    | Double
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Equal => 0
            case Half => 1
            case Quarter => 2
            case Eighth => 3
            case Sixteenth => 4
            case Double => 5
            case Count => 6
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): BackbufferRatio {
        match (v) {
            case 0 => Equal
            case 1 => Half
            case 2 => Quarter
            case 3 => Eighth
            case 4 => Sixteenth
            case 5 => Double
            case _ => Count
        }
    }
}

/**
 * @brief 遮挡查询结果
 * @explain 返回遮挡查询的测试结果。
 */
public enum OcclusionQueryResult {
    /** @brief 物体不可见（被完全遮挡） */
    | Invisible
    /** @brief 物体可见（至少有一个像素通过深度测试） */
    | Visible
    /** @brief 查询尚未完成，无结果 */
    | NoResult
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Invisible => 0
            case Visible => 1
            case NoResult => 2
            case Count => 3
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): OcclusionQueryResult {
        match (v) {
            case 0 => Invisible
            case 1 => Visible
            case 2 => NoResult
            case _ => Count
        }
    }
}

/**
 * @brief 图元拓扑类型
 * @explain 定义顶点数据的排列方式，决定如何将顶点组装成图元。
 */
public enum Topology {
    /** @brief 三角形列表（每 3 个顶点构成一个独立三角形） */
    | TriList
    /** @brief 三角形条带 */
    | TriStrip
    /** @brief 线段列表 */
    | LineList
    /** @brief 线段条带 */
    | LineStrip
    /** @brief 点列表 */
    | PointList
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case TriList => 0
            case TriStrip => 1
            case LineList => 2
            case LineStrip => 3
            case PointList => 4
            case Count => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Topology {
        match (v) {
            case 0 => TriList
            case 1 => TriStrip
            case 2 => LineList
            case 3 => LineStrip
            case 4 => PointList
            case _ => Count
        }
    }
}

/**
 * @brief 拓扑转换类型
 * @explain 用于在不同图元拓扑之间进行转换的算法类型。
 */
public enum TopologyConvert {
    /** @brief 三角形列表翻转绕序（CW↔CCW） */
    | TriListFlipWinding
    /** @brief 三角形条带翻转绕序 */
    | TriStripFlipWinding
    /** @brief 三角形列表转换为线段列表 */
    | TriListToLineList
    /** @brief 三角形条带转换为三角形列表 */
    | TriStripToTriList
    /** @brief 线段条带转换为线段列表 */
    | LineStripToLineList
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case TriListFlipWinding => 0
            case TriStripFlipWinding => 1
            case TriListToLineList => 2
            case TriStripToTriList => 3
            case LineStripToLineList => 4
            case Count => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): TopologyConvert {
        match (v) {
            case 0 => TriListFlipWinding
            case 1 => TriStripFlipWinding
            case 2 => TriListToLineList
            case 3 => TriStripToTriList
            case 4 => LineStripToLineList
            case _ => Count
        }
    }
}

/**
 * @brief 拓扑排序类型
 * @explain 用于透明物体排序的算法类型，组合了方向/距离和取极值/平均的策略。
 */
public enum TopologySort {
    /** @brief 按方向从前到后，取最小值 */
    | DirectionFrontToBackMin
    /** @brief 按方向从前到后，取平均值 */
    | DirectionFrontToBackAvg
    /** @brief 按方向从前到后，取最大值 */
    | DirectionFrontToBackMax
    /** @brief 按方向从后到前，取最小值 */
    | DirectionBackToFrontMin
    /** @brief 按方向从后到前，取平均值 */
    | DirectionBackToFrontAvg
    /** @brief 按方向从后到前，取最大值 */
    | DirectionBackToFrontMax
    /** @brief 按距离从前到后，取最小值 */
    | DistanceFrontToBackMin
    /** @brief 按距离从前到后，取平均值 */
    | DistanceFrontToBackAvg
    /** @brief 按距离从前到后，取最大值 */
    | DistanceFrontToBackMax
    /** @brief 按距离从后到前，取最小值 */
    | DistanceBackToFrontMin
    /** @brief 按距离从后到前，取平均值 */
    | DistanceBackToFrontAvg
    /** @brief 按距离从后到前，取最大值 */
    | DistanceBackToFrontMax
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case DirectionFrontToBackMin => 0
            case DirectionFrontToBackAvg => 1
            case DirectionFrontToBackMax => 2
            case DirectionBackToFrontMin => 3
            case DirectionBackToFrontAvg => 4
            case DirectionBackToFrontMax => 5
            case DistanceFrontToBackMin => 6
            case DistanceFrontToBackAvg => 7
            case DistanceFrontToBackMax => 8
            case DistanceBackToFrontMin => 9
            case DistanceBackToFrontAvg => 10
            case DistanceBackToFrontMax => 11
            case Count => 12
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): TopologySort {
        match (v) {
            case 0 => DirectionFrontToBackMin
            case 1 => DirectionFrontToBackAvg
            case 2 => DirectionFrontToBackMax
            case 3 => DirectionBackToFrontMin
            case 4 => DirectionBackToFrontAvg
            case 5 => DirectionBackToFrontMax
            case 6 => DistanceFrontToBackMin
            case 7 => DistanceFrontToBackAvg
            case 8 => DistanceFrontToBackMax
            case 9 => DistanceBackToFrontMin
            case 10 => DistanceBackToFrontAvg
            case 11 => DistanceBackToFrontMax
            case _ => Count
        }
    }
}

/**
 * @brief 视图渲染模式
 * @explain 控制视图的渲染顺序和剔除行为。
 */
public enum ViewMode {
    /** @brief 默认模式（顺序渲染，无特殊排序） */
    | Default
    /** @brief 顺序模式（按提交顺序渲染） */
    | Sequential
    /** @brief 按深度升序排序（从近到远） */
    | DepthAscending
    /** @brief 按深度降序排序（从远到近，用于透明物体） */
    | DepthDescending
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Default => 0
            case Sequential => 1
            case DepthAscending => 2
            case DepthDescending => 3
            case Count => 4
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): ViewMode {
        match (v) {
            case 0 => Default
            case 1 => Sequential
            case 2 => DepthAscending
            case 3 => DepthDescending
            case _ => Count
        }
    }
}

/**
 * @brief 原生窗口句柄类型
 * @explain 指定平台数据中 nwh 字段的窗口系统类型。
 */
public enum NativeWindowHandleType {
    /** @brief 默认窗口句柄类型 */
    | Default
    /** @brief Wayland 窗口句柄 */
    | Wayland
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Default => 0
            case Wayland => 1
            case Count => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): NativeWindowHandleType {
        match (v) {
            case 0 => Default
            case 1 => Wayland
            case _ => Count
        }
    }
}

/**
 * @brief bgfx_render_frame 返回值
 * @explain 指示 bgfx_render_frame 的当前状态。
 */
public enum RenderFrame {
    /** @brief 无渲染上下文可用 */
    | NoContext
    /** @brief 继续渲染 */
    | Render
    /** @brief 超时 */
    | Timeout
    /** @brief 正在退出 */
    | Exiting
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case NoContext => 0
            case Render => 1
            case Timeout => 2
            case Exiting => 3
            case Count => 4
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): RenderFrame {
        match (v) {
            case 0 => NoContext
            case 1 => Render
            case 2 => Timeout
            case 3 => Exiting
            case _ => Count
        }
    }
}

/**
 * @brief Uniform 更新频率
 * @explain 用于 `bgfx_create_uniform_with_freq`，声明 uniform 每帧更新范围以优化存储。
 * @note 对齐新版 c99 bgfx_uniform_freq_t。
 */
public enum UniformFreq {
    /** @brief 每帧每个 Draw Call 更新 */
    | PerDraw
    /** @brief 每帧每个视图更新一次 */
    | PerView
    /** @brief 整帧共享，更新一次 */
    | PerFrame
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case PerDraw => 0
            case PerView => 1
            case PerFrame => 2
            case Count => 3
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): UniformFreq {
        match (v) {
            case 0 => PerDraw
            case 1 => PerView
            case 2 => PerFrame
            case _ => Count
        }
    }
}

/**
 * @brief 视频编解码器类型
 * @explain 硬件视频解码使用的编码格式，配合 Caps.codecs 能力表使用。
 * @note 对齐新版 c99 bgfx_video_codec_t。
 */
public enum VideoCodec {
    /** @brief H.264 / AVC */
    | H264
    /** @brief H.265 / HEVC */
    | H265
    /** @brief AV1 */
    | Av1
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case H264 => 0
            case H265 => 1
            case Av1 => 2
            case Count => 3
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): VideoCodec {
        match (v) {
            case 0 => H264
            case 1 => H265
            case 2 => Av1
            case _ => Count
        }
    }
}

/**
 * @brief 可变速率着色率
 * @explain 用于 `bgfx_set_view_shading_rate`，按块降低像素着色率。
 * @note 对齐新版 c99 bgfx_shading_rate_t。
 */
public enum ShadingRate {
    /** @brief 1x1（完整着色率） */
    | Rate1x1
    /** @brief 1x2 */
    | Rate1x2
    /** @brief 2x1 */
    | Rate2x1
    /** @brief 2x2 */
    | Rate2x2
    /** @brief 2x4 */
    | Rate2x4
    /** @brief 4x2 */
    | Rate4x2
    /** @brief 4x4 */
    | Rate4x4
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Rate1x1 => 0
            case Rate1x2 => 1
            case Rate2x1 => 2
            case Rate2x2 => 3
            case Rate2x4 => 4
            case Rate4x2 => 5
            case Rate4x4 => 6
            case Count => 7
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): ShadingRate {
        match (v) {
            case 0 => Rate1x1
            case 1 => Rate1x2
            case 2 => Rate2x1
            case 3 => Rate2x2
            case 4 => Rate2x4
            case 5 => Rate4x2
            case 6 => Rate4x4
            case _ => Count
        }
    }
}

/**
 * @brief 内部缓冲句柄类型
 * @explain `BufferHandle.type` 字段的取值，标识内部缓冲对应的原始句柄类别。
 * @note 对齐新版 c99 bgfx_buffer_handle_type_t。
 */
public enum BufferHandleType {
    /** @brief 动态索引缓冲 */
    | DynamicIndexBuffer
    /** @brief 动态顶点缓冲 */
    | DynamicVertexBuffer
    /** @brief 静态索引缓冲 */
    | IndexBuffer
    /** @brief 间接绘制缓冲 */
    | IndirectBuffer
    /** @brief 静态顶点缓冲 */
    | VertexBuffer
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case DynamicIndexBuffer => 0
            case DynamicVertexBuffer => 1
            case IndexBuffer => 2
            case IndirectBuffer => 3
            case VertexBuffer => 4
            case Count => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): BufferHandleType {
        match (v) {
            case 0 => DynamicIndexBuffer
            case 1 => DynamicVertexBuffer
            case 2 => IndexBuffer
            case 3 => IndirectBuffer
            case 4 => VertexBuffer
            case _ => Count
        }
    }
}

// =============================================================================
// View ID alias
// =============================================================================

/**
 * @brief 视图 ID 类型别名
 * @explain bgfx 视图标识符，范围为 [0, 255]。
 */
public type ViewId = UInt16

// =============================================================================
// Handle types (each is a struct with a single uint16 idx field)
// =============================================================================

/**
 * @brief 动态索引缓冲句柄
 * @explain 表示一个可动态更新的索引缓冲，idx=0xFFFF 表示无效句柄。
 */
@C
public struct DynamicIndexBufferHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 动态顶点缓冲句柄
 * @explain 表示一个可动态更新的顶点缓冲，idx=0xFFFF 表示无效句柄。
 */
@C
public struct DynamicVertexBufferHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 帧缓冲句柄
 * @explain 表示一个帧缓冲对象，idx=0xFFFF 表示无效句柄。
 */
@C
public struct FrameBufferHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 通用缓冲句柄
 * @explain 新版 bgfx 统一 GPU buffer（compute/blit 用），idx=0xFFFF 无效，
 * type 为 BufferType 的 UInt16 表示。
 */
@C
public struct BufferHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    /** @brief 缓冲类型（BufferType 的 UInt16 表示） */
    public var `type`: UInt16 = 0
    public init() {}
    public init(idx: UInt16, `type`: UInt16) {
        this.idx = idx
        this.`type` = `type`
    }
}

/**
 * @brief 索引缓冲句柄
 * @explain 表示一个静态索引缓冲，idx=0xFFFF 表示无效句柄。
 */
@C
public struct IndexBufferHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 间接绘制缓冲句柄
 * @explain 用于间接绘制命令的缓冲，idx=0xFFFF 表示无效句柄。
 */
@C
public struct IndirectBufferHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 遮挡查询句柄
 * @explain 用于遮挡剔除查询，idx=0xFFFF 表示无效句柄。
 */
@C
public struct OcclusionQueryHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 着色器程序句柄
 * @explain 表示一个顶点+片段着色器组合的程序，idx=0xFFFF 表示无效句柄。
 */
@C
public struct ProgramHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 着色器句柄
 * @explain 表示一个编译后的着色器对象（顶点或片段），idx=0xFFFF 表示无效句柄。
 */
@C
public struct ShaderHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 纹理句柄
 * @explain 表示一个纹理对象，idx=0xFFFF 表示无效句柄。
 */
@C
public struct TextureHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief Uniform 变量句柄
 * @explain 表示一个着色器 uniform 变量，idx=0xFFFF 表示无效句柄。
 */
@C
public struct UniformHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 顶点缓冲句柄
 * @explain 表示一个静态顶点缓冲，idx=0xFFFF 表示无效句柄。
 */
@C
public struct VertexBufferHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

/**
 * @brief 顶点布局句柄
 * @explain 表示一个顶点布局对象，idx=0xFFFF 表示无效句柄。
 */
@C
public struct VertexLayoutHandle {
    /** @brief 句柄索引，0xFFFF 表示无效 */
    public var idx: UInt16 = 0xFFFFu16
    public init() {}
    public init(idx: UInt16) {
        this.idx = idx
    }
}

// =============================================================================
// Function pointer type for memory release callback
// =============================================================================

/**
 * @brief 内存释放回调函数类型
 * @explain 用于 `bgfx_make_ref_release` 的自定义内存释放回调。
 * @param CPointer<Unit> 用户数据指针
 * @param CPointer<Unit> 待释放的内存指针
 */
public type ReleaseFn = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Unit>

// =============================================================================
// Structs (enum fields use UInt32 for C ABI compatibility)
// =============================================================================

/**
 * @brief GPU 信息
 * @explain 描述单个 GPU 的厂商和型号 ID。
 */
@C
public struct CapsGpu {
    /** @brief PCI 厂商 ID（如 0x10DE=NVIDIA, 0x1002=AMD） */
    public var vendorId: UInt16 = 0
    /** @brief PCI 设备 ID */
    public var deviceId: UInt16 = 0
    public init() {}
}

/**
 * @brief 渲染器运行时限制
 * @explain 描述当前渲染器支持的各种资源上限。
 */
@C
public struct CapsLimits {
    /** @brief 最大绘制调用次数 */
    public var maxDrawCalls: UInt32 = 0
    /** @brief 最大 Blit 操作次数 */
    public var maxBlits: UInt32 = 0
    /** @brief 最大纹理尺寸 */
    public var maxTextureSize: UInt32 = 0
    /** @brief 最大纹理层数 */
    public var maxTextureLayers: UInt32 = 0
    /** @brief 最大视图数量 */
    public var maxViews: UInt32 = 0
    /** @brief 最大帧缓冲数量 */
    public var maxFrameBuffers: UInt32 = 0
    /** @brief 最大帧缓冲附加纹理数量 */
    public var maxFBAttachments: UInt32 = 0
    /** @brief 最大着色器程序数量 */
    public var maxPrograms: UInt32 = 0
    /** @brief 最大着色器数量 */
    public var maxShaders: UInt32 = 0
    /** @brief 最大纹理数量 */
    public var maxTextures: UInt32 = 0
    /** @brief 最大纹理采样器数量 */
    public var maxTextureSamplers: UInt32 = 0
    /** @brief 最大计算绑定数量 */
    public var maxComputeBindings: UInt32 = 0
    /** @brief 最大顶点布局数量 */
    public var maxVertexLayouts: UInt32 = 0
    /** @brief 最大顶点流数量 */
    public var maxVertexStreams: UInt32 = 0
    /** @brief 最大顶点属性数量 */
    public var maxVertexAttributes: UInt32 = 0
    /** @brief 最大实例化数据数量 */
    public var maxInstanceData: UInt32 = 0
    /** @brief 最大索引缓冲数量 */
    public var maxIndexBuffers: UInt32 = 0
    /** @brief 最大顶点缓冲数量 */
    public var maxVertexBuffers: UInt32 = 0
    /** @brief 最大动态索引缓冲数量 */
    public var maxDynamicIndexBuffers: UInt32 = 0
    /** @brief 最大动态顶点缓冲数量 */
    public var maxDynamicVertexBuffers: UInt32 = 0
    /** @brief 最大 Uniform 变量数量 */
    public var maxUniforms: UInt32 = 0
    /** @brief 最大遮挡查询数量 */
    public var maxOcclusionQueries: UInt32 = 0
    /** @brief 最大编码器数量 */
    public var maxEncoders: UInt32 = 0
    /** @brief 最小资源回调缓冲大小 */
    public var minResourceCbSize: UInt32 = 0
    /** @brief 瞬态顶点缓冲大小 */
    public var maxTransientVbSize: UInt32 = 0
    /** @brief 瞬态索引缓冲大小 */
    public var maxTransientIbSize: UInt32 = 0
    /** @brief 最小 uniform 缓冲大小 */
    public var minUniformBufferSize: UInt32 = 0
    /** @brief Blit 行间距对齐要求（字节） */
    public var blitRowPitchAlign: UInt32 = 0
    /** @brief Blit 偏移对齐要求（字节） */
    public var blitOffsetAlign: UInt32 = 0
    public init() {}
}

/**
 * @brief 渲染器能力信息
 * @explain 描述当前渲染器支持的特性和功能。
 * @note 枚举类型字段使用 UInt32 存储，需通过 `RendererType.fromValue()` 等函数转换。
 */
@C
public struct Caps {
    /** @brief 渲染器类型（RendererType 的 UInt32 表示） */
    public var rendererType: UInt32 = 0
    /** @brief 支持的能力标志位（CAPS_* 组合） */
    public var supported: UInt64 = 0
    /** @brief GPU 厂商 ID */
    public var vendorId: UInt16 = 0
    /** @brief GPU 设备 ID */
    public var deviceId: UInt16 = 0
    /** @brief 是否使用齐次深度（[0,1] 范围） */
    public var homogeneousDepth: Bool = false
    /** @brief 原点是否在左下角 */
    public var originBottomLeft: Bool = false
    /** @brief GPU 数量 */
    public var numGPUs: UInt8 = 0
    /** @brief GPU 信息数组（最多 4 个） */
    public var gpu = VArray<CapsGpu, $4>(repeat: CapsGpu())
    /** @brief 运行时限制 */
    public var limits: CapsLimits = CapsLimits()
    /** @brief 纹理格式支持表（BGFX_TEXTURE_FORMAT_COUNT=105 项，每项 CAPS_FORMAT_* 标志） */
    public var formats = VArray<UInt32, $105>(repeat: 0)
    /** @brief 视频编解码能力表（BGFX_VIDEO_CODEC_COUNT=4 项，每项 CAPS_VIDEO_CODEC_* 标志） */
    public var codecs = VArray<UInt32, $4>(repeat: 0)
    public init() {}
}

/**
 * @brief bgfx 内部数据
 * @explain 通过 `bgfx_get_internal_data` 获取的内部数据指针，包含能力信息和上下文。
 */
@C
public struct InternalData {
    /** @brief 指向 Caps 结构体的指针 */
    public var caps: CPointer<Caps> = CPointer<Caps>()
    /** @brief 内部渲染上下文指针 */
    public var context: CPointer<Unit> = CPointer<Unit>()
    public init() {}
}

/**
 * @brief 平台数据
 * @explain 新版 bgfx 平台数据并入 bgfx_init_t：context/queue 为 NULL 时
 * bgfx 自行创建上下文/设备；nwh/ndt 已移至 SwapChain。
 */
@C
public struct PlatformData {
    /** @brief GL context / D3D device / Vulkan device，NULL 由 bgfx 创建 */
    public var context: CPointer<Unit> = CPointer<Unit>()
    /** @brief D3D12 Queue，NULL 由 bgfx 创建 */
    public var queue: CPointer<Unit> = CPointer<Unit>()
    /** @brief 原生窗口句柄类型（NativeWindowHandleType 的 UInt32 表示） */
    public var `type`: UInt32 = 0
    public init() {}
}

/**
 * @brief 交换链描述
 * @explain 新版 bgfx 用 SwapChain 取代旧 Resolution：主窗口在 init 时传入
 * Init.swapChain，额外窗口用 bgfx_create_frame_buffer_from_swap_chain 创建。
 */
@C
public struct SwapChain {
    /** @brief 原生窗口句柄（NULL = headless） */
    public var nwh: CPointer<Unit> = CPointer<Unit>()
    /** @brief 原生显示类型（*nix，NULL 沿用主窗口） */
    public var ndt: CPointer<Unit> = CPointer<Unit>()
    /** @brief 交换链宽度 */
    public var width: UInt32 = 0
    /** @brief 交换链高度 */
    public var height: UInt32 = 0
    /** @brief 交换链标志（SWAP_CHAIN_* 组合） */
    public var flags: UInt32 = 0
    /** @brief 颜色格式（TextureFormat 的 UInt32 表示，0/Count 表示平台默认） */
    public var formatColor: UInt32 = 0
    /** @brief 深度模板格式（TextureFormat 的 UInt32 表示，Count 表示无深度） */
    public var formatDepthStencil: UInt32 = 0
    /** @brief 外部深度纹理句柄（无效时由 bgfx 创建并持有） */
    public var depth: TextureHandle = TextureHandle()
    /** @brief 后缓冲数量 */
    public var numBackBuffers: UInt8 = 0
    /** @brief 最大帧延迟 */
    public var maxFrameLatency: UInt8 = 0
    public init() {}
}

/**
 * @brief 可配置的运行时限制参数
 * @explain 用于 Init 结构中自定义运行时限制。
 */
@C
public struct InitLimits {
    /** @brief 最大编码器数量 */
    public var maxEncoders: UInt16 = 0
    /** @brief 预留给每帧的绘制调用存储数量 */
    public var numDrawCalls: UInt32 = 0
    /** @brief 绘制调用峰值观测帧数 */
    public var numDrawCallPeakFrames: UInt32 = 0
    /** @brief 最小资源回调缓冲大小 */
    public var minResourceCbSize: UInt32 = 0
    /** @brief 瞬态顶点缓冲大小 */
    public var maxTransientVbSize: UInt32 = 0
    /** @brief 瞬态索引缓冲大小 */
    public var maxTransientIbSize: UInt32 = 0
    /** @brief 最小 uniform 缓冲大小 */
    public var minUniformBufferSize: UInt32 = 0
    public init() {}
}

/**
 * @brief 分配器接口（不透明）
 * @explain 用于自定义内存分配的回调接口。
 */
@C
public struct AllocatorInterface {
    /** @brief 虚函数表指针 */
    public var vtbl: CPointer<Unit> = CPointer<Unit>()
    public init() {}
}

/**
 * @brief 回调接口（不透明）
 * @explain 用于接收 bgfx 运行时回调（如错误信息、性能数据等）。
 */
@C
public struct CallbackInterface {
    /** @brief 虚函数表指针 */
    public var vtbl: CPointer<Unit> = CPointer<Unit>()
    public init() {}
}

/**
 * @brief bgfx 初始化参数
 * @explain 传递给 `bgfx_init` 的初始化参数结构体。
 * @note `type` 字段为 RendererType 的 UInt32 表示。
 */
@C
public struct Init {
    /** @brief 渲染器类型（RendererType 的 UInt32 表示，Count=0 自动选择） */
    public var `type`: UInt32 = 0
    /** @brief PCI 厂商 ID（0=任意） */
    public var vendorId: UInt16 = 0
    /** @brief PCI 设备 ID（0=任意） */
    public var deviceId: UInt16 = 0
    /** @brief 请求的能力标志位（默认 UINT64_MAX，0 经 init_ctor 后需自行置全） */
    public var capabilities: UInt64 = 0
    /** @brief 是否启用调试模式 */
    public var debug: Bool = false
    /** @brief 是否启用性能分析 */
    public var profile: Bool = false
    /** @brief 是否允许回退到下一个可用渲染器 */
    public var fallback: Bool = true
    /** @brief 是否启用视频解码 */
    public var videoDecode: Bool = false
    /** @brief 平台数据（context/queue/type） */
    public var platformData: PlatformData = PlatformData()
    /** @brief 主窗口交换链（nwh/尺寸/格式/后缓冲等） */
    public var swapChain: SwapChain = SwapChain()
    /** @brief 设备与帧全局重置标志（RESET_* 组合） */
    public var reset: UInt32 = 0
    /** @brief 运行时限制 */
    public var limits: InitLimits = InitLimits()
    /** @brief 回调接口指针 */
    public var callback: CPointer<CallbackInterface> = CPointer<CallbackInterface>()
    /** @brief 分配器接口指针 */
    public var allocator: CPointer<AllocatorInterface> = CPointer<AllocatorInterface>()
    public init() {}
}

/**
 * @brief bgfx 内存块
 * @explain 通过 `bgfx_alloc`、`bgfx_copy` 或 `bgfx_make_ref` 获取的内存块。
 */
@C
public struct Memory {
    /** @brief 数据指针 */
    public var data: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 数据大小（字节） */
    public var size: UInt32 = 0
    public init() {}
}

/**
 * @brief 瞬态索引缓冲
 * @explain 用于临时分配的索引缓冲，每帧可重复使用。
 */
@C
public struct TransientIndexBuffer {
    /** @brief 数据指针 */
    public var data: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 数据大小（字节） */
    public var size: UInt32 = 0
    /** @brief 起始索引偏移 */
    public var startIndex: UInt32 = 0
    /** @brief 内部使用的索引缓冲句柄 */
    public var handle: IndexBufferHandle = IndexBufferHandle()
    /** @brief 是否使用 16 位索引（false=32 位） */
    public var isIndex16: Bool = false
    public init() {}
}

/**
 * @brief 瞬态顶点缓冲
 * @explain 用于临时分配的顶点缓冲，每帧可重复使用。
 */
@C
public struct TransientVertexBuffer {
    /** @brief 数据指针 */
    public var data: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 数据大小（字节） */
    public var size: UInt32 = 0
    /** @brief 起始顶点偏移 */
    public var startVertex: UInt32 = 0
    /** @brief 顶点步长（字节） */
    public var stride: UInt16 = 0
    /** @brief 内部使用的顶点缓冲句柄 */
    public var handle: VertexBufferHandle = VertexBufferHandle()
    /** @brief 顶点布局句柄 */
    public var layoutHandle: VertexLayoutHandle = VertexLayoutHandle()
    public init() {}
}

/**
 * @brief 实例数据缓冲
 * @explain 用于实例化渲染的每实例数据。
 */
@C
public struct InstanceDataBuffer {
    /** @brief 数据指针 */
    public var data: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 数据大小（字节） */
    public var size: UInt32 = 0
    /** @brief 数据偏移 */
    public var offset: UInt32 = 0
    /** @brief 实例数量 */
    public var num: UInt32 = 0
    /** @brief 每实例数据步长（字节） */
    public var stride: UInt16 = 0
    /** @brief 内部使用的顶点缓冲句柄 */
    public var handle: VertexBufferHandle = VertexBufferHandle()
    public init() {}
}

/**
 * @brief 纹理信息
 * @explain 描述纹理的尺寸、格式等属性。
 */
@C
public struct TextureInfo {
    /** @brief 纹理格式（TextureFormat 的 UInt32 表示） */
    public var format: UInt32 = 0
    /** @brief 存储大小（字节） */
    public var storageSize: UInt32 = 0
    /** @brief 宽度（像素） */
    public var width: UInt16 = 0
    /** @brief 高度（像素） */
    public var height: UInt16 = 0
    /** @brief 深度（像素） */
    public var depth: UInt16 = 0
    /** @brief 层数 */
    public var numLayers: UInt16 = 0
    /** @brief Mip 等级数量 */
    public var numMips: UInt8 = 0
    /** @brief 每像素位数 */
    public var bitsPerPixel: UInt8 = 0
    /** @brief 是否为立方体贴图 */
    public var cubeMap: Bool = false
    public init() {}
}

/**
 * @brief Uniform 变量信息
 * @explain 描述着色器 uniform 变量的名称、类型和数量。
 */
@C
public struct UniformInfo {
    /** @brief uniform 名称（256 字节固定数组） */
    public var name = VArray<UInt8, $256>(repeat: 0)
    /** @brief uniform 类型（UniformType 的 UInt32 表示） */
    public var `type`: UInt32 = 0
    /** @brief uniform 数量（数组大小） */
    public var num: UInt16 = 0
    public init() {}
}

/**
 * @brief 帧缓冲纹理附加信息
 * @explain 描述帧缓冲附加纹理的访问权限、mip 等级和层信息。
 */
@C
public struct Attachment {
    /** @brief 访问权限（Access 的 UInt32 表示） */
    public var access: UInt32 = 0
    /** @brief 纹理句柄 */
    public var handle: TextureHandle = TextureHandle()
    /** @brief Mip 等级 */
    public var mip: UInt16 = 0
    /** @brief 图层索引 */
    public var layer: UInt16 = 0
    /** @brief 图层数量 */
    public var numLayers: UInt16 = 0
    /** @brief 附加标志（ATTACHMENT_*：AUTO_GEN_MIPS/READ_ONLY_DEPTH/SRGB 等） */
    public var flags: UInt8 = 0
    public init() {}
}

/**
 * @brief 纹理区域
 * @explain 新版 bgfx blit/read 模型：以 region 描述符取代旧 blit 的长参数表。
 * width/height/depth 为 0 表示从 x/y/z 起延伸到该 mip 的剩余部分。
 */
@C
public struct TextureRegion {
    /** @brief 纹理句柄 */
    public var handle: TextureHandle = TextureHandle()
    /** @brief Mip 等级 */
    public var mip: UInt8 = 0
    /** @brief 区域 X 偏移 */
    public var x: UInt16 = 0
    /** @brief 区域 Y 偏移 */
    public var y: UInt16 = 0
    /** @brief cube 面 / 数组层 / 3D 纹理 Z 偏移（2D 纹理为 0） */
    public var z: UInt16 = 0
    /** @brief 区域宽度（0 = 取 mip 剩余） */
    public var width: UInt16 = 0
    /** @brief 区域高度（0 = 取 mip 剩余） */
    public var height: UInt16 = 0
    /** @brief 3D 深度 / 层数（0 = 取剩余） */
    public var depth: UInt16 = 0
    public init() {}
}

/**
 * @brief 缓冲区域
 * @explain blit 在 buffer↔buffer / texture↔buffer 间传输，或 bgfx_read 读取
 * buffer 时使用。rowPitch/slicePitch 为 0 表示紧凑布局。
 */
@C
public struct BufferRegion {
    /** @brief 缓冲句柄 */
    public var handle: BufferHandle = BufferHandle()
    /** @brief 缓冲内字节偏移 */
    public var offset: UInt32 = 0
    /** @brief 字节数（两端均为 buffer 或 read 时使用，0 = 取剩余） */
    public var size: UInt32 = 0
    /** @brief 相邻两行块的字节间距（0 = 紧凑） */
    public var rowPitch: UInt32 = 0
    /** @brief 相邻两个 slice/层/面的字节间距（0 = 紧凑） */
    public var slicePitch: UInt32 = 0
    public init() {}
}

/**
 * @brief 变换数据
 * @explain 用于 `bgfx_alloc_transform` 获取的变换矩阵数据。
 */
@C
public struct Transform {
    /** @brief 矩阵数据指针（16 个 float 构成一个 4x4 矩阵） */
    public var data: CPointer<Float32> = CPointer<Float32>()
    /** @brief 矩阵数量 */
    public var num: UInt16 = 0
    public init() {}
}

/**
 * @brief 视图统计信息
 * @explain 单个视图的 CPU/GPU 时间统计。
 */
@C
public struct ViewStats {
    /** @brief 视图名称（256 字节固定数组） */
    public var name = VArray<UInt8, $256>(repeat: 0)
    /** @brief 视图 ID */
    public var view: ViewId = 0
    /** @brief CPU 时间开始（时钟周期） */
    public var cpuTimeBegin: Int64 = 0
    /** @brief CPU 时间结束（时钟周期） */
    public var cpuTimeEnd: Int64 = 0
    /** @brief GPU 时间开始（时钟周期） */
    public var gpuTimeBegin: Int64 = 0
    /** @brief GPU 时间结束（时钟周期） */
    public var gpuTimeEnd: Int64 = 0
    /** @brief GPU 帧号 */
    public var gpuFrameNum: UInt32 = 0
    public init() {}
}

/**
 * @brief 编码器统计信息
 * @explain 单个编码器的 CPU 时间统计。
 */
@C
public struct EncoderStats {
    /** @brief CPU 时间开始（时钟周期） */
    public var cpuTimeBegin: Int64 = 0
    /** @brief CPU 时间结束（时钟周期） */
    public var cpuTimeEnd: Int64 = 0
    public init() {}
}

/**
 * @brief 渲染器统计信息
 * @explain 全面的渲染器运行时统计信息，包括 CPU/GPU 时间、资源计数等。
 */
@C
public struct Stats {
    /** @brief 帧 CPU 总耗时 */
    public var cpuTimeFrame: Int64 = 0
    /** @brief CPU 时间开始 */
    public var cpuTimeBegin: Int64 = 0
    /** @brief CPU 时间结束 */
    public var cpuTimeEnd: Int64 = 0
    /** @brief CPU 计时器频率 */
    public var cpuTimerFreq: Int64 = 0
    /** @brief GPU 时间开始 */
    public var gpuTimeBegin: Int64 = 0
    /** @brief GPU 时间结束 */
    public var gpuTimeEnd: Int64 = 0
    /** @brief GPU 计时器频率 */
    public var gpuTimerFreq: Int64 = 0
    /** @brief 等待渲染的时间 */
    public var waitRender: Int64 = 0
    /** @brief 等待提交的时间 */
    public var waitSubmit: Int64 = 0
    /** @brief 绘制调用次数 */
    public var numDraw: UInt32 = 0
    /** @brief 计算调度次数 */
    public var numCompute: UInt32 = 0
    /** @brief Blit 操作次数 */
    public var numBlit: UInt32 = 0
    /** @brief Blit 重排次数（后端无法原生拷贝时的额外 pass） */
    public var numBlitRepack: UInt32 = 0
    /** @brief 绘制调用峰值 */
    public var numDrawCallsPeak: UInt32 = 0
    /** @brief 最大 GPU 延迟 */
    public var maxGpuLatency: UInt32 = 0
    /** @brief GPU 帧号 */
    public var gpuFrameNum: UInt32 = 0
    /** @brief 动态索引缓冲数量 */
    public var numDynamicIndexBuffers: UInt16 = 0
    /** @brief 动态顶点缓冲数量 */
    public var numDynamicVertexBuffers: UInt16 = 0
    /** @brief 帧缓冲数量 */
    public var numFrameBuffers: UInt16 = 0
    /** @brief 索引缓冲数量 */
    public var numIndexBuffers: UInt16 = 0
    /** @brief 遮挡查询数量 */
    public var numOcclusionQueries: UInt16 = 0
    /** @brief 着色器程序数量 */
    public var numPrograms: UInt16 = 0
    /** @brief 着色器数量 */
    public var numShaders: UInt16 = 0
    /** @brief 纹理数量 */
    public var numTextures: UInt16 = 0
    /** @brief Uniform 变量数量 */
    public var numUniforms: UInt16 = 0
    /** @brief 顶点缓冲数量 */
    public var numVertexBuffers: UInt16 = 0
    /** @brief 顶点布局数量 */
    public var numVertexLayouts: UInt16 = 0
    /** @brief 纹理内存使用量 */
    public var textureMemoryUsed: Int64 = 0
    /** @brief 渲染目标内存使用量 */
    public var rtMemoryUsed: Int64 = 0
    /** @brief 瞬态顶点缓冲使用量 */
    public var transientVbUsed: Int32 = 0
    /** @brief 瞬态索引缓冲使用量 */
    public var transientIbUsed: Int32 = 0
    /** @brief 每类图元的绘制数量（最多 5 种） */
    public var numPrims = VArray<UInt32, $5>(repeat: 0)
    /** @brief GPU 最大内存 */
    public var gpuMemoryMax: Int64 = 0
    /** @brief GPU 已用内存 */
    public var gpuMemoryUsed: Int64 = 0
    /** @brief 后缓冲宽度 */
    public var width: UInt16 = 0
    /** @brief 后缓冲高度 */
    public var height: UInt16 = 0
    /** @brief 调试文本宽度（字符数） */
    public var textWidth: UInt16 = 0
    /** @brief 调试文本高度（字符数） */
    public var textHeight: UInt16 = 0
    /** @brief 视图数量 */
    public var numViews: UInt16 = 0
    /** @brief 视图统计信息数组指针 */
    public var viewStats: CPointer<ViewStats> = CPointer<ViewStats>()
    /** @brief 编码器数量 */
    public var numEncoders: UInt8 = 0
    /** @brief 编码器统计信息数组指针 */
    public var encoderStats: CPointer<EncoderStats> = CPointer<EncoderStats>()
    public init() {}
}

/**
 * @brief 顶点布局
 * @explain 描述顶点缓冲中每个属性的偏移、类型和格式。
 * @note 使用 `bgfx_vertex_layout_begin/add/end` 系列函数构建。
 */
@C
public struct VertexLayout {
    /** @brief 布局哈希值 */
    public var hash: UInt32 = 0
    /** @brief 顶点步长（字节） */
    public var stride: UInt16 = 0
    /** @brief 每个属性的偏移量（新版 bgfx BGFX_ATTRIB_COUNT=26） */
    public var offset = VArray<UInt16, $26>(repeat: 0)
    /** @brief 每个属性的编码信息（新版 bgfx BGFX_ATTRIB_COUNT=26） */
    public var attributes = VArray<UInt16, $26>(repeat: 0)
    public init() {}
}

/**
 * @brief 编码器（不透明类型）
 * @explain 用于多线程编码的渲染编码器，通过 `bgfx_encoder_begin` 获取。
 */
@C
public struct Encoder {
    public init() {}
}

/**
 * @brief 视频解码器初始化参数
 * @explain 硬件视频解码器的创建参数，配合 VIDEO_DECODER_INIT_* 标志使用。
 * @note 对齐新版 c99 bgfx_video_decoder_init_t。
 */
@C
public struct VideoDecoderInit {
    /** @brief 结构体魔数，必须为 BX_MAKEFOURCC('V','D','I',0x0) */
    public var magic: UInt32 = 0
    /** @brief 视频编解码器（VideoCodec 的 UInt32 表示） */
    public var codec: UInt32 = 0
    /** @brief 编码参数集（H.264/H.265 为 Annex B，AV1 为 OBU） */
    public var parameterSets: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 参数集大小（字节） */
    public var parameterSetsSize: UInt32 = 0
    /** @brief 流式访问单元 FIFO 字节软上限（0 = 默认；RETAIN 模式下忽略） */
    public var cachedAuBytes: UInt32 = 0
    /** @brief 解码器生命周期标志（VIDEO_DECODER_INIT_*） */
    public var flags: UInt8 = 0
    public init() {}
}

/**
 * @brief 视频访问单元描述
 * @explain 描述单个访问单元（AU）的大小与显示时间戳。
 * @note 对齐新版 c99 bgfx_video_decoder_au_t。
 */
@C
public struct VideoDecoderAu {
    /** @brief 访问单元大小（字节） */
    public var size: UInt32 = 0
    /** @brief 该访问单元的显示时间戳（微秒，容器提供） */
    public var ptsUs: Int64 = 0
    public init() {}
}

/**
 * @brief 视频解码帧提交参数
 * @explain 每次视频解码提交的参数，配合 VIDEO_DECODE_FRAME_* 标志使用。
 * @note 对齐新版 c99 bgfx_video_decoder_frame_t。
 */
@C
public struct VideoDecoderFrame {
    /** @brief 结构体魔数，必须为 BX_MAKEFOURCC('V','D','F',0x0) */
    public var magic: UInt32 = 0
    /** @brief 拼接的访问单元码流（解码顺序）；仅呈现 tick 时为 NULL */
    public var bitstream: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 每 AU 大小与 PTS 数组；numAus=0 时为 NULL */
    public var aus: CPointer<VideoDecoderAu> = CPointer<VideoDecoderAu>()
    /** @brief 本批次访问单元数量（0 = 仅呈现 tick） */
    public var numAus: UInt32 = 0
    /** @brief 当前播放墙钟时间（微秒，驱动据此挑选最匹配的画面） */
    public var presentationTimeUs: Int64 = 0
    /** @brief 每帧提交标志（VIDEO_DECODE_FRAME_*） */
    public var flags: UInt8 = 0
    public init() {}
}