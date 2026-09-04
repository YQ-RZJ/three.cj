/**
 * @file[zh-cn] PerspectiveCamera 透视投影相机
 * @brief[zh-cn] 透视投影相机：模拟人眼近大远小效果，最常用的相机类型
 * @explain[zh-cn] fov/aspect/near/far 完整定义视锥；filmGauge/filmOffset 提供物理相机参数；
 * view 字段支持多视口（VR/多显示器）裁剪。
 *
 * @file[en] PerspectiveCamera
 * @brief[en] Perspective camera: simulates human eye perspective distortion, the most commonly used camera type
 * @explain[en] fov/aspect/near/far fully define the viewing frustum; filmGauge/filmOffset provide physical camera parameters;
 * view field supports multi-viewport (VR/multi-display) clipping.
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
 * @brief[zh-cn] 透视投影相机
 * @explain[zh-cn] 模拟人眼近大远小效果，最常用的相机类型。
 * fov/aspect/near/far 完整定义视锥；filmGauge/filmOffset 提供物理相机参数；
 * view 字段支持多视口（VR/多显示器）裁剪。
 *
 * @brief[en] Perspective camera
 * @explain[en] Simulates human eye perspective distortion, the most commonly used camera type.
 * fov/aspect/near/far fully define the viewing frustum; filmGauge/filmOffset provide physical camera parameters;
 * view field supports multi-viewport (VR/multi-display) clipping.
 */
@JsonAdapter[withSuperClass = Camera]
public open class PerspectiveCamera <: Camera {
    /**
     * @brief[zh-cn] 垂直视场角（度）
     *
     * @brief[en] Vertical field of view (degrees)
     */
    public var fov: Float64
    /**
     * @brief[zh-cn] 宽高比
     *
     * @brief[en] Aspect ratio
     */
    public var aspect: Float64
    /**
     * @brief[zh-cn] 缩放因子
     *
     * @brief[en] Zoom factor
     */
    public var zoom: Float64
    /**
     * @brief[zh-cn] 焦距
     *
     * @brief[en] Focus distance
     */
    public var focus: Float64
    /**
     * @brief[zh-cn] 胶片尺寸（毫米）
     *
     * @brief[en] Film gauge (millimeters)
     */
    public var filmGauge: Float64
    /**
     * @brief[zh-cn] 胶片偏移
     *
     * @brief[en] Film offset
     */
    public var filmOffset: Float64
    /**
     * @brief[zh-cn] 多视口裁剪配置（VR/多显示器），用具体类型 CameraView 以满足 fastjson 宏约束
     *
     * @brief[en] Multi-viewport clipping configuration (VR/multi-display), uses concrete type CameraView for fastjson macro constraint
     */
    public var view: Option<CameraView>

    /**
     * @brief[zh-cn] 构造透视投影相机
     * @param[zh-cn] fov 垂直视场角（度），默认 50
     * aspect 宽高比，默认 1
     * near 近裁剪面距离，默认 0.1
     * far 远裁剪面距离，默认 2000
     *
     * @brief[en] Construct perspective camera
     * @param[en] fov Vertical field of view (degrees), default 50
     * aspect Aspect ratio, default 1
     * near Near clipping plane distance, default 0.1
     * far Far clipping plane distance, default 2000
     */
    public init(fov!: Float64 = 50.0, aspect!: Float64 = 1.0, near!: Float64 = 0.1, far!: Float64 = 2000.0) {
        super(near: near, far: far)
        this.kind = "PerspectiveCamera"
        this.fov = fov
        this.zoom = 1.0
        this.near = near
        this.far = far
        this.focus = 10.0
        this.aspect = aspect
        this.view = None
        this.filmGauge = 35.0
        this.filmOffset = 0.0
        // 在构造函数中内联投影矩阵更新，避免调用实例方法（仓颉限制：
        // open class 子类构造中不可访问实例方法）。
        // 与 _updateProjectionMatrix 一致：top 按 zoom 缩放。
        let nearT = near
        var topT = nearT * tan(MathUtils.degToRad(0.5 * fov)) / this.zoom
        var heightT = 2.0 * topT
        var widthT = aspect * heightT
        var leftT = -0.5 * widthT
        this.projectionMatrix.makePerspective(leftT, leftT + widthT, topT, topT - heightT, nearT, far)
        this.projectionMatrixInverse.copy(this.projectionMatrix).invert()
    }

