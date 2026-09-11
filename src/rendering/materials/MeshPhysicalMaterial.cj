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
 * @file[zh-cn] 物理材质
 * @brief[zh-cn] 物理材质，在Standard材质基础上增加清漆、透射等高级PBR属性
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshPhysicalMaterial.js。在 MeshStandardMaterial 基础上增加了 clearcoat、
 * clearcoatRoughness、sheen、transmission、ior、thickness 等物理属性，
 * 用于更精确地模拟真实世界材质（如玻璃、车漆、布料等）。
 *
 * @file[en] Mesh Physical Material
 * @brief[en] Physical material, extending Standard material with advanced PBR properties like clearcoat and transmission
 * @explain[en] 
 * Corresponds to Three.js materials/MeshPhysicalMaterial.js. Extends MeshStandardMaterial with clearcoat,
 * clearcoatRoughness, sheen, transmission, ior, thickness and other physical properties,
 * for more accurate simulation of real-world materials (e.g., glass, car paint, fabric).
 */
package three.rendering.materials

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 物理材质，在Standard材质基础上增加清漆、透射等高级PBR属性
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshPhysicalMaterial.js。增加 clearcoat、clearcoatRoughness、sheen、
 * transmission、ior、thickness 等物理属性，用于模拟真实世界材质。
 *
 * @brief[en] Physical material, extending Standard material with advanced PBR properties like clearcoat and transmission
 * @explain[en] 
 * Corresponds to Three.js materials/MeshPhysicalMaterial.js. Adds clearcoat, clearcoatRoughness, sheen,
 * transmission, ior, thickness and other physical properties for real-world material simulation.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Material]
public class MeshPhysicalMaterial <: Material {
    /**
     * @brief[zh-cn] 粗糙度，默认1
     *
     * @brief[en] Roughness, default 1
     */
    public var roughness: Float64

    /**
     * @brief[zh-cn] 金属度，默认0
     *
     * @brief[en] Metalness, default 0
     */
    public var metalness: Float64

    /**
     * @brief[zh-cn] 清漆层强度，默认0
     *
     * @brief[en] Clearcoat intensity, default 0
     */
    public var clearcoat: Float64

    /**
     * @brief[zh-cn] 清漆层粗糙度，默认0
     *
     * @brief[en] Clearcoat roughness, default 0
     */
    public var clearcoatRoughness: Float64

    /**
     * @brief[zh-cn] 光泽强度，默认0
     *
     * @brief[en] Sheen intensity, default 0
     */
    public var sheen: Float64

    /**
     * @brief[zh-cn] 透射率，默认0
     *
     * @brief[en] Transmission rate, default 0
     */
    public var transmission: Float64

    /**
     * @brief[zh-cn] 折射率，默认1.5
     *
     * @brief[en] Index of refraction, default 1.5
     */
    public var ior: Float64

    /**
     * @brief[zh-cn] 厚度，默认0
     *
     * @brief[en] Thickness, default 0
     */
    public var thickness: Float64

    /**
     * @brief[zh-cn] 构造一个新的物理材质
     *
     * @brief[en] Construct a new physical material
     */
    public init() { super(); this.roughness = 1.0; this.metalness = 0.0; this.clearcoat = 0.0; this.clearcoatRoughness = 0.0; this.sheen = 0.0; this.transmission = 0.0; this.ior = 1.5; this.thickness = 0.0 }

}
