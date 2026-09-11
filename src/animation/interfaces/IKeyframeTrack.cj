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
 * @file[zh-cn] IKeyframeTrack 关键帧轨道接口（解耦 clip 与 blend 包的循环依赖）
 * @brief[zh-cn] 定义 KeyframeTrack 的公共契约，供 clip 包以接口引用轨道实例
 *
 * @file[en] IKeyframeTrack  Keyframe track interface (decouples the circular dependency between the clip and blend packages)
 * @brief[en] Defines the public contract of KeyframeTrack, referenced by the clip package through this interface
 */
package three.animation.interfaces

import three.core.math.Interpolant

/**
 * @brief[zh-cn] 关键帧轨道接口：AnimationClip.tracks 的元素类型
 * @explain[zh-cn] 暴露 clip 包所需访问的只读属性与方法签名。
 * KeyframeTrack（blend 包）实现本接口；其子类（tracks/\*）通过继承自动实现。
 *
 * @brief[en] Keyframe track interface: the element type of AnimationClip.tracks
 * @explain[en] Exposes the read-only properties and method signatures the clip package needs to access.
 * KeyframeTrack (blend package) implements this interface; its subclasses (tracks/\*) implement
 * it automatically through inheritance.
 */
public interface IKeyframeTrack {
    /**
     * @brief[zh-cn] 轨道名称（用于 PropertyBinding 绑定目标属性）
     *
     * @brief[en] Track name (used by PropertyBinding to bind the target property)
     */
    mut prop name: String

    /**
     * @brief[zh-cn] 关键帧时间数组（秒）
     *
     * @brief[en] Keyframe time array (seconds)
     */
    mut prop times: Array<Float64>

    /**
     * @brief[zh-cn] 关键帧值数组（按 getValueSize 分组）
     *
     * @brief[en] Keyframe value array (grouped by getValueSize)
     */
    mut prop values: Array<Float64>

    /**
     * @brief[zh-cn] 值类型名（子类设置，如 "number"/"vector"/"quaternion"/"bool"/"string"/"color"）
     *
     * @brief[en] Value type name (set by subclasses, e.g. "number"/"vector"/"quaternion"/"bool"/"string"/"color")
     */
    mut prop ValueTypeName: String

    /**
     * @brief[zh-cn] 值容器类型（"Array" 或 TypedArray 名）
     *
     * @brief[en] Value buffer type ("Array" or a TypedArray name)
     */
    mut prop ValueBufferType: String

    /**
     * @brief[zh-cn] 默认插值类型（InterpolateLinear/InterpolateDiscrete 等）
     *
     * @brief[en] Default interpolation type (InterpolateLinear/InterpolateDiscrete, etc.)
     */
    mut prop DefaultInterpolation: Int64

    /**
     * @brief[zh-cn] 创建插值器（按当前 _interpolation 选择工厂方法）
     * @param[zh-cn] result 可选的结果缓冲区，用于复用
     * @return[zh-cn] 新建的插值器实例
     *
     * @brief[en] Creates an interpolant (choosing the factory method by the current _interpolation)
     * @param[en] result Optional result buffer to reuse
     * @return[en] The newly created interpolant
     */
    func createInterpolant(result: Option<Array<Float64>>): Interpolant

    /**
     * @brief[zh-cn] 平移时间（返回 this 以支持链式调用）
     * @param[zh-cn] timeOffset 时间偏移量（秒）
     * @return[zh-cn] 当前轨道
     *
     * @brief[en] Shifts the times by an offset (returns this for chaining)
     * @param[en] timeOffset Time offset (seconds)
     * @return[en] This track
     */
    func shift(timeOffset: Float64): IKeyframeTrack

    /**
     * @brief[zh-cn] 缩放时间（返回 this）
     * @param[zh-cn] timeScale 时间缩放因子
     * @return[zh-cn] 当前轨道
     *
     * @brief[en] Scales the times (returns this)
     * @param[en] timeScale Time scale factor
     * @return[en] This track
     */
    func scale(timeScale: Float64): IKeyframeTrack

