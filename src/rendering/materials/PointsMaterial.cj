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
 * @file[zh-cn] 点材质
 * @brief[zh-cn] 点材质，用于点云渲染，支持点大小和距离衰减
 * @explain[zh-cn] 
 * 对应 Three.js materials/PointsMaterial.js。支持 size/sizeAttenuation、map/alphaMap。
 *
 * @file[en] Points Material
 * @brief[en] Points material, used for point cloud rendering, supporting point size and distance attenuation
 * @explain[en] 
 * Corresponds to Three.js materials/PointsMaterial.js. Supports size/sizeAttenuation, map/alphaMap.
 */
package three.rendering.materials

import three.rendering.textures.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 点材质，用于点云渲染，支持点大小和距离衰减
 * @explain[zh-cn] 
 * 对应 Three.js materials/PointsMaterial.js。支持 size/sizeAttenuation、map/alphaMap。
 *
 * @brief[en] Points material, used for point cloud rendering, supporting point size and distance attenuation
 * @explain[en] 
 * Corresponds to Three.js materials/PointsMaterial.js. Supports size/sizeAttenuation, map/alphaMap.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class PointsMaterial <: Material {
    /**
     * @brief[zh-cn] 点大小，默认1
     *
     * @brief[en] Point size, default 1
     */
    public var size: Float64

    /**
     * @brief[zh-cn] 是否随距离衰减，默认true
     *
     * @brief[en] Whether to attenuate with distance, default true
     */
    public var sizeAttenuation: Bool

    /**
     * @brief[zh-cn] 点纹理贴图
     *
     * @brief[en] Point texture map
     */
    public var map: Option<Texture>

    /**
     * @brief[zh-cn] 透明度贴图
     *
     * @brief[en] Alpha map
     */
    public var alphaMap: Option<Texture>

    /**
     * @brief[zh-cn] 构造一个新的点材质
     *
     * @brief[en] Construct a new points material
     */
    public init() {
        super()
        this.size = 1.0
        this.sizeAttenuation = true
        this.map = None
        this.alphaMap = None
    }

    /**
     * @brief[zh-cn] 将给定点材质实例的值复制到本实例
     * @param[zh-cn] source 源材质
     * recursive 是否递归复制
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the values from the given points material instance to this instance
     * @param[en] source Source material
     * recursive Whether to copy recursively
     * @return[en] This instance
     */
    public func copy(source: PointsMaterial, recursive!: Bool = true): PointsMaterial {
        super.copy(source)
        this.color.copy(source.color)
        this.size = source.size
        this.sizeAttenuation = source.sizeAttenuation
        this.map = source.map
        this.alphaMap = source.alphaMap
        return this
    }
}
