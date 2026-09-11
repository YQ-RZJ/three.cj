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
 * @file[zh-cn] 球体几何体
 * @brief[zh-cn] 球体几何体，由经纬线网格构成
 * @explain[zh-cn] 
 * SphereGeometry 继承自 BufferGeometry，生成球体的顶点、法线、UV 和索引数据。
 * 对应 Three.js geometries/SphereGeometry.js。
 *
 * @file[en] Sphere Geometry
 * @brief[en] Sphere geometry composed of latitude/longitude grid lines
 * @explain[en] 
 * SphereGeometry extends BufferGeometry, generating vertex, normal, UV and index data for a sphere.
 * Corresponds to Three.js geometries/SphereGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 球体几何体类
 * @explain[zh-cn] 
 * 生成球体的顶点、法线、UV 和索引数据，支持半径、分段数和角度范围参数。
 *
 * @brief[en] Sphere geometry class
 * @explain[en] 
 * Generates vertex, normal, UV and index data for a sphere, supporting radius, segments, and angle range parameters.
 */
public class SphereGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 构造参数
     *
     * @brief[en] Construction parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造球体几何体
     * @param[zh-cn] radius 球体半径，默认 1.0
     * widthSegments 水平分段数，默认 32
     * heightSegments 垂直分段数，默认 16
     * phiStart 水平起始角，默认 0
     * phiLength 水平弧长，默认 2π
     * thetaStart 垂直起始角，默认 0
     * thetaLength 垂直弧长，默认 π
     *
     * @brief[en] Constructs a sphere geometry
     * @param[en] radius Sphere radius, default 1.0
     * widthSegments Horizontal segments, default 32
     * heightSegments Vertical segments, default 16
     * phiStart Horizontal start angle, default 0
     * phiLength Horizontal arc length, default 2π
     * thetaStart Vertical start angle, default 0
     * thetaLength Vertical arc length, default π
     */
    public init(radius!: Float64 = 1.0, widthSegments!: Int64 = 32, heightSegments!: Int64 = 16, phiStart!: Float64 = 0.0, phiLength!: Float64 = PI * 2.0, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI) {
        super()
        this.kind = "SphereGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("radius", radius); this.parameters.add("widthSegments", widthSegments)
        this.parameters.add("heightSegments", heightSegments); this.parameters.add("phiStart", phiStart)
        this.parameters.add("phiLength", phiLength); this.parameters.add("thetaStart", thetaStart)
        this.parameters.add("thetaLength", thetaLength)

        let wSeg = max(3, widthSegments); let hSeg = max(2, heightSegments)
        let thetaEnd = min(thetaStart + thetaLength, PI)
        var index: Int64 = 0; let grid = ArrayList<ArrayList<Int64>>()
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>(); let indices = ArrayList<Int64>()

        for (iy in 0..=hSeg) {
            let verticesRow = ArrayList<Int64>()
            let v = Float64(iy) / Float64(hSeg)
            let theta = thetaStart + v * thetaLength
            let y = radius * cos(theta)
            let ringRadius = sqrt(radius * radius - y * y)
            let uOffset = if (iy == 0 && thetaStart == 0.0) { 0.5 / Float64(wSeg) } else if (iy == hSeg && thetaEnd == PI) { -0.5 / Float64(wSeg) } else { 0.0 }
            for (ix in 0..=wSeg) {
                let u = Float64(ix) / Float64(wSeg)
                let phi = phiStart + u * phiLength
                let x = -ringRadius * cos(phi); let yv = y; let z = ringRadius * sin(phi)
                let len = sqrt(x * x + yv * yv + z * z)
                vertices.add(x); vertices.add(yv); vertices.add(z)
                normals.add(x / len); normals.add(yv / len); normals.add(z / len)
                uvs.add(u + uOffset); uvs.add(1.0 - v)
                verticesRow.add(index); index += 1
            }
            grid.add(verticesRow)
        }

        for (iy in 0..hSeg) {
            for (ix in 0..wSeg) {
                let a = grid[iy][ix + 1]; let b = grid[iy][ix]; let c = grid[iy + 1][ix]; let d = grid[iy + 1][ix + 1]
                if (iy != 0 || thetaStart > 0.0) { indices.add(a); indices.add(b); indices.add(d) }
                if (iy != hSeg - 1 || thetaEnd < PI) { indices.add(b); indices.add(c); indices.add(d) }
            }
        }

        let idxArr = Array<Float64>(indices.size, { i => Float64(indices[i]) })
        this.setIndex(BufferAttribute(idxArr, 1))
        this.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        this.setAttribute("normal", BufferAttribute(normals.toArray(), 3))
        this.setAttribute("uv", BufferAttribute(uvs.toArray(), 2))
    }
}