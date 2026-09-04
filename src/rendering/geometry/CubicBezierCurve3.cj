/**
 * @file[zh-cn] 3D 三次贝塞尔曲线
 * @brief[zh-cn] 4 个控制点定义的 3D 三次贝塞尔曲线
 * @explain[zh-cn] 
 * 对应 Three.js extras/curves/CubicBezierCurve3.js。
 *
 * @file[en] 3D Cubic Bezier Curve
 * @brief[en] 3D cubic Bezier curve defined by 4 control points
 * @explain[en] 
 * Corresponds to Three.js extras/curves/CubicBezierCurve3.js.
 */
package three.rendering.geometry

import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 3D 三次贝塞尔曲线类
 * @explain[zh-cn] 
 * 使用 CubicBezier 基函数插值 x、y、z 分量。
 *
 * @brief[en] 3D cubic Bezier curve class
 * @explain[en] 
 * Interpolates x, y, z components using CubicBezier basis functions.
 */
public class CubicBezierCurve3 <: Curve {
    /**
     * 起始点
     */
    public var v0: Vector3

    /**
     * 第一个控制点
     */
    public var v1: Vector3

    /**
     * 第二个控制点
     */
    public var v2: Vector3

    /**
     * 终止点
     */
    public var v3: Vector3

    /**
     * @param[zh-cn] v0 起始点，默认为空向量
     * @param[zh-cn] v1 第一个控制点，默认为空向量
     * @param[zh-cn] v2 第二个控制点，默认为空向量
     * @param[zh-cn] v3 终止点，默认为空向量
     *
     * 构造新的 3D 三次贝塞尔曲线
     *
     * @param[en] v0 Start point, default zero vector
     * @param[en] v1 First control point, default zero vector
     * @param[en] v2 Second control point, default zero vector
     * @param[en] v3 End point, default zero vector
     *
     * Construct a new 3D cubic Bezier curve
     */
    public init(v0!: Vector3 = Vector3(), v1!: Vector3 = Vector3(), v2!: Vector3 = Vector3(), v3!: Vector3 = Vector3()) {
        super()
        this.kind = "CubicBezierCurve3"
        this.v0 = v0
        this.v1 = v1
        this.v2 = v2
        this.v3 = v3
    }

    /**
     * 兼容重载：4 参数形式
     */

    /**
     * @param[zh-cn] t 插值因子，0 到 1 之间
     * @return[zh-cn] 曲线上的点
     *
     * 返回曲线上给定插值因子 t 处的点
     *
     * 用三次贝塞尔基函数分别插值 x、y、z 分量。
     *
     * @param[en] t Interpolation factor, between 0 and 1
     * @return[en] Point on the curve
     *
     * Return the point on the curve at the given interpolation factor t
     *
     * Interpolate x, y, z components using cubic Bezier basis functions respectively.
     */
    public override func getPoint(t: Float64): Vector3 {
        let v0 = this.v0
        let v1 = this.v1
        let v2 = this.v2
        let v3 = this.v3
        return Vector3(
            CubicBezier(t, v0.x, v1.x, v2.x, v3.x),
            CubicBezier(t, v0.y, v1.y, v2.y, v3.y),
            CubicBezier(t, v0.z, v1.z, v2.z, v3.z)
        )
    }

    /**
     * @param[zh-cn] source 要复制的源曲线
     * @return[zh-cn] 当前实例的引用
     *
     * 将给定 3D 三次贝塞尔曲线的设置复制到此实例
     *
     * @param[en] source Source curve to copy from
     * @return[en] Reference to the current instance
     *
     * Copy the settings of the given 3D cubic Bezier curve to this instance
     */
    public override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: CubicBezierCurve3 =>
                this.v0.copy(src.v0)
                this.v1.copy(src.v1)
                this.v2.copy(src.v2)
                this.v3.copy(src.v3)
            case _ => ()
        }
        return this
    }

    /**
     * @return[zh-cn] 包含 v0、v1、v2、v3 数组的 HashMap
     *
     * 将 3D 三次贝塞尔曲线序列化为 JSON
     *
     * @return[en] HashMap containing v0, v1, v2, v3 arrays
     *
     * Serialize the 3D cubic Bezier curve to JSON
     */
    /**
     * @param[zh-cn] json 包含 v0、v1、v2、v3 数组的 HashMap
     * @return[zh-cn] 当前实例的引用
     *
     * 从 JSON 反序列化 3D 三次贝塞尔曲线
     *
     * @param[en] json HashMap containing v0, v1, v2, v3 arrays
     * @return[en] Reference to the current instance
     *
     * Deserialize the 3D cubic Bezier curve from JSON
     */
    public override func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)
        if (let Some(v) <- json.get("v0")) { match (v) { case arr: ArrayList<Any> => this.v0 = fromArrayToVector3(arr); case _ => () } }
        if (let Some(v) <- json.get("v1")) { match (v) { case arr: ArrayList<Any> => this.v1 = fromArrayToVector3(arr); case _ => () } }
        if (let Some(v) <- json.get("v2")) { match (v) { case arr: ArrayList<Any> => this.v2 = fromArrayToVector3(arr); case _ => () } }
        if (let Some(v) <- json.get("v3")) { match (v) { case arr: ArrayList<Any> => this.v3 = fromArrayToVector3(arr); case _ => () } }
        return this
    }

    private static func fromArrayToVector3(arr: ArrayList<Any>): Vector3 {
        let v = Vector3()
        var i = 0
        for (x in arr) { match (x) { case d: Float64 => match (i) { case 0 => v.x = d; case 1 => v.y = d; case 2 => v.z = d; case _ => () }; i += 1; case _ => () } }
        return v
    }
}
