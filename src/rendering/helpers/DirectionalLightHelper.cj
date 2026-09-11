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
 * @file[zh-cn] 方向光辅助对象
 * @brief[zh-cn] 方向光辅助对象，用于可视化方向光的位置和方向
 * @explain[zh-cn] 
 * 对应 Three.js helpers/DirectionalLightHelper.js。由一个平面（表示光源位置）和一条线
 * （表示光照方向）组成。当光源或其目标变换时，需要调用 update() 方法更新。
 *
 * @file[en] Directional Light Helper
 * @brief[en] Directional light helper for visualizing position and direction
 * @explain[en] 
 * Corresponds to Three.js helpers/DirectionalLightHelper.js. Composed of a plane (light position)
 * and a line (light direction). Call update() when the light or its target changes.
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
import three.rendering.lights.*

/**
 * @brief[zh-cn] 方向光辅助对象，用于可视化方向光的效果
 * @explain[zh-cn] 
 * 由一个平面（表示光源位置）和一条线（表示光照方向）组成。
 * 当光源或其目标变换时，需要调用 update() 方法更新。
 *
 * @brief[en] Directional light helper for visualizing directional light effects
 * @explain[en] 
 * Composed of a plane (light position) and a line (light direction).
 * Call update() when the light or its target changes.
 */
@JsonAdapter[polymorphic = true ; withSuperClass = Object3D]
public class DirectionalLightHelper <: Object3D {
    /**
     * @brief[zh-cn] 被可视化的光源
     *
     * @brief[en] The light being visualized
     */
    public var light: Light

    /**
     * @brief[zh-cn] 平面尺寸
     *
     * @brief[en] Plane size
     */
    public var size: Float64

    /**
     * @brief[zh-cn] 颜色（可选，未设置时使用光源颜色）
     *
     * @brief[en] Color (optional, uses light color when not set)
     */
    public var color: Option<Color>

    /**
     * @brief[zh-cn] 光源平面线
     *
     * @brief[en] Light plane line
     */
    public var lightPlane: Line

    /**
     * @brief[zh-cn] 目标方向线
     *
     * @brief[en] Target direction line
     */
    public var targetLine: Line

    /**
     * @brief[zh-cn] 构造方向光辅助对象
     * @param[zh-cn] light 要可视化的方向光
     * size 平面尺寸，默认 1
     * color 颜色，未设置时使用光源颜色
     *
     * @brief[en] Construct a directional light helper
     * @param[en] light The directional light to visualize
     * size Plane size, default 1
     * color Color, uses light color when not set
     */
    public init() {
        this(Light())
    }
    public init(light: Light, size!: Float64 = 1.0, color!: Option<Color> = None<Color>) {
        super()
        this.light = light
        this.size = size
        this.color = color
        this.matrix = light.matrixWorld
        this.matrixAutoUpdate = false

        let geometry1 = BufferGeometry()
        geometry1.setAttribute("position", BufferAttribute(Array<Float64>(15, { i =>
            [-size, size, 0.0, size, size, 0.0, size, -size, 0.0, -size, -size, 0.0, -size, size, 0.0][i]
        }), 3))
        let material = LineBasicMaterial()
        this.lightPlane = Line(geometry: geometry1, material: material)
        this.children.add(this.lightPlane)

        let geometry2 = BufferGeometry()
        geometry2.setAttribute("position", BufferAttribute(Array<Float64>(6, { i => [0.0, 0.0, 0.0, 0.0, 0.0, 1.0][i] }), 3))
        this.targetLine = Line(geometry: geometry2, material: material)
        this.children.add(this.targetLine)

        this.update()
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        this.lightPlane.geometry.dispose()
        this.lightPlane.material.dispose()
        this.targetLine.geometry.dispose()
        this.targetLine.material.dispose()
    }

    /**
     * @brief[zh-cn] 更新辅助对象以匹配光源的位置和方向
     * @explain[zh-cn] 
     * lightPlane 朝向 target、targetLine 指向 target 且长度 = 光→目标距离。
     *
     * @brief[en] Update helper to match light position and direction
     * @explain[en] 
     * lightPlane faces target, targetLine points to target with length = light-to-target distance.
     */
    public func update(): Unit {
        this.matrixWorldNeedsUpdate = true
        this.light.updateWorldMatrix(true, false, false)
        
        match (this.light) {
            case dl: DirectionalLight => dl.target.updateWorldMatrix(true, false, false)
            case _ => ()
        }
        // _v1 = light 世界位置；_v2 = target 世界位置；_v3 = _v2 - _v1
        let v1 = Vector3().setFromMatrixPosition(this.light.matrixWorld)
        let v2 = this._targetWorldMatrixPosition()
        let v3 = Vector3().subVectors(v2, v1)
        
        this.lightPlane.lookAt(v2)
        match (this.color) {
            case Some(c) =>
                this.lightPlane.material.color.copy(c)
                this.targetLine.material.color.copy(c)
            case None =>
                this.lightPlane.material.color.copy(this.light.color)
                this.targetLine.material.color.copy(this.light.color)
        }
        
        this.targetLine.lookAt(v2)
        this.targetLine.scale.z = v3.length()
    }

    /**
     * @brief[zh-cn] 取光源目标的世界位置
     * @return[zh-cn] 光源目标的世界位置
     *
     * @brief[en] Get light target world position
     * @return[en] Light target world position
     */
    private func _targetWorldMatrixPosition(): Vector3 {
        match (this.light) {
            case dl: DirectionalLight => return Vector3().setFromMatrixPosition(dl.target.matrixWorld)
            case sl: SpotLight => return Vector3().setFromMatrixPosition(sl.target.matrixWorld)
            case _ => return Vector3().setFromMatrixPosition(this.light.matrixWorld)
        }
    }
}
