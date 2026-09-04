/**
 * @file[zh-cn] Sprite材质
 * @brief[zh-cn] Sprite材质，用于精灵图渲染，支持尺寸衰减和UV旋转
 * @explain[zh-cn] 
 * 对应 Three.js materials/SpriteMaterial.js。支持 sizeAttenuation/rotation、map/alphaMap、fog。
 * Sprite 材质默认透明（transparent=true）。
 *
 * @file[en] Sprite Material
 * @brief[en] Sprite material, used for sprite rendering, supporting size attenuation and UV rotation
 * @explain[en] 
 * Corresponds to Three.js materials/SpriteMaterial.js. Supports sizeAttenuation/rotation, map/alphaMap, fog.
 * Sprite material is transparent by default (transparent=true).
 */
package three.rendering.materials

import three.rendering.textures.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] Sprite材质，用于精灵图渲染，支持尺寸衰减和UV旋转
 * @explain[zh-cn] 
 * 对应 Three.js materials/SpriteMaterial.js。支持 sizeAttenuation/rotation、map/alphaMap、fog。
 * Sprite 材质默认透明（transparent=true）。
 *
 * @brief[en] Sprite material, used for sprite rendering, supporting size attenuation and UV rotation
 * @explain[en] 
 * Corresponds to Three.js materials/SpriteMaterial.js. Supports sizeAttenuation/rotation, map/alphaMap, fog.
 * Sprite material is transparent by default (transparent=true).
 */
@JsonAdapter[withSuperClass = Material]
public class SpriteMaterial <: Material {
    /**
     * @brief[zh-cn] 是否随距离衰减尺寸，默认true
     *
     * @brief[en] Whether to attenuate size with distance, default true
     */
    public var sizeAttenuation: Bool

    /**
     * @brief[zh-cn] UV旋转弧度，默认0
     *
     * @brief[en] UV rotation in radians, default 0
     */
    public var rotation: Float64

    /**
     * @brief[zh-cn] Sprite纹理贴图
     *
     * @brief[en] Sprite texture map
     */
    public var map: Option<Texture>

    /**
     * @brief[zh-cn] 透明度贴图
     *
     * @brief[en] Alpha map
     */
    public var alphaMap: Option<Texture>

    /**
     * @brief[zh-cn] 构造一个新的Sprite材质
     *
     * @brief[en] Construct a new sprite material
     */
    public init() {
        super()
        this.kind = "SpriteMaterial"
        this.sizeAttenuation = true
        this.rotation = 0.0
        this.map = None
        this.alphaMap = None
        this.fog = true
        
        this.transparent = true
    }

    /**
     * @brief[zh-cn] 将给定Sprite材质实例的值复制到本实例
     * @param[zh-cn] source 源材质
     * recursive 是否递归复制
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the values from the given sprite material instance to this instance
     * @param[en] source Source material
     * recursive Whether to copy recursively
     * @return[en] This instance
     */
    public func copy(source: SpriteMaterial, recursive!: Bool = true): SpriteMaterial {
        super.copy(source)
        this.color.copy(source.color)
        this.sizeAttenuation = source.sizeAttenuation
        this.rotation = source.rotation
        this.map = source.map
        this.alphaMap = source.alphaMap
        return this
    }
}
