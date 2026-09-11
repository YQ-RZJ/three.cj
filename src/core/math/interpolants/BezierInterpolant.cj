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
 * @file[zh-cn] BezierInterpolant
 * @brief[zh-cn] 贝塞尔插值器
 * @explain[zh-cn] 使用三次贝塞尔曲线和 2D 控制点进行插值，继承自 Interpolant。
 *
 * @file[en] BezierInterpolant
 * @brief[en] Bezier interpolant
 * @explain[en] Interpolates using cubic Bezier curves with 2D control points, extending Interpolant.
 */
package three.core.math.interpolants

import three.core.math.Interpolant
import std.math.*

/**
 * @brief[zh-cn] 贝塞尔插值器，使用三次贝塞尔曲线和 2D 控制点
 *
 * @brief[en] Bezier interpolant using cubic Bezier curves with 2D control points
 *
 * @augments Interpolant
 */
public class BezierInterpolant <: Interpolant {
    /**
     * @brief[zh-cn] 入切线数据
     *
     * @brief[en] In-tangents data
     */
    public var inTangents: Option<Array<Float64>>
    /**
     * @brief[zh-cn] 出切线数据
     *
     * @brief[en] Out-tangents data
     */
    public var outTangents: Option<Array<Float64>>

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] parameterPositions 参数位置数组
     * sampleValues 采样值数组
     * sampleSize 采样大小
     * resultBuffer 结果缓冲区
     *
     * @brief[en] Constructor
     * @param[en] parameterPositions Parameter positions array
     * sampleValues Sample values array
     * sampleSize Sample size
     * resultBuffer Result buffer
     */
    public init(parameterPositions: Array<Float64>, sampleValues: Array<Float64>, sampleSize: Int64, resultBuffer: Option<Array<Float64>>) {
        super(parameterPositions, sampleValues, sampleSize, resultBuffer)
        this.inTangents = None
        this.outTangents = None
    }

    /**
     * @brief[zh-cn] 贝塞尔插值计算
     * @param[zh-cn] i1 右侧关键帧索引
     * t0 左侧时间
     * t 当前插值时间
     * t1 右侧时间
     * @return[zh-cn] 插值结果数组
     *
     * @brief[en] Bezier interpolation calculation
     * @param[en] i1 Right keyframe index
     * t0 Left time
     * t Current interpolation time
     * t1 Right time
     * @return[en] Interpolated result array
     */
    public override func interpolate_(i1: Int64, t0: Float64, t: Float64, t1: Float64): Array<Float64> {
        let result = this.resultBuffer
        let values = this.sampleValues
        let stride = this.valueSize

        let offset1 = i1 * stride
        let offset0 = offset1 - stride

        let inTangents = this.inTangents
        let outTangents = this.outTangents

        // 如果没有切线数据，回退到线性插值
        if (inTangents == None || outTangents == None) {
            let weight1 = (t - t0) / (t1 - t0)
            let weight0 = 1.0 - weight1
            for (i in 0..stride) {
                result[i] = values[offset0 + i] * weight0 + values[offset1 + i] * weight1
            }
            return result
        }

        // 使用 unwrap
        let inT = inTangents.getOrThrow()
        let outT = outTangents.getOrThrow()

        let tangentStride = stride * 2
        let i0 = i1 - 1

        for (i in 0..stride) {
            let v0 = values[offset0 + i]
            let v1 = values[offset1 + i]

            // outTangent of previous keyframe (C0)
            let outTangentOffset = i0 * tangentStride + i * 2
            let c0x = outT[outTangentOffset]
            let c0y = outT[outTangentOffset + 1]

            // inTangent of current keyframe (C1)
            let inTangentOffset = i1 * tangentStride + i * 2
            let c1x = inT[inTangentOffset]
            let c1y = inT[inTangentOffset + 1]

            // Find the curve parameter s where the Bezier X(s) matches t, then evaluate Y(s)
            let s = solveBezierParameter(t, t0, c0x, c1x, t1)
            result[i] = cubicBezier(s, v0, c0y, c1y, v1)
        }
        return result
    }
}

/**
 * @brief[zh-cn] 三次贝塞尔曲线求值
 * @param[zh-cn] s 曲线参数 [0,1]
 * p0 起点值
 * p1 控制点1
 * p2 控制点2
 * p3 终点值
 * @return[zh-cn] 贝塞尔曲线值
 *
 * @brief[en] Evaluate cubic Bezier curve
 * @param[en] s Curve parameter [0,1]
 * p0 Start value
 * p1 Control point 1
 * p2 Control point 2
 * p3 End value
 * @return[en] Bezier curve value
 */
private func cubicBezier(s: Float64, p0: Float64, p1: Float64, p2: Float64, p3: Float64): Float64 {
    let k = 1.0 - s
    return k * k * k * p0 + 3.0 * k * k * s * p1 + 3.0 * k * s * s * p2 + s * s * s * p3
}

/**
 * @brief[zh-cn] 三次贝塞尔曲线斜率
 * @param[zh-cn] s 曲线参数 [0,1]
 * p0 起点值
 * p1 控制点1
 * p2 控制点2
 * p3 终点值
 * @return[zh-cn] 贝塞尔曲线斜率
 *
 * @brief[en] Cubic Bezier curve slope
 * @param[en] s Curve parameter [0,1]
 * p0 Start value
 * p1 Control point 1
 * p2 Control point 2
 * p3 End value
 * @return[en] Bezier curve slope
 */
private func cubicBezierSlope(s: Float64, p0: Float64, p1: Float64, p2: Float64, p3: Float64): Float64 {
    let k = 1.0 - s
    return 3.0 * k * k * (p1 - p0) + 6.0 * k * s * (p2 - p1) + 3.0 * s * s * (p3 - p2)
}

/**
 * @brief[zh-cn] 求解贝塞尔参数：在 [0,1] 范围内找到 s 使得 cubicBezier(s, x0, x1, x2, x3) = x，使用 Newton-Raphson 迭代法
 * @param[zh-cn] x 目标 x 值
 * x0 起点 x
 * x1 控制点1 x
 * x2 控制点2 x
 * x3 终点 x
 * @return[zh-cn] 曲线参数 s
 *
 * @brief[en] Solve Bezier parameter: find s in [0,1] such that cubicBezier(s, x0, x1, x2, x3) = x, using Newton-Raphson iteration
 * @param[en] x Target x value
 * x0 Start x
 * x1 Control point 1 x
 * x2 Control point 2 x
 * x3 End x
 * @return[en] Curve parameter s
 */
private func solveBezierParameter(x: Float64, x0: Float64, x1: Float64, x2: Float64, x3: Float64): Float64 {
    var s = (x - x0) / (x3 - x0)
    for (_ in 0..8) {
        let err = cubicBezier(s, x0, x1, x2, x3) - x
        if (abs(err) < 1e-10) { break }
        let slope = cubicBezierSlope(s, x0, x1, x2, x3)
        if (abs(slope) < 1e-10) { break }
        s = max(0.0, min(1.0, s - err / slope))
    }
    return s
}