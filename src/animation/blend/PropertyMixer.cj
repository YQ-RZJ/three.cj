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
 * @file[zh-cn] 属性混合器
 * @brief[zh-cn] 缓冲场景图属性，允许加权累积；内部使用
 * @explain[zh-cn] 
 * 缓冲区布局: [ incoming | accu0 | accu1 | orig | addAccu | (optional work) ]
 * - interpolators 可以使用 .buffer 作为 .result
 * - 数据然后进入 'incoming' 区域
 * - 'accu0' 和 'accu1' 用于帧交替累积结果，并比较以检测变化
 * - 'orig' 存储属性的原始状态
 * - 'add' 用于加法累积结果
 * - 'work' 是可选的，仅用于四元数类型，存储中间四元数乘法结果
 *
 * @file[en] Property Mixer
 * @brief[en] Buffers scene graph properties, allowing weighted accumulation; used internally
 * @explain[en] 
 * Buffer layout: [ incoming | accu0 | accu1 | orig | addAccu | (optional work) ]
 * - Interpolators may use .buffer as .result
 * - The data then goes into the 'incoming' region
 * - 'accu0' and 'accu1' are used for frame-alternating accumulated results, and are compared to detect changes
 * - 'orig' stores the original state of the property
 * - 'add' is used for additive accumulated results
 * - 'work' is optional, only used for quaternion types, and stores intermediate quaternion multiplication results
 */
package three.animation.blend

import three.core.math.Quaternion
import three.core.math.*

/**
 * @brief[zh-cn] 属性混合器，缓冲场景图属性，允许加权累积
 * @explain[zh-cn] 
 * 内部使用，为动画混合过程提供缓冲存储与加权累积、加法累积、应用与恢复状态等能力
 *
 * @brief[en] Property mixer that buffers scene graph properties and allows weighted accumulation
 * @explain[en] 
 * Used internally, providing buffered storage and capabilities for weighted accumulation, additive accumulation, applying and restoring state during the animation blending process
 */
public class PropertyMixer {
    /**
     * @brief[zh-cn] 属性绑定
     *
     * @brief[en] Property binding
     */
    internal var binding: PropertyBinding
    /**
     * @brief[zh-cn] 关键帧轨道值大小
     *
     * @brief[en] Keyframe track value size
     */
    internal var valueSize: Int64
    /**
     * @brief[zh-cn] 缓冲区
     *
     * @brief[en] Buffer
     */
    internal var buffer: Array<Float64>
    /**
     * @brief[zh-cn] 累积权重
     *
     * @brief[en] Cumulative weight
     */
    public var cumulativeWeight: Float64
    /**
     * @brief[zh-cn] 加法累积权重
     *
     * @brief[en] Cumulative additive weight
     */
    public var cumulativeWeightAdditive: Float64
    /**
     * @brief[zh-cn] 使用此属性绑定的活跃关键帧轨道数量
     *
     * @brief[en] Number of active keyframe tracks using this property binding
     */
    public var useCount: Int64
    /**
     * @brief[zh-cn] 引用此属性绑定的关键帧轨道数量
     *
     * @brief[en] Number of keyframe tracks referencing this property binding
     */
    public var referenceCount: Int64
    /**
     * @brief[zh-cn] 缓存索引（内存管理用）
     *
     * @brief[en] Cache index (for memory management)
     */
    internal var _cacheIndex: Option<Int64>
    /**
     * @brief[zh-cn] 类型名称（如 "quaternion"、"string"、"bool" 等）
     *
     * @brief[en] Type name (e.g. "quaternion", "string", "bool", etc.)
     */
    internal var typeName: String
    /**
     * @brief[zh-cn] 原始值在缓冲区中的索引偏移
     *
     * @brief[en] Index offset of the original value in the buffer
     */
    internal var _origIndex: Int64
    /**
     * @brief[zh-cn] 加法累积值在缓冲区中的索引偏移
     *
     * @brief[en] Index offset of the additive accumulation value in the buffer
     */
    internal var _addIndex: Int64
    /**
     * @brief[zh-cn] 工作区索引偏移（仅四元数使用）
     *
     * @brief[en] Workspace index offset (only used for quaternions)
     */
    internal var _workIndex: Int64

