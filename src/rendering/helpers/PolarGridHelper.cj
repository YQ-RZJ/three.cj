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
 * @file[zh-cn] 极坐标网格辅助对象
 * @brief[zh-cn] 极坐标网格辅助对象，用于在场景中显示极坐标网格
 * @explain[zh-cn] 
 * 对应 Three.js helpers/PolarGridHelper.js。由径向射线和同心圆环组成，
 * 用于极坐标系统的可视化。网格位于 XZ 平面。
 *
 * @file[en] Polar Grid Helper
 * @brief[en] Polar grid helper for displaying a polar coordinate grid in the scene
 * @explain[en] 
 * Corresponds to Three.js helpers/PolarGridHelper.js. Composed of radial rays and
 * concentric rings for polar coordinate visualization. Grid is on the XZ plane.
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
import std.math.*

/**
 * @brief[zh-cn] 极坐标网格辅助对象，在 XZ 平面显示极坐标网格
 * @explain[zh-cn] 
 * 由径向射线和同心圆环组成，用于极坐标系统的可视化。
 *
 * @brief[en] Polar grid helper displaying a polar coordinate grid on the XZ plane
 * @explain[en] 
 * Composed of radial rays and concentric rings for polar coordinate visualization.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = LineSegments]
public class PolarGridHelper <: LineSegments {
    /**
     * @brief[zh-cn] 构造极坐标网格辅助对象
     * @param[zh-cn] radius 半径，默认 10
     * sectors 扇形数，默认 16
     * rings 圆环数，默认 8
     * divisions 圆环分段数，默认 64
     * color1 径向线颜色，默认深灰 0x444444
     * color2 圆环颜色，默认浅灰 0x888888
     *
     * @brief[en] Construct a polar grid helper
     * @param[en] radius Radius, default 10
     * sectors Number of sectors, default 16
     * rings Number of rings, default 8
     * divisions Ring segments, default 64
     * color1 Radial line color, default dark gray 0x444444
     * color2 Ring color, default light gray 0x888888
     */
    public init(radius!: Float64 = 10.0, sectors!: Int64 = 16, rings!: Int64 = 8, divisions!: Int64 = 64, color1!: Color = Color(0x444444), color2!: Color = Color(0x888888)) {
        super(geometry: BufferGeometry(), material: LineBasicMaterial())
        let vertices = ArrayList<Float64>()
        let colors = ArrayList<Float64>()

        // 径向射线（对照 JS: sectors>1 时创建；颜色按 i 奇偶在 color1/color2 间交替）
        if (sectors > 1) {
            for (i in 0..sectors) {
                let v = (Float64(i) / Float64(sectors)) * PI * 2.0
                let x = sin(v) * radius
                let z = cos(v) * radius
                vertices.add(0.0); vertices.add(0.0); vertices.add(0.0)
                vertices.add(x); vertices.add(0.0); vertices.add(z)
                let color = if (i % 2 == 1) { color1 } else { color2 }
                for (_ in 0..2) {
                    colors.add(color.r); colors.add(color.g); colors.add(color.b)
                }
            }
        }

        // 同心圆环（对照 JS: 颜色按环 i 奇偶在 color1/color2 间交替）
        for (i in 0..rings) {
            let r = radius - (radius / Float64(rings)) * Float64(i)
            let color = if (i % 2 == 1) { color1 } else { color2 }
            for (j in 0..divisions) {
                var v = (Float64(j) / Float64(divisions)) * PI * 2.0
                var x = sin(v) * r
                var z = cos(v) * r
                vertices.add(x); vertices.add(0.0); vertices.add(z)
                v = (Float64(j + 1) / Float64(divisions)) * PI * 2.0
                x = sin(v) * r
                z = cos(v) * r
                vertices.add(x); vertices.add(0.0); vertices.add(z)
                for (_ in 0..2) {
                    colors.add(color.r); colors.add(color.g); colors.add(color.b)
                }
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
