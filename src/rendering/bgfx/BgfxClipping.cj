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
 * @file[zh-cn] bgfx 裁剪平面管理
 * @brief[zh-cn] 替代 WebGLClipping，管理裁剪平面数据传递给着色器
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLClipping.js。在 WebGL 中通过 uniform 传递裁剪平面数据，在 bgfx 中同样通过 uniform 传递，使用 bgfx_set_uniform_cj。
 *
 * @file[en] bgfx Clipping Plane Management
 * @brief[en] Replaces WebGLClipping, manages clipping plane data passed to shaders
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLClipping.js. In WebGL, clipping plane data is passed via uniforms; in bgfx, the same approach is used with bgfx_set_uniform_cj.
 */
package three.rendering.bgfx

import std.collection.*
import three.core.math.*
import three.rendering.materials.Material
import three.rendering.cameras.Camera

/**
 * @brief[zh-cn] 裁剪平面 Uniform 数据
 * @explain[zh-cn] 存储裁剪平面数据，每4个浮点数一个平面（normal.x, normal.y, normal.z, constant）
 *
 * @brief[en] Clipping plane uniform data
 * @explain[en] Stores clipping plane data, 4 floats per plane (normal.x, normal.y, normal.z, constant)
 */
public class ClippingUniform {
    /**
     * @brief[zh-cn] 裁剪平面数据（每4个浮点数一个平面）
     *
     * @brief[en] Clipping plane data (4 floats per plane)
     */
    public var value: Option<ArrayList<Float32>> = None
    /**
     * @brief[zh-cn] 是否需要更新
     *
     * @brief[en] Whether update is needed
     */
    public var needsUpdate: Bool = false
}

/**
 * @brief[zh-cn] bgfx 裁剪平面管理
 * @explain[zh-cn] 对照 WebGLClipping，管理场景和材质的裁剪平面。将裁剪平面投影到视图空间后传递给着色器 uniform。
 *
 * @brief[en] bgfx clipping plane management
 * @explain[en] Corresponds to WebGLClipping, manages scene and material clipping planes. Projects clipping planes to view space before passing to shader uniforms.
 */
public class BgfxClipping {
    /**
     * @brief[zh-cn] 裁剪平面 uniform
     *
     * @brief[en] Clipping plane uniform
     */
    public let uniform: ClippingUniform
    /**
     * @brief[zh-cn] 裁剪平面数量
     *
     * @brief[en] Number of clipping planes
     */
    public var numPlanes: Int64 = 0
    /**
     * @brief[zh-cn] 交叉裁剪平面数量
     *
     * @brief[en] Number of intersection clipping planes
     */
    public var numIntersection: Int64 = 0

    /**
     * @brief[zh-cn] 全局裁剪状态数据
     *
     * @brief[en] Global clipping state data
     */
    private var globalState: Option<ArrayList<Float32>> = None
    /**
     * @brief[zh-cn] 全局裁剪平面数量
     *
     * @brief[en] Global clipping plane count
     */
    private var numGlobalPlanes: Int64 = 0
    /**
     * @brief[zh-cn] 是否启用局部裁剪
     *
     * @brief[en] Whether local clipping is enabled
     */
    private var localClippingEnabled: Bool = false
    /**
     * @brief[zh-cn] 是否正在渲染阴影
     *
     * @brief[en] Whether shadows are currently being rendered
     */
    private var renderingShadows: Bool = false

    /**
     * @brief[zh-cn] 临时裁剪平面
     *
     * @brief[en] Temporary clipping planes
     */
    private let plane: Plane = Plane()
    /**
     * @brief[zh-cn] 视图法线矩阵
     *
     * @brief[en] View normal matrix
     */
    private let viewNormalMatrix: Matrix3 = Matrix3()

    public init() {
        this.uniform = ClippingUniform()
    }