    /**
     * @brief[zh-cn] 构造一个新的属性混合器
     * @param[zh-cn] binding 属性绑定
     * @param[zh-cn] typeName 关键帧轨道类型名称
     * @param[zh-cn] valueSize 关键帧轨道值大小
     *
     * @brief[en] Constructs a new property mixer
     * @param[en] binding Property binding
     * @param[en] typeName Keyframe track type name
     * @param[en] valueSize Keyframe track value size
     */
    public init(binding: PropertyBinding, typeName: String, valueSize: Int64) {
        this.binding = binding
        this.valueSize = valueSize
        this.typeName = typeName

        // 根据类型名称选择混合函数和缓冲区大小
        if (typeName == "quaternion") {
            // 四元数：6 倍 valueSize（incoming + accu0 + accu1 + orig + addAccu + work）
            this.buffer = Array<Float64>(valueSize * 6, { _ => 0.0 })
            this._workIndex = 5
        } else if (typeName == "string" || typeName == "bool") {
            // 字符串/布尔：5 倍 valueSize（无 work 区）
            this.buffer = Array<Float64>(valueSize * 5, { _ => 0.0 })
            this._workIndex = -1
        } else {
            // 默认数值类型：5 倍 valueSize
            this.buffer = Array<Float64>(valueSize * 5, { _ => 0.0 })
            this._workIndex = -1
        }

        this._origIndex = 3
        this._addIndex = 4
        this.cumulativeWeight = 0.0
        this.cumulativeWeightAdditive = 0.0
        this.useCount = 0
        this.referenceCount = 0
        this._cacheIndex = None
    }

    /**
     * @brief[zh-cn] 将 incoming 区域的数据累积到 accu<i> 区域
     * @param[zh-cn] accuIndex 累积索引（0 或 1）
     * @param[zh-cn] weight 权重
     *
     * @brief[en] Accumulates data from the 'incoming' region into the accu<i> region
     * @param[en] accuIndex Accumulation index (0 or 1)
     * @param[en] weight Weight
     */
    public func accumulate(accuIndex: Int64, weight: Float64): Unit {
        // 注意：当 weight = 0 时也会累积，调用者知道权重
        // 不应在 weight = 0 时调用此方法

        let buffer = this.buffer
        let stride = this.valueSize
        let offset = accuIndex * stride + stride

        var currentWeight = this.cumulativeWeight

        if (currentWeight == 0.0) {
            // accuN := incoming * weight
            for (i in 0..stride) {
                buffer[offset + i] = buffer[i]
            }
            currentWeight = weight
        } else {
            // accuN := accuN + incoming * weight
            currentWeight += weight
            let mix = weight / currentWeight
            this._mixBufferRegion(buffer, offset, 0, mix, stride)
        }

        this.cumulativeWeight = currentWeight
    }

    /**
     * @brief[zh-cn] 将 incoming 区域的数据累积到 add（加法）区域
     * @param[zh-cn] weight 权重
     *
     * @brief[en] Accumulates data from the 'incoming' region into the add (additive) region
     * @param[en] weight Weight
     */
    public func accumulateAdditive(weight: Float64): Unit {
        let buffer = this.buffer
        let stride = this.valueSize
        let offset = stride * this._addIndex

        if (this.cumulativeWeightAdditive == 0.0) {
            // add = identity（设置加法恒等值）
            this._setIdentity()
        }

        // add := add + incoming * weight
        this._mixBufferRegionAdditive(buffer, offset, 0, weight, stride)
        this.cumulativeWeightAdditive += weight
    }

    /**
     * @brief[zh-cn] 当 accu 区域与原始值不同时，将 accu<i> 的状态应用到绑定
     * @param[zh-cn] accuIndex 累积索引
     *
     * @brief[en] Applies the state of the accu<i> region to the binding when it differs from the original value
     * @param[en] accuIndex Accumulation index
     */
    public func apply(accuIndex: Int64): Unit {
        let stride = this.valueSize
        let buffer = this.buffer
        let offset = accuIndex * stride + stride

        let weight = this.cumulativeWeight
        let weightAdditive = this.cumulativeWeightAdditive

        this.cumulativeWeight = 0.0
        this.cumulativeWeightAdditive = 0.0

        if (weight < 1.0) {
            // accuN := accuN + original * (1 - cumulativeWeight)
            let originalValueOffset = stride * this._origIndex
            this._mixBufferRegion(buffer, offset, originalValueOffset, 1.0 - weight, stride)
        }

        if (weightAdditive > 0.0) {
            // accuN := accuN + additive accuN
            this._mixBufferRegionAdditive(buffer, offset, this._addIndex * stride, 1.0, stride)
        }

        // 比较当前累积值与上一帧的累积值，检测变化
        for (i in stride..(stride + stride)) {
            if (buffer[i] != buffer[i + stride]) {
                // 值已变化 -> 更新场景图
                this.binding.setValue(buffer, offset)
                break
            }
        }
    }

