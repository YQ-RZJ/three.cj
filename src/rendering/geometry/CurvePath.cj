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
 * @file[zh-cn] 曲线路径
 * @brief[zh-cn] 由多条曲线串联而成的复合路径
 * @explain[zh-cn] 
 * CurvePath 继承 Curve，持有一组有序的子曲线；
 * 重写 getPoint/getLength/getCurveLengths 以支持跨子曲线插值。
 *
 * @file[en] Curve Path
 * @brief[en] Composite path composed of multiple curves connected in sequence
 * @explain[en] 
 * CurvePath extends Curve, holding an ordered set of sub-curves;
 * overrides getPoint/getLength/getCurveLengths to support cross-curve interpolation.
 */
package three.rendering.geometry

import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 曲线路径类，由多条曲线串联而成的复合路径
 * @explain[zh-cn] 
 * 使用示例：
 * ```
 * let path = CurvePath()
 * path.add(LineCurve(Vector3(0.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0)))
 * path.add(LineCurve(Vector3(1.0, 0.0, 0.0), Vector3(1.0, 1.0, 0.0)))
 * let pts = path.getPoints(12)
 * ```
 *
 * @brief[en] Curve path class, a composite path of multiple curves connected in sequence
 * @explain[en] 
 * Usage example:
 * ```
 * let path = CurvePath()
 * path.add(LineCurve(Vector3(0.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0)))
 * path.add(LineCurve(Vector3(1.0, 0.0, 0.0), Vector3(1.0, 1.0, 0.0)))
 * let pts = path.getPoints(12)
 * ```
 */
public open class CurvePath <: Curve {
    /**
     * 持有此路径的所有子曲线
     * @type {Array<Curve>}
     */
    public var curves: ArrayList<Curve>

    /**
     * 是否自动用一条 LineCurve 闭合此路径
     * @default false
     */
    public var autoClose: Bool

    /**
     * 缓存的子曲线累积长度数组
     * @private
     * @default null
     */
    private var cacheLengths: ?Array<Float64>

    /**
     * 构造新的曲线路径
     */
    public init() {
        super()
        this.kind = "CurvePath"
        this.curves = ArrayList<Curve>()
        this.autoClose = false
        this.cacheLengths = None
    }

    /**
     * @param[zh-cn] curve 要添加的子曲线
     *
     * 向此曲线路径添加一条子曲线
     *
     * @param[en] curve Sub-curve to add
     *
     * Add a sub-curve to this curve path
     */
    public func add(curve: Curve): Unit {
        this.curves.add(curve)
    }

    /**
     * @return[zh-cn] 当前实例的引用
     *
     * 添加一条 LineCurve 闭合此路径
     *
     * 仅当首末点不重合时才添加。
     *
     * @return[en] Reference to the current instance
     *
     * Add a LineCurve to close this path
     *
     * Only added when the start and end points do not coincide.
     */
    public func closePath(): CurvePath {
        // 首末点不重合时添加 LineCurve 闭合
        let startPoint = this.curves[0].getPoint(0.0)
        let endPoint = this.curves[this.curves.size - 1].getPoint(1.0)
        if (!startPoint.equals(endPoint)) {
            // JS 用 startPoint.isVector2 判断走 LineCurve / LineCurve3；
            // 仓颉侧用具体 Vector3 一致走 LineCurve（Path 在 3D 坐标 z=0）。
            this.curves.add(LineCurve(v1: endPoint, v2: startPoint))
        }
        return this
    }

