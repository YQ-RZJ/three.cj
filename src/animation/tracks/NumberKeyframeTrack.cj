/**
 * @file[zh-cn] 数值关键帧轨道
 * @brief[zh-cn] 数值关键帧轨道，用于标量数值的动画
 *
 * @file[en] Number Keyframe Track
 * @brief[en] Number keyframe track, used for animating scalar numeric values
 */
package three.animation.tracks

import three.animation.blend.KeyframeTrack

/**
 * @brief[zh-cn] 数值关键帧轨道
 * @explain[zh-cn] 默认使用线性插值。继承自 KeyframeTrack
 *
 * @brief[en] Number keyframe track
 * @explain[en] Uses linear interpolation by default. Inherits from KeyframeTrack
 */
public class NumberKeyframeTrack <: KeyframeTrack {
    /**
     * @brief[zh-cn] 构造一个新的数值关键帧轨道
     * @param[zh-cn] name 关键帧轨道名称
     * times 关键帧时间数组
     * values 关键帧值数组
     * interpolation 插值类型，默认为线性插值
     *
     * @brief[en] Constructs a new number keyframe track
     * @param[en] name Keyframe track name
     * times Keyframe time array
     * values Keyframe value array
     * interpolation Interpolation type, defaults to linear interpolation
     */
    public init(name: String, times: Array<Float64>, values: Array<Float64>, interpolation!: Int64 = 0) {
        super(name, times, values, interpolation: interpolation)
        this.ValueTypeName = "number"
    }
}
