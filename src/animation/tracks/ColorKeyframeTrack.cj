/**
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
