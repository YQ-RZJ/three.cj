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
 * @file[zh-cn] 四元数关键帧轨道
 * @brief[zh-cn] 四元数关键帧轨道，使用球面线性插值（SLERP）
 *
 * @file[en] Quaternion Keyframe Track
 * @brief[en] Quaternion keyframe track, using spherical linear interpolation (SLERP)
 */
package three.animation.tracks

import three.core.math.Interpolant
import three.core.math.interpolants.QuaternionLinearInterpolant
import three.animation.blend.KeyframeTrack
import three.utils.constants.*

/**
 * @brief[zh-cn] 四元数关键帧轨道
 * @explain[zh-cn] 继承自 KeyframeTrack
 *
 * @brief[en] Quaternion keyframe track
 * @explain[en] Inherits from KeyframeTrack
 */
public class QuaternionKeyframeTrack <: KeyframeTrack {
    /**
     * @brief[zh-cn] 构造一个新的四元数关键帧轨道
     * @param[zh-cn] name 关键帧轨道名称
     * times 关键帧时间数组
     * values 关键帧值数组
     * interpolation 插值类型，默认为线性插值
     *
     * @brief[en] Constructs a new quaternion keyframe track
     * @param[en] name Keyframe track name
     * times Keyframe time array
     * values Keyframe value array
     * interpolation Interpolation type, defaults to linear interpolation
     */
    public init(name: String, times: Array<Float64>, values: Array<Float64>, interpolation!: Int64 = InterpolateLinear) {
        super(name, times, values, interpolation: interpolation)
        this.ValueTypeName = "quaternion"
    }

    /**
     * @brief[zh-cn] 重写线性插值工厂方法，返回四元数 SLERP 插值器
     * @explain[zh-cn] 四元数使用 QuaternionLinearInterpolant 而非普通 LinearInterpolant
     * @param[zh-cn] result 结果缓冲区的可选项
     * @return[zh-cn] 四元数线性（SLERP）插值器
     *
     * @brief[en] Overrides the linear interpolation factory method to return a quaternion SLERP interpolant
     * @explain[en] Quaternions use QuaternionLinearInterpolant instead of the plain LinearInterpolant
     * @param[en] result Optional result buffer
     * @return[en] Quaternion linear (SLERP) interpolant
     */
    public override func InterpolantFactoryMethodLinear(result: Option<Array<Float64>>): Interpolant {
        return QuaternionLinearInterpolant(this.times, this.values, this.getValueSize(), result)
    }

    /**
     * @brief[zh-cn] 重写平滑插值工厂方法，回退到线性插值
     * @explain[zh-cn] 四元数不支持平滑（三次）插值。对应 JS 中 QuaternionKeyframeTrack.prototype.InterpolantFactoryMethodSmooth = undefined
     * @param[zh-cn] result 结果缓冲区的可选项
     * @return[zh-cn] 四元数线性（SLERP）插值器
     *
     * @brief[en] Overrides the smooth interpolation factory method, falling back to linear interpolation
     * @explain[en] Quaternions do not support smooth (cubic) interpolation. Corresponds to QuaternionKeyframeTrack.prototype.InterpolantFactoryMethodSmooth = undefined in JS
     * @param[en] result Optional result buffer
     * @return[en] Quaternion linear (SLERP) interpolant
     */
    public override func InterpolantFactoryMethodSmooth(result: Option<Array<Float64>>): Interpolant {
        // 四元数不支持平滑插值，回退到线性（SLERP）插值
        return this.InterpolantFactoryMethodLinear(result)
    }
}
