/**
 * @file[zh-cn] 线段基础材质
 * @brief[zh-cn] 线段基础材质，支持线宽、线帽和线连接样式
 * @explain[zh-cn] 
 * 对应 Three.js materials/LineBasicMaterial.js。支持 linewidth/linecap/linejoin 属性。
 *
 * @file[en] Line Basic Material
 * @brief[en] Basic line material, supporting linewidth, linecap, and linejoin styles
 * @explain[en] 
 * Corresponds to Three.js materials/LineBasicMaterial.js. Supports linewidth, linecap, and linejoin properties.
 */
package three.rendering.materials

import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 线段基础材质，支持线宽、线帽和线连接样式
 * @explain[zh-cn] 
 * 对应 Three.js materials/LineBasicMaterial.js。支持 linewidth/linecap/linejoin 属性。
 *
 * @brief[en] Basic line material, supporting linewidth, linecap, and linejoin styles
 * @explain[en] 
 * Corresponds to Three.js materials/LineBasicMaterial.js. Supports linewidth, linecap, and linejoin properties.
 */
@JsonAdapter[withSuperClass = Material]
public class LineBasicMaterial <: Material {
    /**
     * @brief[zh-cn] 线宽，默认1
     *
     * @brief[en] Line width, default 1
     */
    public var linewidth: Float64

    /**
     * @brief[zh-cn] 线帽样式，可选'round'/'butt'/'square'，默认'round'
     *
     * @brief[en] Line cap style, options 'round'/'butt'/'square', default 'round'
     */
    public var linecap: String

    /**
     * @brief[zh-cn] 线连接样式，可选'round'/'bevel'/'miter'，默认'round'
     *
     * @brief[en] Line join style, options 'round'/'bevel'/'miter', default 'round'
     */
    public var linejoin: String

    /**
     * @brief[zh-cn] 构造一个新的线段基础材质
     *
     * @brief[en] Construct a new line basic material
     */
    public init() {
        super()
        this.kind = "LineBasicMaterial"
        this.linewidth = 1.0
        this.linecap = "round"
        this.linejoin = "round"
    }
}