    /**
     * @brief[zh-cn] 记住绑定属性的原始状态，并复制到两个累积区域
     *
     * @brief[en] Remembers the original state of the bound property and copies it into the two accumulation regions
     */
    public func saveOriginalState(): Unit {
        let binding = this.binding
        let buffer = this.buffer
        let stride = this.valueSize
        let originalValueOffset = stride * this._origIndex

        binding.getValue(buffer, originalValueOffset)

        // accu[0..1] := orig — 初始时与原始值比较以检测变化
        for (i in stride..originalValueOffset) {
            buffer[i] = buffer[originalValueOffset + (i % stride)]
        }

        // 设置加法恒等值
        this._setIdentity()

        this.cumulativeWeight = 0.0
        this.cumulativeWeightAdditive = 0.0
    }

    /**
     * @brief[zh-cn] 将之前通过 saveOriginalState 保存的状态恢复到绑定
     *
     * @brief[en] Restores the state previously saved via saveOriginalState to the binding
     */
    public func restoreOriginalState(): Unit {
        let originalValueOffset = this.valueSize * 3
        this.binding.setValue(this.buffer, originalValueOffset)
    }

    // === 内部方法 ===

    /**
     * @brief[zh-cn] 混合缓冲区区域（根据类型选择混合方式）
     * @param[zh-cn] buffer 缓冲区
     * @param[zh-cn] dstOffset 目标偏移
     * @param[zh-cn] srcOffset 源偏移
     * @param[zh-cn] t 混合因子
     * @param[zh-cn] stride 步长
     *
     * @brief[en] Mixes buffer regions (selects mixing method based on type)
     * @param[en] buffer Buffer
     * @param[en] dstOffset Destination offset
     * @param[en] srcOffset Source offset
     * @param[en] t Blend factor
     * @param[en] stride Stride
     */
    internal func _mixBufferRegion(buffer: Array<Float64>, dstOffset: Int64, srcOffset: Int64, t: Float64, stride: Int64): Unit {
        if (this.typeName == "quaternion") {
            this._slerp(buffer, dstOffset, srcOffset, t)
        } else if (this.typeName == "string" || this.typeName == "bool") {
            this._select(buffer, dstOffset, srcOffset, t, stride)
        } else {
            this._lerp(buffer, dstOffset, srcOffset, t, stride)
        }
    }

    /**
     * @brief[zh-cn] 加法混合缓冲区区域
     * @param[zh-cn] buffer 缓冲区
     * @param[zh-cn] dstOffset 目标偏移
     * @param[zh-cn] srcOffset 源偏移
     * @param[zh-cn] t 混合因子
     * @param[zh-cn] stride 步长
     *
     * @brief[en] Additive mix of buffer regions
     * @param[en] buffer Buffer
     * @param[en] dstOffset Destination offset
     * @param[en] srcOffset Source offset
     * @param[en] t Blend factor
     * @param[en] stride Stride
     */
    internal func _mixBufferRegionAdditive(buffer: Array<Float64>, dstOffset: Int64, srcOffset: Int64, t: Float64, stride: Int64): Unit {
        if (this.typeName == "quaternion") {
            this._slerpAdditive(buffer, dstOffset, srcOffset, t, stride)
        } else if (this.typeName == "string" || this.typeName == "bool") {
            this._select(buffer, dstOffset, srcOffset, t, stride)
        } else {
            this._lerpAdditive(buffer, dstOffset, srcOffset, t, stride)
        }
    }

    /**
     * @brief[zh-cn] 设置加法恒等值为数值零
     *
     * @brief[en] Sets the additive identity to numeric zero
     */
    internal func _setAdditiveIdentityNumeric(): Unit {
        let startIndex = this._addIndex * this.valueSize
        let endIndex = startIndex + this.valueSize
        for (i in startIndex..endIndex) {
            this.buffer[i] = 0.0
        }
    }

    /**
     * @brief[zh-cn] 设置加法恒等值为四元数单位 (0,0,0,1)
     *
     * @brief[en] Sets the additive identity to the quaternion identity (0,0,0,1)
     */
    internal func _setAdditiveIdentityQuaternion(): Unit {
        this._setAdditiveIdentityNumeric()
        this.buffer[this._addIndex * this.valueSize + 3] = 1.0
    }

