/**
 * @file bimg CFFI 函数声明
 * @brief bimg C API 的所有 foreign 函数声明
 * @explain 本文件包含 bimg 图像库的 CFFI 绑定，包括 ImageContainer 字段访问器、
 *         bimg.h 核心函数、encode.h 编码函数和 decode.h 解码函数。
 * @note ImageContainer 为不透明指针，字段通过 `bimg_ic_get_*` 函数访问。
 * @link libs/libbimg_capi.a libs/libbimg.a libs/libbimg_encode.a libs/libbimg_decode.a
 */
protected package three._vendor.bgfx4cj.bimg

// =============================================================================
// ImageContainer field accessors
// =============================================================================

foreign func bimg_ic_get_allocator(_ic: CPointer<ImageContainer>): CPointer<BimgAllocator>

foreign func bimg_ic_get_data(_ic: CPointer<ImageContainer>): CPointer<Unit>

foreign func bimg_ic_get_format(_ic: CPointer<ImageContainer>): UInt32

foreign func bimg_ic_get_orientation(_ic: CPointer<ImageContainer>): UInt32

foreign func bimg_ic_get_size(_ic: CPointer<ImageContainer>): UInt32

foreign func bimg_ic_get_offset(_ic: CPointer<ImageContainer>): UInt32

foreign func bimg_ic_get_width(_ic: CPointer<ImageContainer>): UInt32

foreign func bimg_ic_get_height(_ic: CPointer<ImageContainer>): UInt32

foreign func bimg_ic_get_depth(_ic: CPointer<ImageContainer>): UInt32

foreign func bimg_ic_get_num_layers(_ic: CPointer<ImageContainer>): UInt16

foreign func bimg_ic_get_num_mips(_ic: CPointer<ImageContainer>): UInt8

foreign func bimg_ic_get_has_alpha(_ic: CPointer<ImageContainer>): Bool

foreign func bimg_ic_get_cube_map(_ic: CPointer<ImageContainer>): Bool

foreign func bimg_ic_get_ktx(_ic: CPointer<ImageContainer>): Bool

foreign func bimg_ic_get_pvr3(_ic: CPointer<ImageContainer>): Bool

foreign func bimg_ic_get_srgb(_ic: CPointer<ImageContainer>): Bool

// =============================================================================
// bimg functions — bimg.h (libbimg.a)
// =============================================================================

foreign func bimg_is_compressed(_format: UInt32): Bool

foreign func bimg_is_color(_format: UInt32): Bool

foreign func bimg_is_depth(_format: UInt32): Bool

foreign func bimg_is_valid(_format: UInt32): Bool

foreign func bimg_is_float(_format: UInt32): Bool

foreign func bimg_get_bits_per_pixel(_format: UInt32): UInt8

foreign func bimg_get_block_info(_format: UInt32): ImageBlockInfo

foreign func bimg_get_name(_format: UInt32): CPointer<CPointer<UInt8>>

foreign func bimg_get_format(_name: CPointer<UInt8>): UInt32

foreign func bimg_image_get_num_mips(_format: UInt32, _width: UInt16, _height: UInt16, _depth: UInt16): UInt8

foreign func bimg_image_get_size(_info: CPointer<TextureInfo>, _width: UInt16, _height: UInt16, _depth: UInt16, _cubeMap: Bool, _hasMips: Bool, _numLayers: UInt16, _format: UInt32): UInt32

foreign func bimg_image_solid(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _solid: UInt32): Unit

foreign func bimg_image_checkerboard(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _step: UInt32, _0: UInt32, _1: UInt32): Unit

