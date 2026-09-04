/**
 * @file[zh-cn] 环境光
 * @brief[zh-cn] 环境光，从各方向均匀照射场景的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/AmbientLight.js。该光源颜色会均匀叠加到场景各物体上，
 * 不产生阴影、不计算法线。
 *
 * @file[en] Ambient Light
 * @brief[en] Ambient light that illuminates the scene uniformly from all directions
 * @explain[en] 
 * Corresponds to Three.js lights/AmbientLight.js. The light color is uniformly applied
 * to all objects in the scene, without shadows or normal calculations.
 */
package three.rendering.lights

import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 环境光，从各方向均匀照射场景的光源
 * @explain[zh-cn] 
 * 该光源颜色会均匀叠加到场景各物体上，不产生阴影、不计算法线。
 *
 * @brief[en] Ambient light that illuminates the scene uniformly from all directions
 * @explain[en] 
 * The light color is uniformly applied to all objects in the scene,
 * without shadows or normal calculations.
 */
@JsonAdapter[withSuperClass = Light]
public class AmbientLight <: Light {

    /**
     * @brief[zh-cn] 构造一个新的环境光
     * @param[zh-cn] color 光源颜色，默认 0xffffff
     * intensity 光源强度，默认 1
     *
     * @brief[en] Construct a new ambient light
     * @param[en] color Light color, default 0xffffff
     * intensity Light intensity, default 1
     */
    public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0) {
        super(color: color, intensity: intensity)
        this.kind = "AmbientLight"
    }
}
