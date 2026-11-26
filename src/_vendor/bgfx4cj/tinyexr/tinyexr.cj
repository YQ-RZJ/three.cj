/**
 * @file tinyexr EXR 图像库 CFFI 绑定
 * @brief tinyexr OpenEXR 图像读写库的 CFFI 绑定
 * @explain 本文件包含 tinyexr 库的完整 CFFI 绑定，支持 OpenEXR 格式图像的
 *         读取（LoadEXR）、写入（SaveEXR）、版本解析、头部解析、多部分图像、
 *         磁贴图像和深度图像功能。
 * @note tinyexr 是轻量级的 OpenEXR 格式 C 语言库，不含 C++ 依赖。
 * @link libs/libbimg_decode.a tinyexr 通过 libbimg_decode.a 链接
 * @see https://github.com/syoyo/tinyexr
 */
protected package three._vendor.bgfx4cj.tinyexr

// =============================================================================
// Constants
// =============================================================================

/** @brief EXR 操作成功 */
public const TINYEXR_SUCCESS: Int32 = 0
/** @brief EXR 错误：无效魔数 */
public const TINYEXR_ERROR_INVALID_MAGIC_NUMBER: Int32 = -1
/** @brief EXR 错误：无效版本 */
public const TINYEXR_ERROR_INVALID_EXR_VERSION: Int32 = -2
/** @brief EXR 错误：无效参数 */
public const TINYEXR_ERROR_INVALID_ARGUMENT: Int32 = -3
/** @brief EXR 错误：无效数据 */
public const TINYEXR_ERROR_INVALID_DATA: Int32 = -4
/** @brief EXR 错误：无效文件 */
public const TINYEXR_ERROR_INVALID_FILE: Int32 = -5
/** @brief EXR 错误：无效参数 */
public const TINYEXR_ERROR_INVALID_PARAMETER: Int32 = -6
/** @brief EXR 错误：无法打开文件 */
public const TINYEXR_ERROR_CANT_OPEN_FILE: Int32 = -7
/** @brief EXR 错误：不支持的格式 */
public const TINYEXR_ERROR_UNSUPPORTED_FORMAT: Int32 = -8
/** @brief EXR 错误：无效头部 */
public const TINYEXR_ERROR_INVALID_HEADER: Int32 = -9
/** @brief EXR 错误：不支持的功能 */
public const TINYEXR_ERROR_UNSUPPORTED_FEATURE: Int32 = -10
/** @brief EXR 错误：无法写入文件 */
public const TINYEXR_ERROR_CANT_WRITE_FILE: Int32 = -11
/** @brief EXR 错误：序列化失败 */
public const TINYEXR_ERROR_SERIALZATION_FAILED: Int32 = -12
/** @brief EXR 错误：未找到图层 */
public const TINYEXR_ERROR_LAYER_NOT_FOUND: Int32 = -13

/** @brief EXR 像素类型：无符号整数 */
public const TINYEXR_PIXELTYPE_UINT: Int32 = 0
/** @brief EXR 像素类型：半精度浮点 */
public const TINYEXR_PIXELTYPE_HALF: Int32 = 1
/** @brief EXR 像素类型：单精度浮点 */
public const TINYEXR_PIXELTYPE_FLOAT: Int32 = 2

/** @brief EXR 最大头部属性数 */
public const TINYEXR_MAX_HEADER_ATTRIBUTES: Int32 = 1024
/** @brief EXR 最大自定义属性数 */
public const TINYEXR_MAX_CUSTOM_ATTRIBUTES: Int32 = 128

/** @brief EXR 压缩：无 */
public const TINYEXR_COMPRESSIONTYPE_NONE: Int32 = 0
/** @brief EXR 压缩：RLE */
public const TINYEXR_COMPRESSIONTYPE_RLE: Int32 = 1
/** @brief EXR 压缩：ZIPS */
public const TINYEXR_COMPRESSIONTYPE_ZIPS: Int32 = 2
/** @brief EXR 压缩：ZIP */
public const TINYEXR_COMPRESSIONTYPE_ZIP: Int32 = 3
/** @brief EXR 压缩：PIZ */
public const TINYEXR_COMPRESSIONTYPE_PIZ: Int32 = 4
/** @brief EXR 压缩：ZFP */
public const TINYEXR_COMPRESSIONTYPE_ZFP: Int32 = 128

/** @brief ZFP 压缩模式：码率 */
public const TINYEXR_ZFP_COMPRESSIONTYPE_RATE: Int32 = 0
/** @brief ZFP 压缩模式：精度 */
public const TINYEXR_ZFP_COMPRESSIONTYPE_PRECISION: Int32 = 1
/** @brief ZFP 压缩模式：准确度 */
public const TINYEXR_ZFP_COMPRESSIONTYPE_ACCURACY: Int32 = 2

