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
 * @file[zh-cn] 矩形面光源
 * @brief[zh-cn] 以矩形面积发光的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/RectAreaLight.js。与其他光源不同，本光源无衰减、不产生阴影。
 * 主要用途：配合 AreaLight 等节点材质使用。
 *
 * @file[en] Rect Area Light
 * @brief[en] A light that emits from a rectangular area
 * @explain[en] 
 * Corresponds to Three.js lights/RectAreaLight.js. Unlike other lights, this light has no decay and does not cast shadows.
 * Main use case: works with AreaLight node materials.
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
 * @brief[zh-cn] 以矩形面积发光的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/RectAreaLight.js。与其他光源不同，本光源无衰减、不产生阴影。
 * 主要用途：配合 AreaLight 等节点材质使用。
 *
 * @brief[en] A light that emits from a rectangular area
 * @explain[en] 
 * Corresponds to Three.js lights/RectAreaLight.js. Unlike other lights, this light has no decay and does not cast shadows.
 * Main use case: works with AreaLight node materials.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Light]
public class RectAreaLight <: Light {

    /**
     * @brief[zh-cn] 矩形宽度，默认10
     *
     * @brief[en] Rectangle width, default 10
     */
    public var width: Float64

    /**
     * @brief[zh-cn] 矩形高度，默认10
     *
     * @brief[en] Rectangle height, default 10
     */
    public var height: Float64

    /**
     * @brief[zh-cn] 构造一个新的矩形面光源
     * @param[zh-cn] color 光源颜色，默认0xffffff
     * intensity 光源强度，默认1
     * width 矩形宽度，默认10
     * height 矩形高度，默认10
     *
     * @brief[en] Construct a new rectangular area light
     * @param[en] color Light color, default 0xffffff
     * intensity Light intensity, default 1
     * width Rectangle width, default 10
     * height Rectangle height, default 10
     */
    public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, width!: Float64 = 10.0, height!: Float64 = 10.0) {
        super(color: color, intensity: intensity)
        this.width = width
        this.height = height
    }

    /**
     * @brief[zh-cn] 直接访问矩形面光源功率（流明）
     * @explain[zh-cn] 
     * 默认从光在矩形面积×立体角内积分计算。
     *
     * @brief[en] Direct access to the rectangular area light power (lumens)
     * @explain[en] 
     * Default is computed from integrating light over the rectangular area times solid angle.
     */
    @JsonIgnore
    public mut prop power: Float64 {
        get() {
            return this.intensity * this.width * this.height * PI
        }
        set(v) {
            this.intensity = v / (this.width * this.height * PI)
        }
    }

    /**
     * @brief[zh-cn] 将给定矩形面光源实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the values from the given rectangular area light instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy child objects
     * @return[en] This instance
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case r: RectAreaLight =>
                this.width = r.width
                this.height = r.height
            case _ => ()
        }
        return this
    }
}