    /**
     * @brief[zh-cn] 裁剪时间范围（返回 this）
     * @param[zh-cn] startTime 裁剪起始时间（秒）
     * endTime 裁剪结束时间（秒）
     * @return[zh-cn] 当前轨道
     *
     * @brief[en] Trims the time range (returns this)
     * @param[en] startTime Trim start time (seconds)
     * endTime Trim end time (seconds)
     * @return[en] This track
     */
    func trim(startTime: Float64, endTime: Float64): IKeyframeTrack

    /**
     * @brief[zh-cn] 验证关键帧数据有效性
     * @return[zh-cn] 数据是否有效
     *
     * @brief[en] Validates the keyframe data
     * @return[en] Whether the data is valid
     */
    func validate(): Bool

    /**
     * @brief[zh-cn] 优化关键帧（移除等效的连续关键帧，返回 this）
     * @return[zh-cn] 当前轨道
     *
     * @brief[en] Optimizes the keyframes (removes equivalent consecutive keyframes, returns this)
     * @return[en] This track
     */
    func optimize(): IKeyframeTrack

    /**
     * @brief[zh-cn] 克隆轨道
     * @return[zh-cn] 轨道副本
     *
     * @brief[en] Clones the track
     * @return[en] A copy of the track
     */
    func clone(): IKeyframeTrack

    /**
     * @brief[zh-cn] 获取值大小（每个关键帧的数值数量）
     * @return[zh-cn] 值大小
     *
     * @brief[en] Returns the value size (number of numbers per keyframe)
     * @return[en] The value size
     */
    func getValueSize(): Int64

    /**
     * @brief[zh-cn] 获取当前插值类型
     * @return[zh-cn] 插值类型
     *
     * @brief[en] Returns the current interpolation type
     * @return[en] The interpolation type
     */
    func getInterpolation(): Int64

    /**
     * @brief[zh-cn] 设置插值方式（返回 this）
     * @param[zh-cn] interpolation 插值类型
     * @return[zh-cn] 当前轨道
     *
     * @brief[en] Sets the interpolation type (returns this)
     * @param[en] interpolation Interpolation type
     * @return[en] This track
     */
    func setInterpolation(interpolation: Int64): IKeyframeTrack

    /**
     * @brief[zh-cn] 创建离散插值器
     * @param[zh-cn] result 可选的结果缓冲区，用于复用
     * @return[zh-cn] 离散插值器实例
     *
     * @brief[en] Creates a discrete interpolant
     * @param[en] result Optional result buffer to reuse
     * @return[en] A discrete interpolant
     */
    func InterpolantFactoryMethodDiscrete(result: Option<Array<Float64>>): Interpolant

    /**
     * @brief[zh-cn] 创建线性插值器
     * @param[zh-cn] result 可选的结果缓冲区，用于复用
     * @return[zh-cn] 线性插值器实例
     *
     * @brief[en] Creates a linear interpolant
     * @param[en] result Optional result buffer to reuse
     * @return[en] A linear interpolant
     */
    func InterpolantFactoryMethodLinear(result: Option<Array<Float64>>): Interpolant

    /**
     * @brief[zh-cn] 创建平滑插值器
     * @param[zh-cn] result 可选的结果缓冲区，用于复用
     * @return[zh-cn] 平滑插值器实例
     *
     * @brief[en] Creates a smooth (cubic) interpolant
     * @param[en] result Optional result buffer to reuse
     * @return[en] A smooth interpolant
     */
    func InterpolantFactoryMethodSmooth(result: Option<Array<Float64>>): Interpolant

    /**
     * @brief[zh-cn] 创建贝塞尔插值器
     * @param[zh-cn] result 可选的结果缓冲区，用于复用
     * @return[zh-cn] 贝塞尔插值器实例
     *
     * @brief[en] Creates a bezier interpolant
     * @param[en] result Optional result buffer to reuse
     * @return[en] A bezier interpolant
     */
    func InterpolantFactoryMethodBezier(result: Option<Array<Float64>>): Interpolant
}
