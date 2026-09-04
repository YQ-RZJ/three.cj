/**
 * @file[zh-cn] 数据数组纹理
 * @brief[zh-cn] 2D 数组纹理（含 depth 层维），用于体渲染、多层阴影贴图等
 * @explain[zh-cn] 数据数组纹理：2D 数组纹理（含 depth 层维），用于体渲染、多层阴影贴图等。与 Data3DTexture 不同：本类是 Array 纹理（每层独立采样），非 3D 纹理（层间线性插值）。默认 magFilter/minFilter=NearestFilter、generateMipmaps=false、flipY=false、unpackAlignment=1。

 * @file[en] Data Array Texture
 * @brief[en] 2D array texture (with depth layer dimension), used for volume rendering, multi-layer shadow maps, etc.
 * @explain[en] Data array texture: 2D array texture (with depth layer dimension), used for volume rendering, multi-layer shadow maps, etc. Unlike Data3DTexture: this is an Array texture (each layer sampled independently), not a 3D texture (linear interpolation between layers). Defaults magFilter/minFilter=NearestFilter, generateMipmaps=false, flipY=false, unpackAlignment=1. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] 数据数组纹理类
 * @explain[zh-cn] 2D 数组纹理（含 depth 层维），默认 magFilter/minFilter=NearestFilter、generateMipmaps=false、flipY=false、unpackAlignment=1。

 * @brief[en] Data array texture class
 * @explain[en] 2D array texture (with depth layer dimension), defaults magFilter/minFilter=NearestFilter, generateMipmaps=false, flipY=false, unpackAlignment=1.
 */
public open class DataArrayTexture <: Texture {

    /**
     * @brief[zh-cn] 沿 R 维（层维）的环绕模式，默认 ClampToEdgeWrapping

     * @brief[en] Wrap mode along R dimension (layer dimension), defaults to ClampToEdgeWrapping
     */
    public var wrapR: Int64

    /**
     * @brief[zh-cn] 构造一个新的数据数组纹理
     * @param[zh-cn] data 像素数组
     * width 纹理宽度（像素）
     * height 纹理高度（像素）
     * depth 层数量

     * @brief[en] Construct a new data array texture
     * @param[en] data Pixel array
     * width Texture width in pixels
     * height Texture height in pixels
     * depth Layer count
     */
    public init(data: Array<UInt8>, width: Int64, height: Int64, depth: Int64) {
        super(image: data, width: width, height: height)
        this.kind = "DataArrayTexture"
        this.wrapR = ClampToEdgeWrapping
        this.magFilter = NearestFilter
        this.minFilter = NearestFilter
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
        match (source as DataArrayTexture) {
            case Some(sat) => this.wrapR = sat.wrapR
            case None => ()
        }
        return this
    }
}
