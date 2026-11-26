/**
 * @file bimg 公共函数包装
 * @brief bimg C API 的仓颉安全包装函数
 * @explain 本文件为每个 bimg foreign 函数提供 `_cj` 后缀的公共包装。
 *         所有 foreign 调用被包裹在 unsafe 块中，以满足仓颉 FFI 要求。
 * @note 包括 ImageContainer 字段访问器、图像格式查询、图像编解码、文件读写等。
 */
protected package three._vendor.bgfx4cj.bimg

// =============================================================================
// ImageContainer field accessors
// =============================================================================

/**
 * @brief 获取 ImageContainer 的分配器指针
 * @param _ic 图像容器指针
 * @return CPointer 返回值描述
 */
public func bimg_ic_get_allocator_cj(_ic: CPointer<ImageContainer>): CPointer<BimgAllocator> {
    return unsafe {
        bimg_ic_get_allocator(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的图像数据指针
 * @param _ic 图像容器指针
 * @return CPointer 返回值描述
 */
public func bimg_ic_get_data_cj(_ic: CPointer<ImageContainer>): CPointer<Unit> {
    return unsafe {
        bimg_ic_get_data(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的纹理格式
 * @param _ic 图像容器指针
 * @return UInt32 返回值描述
 */
public func bimg_ic_get_format_cj(_ic: CPointer<ImageContainer>): UInt32 {
    return unsafe {
        bimg_ic_get_format(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的图像朝向
 * @param _ic 图像容器指针
 * @return UInt32 返回值描述
 */
public func bimg_ic_get_orientation_cj(_ic: CPointer<ImageContainer>): UInt32 {
    return unsafe {
        bimg_ic_get_orientation(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的数据大小
 * @param _ic 图像容器指针
 * @return UInt32 返回值描述
 */
public func bimg_ic_get_size_cj(_ic: CPointer<ImageContainer>): UInt32 {
    return unsafe {
        bimg_ic_get_size(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的数据偏移
 * @param _ic 图像容器指针
 * @return UInt32 返回值描述
 */
public func bimg_ic_get_offset_cj(_ic: CPointer<ImageContainer>): UInt32 {
    return unsafe {
        bimg_ic_get_offset(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的图像宽度
 * @param _ic 图像容器指针
 * @return UInt32 返回值描述
 */
public func bimg_ic_get_width_cj(_ic: CPointer<ImageContainer>): UInt32 {
    return unsafe {
        bimg_ic_get_width(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的图像高度
 * @param _ic 图像容器指针
 * @return UInt32 返回值描述
 */
public func bimg_ic_get_height_cj(_ic: CPointer<ImageContainer>): UInt32 {
    return unsafe {
        bimg_ic_get_height(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的图像深度
 * @param _ic 图像容器指针
 * @return UInt32 返回值描述
 */
public func bimg_ic_get_depth_cj(_ic: CPointer<ImageContainer>): UInt32 {
    return unsafe {
        bimg_ic_get_depth(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的图层数量
 * @param _ic 图像容器指针
 * @return UInt16 返回值描述
 */
public func bimg_ic_get_num_layers_cj(_ic: CPointer<ImageContainer>): UInt16 {
    return unsafe {
        bimg_ic_get_num_layers(_ic)
    }
}

/**
 * @brief 获取 ImageContainer 的 mip 等级数量
 * @param _ic 图像容器指针
 * @return UInt8 返回值描述
 */
public func bimg_ic_get_num_mips_cj(_ic: CPointer<ImageContainer>): UInt8 {
    return unsafe {
        bimg_ic_get_num_mips(_ic)
    }
}

/**
 * @brief 检查 ImageContainer 是否包含 alpha 通道
 * @param _ic 图像容器指针
 * @return Bool 返回值描述
 */
public func bimg_ic_get_has_alpha_cj(_ic: CPointer<ImageContainer>): Bool {
    return unsafe {
        bimg_ic_get_has_alpha(_ic)
    }
}

/**
 * @brief 检查 ImageContainer 是否为立方体贴图
 * @param _ic 图像容器指针
 * @return Bool 返回值描述
 */
public func bimg_ic_get_cube_map_cj(_ic: CPointer<ImageContainer>): Bool {
    return unsafe {
        bimg_ic_get_cube_map(_ic)
    }
}

/**
 * @brief 检查 ImageContainer 是否为 KTX 格式
 * @param _ic 图像容器指针
 * @return Bool 返回值描述
 */
public func bimg_ic_get_ktx_cj(_ic: CPointer<ImageContainer>): Bool {
    return unsafe {
        bimg_ic_get_ktx(_ic)
    }
}

/**
 * @brief 检查 ImageContainer 是否为 PVR3 格式
 * @param _ic 图像容器指针
 * @return Bool 返回值描述
 */
public func bimg_ic_get_pvr3_cj(_ic: CPointer<ImageContainer>): Bool {
    return unsafe {
        bimg_ic_get_pvr3(_ic)
    }
}

/**
 * @brief 检查 ImageContainer 是否为 SRGB 格式
 * @param _ic 图像容器指针
 * @return Bool 返回值描述
 */
public func bimg_ic_get_srgb_cj(_ic: CPointer<ImageContainer>): Bool {
    return unsafe {
        bimg_ic_get_srgb(_ic)
    }
}

// =============================================================================
// bimg functions — bimg.h (libbimg.a)
// =============================================================================

/**
 * @brief 检查纹理格式是否为压缩格式
 * @param _format 格式
 * @return Bool 返回值描述
 */
public func bimg_is_compressed_cj(_format: UInt32): Bool {
    return unsafe {
        bimg_is_compressed(_format)
    }
}

/**
 * @brief 检查纹理格式是否为颜色格式
 * @param _format 格式
 * @return Bool 返回值描述
 */
public func bimg_is_color_cj(_format: UInt32): Bool {
    return unsafe {
        bimg_is_color(_format)
    }
}

/**
 * @brief 检查纹理格式是否为深度格式
 * @param _format 格式
 * @return Bool 返回值描述
 */
public func bimg_is_depth_cj(_format: UInt32): Bool {
    return unsafe {
        bimg_is_depth(_format)
    }
}

/**
 * @brief 检查纹理格式是否为有效格式
 * @param _format 格式
 * @return Bool 返回值描述
 */
public func bimg_is_valid_cj(_format: UInt32): Bool {
    return unsafe {
        bimg_is_valid(_format)
    }
}

/**
 * @brief 检查纹理格式是否为浮点格式
 * @param _format 格式
 * @return Bool 返回值描述
 */
public func bimg_is_float_cj(_format: UInt32): Bool {
    return unsafe {
        bimg_is_float(_format)
    }
}

/**
 * @brief 获取纹理格式的每像素位数
 * @param _format 格式
 * @return UInt8 返回值描述
 */
public func bimg_get_bits_per_pixel_cj(_format: UInt32): UInt8 {
    return unsafe {
        bimg_get_bits_per_pixel(_format)
    }
}

/**
 * @brief 获取纹理格式的块信息
 * @param _format 格式
 * @return ImageBlockInfo 返回值描述
 */
public func bimg_get_block_info_cj(_format: UInt32): ImageBlockInfo {
    return unsafe {
        bimg_get_block_info(_format)
    }
}

/**
 * @brief 获取纹理格式的名称字符串
 * @param _format 格式
 * @return CPointer 返回值描述
 */
public func bimg_get_name_cj(_format: UInt32): CPointer<CPointer<UInt8>> {
    return unsafe {
        bimg_get_name(_format)
    }
}

/**
 * @brief 从名称字符串获取纹理格式值
 * @param _name 名称字符串
 * @return UInt32 返回值描述
 */
public func bimg_get_format_cj(_name: CPointer<UInt8>): UInt32 {
    return unsafe {
        bimg_get_format(_name)
    }
}

/**
 * @brief 计算图像的 mip 等级数量
 * @param _format 格式
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @return UInt8 返回值描述
 */
public func bimg_image_get_num_mips_cj(_format: UInt32, _width: UInt16, _height: UInt16, _depth: UInt16): UInt8 {
    return unsafe {
        bimg_image_get_num_mips(_format, _width, _height, _depth)
    }
}

/**
 * @brief 计算图像尺寸信息
 * @param _info 信息结构体指针
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _cubeMap 是否为立方体贴图
 * @param _hasMips 是否有 Mip
 * @param _numLayers 图层数量
 * @param _format 格式
 * @return UInt32 返回值描述
 */
public func bimg_image_get_size_cj(_info: CPointer<TextureInfo>, _width: UInt16, _height: UInt16, _depth: UInt16, _cubeMap: Bool, _hasMips: Bool, _numLayers: UInt16, _format: UInt32): UInt32 {
    return unsafe {
        bimg_image_get_size(_info, _width, _height, _depth, _cubeMap, _hasMips, _numLayers, _format)
    }
}

/**
 * @brief 生成纯色图像
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _solid 填充颜色值
 */
public func bimg_image_solid_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _solid: UInt32): Unit {
    unsafe {
        bimg_image_solid(_dst, _width, _height, _solid)
    }
}

/**
 * @brief 生成棋盘格图像
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _step 步长
 * @param _0 颜色 0
 * @param _1 颜色 1
 */
public func bimg_image_checkerboard_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _step: UInt32, _0: UInt32, _1: UInt32): Unit {
    unsafe {
        bimg_image_checkerboard(_dst, _width, _height, _step, _0, _1)
    }
}

/**
 * @brief RGBA8 图像 2x2 降采样
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _srcPitch 源行步长
 * @param _dstPitch 目标行步长
 * @param _src 源缓冲
 */
public func bimg_image_rgba8_downsample2x2_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _dstPitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_rgba8_downsample2x2(_dst, _width, _height, _depth, _srcPitch, _dstPitch, _src)
    }
}

/**
 * @brief RGBA32F 图像转线性空间
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 */
public func bimg_image_rgba32f_to_linear_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_rgba32f_to_linear(_dst, _width, _height, _depth, _srcPitch, _src)
    }
}

/**
 * @brief ImageContainer 整体转线性空间
 * @param _imageContainer 图像容器指针
 */
public func bimg_image_rgba32f_to_linear_ic_cj(_imageContainer: CPointer<ImageContainer>): Unit {
    unsafe {
        bimg_image_rgba32f_to_linear_ic(_imageContainer)
    }
}

/**
 * @brief RGBA32F 图像转 Gamma 空间
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 */
public func bimg_image_rgba32f_to_gamma_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_rgba32f_to_gamma(_dst, _width, _height, _depth, _srcPitch, _src)
    }
}

/**
 * @brief ImageContainer 整体转 Gamma 空间
 * @param _imageContainer 图像容器指针
 */
public func bimg_image_rgba32f_to_gamma_ic_cj(_imageContainer: CPointer<ImageContainer>): Unit {
    unsafe {
        bimg_image_rgba32f_to_gamma_ic(_imageContainer)
    }
}

/**
 * @brief RGBA32F 线性图像 2x2 降采样
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 */
public func bimg_image_rgba32f_linear_downsample2x2_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_rgba32f_linear_downsample2x2(_dst, _width, _height, _depth, _srcPitch, _src)
    }
}

/**
 * @brief RGBA32F 图像 2x2 降采样
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 */
public func bimg_image_rgba32f_downsample2x2_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_rgba32f_downsample2x2(_dst, _width, _height, _depth, _srcPitch, _src)
    }
}

/**
 * @brief RGBA32F 法线贴图 2x2 降采样
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _srcPitch 源行步长
 * @param _dstPitch 目标行步长
 * @param _src 源缓冲
 */
public func bimg_image_rgba32f_downsample2x2_normal_map_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _dstPitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_rgba32f_downsample2x2_normal_map(_dst, _width, _height, _srcPitch, _dstPitch, _src)
    }
}

/**
 * @brief BGRA8 图像通道重排
 * @param _dst 目标缓冲
 * @param _dstPitch 目标行步长
 * @param _width 宽度
 * @param _height 高度
 * @param _src 源缓冲
 * @param _srcPitch 源行步长
 */
public func bimg_image_swizzle_bgra8_cj(_dst: CPointer<Unit>, _dstPitch: UInt32, _width: UInt32, _height: UInt32, _src: CPointer<Unit>, _srcPitch: UInt32): Unit {
    unsafe {
        bimg_image_swizzle_bgra8(_dst, _dstPitch, _width, _height, _src, _srcPitch)
    }
}

/**
 * @brief 图像拷贝
 * @param _dst 目标缓冲
 * @param _height 高度
 * @param _srcPitch 源行步长
 * @param _depth 深度值
 * @param _src 源缓冲
 * @param _dstPitch 目标行步长
 */
public func bimg_image_copy_cj(_dst: CPointer<Unit>, _height: UInt32, _srcPitch: UInt32, _depth: UInt32, _src: CPointer<Unit>, _dstPitch: UInt32): Unit {
    unsafe {
        bimg_image_copy(_dst, _height, _srcPitch, _depth, _src, _dstPitch)
    }
}

/**
 * @brief 按每像素位数拷贝图像
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _bpp 每像素位数
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 */
public func bimg_image_copy_bpp_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _bpp: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_copy_bpp(_dst, _width, _height, _depth, _bpp, _srcPitch, _src)
    }
}

/**
 * @brief 检查图像格式转换是否支持
 * @param _dstFormat 目标格式
 * @param _srcFormat 源格式
 * @return Bool 返回值描述
 */
public func bimg_image_convert_cj(_dstFormat: UInt32, _srcFormat: UInt32): Bool {
    return unsafe {
        bimg_image_convert(_dstFormat, _srcFormat)
    }
}

/**
 * @brief 原始图像格式转换
 * @param _dst 目标缓冲
 * @param _bpp 每像素位数
 * @param _packFn 打包函数指针
 * @param _src 源缓冲
 * @param _unpackFn 解包函数指针
 * @param _size 大小（字节）
 */
public func bimg_image_convert_raw_cj(_dst: CPointer<Unit>, _bpp: UInt32, _packFn: CPointer<Unit>, _src: CPointer<Unit>, _unpackFn: CPointer<Unit>, _size: UInt32): Unit {
    unsafe {
        bimg_image_convert_raw(_dst, _bpp, _packFn, _src, _unpackFn, _size)
    }
}

/**
 * @brief 带尺寸参数的图像格式转换
 * @param _dst 目标缓冲
 * @param _dstBpp 目标每像素位数
 * @param _packFn 打包函数指针
 * @param _src 源缓冲
 * @param _srcBpp 源每像素位数
 * @param _unpackFn 解包函数指针
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _srcPitch 源行步长
 * @param _dstPitch 目标行步长
 */
public func bimg_image_convert_dims_cj(_dst: CPointer<Unit>, _dstBpp: UInt32, _packFn: CPointer<Unit>, _src: CPointer<Unit>, _srcBpp: UInt32, _unpackFn: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _dstPitch: UInt32): Unit {
    unsafe {
        bimg_image_convert_dims(_dst, _dstBpp, _packFn, _src, _srcBpp, _unpackFn, _width, _height, _depth, _srcPitch, _dstPitch)
    }
}

/**
 * @brief 分配并转换图像格式
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _dstFormat 目标格式
 * @param _src 源缓冲
 * @param _srcFormat 源格式
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @return Bool 返回值描述
 */
public func bimg_image_convert_alloc_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _dstFormat: UInt32, _src: CPointer<Unit>, _srcFormat: UInt32, _width: UInt32, _height: UInt32, _depth: UInt32): Bool {
    return unsafe {
        bimg_image_convert_alloc(_allocator, _dst, _dstFormat, _src, _srcFormat, _width, _height, _depth)
    }
}

/**
 * @brief 分配 ImageContainer
 * @param _allocator 分配器指针
 * @param _format 格式
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _numLayers 图层数量
 * @param _cubeMap 是否为立方体贴图
 * @param _hasMips 是否有 Mip
 * @param _data 数据指针
 * @return CPointer 返回值描述
 */
public func bimg_image_alloc_cj(_allocator: CPointer<BimgAllocator>, _format: UInt32, _width: UInt16, _height: UInt16, _depth: UInt16, _numLayers: UInt16, _cubeMap: Bool, _hasMips: Bool, _data: CPointer<Unit>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_alloc(_allocator, _format, _width, _height, _depth, _numLayers, _cubeMap, _hasMips, _data)
    }
}

/**
 * @brief 释放 ImageContainer
 * @param _imageContainer 图像容器指针
 */
public func bimg_image_free_cj(_imageContainer: CPointer<ImageContainer>): Unit {
    unsafe {
        bimg_image_free(_imageContainer)
    }
}

/**
 * @brief 写入 TGA 格式图像
 * @param _writer 写入器指针
 * @param _width 宽度
 * @param _height 高度
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 * @param _grayscale 是否灰度
 * @param _yflip yflip
 * @param _err 错误信息输出
 * @return Int32 返回值描述
 */
public func bimg_image_write_tga_cj(_writer: CPointer<BimgWriter>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _grayscale: Bool, _yflip: Bool, _err: CPointer<BimgError>): Int32 {
    return unsafe {
        bimg_image_write_tga(_writer, _width, _height, _srcPitch, _src, _grayscale, _yflip, _err)
    }
}

/**
 * @brief 写入 PNG 格式图像
 * @param _writer 写入器指针
 * @param _width 宽度
 * @param _height 高度
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 * @param _format 格式
 * @param _yflip yflip
 * @param _err 错误信息输出
 * @return Int32 返回值描述
 */
public func bimg_image_write_png_cj(_writer: CPointer<BimgWriter>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _format: UInt32, _yflip: Bool, _err: CPointer<BimgError>): Int32 {
    return unsafe {
        bimg_image_write_png(_writer, _width, _height, _srcPitch, _src, _format, _yflip, _err)
    }
}

/**
 * @brief 写入 EXR 格式图像
 * @param _writer 写入器指针
 * @param _width 宽度
 * @param _height 高度
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 * @param _format 格式
 * @param _yflip yflip
 * @param _err 错误信息输出
 * @return Int32 返回值描述
 */
public func bimg_image_write_exr_cj(_writer: CPointer<BimgWriter>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _format: UInt32, _yflip: Bool, _err: CPointer<BimgError>): Int32 {
    return unsafe {
        bimg_image_write_exr(_writer, _width, _height, _srcPitch, _src, _format, _yflip, _err)
    }
}

/**
 * @brief 写入 DDS 格式图像
 * @param _writer 写入器指针
 * @param _imageContainer 图像容器指针
 * @param _data 数据指针
 * @param _size 大小（字节）
 * @param _err 错误信息输出
 * @return Int32 返回值描述
 */
public func bimg_image_write_dds_cj(_writer: CPointer<BimgWriter>, _imageContainer: CPointer<ImageContainer>, _data: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): Int32 {
    return unsafe {
        bimg_image_write_dds(_writer, _imageContainer, _data, _size, _err)
    }
}

/**
 * @brief 写入 KTX 格式图像
 * @param _writer 写入器指针
 * @param _format 格式
 * @param _cubeMap 是否为立方体贴图
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _numMips Mip 数量
 * @param _numLayers 图层数量
 * @param _srgb 是否 SRGB
 * @param _src 源缓冲
 * @param _err 错误信息输出
 * @return Int32 返回值描述
 */
public func bimg_image_write_ktx_cj(_writer: CPointer<BimgWriter>, _format: UInt32, _cubeMap: Bool, _width: UInt32, _height: UInt32, _depth: UInt32, _numMips: UInt8, _numLayers: UInt32, _srgb: Bool, _src: CPointer<Unit>, _err: CPointer<BimgError>): Int32 {
    return unsafe {
        bimg_image_write_ktx(_writer, _format, _cubeMap, _width, _height, _depth, _numMips, _numLayers, _srgb, _src, _err)
    }
}

/**
 * @brief 写入 KTX 格式（从 ImageContainer）
 * @param _writer 写入器指针
 * @param _imageContainer 图像容器指针
 * @param _data 数据指针
 * @param _size 大小（字节）
 * @param _err 错误信息输出
 * @return Int32 返回值描述
 */
public func bimg_image_write_ktx_ic_cj(_writer: CPointer<BimgWriter>, _imageContainer: CPointer<ImageContainer>, _data: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): Int32 {
    return unsafe {
        bimg_image_write_ktx_ic(_writer, _imageContainer, _data, _size, _err)
    }
}

/**
 * @brief 从 ReaderSeeker 解析图像
 * @param _imageContainer 图像容器指针
 * @param _reader 读取器指针
 * @param _err 错误信息输出
 * @return Bool 返回值描述
 */
public func bimg_image_parse_reader_cj(_imageContainer: CPointer<ImageContainer>, _reader: CPointer<BimgReaderSeeker>, _err: CPointer<BimgError>): Bool {
    return unsafe {
        bimg_image_parse_reader(_imageContainer, _reader, _err)
    }
}

/**
 * @brief 从内存解析图像
 * @param _imageContainer 图像容器指针
 * @param _data 数据指针
 * @param _size 大小（字节）
 * @param _err 错误信息输出
 * @return Bool 返回值描述
 */
public func bimg_image_parse_mem_cj(_imageContainer: CPointer<ImageContainer>, _data: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): Bool {
    return unsafe {
        bimg_image_parse_mem(_imageContainer, _data, _size, _err)
    }
}

/**
 * @brief 解析 DDS 格式图像
 * @param _allocator 分配器指针
 * @param _src 源缓冲
 * @param _size 大小（字节）
 * @param _err 错误信息输出
 * @return CPointer 返回值描述
 */
public func bimg_image_parse_dds_cj(_allocator: CPointer<BimgAllocator>, _src: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_parse_dds(_allocator, _src, _size, _err)
    }
}

/**
 * @brief 解析 KTX 格式图像
 * @param _allocator 分配器指针
 * @param _src 源缓冲
 * @param _size 大小（字节）
 * @param _err 错误信息输出
 * @return CPointer 返回值描述
 */
public func bimg_image_parse_ktx_cj(_allocator: CPointer<BimgAllocator>, _src: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_parse_ktx(_allocator, _src, _size, _err)
    }
}

/**
 * @brief 解析 PVR3 格式图像
 * @param _allocator 分配器指针
 * @param _src 源缓冲
 * @param _size 大小（字节）
 * @param _err 错误信息输出
 * @return CPointer 返回值描述
 */
public func bimg_image_parse_pvr3_cj(_allocator: CPointer<BimgAllocator>, _src: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_parse_pvr3(_allocator, _src, _size, _err)
    }
}

/**
 * @brief 解码图像到 R8 格式
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _src 源缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _dstPitch 目标行步长
 * @param _srcFormat 源格式
 */
public func bimg_image_decode_to_r8_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _dstPitch: UInt32, _srcFormat: UInt32): Unit {
    unsafe {
        bimg_image_decode_to_r8(_allocator, _dst, _src, _width, _height, _depth, _dstPitch, _srcFormat)
    }
}

/**
 * @brief 解码图像到 BGRA8 格式
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _src 源缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _dstPitch 目标行步长
 * @param _format 格式
 */
public func bimg_image_decode_to_bgra8_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _dstPitch: UInt32, _format: UInt32): Unit {
    unsafe {
        bimg_image_decode_to_bgra8(_allocator, _dst, _src, _width, _height, _dstPitch, _format)
    }
}

/**
 * @brief 解码图像到 RGBA8 格式
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _src 源缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _dstPitch 目标行步长
 * @param _format 格式
 */
public func bimg_image_decode_to_rgba8_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _dstPitch: UInt32, _format: UInt32): Unit {
    unsafe {
        bimg_image_decode_to_rgba8(_allocator, _dst, _src, _width, _height, _dstPitch, _format)
    }
}

/**
 * @brief 解码图像到 RGBA32F 格式
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _src 源缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _dstPitch 目标行步长
 * @param _format 格式
 */
public func bimg_image_decode_to_rgba32f_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _dstPitch: UInt32, _format: UInt32): Unit {
    unsafe {
        bimg_image_decode_to_rgba32f(_allocator, _dst, _src, _width, _height, _depth, _dstPitch, _format)
    }
}

/**
 * @brief 获取图像原始数据
 * @param _imageContainer 图像容器指针
 * @param _side 立方体贴图面
 * @param _lod LOD 等级
 * @param _data 数据指针
 * @param _size 大小（字节）
 * @param _mip Mip 等级
 * @return Bool 返回值描述
 */
public func bimg_image_get_raw_data_cj(_imageContainer: CPointer<ImageContainer>, _side: UInt16, _lod: UInt8, _data: CPointer<Unit>, _size: UInt32, _mip: CPointer<ImageMip>): Bool {
    return unsafe {
        bimg_image_get_raw_data(_imageContainer, _side, _lod, _data, _size, _mip)
    }
}

// =============================================================================
// bimg functions — encode.h (libbimg_encode.a)
// =============================================================================

/**
 * @brief 从 RGBA8 编码图像
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _src 源缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _format 格式
 * @param _quality 编码质量
 * @param _err 错误信息输出
 */
public func bimg_image_encode_from_rgba8_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _format: UInt32, _quality: UInt32, _err: CPointer<BimgError>): Unit {
    unsafe {
        bimg_image_encode_from_rgba8(_allocator, _dst, _src, _width, _height, _depth, _format, _quality, _err)
    }
}

/**
 * @brief 从 RGBA32F 编码图像
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _src 源缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _format 格式
 * @param _quality 编码质量
 * @param _err 错误信息输出
 */
public func bimg_image_encode_from_rgba32f_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _format: UInt32, _quality: UInt32, _err: CPointer<BimgError>): Unit {
    unsafe {
        bimg_image_encode_from_rgba32f(_allocator, _dst, _src, _width, _height, _depth, _format, _quality, _err)
    }
}

