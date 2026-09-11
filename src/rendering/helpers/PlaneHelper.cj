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
 * @file[zh-cn] 平面辅助对象
 * @brief[zh-cn] 平面辅助对象，用于可视化 Plane 平面
 * @explain[zh-cn] 
 * 对应 Three.js helpers/PlaneHelper.js。显示为网格线框，带半透明填充面。
 *
 * @file[en] Plane Helper
 * @brief[en] Plane helper for visualizing Plane objects
 * @explain[en] 
 * Corresponds to Three.js helpers/PlaneHelper.js. Displays as wireframe grid with a semi-transparent fill face.
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

/**
 * @brief[zh-cn] 平面辅助对象，用于可视化 Plane 平面
 * @explain[zh-cn] 
 * 显示为网格线框，带半透明填充面。
 *
 * @brief[en] Plane helper for visualizing Plane objects
 * @explain[en] 
 * Displays as wireframe grid with a semi-transparent fill face.
 */
@JsonAdapter[polymorphic = true ; withSuperClass = Line]
public class PlaneHelper <: Line {
    /**
     * @brief[zh-cn] 被可视化的平面
     *
     * @brief[en] The plane being visualized
     */
    public var plane: Plane

    /**
     * @brief[zh-cn] 辅助线的边长
     *
     * @brief[en] Helper line edge length
     */
    public var size: Float64

    /**
     * @brief[zh-cn] 构造平面辅助对象
     * @param[zh-cn] plane 要可视化的平面
     * size 边长，默认 1
     * hex 颜色，默认黄色 0xffff00
     *
     * @brief[en] Construct a plane helper
     * @param[en] plane The plane to visualize
     * size Edge length, default 1
     * hex Color, default yellow 0xffff00
     */
    public init() {
        this(Plane())
    }
    public init(plane: Plane, size!: Float64 = 1.0, hex!: UInt32 = 0xffff00) {
        super(geometry: BufferGeometry(), material: LineBasicMaterial())
        this.plane = plane
        this.size = size
        let positions = Array<Float64>(24, { i =>
            [1.0, -1.0, 0.0, -1.0, 1.0, 0.0, -1.0, -1.0, 0.0, 1.0, 1.0, 0.0,
             -1.0, 1.0, 0.0, -1.0, -1.0, 0.0, 1.0, -1.0, 0.0, 1.0, 1.0, 0.0][i]
        })
        this.geometry.setAttribute("position", BufferAttribute(positions, 3))
        this.geometry.computeBoundingSphere()
        
        this.material.color.copy(Color(hex))

        // 添加半透明填充面（对照 JS: MeshBasicMaterial({ color, opacity: 0.2, transparent: true, depthWrite: false })）
        let positions2 = Array<Float64>(18, { i =>
            [1.0, 1.0, 0.0, -1.0, 1.0, 0.0, -1.0, -1.0, 0.0,
             1.0, 1.0, 0.0, -1.0, -1.0, 0.0, 1.0, -1.0, 0.0][i]
        })
        let geometry2 = BufferGeometry()
        geometry2.setAttribute("position", BufferAttribute(positions2, 3))
        geometry2.computeBoundingSphere()
        let fillMaterial = MeshBasicMaterial()
        fillMaterial.color.copy(Color(hex))
        fillMaterial.opacity = 0.2
        fillMaterial.transparent = true
        fillMaterial.depthWrite = false
        this.add(Mesh(geometry: geometry2, material: fillMaterial))
    }

    /**
     * @brief[zh-cn] 更新矩阵世界，将平面变换到正确位置
     * @param[zh-cn] force 是否强制更新
     *
     * @brief[en] Update world matrix, transforming the plane to the correct position
     * @param[en] force Whether to force update
     */
    public override func updateMatrixWorld(force: Bool): Unit {
        this.position.set(0.0, 0.0, 0.0)
        this.scale.set(0.5 * this.size, 0.5 * this.size, 1.0)
        this.lookAt(this.plane.normal)
        this.translateZ(-this.plane.constant)
        super.updateMatrixWorld(force)
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        this.geometry.dispose()
        this.material.dispose()
        if (this.children.size > 0) {
            let fillOpt = this.children[0] as Mesh
            if (let Some(fill) <- fillOpt) {
                fill.geometry.dispose()
                fill.material.dispose()
            }
        }
    }
}
