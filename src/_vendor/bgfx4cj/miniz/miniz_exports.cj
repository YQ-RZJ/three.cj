/**
 * @file miniz 公共函数包装
 * @brief miniz C API 的仓颉安全包装函数
 * @explain 本文件为每个 miniz foreign 函数提供 `_cj` 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中，以满足仓颉 FFI 要求。
 * @note 包括 zlib 兼容压缩/解压缩与 tdefl 低级压缩。
 *       bimg 编译 miniz 时启用了 MINIZ_NO_ARCHIVE_APIS 并裁剪了 tinfl，
 *       链接库中无 mz_zip_* / tinfl_* 符号，故不提供对应包装。
 */
protected package three._vendor.bgfx4cj.miniz

/**
 * @brief 释放 miniz 分配的内存
 * @param p 指针
 */
public func mz_free_cj(p: CPointer<Unit>): Unit {
    unsafe {
        mz_free(p)
    }
}

/**
 * @brief 计算 Adler32 校验和
 * @param adler Adler32 校验和
 * @param ptr 指针值
 * @param buf_len 缓冲长度
 * @return MzUlong 返回值描述
 */
public func mz_adler32_cj(adler: MzUlong, ptr: CPointer<UInt8>, buf_len: UIntNative): MzUlong {
    return unsafe {
        mz_adler32(adler, ptr, buf_len)
    }
}

/**
 * @brief 计算 CRC32 校验和
 * @param crc CRC32 校验和
 * @param ptr 指针值
 * @param buf_len 缓冲长度
 * @return MzUlong 返回值描述
 */
public func mz_crc32_cj(crc: MzUlong, ptr: CPointer<UInt8>, buf_len: UIntNative): MzUlong {
    return unsafe {
        mz_crc32(crc, ptr, buf_len)
    }
}

/**
 * @brief 获取 miniz 版本字符串
 * @return CString 返回值描述
 */
public func mz_version_cj(): CString {
    return unsafe {
        mz_version()
    }
}

/**
 * @brief miniz 默认内存分配函数
 * @param opaque 不透明上下文
 * @param items 元素数量
 * @param `size` size
 * @return CPointer 返回值描述
 */
public func miniz_def_alloc_func_cj(opaque: CPointer<Unit>, items: UIntNative, `size`: UIntNative): CPointer<Unit> {
    return unsafe {
        miniz_def_alloc_func(opaque, items, `size`)
    }
}

/**
 * @brief miniz 默认内存释放函数
 * @param opaque 不透明上下文
 * @param address 内存地址
 */
public func miniz_def_free_func_cj(opaque: CPointer<Unit>, address: CPointer<Unit>): Unit {
    unsafe {
        miniz_def_free_func(opaque, address)
    }
}

/**
 * @brief miniz 默认内存重分配函数
 * @param opaque 不透明上下文
 * @param address 内存地址
 * @param items 元素数量
 * @param `size` size
 * @return CPointer 返回值描述
 */
public func miniz_def_realloc_func_cj(opaque: CPointer<Unit>, address: CPointer<Unit>, items: UIntNative, `size`: UIntNative): CPointer<Unit> {
    return unsafe {
        miniz_def_realloc_func(opaque, address, items, `size`)
    }
}

/**
 * @brief 初始化 deflate 流（zlib 兼容）
 * @param pStream 流指针
 * @param level 压缩级别
 * @return Int32 返回值描述
 */
public func mz_deflateInit_cj(pStream: CPointer<MzStream>, level: Int32): Int32 {
    return unsafe {
        mz_deflateInit(pStream, level)
    }
}

/**
 * @brief 初始化 deflate 流（高级参数）
 * @param pStream 流指针
 * @param level 压缩级别
 * @param method 压缩方法
 * @param window_bits 窗口位数
 * @param mem_level 内存级别
 * @param strategy 压缩策略
 * @return Int32 返回值描述
 */
public func mz_deflateInit2_cj(pStream: CPointer<MzStream>, level: Int32, method: Int32, window_bits: Int32, mem_level: Int32, strategy: Int32): Int32 {
    return unsafe {
        mz_deflateInit2(pStream, level, method, window_bits, mem_level, strategy)
    }
}

/**
 * @brief 重置 deflate 流状态
 * @param pStream 流指针
 * @return Int32 返回值描述
 */
