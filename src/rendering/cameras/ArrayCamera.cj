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
 * @file[zh-cn] ArrayCamera 数组相机
 * @brief[zh-cn] 管理一组 PerspectiveCamera 子相机，用于 VR/多视图阵列渲染
 * @explain[zh-cn] 数组相机：管理一组 PerspectiveCamera 子相机，用于 VR/多视图阵列渲染。
 * 由 WebGLArrayRenderTarget 配合使用，渲染器在一次 draw 内调用多视口。
 *
 * @file[en] ArrayCamera
 * @brief[en] Manages a group of PerspectiveCamera sub-cameras for VR/multi-view array rendering
 * @explain[en] Array camera: manages a group of PerspectiveCamera sub-cameras for VR/multi-view array rendering.
 * Used with WebGLArrayRenderTarget, the renderer invokes multiple viewports in a single draw.
 *
 * @package three.rendering.cameras
 */
package three.rendering.cameras

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
import three.core.interfaces.*
import std.collection.*

/**
 * @brief[zh-cn] 数组相机，管理一组 PerspectiveCamera 子相机
 * @explain[zh-cn] 用于 VR/多视图阵列渲染，由 WebGLArrayRenderTarget 配合使用，
 * 渲染器在一次 draw 内调用多视口。
 *
 * @brief[en] Array camera, manages a group of PerspectiveCamera sub-cameras
 * @explain[en] Used for VR/multi-view array rendering, works with WebGLArrayRenderTarget,
 * the renderer invokes multiple viewports in a single draw.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = PerspectiveCamera]
public class ArrayCamera <: PerspectiveCamera & IArrayCameraSource {

    /**
     * @brief[zh-cn] 是否多视图相机（与 ArrayCamera 类似但语义不同，渲染器内部用）
     *
     * @brief[en] Whether multi-view camera (similar to ArrayCamera but different semantics, used internally by renderer)
     */
    public var isMultiViewCamera: Bool

    /**
     * @brief[zh-cn] 子相机数组。每个子相机是一独立 PerspectiveCamera，对应一个视口
     *
     * @brief[en] Sub-camera array. Each sub-camera is an independent PerspectiveCamera corresponding to a viewport
     */
    public var cameras: ArrayList<PerspectiveCamera>

    /**
     * @brief[zh-cn] 构造一个新的数组相机
     * @param[zh-cn] cameras 子相机数组，默认空数组
     *
     * @brief[en] Construct a new array camera
     * @param[en] cameras Sub-camera array, default empty array
     */
    public init(cameras!: ArrayList<PerspectiveCamera> = ArrayList<PerspectiveCamera>()) {
        super()
        this.isMultiViewCamera = false
        this.cameras = cameras
    }

    // ===== three.interfaces.IArrayCameraSource 实现 =====

    /**
     * @brief[zh-cn] 子相机数量（对照 JS: cameraArray.cameras.length）
     * @return[zh-cn] 数量
     *
     * @brief[en] Sub-camera count (corresponding to JS: cameraArray.cameras.length)
     * @return[en] Count
     */
    public func getCameraCount(): Int64 {
        return this.cameras.size
    }

    /**
     * @brief[zh-cn] 第 i 个子相机的投影矩阵元素（16 个，列主序）
     * @param[zh-cn] i 子相机索引
     * @return[zh-cn] 投影矩阵元素数组
     *
     * @brief[en] Projection matrix elements of the i-th sub-camera (16 elements, column-major)
     * @param[en] i Sub-camera index
     * @return[en] Projection matrix elements array
     */
    public func getCameraProjectionElements(i: Int64): Array<Float64> {
        return this.cameras[i].projectionMatrix.elements
    }

    /**
     * @brief[zh-cn] 第 i 个子相机的视图矩阵逆元素（16 个，列主序）
     * @param[zh-cn] i 子相机索引
     * @return[zh-cn] 视图矩阵逆元素数组
     *
     * @brief[en] Inverse view matrix elements of the i-th sub-camera (16 elements, column-major)
     * @param[en] i Sub-camera index
     * @return[en] Inverse view matrix elements array
     */
    public func getCameraMatrixWorldInverseElements(i: Int64): Array<Float64> {
        return this.cameras[i].matrixWorldInverse.elements
    }
}
