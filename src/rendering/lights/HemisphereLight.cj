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
 * @file[zh-cn] 半球光
 * @brief[zh-cn] 半球光，从天顶与地底两方向照射的光源
 * @explain[zh-cn] 
 * 对应 Three.js lights/HemisphereLight.js。颜色随物体法线方向渐变：
 * 法线朝上取 skyColor，朝下取 groundColor，其余按法线方向混合。
 *
 * @file[en] Hemisphere Light
 * @brief[en] Hemisphere light illuminating from sky and ground directions
 * @explain[en] 
 * Corresponds to Three.js lights/HemisphereLight.js. Color gradient based on surface normal:
 * skyColor for upward normals, groundColor for downward, blended in between.
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
 * @brief[zh-cn] 半球光，从天顶与地底两方向照射的光源
 * @explain[zh-cn] 
 * 颜色随物体法线方向渐变：法线朝上取 skyColor，朝下取 groundColor，其余按法线方向混合。
 *
 * @brief[en] Hemisphere light illuminating from sky and ground directions
 * @explain[en] 
 * Color gradient based on surface normal: skyColor for upward normals,
 * groundColor for downward, blended in between.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Light]
public class HemisphereLight <: Light {

    /**
     * @brief[zh-cn] 顶部（天顶）方向光的颜色
     *
     * @brief[en] Sky (top) direction light color
     */
    public var skyColor: Color

    /**
     * @brief[zh-cn] 底部（地底）方向光的颜色
     *
     * @brief[en] Ground (bottom) direction light color
     */
    public var groundColor: Color

    /**
     * @brief[zh-cn] 构造一个新的半球光
     * @param[zh-cn] skyColor 顶部方向光的颜色，默认 0xffffff
     * groundColor 底部方向光的颜色，默认 0x000000
     * intensity 光源强度，默认 1
     *
     * @brief[en] Construct a new hemisphere light
     * @param[en] skyColor Sky direction light color, default 0xffffff
     * groundColor Ground direction light color, default 0x000000
     * intensity Light intensity, default 1
     */
    public init(skyColor!: Color = Color(0xffffff), groundColor!: Color = Color(0x000000), intensity!: Float64 = 1.0) {
        super(color: skyColor, intensity: intensity)
        this.skyColor = skyColor.clone()
        this.groundColor = groundColor.clone()
        this.position.copy(Vector3(0.0, 1.0, 0.0))
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public override func dispose(): Unit {
        super.dispose()
    }

    /**
     * @brief[zh-cn] 复制另一个半球光实例的值到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Copy values from another hemisphere light instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Self reference
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case h: HemisphereLight =>
                this.skyColor.copy(h.skyColor)
                this.groundColor.copy(h.groundColor)
            case _ => ()
        }
        return this
    }
}
