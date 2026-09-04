/**
 * @file[zh-cn] 十二面体几何体
 * @brief[zh-cn] 十二面体几何体，多面体特例
 * @explain[zh-cn] 
 * 对齐 JS 继承链：DodecahedronGeometry → PolyhedronGeometry → BufferGeometry。
 * 通过 super(vertices, indices, radius, detail) 复用 PolyhedronGeometry 构建。
 * 对应 Three.js geometries/DodecahedronGeometry.js。
 *
 * @file[en] Dodecahedron Geometry
 * @brief[en] Dodecahedron geometry, a polyhedron special case
 * @explain[en] 
 * Aligned with JS inheritance: DodecahedronGeometry → PolyhedronGeometry → BufferGeometry.
 * Reuses PolyhedronGeometry construction via super(vertices, indices, radius, detail).
 * Corresponds to Three.js geometries/DodecahedronGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/// 黄金分割相关常量（super 必须为构造器第一句——常量放顶层）
let D_PHI = (1.0 + sqrt(5.0)) / 2.0
let D_R = 1.0 / D_PHI

/**
 * @brief[zh-cn] 十二面体几何体（多面体特例）
 * @explain[zh-cn] 
 * 顶点/索引与 JS 一致，通过 super(vertices, indices, radius, detail) 复用 PolyhedronGeometry 构建。
 *
 * @brief[en] Dodecahedron geometry (polyhedron special case)
 * @explain[en] 
 * Vertices/indices are consistent with JS, reuses PolyhedronGeometry construction via super(vertices, indices, radius, detail).
 */
public class DodecahedronGeometry <: PolyhedronGeometry {
    public init(radius!: Float64 = 1.0, detail!: Int64 = 0) {
        super(
            vertices: [
                // (±1, ±1, ±1)
                -1.0, -1.0, -1.0,  -1.0, -1.0, 1.0,
                -1.0, 1.0, -1.0,  -1.0, 1.0, 1.0,
                1.0, -1.0, -1.0,  1.0, -1.0, 1.0,
                1.0, 1.0, -1.0,  1.0, 1.0, 1.0,
                // (0, ±1/φ, ±φ)
                0.0, -D_R, -D_PHI,  0.0, -D_R, D_PHI,
                0.0, D_R, -D_PHI,  0.0, D_R, D_PHI,
                // (±1/φ, ±φ, 0)
                -D_R, -D_PHI, 0.0,  -D_R, D_PHI, 0.0,
                D_R, -D_PHI, 0.0,  D_R, D_PHI, 0.0,
                // (±φ, 0, ±1/φ)
                -D_PHI, 0.0, -D_R,  D_PHI, 0.0, -D_R,
                -D_PHI, 0.0, D_R,  D_PHI, 0.0, D_R
            ],
            indices: [
                3, 11, 7,  3, 7, 15,  3, 15, 13,
                7, 19, 17,  7, 17, 6,  7, 6, 15,
                17, 4, 8,  17, 8, 10,  17, 10, 6,
                8, 0, 16,  8, 16, 2,  8, 2, 10,
                0, 12, 1,  0, 1, 18,  0, 18, 16,
                6, 10, 2,  6, 2, 13,  6, 13, 15,
                2, 16, 18,  2, 18, 3,  2, 3, 13,
                18, 1, 9,  18, 9, 11,  18, 11, 3,
                4, 14, 12,  4, 12, 0,  4, 0, 8,
                11, 9, 5,  11, 5, 19,  11, 19, 7,
                19, 5, 14,  19, 14, 4,  19, 4, 17,
                1, 12, 14,  1, 14, 5,  1, 5, 9
            ],
            radius: radius,
            detail: detail
        )
        this.kind = "DodecahedronGeometry"
    }
}
