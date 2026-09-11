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
 * @file[zh-cn] CubicInterpolant
 * @brief[zh-cn] 三次样条插值器
 * @explain[zh-cn] 使用三次样条曲线进行插值，继承自 Interpolant。支持 ZeroCurvatureEnding、ZeroSlopeEnding、WrapAroundEnding 三种边界模式。
 *
 * @file[en] CubicInterpolant
 * @brief[en] Cubic spline interpolant
 * @explain[en] Interpolates using cubic spline curves, extending Interpolant. Supports ZeroCurvatureEnding, ZeroSlopeEnding, and WrapAroundEnding boundary modes.
 */
package three.core.math.interpolants

import three.core.math.Interpolant
import three.utils.constants.*

/**
 * @brief[zh-cn] 三次样条插值器
 *
 * @brief[en] Cubic spline interpolant
 *
 * @augments Interpolant
 */
public class CubicInterpolant <: Interpolant {
    /**
     * @brief[zh-cn] 前一区间权重
     *
     * @brief[en] Weight of the previous interval
     */
    private var _weightPrev: Float64
    /**
     * @brief[zh-cn] 前一区间偏移
     *
     * @brief[en] Offset of the previous interval
     */
    private var _offsetPrev: Int64
    /**
     * @brief[zh-cn] 后一区间权重
     *
     * @brief[en] Weight of the next interval
     */
    private var _weightNext: Float64
    /**
     * @brief[zh-cn] 后一区间偏移
     *
     * @brief[en] Offset of the next interval
     */
    private var _offsetNext: Int64

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
        this._weightPrev = -0.0
        this._offsetPrev = -0
        this._weightNext = -0.0
        this._offsetNext = -0
        this.DefaultSettings_["endingStart"] = ZeroCurvatureEnding
        this.DefaultSettings_["endingEnd"] = ZeroCurvatureEnding
    }

    /**
     * @brief[zh-cn] 区间变化时更新权重和偏移
     * @param[zh-cn] i1 右侧关键帧索引
     * t0 左侧时间
     * t1 右侧时间
     *
     * @brief[en] Update weights and offsets when interval changes
     * @param[en] i1 Right keyframe index
     * t0 Left time
     * t1 Right time
     */
    public override func intervalChanged_(i1: Int64, t0: Float64, t1: Float64): Unit {
        let pp = this.parameterPositions
        var iPrev = i1 - 2
        var iNext = i1 + 1
        var tPrev = pp[iPrev]
        var tNext = pp[iNext]

        if (tPrev.isNaN()) {
            let settings = this.getSettings_()
            let endingStart = settings.get("endingStart").getOrThrow()
            if (endingStart == ZeroSlopeEnding) {
                iPrev = i1
                tPrev = 2.0 * t0 - t1
            } else if (endingStart == WrapAroundEnding) {
                iPrev = pp.size - 2
                tPrev = t0 + pp[iPrev] - pp[iPrev + 1]
            } else { // ZeroCurvatureEnding
                iPrev = i1
                tPrev = t1
            }
        }

        if (tNext.isNaN()) {
            let settings = this.getSettings_()
            let endingEnd = settings.get("endingEnd").getOrThrow()
            if (endingEnd == ZeroSlopeEnding) {
                iNext = i1
                tNext = 2.0 * t1 - t0
            } else if (endingEnd == WrapAroundEnding) {
                iNext = 1
                tNext = t1 + pp[1] - pp[0]
            } else { // ZeroCurvatureEnding
                iNext = i1 - 1
                tNext = t0
            }
        }

        let halfDt = (t1 - t0) * 0.5
        let stride = this.valueSize
        this._weightPrev = halfDt / (t0 - tPrev)
        this._weightNext = halfDt / (tNext - t1)
        this._offsetPrev = iPrev * stride
        this._offsetNext = iNext * stride
    }

    /**
     * @brief[zh-cn] 三次样条插值计算
     * @param[zh-cn] i1 右侧关键帧索引
     * t0 左侧时间
     * t 当前插值时间
     * t1 右侧时间
     * @return[zh-cn] 插值结果数组
     *
     * @brief[en] Cubic spline interpolation calculation
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

        let o1 = i1 * stride
        let o0 = o1 - stride
        let oP = this._offsetPrev
        let oN = this._offsetNext
        let wP = this._weightPrev
        let wN = this._weightNext

        let p = (t - t0) / (t1 - t0)
        let pp = p * p
        let ppp = pp * p

        // evaluate polynomials
        let sP = -wP * ppp + 2.0 * wP * pp - wP * p
        let s0 = (1.0 + wP) * ppp + (-1.5 - 2.0 * wP) * pp + (-0.5 + wP) * p + 1.0
        let s1 = (-1.0 - wN) * ppp + (1.5 + wN) * pp + 0.5 * p
        let sN = wN * ppp - wN * pp

        // combine data linearly
        for (i in 0..stride) {
            result[i] = sP * values[oP + i] + s0 * values[o0 + i] + s1 * values[o1 + i] + sN * values[oN + i]
        }
        return result
    }
}