    /**
     * @param[zh-cn] t 插值因子，0 到 1 之间
     * @return[zh-cn] 曲线路径上的点；超出范围返回空向量
     *
     * 返回给定插值因子 t 处的曲线点（沿整条路径）
     *
     * 算法：t * 总长 → 子曲线累积长度定位 → 子曲线参数 u → 子曲线 getPointAt(u)
     *
     * @param[en] t Interpolation factor, between 0 and 1
     * @return[en] Point on the curve path; returns zero vector if out of range
     *
     * Return the curve point at the given interpolation factor t (along the entire path)
     *
     * Algorithm: t * total length → locate via sub-curve cumulative lengths → sub-curve parameter u → sub-curve getPointAt(u)
     */
    public override func getPoint(t: Float64): Vector3 {
        // 为得到相对于整条路径距离的精确点，需：
        // 1. 知道每条子路径长度
        // 2. 定位并识别曲线类型
        // 3. 求该子曲线的 t'
        // 4. 返回 curve.getPointAt(t')
        let d = t * this.getLength()
        let curveLengths = this.getCurveLengths()
        var i = 0
        // 边界点需仔细思考
        while (i < curveLengths.size) {
            if (curveLengths[i] >= d) {
                let diff = curveLengths[i] - d
                let curve = this.curves[i]
                let segmentLength = curve.getLength()
                let u = if (segmentLength == 0.0) { 0.0 } else { 1.0 - diff / segmentLength }
                return curve.getPointAt(u)
            }
            i += 1
        }
        return Vector3()
        // loop where sum != 0, sum > d , sum+1 <d
    }

    /**
     * @return[zh-cn] 曲线路径总长度
     *
     * 返回曲线路径总长度
     *
     * 重写 Curve.getLength：因 Curve.getLength 依赖 getPoint，
     * 而 CurvePath.getPoint 又依赖 getLength，故改用 getCurveLengths 的末值。
     *
     * @return[en] Total length of the curve path
     *
     * Return the total length of the curve path
     *
     * Override Curve.getLength: because Curve.getLength depends on getPoint,
     * and CurvePath.getPoint depends on getLength, so use the last value of getCurveLengths instead.
     */
    public override func getLength(): Float64 {
        let lens = this.getCurveLengths()
        return lens[lens.size - 1]
    }

    /**
     * 标记 cacheLengths 失效并立即重新计算
     */
    public func updateArcLengths(): Unit {
        // cacheLengths 必须重算
        this.needsUpdate = true
        this.cacheLengths = None
        this.getCurveLengths()
    }

    /**
     * @return[zh-cn] 子曲线累积长度数组
     *
     * 返回所有子曲线的累积长度数组
     *
     * 不能重写 getLengths()：UtoT 映射使用它。此处用 cacheLengths 缓存。
     *
     * @return[en] Array of sub-curve cumulative lengths
     *
     * Return the cumulative length array of all sub-curves
     *
     * Cannot override getLengths(): UtoT mapping uses it. Uses cacheLengths for caching here.
     */
    public func getCurveLengths(): Array<Float64> {
        // 计算并缓存长度
        // 不能覆盖 getLengths()：UtoT 映射使用它
        // 若子曲线数量与缓存数组长度一致则用缓存
        if (let Some(cache) <- this.cacheLengths) {
            if (cache.size == this.curves.size) {
                return cache
            }
        }
        // 求每条子曲线长度，累积入缓存数组
        let lengths = ArrayList<Float64>()
        var sums = 0.0
        for (i in 0..this.curves.size) {
            sums += this.curves[i].getLength()
            lengths.add(sums)
        }
        this.cacheLengths = Some(lengths.toArray())
        return this.cacheLengths.getOrThrow()
    }

    /**
     * @param[zh-cn] divisions 分段数，默认为 40
     * @return[zh-cn] 点数组，长度为 divisions + 1（autoClose 为真时末尾重复首点）
     *
     * 返回沿曲线路径均匀弧长分布的点数组
     *
     * @param[en] divisions Number of divisions, default 40
     * @return[en] Array of points, length is divisions + 1 (when autoClose is true, the first point is repeated at the end)
     *
     * Return an array of evenly arc-length distributed points along the curve path
     */
    public override func getSpacedPoints(divisions: Int64): Array<Vector3> {
        let points = ArrayList<Vector3>()
        for (i in 0..=divisions) {
            points.add(this.getPoint(Float64(i) / Float64(divisions)))
        }
        if (this.autoClose) {
            points.add(points[0])
        }
        return points.toArray()
    }

