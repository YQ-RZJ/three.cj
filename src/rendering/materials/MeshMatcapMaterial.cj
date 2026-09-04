/**
 * @file[zh-cn] Matcap材质
 * @brief[zh-cn] Matcap材质，使用材质捕获贴图进行渲染
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshMatcapMaterial.js。支持 matcap 贴图（材质捕获贴图）、flatShading、map。
 * Matcap 通过法线方向在贴图中采样颜色，无需光照计算即可呈现丰富的材质效果。
 *
 * @file[en] Mesh Matcap Material
 * @brief[en] Matcap material, rendered using a material capture texture
 * @explain[en] 
 * Corresponds to Three.js materials/MeshMatcapMaterial.js. Supports matcap texture (material capture texture), flatShading, map.
 * Matcap samples color from a texture based on normal direction, presenting rich material effects without lighting calculations.
 */
package three.rendering.materials

import three.core.math.*
import three.rendering.textures.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] Matcap材质，使用材质捕获贴图进行渲染
 * @explain[zh-cn] 
 * 对应 Three.js materials/MeshMatcapMaterial.js。通过法线方向在matcap贴图中采样颜色，无需光照计算。
 *
 * @brief[en] Matcap material, rendered using a material capture texture
 * @explain[en] 
 * Corresponds to Three.js materials/MeshMatcapMaterial.js. Samples color from matcap texture based on normal direction, no lighting calculation needed.
 */
@JsonAdapter[withSuperClass = Material]
public class MeshMatcapMaterial <: Material {
    /**
     * @brief[zh-cn] 材质捕获贴图
     *
     * @brief[en] Material capture texture
     */
    public var matcap: Option<Texture>

    /**
     * @brief[zh-cn] 漫反射贴图
     *
     * @brief[en] Diffuse map
     */
    public var map: Option<Texture>

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
     * @brief[zh-cn] 构造一个新的Matcap材质
     *
     * @brief[en] Construct a new Matcap material
     */
    public init() {
        super()
        this.kind = "MeshMatcapMaterial"
        this.matcap = None
        this.map = None
        this.bumpMap = None
        this.bumpScale = 1.0
        this.normalMap = None
        this.normalScale = Vector2(1.0, 1.0)
        this.flatShading = false
    }
}
