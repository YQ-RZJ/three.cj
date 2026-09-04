/**
 * @file[zh-cn] 数据纹理
 * @brief[zh-cn] 直接由 Uint8Array 像素数组构造的 2D 纹理
 * @explain[zh-cn] 数据纹理：直接由 Uint8Array 像素数组构造的 2D 纹理。与 ImageTexture 不同：无需 DOM Image 解码，直接上传 data 到 GPU。默认 generateMipmaps=false、flipY=false、unpackAlignment=1（逐行紧密）。

 * @file[en] Data Texture
 * @brief[en] 2D texture constructed directly from a Uint8Array pixel array
 * @explain[en] Data texture: 2D texture constructed directly from a Uint8Array pixel array. Unlike ImageTexture: no DOM Image decoding needed, data is uploaded directly to GPU. Defaults generateMipmaps=false, flipY=false, unpackAlignment=1 (tight row packing). 
 */
package three.rendering.textures

import three.utils.constants.*

/**
 * @brief[zh-cn] 数据纹理类
 * @explain[zh-cn] 直接由像素数组构造的 2D 纹理，默认 generateMipmaps=false、flipY=false、unpackAlignment=1。

 * @brief[en] Data texture class
 * @explain[en] 2D texture constructed directly from a pixel array, defaults generateMipmaps=false, flipY=false, unpackAlignment=1.
 */
public open class DataTexture <: Texture {

    /**
     * @brief[zh-cn] 构造一个新的数据纹理
     * @param[zh-cn] data 像素数组
     * width 纹理宽度（像素）
     * height 纹理高度（像素）
     * format 像素格式，默认 RGBAFormat
     * type 像素数据类型，默认 UnsignedByteType
     * mapping UV 映射模式，默认 UVMapping
     * wrapS 水平环绕模式，默认 ClampToEdgeWrapping
     * wrapT 垂直环绕模式，默认 ClampToEdgeWrapping
     * magFilter 放大过滤器，默认 NearestFilter
     * minFilter 缩小过滤器，默认 NearestFilter
     * anisotropy 各向异性等级，默认 1
     * colorSpace 颜色空间，默认空

     * @brief[en] Construct a new data texture
     * @param[en] data Pixel array
     * width Texture width in pixels
     * height Texture height in pixels
     * format Pixel format, defaults to RGBAFormat
     * type Pixel data type, defaults to UnsignedByteType
     * mapping UV mapping mode, defaults to UVMapping
     * wrapS Horizontal wrap mode, defaults to ClampToEdgeWrapping
     * wrapT Vertical wrap mode, defaults to ClampToEdgeWrapping
     * magFilter Magnification filter, defaults to NearestFilter
     * minFilter Minification filter, defaults to NearestFilter
     * anisotropy Anisotropy level, defaults to 1
     * colorSpace Color space, defaults to empty
     */
    public init(data: Array<UInt8>, width: Int64, height: Int64, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = NearestFilter, minFilter!: Int64 = NearestFilter, anisotropy!: Int64 = 1, colorSpace!: String = "") {
        super(image: data, width: width, height: height, format: format, `type`: `type`, mapping: mapping, wrapS: wrapS, wrapT: wrapT, magFilter: magFilter, minFilter: minFilter, anisotropy: anisotropy, colorSpace: colorSpace)
        this.kind = "DataTexture"
        this.generateMipmaps = false
        this.flipY = false
        this.unpackAlignment = 1
    }
}
