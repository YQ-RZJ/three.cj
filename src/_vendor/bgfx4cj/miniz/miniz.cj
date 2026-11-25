/**
 * @file miniz 压缩库 CFFI 绑定
 * @brief miniz 压缩库的 CFFI 绑定（zlib 兼容压缩/解压缩 + tdefl 低级压缩）
 * @explain 本文件包含 miniz 库的 CFFI 绑定，仅覆盖宿主静态库
 *         （libbimg_decode.a 等）实际导出的符号：zlib 兼容的
 *         deflate/inflate 压缩解压缩与 tdefl 低级压缩。
 * @note bimg 编译 miniz 时定义了 MINIZ_NO_ARCHIVE_APIS（并裁剪 tinfl），
 *       因此 ZIP 存档 API（mz_zip_*）与低级解压 API（tinfl_*）在链接库中
 *       不存在，此处不做绑定；如需 ZIP 能力请改用完整 miniz 构建并扩充本文件。
 * @link libs/libbimg_decode.a miniz 通过 libbimg_decode.a 链接
 * @see https://github.com/richgel999/miniz
 */
protected package three._vendor.bgfx4cj.miniz

// =============================================================================
// Type aliases (C primitive typedefs)
// =============================================================================

/** @brief unsigned long 类型别名（Windows 下为 UInt32） */
public type MzUlong = UInt32       // unsigned long (Windows)
/** @brief uint8_t 类型别名 */
public type MzUint8 = UInt8
/** @brief int16_t 类型别名 */
public type MzInt16 = Int16
/** @brief uint16_t 类型别名 */
public type MzUint16 = UInt16
/** @brief uint32_t 类型别名 */
public type MzUint32 = UInt32
/** @brief unsigned int 类型别名 */
public type MzUint = UInt32
/** @brief int64_t 类型别名 */
public type MzInt64 = Int64
/** @brief uint64_t 类型别名 */
public type MzUint64 = UInt64
/** @brief bool 类型别名 */
public type MzBool = Bool

// =============================================================================
// Function pointer typedefs
// =============================================================================

/** @brief 内存分配函数指针类型 */
public type MzAllocFunc = CFunc<(CPointer<Unit>, UIntNative, UIntNative) -> CPointer<Unit>>
/** @brief 内存释放函数指针类型 */
public type MzFreeFunc = CFunc<(CPointer<Unit>, CPointer<Unit>) -> Unit>
/** @brief 内存重分配函数指针类型 */
public type MzReallocFunc = CFunc<(CPointer<Unit>, CPointer<Unit>, UIntNative, UIntNative) -> CPointer<Unit>>
/** @brief tdefl 输出缓冲写入函数指针类型 */
public type TdeflPutBufFuncPtr = CFunc<(CPointer<Unit>, Int32, CPointer<Unit>) -> Bool>

// =============================================================================
// Constants
// =============================================================================

// Compression levels
/** @brief 不压缩 */
public const MZ_NO_COMPRESSION: Int32 = 0
/** @brief 最快速度 */
public const MZ_BEST_SPEED: Int32 = 1
/** @brief 最佳压缩 */
public const MZ_BEST_COMPRESSION: Int32 = 9
/** @brief 极限压缩 */
public const MZ_UBER_COMPRESSION: Int32 = 10
/** @brief 默认压缩级别 */
public const MZ_DEFAULT_LEVEL: Int32 = 6
/** @brief 默认压缩（-1 表示使用默认级别 6） */
public const MZ_DEFAULT_COMPRESSION: Int32 = -1

// Flush values
/** @brief 刷新：无 */
public const MZ_NO_FLUSH: Int32 = 0
/** @brief 刷新：部分 */
public const MZ_PARTIAL_FLUSH: Int32 = 1
/** @brief 刷新：同步 */
public const MZ_SYNC_FLUSH: Int32 = 2
/** @brief 刷新：完全 */
public const MZ_FULL_FLUSH: Int32 = 3
/** @brief 刷新：完成 */
public const MZ_FINISH: Int32 = 4
/** @brief 刷新：块 */
public const MZ_BLOCK: Int32 = 5

