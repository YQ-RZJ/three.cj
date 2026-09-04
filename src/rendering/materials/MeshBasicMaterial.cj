/**
 * @file[zh-cn] 网格基础材质
 * @brief[zh-cn] 网格基础材质，以简单方式（无光照）渲染几何体
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshBasicMaterial.js。不受光照影响，使用颜色或纹理进行渲染。
 * 支持 map、lightMap、aoMap、specularMap、alphaMap、envMap 等贴图属性，
 * 以及 reflectivity、refractionRatio 等反射/折射参数。
 *
 * @file[en] Mesh Basic Material
 * @brief[en] Mesh basic material, renders geometry in a simple way (no lighting)
 * @explain[en] 
 * Corresponds to Three.js materials/MeshBasicMaterial.js. Not affected by lighting, renders using color or textures.
 * Supports map, lightMap, aoMap, specularMap, alphaMap, envMap and other texture properties,
 * as well as reflectivity, refractionRatio and other reflection/refraction parameters.
 */
package three.rendering.materials

import three.core.math.*
import three.rendering.textures.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 网格基础材质，以简单方式（无光照）渲染几何体
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshBasicMaterial.js。不受光照影响，使用颜色或纹理进行渲染。
 * 支持 map、lightMap、aoMap、specularMap、alphaMap、envMap 等贴图属性。
 *
 * @brief[en] Mesh basic material, renders geometry in a simple way (no lighting)
 * @explain[en] 
 * Corresponds to Three.js materials/MeshBasicMaterial.js. Not affected by lighting, renders using color or textures.
 * Supports map, lightMap, aoMap, specularMap, alphaMap, envMap and other texture properties.
 */
@JsonAdapter[withSuperClass = Material]
public class MeshBasicMaterial <: Material {
    /**
     * @brief[zh-cn] 漫反射颜色贴图
     *
     * @brief[en] Diffuse color map
     */
    public var map: Option<Texture>

    /**
     * @brief[zh-cn] 光照贴图
     *
     * @brief[en] Light map
     */
    public var lightMap: Option<Texture>

    /**
     * @brief[zh-cn] 光照贴图强度，默认1
     *
     * @brief[en] Light map intensity, default 1
     */
    public var lightMapIntensity: Float64

    /**
     * @brief[zh-cn] 环境光遮蔽贴图
     *
     * @brief[en] Ambient occlusion map
     */
    public var aoMap: Option<Texture>

    /**
     * @brief[zh-cn] 环境光遮蔽贴图强度，默认1
     *
     * @brief[en] Ambient occlusion map intensity, default 1
     */
    public var aoMapIntensity: Float64

    /**
     * @brief[zh-cn] 镜面高光贴图
     *
     * @brief[en] Specular highlight map
     */
    public var specularMap: Option<Texture>

    /**
     * @brief[zh-cn] 透明度贴图
     *
     * @brief[en] Alpha map
     */
    public var alphaMap: Option<Texture>

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
     * @brief[zh-cn] 线框线条粗细，默认1
     *
     * @brief[en] Wireframe line width, default 1
     */
    public var wireframeLinewidth: Float64

    /**
     * @brief[zh-cn] 构造一个新的网格基础材质
     *
     * @brief[en] Construct a new mesh basic material
     */
    public init() {
        super()
        this.kind = "MeshBasicMaterial"
        this.color = Color(0xffffff)
        this.map = None
        this.lightMap = None
        this.lightMapIntensity = 1.0
        this.aoMap = None
        this.aoMapIntensity = 1.0
        this.specularMap = None
        this.alphaMap = None
        this.envMap = None
        this.envMapRotation = None
        this.combine = 0
        this.reflectivity = 1.0
        this.refractionRatio = 0.98
        this.wireframe = false
        this.wireframeLinewidth = 1.0
    }

    /**
     * @brief[zh-cn] 将给定MeshBasicMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * recursive 是否递归复制
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given MeshBasicMaterial to this instance
     * @param[en] source Source material
     * recursive Whether to copy recursively
     * @return[en] This instance
     */
    public func copy(source: MeshBasicMaterial, recursive!: Bool = true): MeshBasicMaterial {
        super.copy(source)
        this.color.copy(source.color)
        this.map = source.map
        this.lightMap = source.lightMap
        this.lightMapIntensity = source.lightMapIntensity
        this.aoMap = source.aoMap
        this.aoMapIntensity = source.aoMapIntensity
        this.specularMap = source.specularMap
        this.alphaMap = source.alphaMap
        this.envMap = source.envMap
        this.envMapRotation = source.envMapRotation
        this.combine = source.combine
        this.reflectivity = source.reflectivity
        this.refractionRatio = source.refractionRatio
        this.wireframe = source.wireframe
        this.wireframeLinewidth = source.wireframeLinewidth
        return this
    }
}
