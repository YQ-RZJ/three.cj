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
 * @file[zh-cn] KeyframeTrack.cj 关键帧轨道
 * @brief[zh-cn] 本文件定义关键帧轨道基类，管理动画关键帧数据
 * @explain[zh-cn] 关键帧轨道保存某一属性的时间序列与对应取值，并负责按插值方式生成插值器。
 * 实现 IKeyframeTrack 接口，便于 clip 包通过接口引用（避免循环依赖）。
 *
 * @file[en] KeyframeTrack.cj Keyframe track
 * @brief[en] This file defines the base keyframe track class that manages animation keyframe data
 * @explain[en] A keyframe track stores the time sequence and corresponding values of a property,
 * and is responsible for creating interpolants according to the interpolation mode.
 * It implements the IKeyframeTrack interface so the clip package can reference it
 * through the interface (avoiding circular dependencies).
 */
package three.animation.blend

import three.core.math.Interpolant
import three.core.math.interpolants.*
import three.utils.constants.*
import three.utils.log.Logger
import three.animation.interfaces.IKeyframeTrack
import std.collection.*
import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 关键帧轨道
 * @explain[zh-cn] 管理一组关键帧的时间与值，根据插值类型创建对应的插值器。
 * 子类（tracks 目录下的类）继承本类时自动实现 IKeyframeTrack 接口。
 *
 * @brief[en] Keyframe track
 * @explain[en] Manages the times and values of a set of keyframes and creates the
 * corresponding interpolant based on the interpolation type. Subclasses
 * (classes under the tracks directory) automatically implement the
 * IKeyframeTrack interface by inheriting this class.
 */
@JsonAdapter
public open class KeyframeTrack <: IKeyframeTrack {
    /**
     * @brief[zh-cn] 轨道名称（私有存储，由 name 属性访问）
     *
     * @brief[en] Track name (private storage, accessed via the name property)
     */
    @JsonIgnore
    internal var _name: String = ""
    /**
     * @brief[zh-cn] 用于访问轨道名称
     *
     * @brief[en] Used to access the track name
     */
    public mut prop name: String {
        get() { return this._name }
        set(v) { this._name = v }
    }

    /**
     * @brief[zh-cn] 各关键帧的时间序列（私有存储，由 times 属性访问）
     *
     * @brief[en] Time sequence of each keyframe (private storage, accessed via the times property)
     */
    @JsonIgnore
    internal var _times: Array<Float64> = Array<Float64>(0, { _ => 0.0 })
    /**
     * @brief[zh-cn] 用于访问各关键帧的时间序列
     *
     * @brief[en] Used to access the time sequence of each keyframe
     */
    public mut prop times: Array<Float64> {
        get() { return this._times }
        set(v) { this._times = v }
    }

    /**
     * @brief[zh-cn] 各关键帧对应的取值序列（私有存储，由 values 属性访问）
     *
     * @brief[en] Value sequence corresponding to each keyframe (private storage, accessed via the values property)
     */
    @JsonIgnore
    internal var _values: Array<Float64> = Array<Float64>(0, { _ => 0.0 })
    /**
     * @brief[zh-cn] 用于访问各关键帧对应的取值序列
     *
     * @brief[en] Used to access the value sequence corresponding to each keyframe
     */
    public mut prop values: Array<Float64> {
        get() { return this._values }
        set(v) { this._values = v }
    }

    /**
     * @brief[zh-cn] 私有插值类型，由 get/set 访问器管理，不参与序列化
     *
     * @brief[en] Private interpolation type, managed by the get/set accessors and excluded from serialization
     */
    @JsonIgnore
    internal var _interpolation: Int64

    /**
     * @brief[zh-cn] 类型属性名称（私有存储，子类可覆盖）
     *
     * @brief[en] Type property name (private storage, overridable by subclasses)
     */
    @JsonIgnore
    internal var _ValueTypeName: String = ""
    /**
     * @brief[zh-cn] 用于访问类型属性名称
     *
     * @brief[en] Used to access the type property name
     */
    public mut prop ValueTypeName: String {
        get() { return this._ValueTypeName }
        set(v) { this._ValueTypeName = v }
    }

    /**
     * @brief[zh-cn] 值缓冲类型名称（私有存储，子类可覆盖）
     *
     * @brief[en] Value buffer type name (private storage, overridable by subclasses)
     */
    @JsonIgnore
    internal var _ValueBufferType: String = ""
    /**
     * @brief[zh-cn] 用于访问值缓冲类型名称
     *
     * @brief[en] Used to access the value buffer type name
     */
    public mut prop ValueBufferType: String {
        get() { return this._ValueBufferType }
        set(v) { this._ValueBufferType = v }
    }

