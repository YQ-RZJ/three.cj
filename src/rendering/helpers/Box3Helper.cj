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
 * @file[zh-cn] Box3 辅助对象
 * @brief[zh-cn] Box3 轴对齐包围盒辅助对象，用于可视化 Box3 边界
 * @explain[zh-cn] 
 * 对应 Three.js helpers/Box3Helper.js。以线框绘制 Box3 包围盒，
 * 自动根据 Box3 的中心和尺寸更新位置与缩放。
 *
 * @file[en] Box3 Helper
 * @brief[en] Box3 axis-aligned bounding box helper for visualizing Box3 boundaries
 * @explain[en] 
 * Corresponds to Three.js helpers/Box3Helper.js. Draws a Box3 bounding box as wireframe,
 * automatically updates position and scale based on Box3 center and size.
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

/**
 * @brief[zh-cn] Box3 轴对齐包围盒辅助对象
 * @explain[zh-cn] 
 * 以线框绘制 Box3 包围盒，自动根据 Box3 的中心和尺寸更新位置与缩放。
 *
 * @brief[en] Box3 axis-aligned bounding box helper
 * @explain[en] 
 * Draws a Box3 bounding box as wireframe, automatically updates position and scale
 * based on Box3 center and size.
 */
@JsonAdapter[polymorphic = true ; withSuperClass = LineSegments]
public class Box3Helper <: LineSegments {
    /**
     * @brief[zh-cn] 被可视化的包围盒
     *
     * @brief[en] The bounding box being visualized
     */
    public var box: Box3

    /**
     * @brief[zh-cn] 构造 Box3 辅助对象
     * @param[zh-cn] box 要可视化的 Box3 包围盒
     * color 线框颜色，默认黄色 0xffff00
     *
     * @brief[en] Construct a Box3 helper
     * @param[en] box The Box3 bounding box to visualize
     * color Wireframe color, default yellow 0xffff00
     */
    public init() {
        this(Box3())
    }
    public init(box: Box3, color!: UInt32 = 0xffff00) {
        super(geometry: BufferGeometry(), material: LineBasicMaterial())
        this.box = box
        let indices = Array<Float64>(24, { i => Float64([0, 1, 1, 2, 2, 3, 3, 0, 4, 5, 5, 6, 6, 7, 7, 4, 0, 4, 1, 5, 2, 6, 3, 7][i]) })
        let positions = Array<Float64>(24, { i =>
            [1.0, 1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0,
             1.0, 1.0, -1.0, -1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, -1.0][i]
        })
        this.geometry.setIndex(BufferAttribute(indices, 1))
        this.geometry.setAttribute("position", BufferAttribute(positions, 3))
        this.geometry.computeBoundingSphere()
    }

    /**
     * @brief[zh-cn] 更新世界矩阵，根据包围盒中心和尺寸调整位置与缩放
     * @param[zh-cn] force 是否强制更新
     *
     * @brief[en] Update world matrix, adjusting position and scale based on bounding box center and size
     * @param[en] force Whether to force update
     */
    public override func updateMatrixWorld(force: Bool): Unit {
        if (!this.box.isEmpty()) {
            let center = Vector3()
            this.box.getCenter(center)
            this.position.copy(center)
            let size = Vector3()
            this.box.getSize(size)
            this.scale.copy(size.multiplyScalar(0.5))
        }
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
    }
}