// Return status codes
/** @brief 操作成功 */
public const MZ_OK: Int32 = 0
/** @brief 流结束 */
public const MZ_STREAM_END: Int32 = 1
/** @brief 需要字典 */
public const MZ_NEED_DICT: Int32 = 2
/** @brief 系统错误 */
public const MZ_ERRNO: Int32 = -1
/** @brief 流错误 */
public const MZ_STREAM_ERROR: Int32 = -2
/** @brief 数据错误 */
public const MZ_DATA_ERROR: Int32 = -3
/** @brief 内存错误 */
public const MZ_MEM_ERROR: Int32 = -4
/** @brief 缓冲错误 */
public const MZ_BUF_ERROR: Int32 = -5
/** @brief 版本错误 */
public const MZ_VERSION_ERROR: Int32 = -6
/** @brief 参数错误 */
public const MZ_PARAM_ERROR: Int32 = -10000

// Compression method
/** @brief 压缩方法：Deflate */
public const MZ_DEFLATED: Int32 = 8

// Window bits
/** @brief 默认窗口位数 */
public const MZ_DEFAULT_WINDOW_BITS: Int32 = 15

// Adler32 / CRC32 init
/** @brief Adler32 初始值 */
public const MZ_ADLER32_INIT: UInt32 = 1
/** @brief CRC32 初始值 */
public const MZ_CRC32_INIT: UInt32 = 0

// Version
/** @brief 版本号 */
public const MZ_VERNUM: UInt32 = 0xA100
/** @brief 主版本号 */
public const MZ_VER_MAJOR: UInt32 = 10
/** @brief 次版本号 */
public const MZ_VER_MINOR: UInt32 = 2
/** @brief 修订号 */
public const MZ_VER_REVISION: UInt32 = 0
/** @brief 子修订号 */
public const MZ_VER_SUBREVISION: UInt32 = 0

// Strategy
/** @brief 默认策略 */
public const MZ_DEFAULT_STRATEGY: Int32 = 0
/** @brief 过滤策略 */
public const MZ_FILTERED: Int32 = 1
/** @brief 仅霍夫曼编码 */
public const MZ_HUFFMAN_ONLY: Int32 = 2
/** @brief RLE 策略 */
public const MZ_RLE: Int32 = 3
/** @brief 固定策略 */
public const MZ_FIXED: Int32 = 4

// Limits
/** @brief UInt16 最大值 */
public const MZ_UINT16_MAX: UInt32 = 0xFFFF
/** @brief UInt32 最大值 */
public const MZ_UINT32_MAX: UInt32 = 0xFFFFFFFF

// tdefl flags
/** @brief tdefl 标志：仅霍夫曼编码 */
public const TDEFL_HUFFMAN_ONLY: Int32 = 0
/** @brief tdefl 默认最大探测次数 */
public const TDEFL_DEFAULT_MAX_PROBES: Int32 = 128
/** @brief tdefl 最大探测次数掩码 */
public const TDEFL_MAX_PROBES_MASK: Int32 = 0xFFF
/** @brief tdefl 写入 zlib 头部 */
public const TDEFL_WRITE_ZLIB_HEADER: Int32 = 0x01000
/** @brief tdefl 计算 Adler32 */
public const TDEFL_COMPUTE_ADLER32: Int32 = 0x02000
/** @brief tdefl 贪婪解析标志 */
public const TDEFL_GREEDY_PARSING_FLAG: Int32 = 0x04000
/** @brief tdefl 非确定性解析标志 */
public const TDEFL_NONDETERMINISTIC_PARSING_FLAG: Int32 = 0x08000
/** @brief tdefl RLE 匹配 */
public const TDEFL_RLE_MATCHES: Int32 = 0x10000
/** @brief tdefl 过滤匹配 */
public const TDEFL_FILTER_MATCHES: Int32 = 0x20000
/** @brief tdefl 强制所有静态块 */
public const TDEFL_FORCE_ALL_STATIC_BLOCKS: Int32 = 0x40000
/** @brief tdefl 强制所有原始块 */
public const TDEFL_FORCE_ALL_RAW_BLOCKS: Int32 = 0x80000