    /**
     * @brief[zh-cn] 设置加法恒等值为原始值（用于非数值类型如 string/bool）
     *
     * @brief[en] Sets the additive identity to the original value (for non-numeric types like string/bool)
     */
    internal func _setAdditiveIdentityOther(): Unit {
        let startIndex = this._origIndex * this.valueSize
        let targetIndex = this._addIndex * this.valueSize
        for (i in 0..this.valueSize) {
            this.buffer[targetIndex + i] = this.buffer[startIndex + i]
        }
    }

    /**
     * @brief[zh-cn] 根据类型设置加法恒等值
     *
     * @brief[en] Sets the additive identity based on type
     */
    internal func _setIdentity(): Unit {
        if (this.typeName == "quaternion") {
            this._setAdditiveIdentityQuaternion()
        } else if (this.typeName == "string" || this.typeName == "bool") {
            this._setAdditiveIdentityOther()
        } else {
            this._setAdditiveIdentityNumeric()
        }
    }

    // === 混合函数 ===

    /**
     * @brief[zh-cn] 选择混合（用于 string/bool 类型）
     * @explain[zh-cn] 当 t >= 0.5 时，将源值复制到目标位置
     *
     * @brief[en] Select blending (for string/bool types)
     * @explain[en] When t >= 0.5, copies the source value to the destination position
     */
    internal func _select(buffer: Array<Float64>, dstOffset: Int64, srcOffset: Int64, t: Float64, stride: Int64): Unit {
        if (t >= 0.5) {
            for (i in 0..stride) {
                buffer[dstOffset + i] = buffer[srcOffset + i]
            }
        }
    }

    /**
     * @brief[zh-cn] 球面线性插值（用于四元数类型）
     *
     * @brief[en] Spherical linear interpolation (for quaternion types)
     */
    internal func _slerp(buffer: Array<Float64>, dstOffset: Int64, srcOffset: Int64, t: Float64): Unit {
        Quaternion.slerpFlat(buffer, dstOffset, buffer, dstOffset, buffer, srcOffset, t)
    }

    /**
     * @brief[zh-cn] 加法球面线性插值（用于四元数类型）
     * @explain[zh-cn] 先将目标与源相乘，再对结果进行球面插值
     *
     * @brief[en] Additive spherical linear interpolation (for quaternion types)
     * @explain[en] First multiplies the target with the source, then performs spherical interpolation on the result
     */
    internal func _slerpAdditive(buffer: Array<Float64>, dstOffset: Int64, srcOffset: Int64, t: Float64, stride: Int64): Unit {
        let workOffset = this._workIndex * stride
        // 在中间缓冲区存储乘法结果
        Quaternion.multiplyQuaternionsFlat(buffer, workOffset, buffer, dstOffset, buffer, srcOffset)
        // 对中间结果进行球面插值
        Quaternion.slerpFlat(buffer, dstOffset, buffer, dstOffset, buffer, workOffset, t)
    }

    /**
     * @brief[zh-cn] 线性插值（用于数值类型）
     * @explain[zh-cn] buffer[dst] = buffer[dst] * (1-t) + buffer[src] * t
     *
     * @brief[en] Linear interpolation (for numeric types)
     * @explain[en] buffer[dst] = buffer[dst] * (1-t) + buffer[src] * t
     */
    internal func _lerp(buffer: Array<Float64>, dstOffset: Int64, srcOffset: Int64, t: Float64, stride: Int64): Unit {
        let s = 1.0 - t
        for (i in 0..stride) {
            let j = dstOffset + i
            buffer[j] = buffer[j] * s + buffer[srcOffset + i] * t
        }
    }

    /**
     * @brief[zh-cn] 加法线性插值（用于数值类型）
     * @explain[zh-cn] buffer[dst] = buffer[dst] + buffer[src] * t
     *
     * @brief[en] Additive linear interpolation (for numeric types)
     * @explain[en] buffer[dst] = buffer[dst] + buffer[src] * t
     */
    internal func _lerpAdditive(buffer: Array<Float64>, dstOffset: Int64, srcOffset: Int64, t: Float64, stride: Int64): Unit {
        for (i in 0..stride) {
            let j = dstOffset + i
            buffer[j] = buffer[j] + buffer[srcOffset + i] * t
        }
    }
}
