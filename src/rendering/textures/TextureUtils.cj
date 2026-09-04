/**
 * @file[zh-cn] 纹理工具函数
 * @brief[zh-cn] 对应 Three.js extras/TextureUtils.js，提供纹理裁剪适配与字节长度估算
 * @explain[zh-cn] 提供 CSS object-fit 风格的纹理变换（contain/cover/fill）以及给定尺寸、格式、类型下的纹理字节数估算方法。

 * @file[en] Texture Utilities
 * @brief[en] Corresponding to Three.js extras/TextureUtils.js, provides texture fit/sizing and byte length estimation
 * @explain[en] Provides CSS object-fit style texture transforms (contain/cover/fill) and texture byte length estimation methods for given dimensions, format, and type. 
 */
package three.rendering.textures

import std.math.*
import three.utils.constants.*
import three.core.math.*

/**
 * @brief[zh-cn] 纹理类型字节描述：每个像素的字节数与该类型一次写入的分量数

 * @brief[en] Texture type byte description: bytes per pixel and components per write for each type
 */
public struct TypeByteLength {
    /**
     * @brief[zh-cn] 每像素（或每分量组）的字节数

     * @brief[en] Bytes per pixel (or per component group)
     */
    public let byteLength: Int64
    /**
     * @brief[zh-cn] 每像素的分量数

     * @brief[en] Components per pixel
     */
    public let components: Int64
    public init(byteLength: Int64, components: Int64) {
        this.byteLength = byteLength
        this.components = components
    }
}

/**
 * @brief[zh-cn] 查表获取给定纹理类型对应的字节数与分量数
 * @param[zh-cn] type 纹理类型常量
 * @return[zh-cn] TypeByteLength 结构

 * @brief[en] Look up bytes per pixel and components for the given texture type
 * @param[en] type Texture type constant
 * @return[en] TypeByteLength structure
 */
public func getTextureTypeByteLength(`type`: Int64): TypeByteLength {
    if (`type` == UnsignedByteType || `type` == ByteType) {
        return TypeByteLength(1, 1)
    } else if (`type` == UnsignedShortType || `type` == ShortType || `type` == HalfFloatType) {
        return TypeByteLength(2, 1)
    } else if (`type` == UnsignedShort4444Type || `type` == UnsignedShort5551Type) {
        return TypeByteLength(2, 4)
    } else if (`type` == UnsignedIntType || `type` == IntType || `type` == FloatType) {
        return TypeByteLength(4, 1)
    } else if (`type` == UnsignedInt5999Type || `type` == UnsignedInt101111Type) {
        return TypeByteLength(4, 3)
    }
    throw Exception("THREE.TextureUtils: Unknown texture type ${`type`}.")
}

/**
 * @brief[zh-cn] 按包含模式缩放纹理（包级便捷函数，转发到 TextureUtils.contain）
 * @param[zh-cn] texture 目标纹理
 * aspect 目标表面宽高比
 * @return[zh-cn] 被修改的纹理

 * @brief[en] Scale texture in contain mode (package-level convenience function, forwards to TextureUtils.contain)
 * @param[en] texture Target texture
 * aspect Target surface aspect ratio
 * @return[en] Modified texture
 */
public func contain(texture: Texture, aspect: Float64): Texture {
    return TextureUtils.contain(texture, aspect)
}

/**
 * @brief[zh-cn] 按覆盖模式缩放纹理（包级便捷函数，转发到 TextureUtils.cover）
 * @param[zh-cn] texture 目标纹理
 * aspect 目标表面宽高比
 * @return[zh-cn] 被修改的纹理

 * @brief[en] Scale texture in cover mode (package-level convenience function, forwards to TextureUtils.cover)
 * @param[en] texture Target texture
 * aspect Target surface aspect ratio
 * @return[en] Modified texture
 */
public func cover(texture: Texture, aspect: Float64): Texture {
    return TextureUtils.cover(texture, aspect)
}

/**
 * @brief[zh-cn] 将纹理重置为默认变换（包级便捷函数，转发到 TextureUtils.fill）
 * @param[zh-cn] texture 目标纹理
 * @return[zh-cn] 被修改的纹理

 * @brief[en] Reset texture to default transform (package-level convenience function, forwards to TextureUtils.fill)
 * @param[en] texture Target texture
 * @return[en] Modified texture
 */
