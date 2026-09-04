/**
 * @file[zh-cn] 阴影材质
 * @brief[zh-cn] 阴影材质，可以接收阴影但本身完全透明
 * @explain[zh-cn] 
 * 对应 Three.js materials/ShadowMaterial.js。该材质可以接收阴影，但本身完全透明。
 * 常用于在地面平面等几何体上仅显示阴影投射效果。
 *
 * @file[en] Shadow Material
 * @brief[en] Shadow material, can receive shadows but is itself fully transparent
 * @explain[en] 
 * Corresponds to Three.js materials/ShadowMaterial.js. This material can receive shadows but is itself fully transparent.
 * Commonly used to display only shadow casting effects on geometry such as ground planes.
 */
package three.rendering.materials

import three.core.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 阴影材质，可以接收阴影但本身完全透明
 * @explain[zh-cn] 
 * 对应 Three.js materials/ShadowMaterial.js。常用于在地面平面等几何体上仅显示阴影投射效果。
 *
 * @brief[en] Shadow material, can receive shadows but is itself fully transparent
 * @explain[en] 
 * Corresponds to Three.js materials/ShadowMaterial.js. Commonly used to display only shadow casting effects on ground planes.
 */
@JsonAdapter[withSuperClass = Material]
public class ShadowMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的阴影材质
     *
     * @brief[en] Construct a new shadow material
     */
    public init() {
        super()
        this.kind = "ShadowMaterial"
        this.color = Color(0x000000)
        this.transparent = true  // 阴影材质默认透明
        this.fog = true           // 受雾效影响
    }

    /**
     * @brief[zh-cn] 将给定ShadowMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given ShadowMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: ShadowMaterial): ShadowMaterial {
        super.copy(source)
        this.color.copy(source.color)
        this.fog = source.fog
        return this
    }
}
