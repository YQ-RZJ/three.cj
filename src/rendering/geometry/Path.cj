/**
 * @file[zh-cn] 路径
 * @brief[zh-cn] 由多条子曲线串联构成的 2D 路径
 * @explain[zh-cn] 
 * Path 继承 CurvePath，提供 moveTo/lineTo/bezierCurveTo/quadraticCurveTo/arc/ellipse 等路径绘制方法。
 * 对应 Three.js extras/core/Path.js。
 *
 * @file[en] Path
 * @brief[en] 2D path composed of multiple sub-curves connected in sequence
 * @explain[en] 
 * Path extends CurvePath, providing path drawing methods such as moveTo/lineTo/bezierCurveTo/quadraticCurveTo/arc/ellipse.
 * Corresponds to Three.js extras/core/Path.js.
 */
package three.rendering.geometry

import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 2D 路径类
 * @explain[zh-cn] 
 * Path 继承 CurvePath，提供 moveTo/lineTo/bezierCurveTo 等路径绘制方法。
 *
 * @brief[en] 2D path class
 * @explain[en] 
 * Path extends CurvePath, providing path drawing methods such as moveTo/lineTo/bezierCurveTo.
 */
public open class Path <: CurvePath {
    /**
     * @brief[zh-cn] 当前绘制点
     *
     * @brief[en] Current drawing point
     */
    public var currentPoint: Vector3

    /**
     * @brief[zh-cn] 构造空路径
     *
     * @brief[en] Constructs an empty path
     */
    public init() { super(); this.kind = "Path"; this.currentPoint = Vector3() }

    /**
     * @brief[zh-cn] 从点数组构造路径
     * @param[zh-cn] points 定义路径的 2D 点数组
     *
     * @brief[en] Constructs a path from an array of points
     * @param[en] points Array of 2D points defining the path
     */
    public init(points: Array<Vector3>) { super(); this.kind = "Path"; this.currentPoint = Vector3(); for (i in 0..points.size) { let p = points[i]; let start = if (i == 0) { this.currentPoint.clone() } else { this.curves[this.curves.size - 1].getPoint(1.0).clone() }; let end = Vector3(p.x, p.y, 0.0); this.curves.add(LineCurve(v1: start, v2: end)); this.currentPoint = end } }
    /**
     * @brief[zh-cn] 从点数组创建路径
     * @param[zh-cn] points 点数组
     *
     * @brief[en] Creates path from an array of points
     * @param[en] points Array of points
     */
    public func fromPoints(points: Array<Vector3>): Unit { for (p in points) { this.lineTo(p.x, p.y) } }

    /**
     * @brief[zh-cn] 移动当前绘制点到指定位置
     * @param[zh-cn] x X 坐标
     * y Y 坐标
     *
     * @brief[en] Moves the current drawing point to the specified position
     * @param[en] x X coordinate
     * y Y coordinate
     */
    public func moveTo(x: Float64, y: Float64): Unit { this.currentPoint = Vector3(x, y, 0.0) }

