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
 * @file[zh-cn] 曲线基类
 * @brief[zh-cn] 曲线抽象基类，提供通用曲线算法
 * @explain[zh-cn] 
 * 此类位于 package three.rendering.geometry，用于解 core↔curves 循环依赖。
 * 外部应通过 three.extras.core.Curve 重公开导入访问。
 * 对应 Three.js extras/core/Curve.js。
 *
 * @file[en] Curve Base Class
 * @brief[en] Abstract base class for curves, providing common curve algorithms
 * @explain[en] 
 * This class is in package three.rendering.geometry to decouple core↔curves circular dependency.
 * External code should access it through three.extras.core.Curve re-export.
 * Corresponds to Three.js extras/core/Curve.js.
 */
package three.rendering.geometry

import three.core.math.*
import three.utils.log.*
import three.utils.log.macros.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 曲线抽象基类
 * @explain[zh-cn] 
 * 具体子类（LineCurve、CubicBezierCurve3、CatmullRomCurve3 等）重写 getPoint(t) 即可。
 * 基类提供 getPoints/getSpacedPoints/getLength/getUtoTmapping/getTangent/computeFrenetFrames 等通用算法。
 *
 * @brief[en] Abstract base class for curves
 * @explain[en] 
 * Concrete subclasses (LineCurve, CubicBezierCurve3, CatmullRomCurve3, etc.) override getPoint(t).
 * The base class provides common algorithms such as getPoints/getSpacedPoints/getLength/getUtoTmapping/getTangent/computeFrenetFrames.
 */
public open class Curve {
    /**
     * 几何体类型字符串，用于序列化/反序列化多态判断
     * @default "Curve"
     * @readonly
     */
    public var kind: String

    /**
     * 计算累积段长度时的分段数
     * 曲线很大时建议增大此值以确保精度（getSpacedPoints 等）
     * @default 200
     */
    public var arcLengthDivisions: Int64

    /**
     * 若曲线参数已变，必须设为 true（用于失效 cacheArcLengths）
     * @default false
     */
    public var needsUpdate: Bool

    /**
     * 持有预计算的曲线长度值的内部缓存
     * @private
     * @default null
     */
    private var cacheArcLengths: ?Array<Float64>

    /**
     * 构造新的曲线实例
     */
    public init() {
        this.kind = "Curve"
        this.arcLengthDivisions = 200
        this.needsUpdate = false
        this.cacheArcLengths = None
    }

    /**
     * @param[zh-cn] t 插值因子，0 到 1 之间
     * @return[zh-cn] 曲线上的点；具体子类重写此方法
     *
     * 返回给定插值因子 t 处的曲线点
     *
     * @param[en] t Interpolation factor, between 0 and 1
     * @return[en] Point on the curve; concrete subclasses override this method
     *
     * Return the curve point at the given interpolation factor t
     */
    public open func getPoint(t: Float64): Vector3 {
        @LogWarn(["Curve", "Warning, getPoint() not implemented!"])
        return Vector3()
    }

    /**
     * @param[zh-cn] u 0 到 1 之间的均匀弧长参数
     * @return[zh-cn] 曲线上的点
     *
     * 返回给定 u（沿曲线弧长均匀化参数）处的曲线点
     *
     * @param[en] u Uniform arc length parameter between 0 and 1
     * @return[en] Point on the curve
     *
     * Return the curve point at the given u (arc-length uniformized parameter)
     */
    public open func getPointAt(u: Float64): Vector3 {
        let t = this.getUtoTmapping(u)
        return this.getPoint(t)
    }

    /**
     * @param[zh-cn] divisions 分段数，默认为 5
     * @return[zh-cn] 点数组，长度为 divisions + 1
     *
     * 返回沿曲线均匀分布的点数组（按 t 均匀划分）
     *
     * @param[en] divisions Number of divisions, default 5
     * @return[en] Array of points, length is divisions + 1
     *
     * Return an array of evenly distributed points along the curve (uniformly divided by t)
     */
    public open func getPoints(divisions: Int64): Array<Vector3> {
        let points = ArrayList<Vector3>()
        for (i in 0..=divisions) {
            points.add(this.getPoint(Float64(i) / Float64(divisions)))
        }
        return points.toArray()
    }

    /**
     * @param[zh-cn] divisions 分段数，默认为 5
     * @return[zh-cn] 点数组，长度为 divisions + 1
     *
     * 返回沿曲线均匀弧长分布的点数组（按 u 均匀划分）
     *
     * @param[en] divisions Number of divisions, default 5
     * @return[en] Array of points, length is divisions + 1
     *
     * Return an array of evenly arc-length distributed points along the curve (uniformly divided by u)
     */
    public open func getSpacedPoints(divisions: Int64): Array<Vector3> {
        let points = ArrayList<Vector3>()
        for (i in 0..=divisions) {
            points.add(this.getPointAt(Float64(i) / Float64(divisions)))
        }
        return points.toArray()
    }

