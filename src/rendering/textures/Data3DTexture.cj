/**
 * @file[zh-cn] 3D 数据纹理
 * @brief[zh-cn] 3D 纹理（含 depth 层维，层间线性插值），用于体渲染、3D 查找表等
 * @explain[zh-cn] 3D 数据纹理：3D 纹理（含 depth 层维，层间线性插值），用于体渲染、3D 查找表等。与 DataArrayTexture 不同：本类是 3D 纹理（层间线性插值），非 Array 纹理（每层独立采样）。默认 magFilter/minFilter=NearestFilter、generateMipmaps=false、flipY=false、unpackAlignment=1。

 * @file[en] Data 3D Texture
 * @brief[en] 3D texture (with depth layer dimension, linear interpolation between layers), used for volume rendering, 3D lookup tables, etc.
 * @explain[en] 3D data texture: 3D texture (with depth layer dimension, linear interpolation between layers), used for volume rendering, 3D lookup tables, etc. Unlike DataArrayTexture: this is a 3D texture (linear interpolation between layers), not an Array texture (each layer sampled independently). Defaults magFilter/minFilter=NearestFilter, generateMipmaps=false, flipY=false, unpackAlignment=1. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] 3D 数据纹理类
 * @explain[zh-cn] 3D 纹理（含 depth 层维，层间线性插值），默认 magFilter/minFilter=NearestFilter、generateMipmaps=false、flipY=false、unpackAlignment=1。

 * @brief[en] Data 3D texture class
 * @explain[en] 3D texture (with depth layer dimension, linear interpolation between layers), defaults magFilter/minFilter=NearestFilter, generateMipmaps=false, flipY=false, unpackAlignment=1.
 */
public open class Data3DTexture <: Texture {

    /**
     * @brief[zh-cn] 沿 R 维（层维）的环绕模式，默认 ClampToEdgeWrapping

     * @brief[en] Wrap mode along R dimension (layer dimension), defaults to ClampToEdgeWrapping
     */
    public var wrapR: Int64

    /**
     * @brief[zh-cn] 构造一个新的 3D 数据纹理
     * @param[zh-cn] data 像素数组
     * width 纹理宽度（像素）
     * height 纹理高度（像素）
     * depth 层数量

     * @brief[en] Construct a new 3D data texture
     * @param[en] data Pixel array
     * width Texture width in pixels
     * height Texture height in pixels
     * depth Layer count
     */
    public init(data: Array<UInt8>, width: Int64, height: Int64, depth: Int64) {
        super(image: data, width: width, height: height)
        this.kind = "Data3DTexture"
        this.wrapR = ClampToEdgeWrapping
        this.magFilter = NearestFilter
        this.minFilter = NearestFilter
        this.generateMipmaps = false
        this.flipY = false
        this.unpackAlignment = 1
    }
}
