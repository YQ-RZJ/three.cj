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
 * @file[zh-cn] LineLoop 线环
 * @brief[zh-cn] 从一组顶点构造的闭合线段，首末顶点自动连接成环
 * @explain[zh-cn] 继承自 Line，仅类型标志不同；raycast 等行为与 Line 一致
 *
 * @file[en] LineLoop  Line loop
 * @brief[en] Closed line loop constructed from vertices, first and last vertices auto-connected
 * @explain[en] Inherits from Line with only the type flag different; raycast behavior matches Line
 */
package three.scene.entity

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*
import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*

/**
 * @brief[zh-cn] 线环，首末顶点自动连接成环的闭合折线
 *
 * @brief[en] Line loop, a closed polyline with first and last vertices auto-connected
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Line]
public class LineLoop <: Line {

    /**
     * @brief[zh-cn] 构造一个新的线环
     * @param[zh-cn] geometry 顶点/索引几何，默认空 BufferGeometry
     * material 线材质，默认空 LineBasicMaterial
     *
     * @brief[en] Construct a new line loop
     * @param[en] geometry Vertex/index geometry, default empty BufferGeometry
     * material Line material, default LineBasicMaterial
     */
    public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial()) {
        super(geometry: geometry, material: material)
    }
}