    /**
     * @return[zh-cn] 曲线总长度
     *
     * 返回曲线总长度
     *
     * @return[en] Total length of the curve
     *
     * Return the total length of the curve
     */
    public open func getLength(): Float64 {
        let lengths = this.getLengths(this.arcLengthDivisions)
        return lengths[lengths.size - 1]
    }

    /**
     * @param[zh-cn] divisions 分段数，默认为 this.arcLengthDivisions
     * @return[zh-cn] 长度为 divisions + 1 的累积长度数组
     *
     * 返回累积段长度数组
     *
     * @param[en] divisions Number of divisions, default this.arcLengthDivisions
     * @return[en] Cumulative length array of length divisions + 1
     *
     * Return the cumulative segment length array
     */
    public open func getLengths(divisions: Int64): Array<Float64> {
        if (let Some(cache) <- this.cacheArcLengths) {
            if (cache.size == divisions + 1 && !this.needsUpdate) {
                return cache
            }
        }
        let lengths = ArrayList<Float64>()
        lengths.add(0.0)
        var sum = 0.0
        for (i in 1..=divisions) {
            let t1 = Float64(i) / Float64(divisions)
            let t0 = Float64(i - 1) / Float64(divisions)
            let p1 = this.getPoint(t1)
            let p0 = this.getPoint(t0)
            sum += p1.distanceTo(p0)
            lengths.add(sum)
        }
        this.cacheArcLengths = Some(lengths.toArray())
        this.needsUpdate = false
        return this.cacheArcLengths.getOrThrow()
    }

    /**
     * 标记 cacheArcLengths 失效并立即重新计算
     */
    public open func updateArcLengths(): Unit {
        this.needsUpdate = true
        this.getLengths(this.arcLengthDivisions)
    }

    /**
     * @param[zh-cn] u 0 到 1 之间的均匀弧长参数
     * @param[zh-cn] distance 可选的目标距离值；不传则用 u * 总弧长
     * @return[zh-cn] 对应的曲线参数 t
     *
     * 将弧长均匀参数 u 映射到曲线参数 t（二分搜索精确实现）
     *
     * @param[en] u Uniform arc length parameter between 0 and 1
     * @param[en] distance Optional target distance value; if not provided, uses u * total arc length
     * @return[en] Corresponding curve parameter t
     *
     * Map the arc-length uniform parameter u to the curve parameter t (binary search implementation)
     */
    public func getUtoTmapping(u: Float64, distance!: ?Float64 = None): Float64 {
        let arcLengths = this.getLengths(this.arcLengthDivisions)
        let il = arcLengths.size
        var targetArcLength: Float64
        if (let Some(d) <- distance) {
            targetArcLength = d
        } else {
            targetArcLength = u * arcLengths[il - 1]
        }
        // 二分搜索：找到小于目标的最大索引
        var low = 0
        var high = il - 1
        var i = 0
        var comparison: Float64
        while (low <= high) {
            i = low + (high - low) / 2
            comparison = arcLengths[i] - targetArcLength
            if (comparison < 0.0) {
                low = i + 1
            } else if (comparison > 0.0) {
                high = i - 1
            } else {
                high = i
                break
            }
        }
        i = high
        if (arcLengths[i] == targetArcLength) {
            return Float64(i) / Float64(il - 1)
        }
        let lengthBefore = arcLengths[i]
        let lengthAfter = arcLengths[i + 1]
        let segmentLength = lengthAfter - lengthBefore
        let segmentFraction = (targetArcLength - lengthBefore) / segmentLength
        let t = (Float64(i) + segmentFraction) / Float64(il - 1)
        return t
    }

    /**
     * @param[zh-cn] t 插值因子
     * @return[zh-cn] 归一化切线向量
     *
     * 返回给定 t 处的曲线切线向量（已归一化）
     *
     * 通过求 t 附近两点差分计算切线。
     *
     * @param[en] t Interpolation factor
     * @return[en] Normalized tangent vector
     *
     * Return the curve tangent vector at the given t (normalized)
     *
     * Compute the tangent by finite difference of two points near t.
     */
    public open func getTangent(t: Float64): Vector3 {
        let delta = 0.0001
        var t1 = t - delta
        var t2 = t + delta
        // 危险值钳制
        if (t1 < 0.0) { t1 = 0.0 }
        if (t2 > 1.0) { t2 = 1.0 }
        let pt1 = this.getPoint(t1)
        let pt2 = this.getPoint(t2)
        let tangent = Vector3()
        tangent.copy(pt2).sub(pt1).normalize()
        return tangent
    }

    /**
     * @param[zh-cn] u 0 到 1 之间的均匀弧长参数
     * @return[zh-cn] 归一化切线向量
     *
     * 返回给定 u（弧长均匀参数）处的曲线切线向量
     *
     * @param[en] u Uniform arc length parameter between 0 and 1
     * @return[en] Normalized tangent vector
     *
     * Return the curve tangent vector at the given u (arc-length uniform parameter)
     */
    public open func getTangentAt(u: Float64): Vector3 {
        let t = this.getUtoTmapping(u)
        return this.getTangent(t)
    }

