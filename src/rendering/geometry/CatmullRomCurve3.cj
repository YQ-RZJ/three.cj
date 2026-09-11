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
 * @file[zh-cn] 3D Catmull-Rom 样条曲线
 * @brief[zh-cn] 由 3D 点数组定义的 Catmull-Rom 样条曲线，支持 centripetal/chordal/catmullrom 三种类型
 * @explain[zh-cn] 
 * 对应 Three.js extras/curves/CatmullRomCurve3.js。
 * curveType 接受以下值：centripetal（默认，向心参数化，避免尖点和自相交）、chordal（弦长参数化）、catmullrom（经典 Catmull-Rom，使用 tension 参数）。
 *
 * @file[en] 3D Catmull-Rom Spline Curve
 * @brief[en] 3D Catmull-Rom spline curve defined by an array of 3D points, supporting centripetal/chordal/catmullrom types
 * @explain[en] 
 * Corresponds to Three.js extras/curves/CatmullRomCurve3.js.
 * curveType accepts: centripetal (default, centripetal parameterization, avoids cusps and self-intersections), chordal (chord-length parameterization), catmullrom (classic Catmull-Rom using tension parameter).
 */
package three.rendering.geometry

import three.core.math.*
import std.math.*
import std.collection.*

/**
 * @brief[zh-cn] 三次多项式辅助类
 * @explain[zh-cn] 
 * 用于 CatmullRomCurve3 的 centripetal/chordal/catmullrom 插值计算。
 * 计算三次多项式 p(s) = c0 + c1*s + c2*s^2 + c3*s^3，
 * 使得 p(0) = x0, p(1) = x1, p'(0) = t0, p'(1) = t1。
 *
 * @brief[en] Cubic polynomial helper class
 * @explain[en] 
 * Used for centripetal/chordal/catmullrom interpolation calculations in CatmullRomCurve3.
 * Computes cubic polynomial p(s) = c0 + c1*s + c2*s^2 + c3*s^3,
 * such that p(0) = x0, p(1) = x1, p'(0) = t0, p'(1) = t1.
 */
class CubicPoly {
    /**
     * @brief[zh-cn] 多项式系数 c0
     *
     * @brief[en] Polynomial coefficient c0
     */
    private var c0: Float64 = 0.0
    /**
     * @brief[zh-cn] 多项式系数 c1
     *
     * @brief[en] Polynomial coefficient c1
     */
    private var c1: Float64 = 0.0
    /**
     * @brief[zh-cn] 多项式系数 c2
     *
     * @brief[en] Polynomial coefficient c2
     */
    private var c2: Float64 = 0.0
    /**
     * @brief[zh-cn] 多项式系数 c3
     *
     * @brief[en] Polynomial coefficient c3
     */
    private var c3: Float64 = 0.0

    public init() {}

    /**
     * @param[zh-cn] x0 起点值（s=0 处）
     * @param[zh-cn] x1 终点值（s=1 处）
     * @param[zh-cn] t0 起点切线
     * @param[zh-cn] t1 终点切线
     *
     * 使用端点和切线初始化三次多项式
     *
     * @param[en] x0 Start value (at s=0)
     * @param[en] x1 End value (at s=1)
     * @param[en] t0 Start tangent
     * @param[en] t1 End tangent
     *
     * Initialize cubic polynomial using endpoints and tangents
     */
    public func initPoly(x0: Float64, x1: Float64, t0: Float64, t1: Float64): Unit {
        this.c0 = x0
        this.c1 = t0
        this.c2 = -3.0 * x0 + 3.0 * x1 - 2.0 * t0 - t1
        this.c3 = 2.0 * x0 - 2.0 * x1 + t0 + t1
    }

    /**
     * @param[zh-cn] x0 前一控制点
     * @param[zh-cn] x1 当前段起点
     * @param[zh-cn] x2 当前段终点
     * @param[zh-cn] x3 后一控制点
     * @param[zh-cn] tension 张力参数，默认 0.5
     *
     * 使用 CatmullRom 张力参数初始化
     *
     * @param[en] x0 Previous control point
     * @param[en] x1 Current segment start point
     * @param[en] x2 Current segment end point
     * @param[en] x3 Next control point
     * @param[en] tension Tension parameter, default 0.5
     *
     * Initialize using CatmullRom tension parameter
     */
    public func initCatmullRom(x0: Float64, x1: Float64, x2: Float64, x3: Float64, tension: Float64): Unit {
        this.initPoly(x1, x2, tension * (x2 - x0), tension * (x3 - x1))
    }

