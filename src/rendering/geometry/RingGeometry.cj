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
 * @file[zh-cn] 环形几何体
 * @brief[zh-cn] 在 XY 平面上生成的环形（圆环）几何体
 * @explain[zh-cn] 
 * RingGeometry 继承自 BufferGeometry，在 XY 平面上生成环形几何体。
 * 对应 Three.js geometries/RingGeometry.js。
 *
 * @file[en] Ring Geometry
 * @brief[en] Ring (annulus) geometry generated on the XY plane
 * @explain[en] 
 * RingGeometry extends BufferGeometry, generating a ring geometry on the XY plane.
 * Corresponds to Three.js geometries/RingGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 环形几何体类
 * @explain[zh-cn] 
 * 在 XY 平面上生成环形几何体，支持内外半径、分段数和角度范围参数。
 *
 * @brief[en] Ring geometry class
 * @explain[en] 
 * Generates a ring geometry on the XY plane, supporting inner/outer radius, segments, and angle range parameters.
 */
public class RingGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 构造参数
     *
     * @brief[en] Construction parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造环形几何体
     * @param[zh-cn] innerRadius 内半径，默认 0.5
     * outerRadius 外半径，默认 1.0
     * thetaSegments 圆周分段数，默认 32
     * phiSegments 径向分段数，默认 1
     * thetaStart 起始角（弧度），默认 0
     * thetaLength 圆弧长度（弧度），默认 2π
     *
     * @brief[en] Constructs a ring geometry
     * @param[en] innerRadius Inner radius, default 0.5
     * outerRadius Outer radius, default 1.0
     * thetaSegments Circumferential segments, default 32
     * phiSegments Radial segments, default 1
     * thetaStart Start angle in radians, default 0
     * thetaLength Arc length in radians, default 2π
     */
    public init(innerRadius!: Float64 = 0.5, outerRadius!: Float64 = 1.0, thetaSegments!: Int64 = 32, phiSegments!: Int64 = 1, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0) {
        super()
        this.kind = "RingGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("innerRadius", innerRadius); this.parameters.add("outerRadius", outerRadius)
        this.parameters.add("thetaSegments", thetaSegments); this.parameters.add("phiSegments", phiSegments)
        this.parameters.add("thetaStart", thetaStart); this.parameters.add("thetaLength", thetaLength)

        let tSeg = max(3, thetaSegments); let pSeg = max(1, phiSegments)
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()
        var r = innerRadius
        let rStep = (outerRadius - innerRadius) / Float64(pSeg)

        for (j in 0..=pSeg) {
            for (i in 0..=tSeg) {
                let segment = thetaStart + Float64(i) / Float64(tSeg) * thetaLength
                let x = r * cos(segment); let y = r * sin(segment)
                vertices.add(x); vertices.add(y); vertices.add(0.0)
                normals.add(0.0); normals.add(0.0); normals.add(1.0)
                uvs.add((x / outerRadius + 1.0) / 2.0); uvs.add((y / outerRadius + 1.0) / 2.0)
            }
            r += rStep
        }

        for (j in 0..pSeg) {
            for (i in 0..tSeg) {
                let a = i + (tSeg + 1) * j
                let b = i + (tSeg + 1) * (j + 1)
                let c = (i + 1) + (tSeg + 1) * (j + 1)
                let d = (i + 1) + (tSeg + 1) * j
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