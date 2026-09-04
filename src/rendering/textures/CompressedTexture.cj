/**
 * @file[zh-cn] 压缩纹理
 * @brief[zh-cn] 由 GPU 原生压缩格式数据构造的纹理
 * @explain[zh-cn] 压缩纹理：由 GPU 原生压缩格式（BC1/BC3/ASTC/ETC/PVRTC 等）数据构造。与 DataTexture 不同：data 已是 GPU 压缩格式，直接上传无需 CPU 解码；mipmaps 数组填充各 mipmap 层压缩数据。默认 generateMipmaps=false、flipY=false、unpackAlignment=1。

 * @file[en] Compressed Texture
 * @brief[en] Texture constructed from GPU native compressed format data
 * @explain[en] Compressed texture: constructed from GPU native compressed format data (BC1/BC3/ASTC/ETC/PVRTC, etc.). Unlike DataTexture: data is already in GPU compressed format, uploaded directly without CPU decoding; mipmaps array is filled with compressed data for each mipmap level. Defaults generateMipmaps=false, flipY=false, unpackAlignment=1. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] 压缩纹理类
 * @explain[zh-cn] 由 GPU 原生压缩格式数据构造的纹理，默认 generateMipmaps=false、flipY=false、unpackAlignment=1。

 * @brief[en] Compressed texture class
 * @explain[en] Texture constructed from GPU native compressed format data, defaults generateMipmaps=false, flipY=false, unpackAlignment=1.
 */
public open class CompressedTexture <: Texture {

    /**
     * @brief[zh-cn] 构造一个新的压缩纹理
     * @param[zh-cn] data 压缩像素数组
     * width 纹理宽度（像素）
     * height 纹理高度（像素）
     * format 像素格式（压缩格式枚举），默认 RGBAFormat
     * type 像素数据类型，默认 UnsignedByteType
     * mapping UV 映射模式，默认 UVMapping
     * wrapS 水平环绕模式，默认 ClampToEdgeWrapping
     * wrapT 垂直环绕模式，默认 ClampToEdgeWrapping
     * magFilter 放大过滤器，默认 LinearFilter
     * minFilter 缩小过滤器，默认 LinearMipmapLinearFilter
     * anisotropy 各向异性等级，默认 1
     * colorSpace 颜色空间，默认空

     * @brief[en] Construct a new compressed texture
     * @param[en] data Compressed pixel array
     * width Texture width in pixels
     * height Texture height in pixels
     * format Pixel format (compressed format enum), defaults to RGBAFormat
     * type Pixel data type, defaults to UnsignedByteType
     * mapping UV mapping mode, defaults to UVMapping
     * wrapS Horizontal wrap mode, defaults to ClampToEdgeWrapping
     * wrapT Vertical wrap mode, defaults to ClampToEdgeWrapping
     * magFilter Magnification filter, defaults to LinearFilter
     * minFilter Minification filter, defaults to LinearMipmapLinearFilter
     * anisotropy Anisotropy level, defaults to 1
     * colorSpace Color space, defaults to empty
     */
    public init(data: Array<UInt8>, width: Int64, height: Int64, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, anisotropy!: Int64 = 1, colorSpace!: String = "") {
        super(image: data, width: width, height: height, format: format, `type`: `type`, mapping: mapping, wrapS: wrapS, wrapT: wrapT, magFilter: magFilter, minFilter: minFilter, anisotropy: anisotropy, colorSpace: colorSpace)
        this.kind = "CompressedTexture"
        this.generateMipmaps = false
        this.flipY = false
        this.unpackAlignment = 1
    }
}
