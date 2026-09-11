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
 * @file[zh-cn] 半球光辅助对象
 * @brief[zh-cn] 半球光辅助对象，用于可视化半球光
 * @explain[zh-cn] 
 * 对应 Three.js helpers/HemisphereLightHelper.js。用八面体网格可视化半球光，
 * 当光源变换或属性改变时，需要调用 update() 方法更新。
 *
 * @file[en] Hemisphere Light Helper
 * @brief[en] Hemisphere light helper for visualizing hemisphere lights
 * @explain[en] 
 * Corresponds to Three.js helpers/HemisphereLightHelper.js. Visualizes hemisphere light
 * with an octahedron mesh. Call update() when the light or its properties change.
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
import three.rendering.lights.*
import std.math.*

/**
 * @brief[zh-cn] 半球光辅助对象，用八面体网格可视化半球光
 * @explain[zh-cn] 
 * 当光源变换或属性改变时，需要调用 update() 方法更新。
 *
 * @brief[en] Hemisphere light helper visualized with an octahedron mesh
 * @explain[en] 
 * Call update() when the light or its properties change.
 */
@JsonAdapter[polymorphic = true ; withSuperClass = Object3D]
public class HemisphereLightHelper <: Object3D {
    /**
     * @brief[zh-cn] 被可视化的光源
     *
     * @brief[en] The light being visualized
     */
    public var light: Light

    /**
     * @brief[zh-cn] 颜色（可选，未设置时使用光源颜色）
     *
     * @brief[en] Color (optional, uses light color when not set)
     */
    public var color: Option<Color>

    /**
     * @brief[zh-cn] 材质引用
     *
     * @brief[en] Material reference
     */
    public var material: Material

    /**
     * @brief[zh-cn] 构造半球光辅助对象
     * @param[zh-cn] light 要可视化的半球光
     * size 尺寸，默认 1
     * color 颜色，未设置时使用光源颜色
     *
     * @brief[en] Construct a hemisphere light helper
     * @param[en] light The hemisphere light to visualize
     * size Size, default 1
     * color Color, uses light color when not set
     */
    public init() {
        this(Light())
    }
    public init(light: Light, size!: Float64 = 1.0, color!: Option<Color> = None<Color>) {
        super()
        this.light = light
        this.color = color
        this.matrix = light.matrixWorld
        this.matrixAutoUpdate = false

        
        let geometry = OctahedronGeometry(radius: size)
        geometry.rotateY(PI * 0.5)

        this.material = MeshBasicMaterial()
        
        this.material.wireframe = true
        if (this.color.isNone()) {
            this.material.vertexColors = true
        }

        
        let position = geometry.getAttribute("position")
        let colorCount = match (position) {
            case Some(p) => p.count * 3
            case None => 0
        }
        geometry.setAttribute("color", BufferAttribute(Array<Float64>(colorCount, { _ => 0.0 }), 3))

        let mesh = Mesh(geometry: geometry, material: this.material)
        this.children.add(mesh)
        this.update()
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        if (this.children.size > 0) {
            let meshOpt = this.children[0] as Mesh
            if (let Some(mesh) <- meshOpt) {
                mesh.geometry.dispose()
                mesh.material.dispose()
            }
        }
    }

    /**
     * @brief[zh-cn] 更新辅助对象以匹配光源位置和颜色
     * @explain[zh-cn] 
     * color 未指定时按顶点写 skyColor/groundColor 各半，且 mesh 朝向光源反向。
     *
     * @brief[en] Update helper to match light position and color
     * @explain[en] 
     * When color is not specified, vertices are colored skyColor/groundColor each half,
     * and mesh faces opposite to the light direction.
     */
    public func update(): Unit {
        let meshOpt = this.children[0] as Mesh
        match (this.color) {
            case Some(c) => this.material.color.copy(c)
            case None =>
                match (meshOpt) {
                    case Some(mesh) =>
                        match (mesh.geometry.getAttribute("color")) {
                            case Some(colors) =>
                                let sky = this.light.color
                                let ground = match (this.light) {
                                    case hl: HemisphereLight => hl.groundColor
                                    case _ => Color(0x000000)
                                }
                                for (i in 0..colors.count) {
                                    let c = if (i < (colors.count / 2)) { sky } else { ground }
                                    colors.setXYZ(i, c.r, c.g, c.b)
                                }
                                colors.version += 1
                            case None => ()
                        }
                    case None => ()
                }
        }
        this.matrixWorldNeedsUpdate = true
        this.light.updateWorldMatrix(true, false, false)
        
        match (meshOpt) {
            case Some(mesh) =>
                let v = Vector3().setFromMatrixPosition(this.light.matrixWorld).negate()
                mesh.lookAt(v)
            case None => ()
        }
    }
}