    /**
     * @param[zh-cn] divisions 分段数，默认为 12
     * @return[zh-cn] 点数组
     *
     * 返回沿曲线路径均匀 t 划分的点数组（去重相邻重复点）
     *
     * 子曲线类型决定其 resolution：EllipseCurve 用 divisions*2，
     * LineCurve/LineCurve3 用 1，SplineCurve 用 divisions*点数，其他用 divisions。
     *
     * @param[en] divisions Number of divisions, default 12
     * @return[en] Array of points
     *
     * Return an array of points along the curve path evenly divided by t (with adjacent duplicate points removed)
     *
     * The sub-curve type determines its resolution: EllipseCurve uses divisions*2,
     * LineCurve/LineCurve3 uses 1, SplineCurve uses divisions*point count, others use divisions.
     */
    public override func getPoints(divisions: Int64): Array<Vector3> {
        let points = ArrayList<Vector3>()
        var last: ?Vector3 = None
        for (i in 0..this.curves.size) {
            let curve = this.curves[i]
            let resolution = if (curve.kind == "EllipseCurve") {
                divisions * 2
            } else if (curve.kind == "LineCurve" || curve.kind == "LineCurve3") {
                1
            } else if (curve.kind == "SplineCurve") {
                
                match (curve) {
                    case sc: SplineCurve => divisions * Int64(sc.points.size)
                    case _ => divisions
                }
            } else {
                divisions
            }
            let pts = curve.getPoints(resolution)
            for (j in 0..pts.size) {
                let point = pts[j]
                // 确保不出现连续重复点
                if (let Some(lp) <- last) {
                    if (lp.equals(point)) {
                        continue
                    }
                }
                points.add(point)
                last = Some(point)
            }
        }
        if (this.autoClose && points.size > 1 && !points[points.size - 1].equals(points[0])) {
            points.add(points[0])
        }
        return points.toArray()
    }

    /**
     * @param[zh-cn] source 要复制的曲线路径
     * @return[zh-cn] 当前实例的引用
     *
     * 将给定曲线路径的设置复制到此实例
     *
     * @param[en] source Curve path to copy from
     * @return[en] Reference to the current instance
     *
     * Copy the settings of the given curve path to this instance
     */
    public open override func copy(source: Curve): Curve {
        super.copy(source)
        match (source) {
            case src: CurvePath =>
                this.curves = ArrayList<Curve>()
                for (i in 0..src.curves.size) {
                    this.curves.add(src.curves[i].clone())
                }
                this.autoClose = src.autoClose
            case _ => ()
        }
        return this
    }

    /**
     * @return[zh-cn] 包含 autoClose 与 curves 数组的 HashMap
     *
     * 将曲线路径序列化为 JSON
     *
     * @return[en] HashMap containing autoClose and curves array
     *
     * Serialize the curve path to JSON
     */
    public open override func fromJSON(json: HashMap<String, Any>): Curve {
        super.fromJSON(json)
        if (let Some(ac) <- json.get("autoClose")) {
            match (ac) {
                case b: Bool => this.autoClose = b
                case _ => ()
            }
        }
        this.curves = ArrayList<Curve>()
        if (let Some(c) <- json.get("curves")) {
            match (c) {
                case arr: ArrayList<Any> =>
                    for (i in 0..arr.size) {
                        
                        match (arr[i]) {
                            case curveJson: HashMap<String, Any> =>
                                var curve: Curve = LineCurve()
                                if (let Some(t) <- curveJson.get("type")) {
                                    match (t) {
                                        case s: String =>
                                            match (s) {
                                                case "LineCurve" => curve = LineCurve()
                                                case "LineCurve3" => curve = LineCurve3()
                                                case "CubicBezierCurve" => curve = CubicBezierCurve()
                                                case "CubicBezierCurve3" => curve = CubicBezierCurve3()
                                                case "QuadraticBezierCurve" => curve = QuadraticBezierCurve()
                                                case "QuadraticBezierCurve3" => curve = QuadraticBezierCurve3()
                                                case "SplineCurve" => curve = SplineCurve()
                                                case "ArcCurve" => curve = ArcCurve()
                                                case "EllipseCurve" => curve = EllipseCurve()
                                                case "CatmullRomCurve3" => curve = CatmullRomCurve3()
                                                case _ => curve = LineCurve()
                                            }
                                        case _ => ()
                                    }
                                }
                                curve.fromJSON(curveJson)
                                this.curves.add(curve)
                            case _ => ()
                        }
                    }
                case _ => ()
            }
        }
        return this
    }
}
