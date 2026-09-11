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
 * @file[zh-cn] 圆形几何体
 * @brief[zh-cn] 圆形/扇形几何体，由半径、分段数和角度范围定义
 * @explain[zh-cn] 
 * CircleGeometry 继承自 BufferGeometry，生成圆形或扇形的顶点、法线、UV 和索引数据。
 * 对应 Three.js geometries/CircleGeometry.js。
 *
 * @file[en] Circle Geometry
 * @brief[en] Circle/sector geometry defined by radius, segments and angle range
 * @explain[en] 
 * CircleGeometry extends BufferGeometry, generating vertex, normal, UV and index data for a circle or sector.
 * Corresponds to Three.js geometries/CircleGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 圆形几何体类
 * @explain[zh-cn] 
 * 生成圆形或扇形的顶点、法线、UV 和索引数据。
 *
 * @brief[en] Circle geometry class
 * @explain[en] 
 * Generates vertex, normal, UV and index data for a circle or sector.
 */
public class CircleGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 几何体生成参数
     *
     * @brief[en] Geometry generation parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造圆形几何体
     * @param[zh-cn] radius 半径，默认为 1
     * segments 分段数，默认为 32
     * thetaStart 起始角，默认为 0
     * thetaLength 角度范围，默认为 2π
     *
     * @brief[en] Constructs a circle geometry
     * @param[en] radius Radius, default 1
     * segments Number of segments, default 32
     * thetaStart Start angle, default 0
     * thetaLength Angle length, default 2π
     */
    public init(radius!: Float64 = 1.0, segments!: Int64 = 32, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0) {
        super()
        this.kind = "CircleGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("radius", radius); this.parameters.add("segments", segments)
        this.parameters.add("thetaStart", thetaStart); this.parameters.add("thetaLength", thetaLength)

        let seg = max(3, segments)
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()

        vertices.add(0.0); vertices.add(0.0); vertices.add(0.0)
        normals.add(0.0); normals.add(0.0); normals.add(1.0)
        uvs.add(0.5); uvs.add(0.5)

        for (s in 0..=seg) {
            let segment = thetaStart + Float64(s) / Float64(seg) * thetaLength
            let x = radius * cos(segment); let y = radius * sin(segment)
            vertices.add(x); vertices.add(y); vertices.add(0.0)
            normals.add(0.0); normals.add(0.0); normals.add(1.0)
            uvs.add((x / radius + 1.0) / 2.0); uvs.add((y / radius + 1.0) / 2.0)
        }

        for (i in 1..=seg) { indices.add(i); indices.add(0); indices.add(i + 1) }

        let idxArr = Array<Float64>(indices.size, { i => Float64(indices[i]) })
        this.setIndex(BufferAttribute(idxArr, 1))
        this.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        this.setAttribute("normal", BufferAttribute(normals.toArray(), 3))
        this.setAttribute("uv", BufferAttribute(uvs.toArray(), 2))
    }
}