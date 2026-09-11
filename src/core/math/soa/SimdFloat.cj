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
 * @file[zh-cn] SimdFloat
 * @brief[zh-cn] 4-wide 标量浮点数模拟
 * @explain[zh-cn] 将 4 个 Float32 值打包在一起，通过标量循环模拟 SIMD lanes 的行为。
 *                  用于 SoA 数学运算的中间结果传递。
 *
 * @file[en] SimdFloat
 * @brief[en] 4-wide scalar float simulation
 * @explain[en] Packs 4 Float32 values together, simulating SIMD lanes via scalar loops.
 *              Used for intermediate results in SoA math operations.
 */
package three.core.math.soa

import std.math.*

/**
 * @brief[zh-cn] 4-wide 标量浮点数
 * @explain[zh-cn] 每个算术操作对 4 个 lane 独立执行。命名使用 Float32 以匹配 ozz 的 SimdFloat4 接口。
 *
 * @brief[en] 4-wide scalar float
 * @explain[en] Each arithmetic operation executes independently on the 4 lanes. Named with Float32 to match ozz's SimdFloat4 interface.
 */
public class SimdFloat {
    /**
     * @brief[zh-cn] 4 个 lane 的值
     *
     * @brief[en] Values for the 4 lanes
     */
    public var values: Array<Float32>

    /**
     * @brief[zh-cn] 默认构造函数，初始化为零
     *
     * @brief[en] Default constructor, initializes to zero
     */
    public init() {
        this.values = Array<Float32>(4, { _ => 0.0f32})
    }

    /**
     * @brief[zh-cn] 从标量值构造（4 个 lane 相同）
     * @param[zh-cn] scalar 标量值
     *
     * @brief[en] Construct from a scalar (same value in all 4 lanes)
     * @param[en] scalar Scalar value
     */
    public init(scalar: Float32) {
        this.values = Array<Float32>(4, { _ => scalar })
    }

    /**
     * @brief[zh-cn] 从原始数组构造
     * @param[zh-cn] values 4 个元素的数组
     *
     * @brief[en] Construct from raw array
     * @param[en] values Array of 4 elements
     */
    public init(values: Array<Float32>) {
        this.values = values
    }

    // --- Arithmetic operations ---

    /**
     * @brief[zh-cn] 加法：this = this + rhs
     *
     * @brief[en] Addition: this = this + rhs
     */
    public func add(rhs: SimdFloat): Unit {
        for (i in 0..4) {
            this.values[i] += rhs.values[i]
        }
    }

    /**
     * @brief[zh-cn] 减法：this = this - rhs
     *
     * @brief[en] Subtraction: this = this - rhs
     */
    public func sub(rhs: SimdFloat): Unit {
        for (i in 0..4) {
            this.values[i] -= rhs.values[i]
        }
    }

    /**
     * @brief[zh-cn] 乘法：this = this * rhs
     *
     * @brief[en] Multiplication: this = this * rhs
     */
    public func mul(rhs: SimdFloat): Unit {
        for (i in 0..4) {
            this.values[i] *= rhs.values[i]
        }
    }

    /**
     * @brief[zh-cn] 标量乘法：this = this * scalar
     *
     * @brief[en] Scalar multiplication: this = this * scalar
     */
    public func mulScalar(scalar: Float32): Unit {
        for (i in 0..4) {
            this.values[i] *= scalar
        }
    }

    /**
     * @brief[zh-cn] 逐 lane 取最小值
     *
     * @brief[en] Per-lane minimum
     */
    public func min(rhs: SimdFloat): Unit {
        for (i in 0..4) {
            if (this.values[i] > rhs.values[i]) { this.values[i] = rhs.values[i] }
        }
    }

    /**
     * @brief[zh-cn] 逐 lane 取最大值
     *
     * @brief[en] Per-lane maximum
     */
    public func max(rhs: SimdFloat): Unit {
        for (i in 0..4) {
            if (this.values[i] < rhs.values[i]) { this.values[i] = rhs.values[i] }
        }
    }

