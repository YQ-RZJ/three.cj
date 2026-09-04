/**
 * @file[zh-cn] 压缩数组纹理
 * @brief[zh-cn] 2D 数组纹理的压缩格式版本（含 depth 层维）
 * @explain[zh-cn] 压缩数组纹理：2D 数组纹理的压缩格式版本（含 depth 层维）。继承 CompressedTexture；默认 wrapR=ClampToEdgeWrapping。

 * @file[en] Compressed Array Texture
 * @brief[en] Compressed format version of 2D array texture (with depth layer dimension)
 * @explain[en] Compressed array texture: compressed format version of 2D array texture (with depth layer dimension). Extends CompressedTexture; defaults wrapR=ClampToEdgeWrapping. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] 压缩数组纹理类
 * @explain[zh-cn] 继承 CompressedTexture，2D 数组纹理的压缩格式版本，含 depth 层维。

 * @brief[en] Compressed array texture class
 * @explain[en] Extends CompressedTexture, compressed format version of 2D array texture with depth layer dimension.
 */
public open class CompressedArrayTexture <: CompressedTexture {

    /**
     * @brief[zh-cn] 沿 R 维（层维）的环绕模式，默认 ClampToEdgeWrapping

     * @brief[en] Wrap mode along R dimension (layer dimension), defaults to ClampToEdgeWrapping
     */
    public var wrapR: Int64

    /**
     * @brief[zh-cn] 构造一个新的压缩数组纹理
     * @param[zh-cn] data 压缩像素数组
     * width 纹理宽度（像素）
     * height 纹理高度（像素）
     * depth 层数量
     * format 像素格式（压缩格式枚举），默认 RGBAFormat

     * @brief[en] Construct a new compressed array texture
     * @param[en] data Compressed pixel array
     * width Texture width in pixels
     * height Texture height in pixels
     * depth Layer count
     * format Pixel format (compressed format enum), defaults to RGBAFormat
     */
    public init(data: Array<UInt8>, width: Int64, height: Int64, depth: Int64, format!: Int64 = RGBAFormat) {
        super(data, width, height, format: format)
        this.kind = "CompressedArrayTexture"
        this.wrapR = ClampToEdgeWrapping
        this.generateMipmaps = false
        this.flipY = false
        this.unpackAlignment = 1
    }

    /**
     * @brief[zh-cn] 拷贝纹理
     * @param[zh-cn] source 源纹理
     * @return[zh-cn] 当前实例

     * @brief[en] Copy texture
     * @param[en] source Source texture
     * @return[en] This instance
     */
    public override func copy(source: Texture): Texture {
        super.copy(source)
        match (source as CompressedArrayTexture) {
            case Some(sat) => this.wrapR = sat.wrapR
            case None => ()
        }
        return this
    }
}
