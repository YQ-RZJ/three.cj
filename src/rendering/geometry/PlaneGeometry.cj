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
 * @file[zh-cn] 平面几何体
 * @brief[zh-cn] 在 XY 平面上生成的矩形平面几何体
 * @explain[zh-cn] 
 * PlaneGeometry 继承自 BufferGeometry，在 XY 平面上生成矩形平面。
 * 对应 Three.js geometries/PlaneGeometry.js。
 *
 * @file[en] Plane Geometry
 * @brief[en] Rectangular plane geometry generated on the XY plane
 * @explain[en] 
 * PlaneGeometry extends BufferGeometry, generating a rectangular plane on the XY plane.
 * Corresponds to Three.js geometries/PlaneGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 平面几何体类
 * @explain[zh-cn] 
 * 在 XY 平面上生成矩形平面，支持宽高和分段数参数。
 *
 * @brief[en] Plane geometry class
 * @explain[en] 
 * Generates a rectangular plane on the XY plane, supporting width, height, and segment parameters.
 */
public class PlaneGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 构造参数
     *
     * @brief[en] Construction parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造平面几何体
     * @param[zh-cn] width 平面宽度，默认 1.0
     * height 平面高度，默认 1.0
     * widthSegments 宽度方向分段数，默认 1
     * heightSegments 高度方向分段数，默认 1
     *
     * @brief[en] Constructs a plane geometry
     * @param[en] width Plane width, default 1.0
     * height Plane height, default 1.0
     * widthSegments Width segments, default 1
     * heightSegments Height segments, default 1
     */
    public init(width!: Float64 = 1.0, height!: Float64 = 1.0, widthSegments!: Int64 = 1, heightSegments!: Int64 = 1) {
        super()
        this.kind = "PlaneGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("width", width); this.parameters.add("height", height)
        this.parameters.add("widthSegments", widthSegments); this.parameters.add("heightSegments", heightSegments)

        let wh = width / 2.0; let hh = height / 2.0
        let gX = max(1, widthSegments); let gY = max(1, heightSegments)
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()

        for (iy in 0..=gY) {
            let y = Float64(iy) * height / Float64(gY) - hh
            for (ix in 0..=gX) {
                let x = Float64(ix) * width / Float64(gX) - wh
                vertices.add(x); vertices.add(-y); vertices.add(0.0)
                normals.add(0.0); normals.add(0.0); normals.add(1.0)
                uvs.add(Float64(ix) / Float64(gX)); uvs.add(1.0 - Float64(iy) / Float64(gY))
            }
        }

        for (iy in 0..gY) {
            for (ix in 0..gX) {
                let a = ix + (gX + 1) * iy
                let b = ix + (gX + 1) * (iy + 1)
                let c = (ix + 1) + (gX + 1) * (iy + 1)
                let d = (ix + 1) + (gX + 1) * iy
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