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
 * @file[zh-cn] 网格深度材质
 * @brief[zh-cn] 基于深度绘制几何体的材质
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshDepthMaterial.js。深度基于相机近远平面计算：白色最近，黑色最远。
 * 主要用于阴影贴图渲染（作为 DirectionalLight/SpotLight 的阴影深度材质），
 * 也可通过 Object3D.customDepthMaterial 自定义物体的深度绘制行为。
 *
 * @file[en] Mesh Depth Material
 * @brief[en] Material that renders geometry based on depth
 * @explain[en] 
 * Corresponds to Three.js materials/MeshDepthMaterial.js. Depth is calculated based on camera near/far planes: white for nearest, black for farthest.
 * Primarily used for shadow map rendering (as the shadow depth material for DirectionalLight/SpotLight),
 * can also customize depth rendering behavior via Object3D.customDepthMaterial.
 */
package three.rendering.materials

import three.rendering.textures.*
import three.utils.constants.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 基于深度绘制几何体的材质
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshDepthMaterial.js。深度基于相机近远平面计算：白色最近，黑色最远。
 * 主要用于阴影贴图渲染，也可通过 Object3D.customDepthMaterial 自定义深度绘制行为。
 *
 * @brief[en] Material that renders geometry based on depth
 * @explain[en] 
 * Corresponds to Three.js materials/MeshDepthMaterial.js. Depth is calculated based on camera near/far planes.
 * Primarily used for shadow map rendering, can also customize via Object3D.customDepthMaterial.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class MeshDepthMaterial <: Material {
    /**
     * @brief[zh-cn] 深度打包类型，默认BasicDepthPacking
     *
     * @brief[en] Depth packing type, default BasicDepthPacking
     */
    public var depthPacking: Int64

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
     * @brief[zh-cn] 线框线条粗细，默认1
     *
     * @brief[en] Wireframe line width, default 1
     */
    public var wireframeLinewidth: Float64

    /**
     * @brief[zh-cn] 构造一个新的网格深度材质
     *
     * @brief[en] Construct a new mesh depth material
     */
    public init() {
        super()
        this.depthPacking = BasicDepthPacking
        this.map = None
        this.alphaMap = None
        this.displacementMap = None
        this.displacementScale = 1.0
        this.displacementBias = 0.0
        this.wireframe = false
        this.wireframeLinewidth = 1.0
    }

    /**
     * @brief[zh-cn] 将给定MeshDepthMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given MeshDepthMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: MeshDepthMaterial): MeshDepthMaterial {
        super.copy(source)
        this.depthPacking = source.depthPacking
        this.map = source.map
        this.alphaMap = source.alphaMap
        this.displacementMap = source.displacementMap
        this.displacementScale = source.displacementScale
        this.displacementBias = source.displacementBias
        this.wireframe = source.wireframe
        this.wireframeLinewidth = source.wireframeLinewidth
        return this
    }
}
