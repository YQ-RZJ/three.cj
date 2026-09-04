/**
 * @file[zh-cn] 深度纹理
 * @brief[zh-cn] 存储深度信息的纹理，用于阴影贴图、深度预 pass、屏幕空间反射等
 * @explain[zh-cn] 深度纹理：存储深度信息的纹理，用于阴影贴图（ShadowMap）、深度预 pass、屏幕空间反射等。默认 format=DepthFormat、generateMipmaps=false、flipY=false、unpackAlignment=1、magFilter=NearestFilter、minFilter=NearestFilter、type=UnsignedIntType。构造时校验 type 必须是 UnsignedShortType/UnsignedIntType/FloatType 之一，format 必须是 DepthFormat/DepthStencilFormat 之一。

 * @file[en] Depth Texture
 * @brief[en] Texture storing depth information, used for shadow maps, depth pre-pass, screen-space reflections, etc.
 * @explain[en] Depth texture: texture storing depth information, used for shadow maps, depth pre-pass, screen-space reflections, etc. Defaults format=DepthFormat, generateMipmaps=false, flipY=false, unpackAlignment=1, magFilter=NearestFilter, minFilter=NearestFilter, type=UnsignedIntType. Constructor validates type must be one of UnsignedShortType/UnsignedIntType/FloatType, format must be one of DepthFormat/DepthStencilFormat. 
 */
package three.rendering.textures
import three.utils.log.Logger
import three.utils.constants.*
import std.collection.*

/**
 * @brief[zh-cn] 深度纹理类
 * @explain[zh-cn] 存储深度信息的纹理，用于阴影贴图、深度预 pass、屏幕空间反射等。默认 format=DepthFormat、generateMipmaps=false、flipY=false。

 * @brief[en] Depth texture class
 * @explain[en] Texture storing depth information, used for shadow maps, depth pre-pass, screen-space reflections, etc. Defaults format=DepthFormat, generateMipmaps=false, flipY=false.
 */
public open class DepthTexture <: Texture {

    /**
     * @brief[zh-cn] 深度比较函数（WebGL compareFunction），None 表示无比较

     * @brief[en] Depth comparison function (WebGL compareFunction), None means no comparison
     */
    public var compareFunction: Option<Int64>

    /**
     * @brief[zh-cn] 构造一个新的深度纹理
     * @param[zh-cn] width 纹理宽度（像素）
     * height 纹理高度（像素）
     * type 像素数据类型，默认 UnsignedIntType

     * @brief[en] Construct a new depth texture
     * @param[en] width Texture width in pixels
     * height Texture height in pixels
     * type Pixel data type, defaults to UnsignedIntType
     */
    public init(width: Int64, height: Int64, `type`!: Int64 = UnsignedIntType) {
        super(image: Array<UInt8>(), width: width, height: height, format: DepthFormat, `type`: `type`, magFilter: NearestFilter, minFilter: NearestFilter)
        if (`type` != UnsignedShortType && `type` != UnsignedIntType && `type` != FloatType) {
            Logger.warn(["DepthTexture", "WARNING: unsupported type, expected UnsignedShortType/UnsignedIntType/FloatType"])
        }
        this.kind = "DepthTexture"
        this.generateMipmaps = false
        this.flipY = false
        this.unpackAlignment = 1
        this.compareFunction = None
    }

    /**
     * @brief[zh-cn] 将给定深度纹理实例的值复制到本实例
     * @param[zh-cn] source 源纹理
     * @return[zh-cn] 当前实例

     * @brief[en] Copy values from the given depth texture instance to this instance
     * @param[en] source Source texture
     * @return[en] This instance
     */
    public override func copy(source: Texture): Texture {
        super.copy(source)
        match (source) {
            case s: DepthTexture => this.compareFunction = s.compareFunction
            case _ => ()
        }
        return this
    }
}
