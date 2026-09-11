/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] 点光源
 * @brief[zh-cn] 从某点向各方向均匀照射的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/PointLight.js。光线随距离按 decay 衰减（物理正确时 decay=2）。
 * 点光源不投射方向性阴影，而是通过 PointLightShadow 生成六面立方体阴影贴图。
 *
 * @file[en] Point Light
 * @brief[en] A light that emits uniformly in all directions from a point
 * @explain[en] 
 * Corresponds to Three.js lights/PointLight.js. Light decays with distance according to decay (physically correct when decay=2).
 * Point lights do not cast directional shadows; instead they use PointLightShadow to generate a 6-face cube shadow map.
 */
package three.rendering.lights

import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 从某点向各方向均匀照射的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/PointLight.js。光线随距离按 decay 衰减（物理正确时 decay=2）。
 * 点光源不投射方向性阴影，而是通过 PointLightShadow 生成六面立方体阴影贴图。
 *
 * @brief[en] A light that emits uniformly in all directions from a point
 * @explain[en] 
 * Corresponds to Three.js lights/PointLight.js. Light decays with distance according to decay (physically correct when decay=2).
 * Point lights do not cast directional shadows; instead they use PointLightShadow to generate a 6-face cube shadow map.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Light]
public class PointLight <: Light {

    /**
     * @brief[zh-cn] 光线照射范围，0表示不衰减，默认0
     *
     * @brief[en] Light range, 0 means no decay, default 0
     */
    public var distance: Float64

    /**
     * @brief[zh-cn] 沿光线方向的物理衰减系数，1=稳定，2=真实世界，默认2
     *
     * @brief[en] Physical decay coefficient along the light direction, 1=constant, 2=physically correct, default 2
     */
    public var decay: Float64

    /**
     * @brief[zh-cn] 阴影配置对象
     *
     * @brief[en] Shadow configuration object
     */
    @JsonIgnore
    public var shadow: PointLightShadow

    /**
     * @brief[zh-cn] 构造一个新的点光源
     * @param[zh-cn] color 光源颜色，默认0xffffff
     * intensity 光源强度，默认1
     * distance 光线照射范围，默认0
     * decay 物理衰减系数，默认2
     *
     * @brief[en] Construct a new point light
     * @param[en] color Light color, default 0xffffff
     * intensity Light intensity, default 1
     * distance Light range, default 0
     * decay Physical decay coefficient, default 2
     */
    public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, distance!: Float64 = 0.0, decay!: Float64 = 2.0) {
        super(color: color, intensity: intensity)
        this.distance = distance
        this.decay = decay
        this.shadow = PointLightShadow()
    }

    /**
     * @brief[zh-cn] 直接访问点光源功率（流明）
     * @explain[zh-cn] 
     * 当 physicallyCorrectLight=true 时，光强度按此值缩放。
     * 默认从光在球面立体角（4π）内积分计算。
     *
     * @brief[en] Direct access to the point light power (lumens)
     * @explain[en] 
     * When physicallyCorrectLight=true, light intensity is scaled by this value.
     * Default is computed from integrating light over a spherical solid angle (4π).
     */
    @JsonIgnore
    public mut prop power: Float64 {
        get() {
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
     * @brief[zh-cn] 将给定点光源实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the values from the given point light instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy child objects
     * @return[en] This instance
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case p: PointLight =>
                this.distance = p.distance
                this.decay = p.decay
                let shadowCopy = p.shadow.clone()
                this.shadow.copy(shadowCopy)
            case _ => ()
        }
        return this
    }
}
