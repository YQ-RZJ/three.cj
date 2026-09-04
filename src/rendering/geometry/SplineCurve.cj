/**
 * @file[zh-cn] 2D 样条曲线
 * @brief[zh-cn] 由点数组定义的 2D Catmull-Rom 样条曲线
 * @explain[zh-cn] 
 * SplineCurve 继承 Curve，由一组 2D 点定义，使用 CatmullRom 插值。
 * 对应 Three.js extras/curves/SplineCurve.js。
 *
 * @file[en] 2D Spline Curve
 * @brief[en] 2D Catmull-Rom spline curve defined by an array of points
 * @explain[en] 
 * SplineCurve extends Curve, defined by a set of 2D points using CatmullRom interpolation.
 * Corresponds to Three.js extras/curves/SplineCurve.js.
 */
package three.rendering.geometry
import std.collection.*

import three.core.math.*

/**
 * @brief[zh-cn] 2D 样条曲线类
 * @explain[zh-cn] 
 * 使用示例：
 * ```
 * let curve = SplineCurve([
 * Vector2(-10.0, 0.0),
 * Vector2(-5.0, 5.0),
 * Vector2(0.0, 0.0),
 * Vector2(5.0, -5.0),
 * Vector2(10.0, 0.0)
 * ])
 * let pts = curve.getPoints(50)
 * ```
 *
 * @brief[en] 2D spline curve class
 * @explain[en] 
 * Usage example:
 * ```
 * let curve = SplineCurve([
 * Vector2(-10.0, 0.0),
 * Vector2(-5.0, 5.0),
 * Vector2(0.0, 0.0),
 * Vector2(5.0, -5.0),
 * Vector2(10.0, 0.0)
 * ])
 * let pts = curve.getPoints(50)
 * ```
 */
public class SplineCurve <: Curve {
    /**
     * @brief[zh-cn] 定义曲线的 2D 点数组（仓颉侧用 Vector3，z=0）
     *
     * @brief[en] Array of 2D points defining the curve (using Vector3 with z=0 in Cangjie)
     */
    public var points: Array<Vector3>

    /**
     * @brief[zh-cn] 构造新的 2D 样条曲线
     * @param[zh-cn] points 定义曲线的 2D 点数组，默认为空
     *
     * @brief[en] Constructs a new 2D spline curve
     * @param[en] points Array of 2D points defining the curve, default empty
     */
    public init(points!: Array<Vector3> = Array<Vector3>(0, { _ => Vector3() })) {
        super()
        this.kind = "SplineCurve"
        this.points = points
    }


    /**
     * @param[zh-cn] t 插值因子，0 到 1 之间
     * @return[zh-cn] 曲线上的点（z=0）
     *
     * 返回样条曲线上给定插值因子 t 处的点
     *
     * 使用 CatmullRom 基函数插值 x、y 分量。
     *
     * @param[en] t Interpolation factor, between 0 and 1
     * @return[en] Point on the curve (z=0)
     *
     * Return the point on the spline curve at the given interpolation factor t
     *
     * Interpolate x and y components using CatmullRom basis functions.
     */
    public override func getPoint(t: Float64): Vector3 {
        let points = this.points
        let p = Float64(points.size - 1) * t
        let intPoint = Int64(p)
        let weight = p - Float64(intPoint)
        let p0 = points[if (intPoint == 0) { intPoint } else { intPoint - 1 }]
        let p1 = points[intPoint]
        let p2 = points[if (intPoint > points.size - 2) { points.size - 1 } else { intPoint + 1 }]
        let p3 = points[if (intPoint > points.size - 3) { points.size - 1 } else { intPoint + 2 }]
        return Vector3(
            CatmullRom(weight, p0.x, p1.x, p2.x, p3.x),
            CatmullRom(weight, p0.y, p1.y, p2.y, p3.y),
            0.0
        )
    }

    public override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: SplineCurve =>
                this.points = Array<Vector3>(src.points.size, { i => src.points[i].clone() })
            case _ => ()
        }
        return this
    }

    public override func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)
        this.points = Array<Vector3>(0, { _ => Vector3() })
        if (let Some(p) <- json.get("points")) {
            match (p) {
                case arr: ArrayList<Any> =>
                    let pts = ArrayList<Vector3>()
                    for (i in 0..arr.size) {
                        match (arr[i]) {
                            case v: ArrayList<Any> => pts.add(fromArrayToVector3(v))
                            case _ => ()
                        }
                    }
                    this.points = pts.toArray()
                case _ => ()
            }
        }
        return this
    }

    private static func fromArrayToVector3(arr: ArrayList<Any>): Vector3 {
        let v = Vector3()
        var i = 0
        for (x in arr) { match (x) { case d: Float64 => match (i) { case 0 => v.x = d; case 1 => v.y = d; case 2 => v.z = d; case _ => () }; i += 1; case _ => () } }
        return v
    }
}