/**
 * @brief 编码图像格式转换
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _src 源缓冲
 * @param _srcFormat 源格式
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _dstFormat 目标格式
 * @param _quality 编码质量
 * @param _err 错误信息输出
 */
public func bimg_image_encode_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _srcFormat: UInt32, _width: UInt32, _height: UInt32, _depth: UInt32, _dstFormat: UInt32, _quality: UInt32, _err: CPointer<BimgError>): Unit {
    unsafe {
        bimg_image_encode(_allocator, _dst, _src, _srcFormat, _width, _height, _depth, _dstFormat, _quality, _err)
    }
}

/**
 * @brief 编码 ImageContainer 格式转换
 * @param _allocator 分配器指针
 * @param _dstFormat 目标格式
 * @param _quality 编码质量
 * @param _input 输入数据
 * @return CPointer 返回值描述
 */
public func bimg_image_encode_ic_cj(_allocator: CPointer<BimgAllocator>, _dstFormat: UInt32, _quality: UInt32, _input: CPointer<ImageContainer>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_encode_ic(_allocator, _dstFormat, _quality, _input)
    }
}

/**
 * @brief RGBA32F [-1,1] 转 [0,1]
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _depth 深度值
 * @param _pitch 行步长
 * @param _src 源缓冲
 */
public func bimg_image_rgba32f_11to01_cj(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _pitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_rgba32f_11to01(_dst, _width, _height, _depth, _pitch, _src)
    }
}