public func mz_deflateReset_cj(pStream: CPointer<MzStream>): Int32 {
    return unsafe {
        mz_deflateReset(pStream)
    }
}

/**
 * @brief 执行 deflate 压缩
 * @param pStream 流指针
 * @param flush 刷新模式
 * @return Int32 返回值描述
 */
public func mz_deflate_cj(pStream: CPointer<MzStream>, flush: Int32): Int32 {
    return unsafe {
        mz_deflate(pStream, flush)
    }
}

/**
 * @brief 结束 deflate 流，释放资源
 * @param pStream 流指针
 * @return Int32 返回值描述
 */
public func mz_deflateEnd_cj(pStream: CPointer<MzStream>): Int32 {
    return unsafe {
        mz_deflateEnd(pStream)
    }
}

/**
 * @brief 计算 deflate 压缩后的上限大小
 * @param pStream 流指针
 * @param source_len 源数据长度
 * @return MzUlong 返回值描述
 */
public func mz_deflateBound_cj(pStream: CPointer<MzStream>, source_len: MzUlong): MzUlong {
    return unsafe {
        mz_deflateBound(pStream, source_len)
    }
}

/**
 * @brief 压缩数据（zlib 兼容，默认级别）
 * @param pDest 目标缓冲指针
 * @param pDest_len 目标长度指针
 * @param pSource 源数据指针
 * @param source_len 源数据长度
 * @return Int32 返回值描述
 */
public func mz_compress_cj(pDest: CPointer<UInt8>, pDest_len: CPointer<MzUlong>, pSource: CPointer<UInt8>, source_len: MzUlong): Int32 {
    return unsafe {
        mz_compress(pDest, pDest_len, pSource, source_len)
    }
}

/**
 * @brief 压缩数据（zlib 兼容，指定级别）
 * @param pDest 目标缓冲指针
 * @param pDest_len 目标长度指针
 * @param pSource 源数据指针
 * @param source_len 源数据长度
 * @param level 压缩级别
 * @return Int32 返回值描述
 */
public func mz_compress2_cj(pDest: CPointer<UInt8>, pDest_len: CPointer<MzUlong>, pSource: CPointer<UInt8>, source_len: MzUlong, level: Int32): Int32 {
    return unsafe {
        mz_compress2(pDest, pDest_len, pSource, source_len, level)
    }
}

/**
 * @brief 计算压缩后的上限大小
 * @param source_len 源数据长度
 * @return MzUlong 返回值描述
 */
public func mz_compressBound_cj(source_len: MzUlong): MzUlong {
    return unsafe {
        mz_compressBound(source_len)
    }
}

/**
 * @brief 初始化 inflate 流（zlib 兼容）
 * @param pStream 流指针
 * @return Int32 返回值描述
 */
public func mz_inflateInit_cj(pStream: CPointer<MzStream>): Int32 {
    return unsafe {
        mz_inflateInit(pStream)
    }
}

/**
 * @brief 初始化 inflate 流（高级参数）
 * @param pStream 流指针
 * @param window_bits 窗口位数
 * @return Int32 返回值描述
 */
public func mz_inflateInit2_cj(pStream: CPointer<MzStream>, window_bits: Int32): Int32 {
    return unsafe {
        mz_inflateInit2(pStream, window_bits)
    }
}

/**
 * @brief 重置 inflate 流状态
 * @param pStream 流指针
 * @return Int32 返回值描述
 */
public func mz_inflateReset_cj(pStream: CPointer<MzStream>): Int32 {
    return unsafe {
        mz_inflateReset(pStream)
    }
}

/**
 * @brief 执行 inflate 解压缩
 * @param pStream 流指针
 * @param flush 刷新模式
 * @return Int32 返回值描述
 */
public func mz_inflate_cj(pStream: CPointer<MzStream>, flush: Int32): Int32 {
    return unsafe {
        mz_inflate(pStream, flush)
    }
}

/**
 * @brief 结束 inflate 流，释放资源
 * @param pStream 流指针
 * @return Int32 返回值描述
 */
public func mz_inflateEnd_cj(pStream: CPointer<MzStream>): Int32 {
    return unsafe {
        mz_inflateEnd(pStream)
    }
}

