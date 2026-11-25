/**
 * @file bimg 类型定义
 * @brief bimg C API 的枚举、不透明类型和结构体定义
 * @explain 本文件包含 bimg 图像库的 CFFI 类型定义，包括 Quality/LightingModel/
 *         Orientation 枚举、不透明类型（ImageContainer/BimgAllocator 等）
 *         和值类型（TextureInfo/ImageBlockInfo/ImageMip）。
 * @note bimg::ImageContainer 作为不透明指针处理，字段通过 `bimg_ic_get_*` 函数访问。
 * @note 值类型通过 `@C` 标注确保 C 内存布局兼容。
 */
protected package three._vendor.bgfx4cj.bimg

// =============================================================================
// Enums
// =============================================================================

/**
 * @brief 图像编码质量枚举
 * @explain 控制图像编码器（如 BC 压缩）的质量/速度权衡。
 */
public enum Quality {
    /** @brief 默认质量 */
    | Default
    /** @brief 最高质量（较慢） */
    | Highest
    /** @brief 最快速度（质量较低） */
    | Fastest
    /** @brief 法线贴图默认质量 */
    | NormalMapDefault
    /** @brief 法线贴图最高质量 */
    | NormalMapHighest
    /** @brief 法线贴图最快速度 */
    | NormalMapFastest
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Default => 0
            case Highest => 1
            case Fastest => 2
            case NormalMapDefault => 3
            case NormalMapHighest => 4
            case NormalMapFastest => 5
            case Count => 6
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Quality {
        match (v) {
            case 0 => Default
            case 1 => Highest
            case 2 => Fastest
            case 3 => NormalMapDefault
            case 4 => NormalMapHighest
            case 5 => NormalMapFastest
            case _ => Count
        }
    }
}

/**
 * @brief 灯光模型枚举
 * @explain 用于立方体贴图辐射度滤波的灯光模型类型。
 */
public enum LightingModel {
    /** @brief Phong 光照模型 */
    | Phong
    /** @brief Phong BRDF 模型 */
    | PhongBrdf
    /** @brief Blinn 光照模型 */
    | Blinn
    /** @brief Blinn BRDF 模型 */
    | BlinnBrdf
    /** @brief GGX 微表面模型（PBR） */
    | Ggx
    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Phong => 0
            case PhongBrdf => 1
            case Blinn => 2
            case BlinnBrdf => 3
            case Ggx => 4
            case Count => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): LightingModel {
        match (v) {
            case 0 => Phong
            case 1 => PhongBrdf
            case 2 => Blinn
            case 3 => BlinnBrdf
            case 4 => Ggx
            case _ => Count
        }
    }
}

/**
 * @brief 图像朝向枚举
 * @explain 定义图像的旋转和翻转方向。
 */
public enum Orientation {
    /** @brief 不旋转 */
    | R0
    /** @brief 顺时针旋转 90 度 */
    | R90
    /** @brief 旋转 180 度 */
    | R180
    /** @brief 顺时针旋转 270 度 */
    | R270
    /** @brief 水平翻转 */
    | HFlip
    /** @brief 水平翻转 + 旋转 90 度 */
    | HFlipR90
    /** @brief 水平翻转 + 旋转 270 度 */
    | HFlipR270
    /** @brief 垂直翻转 */
    | VFlip

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case R0 => 0
            case R90 => 1
            case R180 => 2
            case R270 => 3
            case HFlip => 4
            case HFlipR90 => 5
            case HFlipR270 => 6
            case VFlip => 7
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Orientation {
        match (v) {
            case 0 => R0
            case 1 => R90
            case 2 => R180
            case 3 => R270
            case 4 => HFlip
            case 5 => HFlipR90
            case 6 => HFlipR270
            case 7 => VFlip
            case _ => R0
        }
    }
}

/**
 * @brief 纹理格式枚举
 * @explain 与 bimg::TextureFormat::Enum（bimg/bimg.h）严格对齐，数值与新版 bgfx TextureFormat 一致
 *         （新版在 R8/RG8/RGB8/RGBA8 等前后插入了 R8I/R8U/R8S、RGBA8I/U/S 等格式，RGBA8=74）。
 * @note 解码目标格式请使用枚举成员（如 TextureFormat.RGBA8.value()），
 */