    /**
     * @brief[zh-cn] 从当前点画直线到指定位置
     * @param[zh-cn] x 目标 X 坐标
     * y 目标 Y 坐标
     *
     * @brief[en] Draws a line from the current point to the specified position
     * @param[en] x Target X coordinate
     * y Target Y coordinate
     */
    public func lineTo(x: Float64, y: Float64): Unit {
        let start = this.currentPoint.clone()
        let end = Vector3(x, y, 0.0)
        this.curves.add(LineCurve(v1: start, v2: end))
        this.currentPoint = end
    }
    /**
     * @brief[zh-cn] 从当前点画二次贝塞尔曲线到指定位置
     * @param[zh-cn] cpx 控制点 X 坐标
     * cpy 控制点 Y 坐标
     * x 目标 X 坐标
     * y 目标 Y 坐标
     *
     * @brief[en] Draws a quadratic Bezier curve from the current point to the specified position
     * @param[en] cpx Control point X coordinate
     * cpy Control point Y coordinate
     * x Target X coordinate
     * y Target Y coordinate
     */
    public func quadraticCurveTo(cpx: Float64, cpy: Float64, x: Float64, y: Float64): Unit {
        let start = this.currentPoint.clone()
        let cp = Vector3(cpx, cpy, 0.0)
        let end = Vector3(x, y, 0.0)
        this.curves.add(QuadraticBezierCurve(v0: start, v1: cp, v2: end))
        this.currentPoint = end
    }
    /**
     * @brief[zh-cn] 从当前点画三次贝塞尔曲线到指定位置
     * @param[zh-cn] cp1x 第一个控制点 X 坐标
     * cp1y 第一个控制点 Y 坐标
     * cp2x 第二个控制点 X 坐标
     * cp2y 第二个控制点 Y 坐标
     * x 目标 X 坐标
     * y 目标 Y 坐标
     *
     * @brief[en] Draws a cubic Bezier curve from the current point to the specified position
     * @param[en] cp1x First control point X coordinate
     * cp1y First control point Y coordinate
     * cp2x Second control point X coordinate
     * cp2y Second control point Y coordinate
     * x Target X coordinate
     * y Target Y coordinate
     */
    public func bezierCurveTo(cp1x: Float64, cp1y: Float64, cp2x: Float64, cp2y: Float64, x: Float64, y: Float64): Unit {
        let start = this.currentPoint.clone()
        let cp1 = Vector3(cp1x, cp1y, 0.0)
        let cp2 = Vector3(cp2x, cp2y, 0.0)
        let end = Vector3(x, y, 0.0)
        this.curves.add(CubicBezierCurve(v0: start, v1: cp1, v2: cp2, v3: end))
        this.currentPoint = end
    }
    /**
     * @brief[zh-cn] 添加绝对圆弧
     * @param[zh-cn] aX 圆心 X 坐标
     * aY 圆心 Y 坐标
     * aRadius 半径
     * aStartAngle 起始角
     * aEndAngle 终止角
     * aClockwise 是否顺时针
     *
     * @brief[en] Adds an absolute arc
     * @param[en] aX Center X coordinate
     * aY Center Y coordinate
     * aRadius Radius
     * aStartAngle Start angle
     * aEndAngle End angle
     * aClockwise Whether clockwise
     */
    public func absarc(aX: Float64, aY: Float64, aRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool): Unit {
        this.absellipse(aX, aY, aRadius, aRadius, aStartAngle, aEndAngle, aClockwise, 0.0)
    }
    /**
     * @brief[zh-cn] 添加绝对椭圆弧
     * @param[zh-cn] aX 圆心 X 坐标
     * aY 圆心 Y 坐标
     * xRadius X 方向半径
     * yRadius Y 方向半径
     * aStartAngle 起始角
     * aEndAngle 终止角
     * aClockwise 是否顺时针
     * aRotation 旋转角
     *
     * @brief[en] Adds an absolute ellipse arc
     * @param[en] aX Center X coordinate
     * aY Center Y coordinate
     * xRadius X-direction radius
     * yRadius Y-direction radius
     * aStartAngle Start angle
     * aEndAngle End angle
     * aClockwise Whether clockwise
     * aRotation Rotation angle
     */
    public func absellipse(aX: Float64, aY: Float64, xRadius: Float64, yRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit {
        this.curves.add(EllipseCurve(aX: aX, aY: aY, xRadius: xRadius, yRadius: yRadius, aStartAngle: aStartAngle, aEndAngle: aEndAngle, aClockwise: aClockwise, aRotation: aRotation))
        this.currentPoint = Vector3(aX, aY, 0.0)
    }
    /**
     * @brief[zh-cn] 添加样条曲线通过指定点
     * @param[zh-cn] points 样条曲线通过的点数组
     *
     * @brief[en] Adds a spline curve through the specified points
     * @param[en] points Array of points for the spline curve to pass through
     */
    public func splineThru(points: Array<Vector3>): Unit {
        let all = ArrayList<Vector3>()
        all.add(this.currentPoint.clone())
        for (p in points) { all.add(p.clone()) }
        this.curves.add(SplineCurve(points: all.toArray()))
        this.currentPoint = points[points.size - 1].clone()
    }
    /**
     * @brief[zh-cn] 添加相对圆弧
     * @param[zh-cn] aX 圆心 X 偏移
     * aY 圆心 Y 偏移
     * aRadius 半径
     * aStartAngle 起始角
     * aEndAngle 终止角
     * aClockwise 是否顺时针
     * aRotation 旋转角
     *
     * @brief[en] Adds a relative arc
     * @param[en] aX Center X offset
     * aY Center Y offset
     * aRadius Radius
     * aStartAngle Start angle
     * aEndAngle End angle
     * aClockwise Whether clockwise
     * aRotation Rotation angle
     */
    public func arc(aX: Float64, aY: Float64, aRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit {
        this.absarc(aX + this.currentPoint.x, aY + this.currentPoint.y, aRadius, aStartAngle, aEndAngle, aClockwise)
    }
    public func ellipse(aX: Float64, aY: Float64, xRadius: Float64, yRadius: Float64, aStartAngle: Float64, aEndAngle: Float64, aClockwise: Bool, aRotation: Float64): Unit {
        this.absellipse(aX + this.currentPoint.x, aY + this.currentPoint.y, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise, aRotation)
    }
    /**
     * @brief[zh-cn] 复制源路径的设置到当前实例
     * @param[zh-cn] source 源曲线
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copies settings from the source path to this instance
     * @param[en] source Source curve
     * @return[en] Reference to this instance
     */
    public open override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: Path => this.currentPoint.copy(src.currentPoint)
            case _ => ()
        }
        return this
    }
    /**
     * @brief[zh-cn] 从 JSON 反序列化路径
     * @param[zh-cn] json 包含路径数据的 HashMap
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Deserializes the path from JSON
     * @param[en] json HashMap containing path data
     * @return[en] Reference to this instance
     */
    public open override func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)
        if (let Some(cp) <- json.get("currentPoint")) {
            match (cp) {
                case arr: ArrayList<Any> =>
                    let v = Vector3()
                    var i = 0
                    for (x in arr) {
                        match (x) {
                            case d: Float64 => match (i) { case 0 => v.x = d; case 1 => v.y = d; case 2 => v.z = d; case _ => () }; i += 1
                            case _ => ()
                        }
                    }
                    this.currentPoint = v
                case _ => ()
            }
        }
        return this
    }
}