    /**
     * @param[zh-cn] x0 前一控制点
     * @param[zh-cn] x1 当前段起点
     * @param[zh-cn] x2 当前段终点
     * @param[zh-cn] x3 后一控制点
     * @param[zh-cn] dt0 x0 到 x1 的弦长幂
     * @param[zh-cn] dt1 x1 到 x2 的弦长幂
     * @param[zh-cn] dt2 x2 到 x3 的弦长幂
     *
     * 使用非均匀参数化初始化（centripetal/chordal）
     *
     * @param[en] x0 Previous control point
     * @param[en] x1 Current segment start point
     * @param[en] x2 Current segment end point
     * @param[en] x3 Next control point
     * @param[en] dt0 Chord length power from x0 to x1
     * @param[en] dt1 Chord length power from x1 to x2
     * @param[en] dt2 Chord length power from x2 to x3
     *
     * Initialize using non-uniform parameterization (centripetal/chordal)
     */
    public func initNonuniformCatmullRom(x0: Float64, x1: Float64, x2: Float64, x3: Float64, dt0: Float64, dt1: Float64, dt2: Float64): Unit {
        // 计算在 [t1, t2] 参数化下的切线
        var t1 = (x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1
        var t2 = (x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2

        // 将切线重新缩放到 [0, 1] 参数化
        t1 *= dt1
        t2 *= dt1

        this.initPoly(x1, x2, t1, t2)
    }

    /**
     * @param[zh-cn] t 插值参数，0 到 1 之间
     * @return[zh-cn] 多项式计算结果
     *
     * 计算三次多项式在参数 t 处的值
     *
     * @param[en] t Interpolation parameter, between 0 and 1
     * @return[en] Polynomial calculation result
     *
     * Compute the value of the cubic polynomial at parameter t
     */
    public func calc(t: Float64): Float64 {
        let t2 = t * t
        let t3 = t2 * t
        return this.c0 + this.c1 * t + this.c2 * t2 + this.c3 * t3
    }
}

/**
 * @brief[zh-cn] 3D Catmull-Rom 样条曲线类
 * @explain[zh-cn] 
 * 具体子类重写 getPoint(t) 即可。基类提供 getPoints/getSpacedPoints/getLength/getUtoTmapping/getTangent/computeFrenetFrames 等通用算法。
 *
 * @brief[en] 3D Catmull-Rom spline curve class
 * @explain[en] 
 * Subclasses override getPoint(t). The base class provides common algorithms such as getPoints/getSpacedPoints/getLength/getUtoTmapping/getTangent/computeFrenetFrames.
 */
public open class CatmullRomCurve3 <: Curve {
    /**
     * @brief[zh-cn] 定义曲线的 3D 点数组
     *
     * @brief[en] 3D point array defining the curve
     */
    public var points: Array<Vector3>

    /**
     * @brief[zh-cn] 曲线是否闭合
     *
     * @brief[en] Whether the curve is closed
     */
    public var closed: Bool

    /**
     * @brief[zh-cn] 曲线类型：centripetal | chordal | catmullrom
     *
     * @brief[en] Curve type: centripetal | chordal | catmullrom
     */
    public var curveType: String

    /**
     * @brief[zh-cn] 曲线张力（仅在 curveType 为 catmullrom 时使用）
     *
     * @brief[en] Curve tension (only used when curveType is catmullrom)
     */
    public var tension: Float64

    /**
     * @param[zh-cn] points 定义曲线的 3D 点数组，默认为空
     * @param[zh-cn] closed 曲线是否闭合，默认为 false
     * @param[zh-cn] curveType 曲线类型，默认为 'centripetal'
     * @param[zh-cn] tension 张力参数，默认为 0.5
     *
     * 构造新的 Catmull-Rom 样条曲线
     *
     * @param[en] points Array of 3D points defining the curve, default empty
     * @param[en] closed Whether the curve is closed, default false
     * @param[en] curveType Curve type, default 'centripetal'
     * @param[en] tension Tension parameter, default 0.5
     *
     * Construct a new Catmull-Rom spline curve
     */
    public init(points!: Array<Vector3> = Array<Vector3>(0, { _ => Vector3() }), closed!: Bool = false, curveType!: String = "centripetal", tension!: Float64 = 0.5) {
        super()
        this.kind = "CatmullRomCurve3"
        this.points = points
        this.closed = closed
        this.curveType = curveType
        this.tension = tension
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
     * 根据 curveType 选择不同的插值方式：
     * - centripetal/chordal：使用非均匀 Catmull-Rom 参数化
     * - catmullrom：使用经典 Catmull-Rom（带 tension 参数）
     *
     * @param[en] t Interpolation factor, between 0 and 1
     * @return[en] Point on the curve
     *
     * Return the point on the curve at the given interpolation factor t
     *
     * Selects different interpolation methods based on curveType:
     * - centripetal/chordal: uses non-uniform Catmull-Rom parameterization
     * - catmullrom: uses classic Catmull-Rom (with tension parameter)
     */
    public override func getPoint(t: Float64): Vector3 {
        let point = Vector3()

        let points = this.points
        let l = points.size

        let p = Float64(l - (if (this.closed) { 0 } else { 1 })) * t
        var intPoint = Int64(floor(p))
        var weight = p - Float64(intPoint)

        // 闭合曲线处理
        if (this.closed) {
            if (intPoint > 0) {
                // intPoint 不变
            } else {
                intPoint = intPoint + (Int64(floor(abs(Float64(intPoint)) / Float64(l))) + 1) * Int64(l)
            }
        } else if (weight == 0.0 && intPoint == Int64(l) - 1) {
            // 边界情况：t=1 时回退到上一段
            intPoint = Int64(l) - 2
            weight = 1.0
        }

        var p0: Vector3
        var p3: Vector3

        let p1 = points[Int64(intPoint) % l]
        let p2 = points[(Int64(intPoint) + 1) % l]

        if (this.closed || intPoint > 0) {
            p0 = points[(Int64(intPoint) - 1) % l]
        } else {
            // 外推第一个点
            let tmp2 = Vector3()
            tmp2.subVectors(points[0], points[1]).add(points[0])
            p0 = tmp2
        }

        if (this.closed || Int64(intPoint) + 2 < l) {
            p3 = points[(Int64(intPoint) + 2) % l]
        } else {
            // 外推最后一个点
            let tmp = Vector3()
            tmp.subVectors(points[l - 1], points[l - 2]).add(points[l - 1])
            p3 = tmp
        }

        if (this.curveType == "centripetal" || this.curveType == "chordal") {
            // 向心/弦长 Catmull-Rom 参数化
            let power = if (this.curveType == "chordal") { 0.5 } else { 0.25 }
            var dt0 = pow(p0.distanceToSquared(p1), power)
            var dt1 = pow(p1.distanceToSquared(p2), power)
            var dt2 = pow(p2.distanceToSquared(p3), power)

            // 安全检查：重复点处理
            if (dt1 < 1e-4) { dt1 = 1.0 }
            if (dt0 < 1e-4) { dt0 = dt1 }
            if (dt2 < 1e-4) { dt2 = dt1 }

            let px = CubicPoly()
            px.initNonuniformCatmullRom(p0.x, p1.x, p2.x, p3.x, dt0, dt1, dt2)
            let py = CubicPoly()
            py.initNonuniformCatmullRom(p0.y, p1.y, p2.y, p3.y, dt0, dt1, dt2)
            let pz = CubicPoly()
            pz.initNonuniformCatmullRom(p0.z, p1.z, p2.z, p3.z, dt0, dt1, dt2)

            point.set(px.calc(weight), py.calc(weight), pz.calc(weight))
        } else if (this.curveType == "catmullrom") {
            // 经典 Catmull-Rom（带 tension 参数）
            let px = CubicPoly()
            px.initCatmullRom(p0.x, p1.x, p2.x, p3.x, this.tension)
            let py = CubicPoly()
            py.initCatmullRom(p0.y, p1.y, p2.y, p3.y, this.tension)
            let pz = CubicPoly()
            pz.initCatmullRom(p0.z, p1.z, p2.z, p3.z, this.tension)

            point.set(px.calc(weight), py.calc(weight), pz.calc(weight))
        }

        return point
    }

    /**
     * @param[zh-cn] source 要复制的源曲线
     * @return[zh-cn] 当前实例的引用
     *
     * 将给定 CatmullRomCurve3 的设置复制到此实例
     *
     * @param[en] source Source curve to copy from
     * @return[en] Reference to the current instance
     *
     * Copy the settings of the given CatmullRomCurve3 to this instance
     */
    public override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: CatmullRomCurve3 =>
                this.points = Array<Vector3>(src.points.size, { i => src.points[i].clone() })
                this.closed = src.closed
                this.curveType = src.curveType
                this.tension = src.tension
            case _ => ()
        }
        return this
    }

    /**
     * @return[zh-cn] 包含 points、closed、curveType、tension 的 HashMap
     *
     * 将 CatmullRomCurve3 序列化为 JSON
     *
     * @return[en] HashMap containing points, closed, curveType, tension
     *
     * Serialize CatmullRomCurve3 to JSON
     */
    public func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)