/** @brief EXR 磁贴：单级 */
public const TINYEXR_TILE_ONE_LEVEL: Int32 = 0
/** @brief EXR 磁贴：Mipmap 级别 */
public const TINYEXR_TILE_MIPMAP_LEVELS: Int32 = 1
/** @brief EXR 磁贴：Ripmap 级别 */
public const TINYEXR_TILE_RIPMAP_LEVELS: Int32 = 2

/** @brief EXR 磁贴舍入：向下 */
public const TINYEXR_TILE_ROUND_DOWN: Int32 = 0
/** @brief EXR 磁贴舍入：向上 */
public const TINYEXR_TILE_ROUND_UP: Int32 = 1

// =============================================================================
// Structs
// =============================================================================

/** @brief EXR 版本信息 */
@C
public struct EXRVersion {
    /** @brief 版本号 */
    public var version: Int32 = 0
    /** @brief 是否为分块（tiled）格式 */
    public var tiled: Int32 = 0
    /** @brief 是否使用长名称 */
    public var long_name: Int32 = 0
    /** @brief 是否为非图像数据 */
    public var non_image: Int32 = 0
    /** @brief 是否为多部分（multipart）格式 */
    public var multipart: Int32 = 0
    public init() {}
}

/** @brief EXR 属性 */
@C
public struct EXRAttribute {
    /** @brief 属性名称 */
    public var name = VArray<UInt8, $256>(repeat: 0)
    /** @brief 属性类型 */
    public var `type` = VArray<UInt8, $256>(repeat: 0)
    /** @brief 属性值指针 */
    public var value: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 属性值大小 */
    public var size: Int32 = 0
    /** @brief 对齐填充 */
    public var pad0: Int32 = 0
    public init() {}
}

/** @brief EXR 通道信息 */
@C
public struct EXRChannelInfo {
    /** @brief 通道名称 */
    public var name = VArray<UInt8, $256>(repeat: 0)
    /** @brief 像素类型 */
    public var pixel_type: Int32 = 0
    /** @brief X 方向采样率 */
    public var x_sampling: Int32 = 0
    /** @brief Y 方向采样率 */
    public var y_sampling: Int32 = 0
    /** @brief 线性标志 */
    public var p_linear: UInt8 = 0
    /** @brief 对齐填充 */
    public var pad = VArray<UInt8, $3>(repeat: 0)
    public init() {}
}

/** @brief EXR 二维边界框 */
@C
public struct EXRBox2i {
    /** @brief 最小 X 坐标 */
    public var min_x: Int32 = 0
    /** @brief 最小 Y 坐标 */
    public var min_y: Int32 = 0
    /** @brief 最大 X 坐标 */
    public var max_x: Int32 = 0
    /** @brief 最大 Y 坐标 */
    public var max_y: Int32 = 0
    public init() {}
}

/** @brief EXR 磁贴 */
@C
public struct EXRTile {
    /** @brief X 方向偏移 */
    public var offset_x: Int32 = 0
    /** @brief Y 方向偏移 */
    public var offset_y: Int32 = 0
    /** @brief X 方向级别 */
    public var level_x: Int32 = 0
    /** @brief Y 方向级别 */
    public var level_y: Int32 = 0
    /** @brief 磁贴宽度 */
    public var width: Int32 = 0
    /** @brief 磁贴高度 */
    public var height: Int32 = 0
    /** @brief 磁贴图像数据指针 */
    public var images: CPointer<CPointer<UInt8>> = CPointer<CPointer<UInt8>>()
    public init() {}
}

