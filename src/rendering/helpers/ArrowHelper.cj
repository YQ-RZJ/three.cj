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
 * @file[zh-cn] 箭头辅助对象
 * @brief[zh-cn] 三维箭头辅助对象，用于可视化方向
 * @explain[zh-cn] 
 * 对应 Three.js helpers/ArrowHelper.js。由一条线（表示方向）和一个锥体（表示箭头头部）组成，
 * 支持设置方向、长度和颜色。
 *
 * @file[en] Arrow Helper
 * @brief[en] 3D arrow helper for visualizing directions
 * @explain[en] 
 * Corresponds to Three.js helpers/ArrowHelper.js. Composed of a line (direction)
 * and a cone (arrow head), supports setting direction, length and color.
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
import three.rendering.geometry.*
import std.math.*

/**
 * @brief[zh-cn] 三维箭头辅助对象，用于可视化方向
 * @explain[zh-cn] 
 * 由一条线（表示方向）和一个锥体（表示箭头头部）组成，
 * 支持设置方向、长度和颜色。
 *
 * @brief[en] 3D arrow helper for visualizing directions
 * @explain[en] 
 * Composed of a line (direction) and a cone (arrow head),
 * supports setting direction, length and color.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Object3D]
public class ArrowHelper <: Object3D {
    private static var _lineGeometry: Option<BufferGeometry> = None<BufferGeometry>
    private static var _coneGeometry: Option<BufferGeometry> = None<BufferGeometry>
    private static var _axis: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 箭头的线体部分
     *
     * @brief[en] Line body of the arrow
     */
    @JsonIgnore
    public var line: Line

    /**
     * @brief[zh-cn] 箭头的锥体头部部分
     *
     * @brief[en] Cone head of the arrow
     */
    @JsonIgnore
    public var cone: Mesh

    /**
     * @brief[zh-cn] 构造箭头辅助对象
     * @param[zh-cn] dir 方向向量（需归一化），默认 +Z 方向
     * origin 起点位置，默认原点
     * length 箭头长度（世界单位），默认 1
     * color 颜色，默认黄色 0xffff00
     * headLength 头部长度，默认 length * 0.2
     * headWidth 头部宽度，默认 headLength * 0.2
     *
     * @brief[en] Construct an arrow helper
     * @param[en] dir Direction vector (normalized), default +Z direction
     * origin Origin position, default origin
     * length Arrow length (world units), default 1
     * color Color, default yellow 0xffff00
     * headLength Head length, default length * 0.2
     * headWidth Head width, default headLength * 0.2
     */
    public init(dir!: Vector3 = Vector3(0.0, 0.0, 1.0), origin!: Vector3 = Vector3(0.0, 0.0, 0.0), length!: Float64 = 1.0, color!: UInt32 = 0xffff00, headLength!: Float64 = 0.0, headWidth!: Float64 = 0.0) {
        super()

        let hl = if (headLength == 0.0) { length * 0.2 } else { headLength }
        let hw = if (headWidth == 0.0) { hl * 0.2 } else { headWidth }

        if (ArrowHelper._lineGeometry.isNone()) {
            let lg = BufferGeometry()
            
            // 线段从原点指向 +Y 单位长度（后续经 setLength 的 scale.y 拉伸成实际长度）
            lg.setAttribute("position", BufferAttribute(Array<Float64>(6, { i => [0.0, 0.0, 0.0, 0.0, 1.0, 0.0][i] }), 3))
            ArrowHelper._lineGeometry = Some(lg)
            
            // 读取 ConeGeometry 的 position 属性经 translate(0, -0.5, 0) 变换后填入 _coneGeometry，使锥体底部在原点。
            let cg = ConeGeometry(radius: 0.5, height: 1.0, radialSegments: 5)
            cg.translate(0.0, -0.5, 0.0)
            ArrowHelper._coneGeometry = Some(cg)
        }

        this.position.copy(origin)
        this.line = Line(geometry: ArrowHelper._lineGeometry.getOrThrow(), material: LineBasicMaterial())
        this.line.matrixAutoUpdate = false
        
        this.line.material.color.copy(Color(color))
        this.children.add(this.line)

        this.cone = Mesh(geometry: ArrowHelper._coneGeometry.getOrThrow(), material: MeshBasicMaterial())
        this.cone.matrixAutoUpdate = false
        this.cone.position.y = 0.0
        this.cone.material.color.copy(Color(color))
        this.children.add(this.cone)

        this.setDirection(dir)
        this.setLength(length, hl, hw)
    }

    /**
     * @brief[zh-cn] 设置箭头的方向
     * @param[zh-cn] dir 归一化的方向向量
     *
     * @brief[en] Set the direction of the arrow
     * @param[en] dir Normalized direction vector
     */
    public func setDirection(dir: Vector3): Unit {
        if (dir.y > 0.99999) {
            this.quaternion.set(0.0, 0.0, 0.0, 1.0)
        } else if (dir.y < -0.99999) {
            this.quaternion.set(1.0, 0.0, 0.0, 0.0)
        } else {
            ArrowHelper._axis.set(dir.z, 0.0, -dir.x).normalize()
            let radians = acos(dir.y)
            this.quaternion.setFromAxisAngle(ArrowHelper._axis, radians)
        }
    }

    /**
     * @brief[zh-cn] 设置箭头的长度
     * @param[zh-cn] length 总长度
     * headLength 头部长度
     * headWidth 头部宽度
     *
     * @brief[en] Set the length of the arrow
     * @param[en] length Total length
     * headLength Head length
     * headWidth Head width
     */
    public func setLength(length: Float64, headLength: Float64, headWidth: Float64): Unit {
        this.line.scale.set(1.0, max(0.0001, length - headLength), 1.0)
        this.line.updateMatrix()
        this.cone.scale.set(headWidth, headLength, headWidth)
        this.cone.position.y = length
        this.cone.updateMatrix()
    }

    /**
     * @brief[zh-cn] 设置箭头的颜色
     * @param[zh-cn] color 颜色值
     *
     * @brief[en] Set the color of the arrow
     * @param[en] color Color value
     */
    public func setColor(color: Color): Unit {
        this.line.material.color.copy(color)
        this.cone.material.color.copy(color)
    }

    /**
     * @brief[zh-cn] 复制另一个箭头辅助对象
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Copy from another arrow helper
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Self reference
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: ArrowHelper =>
                this.line = s.line
                this.cone = s.cone
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        this.line.geometry.dispose()
        this.line.material.dispose()
        this.cone.geometry.dispose()
        this.cone.material.dispose()
    }
}