// tdefl 状态码（枚举值）
/** @brief tdefl 状态：参数错误 */
public const TDEFL_STATUS_BAD_PARAM: Int32 = -2
/** @brief tdefl 状态：写入缓冲区失败 */
public const TDEFL_STATUS_PUT_BUF_FAILED: Int32 = -1
/** @brief tdefl 状态：正常 */
public const TDEFL_STATUS_OKAY: Int32 = 0
/** @brief tdefl 状态：完成 */
public const TDEFL_STATUS_DONE: Int32 = 1

// tdefl 刷新模式（枚举值）
/** @brief tdefl 刷新：不刷新 */
public const TDEFL_NO_FLUSH: Int32 = 0
/** @brief tdefl 刷新：同步刷新 */
public const TDEFL_SYNC_FLUSH: Int32 = 2
/** @brief tdefl 刷新：完全刷新 */
public const TDEFL_FULL_FLUSH: Int32 = 3
/** @brief tdefl 刷新：完成流 */
public const TDEFL_FINISH: Int32 = 4

// =============================================================================
// Opaque struct types (only used via pointer; internal layout not exposed)
// =============================================================================

@C
/** @brief tdefl 压缩器（不透明） */
public struct TdeflCompressor {}

// =============================================================================
// Public structs
// =============================================================================

/// Compression/decompression stream struct (mz_stream).
/// Function pointer fields are stored as CPointer<Unit> for binary compatibility
/// with C function pointers (same size, same nullability).
@C
/** @brief 压缩/解压缩流结构体（mz_stream） */
public struct MzStream {
    /** @brief 输入缓冲指针 */
    public var next_in: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 输入缓冲可用字节数 */
    public var avail_in: UInt32 = 0
    /** @brief 已处理输入总字节数 */
    public var total_in: MzUlong = 0
    /** @brief 输出缓冲指针 */
    public var next_out: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 输出缓冲可用字节数 */
    public var avail_out: UInt32 = 0
    /** @brief 已产生输出总字节数 */
    public var total_out: MzUlong = 0
    /** @brief 错误消息字符串 */
    public var msg: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 内部状态指针 */
    public var state: CPointer<Unit> = CPointer<Unit>()
    /** @brief 自定义分配函数 */
    public var zalloc: CPointer<Unit> = CPointer<Unit>()
    /** @brief 自定义释放函数 */
    public var zfree: CPointer<Unit> = CPointer<Unit>()
    /** @brief 自定义分配器上下文 */
    public var opaque: CPointer<Unit> = CPointer<Unit>()
    /** @brief 数据类型标志 */
    public var data_type: Int32 = 0
    /** @brief Adler32 校验和 */
    public var adler: MzUlong = 0
    /** @brief 保留字段 */
    public var reserved: MzUlong = 0
    public init() {}
}

// =============================================================================
// Foreign functions — Utility
// =============================================================================

foreign func mz_free(p: CPointer<Unit>): Unit

foreign func mz_adler32(adler: MzUlong, ptr: CPointer<UInt8>, buf_len: UIntNative): MzUlong

foreign func mz_crc32(crc: MzUlong, ptr: CPointer<UInt8>, buf_len: UIntNative): MzUlong

foreign func mz_version(): CString

// =============================================================================
// Foreign functions — Default allocators
// =============================================================================

foreign func miniz_def_alloc_func(
    opaque: CPointer<Unit>,
    items: UIntNative,
    `size`: UIntNative
): CPointer<Unit>

foreign func miniz_def_free_func(opaque: CPointer<Unit>, address: CPointer<Unit>): Unit

foreign func miniz_def_realloc_func(
    opaque: CPointer<Unit>,
    address: CPointer<Unit>,
    items: UIntNative,
    `size`: UIntNative
): CPointer<Unit>

// =============================================================================
// Foreign functions — Compression (zlib-style high-level)
// =============================================================================

foreign func mz_deflateInit(pStream: CPointer<MzStream>, level: Int32): Int32

foreign func mz_deflateInit2(
    pStream: CPointer<MzStream>,
    level: Int32,
    method: Int32,
    window_bits: Int32,
    mem_level: Int32,
    strategy: Int32
): Int32

foreign func mz_deflateReset(pStream: CPointer<MzStream>): Int32

foreign func mz_deflate(pStream: CPointer<MzStream>, flush: Int32): Int32

foreign func mz_deflateEnd(pStream: CPointer<MzStream>): Int32