    private func _updateProjectionMatrix(): Unit {
        let near = this.near
        var top = near * tan(MathUtils.degToRad(0.5 * this.fov)) / this.zoom
        var height = 2.0 * top
        var width = this.aspect * height
        var left = -0.5 * width

        match (this.view) {
            case Some(view) =>
                if (view.enabled) {
                    let fullWidth = view.fullWidth
                    let fullHeight = view.fullHeight
                    let offsetX = view.offsetX
                    let offsetY = view.offsetY
                    let vw = view.width
                    let vh = view.height
                    left += offsetX * width / fullWidth
                    top -= offsetY * height / fullHeight
                    width *= vw / fullWidth
                    height *= vh / fullHeight
                }
            case None => ()
        }

        let skew = this.filmOffset
        if (skew != 0.0) { left += near * skew / this.getFilmWidth() }

        this.projectionMatrix.makePerspective(left, left + width, top, top - height, near, this.far)
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
            case s: PerspectiveCamera =>
                this.fov = s.fov
                this.zoom = s.zoom
                this.near = s.near
                this.far = s.far
                this.focus = s.focus
                this.aspect = s.aspect
                this.view = match (s.view) {
                    case Some(v) => Some(v.clone())
                    case None => None
                }
                this.filmGauge = s.filmGauge
                this.filmOffset = s.filmOffset
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 根据焦距设置视场角
     * @param[zh-cn] focalLength 焦距
     *
     * @brief[en] Set field of view based on focal length
     * @param[en] focalLength Focal length
     */
    public func setFocalLength(focalLength: Float64): Unit {
        let vExtentSlope = 0.5 * this.getFilmHeight() / focalLength
        this.fov = MathUtils.radToDeg(2.0 * atan(vExtentSlope))
        this.updateProjectionMatrix()
    }

    /**
     * @brief[zh-cn] 获取焦距
     * @return[zh-cn] 焦距
     *
     * @brief[en] Get focal length
     * @return[en] Focal length
     */
    public func getFocalLength(): Float64 {
        let vExtentSlope = tan(MathUtils.degToRad(0.5 * this.fov))
        return 0.5 * this.getFilmHeight() / vExtentSlope
    }

    /**
     * @brief[zh-cn] 获取考虑 zoom 后的有效视场角
     * @return[zh-cn] 有效视场角（度）
     *
     * @brief[en] Get effective field of view considering zoom
     * @return[en] Effective field of view (degrees)
     */
    public func getEffectiveFOV(): Float64 {
        return MathUtils.radToDeg(2.0 * atan(tan(MathUtils.degToRad(0.5 * this.fov)) / this.zoom))
    }

    /**
     * @brief[zh-cn] 获取胶片宽度
     * @return[zh-cn] 胶片宽度
     *
     * @brief[en] Get film width
     * @return[en] Film width
     */
    public func getFilmWidth(): Float64 {
        return this.filmGauge * min(this.aspect, 1.0)
    }

    /**
     * @brief[zh-cn] 获取胶片高度
     * @return[zh-cn] 胶片高度
     *
     * @brief[en] Get film height
     * @return[en] Film height
     */
    public func getFilmHeight(): Float64 {
        return this.filmGauge / max(this.aspect, 1.0)
    }

    /**
     * @brief[zh-cn] 获取指定距离处的视图边界
     * @param[zh-cn] distance 距离
     * minTarget 最小目标向量
     * maxTarget 最大目标向量
     *
     * @brief[en] Get view bounds at specified distance
     * @param[en] distance Distance
     * minTarget Minimum target vector
     * maxTarget Maximum target vector
     */
    public func getViewBounds(distance: Float64, minTarget: Vector2, maxTarget: Vector2): Unit {
        // bgfx4cj 左手系：NDC z∈[0,1]，viewZ 为正（相机前方），所以比例因子 = distance / v3.z
        let v3 = Vector3(-1.0, -1.0, 0.5).applyMatrix4(this.projectionMatrixInverse)
        minTarget.set(v3.x, v3.y).multiplyScalar(distance / v3.z)
        let v3b = Vector3(1.0, 1.0, 0.5).applyMatrix4(this.projectionMatrixInverse)
        maxTarget.set(v3b.x, v3b.y).multiplyScalar(distance / v3.z)
    }

    /**
     * @brief[zh-cn] 获取指定距离处的视图尺寸
     * @param[zh-cn] distance 距离
     * target 目标向量
     * @return[zh-cn] 视图尺寸
     *
     * @brief[en] Get view size at specified distance
     * @param[en] distance Distance
     * target Target vector
     * @return[en] View size
     */
    public func getViewSize(distance: Float64, target: Vector2): Vector2 {
        let minT = Vector2()
        let maxT = Vector2()
        this.getViewBounds(distance, minT, maxT)
        return target.subVectors(maxT, minT)
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
        this.aspect = fullWidth / fullHeight
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
        this._updateProjectionMatrix()
    }
}