/**
 * @brief 解压缩数据（zlib 兼容）
 * @param pDest 目标缓冲指针
 * @param pDest_len 目标长度指针
 * @param pSource 源数据指针
 * @param source_len 源数据长度
 * @return Int32 返回值描述
 */
public func mz_uncompress_cj(pDest: CPointer<UInt8>, pDest_len: CPointer<MzUlong>, pSource: CPointer<UInt8>, source_len: MzUlong): Int32 {
    return unsafe {
        mz_uncompress(pDest, pDest_len, pSource, source_len)
    }
}

/**
 * @brief 解压缩数据（zlib 兼容，自动计算源大小）
 * @param pDest 目标缓冲指针
 * @param pDest_len 目标长度指针
 * @param pSource 源数据指针
 * @param pSource_len 源数据长度指针
 * @return Int32 返回值描述
 */
public func mz_uncompress2_cj(pDest: CPointer<UInt8>, pDest_len: CPointer<MzUlong>, pSource: CPointer<UInt8>, pSource_len: CPointer<MzUlong>): Int32 {
    return unsafe {
        mz_uncompress2(pDest, pDest_len, pSource, pSource_len)
    }
}

/**
 * @brief 获取错误码对应的错误字符串
 * @param err 错误信息输出
 * @return CString 返回值描述
 */
public func mz_error_cj(err: Int32): CString {
    return unsafe {
        mz_error(err)
    }
}

/**
 * @brief tdefl 压缩内存到堆
 * @param pSrc_buf 源数据指针
 * @param src_buf_len 源数据长度
 * @param pOut_len 输出长度指针
 * @param flags 标志位
 * @return CPointer 返回值描述
 */
public func tdefl_compress_mem_to_heap_cj(pSrc_buf: CPointer<Unit>, src_buf_len: UIntNative, pOut_len: CPointer<UIntNative>, flags: Int32): CPointer<Unit> {
    return unsafe {
        tdefl_compress_mem_to_heap(pSrc_buf, src_buf_len, pOut_len, flags)
    }
}

/**
 * @brief tdefl 压缩内存到内存
 * @param pOut_buf 输出缓冲指针
 * @param out_buf_len 输出缓冲长度
 * @param pSrc_buf 源数据指针
 * @param src_buf_len 源数据长度
 * @param flags 标志位
 * @return UIntNative 返回值描述
 */
public func tdefl_compress_mem_to_mem_cj(pOut_buf: CPointer<Unit>, out_buf_len: UIntNative, pSrc_buf: CPointer<Unit>, src_buf_len: UIntNative, flags: Int32): UIntNative {
    return unsafe {
        tdefl_compress_mem_to_mem(pOut_buf, out_buf_len, pSrc_buf, src_buf_len, flags)
    }
}

/**
 * @brief tdefl 将图像写入 PNG 内存（高级参数）
 * @param pImage 图像数据指针
 * @param w 宽度
 * @param h 高度
 * @param num_chans 通道数量
 * @param pLen_out 输出长度指针
 * @param level 压缩级别
 * @param flip 是否垂直翻转
 * @return CPointer 返回值描述
 */
public func tdefl_write_image_to_png_file_in_memory_ex_cj(pImage: CPointer<Unit>, w: Int32, h: Int32, num_chans: Int32, pLen_out: CPointer<UIntNative>, level: UInt32, flip: Bool): CPointer<Unit> {
    return unsafe {
        tdefl_write_image_to_png_file_in_memory_ex(pImage, w, h, num_chans, pLen_out, level, flip)
    }
}

/**
 * @brief tdefl 将图像写入 PNG 内存
 * @param pImage 图像数据指针
 * @param w 宽度
 * @param h 高度
 * @param num_chans 通道数量
 * @param pLen_out 输出长度指针
 * @return CPointer 返回值描述
 */
public func tdefl_write_image_to_png_file_in_memory_cj(pImage: CPointer<Unit>, w: Int32, h: Int32, num_chans: Int32, pLen_out: CPointer<UIntNative>): CPointer<Unit> {
    return unsafe {
        tdefl_write_image_to_png_file_in_memory(pImage, w, h, num_chans, pLen_out)
    }
}