        this.points = Array<Vector3>(0, { _ => Vector3() })
        if (let Some(p) <- json.get("points")) {
            match (p) {
                case arr: ArrayList<Any> =>
                    let pts = ArrayList<Vector3>()
                    for (i in 0..arr.size) {
                        match (arr[i]) {
                            case v: ArrayList<Any> =>
                                let vec = Vector3()
                                var idx = 0
                                for (x in v) {
                                    match (x) {
                                        case d: Float64 =>
                                            match (idx) {
                                                case 0 => vec.x = d
                                                case 1 => vec.y = d
                                                case 2 => vec.z = d
                                                case _ => ()
                                            }
                                            idx += 1
                                        case _ => ()
                                    }
                                }
                                pts.add(vec)
                            case _ => ()
                        }
                    }
                    this.points = pts.toArray()
                case _ => ()
            }
        }

        if (let Some(v) <- json.get("closed")) {
            match (v) {
                case b: Bool => this.closed = b
                case _ => ()
            }
        }
        if (let Some(v) <- json.get("curveType")) {
            match (v) {
                case s: String => this.curveType = s
                case _ => ()
            }
        }
        if (let Some(v) <- json.get("tension")) {
            match (v) {
                case d: Float64 => this.tension = d
                case _ => ()
            }
        }

        return this
    }
}