public func fill(texture: Texture): Texture {
    return TextureUtils.fill(texture)
}

/**
 * @brief[zh-cn] 纹理工具类
 * @explain[zh-cn] 提供 CSS object-fit 风格的纹理变换（contain/cover/fill）以及给定尺寸、格式、类型下的纹理字节数估算方法。

 * @brief[en] Texture utilities class
 * @explain[en] Provides CSS object-fit style texture transforms (contain/cover/fill) and texture byte length estimation methods for given dimensions, format, and type.
 */
public class TextureUtils {
    /**
     * @brief[zh-cn] 按包含模式缩放纹理：在不裁剪/拉伸的前提下尽可能大地填充表面
     * @param[zh-cn] texture 目标纹理
     * aspect 目标表面的宽高比
     * @return[zh-cn] 被修改的纹理

     * @brief[en] Scale texture in contain mode: fill surface as large as possible without cropping/stretching
     * @param[en] texture Target texture
     * aspect Target surface aspect ratio
     * @return[en] Modified texture
     */
    public static func contain(texture: Texture, aspect: Float64): Texture {
        let imageAspect = if (texture.image.size > 0 && texture.width > 0) {
            Float64(texture.width) / Float64(texture.height)
        } else {
            1.0
        }
        if (imageAspect > aspect) {
            texture.repeat.set(1.0, imageAspect / aspect)
            texture.offset.set(0.0, (1.0 - texture.repeat.y) / 2.0)
        } else {
            texture.repeat.set(aspect / imageAspect, 1.0)
            texture.offset.set((1.0 - texture.repeat.x) / 2.0, 0.0)
        }
        return texture
    }

    /**
     * @brief[zh-cn] 按覆盖模式缩放纹理
     * @param[zh-cn] texture 目标纹理
     * aspect 目标表面的宽高比
     * @return[zh-cn] 被修改的纹理

     * @brief[en] Scale texture in cover mode
     * @param[en] texture Target texture
     * aspect Target surface aspect ratio
     * @return[en] Modified texture
     */
    public static func cover(texture: Texture, aspect: Float64): Texture {
        let imageAspect = if (texture.image.size > 0 && texture.width > 0) {
            Float64(texture.width) / Float64(texture.height)
        } else {
            1.0
        }
        if (imageAspect > aspect) {
            texture.repeat.set(aspect / imageAspect, 1.0)
            texture.offset.set((1.0 - texture.repeat.x) / 2.0, 0.0)
        } else {
            texture.repeat.set(1.0, imageAspect / aspect)
            texture.offset.set(0.0, (1.0 - texture.repeat.y) / 2.0)
        }
        return texture
    }

    /**
     * @brief[zh-cn] 将纹理重置为默认变换
     * @param[zh-cn] texture 目标纹理
     * @return[zh-cn] 被修改的纹理

     * @brief[en] Reset texture to default transform
     * @param[en] texture Target texture
     * @return[en] Modified texture
     */
    public static func fill(texture: Texture): Texture {
        texture.repeat.set(1.0, 1.0)
        texture.offset.set(0.0, 0.0)
        return texture
    }

