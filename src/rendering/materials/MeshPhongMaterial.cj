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
 * @file[zh-cn] Phong材质
 * @brief[zh-cn] Phong材质，支持镜面高光和光泽度
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshPhongMaterial.js。支持 specular/shininess、specularMap、
 * combine、reflectivity/refractionRatio、flatShading。Phong 模型包含环境光、漫反射和镜面高光。
 *
 * @file[en] Mesh Phong Material
 * @brief[en] Phong material, supporting specular highlights and shininess
 * @explain[en] 
 * Corresponds to Three.js materials/MeshPhongMaterial.js. Supports specular/shininess, specularMap,
 * combine, reflectivity/refractionRatio, flatShading. The Phong model includes ambient, diffuse, and specular components.
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
 * @brief[zh-cn] Phong材质，支持镜面高光和光泽度
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshPhongMaterial.js。Phong 模型包含环境光、漫反射和镜面高光。
 *
 * @brief[en] Phong material, supporting specular highlights and shininess
 * @explain[en] 
 * Corresponds to Three.js materials/MeshPhongMaterial.js. The Phong model includes ambient, diffuse, and specular components.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class MeshPhongMaterial <: Material {
    /**
     * @brief[zh-cn] 镜面高光颜色，默认0x111111
     *
     * @brief[en] Specular highlight color, default 0x111111
     */
    public var specular: Color

    /**
     * @brief[zh-cn] 光泽度，默认30
     *
     * @brief[en] Shininess, default 30
     */
    public var shininess: Float64

    /**
     * @brief[zh-cn] 镜面高光贴图
     *
     * @brief[en] Specular highlight map
     */
    public var specularMap: Option<Texture>

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
     * @brief[zh-cn] 构造一个新的Phong材质
     *
     * @brief[en] Construct a new Phong material
     */
    public init() {
        super()
        this.specular = Color(0x111111)
        this.shininess = 30.0
        this.specularMap = None
        this.combine = MultiplyOperation
        this.reflectivity = 1.0
        this.refractionRatio = 0.98
        this.envMap = None
        this.flatShading = false
    }
}
