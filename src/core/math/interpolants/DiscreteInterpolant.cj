/**
 * @file[zh-cn] DiscreteInterpolant
 * @brief[zh-cn] 离散插值器
 * @explain[zh-cn] 不进行插值，直接返回前一个关键帧的值，继承自 Interpolant。
 *
 * @file[en] DiscreteInterpolant
 * @brief[en] Discrete interpolant
 * @explain[en] No interpolation, directly returns the previous keyframe value, extending Interpolant.
 */
package three.core.math.interpolants

import three.core.math.Interpolant

/**
 * @brief[zh-cn] 离散插值器
 *
 * @brief[en] Discrete interpolant
 *
 * @augments Interpolant
 */
public class DiscreteInterpolant <: Interpolant {
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
     * @brief[zh-cn] 离散插值计算，直接返回前一个关键帧的值
     * @param[zh-cn] i1 右侧关键帧索引
     * t0 左侧时间
     * t 当前插值时间
     * t1 右侧时间
     * @return[zh-cn] 插值结果数组
     *
     * @brief[en] Discrete interpolation, directly returns the previous keyframe value
     * @param[en] i1 Right keyframe index
     * t0 Left time
     * t Current interpolation time
     * t1 Right time
     * @return[en] Interpolated result array
     */
    public override func interpolate_(i1: Int64, t0: Float64, t: Float64, t1: Float64): Array<Float64> {
        return this.copySampleValue_(i1 - 1)
    }
}