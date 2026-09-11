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
 * @file[zh-cn] 四边形网格
 * @brief[zh-cn] 全屏四边形网格，用于后处理等全屏渲染 pass
 * @explain[zh-cn] 
 * QuadMesh 封装了一个全屏四边形的几何体和材质，用于后处理 pass、blit 操作等
 * 需要全屏渲染的场景。对应 Three.js 中的 QuadMesh 概念。
 *
 * @file[en] QuadMesh
 * @brief[en] Fullscreen quad mesh, used for post-processing and other fullscreen render passes
 * @explain[en] 
 * QuadMesh encapsulates the geometry and material of a fullscreen quad, used for post-processing passes, blit operations,
 * and other scenarios requiring fullscreen rendering. Corresponds to the QuadMesh concept in Three.js.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*

/**
 * @brief[zh-cn] 全屏四边形网格
 * @explain[zh-cn] 
 * 封装全屏四边形的几何体和材质，用于后处理和 blit 操作。
 *
 * @brief[en] Fullscreen quad mesh
 * @explain[en] 
 * Encapsulates the geometry and material of a fullscreen quad, used for post-processing and blit operations.
 */
public open class QuadMesh {
    /**
     * @brief[zh-cn] 四边形几何体
     *
     * @brief[en] Quad geometry
     */
    public var geometry: BufferGeometry

    /**
     * @brief[zh-cn] 四边形材质
     *
     * @brief[en] Quad material
     */
    public var material: Material

    /**
     * @brief[zh-cn] 构造默认四边形网格
     *
     * @brief[en] Constructs a default quad mesh
     */
    public init() {
        this.geometry = BufferGeometry()
        this.material = Material()
    }

    /**
     * @brief[zh-cn] 渲染四边形
     * @param[zh-cn] renderer 渲染器
     *
     * @brief[en] Renders the quad
     * @param[en] renderer Renderer
     */
    public func render(renderer: Renderer): Unit { }
}