public enum TextureFormat {
    // ---- 压缩格式 ----
    /** @brief Block Compression 1（DXT1），RGB，4 BPP */
    | BC1
    /** @brief Block Compression 2（DXT3），RGBA，8 BPP */
    | BC2
    /** @brief Block Compression 3（DXT5），RGBA，8 BPP */
    | BC3
    /** @brief Block Compression 4，单通道，4 BPP */
    | BC4
    /** @brief Block Compression 4 有符号版本，单通道，4 BPP */
    | BC4S
    /** @brief Block Compression 5，双通道 RG，8 BPP */
    | BC5
    /** @brief Block Compression 5 有符号版本，双通道 RG，8 BPP */
    | BC5S
    /** @brief Block Compression 6H，HDR RGB，8 BPP */
    | BC6H
    /** @brief Block Compression 6H 无符号浮点版本，HDR RGB，8 BPP */
    | BC6HU
    /** @brief Block Compression 7，高质量 RGBA，8 BPP */
    | BC7
    /** @brief ETC1 压缩，RGB，4 BPP */
    | ETC1
    /** @brief ETC2 压缩，RGB，4 BPP */
    | ETC2
    /** @brief ETC2 压缩带 alpha，RGBA，8 BPP */
    | ETC2A
    /** @brief ETC2 压缩 1 位 alpha，4 BPP */
    | ETC2A1
    /** @brief EAC R11，单 11 位红通道，无符号归一化，4 BPP */
    | EACR11
    /** @brief EAC R11 有符号归一化，4 BPP */
    | EACR11S
    /** @brief EAC RG11，双 11 位通道，无符号归一化，8 BPP */
    | EACRG11
    /** @brief EAC RG11 有符号归一化，8 BPP */
    | EACRG11S
    // ---- PVRTC ----
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
    // ---- ATC ----
    /** @brief ATC RGB 压缩 */
    | ATC
    /** @brief ATC RGBA 压缩（显式 alpha） */
    | ATCE
    /** @brief ATC RGBA 压缩（插值 alpha） */
    | ATCI
    // ---- ASTC ----
    /** @brief ASTC 4x4 块，8 BPP */
    | ASTC4X4
    /** @brief ASTC 5x4 块，8 BPP */
    | ASTC5X4
    /** @brief ASTC 5x5 块，8 BPP */
    | ASTC5X5
    /** @brief ASTC 6x5 块，8 BPP */
    | ASTC6X5
    /** @brief ASTC 6x6 块，8 BPP */
    | ASTC6X6
    /** @brief ASTC 8x5 块，8 BPP */
    | ASTC8X5
    /** @brief ASTC 8x6 块，8 BPP */
    | ASTC8X6
    /** @brief ASTC 8x8 块，8 BPP */
    | ASTC8X8
    /** @brief ASTC 10x5 块，8 BPP */
    | ASTC10X5
    /** @brief ASTC 10x6 块，8 BPP */
    | ASTC10X6
    /** @brief ASTC 10x8 块，8 BPP */
    | ASTC10X8
    /** @brief ASTC 10x10 块，8 BPP */
    | ASTC10X10
    /** @brief ASTC 12x10 块，8 BPP */
    | ASTC12X10
    /** @brief ASTC 12x12 块，8 BPP */
    | ASTC12X12

