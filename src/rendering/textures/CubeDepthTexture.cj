/**
 * @file[zh-cn] 立方体深度纹理
 * @brief[zh-cn] 立方体贴图格式的深度纹理，6 面对应 ±X/±Y/±Z 六面深度
 * @explain[zh-cn] 立方体深度纹理：立方体贴图格式的深度纹理，6 面对应 ±X/±Y/±Z 六面深度。继承 DepthTexture。默认 format=DepthFormat、mapping=CubeReflectionMapping、generateMipmaps=false、flipY=false。

 * @file[en] Cube Depth Texture
 * @brief[en] Cube map format depth texture, 6 faces correspond to ±X/±Y/±Z depth
 * @explain[en] Cube depth texture: cube map format depth texture, 6 faces correspond to ±X/±Y/±Z depth. Extends DepthTexture. Defaults format=DepthFormat, mapping=CubeReflectionMapping, generateMipmaps=false, flipY=false. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] 立方体深度纹理类
 * @explain[zh-cn] 立方体贴图格式的深度纹理，继承 DepthTexture，默认 mapping=CubeReflectionMapping。

 * @brief[en] Cube depth texture class
 * @explain[en] Cube map format depth texture, extends DepthTexture, defaults mapping=CubeReflectionMapping.
 */
public open class CubeDepthTexture <: DepthTexture {

    /**
     * @brief[zh-cn] 构造一个新的立方体深度纹理
     * @param[zh-cn] width 单面宽度（像素）
     * height 单面高度（像素）

     * @brief[en] Construct a new cube depth texture
     * @param[en] width Single face width in pixels
     * height Single face height in pixels
     */
    public init(width: Int64, height: Int64) {
        super(width, height)
        this.kind = "CubeDepthTexture"
        this.mapping = CubeReflectionMapping
    }
}