foreign func mz_deflateBound(pStream: CPointer<MzStream>, source_len: MzUlong): MzUlong

foreign func mz_compress(
    pDest: CPointer<UInt8>,
    pDest_len: CPointer<MzUlong>,
    pSource: CPointer<UInt8>,
    source_len: MzUlong
): Int32

foreign func mz_compress2(
    pDest: CPointer<UInt8>,
    pDest_len: CPointer<MzUlong>,
    pSource: CPointer<UInt8>,
    source_len: MzUlong,
    level: Int32
): Int32

foreign func mz_compressBound(source_len: MzUlong): MzUlong

foreign func mz_inflateInit(pStream: CPointer<MzStream>): Int32

foreign func mz_inflateInit2(pStream: CPointer<MzStream>, window_bits: Int32): Int32

foreign func mz_inflateReset(pStream: CPointer<MzStream>): Int32

foreign func mz_inflate(pStream: CPointer<MzStream>, flush: Int32): Int32

foreign func mz_inflateEnd(pStream: CPointer<MzStream>): Int32

foreign func mz_uncompress(
    pDest: CPointer<UInt8>,
    pDest_len: CPointer<MzUlong>,
    pSource: CPointer<UInt8>,
    source_len: MzUlong
): Int32

foreign func mz_uncompress2(
    pDest: CPointer<UInt8>,
    pDest_len: CPointer<MzUlong>,
    pSource: CPointer<UInt8>,
    pSource_len: CPointer<MzUlong>
): Int32

foreign func mz_error(err: Int32): CString

// =============================================================================
// Foreign functions — tdefl (low-level compression)
// =============================================================================

foreign func tdefl_compress_mem_to_heap(
    pSrc_buf: CPointer<Unit>,
    src_buf_len: UIntNative,
    pOut_len: CPointer<UIntNative>,
    flags: Int32
): CPointer<Unit>

foreign func tdefl_compress_mem_to_mem(
    pOut_buf: CPointer<Unit>,
    out_buf_len: UIntNative,
    pSrc_buf: CPointer<Unit>,
    src_buf_len: UIntNative,
    flags: Int32
): UIntNative

foreign func tdefl_write_image_to_png_file_in_memory_ex(
    pImage: CPointer<Unit>,
    w: Int32,
    h: Int32,
    num_chans: Int32,
    pLen_out: CPointer<UIntNative>,
    level: UInt32,
    flip: Bool
): CPointer<Unit>

foreign func tdefl_write_image_to_png_file_in_memory(
    pImage: CPointer<Unit>,
    w: Int32,
    h: Int32,
    num_chans: Int32,
    pLen_out: CPointer<UIntNative>
): CPointer<Unit>

foreign func tdefl_compress_mem_to_output(
    pBuf: CPointer<Unit>,
    buf_len: UIntNative,
    pPut_buf_func: TdeflPutBufFuncPtr,
    pPut_buf_user: CPointer<Unit>,
    flags: Int32
): Bool

foreign func tdefl_init(
    d: CPointer<TdeflCompressor>,
    pPut_buf_func: TdeflPutBufFuncPtr,
    pPut_buf_user: CPointer<Unit>,
    flags: Int32
): Int32

foreign func tdefl_compress(
    d: CPointer<TdeflCompressor>,
    pIn_buf: CPointer<Unit>,
    pIn_buf_size: CPointer<UIntNative>,
    pOut_buf: CPointer<Unit>,
    pOut_buf_size: CPointer<UIntNative>,
    flush: Int32
): Int32

foreign func tdefl_compress_buffer(
    d: CPointer<TdeflCompressor>,
    pIn_buf: CPointer<Unit>,
    in_buf_size: UIntNative,
    flush: Int32
): Int32

foreign func tdefl_get_prev_return_status(d: CPointer<TdeflCompressor>): Int32

foreign func tdefl_get_adler32(d: CPointer<TdeflCompressor>): UInt32

foreign func tdefl_create_comp_flags_from_zip_params(
    level: Int32,
    window_bits: Int32,
    strategy: Int32
): UInt32

foreign func tdefl_compressor_alloc(): CPointer<TdeflCompressor>

foreign func tdefl_compressor_free(pComp: CPointer<TdeflCompressor>): Unit
