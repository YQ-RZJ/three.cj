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
 * @file[zh-cn] 管道几何体
 * @brief[zh-cn] 沿 3D 曲线挤出的管道几何体
 * @explain[zh-cn] 
 * TubeGeometry 继承自 BufferGeometry，沿 3D 曲线挤出管道。
 * 对应 Three.js geometries/TubeGeometry.js。
 *
 * @file[en] Tube Geometry
 * @brief[en] Tube geometry extruded along a 3D curve
 * @explain[en] 
 * TubeGeometry extends BufferGeometry, extruding a tube along a 3D curve.
 * Corresponds to Three.js geometries/TubeGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 管道几何体类，沿 3D 曲线挤出管道
 * @explain[zh-cn] 
 * 沿 3D 曲线挤出管道，使用 Frenet 帧计算法线和副法线。
 *
 * @brief[en] Tube geometry class, extruding a tube along a 3D curve
 * @explain[en] 
 * Extrudes a tube along a 3D curve, using Frenet frames to compute normals and binormals.
 */
public class TubeGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 构造参数
     *
     * @brief[en] Construction parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造管道几何体
     * @param[zh-cn] path 管道沿着的 3D 曲线
     * tubularSegments 管状分段数，默认 64
     * radius 管道半径，默认 1.0
     * radialSegments 径向分段数，默认 8
     * closed 管道是否闭合，默认 false
     *
     * @brief[en] Constructs a tube geometry
     * @param[en] path 3D curve along which the tube is extruded
     * tubularSegments Tubular segments, default 64
     * radius Tube radius, default 1.0
     * radialSegments Radial segments, default 8
     * closed Whether the tube is closed, default false
     */
    public init(path: Curve, tubularSegments!: Int64 = 64, radius!: Float64 = 1.0, radialSegments!: Int64 = 8, closed!: Bool = false) {
        super()
        this.kind = "TubeGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("path", path); this.parameters.add("tubularSegments", tubularSegments)
        this.parameters.add("radius", radius); this.parameters.add("radialSegments", radialSegments)
        this.parameters.add("closed", closed)

        let tSeg = max(1, tubularSegments); let rSeg = max(3, radialSegments)
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()

        
        // 仓颉侧 Curve.computeFrenetFrames 已完整实现对齐 JS（初始 normal 最小分量 + 累积旋转 + closed 闭合对齐）
        let (tangents, frameNormals, frameBinormals) = path.computeFrenetFrames(tSeg, closed: closed)

        
        // cos = -Math.cos(v)（取负），normal.normalize() 后乘 radius 得顶点
        for (i in 0..=tSeg) {
            
            let p = path.getPointAt(Float64(i) / Float64(tSeg))
            let N = frameNormals[i]
            let B = frameBinormals[i]
            for (j in 0..=rSeg) {
                let v = Float64(j) / Float64(rSeg) * PI * 2.0
                let sinV = sin(v)
                let cosV = -cos(v) 
                
                let nx = cosV * N.x + sinV * B.x
                let ny = cosV * N.y + sinV * B.y
                let nz = cosV * N.z + sinV * B.z
                let nLen = sqrt(nx * nx + ny * ny + nz * nz)
                let nxN = nx / nLen; let nyN = ny / nLen; let nzN = nz / nLen
                normals.add(nxN); normals.add(nyN); normals.add(nzN)
                
                vertices.add(p.x + radius * nxN)
                vertices.add(p.y + radius * nyN)
                vertices.add(p.z + radius * nzN)
            }
        }

        
        for (i in 0..=tSeg) {
            for (j in 0..=rSeg) {
                uvs.add(Float64(i) / Float64(tSeg))
                uvs.add(Float64(j) / Float64(rSeg))
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