/** @brief EXR 头部信息 */
@C
public struct EXRHeader {
    /** @brief 像素宽高比 */
    public var pixel_aspect_ratio: Float32 = 0.0
    /** @brief 行序 */
    public var line_order: Int32 = 0
    /** @brief 数据窗口 */
    public var data_window: EXRBox2i = EXRBox2i()
    /** @brief 显示窗口 */
    public var display_window: EXRBox2i = EXRBox2i()
    /** @brief 屏幕窗口中心 */
    public var screen_window_center = VArray<Float32, $2>(repeat: 0.0)
    /** @brief 屏幕窗口宽度 */
    public var screen_window_width: Float32 = 0.0
    /** @brief 数据块数量 */
    public var chunk_count: Int32 = 0
    /** @brief 是否为分块格式 */
    public var tiled: Int32 = 0
    /** @brief 磁贴 X 方向大小 */
    public var tile_size_x: Int32 = 0
    /** @brief 磁贴 Y 方向大小 */
    public var tile_size_y: Int32 = 0
    /** @brief 磁贴级别模式 */
    public var tile_level_mode: Int32 = 0
    /** @brief 磁贴舍入模式 */
    public var tile_rounding_mode: Int32 = 0
    /** @brief 是否使用长名称 */
    public var long_name: Int32 = 0
    /** @brief 是否为非图像数据 */
    public var non_image: Int32 = 0
    /** @brief 是否为多部分格式 */
    public var multipart: Int32 = 0
    /** @brief 头部长度 */
    public var header_len: UInt32 = 0
    /** @brief 自定义属性数量 */
    public var num_custom_attributes: Int32 = 0
    /** @brief 自定义属性数组指针 */
    public var custom_attributes: CPointer<EXRAttribute> = CPointer<EXRAttribute>()
    /** @brief 通道信息数组指针 */
    public var channels: CPointer<EXRChannelInfo> = CPointer<EXRChannelInfo>()
    /** @brief 像素类型数组指针 */
    public var pixel_types: CPointer<Int32> = CPointer<Int32>()
    /** @brief 通道数量 */
    public var num_channels: Int32 = 0
    /** @brief 压缩类型 */
    public var compression_type: Int32 = 0
    /** @brief 请求的像素类型数组指针 */
    public var requested_pixel_types: CPointer<Int32> = CPointer<Int32>()
    /** @brief 头部名称 */
    public var name = VArray<UInt8, $256>(repeat: 0)
    public init() {}
}

/** @brief 多部分头部信息 */
@C
public struct EXRMultiPartHeader {
    /** @brief 头部数量 */
    public var num_headers: Int32 = 0
    /** @brief 头部数组指针 */
    public var headers: CPointer<EXRHeader> = CPointer<EXRHeader>()
    public init() {}
}

/** @brief EXR 图像数据 */
@C
public struct EXRImage {
    /** @brief 磁贴数组指针 */
    public var tiles: CPointer<EXRTile> = CPointer<EXRTile>()
    /** @brief 下一级别图像指针 */
    public var next_level: CPointer<EXRImage> = CPointer<EXRImage>()
    /** @brief X 方向级别 */
    public var level_x: Int32 = 0
    /** @brief Y 方向级别 */
    public var level_y: Int32 = 0
    /** @brief 图像数据指针 */
    public var images: CPointer<CPointer<UInt8>> = CPointer<CPointer<UInt8>>()
    /** @brief 图像宽度 */
    public var width: Int32 = 0
    /** @brief 图像高度 */
    public var height: Int32 = 0
    /** @brief 通道数量 */
    public var num_channels: Int32 = 0
    /** @brief 磁贴数量 */
    public var num_tiles: Int32 = 0
    public init() {}
}

/** @brief 多部分图像数据 */
@C
public struct EXRMultiPartImage {
    /** @brief 图像数量 */
    public var num_images: Int32 = 0
    /** @brief 图像数组指针 */
    public var images: CPointer<EXRImage> = CPointer<EXRImage>()
    public init() {}
}

/** @brief 深度图像数据 */
@C
public struct DeepImage {
    /** @brief 通道名称数组指针 */
    public var channel_names: CPointer<CString> = CPointer<CString>()
    /** @brief 图像数据指针 */
    public var image: CPointer<CPointer<CPointer<Float32>>> = CPointer<CPointer<CPointer<Float32>>>()
    /** @brief 偏移表指针 */
    public var offset_table: CPointer<CPointer<Int32>> = CPointer<CPointer<Int32>>()
    /** @brief 通道数量 */
    public var num_channels: Int32 = 0
    /** @brief 图像宽度 */
    public var width: Int32 = 0
    /** @brief 图像高度 */
    public var height: Int32 = 0
    /** @brief 对齐填充 */
    public var pad0: Int32 = 0
    public init() {}
}

// =============================================================================
// Foreign functions
// =============================================================================

// ----- Simple high-level APIs -----

foreign func LoadEXR(
    out_rgba: CPointer<CPointer<Float32>>,
    width: CPointer<Int32>,
    height: CPointer<Int32>,
    filename: CString,
    err: CPointer<CString>
): Int32

foreign func LoadEXRWithLayer(
    out_rgba: CPointer<CPointer<Float32>>,
    width: CPointer<Int32>,
    height: CPointer<Int32>,
    filename: CString,
    layer_name: CString,
    err: CPointer<CString>
): Int32

foreign func EXRLayers(
    filename: CString,
    layer_names: CPointer<CPointer<CString>>,
    num_layers: CPointer<Int32>,
    err: CPointer<CString>
): Int32

foreign func IsEXR(filename: CString): Int32

foreign func SaveEXR(
    data: CPointer<Float32>,
    width: Int32,
    height: Int32,
    components: Int32,
    save_as_fp16: Int32,
    filename: CString,
    err: CPointer<CString>
): Int32