    /**
     * @brief[zh-cn] 估算给定尺寸、格式、类型下的纹理字节长度
     * @param[zh-cn] width 纹理宽度
     * height 纹理高度
     * format 纹理格式
     * type 纹理类型
     * @return[zh-cn] 字节长度

     * @brief[en] Estimate texture byte length for given dimensions, format, and type
     * @param[en] width Texture width
     * height Texture height
     * format Texture format
     * type Texture type
     * @return[en] Byte length
     */
    public static func getByteLength(width: Int64, height: Int64, format: Int64, `type`: Int64): Int64 {
        let tbl = getTextureTypeByteLength(`type`)
        let components = tbl.components
        let byteLength = tbl.byteLength
        if (format == AlphaFormat) {
            return width * height
        } else if (format == RedFormat || format == RedIntegerFormat) {
            return ((width * height) / components) * byteLength
        } else if (format == RGFormat || format == RGIntegerFormat) {
            return ((width * height * 2) / components) * byteLength
        } else if (format == RGBFormat) {
            return ((width * height * 3) / components) * byteLength
        } else if (format == RGBAFormat || format == RGBAIntegerFormat) {
            return ((width * height * 4) / components) * byteLength
        } else if (format == RGB_S3TC_DXT1_Format || format == RGBA_S3TC_DXT1_Format) {
            return ((width + 3) / 4) * ((height + 3) / 4) * 8
        } else if (format == RGBA_S3TC_DXT3_Format || format == RGBA_S3TC_DXT5_Format) {
            return ((width + 3) / 4) * ((height + 3) / 4) * 16
        } else if (format == RGB_PVRTC_2BPPV1_Format || format == RGBA_PVRTC_2BPPV1_Format) {
            return (max(width, 16) * max(height, 8)) / 4
        } else if (format == RGB_PVRTC_4BPPV1_Format || format == RGBA_PVRTC_4BPPV1_Format) {
            return (max(width, 8) * max(height, 8)) / 2
        } else if (format == RGB_ETC1_Format || format == RGB_ETC2_Format ||
                   format == R11_EAC_Format || format == SIGNED_R11_EAC_Format) {
            return ((width + 3) / 4) * ((height + 3) / 4) * 8
        } else if (format == RGBA_ETC2_EAC_Format || format == RG11_EAC_Format ||
                   format == SIGNED_RG11_EAC_Format) {
            return ((width + 3) / 4) * ((height + 3) / 4) * 16
        } else if (format == RGBA_ASTC_4x4_Format) {
            return ((width + 3) / 4) * ((height + 3) / 4) * 16
        } else if (format == RGBA_ASTC_5x4_Format) {
            return ((width + 4) / 5) * ((height + 3) / 4) * 16
        } else if (format == RGBA_ASTC_5x5_Format) {
            return ((width + 4) / 5) * ((height + 4) / 5) * 16
        } else if (format == RGBA_ASTC_6x5_Format) {
            return ((width + 5) / 6) * ((height + 4) / 5) * 16
        } else if (format == RGBA_ASTC_6x6_Format) {
            return ((width + 5) / 6) * ((height + 5) / 6) * 16
        } else if (format == RGBA_ASTC_8x5_Format) {
            return ((width + 7) / 8) * ((height + 4) / 5) * 16
        } else if (format == RGBA_ASTC_8x6_Format) {
            return ((width + 7) / 8) * ((height + 5) / 6) * 16
        } else if (format == RGBA_ASTC_8x8_Format) {
            return ((width + 7) / 8) * ((height + 7) / 8) * 16
        } else if (format == RGBA_ASTC_10x5_Format) {
            return ((width + 9) / 10) * ((height + 4) / 5) * 16
        } else if (format == RGBA_ASTC_10x6_Format) {
            return ((width + 9) / 10) * ((height + 5) / 6) * 16
        } else if (format == RGBA_ASTC_10x8_Format) {
            return ((width + 9) / 10) * ((height + 7) / 8) * 16
        } else if (format == RGBA_ASTC_10x10_Format) {
            return ((width + 9) / 10) * ((height + 9) / 10) * 16
        } else if (format == RGBA_ASTC_12x10_Format) {
            return ((width + 11) / 12) * ((height + 9) / 10) * 16
        } else if (format == RGBA_ASTC_12x12_Format) {
            return ((width + 11) / 12) * ((height + 11) / 12) * 16
        } else if (format == RGBA_BPTC_Format || format == RGB_BPTC_SIGNED_Format ||
                   format == RGB_BPTC_UNSIGNED_Format) {
            return ((width + 3) / 4) * ((height + 3) / 4) * 16
        } else if (format == RED_RGTC1_Format || format == SIGNED_RED_RGTC1_Format) {
            return ((width + 3) / 4) * ((height + 3) / 4) * 8
        } else if (format == RED_GREEN_RGTC2_Format || format == SIGNED_RED_GREEN_RGTC2_Format) {
            return ((width + 3) / 4) * ((height + 3) / 4) * 16
        }
        throw Exception("Unable to determine texture byte length for ${format} format.")
    }
}