foreign func bimg_image_rgba8_downsample2x2(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _dstPitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_rgba32f_to_linear(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_rgba32f_to_linear_ic(_imageContainer: CPointer<ImageContainer>): Unit

foreign func bimg_image_rgba32f_to_gamma(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_rgba32f_to_gamma_ic(_imageContainer: CPointer<ImageContainer>): Unit

foreign func bimg_image_rgba32f_linear_downsample2x2(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_rgba32f_downsample2x2(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_rgba32f_downsample2x2_normal_map(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _dstPitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_swizzle_bgra8(_dst: CPointer<Unit>, _dstPitch: UInt32, _width: UInt32, _height: UInt32, _src: CPointer<Unit>, _srcPitch: UInt32): Unit

foreign func bimg_image_copy(_dst: CPointer<Unit>, _height: UInt32, _srcPitch: UInt32, _depth: UInt32, _src: CPointer<Unit>, _dstPitch: UInt32): Unit

foreign func bimg_image_copy_bpp(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _bpp: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_convert(_dstFormat: UInt32, _srcFormat: UInt32): Bool

foreign func bimg_image_convert_raw(_dst: CPointer<Unit>, _bpp: UInt32, _packFn: CPointer<Unit>, _src: CPointer<Unit>, _unpackFn: CPointer<Unit>, _size: UInt32): Unit

foreign func bimg_image_convert_dims(_dst: CPointer<Unit>, _dstBpp: UInt32, _packFn: CPointer<Unit>, _src: CPointer<Unit>, _srcBpp: UInt32, _unpackFn: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _srcPitch: UInt32, _dstPitch: UInt32): Unit

foreign func bimg_image_convert_alloc(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _dstFormat: UInt32, _src: CPointer<Unit>, _srcFormat: UInt32, _width: UInt32, _height: UInt32, _depth: UInt32): Bool

foreign func bimg_image_alloc(_allocator: CPointer<BimgAllocator>, _format: UInt32, _width: UInt16, _height: UInt16, _depth: UInt16, _numLayers: UInt16, _cubeMap: Bool, _hasMips: Bool, _data: CPointer<Unit>): CPointer<ImageContainer>

foreign func bimg_image_free(_imageContainer: CPointer<ImageContainer>): Unit

foreign func bimg_image_write_tga(_writer: CPointer<BimgWriter>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _grayscale: Bool, _yflip: Bool, _err: CPointer<BimgError>): Int32

foreign func bimg_image_write_png(_writer: CPointer<BimgWriter>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _format: UInt32, _yflip: Bool, _err: CPointer<BimgError>): Int32

foreign func bimg_image_write_exr(_writer: CPointer<BimgWriter>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _format: UInt32, _yflip: Bool, _err: CPointer<BimgError>): Int32

foreign func bimg_image_write_dds(_writer: CPointer<BimgWriter>, _imageContainer: CPointer<ImageContainer>, _data: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): Int32

foreign func bimg_image_write_ktx(_writer: CPointer<BimgWriter>, _format: UInt32, _cubeMap: Bool, _width: UInt32, _height: UInt32, _depth: UInt32, _numMips: UInt8, _numLayers: UInt32, _srgb: Bool, _src: CPointer<Unit>, _err: CPointer<BimgError>): Int32

foreign func bimg_image_write_ktx_ic(_writer: CPointer<BimgWriter>, _imageContainer: CPointer<ImageContainer>, _data: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): Int32

foreign func bimg_image_parse_reader(_imageContainer: CPointer<ImageContainer>, _reader: CPointer<BimgReaderSeeker>, _err: CPointer<BimgError>): Bool

foreign func bimg_image_parse_mem(_imageContainer: CPointer<ImageContainer>, _data: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): Bool

foreign func bimg_image_parse_dds(_allocator: CPointer<BimgAllocator>, _src: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer>

foreign func bimg_image_parse_ktx(_allocator: CPointer<BimgAllocator>, _src: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer>

foreign func bimg_image_parse_pvr3(_allocator: CPointer<BimgAllocator>, _src: CPointer<Unit>, _size: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer>

foreign func bimg_image_decode_to_r8(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _dstPitch: UInt32, _srcFormat: UInt32): Unit

foreign func bimg_image_decode_to_bgra8(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _dstPitch: UInt32, _format: UInt32): Unit

foreign func bimg_image_decode_to_rgba8(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _dstPitch: UInt32, _format: UInt32): Unit

foreign func bimg_image_decode_to_rgba32f(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _dstPitch: UInt32, _format: UInt32): Unit

foreign func bimg_image_get_raw_data(_imageContainer: CPointer<ImageContainer>, _side: UInt16, _lod: UInt8, _data: CPointer<Unit>, _size: UInt32, _mip: CPointer<ImageMip>): Bool

// =============================================================================
// bimg functions — encode.h (libbimg_encode.a)
// =============================================================================

foreign func bimg_image_encode_from_rgba8(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _format: UInt32, _quality: UInt32, _err: CPointer<BimgError>): Unit

foreign func bimg_image_encode_from_rgba32f(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _format: UInt32, _quality: UInt32, _err: CPointer<BimgError>): Unit

foreign func bimg_image_encode(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _src: CPointer<Unit>, _srcFormat: UInt32, _width: UInt32, _height: UInt32, _depth: UInt32, _dstFormat: UInt32, _quality: UInt32, _err: CPointer<BimgError>): Unit

foreign func bimg_image_encode_ic(_allocator: CPointer<BimgAllocator>, _dstFormat: UInt32, _quality: UInt32, _input: CPointer<ImageContainer>): CPointer<ImageContainer>

foreign func bimg_image_rgba32f_11to01(_dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _depth: UInt32, _pitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_make_dist(_allocator: CPointer<BimgAllocator>, _dst: CPointer<Unit>, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>): Unit

foreign func bimg_image_quality_rgba8(_reference: CPointer<Unit>, _data: CPointer<Unit>, _width: UInt16, _height: UInt16): Float32

foreign func bimg_image_resize_rgba32f_linear(_dst: CPointer<ImageContainer>, _src: CPointer<ImageContainer>): Bool

foreign func bimg_image_alpha_test_coverage(_format: UInt32, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _alphaRef: Float32, _scale: Float32, _upscale: UInt32): Float32

foreign func bimg_image_scale_alpha_to_coverage(_format: UInt32, _width: UInt32, _height: UInt32, _srcPitch: UInt32, _src: CPointer<Unit>, _coverage: Float32, _alphaRef: Float32, _upscale: UInt32): Unit

foreign func bimg_image_cubemap_from_latlong_rgba32f(_allocator: CPointer<BimgAllocator>, _input: CPointer<ImageContainer>, _useBilinearInterpolation: Bool, _err: CPointer<BimgError>): CPointer<ImageContainer>

foreign func bimg_image_cubemap_from_strip_rgba32f(_allocator: CPointer<BimgAllocator>, _input: CPointer<ImageContainer>, _err: CPointer<BimgError>): CPointer<ImageContainer>

foreign func bimg_image_generate_mips(_allocator: CPointer<BimgAllocator>, _image: CPointer<ImageContainer>): CPointer<ImageContainer>

foreign func bimg_image_cubemap_radiance_filter(_allocator: CPointer<BimgAllocator>, _image: CPointer<ImageContainer>, _lightingModel: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer>

// =============================================================================
// bimg functions — decode.h (libbimg_decode.a)
// =============================================================================

foreign func bimg_image_parse_decode(_allocator: CPointer<BimgAllocator>, _data: CPointer<Unit>, _size: UInt32, _dstFormat: UInt32, _err: CPointer<BimgError>): CPointer<ImageContainer>

foreign func bimg_get_default_allocator(): CPointer<BimgAllocator>
