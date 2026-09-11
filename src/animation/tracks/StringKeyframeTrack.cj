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
 * @file[zh-cn] 字符串关键帧轨道
 * @brief[zh-cn] 字符串关键帧轨道，始终使用离散插值
 *
 * @file[en] String Keyframe Track
 * @brief[en] String keyframe track, always using discrete interpolation
 */
package three.animation.tracks

import three.utils.constants.*
import three.core.math.Interpolant
import three.animation.blend.KeyframeTrack

/**
 * @brief[zh-cn] 字符串关键帧轨道
 * @explain[zh-cn] 此关键帧轨道类型没有 interpolation 参数，因为插值始终是离散的。继承自 KeyframeTrack
 *
 * @brief[en] String keyframe track
 * @explain[en] This keyframe track type has no interpolation parameter because interpolation is always discrete. Inherits from KeyframeTrack
 */
public class StringKeyframeTrack <: KeyframeTrack {
    /**
     * @brief[zh-cn] 构造一个新的字符串关键帧轨道
     * @param[zh-cn] name 关键帧轨道名称
     * times 关键帧时间数组
     * values 关键帧值数组
     *
     * @brief[en] Constructs a new string keyframe track
     * @param[en] name Keyframe track name
     * times Keyframe time array
     * values Keyframe value array
     */
    public init(name: String, times: Array<Float64>, values: Array<Float64>) {
        super(name, times, values, interpolation: InterpolateDiscrete)
        this.ValueTypeName = "string"
        this.ValueBufferType = "Array"
        this.DefaultInterpolation = InterpolateDiscrete
    }

    /**
     * @brief[zh-cn] 重写线性插值工厂方法为离散插值
     * @explain[zh-cn] 字符串不支持线性插值。对应 JS 中 StringKeyframeTrack.prototype.InterpolantFactoryMethodLinear = undefined
     * @param[zh-cn] result 结果缓冲区的可选项
     * @return[zh-cn] 离散插值器
     *
     * @brief[en] Overrides the linear interpolation factory method with discrete interpolation
     * @explain[en] Strings do not support linear interpolation. Corresponds to StringKeyframeTrack.prototype.InterpolantFactoryMethodLinear = undefined in JS
     * @param[en] result Optional result buffer
     * @return[en] Discrete interpolant
     */
    public override func InterpolantFactoryMethodLinear(result: Option<Array<Float64>>): Interpolant {
        return this.InterpolantFactoryMethodDiscrete(result)
    }

    /**
     * @brief[zh-cn] 重写平滑插值工厂方法为离散插值
     * @explain[zh-cn] 字符串不支持平滑插值。对应 JS 中 StringKeyframeTrack.prototype.InterpolantFactoryMethodSmooth = undefined
     * @param[zh-cn] result 结果缓冲区的可选项
     * @return[zh-cn] 离散插值器
     *
     * @brief[en] Overrides the smooth interpolation factory method with discrete interpolation
     * @explain[en] Strings do not support smooth interpolation. Corresponds to StringKeyframeTrack.prototype.InterpolantFactoryMethodSmooth = undefined in JS
     * @param[en] result Optional result buffer
     * @return[en] Discrete interpolant
     */
    public override func InterpolantFactoryMethodSmooth(result: Option<Array<Float64>>): Interpolant {
        return this.InterpolantFactoryMethodDiscrete(result)
    }

    /**
     * @brief[zh-cn] 重写设置插值方式，字符串始终使用离散插值
     * @explain[zh-cn] 当尝试设置非离散插值时，回退到默认的离散插值
     * @param[zh-cn] interpolation 要设置的插值类型
     * @return[zh-cn] 设置后的关键帧轨道
     *
     * @brief[en] Overrides the interpolation setter; strings always use discrete interpolation
     * @explain[en] Falls back to the default discrete interpolation when a non-discrete interpolation is requested
     * @param[en] interpolation The interpolation type to set
     * @return[en] The keyframe track after setting
     */
    public override func setInterpolation(interpolation: Int64): KeyframeTrack {
        if (interpolation != InterpolateDiscrete) {
            // 不支持的插值类型，回退到默认离散插值
            return super.setInterpolation(this.DefaultInterpolation)
        }
        return super.setInterpolation(interpolation)
    }
}
