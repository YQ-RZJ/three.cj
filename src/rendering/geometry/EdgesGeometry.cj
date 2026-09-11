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
 * @file[zh-cn] 边线几何体
 * @brief[zh-cn] 从 BufferGeometry 中提取边线，基于相邻面法线夹角阈值
 * @explain[zh-cn] 
 * EdgesGeometry 继承自 BufferGeometry，通过阈值角度控制：仅当相邻面法线夹角超过阈值时才生成边线。
 * 对应 Three.js geometries/EdgesGeometry.js。
 *
 * @file[en] Edges Geometry
 * @brief[en] Extracts edges from BufferGeometry based on adjacent face normal angle threshold
 * @explain[en] 
 * EdgesGeometry extends BufferGeometry, controlled by threshold angle: edges are generated only when the angle between adjacent face normals exceeds the threshold.
 * Corresponds to Three.js geometries/EdgesGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 边线几何体类，从 BufferGeometry 中提取边线
 * @explain[zh-cn] 
 * 通过阈值角度控制：仅当相邻面法线夹角超过阈值时才生成边线。
 *
 * @brief[en] Edges geometry class, extracts edges from BufferGeometry
 * @explain[en] 
 * Controlled by threshold angle: edges are generated only when the angle between adjacent face normals exceeds the threshold.
 */
public class EdgesGeometry <: BufferGeometry {
    public var parameters: HashMap<String, Any>

    public init(geometry: BufferGeometry, thresholdAngle!: Float64 = 1.0) {
        super()
        this.kind = "EdgesGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("geometry", geometry); this.parameters.add("thresholdAngle", thresholdAngle)

        
        let precisionPoints = 4
        let precision = pow(10.0, Float64(precisionPoints))
        let thresholdDot = cos(DEG2RAD * thresholdAngle)

        let indexAttr = geometry.getIndex()
        let positionAttr = geometry.getAttribute("position")
        let indexCount = match (indexAttr) {
            case Some(idx) => idx.count
            case None => match (positionAttr) {
                case Some(p) => p.count
                case None => 0
            }
        }

        let vertices = ArrayList<Float64>()
        // edgeData: 边的 hash -> (index0, index1, normal)，仅存"半边"对应邻接三角形数据
        let edgeData = HashMap<String, ?(Int64, Int64, Vector3)>()
        // 复用临时对象
        let v0 = Vector3(); let v1 = Vector3()
        let normal = Vector3()
        let aV = Vector3(); let bV = Vector3(); let cV = Vector3()

        var i = 0
        while (i < indexCount) {
            // 三角形顶点索引
            let i0 = match (indexAttr) {
                case Some(idx) => Int64(idx.getX(i))
                case None => i
            }
            let i1 = match (indexAttr) {
                case Some(idx) => Int64(idx.getX(i + 1))
                case None => i + 1
            }
            let i2 = match (indexAttr) {
                case Some(idx) => Int64(idx.getX(i + 2))
                case None => i + 2
            }
            // 取三顶点位置
            match (positionAttr) {
                case Some(pa) =>
                    aV.set(pa.getX(i0), pa.getY(i0), pa.getZ(i0))
                    bV.set(pa.getX(i1), pa.getY(i1), pa.getZ(i1))
                    cV.set(pa.getX(i2), pa.getY(i2), pa.getZ(i2))
                case None => ()
            }
            // 计算法向量
            Triangle.computeNormal(aV, bV, cV, normal)

            // 为每条边创建 hash（按精度 4 位四舍五入）
            let h0 = "${round(aV.x * precision)},${round(aV.y * precision)},${round(aV.z * precision)}"
            let h1 = "${round(bV.x * precision)},${round(bV.y * precision)},${round(bV.z * precision)}"
            let h2 = "${round(cV.x * precision)},${round(cV.y * precision)},${round(cV.z * precision)}"
            let hashes = [h0, h1, h2]
            let idxArr = [i0, i1, i2]

            // 跳过退化三角形（任两顶点 hash 相同）
            if (hashes[0] == hashes[1] || hashes[1] == hashes[2] || hashes[2] == hashes[0]) {
                i += 3
                continue
            }

            // 遍历每条边
            for (j in 0..3) {
                let jNext = (j + 1) % 3
                let vecHash0 = hashes[j]
                let vecHash1 = hashes[jNext]
                let hash = "${vecHash0}_${vecHash1}"
                let reverseHash = "${vecHash1}_${vecHash0}"

                match (edgeData.get(reverseHash)) {
                    case Some(opt) =>
                        // 找到兄弟边（值非 None）——按夹角阈值判断是否输出，置 None 保留 key（多面共边不再重复处理）
                        match (opt) {
                            case Some(t) =>
                                if (normal.dot(t[2]) <= thresholdDot) {
                                    match (positionAttr) {
                                        case Some(pa) =>
                                            v0.set(pa.getX(idxArr[j]), pa.getY(idxArr[j]), pa.getZ(idxArr[j]))
                                            v1.set(pa.getX(idxArr[jNext]), pa.getY(idxArr[jNext]), pa.getZ(idxArr[jNext]))
                                        case None => ()
                                    }
                                    vertices.add(v0.x); vertices.add(v0.y); vertices.add(v0.z)
                                    vertices.add(v1.x); vertices.add(v1.y); vertices.add(v1.z)
                                }
                            case None => ()
                        }
                        edgeData.remove(reverseHash)
                        edgeData.add(reverseHash, None)
                    case None =>
                        // 已存在相同 hash 的边则跳过；否则记录新边
                        if (!edgeData.contains(hash)) {
                            edgeData.add(hash, Some((idxArr[j], idxArr[jNext], normal.clone())))
                        }
                }
            }
            i += 3
        }

        // 处理所有剩余未匹配边（开放边或边界）
        for (key in edgeData.keys()) {
            match (edgeData.get(key)) {
                case Some(opt) =>
                    match (opt) {
                        case Some(t) =>
                            let (i0, i1, _) = t
                            match (positionAttr) {
                                case Some(pa) =>
                                    v0.set(pa.getX(i0), pa.getY(i0), pa.getZ(i0))
                                    v1.set(pa.getX(i1), pa.getY(i1), pa.getZ(i1))
                                case None => ()
                            }
                            vertices.add(v0.x); vertices.add(v0.y); vertices.add(v0.z)
                            vertices.add(v1.x); vertices.add(v1.y); vertices.add(v1.z)
                        case None => ()
                    }
                case None => ()
            }
        }

        this.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
    }
}