    /**
     * @brief[zh-cn] 初始化裁剪平面
     * @explain[zh-cn] 对照 WebGLClipping.init()，设置全局裁剪平面并返回是否启用裁剪
     * @param[zh-cn] planes 全局裁剪平面数组
     * enableLocalClipping 是否启用局部裁剪
     * @return[zh-cn] 是否启用裁剪
     *
     * @brief[en] Initializes clipping planes
     * @explain[en] Corresponds to WebGLClipping.init(), sets global clipping planes and returns whether clipping is enabled
     * @param[en] planes Global clipping plane array
     * enableLocalClipping Whether to enable local clipping
     * @return[en] Whether clipping is enabled
     */
    public func `init`(planes: ArrayList<Plane>, enableLocalClipping: Bool): Bool {
        let enabled = planes.size > 0 ||
            enableLocalClipping ||
            numGlobalPlanes > 0 ||
            localClippingEnabled

        localClippingEnabled = enableLocalClipping
        numGlobalPlanes = Int64(planes.size)

        return enabled
    }

    /**
     * @brief[zh-cn] 开始阴影渲染
     * @explain[zh-cn] 对照 WebGLClipping.beginShadows()，标记阴影渲染开始
     *
     * @brief[en] Begins shadow rendering
     * @explain[en] Corresponds to WebGLClipping.beginShadows(), marks the start of shadow rendering
     */
    public func beginShadows(): Unit {
        renderingShadows = true
        projectPlanes(None, None, 0, false)
    }

    /**
     * @brief[zh-cn] 结束阴影渲染
     * @explain[zh-cn] 对照 WebGLClipping.endShadows()，标记阴影渲染结束
     *
     * @brief[en] Ends shadow rendering
     * @explain[en] Corresponds to WebGLClipping.endShadows(), marks the end of shadow rendering
     */
    public func endShadows(): Unit {
        renderingShadows = false
    }

    /**
     * @brief[zh-cn] 设置全局裁剪状态
     * @explain[zh-cn] 对照 WebGLClipping.setGlobalState()，将全局裁剪平面投影到视图空间
     * @param[zh-cn] planes 全局裁剪平面数组
     * camera 相机
     *
     * @brief[en] Sets global clipping state
     * @explain[en] Corresponds to WebGLClipping.setGlobalState(), projects global clipping planes to view space
     * @param[en] planes Global clipping plane array
     * camera Camera
     */
    public func setGlobalState(planes: ArrayList<Plane>, camera: Camera): Unit {
        globalState = Some(projectPlanes(Some(planes), Some(camera), 0, false))
    }

    /**
     * @brief[zh-cn] 设置材质裁剪状态
     * @explain[zh-cn] 对照 WebGLClipping.setState()，从材质读取裁剪平面并更新 uniform
     * @param[zh-cn] material 材质
     * camera 相机
     * useCache 是否使用缓存
     *
     * @brief[en] Sets material clipping state
     * @explain[en] Corresponds to WebGLClipping.setState(), reads clipping planes from material and updates uniforms
     * @param[en] material Material
     * camera Camera
     * useCache Whether to use cache
     */
    public func setState(material: Material, camera: Camera, useCache: Bool): Unit {
        let planesArrOpt: Option<ArrayList<Plane>> = match (material) {
            case m: Material => m.clippingPlanes
            case _ => None
        }
        let clipIntersection = match (material) {
            case m: Material => m.clipIntersection
            case _ => false
        }
        let clipShadows = match (material) {
            case m: Material => m.clipShadows
            case _ => false
        }

        let planesSize: Int64 = match (planesArrOpt) {
            case Some(arr) => Int64(arr.size)
            case None => 0
        }

        if (!localClippingEnabled || planesSize == 0 ||
            (renderingShadows && !clipShadows)) {
            if (renderingShadows) {
                projectPlanes(None, Some(camera), 0, false)
            } else {
                resetGlobalState()
            }
        } else {
            let nGlobal: Int64 = if (renderingShadows) { 0 } else { numGlobalPlanes }
            let lGlobal: Int64 = nGlobal * 4

            let dstArray = projectPlanes(planesArrOpt, Some(camera), lGlobal, !useCache)

            match (globalState) {
                case Some(gs) =>
                    var i = 0
                    while (i != lGlobal) {
                        if (i < Int64(dstArray.size) && i < Int64(gs.size)) {
                            dstArray[Int64(i)] = gs[Int64(i)]
                        }
                        i += 1
                    }
                case None => ()
            }

            this.numIntersection = if (clipIntersection) { this.numPlanes } else { 0 }
            this.numPlanes += nGlobal
        }
    }

