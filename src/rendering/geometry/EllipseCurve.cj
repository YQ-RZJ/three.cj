/**
 * @file[zh-cn] 椭圆曲线
 * @brief[zh-cn] 绕中心点的椭圆曲线
 * @explain[zh-cn] 
 * 对应 Three.js extras/curves/EllipseCurve.js。
 *
 * @file[en] Ellipse Curve
 * @brief[en] Elliptical curve around a center point
 * @explain[en] 
 * Corresponds to Three.js extras/curves/EllipseCurve.js.
 */
package three.rendering.geometry
import std.collection.*

import three.core.math.*
import std.math.*

/**
 * @brief[zh-cn] 椭圆曲线类
 * @explain[zh-cn] 
 * 绕中心点的椭圆曲线，支持 x/y 半径、起始/终止角度、顺时针和旋转。
 *
 * @brief[en] Ellipse curve class
 * @explain[en] 
 * Elliptical curve around a center point, supporting x/y radii, start/end angles, clockwise direction and rotation.
 */
public open class EllipseCurve <: Curve {
    /**
     * 椭圆中心的 X 坐标
     * @default 0
     */
    public var aX: Float64

    /**
     * 椭圆中心的 Y 坐标
     * @default 0
     */
    public var aY: Float64

    /**
     * X 方向半径。设为与 yRadius 相同可得圆
     * @default 1
     */
    public var xRadius: Float64

    /**
     * Y 方向半径。设为与 xRadius 相同可得圆
     * @default 1
     */
    public var yRadius: Float64

    /**
     * 起始角（弧度，从正 X 轴起）
     * @default 0
     */
    public var aStartAngle: Float64

    /**
     * 终止角（弧度，从正 X 轴起）
     * @default Math.PI*2
     */
    public var aEndAngle: Float64

    /**
     * 是否顺时针绘制
     * @default false
     */
    public var aClockwise: Bool

    /**
     * 椭圆的旋转角（弧度，从正 X 轴逆时针）
     * @default 0
     */
    public var aRotation: Float64

    /**
     * @param[zh-cn] aX 椭圆中心 X 坐标，默认为 0
     * @param[zh-cn] aY 椭圆中心 Y 坐标，默认为 0
     * @param[zh-cn] xRadius X 方向半径，默认为 1
     * @param[zh-cn] yRadius Y 方向半径，默认为 1
     * @param[zh-cn] aStartAngle 起始角，默认为 0
     * @param[zh-cn] aEndAngle 止止角，默认为 Math.PI*2
     * @param[zh-cn] aClockwise 是否顺时针，默认为 false
     * @param[zh-cn] aRotation 旋转角，默认为 0
     *
     * 构造新的椭圆曲线
     *
     * @param[en] aX X coordinate of ellipse center, default 0
     * @param[en] aY Y coordinate of ellipse center, default 0
     * @param[en] xRadius X-direction radius, default 1
     * @param[en] yRadius Y-direction radius, default 1
     * @param[en] aStartAngle Start angle, default 0
     * @param[en] aEndAngle End angle, default Math.PI*2
     * @param[en] aClockwise Whether clockwise, default false
     * @param[en] aRotation Rotation angle, default 0
     *
     * Construct a new ellipse curve
     */
    public init(aX!: Float64 = 0.0, aY!: Float64 = 0.0, xRadius!: Float64 = 1.0, yRadius!: Float64 = 1.0, aStartAngle!: Float64 = 0.0, aEndAngle!: Float64 = 2.0 * PI, aClockwise!: Bool = false, aRotation!: Float64 = 0.0) {
        super()
        this.kind = "EllipseCurve"
        this.aX = aX
        this.aY = aY
        this.xRadius = xRadius
        this.yRadius = yRadius
        this.aStartAngle = aStartAngle
        this.aEndAngle = aEndAngle
        this.aClockwise = aClockwise
        this.aRotation = aRotation
    }

    /**
     * 兼容重载：8 参数形式
     */

    /**
     * @param[zh-cn] t 插值因子，0 到 1 之间
     * @return[zh-cn] 椭圆上的点（Vector3，z=0）
     *
     * 返回椭圆上给定插值因子 t 处的点
     *
     * 算法与 JS 侧一致：处理 deltaAngle 在 [0, 2π] 内、aClockwise 反向、aRotation 旋转。
     *
     * @param[en] t Interpolation factor, between 0 and 1
     * @return[en] Point on the ellipse (Vector3, z=0)
     *
     * Return the point on the ellipse at the given interpolation factor t
     *
     * Algorithm consistent with JS side: handles deltaAngle within [0, 2π], aClockwise reversal, aRotation rotation.
     */
    public override func getPoint(t: Float64): Vector3 {
        let twoPi = 2.0 * PI
        var deltaAngle = this.aEndAngle - this.aStartAngle
        let samePoints = abs(deltaAngle) < 2.220446049250313e-16
        // 确保 deltaAngle 在 0 .. 2π
        while (deltaAngle < 0.0) { deltaAngle += twoPi }
        while (deltaAngle > twoPi) { deltaAngle -= twoPi }
        if (deltaAngle < 2.220446049250313e-16) {
            if (samePoints) {
                deltaAngle = 0.0
            } else {
                deltaAngle = twoPi
            }
        }
        if (this.aClockwise && !samePoints) {
            if (deltaAngle == twoPi) {
                deltaAngle = -twoPi
            } else {
                deltaAngle = deltaAngle - twoPi
            }
        }
        let angle = this.aStartAngle + t * deltaAngle
        var x = this.aX + this.xRadius * cos(angle)
        var y = this.aY + this.yRadius * sin(angle)
        if (this.aRotation != 0.0) {
            let cosR = cos(this.aRotation)
            let sinR = sin(this.aRotation)
            let tx = x - this.aX
            let ty = y - this.aY
            // 绕椭圆中心旋转点
            x = tx * cosR - ty * sinR + this.aX
            y = tx * sinR + ty * cosR + this.aY
        }
        return Vector3(x, y, 0.0)
    }

    /**
     * 将给定椭圆曲线的设置复制到此实例
     */
    public override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: EllipseCurve =>
                this.aX = src.aX
                this.aY = src.aY
                this.xRadius = src.xRadius
                this.yRadius = src.yRadius
                this.aStartAngle = src.aStartAngle
                this.aEndAngle = src.aEndAngle
                this.aClockwise = src.aClockwise
                this.aRotation = src.aRotation
            case _ => ()
        }
        return this
    }

    /**
     * 从 JSON 反序列化椭圆曲线
     */
    public func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)
        if (let Some(v) <- json.get("aX")) { match (v) { case d: Float64 => this.aX = d; case _ => () } }
        if (let Some(v) <- json.get("aY")) { match (v) { case d: Float64 => this.aY = d; case _ => () } }
        if (let Some(v) <- json.get("xRadius")) { match (v) { case d: Float64 => this.xRadius = d; case _ => () } }
        if (let Some(v) <- json.get("yRadius")) { match (v) { case d: Float64 => this.yRadius = d; case _ => () } }
        if (let Some(v) <- json.get("aStartAngle")) { match (v) { case d: Float64 => this.aStartAngle = d; case _ => () } }
        if (let Some(v) <- json.get("aEndAngle")) { match (v) { case d: Float64 => this.aEndAngle = d; case _ => () } }
        if (let Some(v) <- json.get("aClockwise")) { match (v) { case b: Bool => this.aClockwise = b; case _ => () } }
        if (let Some(v) <- json.get("aRotation")) { match (v) { case d: Float64 => this.aRotation = d; case _ => () } }
        return this
    }
}
