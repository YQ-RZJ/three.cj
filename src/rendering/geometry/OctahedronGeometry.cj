/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] 八面体几何体
 * @brief[zh-cn] 八面体几何体，多面体特例
 * @explain[zh-cn] 
 * 对齐 JS 继承链：OctahedronGeometry → PolyhedronGeometry → BufferGeometry。
 * 通过 super(vertices, indices, radius, detail) 复用 PolyhedronGeometry 构建
 * （顶点投影球面 + 细分 + UV 生成）。
 * 对应 Three.js geometries/OctahedronGeometry.js。
 *
 * @file[en] Octahedron Geometry
 * @brief[en] Octahedron geometry, a polyhedron special case
 * @explain[en] 
 * Aligned with JS inheritance: OctahedronGeometry → PolyhedronGeometry → BufferGeometry.
 * Reuses PolyhedronGeometry construction via super(vertices, indices, radius, detail)
 * (vertex projection onto sphere + subdivision + UV generation).
 * Corresponds to Three.js geometries/OctahedronGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 八面体几何体（多面体特例）
 * @explain[zh-cn] 
 * 顶点/索引与 JS 一致，通过 super(vertices, indices, radius, detail) 复用 PolyhedronGeometry 构建。
 *
 * @brief[en] Octahedron geometry (polyhedron special case)
 * @explain[en] 
 * Vertices/indices are consistent with JS, reuses PolyhedronGeometry construction via super(vertices, indices, radius, detail).
 */
public class OctahedronGeometry <: PolyhedronGeometry {
    /**
     * @brief[zh-cn] 构造八面体几何体
     * @param[zh-cn] radius 八面体外接球半径，默认 1.0
     * detail 细分级别，默认 0
     *
     * @brief[en] Constructs an octahedron geometry
     * @param[en] radius Circumscribed sphere radius, default 1.0
     * detail Subdivision level, default 0
     */
    public init(radius!: Float64 = 1.0, detail!: Int64 = 0) {
        super(
            vertices: [
                1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  0.0, 1.0, 0.0,
                0.0, -1.0, 0.0,  0.0, 0.0, 1.0,  0.0, 0.0, -1.0
            ],
            indices: [
                0, 2, 4,  0, 4, 3,  0, 3, 5,
                0, 5, 2,  1, 2, 5,  1, 5, 3,
                1, 3, 4,  1, 4, 2
            ],
            radius: radius,
            detail: detail
        )
        this.kind = "OctahedronGeometry"
    }

    /**
     * @brief[zh-cn] 从 JSON 数据创建实例的工厂方法
     * @param[zh-cn] data 包含序列化几何体数据的 JSON 对象
     * @return[zh-cn] 新的 OctahedronGeometry 实例
     *
     * @brief[en] Factory method to create an instance from JSON data
     * @param[en] data JSON object containing serialized geometry data
     * @return[en] New OctahedronGeometry instance
     */
    public static func fromJSON(data: HashMap<String, Any>): OctahedronGeometry {
        var r: Float64 = 1.0
        var d: Int64 = 0
        match (data.get("radius")) { case Some(v: Float64) => r = v; case _ => () }
        match (data.get("detail")) { case Some(v: Int64) => d = v; case _ => () }
        return OctahedronGeometry(radius: r, detail: d)
    }
}