    /**
     * @brief[zh-cn] 重置全局裁剪状态
     *
     * @brief[en] Resets global clipping state
     */
    private func resetGlobalState(): Unit {
        match (globalState) {
            case Some(state) =>
                uniform.value = Some(state)
                uniform.needsUpdate = numGlobalPlanes > 0
            case None =>
                uniform.value = None
                uniform.needsUpdate = false
        }
        numPlanes = numGlobalPlanes
        numIntersection = 0
    }

    /**
     * @brief[zh-cn] 投影裁剪平面到视图空间
     * @explain[zh-cn] 对照 WebGLClipping.js projectPlanes()，将裁剪平面通过视图矩阵变换后写入 uniform 数组
     * @param[zh-cn] planes 裁剪平面数组（None 表示无平面）
     * camera 相机
     * dstOffset 目标数组写入偏移
     * skipTransform 是否跳过投影变换
     * @return[zh-cn] 目标 Float32 数组
     *
     * @brief[en] Projects clipping planes to view space
     * @explain[en] Corresponds to WebGLClipping.js projectPlanes(), transforms clipping planes through view matrix and writes to uniform array
     * @param[en] planes Clipping plane array (None means no planes)
     * camera Camera
     * dstOffset Destination array write offset
     * skipTransform Whether to skip projection transform
     * @return[en] Destination Float32 array
     */
    private func projectPlanes(planes: Option<ArrayList<Plane>>, camera: Option<Camera>, dstOffset: Int64, skipTransform: Bool): ArrayList<Float32> {
        let nPlanes: Int64 = match (planes) {
            case Some(p) => Int64(p.size)
            case None => 0
        }

        let emptyDst = ArrayList<Float32>()

        if (nPlanes != 0) {
            let baseDst: ArrayList<Float32> = match (uniform.value) {
                case Some(arr) => arr
                case None => ArrayList<Float32>()
            }

            let flatSize: Int64 = dstOffset + nPlanes * 4
            let dstArray: ArrayList<Float32>

            if (!skipTransform || baseDst.size == 0) {
                let viewMatrix: Matrix4 = match (camera) {
                    case Some(cam) =>
                        match (cam) {
                            case c: Camera => c.matrixWorldInverse
                            case _ => Matrix4()
                        }
                    case None => Matrix4()
                }
                viewNormalMatrix.getNormalMatrix(viewMatrix)

                if (Int64(baseDst.size) < flatSize) {
                    dstArray = ArrayList<Float32>()
                    for (_ in 0..flatSize) { dstArray.add(0.0f32) }
                    var k = 0
                    while (k < dstOffset && k < Int64(baseDst.size)) {
                        dstArray[Int64(k)] = baseDst[Int64(k)]
                        k += 1
                    }
                } else {
                    dstArray = baseDst
                }

                match (planes) {
                    case Some(p) =>
                        var i = 0
                        var i4 = dstOffset
                        while (i != nPlanes) {
                            if (i < Int64(p.size)) {
                                let pl = p[Int64(i)]
                                this.plane.copy(pl).applyMatrix4(viewMatrix, optionalNormalMatrix: Some(viewNormalMatrix))
                                dstArray[Int64(i4)] = Float32(this.plane.normal.x)
                                dstArray[Int64(i4 + 1)] = Float32(this.plane.normal.y)
                                dstArray[Int64(i4 + 2)] = Float32(this.plane.normal.z)
                                dstArray[Int64(i4 + 3)] = Float32(this.plane.constant)
                            }
                            i += 1
                            i4 += 4
                        }
                    case None => ()
                }
            } else {
                dstArray = baseDst
            }

            uniform.value = Some(dstArray)
            uniform.needsUpdate = true

            this.numPlanes = nPlanes
            this.numIntersection = 0
            return dstArray
        }

        this.numPlanes = 0
        this.numIntersection = 0
        return emptyDst
    }
}
