/**
 * @file[zh-cn] 二十面体几何体
 * @brief[zh-cn] 二十面体几何体，多面体特例
 * @explain[zh-cn] 
 * 对齐 JS 继承链：IcosahedronGeometry → PolyhedronGeometry → BufferGeometry。
 * 通过 super(vertices, indices, radius, detail) 复用 PolyhedronGeometry 构建。
 * 对应 Three.js geometries/IcosahedronGeometry.js。
 *
 * @file[en] Icosahedron Geometry
 * @brief[en] Icosahedron geometry, a polyhedron special case
 * @explain[en] 
 * Aligned with JS inheritance: IcosahedronGeometry → PolyhedronGeometry → BufferGeometry.
 * Reuses PolyhedronGeometry construction via super(vertices, indices, radius, detail).
 * Corresponds to Three.js geometries/IcosahedronGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/// 黄金比例（super 必须为构造器第一句——常量放顶层）
let I_PHI = (1.0 + sqrt(5.0)) / 2.0

/**
 * @brief[zh-cn] 二十面体几何体（多面体特例）
 * @explain[zh-cn] 
 * 顶点/索引与 JS 一致，通过 super(vertices, indices, radius, detail) 复用 PolyhedronGeometry 构建。
 *
 * @brief[en] Icosahedron geometry (polyhedron special case)
 * @explain[en] 
 * Vertices/indices are consistent with JS, reuses PolyhedronGeometry construction via super(vertices, indices, radius, detail).
 */
public class IcosahedronGeometry <: PolyhedronGeometry {
    /**
     * @brief[zh-cn] 构造二十面体几何体
     * @param[zh-cn] radius 二十面体外接球半径，默认 1.0
     * detail 细分级别，默认 0
     *
     * @brief[en] Constructs an icosahedron geometry
     * @param[en] radius Circumscribed sphere radius, default 1.0
     * detail Subdivision level, default 0
     */
    public init(radius!: Float64 = 1.0, detail!: Int64 = 0) {
        super(
            vertices: [
                -1.0, I_PHI, 0.0, 1.0, I_PHI, 0.0, -1.0, -I_PHI, 0.0, 1.0, -I_PHI, 0.0,
                0.0, -1.0, I_PHI, 0.0, 1.0, I_PHI, 0.0, -1.0, -I_PHI, 0.0, 1.0, -I_PHI,
                I_PHI, 0.0, -1.0, I_PHI, 0.0, 1.0, -I_PHI, 0.0, -1.0, -I_PHI, 0.0, 1.0
            ],
            indices: [
                0, 11, 5, 0, 5, 1, 0, 1, 7, 0, 7, 10, 0, 10, 11,
                1, 5, 9, 5, 11, 4, 11, 10, 2, 10, 7, 6, 7, 1, 8,
                3, 9, 4, 3, 4, 2, 3, 2, 6, 3, 6, 8, 3, 8, 9,
                4, 9, 5, 2, 4, 11, 6, 2, 10, 8, 6, 7, 9, 8, 1
            ],
            radius: radius,
            detail: detail
        )
        this.kind = "IcosahedronGeometry"
    }
}