/**
 * @brief 生成距离场图像
 * @param _allocator 分配器指针
 * @param _dst 目标缓冲
 * @param _width 宽度
 * @param _height 高度
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 */
public func bimg_image_make_dist_cj(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit {
    unsafe {
        bimg_image_make_dist(_allocator, _dst, _width, _height, _srcPitch, _src)
    }
}

/**
 * @brief 评估 RGBA8 图像质量
 * @param _reference 参考图像数据
 * @param _data 数据指针
 * @param _width 宽度
 * @param _height 高度
 * @return Float32 返回值描述
 */
public func bimg_image_quality_rgba8_cj(_reference: CPointer<Unit>, _data: CPointer<Unit>, _width: UInt16, _height: UInt16): Float32 {
    return unsafe {
        bimg_image_quality_rgba8(_reference, _data, _width, _height)
    }
}

/**
 * @brief RGBA32F 线性缩放
 * @param _dst 目标缓冲
 * @param _src 源缓冲
 * @return Bool 返回值描述
 */
public func bimg_image_resize_rgba32f_linear_cj(_dst: CPointer<ImageContainer>, _src: CPointer<ImageContainer>): Bool {
    return unsafe {
        bimg_image_resize_rgba32f_linear(_dst, _src)
    }
}

/**
 * @brief Alpha 测试覆盖测试
 * @param _format 格式
 * @param _width 宽度
 * @param _height 高度
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 * @param _alphaRef Alpha 参考值
 * @param _scale 缩放因子
 * @param _upscale 上采样倍数
 * @return Float32 返回值描述
 */
public func bimg_image_alpha_test_coverage_cj(_format: UInt32, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _alphaRef: Float32, _scale: Float32, _upscale: UInt32): Float32 {
    return unsafe {
        bimg_image_alpha_test_coverage(_format, _width, _height, _srcPitch, _src, _alphaRef, _scale, _upscale)
    }
}

/**
 * @brief Alpha 覆盖缩放
 * @param _format 格式
 * @param _width 宽度
 * @param _height 高度
 * @param _srcPitch 源行步长
 * @param _src 源缓冲
 * @param _coverage 覆盖值
 * @param _alphaRef Alpha 参考值
 * @param _upscale 上采样倍数
 */
public func bimg_image_scale_alpha_to_coverage_cj(_format: UInt32, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _coverage: Float32, _alphaRef: Float32, _upscale: UInt32): Unit {
    unsafe {
        bimg_image_scale_alpha_to_coverage(_format, _width, _height, _srcPitch, _src, _coverage, _alphaRef, _upscale)
    }
}

/**
 * @brief 从经纬图生成立方体贴图
 * @param _allocator 分配器指针
 * @param _input 输入数据
 * @param _useBilinearInterpolation 使用双线性插值
 * @param _err 错误信息输出
 * @return CPointer 返回值描述
 */
public func bimg_image_cubemap_from_latlong_rgba32f_cj(_allocator: CPointer<BimgAllocator>, _input: CPointer<ImageContainer>, _useBilinearInterpolation: Bool, _err: CPointer<BimgError>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_cubemap_from_latlong_rgba32f(_allocator, _input, _useBilinearInterpolation, _err)
    }
}

