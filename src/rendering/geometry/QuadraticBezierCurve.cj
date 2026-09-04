/**
 * @file[zh-cn] 2D 二次贝塞尔曲线
 * @brief[zh-cn] 3 个控制点定义的 2D 二次贝塞尔曲线
 * @explain[zh-cn] 
 * QuadraticBezierCurve 继承 Curve，由 v0（起始点）、v1（控制点）、v2（终止点）定义。
 * 对应 Three.js extras/curves/QuadraticBezierCurve.js。
 *
 * @file[en] 2D Quadratic Bezier Curve
 * @brief[en] 2D quadratic Bezier curve defined by 3 control points
 * @explain[en] 
 * QuadraticBezierCurve extends Curve, defined by v0 (start point), v1 (control point), v2 (end point).
 * Corresponds to Three.js extras/curves/QuadraticBezierCurve.js.
 */
package three.rendering.geometry

import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 2D 二次贝塞尔曲线类
 * @explain[zh-cn] 
 * 使用示例：
 * ```
 * let curve = QuadraticBezierCurve(Vector3(-10.0, 0.0, 0.0), Vector3(20.0, 15.0, 0.0),
 * Vector3(10.0, 0.0, 0.0))
 * let pts = curve.getPoints(50)
 * ```
 *
 * @brief[en] 2D quadratic Bezier curve class
 * @explain[en] 
 * Usage example:
 * ```
 * let curve = QuadraticBezierCurve(Vector3(-10.0, 0.0, 0.0), Vector3(20.0, 15.0, 0.0),
 * Vector3(10.0, 0.0, 0.0))
 * let pts = curve.getPoints(50)
 * ```
 */
public class QuadraticBezierCurve <: Curve {
    /**
     * @brief[zh-cn] 起始点
     *
     * @brief[en] Start point
     */
    public var v0: Vector3

    /**
     * @brief[zh-cn] 控制点
     *
     * @brief[en] Control point
     */
    public var v1: Vector3

    /**
     * @brief[zh-cn] 终止点
     *
     * @brief[en] End point
     */
    public var v2: Vector3

    /**
     * @param[zh-cn] v0 起始点，默认为空向量
     * @param[zh-cn] v1 控制点，默认为空向量
     * @param[zh-cn] v2 终止点，默认为空向量
     *
     * 构造新的 2D 二次贝塞尔曲线
     *
     * @param[en] v0 Start point, default zero vector
     * @param[en] v1 Control point, default zero vector
     * @param[en] v2 End point, default zero vector
     *
     * Construct a new 2D quadratic Bezier curve
     */
    public init(v0!: Vector3 = Vector3(), v1!: Vector3 = Vector3(), v2!: Vector3 = Vector3()) {
        super()
        this.kind = "QuadraticBezierCurve"
        this.v0 = v0
        this.v1 = v1
        this.v2 = v2
    }

    /**
     * 兼容重载：3 参数形式
     */

    /**
     * @param[zh-cn] t 插值因子，0 到 1 之间
     * @return[zh-cn] 曲线上的点（z=0）
     *
     * 返回曲线上给定插值因子 t 处的点
     *
     * 用二次贝塞尔基函数分别插值 x、y 分量。
     *
     * @param[en] t Interpolation factor, between 0 and 1
     * @return[en] Point on the curve (z=0)
     *
     * Return the point on the curve at the given interpolation factor t
     *
     * Interpolate x and y components using quadratic Bezier basis functions respectively.
     */
    public override func getPoint(t: Float64): Vector3 {
        let v0 = this.v0
        let v1 = this.v1
        let v2 = this.v2
        return Vector3(
            QuadraticBezier(t, v0.x, v1.x, v2.x),
            QuadraticBezier(t, v0.y, v1.y, v2.y),
            0.0
        )
    }

    /**
     * @param[zh-cn] source 要复制的源曲线
     * @return[zh-cn] 当前实例的引用
     *
     * 将给定二次贝塞尔曲线的设置复制到此实例
     *
     * @param[en] source Source curve to copy from
     * @return[en] Reference to the current instance
     *
     * Copy the settings of the given quadratic Bezier curve to this instance
     */
    public override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: QuadraticBezierCurve =>
                this.v0.copy(src.v0)
                this.v1.copy(src.v1)
                this.v2.copy(src.v2)
            case _ => ()
        }
        return this
    }

    /**
     * @return[zh-cn] 包含 v0、v1、v2 数组的 HashMap
     *
     * 将二次贝塞尔曲线序列化为 JSON
     *
     * @return[en] HashMap containing v0, v1, v2 arrays
     *
     * Serialize the quadratic Bezier curve to JSON
     */
    /**
     * @param[zh-cn] json 包含 v0、v1、v2 数组的 HashMap
     * @return[zh-cn] 当前实例的引用
     *
     * 从 JSON 反序列化二次贝塞尔曲线
     *
     * @param[en] json HashMap containing v0, v1, v2 arrays
     * @return[en] Reference to the current instance
     *
     * Deserialize the quadratic Bezier curve from JSON
     */
    public override func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)
        if (let Some(v) <- json.get("v0")) { match (v) { case arr: ArrayList<Any> => this.v0 = fromArrayToVector3(arr); case _ => () } }
        if (let Some(v) <- json.get("v1")) { match (v) { case arr: ArrayList<Any> => this.v1 = fromArrayToVector3(arr); case _ => () } }
        if (let Some(v) <- json.get("v2")) { match (v) { case arr: ArrayList<Any> => this.v2 = fromArrayToVector3(arr); case _ => () } }
        return this
    }

    private static func fromArrayToVector3(arr: ArrayList<Any>): Vector3 {
        let v = Vector3()
        var i = 0
        for (x in arr) { match (x) { case d: Float64 => match (i) { case 0 => v.x = d; case 1 => v.y = d; case 2 => v.z = d; case _ => () }; i += 1; case _ => () } }
        return v
    }
}
