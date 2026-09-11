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
 * @file[zh-cn] 方向光
 * @brief[zh-cn] 方向光，从特定方向平行照射场景的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/DirectionalLight.js。方向光从无限远处平行照射，
 * 具有 target 对象用于控制照射方向，并支持阴影映射。
 *
 * @file[en] Directional Light
 * @brief[en] Directional light that illuminates the scene from a specific direction
 * @explain[en] 
 * Corresponds to Three.js lights/DirectionalLight.js. Directional light illuminates from
 * infinity in parallel rays, has a target object for controlling direction, and supports shadow mapping.
 */
package three.rendering.lights

import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.cameras.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 方向光，从特定方向平行照射场景的光源
 * @explain[zh-cn] 
 * 方向光从无限远处平行照射，具有 target 对象用于控制照射方向，并支持阴影映射。
 *
 * @brief[en] Directional light that illuminates the scene from a specific direction
 * @explain[en] 
 * Directional light illuminates from infinity in parallel rays,
 * has a target object for controlling direction, and supports shadow mapping.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Light]
public class DirectionalLight <: Light {
    /**
     * @brief[zh-cn] 光源指向的目标对象
     *
     * @brief[en] Target object the light is pointing at
     */
    public var target: Object3D

    /**
     * @brief[zh-cn] 阴影配置对象
     *
     * @brief[en] Shadow configuration object
     */
    @JsonIgnore
    public var shadow: DirectionalLightShadow

    /**
     * @brief[zh-cn] 构造一个新的方向光
     * @param[zh-cn] color 光源颜色，默认 0xffffff
     * intensity 光源强度，默认 1
     *
     * @brief[en] Construct a new directional light
     * @param[en] color Light color, default 0xffffff
     * intensity Light intensity, default 1
     */
    public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0) {
        super(color: color, intensity: intensity)
        this.position.copy(Vector3(0.0, 1.0, 0.0))
        this.target = Object3D()
        this.shadow = DirectionalLightShadow()
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        super.dispose()
        this.shadow.dispose()
    }

    /**
     * @brief[zh-cn] 复制另一个方向光实例的值到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Copy values from another directional light instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Self reference
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: DirectionalLight =>
                this.target = s.target.clone()
                let shadowCopy = s.shadow.clone()
                this.shadow.copy(shadowCopy)
            case _ => ()
        }
        return this
    }
}
