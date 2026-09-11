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
 * @file[zh-cn] LineSegments
 * @brief[zh-cn] 线段组渲染对象，从一组顶点两两配对为独立线段
 * @explain[zh-cn] 继承自 Line，唯二差异：①类型标志 kind="LineSegments"；②computeLineDistances override
 * ——按线段逐段距离（非折线累计）计算 lineDistance。
 *
 * @file[en] LineSegments
 * @brief[en] Line segments rendering object, pairing vertices into independent line segments
 * @explain[en] Extends Line with two differences: ① kind flag "LineSegments"; ② computeLineDistances override
 * ——calculates lineDistance per segment (not cumulative polyline distance).
 */
package three.scene.entity
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.utils.log.Logger
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 线段组渲染对象，从一组顶点两两配对为独立线段
 * @explain[zh-cn] 继承自 Line，唯二差异：类型标志 kind="LineSegments"；computeLineDistances 按线段逐段距离计算
 *
 * @brief[en] Line segments rendering object, pairing vertices into independent line segments
 * @explain[en] Extends Line with two differences: kind flag "LineSegments"; computeLineDistances per segment distance
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Line]
public open class LineSegments <: Line {
    /**
     * @brief[zh-cn] 构造一个新的线段组
     * @param[zh-cn] geometry 顶点/索引几何，默认空 BufferGeometry
     * material 线材质，默认空 LineBasicMaterial
     *
     * @brief[en] Construct a new line segments group
     * @param[en] geometry Vertex/index geometry, default empty BufferGeometry
     * material Line material, default empty LineBasicMaterial
     */
    public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial()) {
        super(geometry: geometry, material: material)
    }

    /**
     * @brief[zh-cn] 计算并写入几何的 lineDistance 属性（各顶点按所属线段距离，非累计）
     * @explain[zh-cn] 与 Line.computeLineDistances 不同：每对顶点 (i, i+1) 的 lineDistance 分别设为 0 和该段长度，
     * 下一段重置为 0。仅非索引几何支持，逐对顶点算段长。
     * @return[zh-cn] 返回 this 以支持链式调用
     *
     * @brief[en] Compute and write lineDistance attribute to geometry (per segment distance, not cumulative)
     * @explain[en] Unlike Line.computeLineDistances: each pair (i, i+1) sets lineDistance to 0 and segment length respectively,
     * next segment resets to 0. Non-indexed geometry only.
     * @return[en] Returns this for method chaining
     */
    public override func computeLineDistances(): Line {
        let geometry = this.geometry
        match (geometry.index) {
            case None =>
                match (geometry.getAttribute("position")) {
                    case Some(positionAttr) =>
                        let count = positionAttr.count
                        if (count < 2) {
                            return this
                        }
                        
                        //          lineDistances[i+1] = lineDistances[i] + _start.distanceTo(_end)
                        let lineDistances = Array<Float64>(count, { _ => 0.0 })
                        let start = Vector3()
                        let end = Vector3()
                        var i = 0
                        while (i + 1 < count) {
                            // _start.fromBufferAttribute(positionAttribute, i) — 仓颉侧用 getX/Y/Z 拼装
                            start.set(positionAttr.getX(i), positionAttr.getY(i), positionAttr.getZ(i))
                            end.set(positionAttr.getX(i + 1), positionAttr.getY(i + 1), positionAttr.getZ(i + 1))
                            // 非索引几何：偶下标为段起点（lineDistance=0），奇下标为段终点（段长）
                            
                            //          lineDistances[i+1] = lineDistances[i] + start.distanceTo(end)
                            // 但 JS 原实现针对 step=2 的 i 循环，段内两顶点同段，前顶点继承上一段末值，后顶点为段长
                            if (i == 0) {
                                lineDistances[i] = 0.0
                            } else {
                                lineDistances[i] = lineDistances[i - 1]
                            }
                            lineDistances[i + 1] = lineDistances[i] + start.distanceTo(end)
                            i += 2
                        }
                        geometry.setAttribute("lineDistance", Float32BufferAttribute(lineDistances, 1))
                    case None => ()
                }
            case Some(_) =>
                
                Logger.warn(["LineSegments.computeLineDistances()", "Computation only possible with non-indexed BufferGeometry."])
        }
        return this
    }
}
