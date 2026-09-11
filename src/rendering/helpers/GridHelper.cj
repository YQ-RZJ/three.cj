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
 * @file[zh-cn] 网格辅助对象
 * @brief[zh-cn] 网格辅助对象，用于在场景中显示二维网格线
 * @explain[zh-cn] 
 * 对应 Three.js helpers/GridHelper.js。网格线位于 XZ 平面，可设置尺寸和分割数。
 * 中心线使用 color1，其他线使用 color2。
 *
 * @file[en] Grid Helper
 * @brief[en] Grid helper for displaying a 2D grid in the scene
 * @explain[en] 
 * Corresponds to Three.js helpers/GridHelper.js. Grid lines are on the XZ plane,
 * with configurable size and divisions. Center lines use color1, other lines use color2.
 */
package three.rendering.helpers

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import std.collection.*

/**
 * @brief[zh-cn] 网格辅助对象，在场景中显示二维网格线
 * @explain[zh-cn] 
 * 网格线位于 XZ 平面，可设置尺寸和分割数。
 * 中心线使用 color1，其他线使用 color2。
 *
 * @brief[en] Grid helper that displays a 2D grid in the scene
 * @explain[en] 
 * Grid lines are on the XZ plane, with configurable size and divisions.
 * Center lines use color1, other lines use color2.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = LineSegments]
public class GridHelper <: LineSegments {
    /**
     * @brief[zh-cn] 构造网格辅助对象
     * @param[zh-cn] size 网格尺寸，默认 10
     * divisions 分割数，默认 10
     * color1 中心线颜色，默认深灰 0x444444
     * color2 网格线颜色，默认浅灰 0x888888
     *
     * @brief[en] Construct a grid helper
     * @param[en] size Grid size, default 10
     * divisions Number of divisions, default 10
     * color1 Center line color, default dark gray 0x444444
     * color2 Grid line color, default light gray 0x888888
     */
    public init(size!: Float64 = 10.0, divisions!: Int64 = 10, color1!: Color = Color(0x444444), color2!: Color = Color(0x888888)) {
        super(geometry: BufferGeometry(), material: LineBasicMaterial())
        let center = Float64(divisions) / 2.0
        let step = size / Float64(divisions)
        let halfSize = size / 2.0
        let vertices = ArrayList<Float64>()
        let colors = ArrayList<Float64>()

        for (i in 0..=divisions) {
            let k = -halfSize + Float64(i) * step
            vertices.add(-halfSize); vertices.add(0.0); vertices.add(k)
            vertices.add(halfSize); vertices.add(0.0); vertices.add(k)
            vertices.add(k); vertices.add(0.0); vertices.add(-halfSize)
            vertices.add(k); vertices.add(0.0); vertices.add(halfSize)

            let color = if (Float64(i) == center) { color1 } else { color2 }
            for (_ in 0..4) {
                colors.add(color.r); colors.add(color.g); colors.add(color.b)
            }
        }

        this.geometry.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        this.geometry.setAttribute("color", BufferAttribute(colors.toArray(), 3))
        
        // 缺 vertexColors 时 color 属性不参与渲染 → 网格显示为材质单色
        this.material.vertexColors = true
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        this.geometry.dispose()
        this.material.dispose()
    }
}
