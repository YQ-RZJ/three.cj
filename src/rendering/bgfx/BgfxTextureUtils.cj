/**
 * @file[zh-cn] bgfx 纹理工具
 * @brief[zh-cn] 对照 WebGLTextureUtils.js，纹理操作工具（mipmap 生成、格式转换）
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLTextureUtils.js
 *
 * @file[en] bgfx Texture Utils
 * @brief[en] Corresponds to WebGLTextureUtils.js, texture utility operations (mipmap generation, format conversion)
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLTextureUtils.js
 */
package three.rendering.bgfx

/**
 * @brief[zh-cn] bgfx 纹理工具
 * @explain[zh-cn] 对照 WebGLTextureUtils，提供纹理格式转换和 mipmap 生成等工具方法
 *
 * @brief[en] bgfx texture utilities
 * @explain[en] Corresponds to WebGLTextureUtils, provides texture format conversion and mipmap generation utility methods
 */
public class BgfxTextureUtils {
    /**
     * @brief[zh-cn] 格式转换工具
     *
     * @brief[en] Format conversion utility
     */
    private var bgfxUtils: BgfxUtils

    public init(bgfxUtils!: BgfxUtils = BgfxUtils()) {
        this.bgfxUtils = bgfxUtils
    }

    /**
     * @brief[zh-cn] 检查纹理是否需要生成 mipmap
     * @param[zh-cn] minFilter 缩小过滤模式
     * width 纹理宽度
     * height 纹理高度
     * isPowerOfTwo 尺寸是否为 2 的幂
     * @return[zh-cn] 是否需要 mipmap
     *
     * @brief[en] Check if texture needs mipmap generation
     * @param[en] minFilter Minification filter mode
     * width Texture width
     * height Texture height
     * isPowerOfTwo Whether dimensions are power of two
     * @return[en] Whether mipmap is needed
     */
    public func needsMipmaps(minFilter: Int64, width: Int64, height: Int64, isPowerOfTwo: Bool): Bool {
        // 如果纹理使用 mipmap 过滤且尺寸是 2 的幂
        if (minFilter != 1003 && minFilter != 1006) {  // NearestFilter, LinearFilter
            return isPowerOfTwo
        }
        return false
    }

    /**
     * @brief[zh-cn] 检查尺寸是否为 2 的幂
     * @param[zh-cn] value 待检查的值
     * @return[zh-cn] 是否为 2 的幂
     *
     * @brief[en] Check if value is power of two
     * @param[en] value Value to check
     * @return[en] Whether power of two
     */
    public func isPowerOfTwo(value: Int64): Bool {
        return (value & (value - 1)) == 0
    }

    /**
     * @brief[zh-cn] 将 three.js 像素格式转换为 bgfx TextureFormat
     * @param[zh-cn] format three.js 像素格式常量
     * @return[zh-cn] bgfx TextureFormat 值
     *
     * @brief[en] Convert three.js pixel format to bgfx TextureFormat
     * @param[en] format three.js pixel format constant
     * @return[en] bgfx TextureFormat value
     */
    public func convertFormat(format: Int64): UInt32 {
        match (BgfxUtils.convert(format, "srgb")) {
            case Some(v) => return v
            case None => return 0u32
        }
    }

    /**
     * @brief[zh-cn] 获取纹理的内存大小估算
     * @param[zh-cn] width 纹理宽度
     * height 纹理高度
     * format 像素格式
     * hasMipmaps 是否有 mipmap
     * @return[zh-cn] 估算的内存大小（字节）
     *
     * @brief[en] Estimate texture memory size
     * @param[en] width Texture width
     * height Texture height
     * format Pixel format
     * hasMipmaps Whether has mipmaps
     * @return[en] Estimated memory size in bytes
     */
    public func estimateMemory(width: Int64, height: Int64, format: Int64, hasMipmaps: Bool): Int64 {
        let bytesPerPixel = getBytesPerPixel(format)
        var size = width * height * bytesPerPixel
        if (hasMipmaps) {
            size = size * 4 / 3  // mipmap 链约增加 33%
        }
        return size
    }

    /**
     * @brief[zh-cn] 获取每像素字节数
     * @param[zh-cn] format 像素格式
     * @return[zh-cn] 每像素字节数
     *
     * @brief[en] Get bytes per pixel
     * @param[en] format Pixel format
     * @return[en] Bytes per pixel
     */
    private func getBytesPerPixel(format: Int64): Int64 {
        // 根据 three.js 格式返回字节数
        if (format == 1023) { return 4 }  // RGBAFormat
        if (format == 1022) { return 3 }  // RGBFormat
        if (format == 1026) { return 2 }  // LuminanceAlphaFormat
        if (format == 1025) { return 1 }  // LuminanceFormat
        return 4  // 默认 RGBA
    }
}
