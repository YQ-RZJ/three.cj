/**
 * @file[zh-cn] 虚线材质
 * @brief[zh-cn] 虚线材质，在LineBasicMaterial基础上支持虚线样式
 * @explain[zh-cn] 
 * 对应 Three.js materials/LineDashedMaterial.js。在 LineBasicMaterial 基础上增加 dashSize 和 gapSize 属性，
 * 用于控制虚线的线段长度和间隔长度。
 *
 * @file[en] Line Dashed Material
 * @brief[en] Dashed line material, extending LineBasicMaterial with dashed line style
 * @explain[en] 
 * Corresponds to Three.js materials/LineDashedMaterial.js. Adds dashSize and gapSize properties on top of LineBasicMaterial,
 * used to control the dash length and gap length of dashed lines.
 */
package three.rendering.materials

import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 虚线材质，支持dashSize和gapSize
 * @explain[zh-cn] 
 * 对应 Three.js materials/LineDashedMaterial.js。dashSize 控制虚线线段长度，gapSize 控制间隔长度。
 *
 * @brief[en] Dashed line material, supporting dashSize and gapSize
 * @explain[en] 
 * Corresponds to Three.js materials/LineDashedMaterial.js. dashSize controls the dash length, gapSize controls the gap length.
 */
@JsonAdapter[withSuperClass = Material]
public class LineDashedMaterial <: Material {
    /**
     * @brief[zh-cn] 虚线线段长度，默认3
     *
     * @brief[en] Dash size, default 3
     */
    public var dashSize: Float64

    /**
     * @brief[zh-cn] 虚线间隔长度，默认1
     *
     * @brief[en] Gap size, default 1
     */
    public var gapSize: Float64

    /**
     * @brief[zh-cn] 构造一个新的虚线材质
     *
     * @brief[en] Construct a new dashed line material
     */
    public init() { super(); this.kind = "LineDashedMaterial"; this.dashSize = 3.0; this.gapSize = 1.0 }
}
