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
 * @file[zh-cn] OrthographicCamera 正交投影相机
 * @brief[zh-cn] 正交投影相机：无近大远小效果，物体大小不随距离变化
 * @explain[zh-cn] 常用于 2D 场景、UI 渲染、CAD 工程视图、阴影相机（DirectionalLight 内部相机）。
 * left/right/top/bottom 定义视锥箱；view 字段支持多视口裁剪。
 *
 * @file[en] OrthographicCamera
 * @brief[en] Orthographic camera: no perspective distortion, object size does not change with distance
 * @explain[en] Commonly used for 2D scenes, UI rendering, CAD engineering views, shadow cameras (DirectionalLight internal camera).
 * left/right/top/bottom define the viewing frustum box; view field supports multi-viewport clipping.
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
import three.utils.constants.*
import std.collection.*
import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 正交投影相机
 * @explain[zh-cn] 无近大远小效果，物体大小不随距离变化。
 * left/right/top/bottom 定义视锥箱；view 字段支持多视口裁剪。
 *
 * @brief[en] Orthographic camera
 * @explain[en] No perspective distortion, object size does not change with distance.
 * left/right/top/bottom define the viewing frustum box; view field supports multi-viewport clipping.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Camera]
public open class OrthographicCamera <: Camera {
    /**
     * @brief[zh-cn] 视锥左边界
     *
     * @brief[en] View frustum left boundary
     */
    public var left: Float64
    /**
     * @brief[zh-cn] 视锥右边界
     *
     * @brief[en] View frustum right boundary
     */
    public var right: Float64
    /**
     * @brief[zh-cn] 视锥上边界
     *
     * @brief[en] View frustum top boundary
     */
    public var top: Float64
    /**
     * @brief[zh-cn] 视锥下边界
     *
     * @brief[en] View frustum bottom boundary
     */
    public var bottom: Float64
    /**
     * @brief[zh-cn] 缩放因子
     *
     * @brief[en] Zoom factor
     */
    public var zoom: Float64
    /**
     * @brief[zh-cn] 多视口裁剪配置（VR/多显示器），用具体类型 CameraView 以满足 fastjson 宏约束
     *
     * @brief[en] Multi-viewport clipping configuration (VR/multi-display), uses concrete type CameraView for fastjson macro constraint
     */
    public var view: Option<CameraView>

    /**
     * @brief[zh-cn] 构造正交投影相机
     * @param[zh-cn] left 视锥左边界，默认 -1
     * right 视锥右边界，默认 1
     * top 视锥上边界，默认 1
     * bottom 视锥下边界，默认 -1
     * near 近裁剪面距离，默认 0.1
     * far 远裁剪面距离，默认 2000
     *
     * @brief[en] Construct orthographic camera
     * @param[en] left View frustum left boundary, default -1
     * right View frustum right boundary, default 1
     * top View frustum top boundary, default 1
     * bottom View frustum bottom boundary, default -1
     * near Near clipping plane distance, default 0.1
     * far Far clipping plane distance, default 2000
     */
    public init(left!: Float64 = -1.0, right!: Float64 = 1.0, top!: Float64 = 1.0, bottom!: Float64 = -1.0, near!: Float64 = 0.1, far!: Float64 = 2000.0) {
        super(near: near, far: far)
        this.left = left
        this.right = right
        this.top = top
        this.bottom = bottom
        this.near = near
        this.far = far
        this.zoom = 1.0
        this.view = None
        // 在构造函数中内联投影矩阵更新，避免调用实例方法（仓颉限制：
        // open class 子类构造中不可访问实例方法）。
        let dx = (right - left) / (2.0 * this.zoom)
        let dy = (top - bottom) / (2.0 * this.zoom)
        let cx = (right + left) / 2.0
        let cy = (top + bottom) / 2.0
        this.projectionMatrix.makeOrthographic(cx - dx, cx + dx, cy + dy, cy - dy, near, far)
        this.projectionMatrixInverse.copy(this.projectionMatrix).invert()
    }

    /**
     * @brief[zh-cn] 将给定源相机的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy values from the given source camera to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] This instance
     */
    public open override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: OrthographicCamera =>
                this.left = s.left
                this.right = s.right
                this.top = s.top
                this.bottom = s.bottom
                this.near = s.near
                this.far = s.far
                this.zoom = s.zoom
                this.view = match (s.view) {
                    case Some(v) => Some(v.clone())
                    case None => None
                }
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置视口偏移
     * @param[zh-cn] fullWidth 全视口宽度
     * fullHeight 全视口高度
     * x 视口偏移 X
     * y 视口偏移 Y
     * width 视口宽度
     * height 视口高度
     *
     * @brief[en] Set viewport offset
     * @param[en] fullWidth Full viewport width
     * fullHeight Full viewport height
     * x Viewport offset X
     * y Viewport offset Y
     * width Viewport width
     * height Viewport height
     */
    public func setViewOffset(fullWidth: Float64, fullHeight: Float64, x: Float64, y: Float64, width: Float64, height: Float64): Unit {
        let v = match (this.view) {
            case Some(v) => v
            case None => CameraView()
        }
        v.enabled = true
        v.fullWidth = fullWidth
        v.fullHeight = fullHeight
        v.offsetX = x
        v.offsetY = y
        v.width = width
        v.height = height
        this.view = Some(v)
        this.updateProjectionMatrix()
    }

    /**
     * @brief[zh-cn] 清除视口偏移
     *
     * @brief[en] Clear viewport offset
     */
    public func clearViewOffset(): Unit {
        match (this.view) {
            case Some(v) => v.enabled = false
            case None => ()
        }
        this.updateProjectionMatrix()
    }

    /**
     * @brief[zh-cn] 更新投影矩阵
     *
     * @brief[en] Update projection matrix
     */
    public func updateProjectionMatrix(): Unit {
        let dx = (this.right - this.left) / (2.0 * this.zoom)
        let dy = (this.top - this.bottom) / (2.0 * this.zoom)
        let cx = (this.right + this.left) / 2.0
        let cy = (this.top + this.bottom) / 2.0
        var left = cx - dx
        var right = cx + dx
        var top = cy + dy
        var bottom = cy - dy

        match (this.view) {
            case Some(view) =>
                if (view.enabled) {
                    let fullWidth = view.fullWidth
                    let fullHeight = view.fullHeight
                    let offsetX = view.offsetX
                    let offsetY = view.offsetY
                    let vw = view.width
                    let vh = view.height
                    let scaleW = (this.right - this.left) / fullWidth / this.zoom
                    let scaleH = (this.top - this.bottom) / fullHeight / this.zoom
                    left += scaleW * offsetX
                    right = left + scaleW * vw
                    top -= scaleH * offsetY
                    bottom = top - scaleH * vh
                }
            case None => ()
        }

        this.projectionMatrix.makeOrthographic(left, right, top, bottom, this.near, this.far)
        this.projectionMatrixInverse.copy(this.projectionMatrix).invert()
    }
}
