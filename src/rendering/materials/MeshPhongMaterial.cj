/**
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
@JsonAdapter[withSuperClass = Material]
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
        this.kind = "MeshPhongMaterial"
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
