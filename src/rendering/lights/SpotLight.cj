/**
 * @file[zh-cn] 聚光源
 * @brief[zh-cn] 从某点沿某方向以圆锥形照射的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/SpotLight.js。圆锥边缘随距离增加而变宽，圆锥之外无光。
 * 聚光源通过 SpotLightShadow 生成阴影贴图，并可通过 target 属性指定照射方向。
 *
 * @file[en] Spot Light
 * @brief[en] A light that emits from a point in a cone shape along a direction
 * @explain[en] 
 * Corresponds to Three.js lights/SpotLight.js. The cone edge widens with distance, and there is no light outside the cone.
 * Spot lights generate shadow maps through SpotLightShadow and can specify the illumination direction via the target property.
 */
package three.rendering.lights

import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.textures.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 从某点沿某方向以圆锥形照射的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/SpotLight.js。圆锥边缘随距离增加而变宽，圆锥之外无光。
 * 聚光源通过 SpotLightShadow 生成阴影贴图，并可通过 target 属性指定照射方向。
 *
 * @brief[en] A light that emits from a point in a cone shape along a direction
 * @explain[en] 
 * Corresponds to Three.js lights/SpotLight.js. The cone edge widens with distance, and there is no light outside the cone.
 * Spot lights generate shadow maps through SpotLightShadow and can specify the illumination direction via the target property.
 */
@JsonAdapter[withSuperClass = Light]
public open class SpotLight <: Light {

    /**
     * @brief[zh-cn] 光源指向的目标对象，影响光照方向
     *
     * @brief[en] The target object the light points to, affecting the light direction
     */
    public var target: Object3D

    /**
     * @brief[zh-cn] 圆锥顶点处的角度（弧度），范围[0, π/2]，默认π/3
     *
     * @brief[en] The angle at the cone vertex (radians), range [0, π/2], default π/3
     */
    public var angle: Float64

    /**
     * @brief[zh-cn] 半影区大小，0=硬边圆锥，1=完全软边，默认0
     *
     * @brief[en] Penumbra size, 0=hard edge cone, 1=fully soft edge, default 0
     */
    public var penumbra: Float64

    /**
     * @brief[zh-cn] 沿光线方向的物理衰减系数，1=稳定，2=真实世界，默认2
     *
     * @brief[en] Physical decay coefficient along the light direction, 1=constant, 2=physically correct, default 2
     */
    public var decay: Float64

    /**
     * @brief[zh-cn] 光线照射范围，0表示不衰减，默认0
     *
     * @brief[en] Light range, 0 means no decay, default 0
     */
    public var distance: Float64

    /**
     * @brief[zh-cn] 阴影配置对象
     *
     * @brief[en] Shadow configuration object
     */
    public var shadow: SpotLightShadow

    /**
     * @brief[zh-cn] 调制聚光灯光的贴图，默认null
     *
     * @brief[en] Texture modulating the spotlight light, default null
     */
    public var map: Option<Texture>

    /**
     * @brief[zh-cn] 构造一个新的聚光源
     * @param[zh-cn] color 光源颜色，默认0xffffff
     * intensity 光源强度，默认1
     * distance 光线照射范围，默认0
     * angle 圆锥顶点角度（弧度），默认π/3
     * penumbra 半影区大小，默认0
     * decay 物理衰减系数，默认2
     *
     * @brief[en] Construct a new spot light
     * @param[en] color Light color, default 0xffffff
     * intensity Light intensity, default 1
     * distance Light range, default 0
     * angle Cone vertex angle (radians), default π/3
     * penumbra Penumbra size, default 0
     * decay Physical decay coefficient, default 2
     */
    public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, distance!: Float64 = 0.0, angle!: Float64 = PI / 3.0, penumbra!: Float64 = 0.0, decay!: Float64 = 2.0) {
        super(color: color, intensity: intensity)
        this.kind = "SpotLight"
        this.distance = distance
        this.angle = angle
        this.penumbra = penumbra
        this.decay = decay
        this.target = Object3D()
        this.shadow = SpotLightShadow()
        this.map = None
        this.position.copy(Vector3(0.0, 0.0, 1.0))
        this.target.position.copy(Vector3(0.0, 0.0, -1.0))
    }

    /**
     * @brief[zh-cn] 直接访问聚光源功率（流明）
     * @explain[zh-cn] 
     * 当 physicallyCorrectLight=true 时，光强度按此值缩放。
     * 默认从光在视锥立体角内积分计算。
     *
     * @brief[en] Direct access to the spot light power (lumens)
     * @explain[en] 
     * When physicallyCorrectLight=true, light intensity is scaled by this value.
     * Default is computed from integrating light over the cone solid angle.
     */
    @JsonIgnore
    public mut prop power: Float64 {
        get() {
            // 立体角 = 2π (1 - cosAngle)
            return this.intensity * 4.0 * PI
        }
        set(v) {
            this.intensity = v / (4.0 * PI)
        }
    }

    /**
     * @brief[zh-cn] 释放本实例分配的GPU相关资源，当实例不再使用时应调用
     *
     * @brief[en] Dispose GPU-related resources allocated by this instance, should be called when the instance is no longer used
     */
    public override func dispose(): Unit {
        super.dispose()
        this.shadow.dispose()
    }

    /**
     * @brief[zh-cn] 将给定聚光源实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the values from the given spot light instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy child objects
     * @return[en] This instance
     */
    public open override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: SpotLight =>
                this.target = s.target.clone()
                let shadowCopy = s.shadow.clone()
                this.shadow.copy(shadowCopy)
                this.distance = s.distance
                this.angle = s.angle
                this.penumbra = s.penumbra
                this.decay = s.decay
                this.map = s.map
            case _ => ()
        }
        return this
    }
}