/**
 * @brief 从条带图生成立方体贴图
 * @param _allocator 分配器指针
 * @param _input 输入数据
 * @param _err 错误信息输出
 * @return CPointer 返回值描述
 */
public func bimg_image_cubemap_from_strip_rgba32f_cj(_allocator: CPointer<BimgAllocator>, _input: CPointer<ImageContainer>, _err: CPointer<BimgError>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_cubemap_from_strip_rgba32f(_allocator, _input, _err)
    }
}

/**
 * @brief 生成 Mip 链
 * @param _allocator 分配器指针
 * @param _image 图像指针
 * @return CPointer 返回值描述
 */
public func bimg_image_generate_mips_cj(_allocator: CPointer<BimgAllocator>, _image: CPointer<ImageContainer>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_generate_mips(_allocator, _image)
    }
}

/**
 * @brief 立方体贴图辐射度滤波
 * @param _allocator 分配器指针
 * @param _image 图像指针
 * @param _lightingModel 光照模型
 * @param _err 错误信息输出
 * @return CPointer 返回值描述
 */
public func bimg_image_cubemap_radiance_filter_cj(_allocator: CPointer<BimgAllocator>, _image: CPointer<ImageContainer>, _lightingModel: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_cubemap_radiance_filter(_allocator, _image, _lightingModel, _err)
    }
}

// =============================================================================
// bimg functions — decode.h (libbimg_decode.a)
// =============================================================================

/**
 * @brief 解析并解码图像
 * @param _allocator 分配器指针
 * @param _data 数据指针
 * @param _size 大小（字节）
 * @param _dstFormat 目标格式
 * @param _err 错误信息输出
 * @return CPointer 返回值描述
 */
public func bimg_image_parse_decode_cj(_allocator: CPointer<BimgAllocator>, _data: CPointer<Unit>, _size: UInt32, _dstFormat: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer> {
    return unsafe {
        bimg_image_parse_decode(_allocator, _data, _size, _dstFormat, _err)
    }
}

/**
 * @brief 获取默认的 bx AllocatorI 指针
 * @return CPointer 默认分配器指针
 */
public func bimg_get_default_allocator_cj(): CPointer<BimgAllocator> {
    return unsafe {
        bimg_get_default_allocator()
    }
}
