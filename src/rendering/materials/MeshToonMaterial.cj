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
 * @file[zh-cn] Toon材质
 * @brief[zh-cn] 卡通材质，使用渐变贴图控制明暗分界实现卡通渲染效果
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshToonMaterial.js。支持 gradiantMap（渐变贴图控制明暗分界）、
 * specularMap、combine、reflectivity/refractionRatio。
 *
 * @file[en] Mesh Toon Material
 * @brief[en] Toon material, using gradient map to control light/dark boundaries for cartoon rendering
 * @explain[en] 
 * Corresponds to Three.js materials/MeshToonMaterial.js. Supports gradiantMap (gradient map controlling light/dark boundaries),
 * specularMap, combine, reflectivity/refractionRatio.
 */
package three.rendering.materials

import three.core.math.*
import three.rendering.textures.*
import three.utils.constants.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 卡通材质，使用渐变贴图控制明暗分界实现卡通渲染效果
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshToonMaterial.js。通过 gradiantMap 渐变贴图控制明暗分界。
 *
 * @brief[en] Toon material, using gradient map to control light/dark boundaries for cartoon rendering
 * @explain[en] 
 * Corresponds to Three.js materials/MeshToonMaterial.js. Controls light/dark boundaries via gradiantMap.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class MeshToonMaterial <: Material {
    /**
     * @brief[zh-cn] 渐变贴图，控制明暗分界
     *
     * @brief[en] Gradient map, controls light/dark boundaries
     */
    public var gradiantMap: Option<Texture>

    /**
     * @brief[zh-cn] 镜面高光贴图
     *
     * @brief[en] Specular highlight map
     */
    public var specularMap: Option<Texture>

    /**
     * @brief[zh-cn] 自发光贴图
     *
     * @brief[en] Emissive map
     */
    public var emissiveMap: Option<Texture>

    /**
     * @brief[zh-cn] 漫反射贴图
     *
     * @brief[en] Diffuse map
     */
    public var map: Option<Texture>

    /**
     * @brief[zh-cn] 环境贴图与漫反射的组合方式
     *
     * @brief[en] Environment map and diffuse combination mode
     */
    public var combine: Int64

    /**
     * @brief[zh-cn] 环境贴图反射强度，默认1
     *
     * @brief[en] Environment map reflectivity, default 1
     */
    public var reflectivity: Float64

    /**
     * @brief[zh-cn] 折射率，默认0.98
     *
     * @brief[en] Refraction ratio, default 0.98
     */
    public var refractionRatio: Float64

    /**
     * @brief[zh-cn] 自发光颜色，默认0x000000
     *
     * @brief[en] Emissive color, default 0x000000
     */
    public var emissive: Color

    /**
     * @brief[zh-cn] 自发光强度，默认1
     *
     * @brief[en] Emissive intensity, default 1
     */
    public var emissiveIntensity: Float64

    /**
     * @brief[zh-cn] 构造一个新的卡通材质
     *
     * @brief[en] Construct a new toon material
     */
    public init() {
        super()
        this.gradiantMap = None
        this.specularMap = None
        this.emissiveMap = None
        this.map = None
        this.envMap = None
        this.combine = MultiplyOperation
        this.reflectivity = 1.0
        this.refractionRatio = 0.98
        this.emissive = Color(0x000000)
        this.emissiveIntensity = 1.0
        this.flatShading = false
    }
}