    /**
     * @brief[zh-cn] 默认插值方式（私有存储，子类可覆盖）
     *
     * @brief[en] Default interpolation mode (private storage, overridable by subclasses)
     */
    @JsonIgnore
    internal var _DefaultInterpolation: Int64 = InterpolateLinear
    /**
     * @brief[zh-cn] 用于访问默认插值方式
     *
     * @brief[en] Used to access the default interpolation mode
     */
    public mut prop DefaultInterpolation: Int64 {
        get() { return this._DefaultInterpolation }
        set(v) { this._DefaultInterpolation = v }
    }

    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] Parameterless constructor (used by fastjson deserialization)
     */
    public init() {
        this._name = ""
        this._times = Array<Float64>(0, { _ => 0.0 })
        this._values = Array<Float64>(0, { _ => 0.0 })
        this._interpolation = InterpolateLinear
    }

    /**
     * @brief[zh-cn] 以指定名称、时间与取值创建关键帧轨道
     * @param[zh-cn] name 轨道名称，不能为空
     * times 各关键帧的时间序列
     * values 各关键帧对应的取值序列
     * interpolation 插值方式，默认为线性插值
     *
     * @brief[en] Creates a keyframe track with the given name, times and values
     * @param[en] name Track name, must not be empty
     * times The time sequence of each keyframe
     * values The value sequence corresponding to each keyframe
     * interpolation The interpolation mode, defaults to linear interpolation
     *
     * @throws[zh-cn] Exception 当名称为空或不存在任何关键帧时
     * @throws[en] Exception When the name is empty or there are no keyframes
     */
    public init(name: String, times: Array<Float64>, values: Array<Float64>, interpolation!: Int64 = InterpolateLinear) {
        if (name == "") { throw Exception("THREE.KeyframeTrack: track name is undefined") }
        if (times.size == 0) { throw Exception("THREE.KeyframeTrack: no keyframes in track named " + name) }

        this._name = name
        this._times = times
        this._values = values
        // 直接设置插值类型，避免在 open class 构造函数中调用实例方法
        if (interpolation == InterpolateDiscrete || interpolation == InterpolateLinear ||
            interpolation == InterpolateSmooth || interpolation == InterpolateBezier) {
            this._interpolation = interpolation
        } else {
            this._interpolation = this._DefaultInterpolation
        }
    }

    /**
     * @brief[zh-cn] 创建插值器（根据当前插值类型自动选择工厂方法）
     * @param[zh-cn] result 可选的结果缓冲数组
     * @return[zh-cn] 返回根据当前插值类型创建的插值器
     *
     * @brief[en] Creates an interpolant, automatically selecting the factory method based on the current interpolation type
     * @param[en] result Optional result buffer array
     * @return[en] Returns the interpolant created for the current interpolation type
     */
    public func createInterpolant(result: Option<Array<Float64>>): Interpolant {
        if (this._interpolation == InterpolateDiscrete) {
            return this.InterpolantFactoryMethodDiscrete(result)
        } else if (this._interpolation == InterpolateSmooth) {
            return this.InterpolantFactoryMethodSmooth(result)
        } else if (this._interpolation == InterpolateBezier) {
            return this.InterpolantFactoryMethodBezier(result)
        }
        return this.InterpolantFactoryMethodLinear(result)
    }

    /**
     * @brief[zh-cn] 创建离散插值器
     * @param[zh-cn] result 可选的结果缓冲数组
     * @return[zh-cn] 返回离散插值器
     *
     * @brief[en] Creates a discrete interpolant
     * @param[en] result Optional result buffer array
     * @return[en] Returns the discrete interpolant
     */
    public open func InterpolantFactoryMethodDiscrete(result: Option<Array<Float64>>): Interpolant {
        return DiscreteInterpolant(this.times, this.values, this.getValueSize(), result)
    }

    /**
     * @brief[zh-cn] 创建线性插值器
     * @param[zh-cn] result 可选的结果缓冲数组
     * @return[zh-cn] 返回线性插值器
     *
     * @brief[en] Creates a linear interpolant
     * @param[en] result Optional result buffer array
     * @return[en] Returns the linear interpolant
     */
    public open func InterpolantFactoryMethodLinear(result: Option<Array<Float64>>): Interpolant {
        return LinearInterpolant(this.times, this.values, this.getValueSize(), result)
    }

    /**
     * @brief[zh-cn] 创建平滑插值器
     * @param[zh-cn] result 可选的结果缓冲数组
     * @return[zh-cn] 返回平滑插值器
     *
     * @brief[en] Creates a smooth (cubic) interpolant
     * @param[en] result Optional result buffer array
     * @return[en] Returns the smooth interpolant
     */
    public open func InterpolantFactoryMethodSmooth(result: Option<Array<Float64>>): Interpolant {
        return CubicInterpolant(this.times, this.values, this.getValueSize(), result)
    }

    /**
     * @brief[zh-cn] 创建贝塞尔插值器
     * @param[zh-cn] result 可选的结果缓冲数组
     * @return[zh-cn] 返回贝塞尔插值器
     *
     * @brief[en] Creates a Bezier interpolant
     * @param[en] result Optional result buffer array
     * @return[en] Returns the Bezier interpolant
     */
    public open func InterpolantFactoryMethodBezier(result: Option<Array<Float64>>): Interpolant {
        let interpolant = BezierInterpolant(this.times, this.values, this.getValueSize(), result)
        return interpolant
    }

    /**
     * @brief[zh-cn] 设置插值方式
     * @param[zh-cn] interpolation 插值方式
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Sets the interpolation mode
     * @param[en] interpolation The interpolation mode
     * @return[en] Returns itself for chaining
     *
     * @note[zh-cn] 不支持的类型会回退到默认插值。
     * @note[en] Unsupported types fall back to the default interpolation.
     */
    public open func setInterpolation(interpolation: Int64): KeyframeTrack {
        if (interpolation == InterpolateDiscrete || interpolation == InterpolateLinear ||
            interpolation == InterpolateSmooth || interpolation == InterpolateBezier) {
            this._interpolation = interpolation
        } else {
            // 不支持的类型，回退到默认
            if (interpolation != this.DefaultInterpolation) {
                return this.setInterpolation(this.DefaultInterpolation)
            }
            Logger.warn(["KeyframeTrack:", "unsupported interpolation for " + this.ValueTypeName + " keyframe track named " + this.name])
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取当前插值类型
     * @return[zh-cn] 返回当前的插值类型
     *
     * @brief[en] Returns the current interpolation type
     * @return[en] Returns the current interpolation type
     */
    public func getInterpolation(): Int64 {
        return this._interpolation
    }

    /**
     * @brief[zh-cn] 获取值大小（每个关键帧的数值数量）
     * @return[zh-cn] 返回每个关键帧的数值数量
     *
     * @brief[en] Returns the value size (number of numbers per keyframe)
     * @return[en] Returns the number of values per keyframe
     */
    public func getValueSize(): Int64 {
        return this.values.size / this.times.size
    }

    /**
     * @brief[zh-cn] 平移时间
     * @param[zh-cn] timeOffset 时间偏移量
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Shifts the times by an offset
     * @param[en] timeOffset The time offset
     * @return[en] Returns itself for chaining
     */
    public func shift(timeOffset: Float64): KeyframeTrack {
        if (timeOffset != 0.0) {
            for (i in 0..this.times.size) {
                this.times[i] += timeOffset
            }
        }
        return this
    }

    /**
     * @brief[zh-cn] 缩放时间
     * @param[zh-cn] timeScale 时间缩放系数
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Scales the times by a factor
     * @param[en] timeScale The time scale factor
     * @return[en] Returns itself for chaining
     */
    public func scale(timeScale: Float64): KeyframeTrack {
        if (timeScale != 1.0) {
            for (i in 0..this.times.size) {
                this.times[i] *= timeScale
            }
        }
        return this
    }

    /**
     * @brief[zh-cn] 裁剪时间范围
     * @param[zh-cn] startTime 起始时间
     * endTime 结束时间
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Trims the track to the given time range
     * @param[en] startTime The start time
     * endTime The end time
     * @return[en] Returns itself for chaining
     *
     * @note[zh-cn] 空轨道不允许，至少保留一个关键帧。
     * @note[en] Empty tracks are not allowed; at least one keyframe is kept.
     */
    public func trim(startTime: Float64, endTime: Float64): KeyframeTrack {
        let times = this.times
        let nKeys = times.size

        var from: Int64 = 0
        var to: Int64 = nKeys - 1

        while (from != nKeys && times[from] < startTime) {
            from += 1
        }
        while (to != -1 && times[to] > endTime) {
            to -= 1
        }
        to += 1 // inclusive -> exclusive bound

        if (from != 0 || to != nKeys) {
            // 空轨道不允许，至少保留一个关键帧
            if (from >= to) {
                to = max(to, 1)
                from = to - 1
            }

            let stride = this.getValueSize()
            // 切片 times
            let newTimesSize = to - from
            let fromVal = from
            let newTimes = Array<Float64>(newTimesSize, { i => times[fromVal + i] })
            this.times = newTimes

            // 切片 values
            let newValuesSize = (to - from) * stride
            let newValues = Array<Float64>(newValuesSize, { i => this.values[fromVal * stride + i] })
            this.values = newValues
        }
        return this
    }

    /**
     * @brief[zh-cn] 验证关键帧数据有效性
     * @return[zh-cn] 数据有效时返回 true，否则返回 false
     *
     * @brief[en] Validates the keyframe data
     * @return[en] Returns true if the data is valid, false otherwise
     */
    public func validate(): Bool {
        var valid = true
        let valueSize = this.getValueSize()
        if (Float64(valueSize) - floor(Float64(valueSize)) != 0.0) {
            Logger.error(["KeyframeTrack: Invalid value size in track."])
            valid = false
        }

        let times = this.times
        let values = this.values
        let nKeys = times.size

        if (nKeys == 0) {
            Logger.error(["KeyframeTrack: Track is empty."])
            valid = false
        }

        var prevTime: Option<Float64> = None
        for (i in 0..nKeys) {
            let currTime = times[i]
            if (currTime.isNaN()) {
                Logger.error(["KeyframeTrack: Time is not a valid number.", i.toString(), currTime.toString()])
                valid = false
                break
            }
            if (prevTime.isSome() && prevTime.getOrThrow() > currTime) {
                Logger.error(["KeyframeTrack: Out of order keys.", i.toString(), currTime.toString(), prevTime.getOrThrow().toString()])
                valid = false
                break
            }
            prevTime = Some(currTime)
        }

        for (i in 0..values.size) {
            if (values[i].isNaN()) {
                Logger.error(["KeyframeTrack: Value is not a valid number.", i.toString(), values[i].toString()])
                valid = false
                break
            }
        }

        return valid
    }

    /**
     * @brief[zh-cn] 优化关键帧（移除等效的连续关键帧）
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Optimizes the track by removing equivalent consecutive keyframes
     * @return[en] Returns itself for chaining
     */
    public func optimize(): KeyframeTrack {
        // 复制 times 和 values
        let times = Array<Float64>(this.times.size, { i => this.times[i] })
        let values = Array<Float64>(this.values.size, { i => this.values[i] })
        let stride = this.getValueSize()
        let smoothInterpolation = this.getInterpolation() == InterpolateSmooth
        let lastIndex = times.size - 1

        var writeIndex: Int64 = 1

        for (i in 1..lastIndex) {
            var keep = false
            let time = times[i]
            let timeNext = times[i + 1]

            // 移除同一时间的相邻关键帧
            if (time != timeNext && (i != 1 || time != times[0])) {
                if (!smoothInterpolation) {
                    // 移除与相邻值相同的不必要关键帧
                    let offset = i * stride
                    let offsetP = offset - stride
                    let offsetN = offset + stride

                    for (j in 0..stride) {
                        let value = values[offset + j]
                        if (value != values[offsetP + j] || value != values[offsetN + j]) {
                            keep = true
                            break
                        }
                    }
                } else {
                    keep = true
                }
            }

            // 原地压缩
            if (keep) {
                if (i != writeIndex) {
                    times[writeIndex] = times[i]
                    let readOffset = i * stride
                    let writeOff = writeIndex * stride
                    for (j in 0..stride) {
                        values[writeOff + j] = values[readOffset + j]
                    }
                }
                writeIndex += 1
            }
        }

        // 刷新最后一个关键帧
        if (lastIndex > 0) {
            times[writeIndex] = times[lastIndex]
            let readOffset = lastIndex * stride
            let writeOff = writeIndex * stride
            for (j in 0..stride) {
                values[writeOff + j] = values[readOffset + j]
            }
            writeIndex += 1
        }

        if (writeIndex != times.size) {
            // 切片
            this.times = Array<Float64>(writeIndex, { i => times[i] })
            this.values = Array<Float64>(writeIndex * stride, { i => values[i] })
        } else {
            this.times = times
            this.values = values
        }

        return this
    }

    /**
     * @brief[zh-cn] 克隆轨道
     * @return[zh-cn] 返回一个新的轨道副本
     *
     * @brief[en] Clones the track
     * @return[en] Returns a new copy of the track
     */
    public func clone(): KeyframeTrack {
        let newTimes = Array<Float64>(this.times.size, { i => this.times[i] })
        let newValues = Array<Float64>(this.values.size, { i => this.values[i] })
        let track = KeyframeTrack(this.name, newTimes, newValues)
        track._interpolation = this._interpolation
        return track
    }
}