foreign func EXRNumLevels(exr_image: CPointer<EXRImage>): Int32

// ----- Header / image init / free -----

foreign func InitEXRHeader(exr_header: CPointer<EXRHeader>): Unit

foreign func EXRSetNameAttr(exr_header: CPointer<EXRHeader>, name: CString): Unit

foreign func InitEXRImage(exr_image: CPointer<EXRImage>): Unit

foreign func FreeEXRHeader(exr_header: CPointer<EXRHeader>): Int32

foreign func FreeEXRImage(exr_image: CPointer<EXRImage>): Int32

foreign func FreeEXRErrorMessage(msg: CString): Unit

// ----- Version parsing -----

foreign func ParseEXRVersionFromFile(
    `version`: CPointer<EXRVersion>,
    filename: CString
): Int32

foreign func ParseEXRVersionFromMemory(
    `version`: CPointer<EXRVersion>,
    `memory`: CPointer<UInt8>,
    `size`: UIntNative
): Int32

// ----- Single-part header parsing -----

foreign func ParseEXRHeaderFromFile(
    header: CPointer<EXRHeader>,
    `version`: CPointer<EXRVersion>,
    filename: CString,
    err: CPointer<CString>
): Int32

foreign func ParseEXRHeaderFromMemory(
    header: CPointer<EXRHeader>,
    `version`: CPointer<EXRVersion>,
    `memory`: CPointer<UInt8>,
    `size`: UIntNative,
    err: CPointer<CString>
): Int32

// ----- Multi-part header parsing -----

foreign func ParseEXRMultipartHeaderFromFile(
    headers: CPointer<CPointer<CPointer<EXRHeader>>>,
    num_headers: CPointer<Int32>,
    `version`: CPointer<EXRVersion>,
    filename: CString,
    err: CPointer<CString>
): Int32

foreign func ParseEXRMultipartHeaderFromMemory(
    headers: CPointer<CPointer<CPointer<EXRHeader>>>,
    num_headers: CPointer<Int32>,
    `version`: CPointer<EXRVersion>,
    `memory`: CPointer<UInt8>,
    `size`: UIntNative,
    err: CPointer<CString>
): Int32

// ----- Single-part image loading -----

foreign func LoadEXRImageFromFile(
    image: CPointer<EXRImage>,
    header: CPointer<EXRHeader>,
    filename: CString,
    err: CPointer<CString>
): Int32

foreign func LoadEXRImageFromMemory(
    image: CPointer<EXRImage>,
    header: CPointer<EXRHeader>,
    `memory`: CPointer<UInt8>,
    `size`: UIntNative,
    err: CPointer<CString>
): Int32

// ----- Multi-part image loading -----

foreign func LoadEXRMultipartImageFromFile(
    images: CPointer<EXRImage>,
    headers: CPointer<CPointer<EXRHeader>>,
    num_parts: UInt32,
    filename: CString,
    err: CPointer<CString>
): Int32

foreign func LoadEXRMultipartImageFromMemory(
    images: CPointer<EXRImage>,
    headers: CPointer<CPointer<EXRHeader>>,
    num_parts: UInt32,
    `memory`: CPointer<UInt8>,
    `size`: UIntNative,
    err: CPointer<CString>
): Int32

// ----- Image saving -----

foreign func SaveEXRImageToFile(
    image: CPointer<EXRImage>,
    exr_header: CPointer<EXRHeader>,
    filename: CString,
    err: CPointer<CString>
): Int32

foreign func SaveEXRImageToMemory(
    image: CPointer<EXRImage>,
    exr_header: CPointer<EXRHeader>,
    `memory`: CPointer<CPointer<UInt8>>,
    err: CPointer<CString>
): UIntNative

foreign func SaveEXRMultipartImageToFile(
    images: CPointer<EXRImage>,
    exr_headers: CPointer<CPointer<EXRHeader>>,
    num_parts: UInt32,
    filename: CString,
    err: CPointer<CString>
): Int32

foreign func SaveEXRMultipartImageToMemory(
    images: CPointer<EXRImage>,
    exr_headers: CPointer<CPointer<EXRHeader>>,
    num_parts: UInt32,
    `memory`: CPointer<CPointer<UInt8>>,
    err: CPointer<CString>
): UIntNative

// ----- Deep image -----

foreign func LoadDeepEXR(
    out_image: CPointer<DeepImage>,
    filename: CString,
    err: CPointer<CString>
): Int32

// ----- Memory variant -----

foreign func LoadEXRFromMemory(
    out_rgba: CPointer<CPointer<Float32>>,
    width: CPointer<Int32>,
    height: CPointer<Int32>,
    `memory`: CPointer<UInt8>,
    `size`: UIntNative,
    err: CPointer<CString>
): Int32