    /**
     * @brief[zh-cn] 逐 lane 平方根
     *
     * @brief[en] Per-lane square root
     */
    public func sqrt(): SimdFloat {
        let result = SimdFloat()
        for (i in 0..4) {
            result.values[i] = sqrt(this.values[i])
        }
        return result
    }

    /**
     * @brief[zh-cn] 逐 lane 取反
     *
     * @brief[en] Per-lane negation
     */
    public func negate(): SimdFloat {
        let result = SimdFloat()
        for (i in 0..4) {
            result.values[i] = -this.values[i]
        }
        return result
    }

    // --- Comparison ---

    /**
     * @brief[zh-cn] 逐 lane 小于比较
     * @return[zh-cn] SimdFloat，结果为 1.0f32或 0.0f
     *
     * @brief[en] Per-lane less-than comparison
     * @return[en] SimdFloat with results of 1.0f32 or 0.0f32
     */
    public func lessThan(rhs: SimdFloat): SimdFloat {
        let result = SimdFloat()
        for (i in 0..4) {
            result.values[i] = if (this.values[i] < rhs.values[i]) { 1.0f32} else { 0.0f32}
        }
        return result
    }

    /**
     * @brief[zh-cn] 逐 lane 大于比较
     * @return[zh-cn] SimdFloat，结果为 1.0f32或 0.0f
     *
     * @brief[en] Per-lane greater-than comparison
     * @return[en] SimdFloat with results of 1.0f32 or 0.0f32
     */
    public func greaterThan(rhs: SimdFloat): SimdFloat {
        let result = SimdFloat()
        for (i in 0..4) {
            result.values[i] = if (this.values[i] > rhs.values[i]) { 1.0f32} else { 0.0f32}
        }
        return result
    }

    // --- Static helpers ---

    /**
     * @brief[zh-cn] 创建全零
     *
     * @brief[en] Creates all zeros
     */
    public static func zero(): SimdFloat {
        SimdFloat(Array<Float32>(4, { _ => 0.0f32 }))
    }

    /**
     * @brief[zh-cn] 创建全一
     *
     * @brief[en] Creates all ones
     */
    public static func one(): SimdFloat {
        SimdFloat(Array<Float32>(4, { _ => 1.0f32 }))
    }

    /**
     * @brief[zh-cn] 逐 lane 线性插值：result = a + (b - a) * t
     * @param[zh-cn] a 起始值
     * @param[zh-cn] b 目标值
     * @param[zh-cn] t 插值因子
     * @return[zh-cn] 插值结果
     *
     * @brief[en] Per-lane linear interpolation: result = a + (b - a) * t
     * @param[en] a Start value
     * @param[en] b Target value
     * @param[en] t Interpolation factor
     * @return[en] Interpolation result
     */
    public static func lerp(a: SimdFloat, b: SimdFloat, t: SimdFloat): SimdFloat {
        let result = SimdFloat()
        for (i in 0..4) {
            result.values[i] = a.values[i] + (b.values[i] - a.values[i]) * t.values[i]
        }
        return result
    }

    /**
     * @brief[zh-cn] 从 4 个标量值构造
     * @param[zh-cn] v0 lane 0
     * @param[zh-cn] v1 lane 1
     * @param[zh-cn] v2 lane 2
     * @param[zh-cn] v3 lane 3
     *
     * @brief[en] Construct from 4 scalar values
     * @param[en] v0 Lane 0
     * @param[en] v1 Lane 1
     * @param[en] v2 Lane 2
     * @param[en] v3 Lane 3
     */
    public static func fromFour(v0: Float32, v1: Float32, v2: Float32, v3: Float32): SimdFloat {
        let arr = Array<Float32>(4, { _ => 0.0f32 })
        arr[0] = v0
        arr[1] = v1
        arr[2] = v2
        arr[3] = v3
        SimdFloat(arr)
    }
}
