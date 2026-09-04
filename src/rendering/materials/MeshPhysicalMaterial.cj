/**
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
    public init() { super(); this.kind = "MeshPhysicalMaterial"; this.roughness = 1.0; this.metalness = 0.0; this.clearcoat = 0.0; this.clearcoatRoughness = 0.0; this.sheen = 0.0; this.transmission = 0.0; this.ior = 1.5; this.thickness = 0.0 }

}
