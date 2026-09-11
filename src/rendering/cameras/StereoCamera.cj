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
 * @file[zh-cn] StereoCamera 立体相机
 * @brief[zh-cn] 用左右两个 PerspectiveCamera 模拟双眼立体视角
 * @explain[zh-cn] 用于 VR / 3D 立体渲染，渲染器内部分别绘制 cameraL/cameraR 通道。
 * eyeSep 表示左右眼间距（米），默认 0.064（人眼平均瞳距）。
 *
 * @file[en] StereoCamera
 * @brief[en] Simulates binocular stereo vision using left and right PerspectiveCamera
 * @explain[en] Used for VR / 3D stereo rendering, the renderer internally draws cameraL/cameraR channels separately.
 * eyeSep represents the inter-pupillary distance (meters), default 0.064 (average human IPD).
 *
 * @package three.rendering.cameras
 */
package three.rendering.cameras

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 立体相机
 * @explain[zh-cn] 用左右两个 PerspectiveCamera 模拟双眼立体视角。
 * 用于 VR / 3D 立体渲染，渲染器内部分别绘制 cameraL/cameraR 通道。
 * eyeSep 表示左右眼间距（米），默认 0.064（人眼平均瞳距）。
 *
 * @brief[en] Stereo camera
 * @explain[en] Simulates binocular stereo vision using left and right PerspectiveCamera.
 * Used for VR / 3D stereo rendering, the renderer internally draws cameraL/cameraR channels separately.
 * eyeSep represents the inter-pupillary distance (meters), default 0.064 (average human IPD).
 */
public class StereoCamera {
    /**
     * @brief[zh-cn] 类型标签
     *
     * @brief[en] Type label
     */
    public var kind: String

    /**
     * @brief[zh-cn] 宽高比，左右眼共用
     *
     * @brief[en] Aspect ratio, shared by both eyes
     */
    public var aspect: Float64

    /**
     * @brief[zh-cn] 左右眼间距（米），默认 0.064
     *
     * @brief[en] Inter-pupillary distance (meters), default 0.064
     */
    public var eyeSep: Float64

    /**
     * @brief[zh-cn] 左眼相机
     *
     * @brief[en] Left eye camera
     */
    public var cameraL: PerspectiveCamera

    /**
     * @brief[zh-cn] 右眼相机
     *
     * @brief[en] Right eye camera
     */
    public var cameraR: PerspectiveCamera

    /**
     * @brief[zh-cn] 缓存：上次 update 的焦点距离
     *
     * @brief[en] Cached focus distance from the last update
     */
    private var _cacheFocus: Float64
    /**
     * @brief[zh-cn] 缓存：上次 update 的视场角
     *
     * @brief[en] Cached field of view from the last update
     */
    private var _cacheFov: Float64
    /**
     * @brief[zh-cn] 缓存：上次 update 的宽高比
     *
     * @brief[en] Cached aspect ratio from the last update
     */
    private var _cacheAspect: Float64
    /**
     * @brief[zh-cn] 缓存：上次 update 的近裁面
     *
     * @brief[en] Cached near clipping plane from the last update
     */
    private var _cacheNear: Float64
    /**
     * @brief[zh-cn] 缓存：上次 update 的远裁面
     *
     * @brief[en] Cached far clipping plane from the last update
     */
    private var _cacheFar: Float64
    /**
     * @brief[zh-cn] 缓存：上次 update 的缩放值
     *
     * @brief[en] Cached zoom value from the last update
     */
    private var _cacheZoom: Float64
    /**
     * @brief[zh-cn] 缓存：上次 update 的眼间距
     *
     * @brief[en] Cached eye separation from the last update
     */
    private var _cacheEyeSep: Float64

    /**
     * @brief[zh-cn] 左眼偏移矩阵
     *
     * @brief[en] Left eye offset matrix
     */
    private var _eyeLeft: Matrix4

    /**
     * @brief[zh-cn] 右眼偏移矩阵
     *
     * @brief[en] Right eye offset matrix
     */
    private var _eyeRight: Matrix4

    /**
     * @brief[zh-cn] 构造立体相机
     *
     * @brief[en] Construct stereo camera
     */
    public init() {
        this.kind = "StereoCamera"
        this.aspect = 1.0
        this.eyeSep = 0.064
        this.cameraL = PerspectiveCamera()
        this.cameraL.layers.enable(1)
        this.cameraL.matrixAutoUpdate = false
        this.cameraR = PerspectiveCamera()
        this.cameraR.layers.enable(2)
        this.cameraR.matrixAutoUpdate = false
        this._cacheFocus = 0.0
        this._cacheFov = 0.0
        this._cacheAspect = 0.0
        this._cacheNear = 0.0
        this._cacheFar = 0.0
        this._cacheZoom = 0.0
        this._cacheEyeSep = 0.0
        this._eyeLeft = Matrix4()
        this._eyeRight = Matrix4()
    }

    /**
     * @brief[zh-cn] 同步本立体相机与给定主相机。主相机投影变化时重新计算左右眼投影矩阵
     * @param[zh-cn] camera 主透视相机
     *
     * @brief[en] Synchronize this stereo camera with the given main camera. Recalculates left/right eye projection matrices when main camera projection changes
     * @param[en] camera Main perspective camera
     */
    public func update(camera: PerspectiveCamera): Unit {
        let needsUpdate = this._cacheFocus != camera.focus || this._cacheFov != camera.fov ||
            this._cacheAspect != (camera.aspect * this.aspect) || this._cacheNear != camera.near ||
            this._cacheFar != camera.far || this._cacheZoom != camera.zoom || this._cacheEyeSep != this.eyeSep

        if (needsUpdate) {
            this._cacheFocus = camera.focus
            this._cacheFov = camera.fov
            this._cacheAspect = camera.aspect * this.aspect
            this._cacheNear = camera.near
            this._cacheFar = camera.far
            this._cacheZoom = camera.zoom
            this._cacheEyeSep = this.eyeSep

            let projMatrix = Matrix4().copy(camera.projectionMatrix)
            let eyeSepHalf = this.eyeSep / 2.0
            let eyeSepOnProjection = eyeSepHalf * camera.near / camera.focus
            let ymax = (camera.near * tan(MathUtils.degToRad(camera.fov * 0.5))) / camera.zoom

            this._eyeLeft.identity()
            this._eyeRight.identity()
            this._eyeLeft.elements[12] = -eyeSepHalf
            this._eyeRight.elements[12] = eyeSepHalf

            // 左眼
            var xmin = -ymax * (camera.aspect * this.aspect) + eyeSepOnProjection
            var xmax = ymax * (camera.aspect * this.aspect) + eyeSepOnProjection
            projMatrix.elements[0] = 2.0 * camera.near / (xmax - xmin)
            projMatrix.elements[8] = (xmax + xmin) / (xmax - xmin)
            this.cameraL.projectionMatrix.copy(projMatrix)

            // 右眼
            xmin = -ymax * (camera.aspect * this.aspect) - eyeSepOnProjection
            xmax = ymax * (camera.aspect * this.aspect) - eyeSepOnProjection
            projMatrix.elements[0] = 2.0 * camera.near / (xmax - xmin)
            projMatrix.elements[8] = (xmax + xmin) / (xmax - xmin)
            this.cameraR.projectionMatrix.copy(projMatrix)
        }

        this.cameraL.matrix.copy(camera.matrixWorld).multiply(this._eyeLeft)
        this.cameraL.matrixWorldNeedsUpdate = true
        this.cameraR.matrix.copy(camera.matrixWorld).multiply(this._eyeRight)
        this.cameraR.matrixWorldNeedsUpdate = true
    }
}
