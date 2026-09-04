/**
 * @file[zh-cn] Lambert材质
 * @brief[zh-cn] Lambert材质，支持自发光、环境贴图和flatShading
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshLambertMaterial.js。支持 emissive/map、specularMap、combine、
 * reflectivity/refractionRatio、flatShading。Lambert 模型仅计算漫反射，不考虑镜面高光。
 *
 * @file[en] Mesh Lambert Material
 * @brief[en] Lambert material, supporting emissive, environment map, and flatShading
 * @explain[en] 
 * Corresponds to Three.js materials/MeshLambertMaterial.js. Supports emissive/map, specularMap, combine,
 * reflectivity/refractionRatio, flatShading. The Lambert model only calculates diffuse reflection, without specular highlights.
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
 * @brief[zh-cn] Lambert材质，支持自发光、环境贴图和flatShading
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshLambertMaterial.js。Lambert 模型仅计算漫反射，不考虑镜面高光。
 *
 * @brief[en] Lambert material, supporting emissive, environment map, and flatShading
 * @explain[en] 
 * Corresponds to Three.js materials/MeshLambertMaterial.js. The Lambert model only calculates diffuse reflection.
 */
@JsonAdapter[withSuperClass = Material]
public class MeshLambertMaterial <: Material {
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
     * @brief[zh-cn] 漫反射贴图
     *
     * @brief[en] Diffuse map
     */
    public var map: Option<Texture>

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
     * @brief[zh-cn] 构造一个新的Lambert材质
     *
     * @brief[en] Construct a new Lambert material
     */
    public init() {
        super()
        this.kind = "MeshLambertMaterial"
        this.emissive = Color(0x000000)
        this.emissiveIntensity = 1.0
        this.map = None
        this.specularMap = None
        this.emissiveMap = None
        this.combine = MultiplyOperation
        this.reflectivity = 1.0
        this.refractionRatio = 0.98
        this.envMap = None
        this.flatShading = false
    }
}