/**
 * @brief tdefl 压缩内存到输出
 * @param pBuf 数据缓冲指针
 * @param buf_len 缓冲长度
 * @param pPut_buf_func 输出缓冲写入函数
 * @param pPut_buf_user 输出缓冲用户数据
 * @param flags 标志位
 * @return Bool 返回值描述
 */
public func tdefl_compress_mem_to_output_cj(pBuf: CPointer<Unit>, buf_len: UIntNative, pPut_buf_func: TdeflPutBufFuncPtr, pPut_buf_user: CPointer<Unit>, flags: Int32): Bool {
    return unsafe {
        tdefl_compress_mem_to_output(pBuf, buf_len, pPut_buf_func, pPut_buf_user, flags)
    }
}

/**
 * @brief 初始化 tdefl 压缩器
 * @param d 压缩器指针
 * @param pPut_buf_func 输出缓冲写入函数
 * @param pPut_buf_user 输出缓冲用户数据
 * @param flags 标志位
 * @return Int32 返回值描述
 */
public func tdefl_init_cj(d: CPointer<TdeflCompressor>, pPut_buf_func: TdeflPutBufFuncPtr, pPut_buf_user: CPointer<Unit>, flags: Int32): Int32 {
    return unsafe {
        tdefl_init(d, pPut_buf_func, pPut_buf_user, flags)
    }
}

/**
 * @brief tdefl 压缩数据
 * @param d 压缩器指针
 * @param pIn_buf 输入缓冲指针
 * @param pIn_buf_size 输入缓冲大小指针
 * @param pOut_buf 输出缓冲指针
 * @param pOut_buf_size 输出缓冲大小指针
 * @param flush 刷新模式
 * @return Int32 返回值描述
 */
public func tdefl_compress_cj(d: CPointer<TdeflCompressor>, pIn_buf: CPointer<Unit>, pIn_buf_size: CPointer<UIntNative>, pOut_buf: CPointer<Unit>, pOut_buf_size: CPointer<UIntNative>, flush: Int32): Int32 {
    return unsafe {
        tdefl_compress(d, pIn_buf, pIn_buf_size, pOut_buf, pOut_buf_size, flush)
    }
}

/**
 * @brief tdefl 压缩缓冲
 * @param d 压缩器指针
 * @param pIn_buf 输入缓冲指针
 * @param in_buf_size 输入缓冲大小
 * @param flush 刷新模式
 * @return Int32 返回值描述
 */
public func tdefl_compress_buffer_cj(d: CPointer<TdeflCompressor>, pIn_buf: CPointer<Unit>, in_buf_size: UIntNative, flush: Int32): Int32 {
    return unsafe {
        tdefl_compress_buffer(d, pIn_buf, in_buf_size, flush)
    }
}

/**
 * @brief 获取 tdefl 上次返回状态
 * @param d 压缩器指针
 * @return Int32 返回值描述
 */
public func tdefl_get_prev_return_status_cj(d: CPointer<TdeflCompressor>): Int32 {
    return unsafe {
        tdefl_get_prev_return_status(d)
    }
}

/**
 * @brief 获取 tdefl Adler32 校验和
 * @param d 压缩器指针
 * @return UInt32 返回值描述
 */
public func tdefl_get_adler32_cj(d: CPointer<TdeflCompressor>): UInt32 {
    return unsafe {
        tdefl_get_adler32(d)
    }
}

/**
 * @brief 从 ZIP 参数创建 tdefl 压缩标志
 * @param level 压缩级别
 * @param window_bits 窗口位数
 * @param strategy 压缩策略
 * @return UInt32 返回值描述
 */
public func tdefl_create_comp_flags_from_zip_params_cj(level: Int32, window_bits: Int32, strategy: Int32): UInt32 {
    return unsafe {
        tdefl_create_comp_flags_from_zip_params(level, window_bits, strategy)
    }
}

/**
 * @brief 分配 tdefl 压缩器
 * @return CPointer 返回值描述
 */
public func tdefl_compressor_alloc_cj(): CPointer<TdeflCompressor> {
    return unsafe {
        tdefl_compressor_alloc()
    }
}

/**
 * @brief 释放 tdefl 压缩器
 * @param pComp 压缩器指针
 */
public func tdefl_compressor_free_cj(pComp: CPointer<TdeflCompressor>): Unit {
    unsafe {
        tdefl_compressor_free(pComp)
    }
}
