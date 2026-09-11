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
 * @file[zh-cn] 光源基类
 * @brief[zh-cn] 光源抽象基类，所有具体光源类型继承本类
 * @explain[zh-cn] 
 * 对应 Three.js lights/Light.js。继承自 Object3D，故光源本身可参与场景图（携带位置/朝向/变换）。
 * 定义光源颜色、强度等通用属性。
 *
 * @file[en] Light Base Class
 * @brief[en] Abstract base class for all light types
 * @explain[en] 
 * Corresponds to Three.js lights/Light.js. Inherits from Object3D so lights can participate
 * in the scene graph (carrying position/orientation/transform). Defines common properties like color and intensity.
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
 * @brief[zh-cn] 光源抽象基类，所有具体光源类型继承本类
 * @explain[zh-cn] 
 * 继承自 Object3D，故光源本身可参与场景图（携带位置/朝向/变换）。
 * 定义光源颜色、强度等通用属性。
 *
 * @brief[en] Abstract base class for all light types
 * @explain[en] 
 * Inherits from Object3D so lights can participate in the scene graph.
 * Defines common properties like color and intensity.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Object3D]
public open class Light <: Object3D {

    /**
     * @brief[zh-cn] 光源颜色
     *
     * @brief[en] Light color
     */
    public var color: Color

    /**
     * @brief[zh-cn] 光源强度，默认 1
     *
     * @brief[en] Light intensity, default 1
     */
    public var intensity: Float64

    /**
     * @brief[zh-cn] 构造一个新的光源
     * @param[zh-cn] color 光源颜色，默认 0xffffff
     * intensity 光源强度，默认 1
     *
     * @brief[en] Construct a new light
     * @param[en] color Light color, default 0xffffff
     * intensity Light intensity, default 1
     */
    public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0) {
        super()
        this.color = color.clone()
        this.intensity = intensity
    }

    /**
     * @brief[zh-cn] 构造一个新的光源（以 UInt32 颜色值构造）
     * @param[zh-cn] hex 颜色十六进制值
     * intensity 光源强度，默认 1
     *
     * @brief[en] Construct a new light with UInt32 color value
     * @param[en] hex Color hexadecimal value
     * intensity Light intensity, default 1
     */
    public init(hex: UInt32, intensity!: Float64 = 1.0) {
        super()
        this.color = Color(hex)
        this.intensity = intensity
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public open func dispose(): Unit {
        this.dispatchEvent(Event("dispose"))
    }

    /**
     * @brief[zh-cn] 复制另一个光源实例的值到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Copy values from another light instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Self reference
     */
    public open func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case l: Light =>
                this.color.copy(l.color)
                this.intensity = l.intensity
            case _ => ()
        }
        return this
    }
}
