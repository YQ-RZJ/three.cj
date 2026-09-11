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
 * @file[zh-cn] 网格距离材质
 * @brief[zh-cn] 用于实现点光源阴影映射的距离材质
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshDistanceMaterial.js。内部渲染时使用，
 * 也可通过 Object3D.customDistanceMaterial 自定义点光源阴影投射。
 *
 * @file[en] Mesh Distance Material
 * @brief[en] Distance material used for point light shadow mapping
 * @explain[en] 
 * Corresponds to Three.js materials/MeshDistanceMaterial.js. Used internally for rendering,
 * can also customize point light shadow casting via Object3D.customDistanceMaterial.
 */
package three.rendering.materials

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.rendering.textures.*

/**
 * @brief[zh-cn] 用于实现点光源阴影映射的距离材质
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshDistanceMaterial.js。内部渲染时使用，
 * 也可通过 Object3D.customDistanceMaterial 自定义点光源阴影投射。
 *
 * @brief[en] Distance material used for point light shadow mapping
 * @explain[en] 
 * Corresponds to Three.js materials/MeshDistanceMaterial.js. Used internally for rendering,
 * can also customize point light shadow casting via Object3D.customDistanceMaterial.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class MeshDistanceMaterial <: Material {
    /**
     * @brief[zh-cn] 颜色贴图
     *
     * @brief[en] Color map
     */
    public var map: Option<Texture>

    /**
     * @brief[zh-cn] Alpha贴图，灰度纹理控制表面透明度
     *
     * @brief[en] Alpha map, grayscale texture controlling surface transparency
     */
    public var alphaMap: Option<Texture>

    /**
     * @brief[zh-cn] 位移贴图，影响网格顶点位置
     *
     * @brief[en] Displacement map, affects mesh vertex positions
     */
    public var displacementMap: Option<Texture>

    /**
     * @brief[zh-cn] 位移贴图影响强度，默认1
     *
     * @brief[en] Displacement map influence strength, default 1
     */
    public var displacementScale: Float64

    /**
     * @brief[zh-cn] 位移贴图偏移量，默认0
     *
     * @brief[en] Displacement map bias, default 0
     */
    public var displacementBias: Float64

    /**
     * @brief[zh-cn] 构造一个新的网格距离材质
     *
     * @brief[en] Construct a new mesh distance material
     */
    public init() {
        super()
        this.map = None
        this.alphaMap = None
        this.displacementMap = None
        this.displacementScale = 1.0
        this.displacementBias = 0.0
    }

    /**
     * @brief[zh-cn] 将给定MeshDistanceMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given MeshDistanceMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: MeshDistanceMaterial): MeshDistanceMaterial {
        super.copy(source)
        this.map = source.map
        this.alphaMap = source.alphaMap
        this.displacementMap = source.displacementMap
        this.displacementScale = source.displacementScale
        this.displacementBias = source.displacementBias
        return this
    }
}
