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
 * @file[zh-cn] 法线材质
 * @brief[zh-cn] 法线材质，将法线向量映射为RGB颜色进行渲染
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshNormalMaterial.js。支持 normalMap/bumpMap/displacementMap、flatShading、wireframe。
 * 将法线方向映射为颜色，常用于调试法线方向。
 *
 * @file[en] Mesh Normal Material
 * @brief[en] Normal material, renders normal vectors as RGB colors
 * @explain[en] 
 * Corresponds to Three.js materials/MeshNormalMaterial.js. Supports normalMap/bumpMap/displacementMap, flatShading, wireframe.
 * Maps normal directions to colors, commonly used for debugging normal directions.
 */
package three.rendering.materials

import three.core.math.*
import three.rendering.textures.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 法线材质，将法线向量映射为RGB颜色进行渲染
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshNormalMaterial.js。将法线方向映射为颜色，常用于调试法线方向。
 *
 * @brief[en] Normal material, renders normal vectors as RGB colors
 * @explain[en] 
 * Corresponds to Three.js materials/MeshNormalMaterial.js. Maps normal directions to colors, commonly used for debugging.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class MeshNormalMaterial <: Material {
    /**
     * @brief[zh-cn] 法线贴图
     *
     * @brief[en] Normal map
     */
    public var normalMap: Option<Texture>

    /**
     * @brief[zh-cn] 法线贴图缩放，默认(1,1)
     *
     * @brief[en] Normal map scale, default (1,1)
     */
    public var normalScale: Vector2

    /**
     * @brief[zh-cn] 凹凸贴图
     *
     * @brief[en] Bump map
     */
    public var bumpMap: Option<Texture>

    /**
     * @brief[zh-cn] 凹凸贴图缩放，默认1
     *
     * @brief[en] Bump map scale, default 1
     */
    public var bumpScale: Float64

    /**
     * @brief[zh-cn] 位移贴图
     *
     * @brief[en] Displacement map
     */
    public var displacementMap: Option<Texture>

    /**
     * @brief[zh-cn] 位移贴图缩放，默认1
     *
     * @brief[en] Displacement map scale, default 1
     */
    public var displacementScale: Float64

    /**
     * @brief[zh-cn] 位移贴图偏移量，默认0
     *
     * @brief[en] Displacement map bias, default 0
     */
    public var displacementBias: Float64

    /**
     * @brief[zh-cn] 构造一个新的法线材质
     *
     * @brief[en] Construct a new normal material
     */
    public init() {
        super()
        this.normalMap = None
        this.normalScale = Vector2(1.0, 1.0)
        this.bumpMap = None
        this.bumpScale = 1.0
        this.displacementMap = None
        this.displacementScale = 1.0
        this.displacementBias = 0.0
        this.flatShading = false
        this.wireframe = false
    }
}
