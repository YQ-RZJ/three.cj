/**
 * @file[zh-cn] 向量关键帧轨道
 * @brief[zh-cn] 向量关键帧轨道，用于向量值（Vector2/Vector3/Vector4）的动画
 *
 * @file[en] Vector Keyframe Track
 * @brief[en] Vector keyframe track, used for animating vector values (Vector2/Vector3/Vector4)
 */
package three.animation.tracks

import three.animation.blend.KeyframeTrack

/**
 * @brief[zh-cn] 向量关键帧轨道
 * @explain[zh-cn] 默认使用线性插值。继承自 KeyframeTrack
 *
 * @brief[en] Vector keyframe track
 * @explain[en] Uses linear interpolation by default. Inherits from KeyframeTrack
 */
public class VectorKeyframeTrack <: KeyframeTrack {
    /**
     * @brief[zh-cn] 构造一个新的向量关键帧轨道
     * @param[zh-cn] name 关键帧轨道名称
     * times 关键帧时间数组
     * values 关键帧值数组
     * interpolation 插值类型，默认为线性插值
     *
     * @brief[en] Constructs a new vector keyframe track
     * @param[en] name Keyframe track name
     * times Keyframe time array
     * values Keyframe value array
     * interpolation Interpolation type, defaults to linear interpolation
     */
    public init(name: String, times: Array<Float64>, values: Array<Float64>, interpolation!: Int64 = 0) {
        super(name, times, values, interpolation: interpolation)
        this.ValueTypeName = "vector"
    }
}