    // ---- 非压缩格式 ----
    /** @brief 未知格式（压缩格式区段之后） */
    | Unknown
    /** @brief 1 位单通道红，1 BPP */
    | R1
    /** @brief 8 位单通道 alpha，8 BPP */
    | A8
    /** @brief 8 位单通道红，无符号归一化，8 BPP */
    | R8
    /** @brief 8 位单通道红，有符号整数，8 BPP */
    | R8I
    /** @brief 8 位单通道红，无符号整数，8 BPP */
    | R8U
    /** @brief 8 位单通道红，有符号归一化，8 BPP */
    | R8S
    /** @brief 16 位单通道红，无符号归一化，16 BPP */
    | R16
    /** @brief 16 位单通道红，有符号整数，16 BPP */
    | R16I
    /** @brief 16 位单通道红，无符号整数，16 BPP */
    | R16U
    /** @brief 16 位单通道红，半精度浮点，16 BPP */
    | R16F
    /** @brief 16 位单通道红，有符号归一化，16 BPP */
    | R16S
    /** @brief 32 位单通道红，有符号整数，32 BPP */
    | R32I
    /** @brief 32 位单通道红，无符号整数，32 BPP */
    | R32U
    /** @brief 32 位单通道红，全精度浮点，32 BPP */
    | R32F
    /** @brief 双通道 RG8，无符号归一化，16 BPP */
    | RG8
    /** @brief 双通道 RG8，有符号整数，16 BPP */
    | RG8I
    /** @brief 双通道 RG8，无符号整数，16 BPP */
    | RG8U
    /** @brief 双通道 RG8，有符号归一化，16 BPP */
    | RG8S
    /** @brief 双通道 RG16，无符号归一化，32 BPP */
    | RG16
    /** @brief 双通道 RG16，有符号整数，32 BPP */
    | RG16I
    /** @brief 双通道 RG16，无符号整数，32 BPP */
    | RG16U
    /** @brief 双通道 RG16，半精度浮点，32 BPP */
    | RG16F
    /** @brief 双通道 RG16，有符号归一化，32 BPP */
    | RG16S
    /** @brief 双通道 RG32，有符号整数，64 BPP */
    | RG32I
    /** @brief 双通道 RG32，无符号整数，64 BPP */
    | RG32U
    /** @brief 双通道 RG32，全精度浮点，64 BPP */
    | RG32F
    /** @brief 三通道 RGB8，无符号归一化，24 BPP */
    | RGB8
    /** @brief 三通道 RGB8，有符号整数，24 BPP */
    | RGB8I
    /** @brief 三通道 RGB8，无符号整数，24 BPP */
    | RGB8U
    /** @brief 三通道 RGB8，有符号归一化，24 BPP */
    | RGB8S
    /** @brief 共享指数 RGB（9 位每通道 + 5 位共享指数），浮点，32 BPP */
    | RGB9E5F
    /** @brief 四通道 BGRA8，无符号归一化，32 BPP */
    | BGRA8
    /** @brief 四通道 RGBA8，无符号归一化，32 BPP */
    | RGBA8
    /** @brief 四通道 RGBA8，有符号整数，32 BPP */
    | RGBA8I
    /** @brief 四通道 RGBA8，无符号整数，32 BPP */
    | RGBA8U
    /** @brief 四通道 RGBA8，有符号归一化，32 BPP */
    | RGBA8S
    /** @brief 四通道 RGBA16，无符号归一化，64 BPP */
    | RGBA16
    /** @brief 四通道 RGBA16，有符号整数，64 BPP */
    | RGBA16I
    /** @brief 四通道 RGBA16，无符号整数，64 BPP */
    | RGBA16U
    /** @brief 四通道 RGBA16，半精度浮点，64 BPP */
    | RGBA16F
    /** @brief 四通道 RGBA16，有符号归一化，64 BPP */
    | RGBA16S
    /** @brief 四通道 RGBA32，有符号整数，128 BPP */
    | RGBA32I
    /** @brief 四通道 RGBA32，无符号整数，128 BPP */
    | RGBA32U
    /** @brief 四通道 RGBA32，全精度浮点，128 BPP */
    | RGBA32F
    // ---- 打包 16/32 位格式 ----
    /** @brief 打包 16 位 B5G6R5，16 BPP */
    | B5G6R5
    /** @brief 打包 16 位 R5G6B5，16 BPP */
    | R5G6B5
    /** @brief 打包 16 位 BGRA4，16 BPP */
    | BGRA4
    /** @brief 打包 16 位 RGBA4，16 BPP */
    | RGBA4
    /** @brief 打包 16 位 BGR5A1，16 BPP */
    | BGR5A1
    /** @brief 打包 16 位 RGB5A1，16 BPP */
    | RGB5A1
    /** @brief 打包 32 位 RGB10A2，无符号归一化，32 BPP */
    | RGB10A2
    /** @brief 打包 32 位 RGB10A2，无符号整数，32 BPP */
    | RGB10A2U
    /** @brief 打包 32 位 RG11B10F，无符号浮点，无 alpha，32 BPP */
    | RG11B10F

