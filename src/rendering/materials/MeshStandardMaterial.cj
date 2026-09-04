/**
 * @file[zh-cn] 标准PBR材质
 * @brief[zh-cn] 基于PBR的标准材质，支持金属度/粗糙度工作流
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshStandardMaterial.js。基于物理的渲染（PBR）材质，
 * 使用金属度/粗糙度工作流，支持多种贴图（map、roughnessMap、metalnessMap、normalMap、aoMap等）。
 *
 * @file[en] Mesh Standard Material
 * @brief[en] Standard PBR material, supporting metalness/roughness workflow
 * @explain[en] 
 * Corresponds to Three.js materials/MeshStandardMaterial.js. Physically based rendering (PBR) material
 * using metalness/roughness workflow, supports various texture maps (map, roughnessMap, metalnessMap, normalMap, aoMap, etc.).
 */
package three.rendering.materials

import std.collection.*
import three.core.math.*
import three.rendering.textures.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 基于PBR的标准材质，支持金属度/粗糙度工作流
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshStandardMaterial.js。使用金属度/粗糙度工作流，
 * 支持多种贴图（map、roughnessMap、metalnessMap、normalMap、aoMap等）。
 *
 * @brief[en] Standard PBR material, supporting metalness/roughness workflow
 * @explain[en] 
 * Corresponds to Three.js materials/MeshStandardMaterial.js. Uses metalness/roughness workflow,
 * supports various texture maps (map, roughnessMap, metalnessMap, normalMap, aoMap, etc.).
 */
@JsonAdapter[withSuperClass = Material]
public class MeshStandardMaterial <: Material {
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
     * @brief[zh-cn] 漫反射颜色贴图
     *
     * @brief[en] Diffuse color map
     */
    public var map: Option<Texture>

    /**
     * @brief[zh-cn] 粗糙度贴图（绿色通道）
     *
     * @brief[en] Roughness map (green channel)
     */
    public var roughnessMap: Option<Texture>

    /**
     * @brief[zh-cn] 金属度贴图（蓝色通道）
     *
     * @brief[en] Metalness map (blue channel)
     */
    public var metalnessMap: Option<Texture>

    /**
     * @brief[zh-cn] 法线贴图
     *
     * @brief[en] Normal map
     */
    public var normalMap: Option<Texture>

    /**
     * @brief[zh-cn] 环境光遮蔽贴图（红色通道，需要第二套UV）
     *
     * @brief[en] Ambient occlusion map (red channel, requires second UV set)
     */
    public var aoMap: Option<Texture>

    /**
     * @brief[zh-cn] 自发光贴图
     *
     * @brief[en] Emissive map
     */
    public var emissiveMap: Option<Texture>

    /**
     * @brief[zh-cn] 光照贴图（需要第二套UV）
     *
     * @brief[en] Light map (requires second UV set)
     */
    public var lightMap: Option<Texture>

    /**
     * @brief[zh-cn] 凹凸贴图
     *
     * @brief[en] Bump map
     */
    public var bumpMap: Option<Texture>

    /**
     * @brief[zh-cn] 透明度贴图
     *
     * @brief[en] Alpha map
     */
    public var alphaMap: Option<Texture>

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
     * @brief[zh-cn] 环境光遮蔽贴图强度，默认1
     *
     * @brief[en] Ambient occlusion map intensity, default 1
     */
    public var aoMapIntensity: Float64

    /**
     * @brief[zh-cn] 光照贴图强度，默认1
     *
     * @brief[en] Light map intensity, default 1
     */
    public var lightMapIntensity: Float64

    /**
     * @brief[zh-cn] 法线贴图缩放，默认(1,1)
     *
     * @brief[en] Normal map scale, default (1,1)
     */
    public var normalScale: Vector2

    /**
     * @brief[zh-cn] 凹凸贴图缩放，默认1
     *
     * @brief[en] Bump map scale, default 1
     */
    public var bumpScale: Float64

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
     * @brief[zh-cn] 构造一个新的标准PBR材质
     *
     * @brief[en] Construct a new standard PBR material
     */
    public init() {
        super()
        this.kind = "MeshStandardMaterial"
        this.roughness = 1.0
        this.metalness = 0.0

        // 纹理贴图默认为空
        this.map = None
        this.roughnessMap = None
        this.metalnessMap = None
        this.normalMap = None
        this.aoMap = None
        this.emissiveMap = None
        this.lightMap = None
        this.bumpMap = None
        this.alphaMap = None
        this.envMap = None

        // 标量属性默认值
        this.emissive = Color(0x000000)
        this.emissiveIntensity = 1.0
        this.aoMapIntensity = 1.0
        this.lightMapIntensity = 1.0
        this.normalScale = Vector2(1.0, 1.0)
        this.bumpScale = 1.0
        this.displacementScale = 1.0
        this.displacementBias = 0.0
        this.envMapIntensity = 1.0
    }

}
