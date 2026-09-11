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
 * @file[zh-cn] 颜色关键帧轨道
 * @brief[zh-cn] 颜色关键帧轨道，继承 KeyframeTrack 的默认插值行为
 *
 * @file[en] Color Keyframe Track
 * @brief[en] Color keyframe track, inheriting KeyframeTrack's default interpolation behavior
 */
package three.animation.tracks

import three.animation.blend.KeyframeTrack

/**
 * @brief[zh-cn] 颜色关键帧轨道
 * @explain[zh-cn] 默认使用线性插值，与 NumberKeyframeTrack 和 VectorKeyframeTrack 相同。继承自 KeyframeTrack
 *
 * @brief[en] Color keyframe track
 * @explain[en] Uses linear interpolation by default, same as NumberKeyframeTrack and VectorKeyframeTrack. Inherits from KeyframeTrack
 */
public class ColorKeyframeTrack <: KeyframeTrack {
    /**
     * @brief[zh-cn] 构造一个新的颜色关键帧轨道
     * @param[zh-cn] name 关键帧轨道名称
     * times 关键帧时间数组
     * values 关键帧值数组
     * interpolation 插值类型，默认为线性插值
     *
     * @brief[en] Constructs a new color keyframe track
     * @param[en] name Keyframe track name
     * times Keyframe time array
     * values Keyframe value array
     * interpolation Interpolation type, defaults to linear interpolation
     */
    public init(name: String, times: Array<Float64>, values: Array<Float64>, interpolation!: Int64 = 0) {
        super(name, times, values, interpolation: interpolation)
        this.ValueTypeName = "color"
    }
}