    // ---- 深度格式 ----
    /** @brief 未知深度格式 */
    | UnknownDepth
    /** @brief 16 位深度，16 BPP */
    | D16
    /** @brief 24 位深度（按 32 位存储），32 BPP */
    | D24
    /** @brief 24 位深度 + 8 位模板，32 BPP */
    | D24S8
    /** @brief 32 位深度，32 BPP */
    | D32
    /** @brief 16 位深度，浮点，16 BPP */
    | D16F
    /** @brief 24 位深度，浮点（按 32 位存储），32 BPP */
    | D24F
    /** @brief 32 位深度，浮点，32 BPP */
    | D32F
    /** @brief 32 位深度浮点 + 8 位模板（按 64 位存储），64 BPP */
    | D32FS8
    /** @brief 仅 8 位模板，8 BPP */
    | D0S8

    /** @brief 枚举成员总数 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
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

    /** @brief 从 UInt32 转换回枚举值（未知值回退 Unknown） */
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
            case _ => Unknown
        }
    }
}

// =============================================================================
// Opaque types (passed as pointers from Cangjie)
// =============================================================================

/** @brief 不透明 bimg::ImageContainer — 通过 bimg_ic_get_* 函数访问字段 */
@C
public struct ImageContainer {}

/** @brief 不透明 bx::AllocatorI */
@C
public struct BimgAllocator {}

/** @brief 不透明 bx::Error */
@C
public struct BimgError {}

/** @brief 不透明 bx::WriterI */
@C
public struct BimgWriter {}

/** @brief 不透明 bx::ReaderSeekerI */
@C
public struct BimgReaderSeeker {}

// =============================================================================
// Value structs (returned by value from C API, layout-safe)
// =============================================================================

/** @brief bimg::TextureInfo 的镜像 */
@C
public struct TextureInfo {
    /** @brief 纹理格式 */
    public var format: UInt32 = 0
    /** @brief 存储大小（字节） */
    public var storageSize: UInt32 = 0
    /** @brief 宽度（像素） */
    public var width: UInt16 = 0
    /** @brief 高度（像素） */
    public var height: UInt16 = 0
    /** @brief 深度（像素） */
    public var depth: UInt16 = 0
    /** @brief 图层数量 */
    public var numLayers: UInt16 = 0
    /** @brief Mip 等级数量 */
    public var numMips: UInt8 = 0
    /** @brief 每像素位数 */
    public var bitsPerPixel: UInt8 = 0
    /** @brief 是否为立方体贴图 */
    public var cubeMap: Bool = false
    public init() {}
}

/** @brief bimg::ImageBlockInfo 的镜像 */
@C
public struct ImageBlockInfo {
    /** @brief 每像素位数 */
    public var bitsPerPixel: UInt8 = 0
    /** @brief 块宽度 */
    public var blockWidth: UInt8 = 0
    /** @brief 块高度 */
    public var blockHeight: UInt8 = 0
    /** @brief 块大小 */
    public var blockSize: UInt8 = 0
    /** @brief 最小块 X */
    public var minBlockX: UInt8 = 0
    /** @brief 最小块 Y */
    public var minBlockY: UInt8 = 0
    /** @brief 深度位数 */
    public var depthBits: UInt8 = 0
    /** @brief 模板位数 */
    public var stencilBits: UInt8 = 0
    /** @brief 红色通道位数 */
    public var rBits: UInt8 = 0
    /** @brief 绿色通道位数 */
    public var gBits: UInt8 = 0
    /** @brief 蓝色通道位数 */
    public var bBits: UInt8 = 0
    /** @brief Alpha 通道位数 */
    public var aBits: UInt8 = 0
    /** @brief 编码类型 */
    public var encoding: UInt8 = 0
    public init() {}
}

/** @brief bimg::ImageMip 的镜像 */
@C
public struct ImageMip {
    /** @brief 纹理格式 */
    public var m_format: UInt32 = 0
    /** @brief 图像宽度 */
    public var m_width: UInt32 = 0
    /** @brief 图像高度 */
    public var m_height: UInt32 = 0
    /** @brief 图像深度 */
    public var m_depth: UInt32 = 0
    /** @brief 块大小 */
    public var m_blockSize: UInt32 = 0
    /** @brief 数据大小 */
    public var m_size: UInt32 = 0
    /** @brief 每像素位数 */
    public var m_bpp: UInt8 = 0
    /** @brief 是否包含 Alpha 通道 */
    public var m_hasAlpha: Bool = false
    /** @brief 数据指针 */
    public var m_data: CPointer<UInt8> = CPointer<UInt8>()
    public init() {}
}
