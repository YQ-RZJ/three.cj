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
 * @file[zh-cn] QuaternionLinearInterpolant
 * @brief[zh-cn] 四元数球面线性插值器
 * @explain[zh-cn] 使用四元数球面线性插值（SLERP）在关键帧之间进行插值，继承自 Interpolant。
 *
 * @file[en] QuaternionLinearInterpolant
 * @brief[en] Quaternion spherical linear interpolant (SLERP)
 * @explain[en] Interpolates between keyframes using quaternion spherical linear interpolation (SLERP), extending Interpolant.
 */
package three.core.math.interpolants

import three.core.math.Interpolant
import three.core.math.Quaternion

/**
 * @brief[zh-cn] 四元数球面线性插值器（SLERP）
 *
 * @brief[en] Quaternion spherical linear interpolant (SLERP)
 *
 * @augments Interpolant
 */
public class QuaternionLinearInterpolant <: Interpolant {
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
    }

    /**
     * @brief[zh-cn] 四元数球面线性插值计算
     * @param[zh-cn] i1 右侧关键帧索引
     * t0 左侧时间
     * t 当前插值时间
     * t1 右侧时间
     * @return[zh-cn] 插值结果数组
     *
     * @brief[en] Quaternion spherical linear interpolation calculation
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
        let alpha = (t - t0) / (t1 - t0)

        var offset = i1 * stride
        let end = offset + stride
        while (offset < end) {
            Quaternion.slerpFlat(result, 0, values, offset - stride, values, offset, alpha)
            offset += 4
        }
        return result
    }
}