    /**
     * @param[zh-cn] segments 分段数
     * @param[zh-cn] closed 曲线是否闭合，默认为 false
     * @return[zh-cn] 包含 tangents/normals/binormals 三个数组的元组
     *
     * 计算曲线的 Frenet 标架（切线、法线、副法线）数组
     *
     * 用于管状几何体（TubeGeometry）等沿曲线生成网格。
     * 详见 http://www.cs.indiana.edu/pub/techreports/TR425.pdf
     *
     * @param[en] segments Number of segments
     * @param[en] closed Whether the curve is closed, default false
     * @return[en] Tuple containing three arrays: tangents, normals, and binormals
     *
     * Compute the Frenet frames (tangent, normal, binormal) arrays of the curve
     *
     * Used for tubular geometries (TubeGeometry) etc. to generate meshes along the curve.
     * See http://www.cs.indiana.edu/pub/techreports/TR425.pdf
     */
    public func computeFrenetFrames(segments: Int64, closed!: Bool = false): (Array<Vector3>, Array<Vector3>, Array<Vector3>) {
        let normal = Vector3()
        let tangents = ArrayList<Vector3>()
        let normals = ArrayList<Vector3>()
        let binormals = ArrayList<Vector3>()
        let vec = Vector3()
        let mat = Matrix4()
        // 计算每个分段处的切线向量
        for (i in 0..=segments) {
            let u = Float64(i) / Float64(segments)
            tangents.add(this.getTangentAt(u))
        }
        // 选择初始法线向量：与第一个切线正交，且取切线最小 xyz 分量的方向
        normals.add(Vector3())
        binormals.add(Vector3())
        var min = Float64.Max
        let tx = abs(tangents[0].x)
        let ty = abs(tangents[0].y)
        let tz = abs(tangents[0].z)
        if (tx <= min) {
            min = tx
            normal.set(1.0, 0.0, 0.0)
        }
        if (ty <= min) {
            min = ty
            normal.set(0.0, 1.0, 0.0)
        }
        if (tz <= min) {
            normal.set(0.0, 0.0, 1.0)
        }
        vec.crossVectors(tangents[0], normal).normalize()
        normals[0].crossVectors(tangents[0], vec)
        binormals[0].crossVectors(tangents[0], normals[0])
        // 计算每个分段处缓慢变化的法线与副法线
        for (i in 1..=segments) {
            normals.add(normals[i - 1].clone())
            binormals.add(binormals[i - 1].clone())
            vec.crossVectors(tangents[i - 1], tangents[i])
            if (vec.length() > 2.220446049250313e-16) { // Float64.Epsilon
                vec.normalize()
                let theta = acos(clamp(tangents[i - 1].dot(tangents[i]), -1.0, 1.0))
                normals[i].applyMatrix4(mat.makeRotationAxis(vec, theta))
            }
            binormals[i].crossVectors(tangents[i], normals[i])
        }
        // 闭合曲线后处理：使首末法线相同
        if (closed) {
            var theta = acos(clamp(normals[0].dot(normals[segments]), -1.0, 1.0))
            theta /= Float64(segments)
            if (tangents[0].dot(vec.crossVectors(normals[0], normals[segments])) > 0.0) {
                theta = -theta
            }
            for (i in 1..=segments) {
                normals[i].applyMatrix4(mat.makeRotationAxis(tangents[i], theta * Float64(i)))
                binormals[i].crossVectors(tangents[i], normals[i])
            }
        }
        return (tangents.toArray(), normals.toArray(), binormals.toArray())
    }

    /**
     * @return[zh-cn] 此实例的克隆
     *
     * 返回从此实例复制值的新曲线
     *
     * @return[en] Clone of this instance
     *
     * Return a new curve with values copied from this instance
     */
    public func clone(): Curve {
        let c = Curve()
        return c.copy(this)
    }

    /**
     * @param[zh-cn] source 要复制的曲线
     * @return[zh-cn] 当前实例的引用
     *
     * 将给定曲线的设置复制到此实例
     *
     * @param[en] source Curve to copy from
     * @return[en] Reference to the current instance
     *
     * Copy the settings of the given curve to this instance
     */
    public open func copy(source: Curve): Curve {
        this.arcLengthDivisions = source.arcLengthDivisions
        return this
    }

    /**
     * @param[zh-cn] json 包含 type、arcLengthDivisions 的 HashMap
     * @return[zh-cn] 当前实例的引用
     *
     * 从 JSON 反序列化曲线
     *
     * @param[en] json HashMap containing type and arcLengthDivisions
     * @return[en] Reference to the current instance
     *
     * Deserialize the curve from JSON
     */
    public open func fromJSON(json: HashMap<String, Any>): Curve {
        if (let Some(t) <- json.get("type")) {
            match (t) {
                case s: String => this.kind = s
                case _ => ()
            }
        }
        if (let Some(d) <- json.get("arcLengthDivisions")) {
            match (d) {
                case i: Int64 => this.arcLengthDivisions = i
                case _ => ()
            }
        }
        return this
    }
}
