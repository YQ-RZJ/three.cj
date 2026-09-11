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
 * @file[zh-cn] 环面纽结几何体
 * @brief[zh-cn] 环面纽结（扭结环）几何体
 * @explain[zh-cn] 
 * TorusKnotGeometry 继承自 BufferGeometry，生成环面纽结的顶点、法线、UV 和索引数据。
 * 对应 Three.js geometries/TorusKnotGeometry.js。
 *
 * @file[en] Torus Knot Geometry
 * @brief[en] Torus knot (knotted ring) geometry
 * @explain[en] 
 * TorusKnotGeometry extends BufferGeometry, generating vertex, normal, UV and index data for a torus knot.
 * Corresponds to Three.js geometries/TorusKnotGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 环面纽结几何体类
 * @explain[zh-cn] 
 * 生成环面纽结的顶点、法线、UV 和索引数据，支持半径、管半径、分段数和 p/q 参数。
 *
 * @brief[en] Torus knot geometry class
 * @explain[en] 
 * Generates vertex, normal, UV and index data for a torus knot, supporting radius, tube radius, segments, and p/q parameters.
 */
public class TorusKnotGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 构造参数
     *
     * @brief[en] Construction parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造环面纽结几何体
     * @param[zh-cn] radius 环面纽结半径，默认 1.0
     * tube 管半径，默认 0.4
     * tubularSegments 管状分段数，默认 64
     * radialSegments 径向分段数，默认 8
     * p 缠绕次数 p，默认 2
     * q 缠绕次数 q，默认 3
     *
     * @brief[en] Constructs a torus knot geometry
     * @param[en] radius Torus knot radius, default 1.0
     * tube Tube radius, default 0.4
     * tubularSegments Tubular segments, default 64
     * radialSegments Radial segments, default 8
     * p Winding number p, default 2
     * q Winding number q, default 3
     */
    public init(radius!: Float64 = 1.0, tube!: Float64 = 0.4, tubularSegments!: Int64 = 64, radialSegments!: Int64 = 8, p!: Int64 = 2, q!: Int64 = 3) {
        super()
        this.kind = "TorusKnotGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("radius", radius); this.parameters.add("tube", tube)
        this.parameters.add("tubularSegments", tubularSegments); this.parameters.add("radialSegments", radialSegments)
        this.parameters.add("p", p); this.parameters.add("q", q)

        let tSeg = tubularSegments; let rSeg = radialSegments
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()

        for (i in 0..=tSeg) {
            let u = Float64(i) / Float64(tSeg) * Float64(p) * PI * 2.0
            let cu = cos(u); let su = sin(u)
            let quOverP = Float64(q) / Float64(p) * u
            let cs = cos(quOverP)
            let p1x = radius * (2.0 + cs) * 0.5 * cu
            let p1y = radius * (2.0 + cs) * su * 0.5
            let p1z = radius * sin(quOverP) * 0.5
            let u2 = u + 0.01
            let cu2 = cos(u2); let su2 = sin(u2)
            let cs2 = cos(Float64(q) / Float64(p) * u2)
            let p2x = radius * (2.0 + cs2) * 0.5 * cu2
            let p2y = radius * (2.0 + cs2) * su2 * 0.5
            let p2z = radius * sin(Float64(q) / Float64(p) * u2) * 0.5
            let tx = p2x - p1x; let ty = p2y - p1y; let tz = p2z - p1z
            let nx = p2x + p1x; let ny = p2y + p1y; let nz = p2z + p1z
            let bx = ty * nz - tz * ny; let by = tz * nx - tx * nz; let bz = tx * ny - ty * nx
            let blen = sqrt(bx*bx + by*by + bz*bz)
            let n2x = by * tz - bz * ty; let n2y = bz * tx - bx * tz; let n2z = bx * ty - by * tx
            let n2len = sqrt(n2x*n2x + n2y*n2y + n2z*n2z)
            let bnx = bx / blen; let bny = by / blen; let bnz = bz / blen
            let nnx = n2x / n2len; let nny = n2y / n2len; let nnz = n2z / n2len
            for (j in 0..=rSeg) {
                let v = Float64(j) / Float64(rSeg) * PI * 2.0
                let cx = -tube * cos(v); let cy = tube * sin(v)
                let vx = p1x + (cx * nnx + cy * bnx)
                let vy = p1y + (cx * nny + cy * bny)
                let vz = p1z + (cx * nnz + cy * bnz)
                vertices.add(vx); vertices.add(vy); vertices.add(vz)
                let vl = sqrt((vx-p1x)*(vx-p1x)+(vy-p1y)*(vy-p1y)+(vz-p1z)*(vz-p1z))
                normals.add((vx-p1x)/vl); normals.add((vy-p1y)/vl); normals.add((vz-p1z)/vl)
                uvs.add(Float64(i) / Float64(tSeg)); uvs.add(Float64(j) / Float64(rSeg))
            }
        }

        for (j in 1..=tSeg) {
            for (i in 1..=rSeg) {
                let a = (rSeg + 1) * (j - 1) + (i - 1)
                let b = (rSeg + 1) * j + (i - 1)
                let c = (rSeg + 1) * j + i
                let d = (rSeg + 1) * (j - 1) + i
                indices.add(a); indices.add(b); indices.add(d)
                indices.add(b); indices.add(c); indices.add(d)
            }
        }

        let idxArr = Array<Float64>(indices.size, { i => Float64(indices[i]) })
        this.setIndex(BufferAttribute(idxArr, 1))
        this.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        this.setAttribute("normal", BufferAttribute(normals.toArray(), 3))
        this.setAttribute("uv", BufferAttribute(uvs.toArray(), 2))
    }
}