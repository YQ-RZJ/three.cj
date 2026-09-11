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
 * @file[zh-cn] VecFloat
 * @brief[zh-cn] Float32 三分量向量操作工具集
 * @explain[zh-cn] 提供 Float32 精度的三分量向量基础运算（加减、点积、叉积、归一化、长度、lerp），
 *                  作为骨骼动画内部计算的轻量级向量工具。
 *
 * @file[en] VecFloat
 * @brief[en] Float32 3-component vector operations
 * @explain[en] Provides Float32-precision 3-component vector operations for skeletal animation internal computation.
 */
package three.core.math.soa

import std.math.*

/**
 * @brief[zh-cn] Float32 三分量向量工具对象
 * @explain[zh-cn] 所有方法为静态函数，接受 Array<Float32> 作为三分量向量（长度至少为3）。
 *
 * @brief[en] Float32 3-component vector utility object
 * @explain[en] All methods are static functions accepting Array<Float32> as a 3-component vector (length at least 3).
 */
public class VecFloat {
    /**
     * @brief[zh-cn] 加法：result = a + b
     * @param[zh-cn] a 左操作数（长度≥3）
     * @param[zh-cn] b 右操作数（长度≥3）
     * @return[zh-cn] 结果（长度3）
     *
     * @brief[en] Addition: result = a + b
     * @param[en] a Left operand (length >= 3)
     * @param[en] b Right operand (length >= 3)
     * @return[en] Result (length 3)
     */
    public func add(a: Array<Float32>, b: Array<Float32>): Array<Float32> {
        Array<Float32>(3, { i => a[i] + b[i] })
    }

    /**
     * @brief[zh-cn] 减法：result = a - b
     *
     * @brief[en] Subtraction: result = a - b
     */
    public func sub(a: Array<Float32>, b: Array<Float32>): Array<Float32> {
        Array<Float32>(3, { i => a[i] - b[i] })
    }

    /**
     * @brief[zh-cn] 标量乘法：result = v * s
     * @param[zh-cn] v 向量（长度≥3）
     * @param[zh-cn] s 标量
     * @return[zh-cn] 结果（长度3）
     *
     * @brief[en] Scalar multiplication: result = v * s
     * @param[en] v Vector (length >= 3)
     * @param[en] s Scalar
     * @return[en] Result (length 3)
     */
    public func scale(v: Array<Float32>, s: Float32): Array<Float32> {
        Array<Float32>(3, { i => v[i] * s })
    }

    /**
     * @brief[zh-cn] 点积：result = a·b
     * @return[zh-cn] Float32 标量结果
     *
     * @brief[en] Dot product: result = a·b
     * @return[en] Float32 scalar result
     */
    public func dot(a: Array<Float32>, b: Array<Float32>): Float32 {
        a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
    }

    /**
     * @brief[zh-cn] 叉积：result = a × b
     * @return[zh-cn] 结果（长度3）
     *
     * @brief[en] Cross product: result = a × b
     * @return[en] Result (length 3)
     */
    public func cross(a: Array<Float32>, b: Array<Float32>): Array<Float32> {
        Array<Float32>(3, { i =>
            match (i) {
                case 0 => a[1] * b[2] - a[2] * b[1]
                case 1 => a[2] * b[0] - a[0] * b[2]
                case _ => a[0] * b[1] - a[1] * b[0]
            }
        })
    }

    /**
     * @brief[zh-cn] 归一化：result = v / |v|
     * @param[zh-cn] v 向量（长度≥3）
     * @return[zh-cn] 归一化后的向量（长度3），若长度接近零则返回原向量
     *
     * @brief[en] Normalize: result = v / |v|
     * @param[en] v Vector (length >= 3)
     * @return[en] Normalized vector (length 3); returns the original vector if its length is near zero
     */
    public func normalize(v: Array<Float32>): Array<Float32> {
        let lenSq = v[0] * v[0] + v[1] * v[1] + v[2] * v[2]
        if (lenSq > 1e-12f32) {
            let invLen = 1.0f32/ sqrt(lenSq)
            Array<Float32>(3, { i => v[i] * invLen })
        } else {
            Array<Float32>(3, { i => v[i] })
        }
    }

    /**
     * @brief[zh-cn] 向量长度
     * @return[zh-cn] Float32 长度值
     *
     * @brief[en] Vector length
     * @return[en] Float32 length value
     */
    public func length(v: Array<Float32>): Float32 {
        sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])
    }

    /**
     * @brief[zh-cn] 向量长度的平方（避免开方）
     * @return[zh-cn] Float32 长度平方值
     *
     * @brief[en] Squared vector length (avoids square root)
     * @return[en] Float32 squared length value
     */
    public func lengthSq(v: Array<Float32>): Float32 {
        v[0] * v[0] + v[1] * v[1] + v[2] * v[2]
    }

    /**
     * @brief[zh-cn] 线性插值：result = a + (b - a) * t
     * @param[zh-cn] a 起始向量
     * @param[zh-cn] b 目标向量
     * @param[zh-cn] t 插值因子
     * @return[zh-cn] 插值结果（长度3）
     *
     * @brief[en] Linear interpolation: result = a + (b - a) * t
     * @param[en] a Start vector
     * @param[en] b Target vector
     * @param[en] t Interpolation factor
     * @return[en] Interpolation result (length 3)
     */
    public func lerp(a: Array<Float32>, b: Array<Float32>, t: Float32): Array<Float32> {
        Array<Float32>(3, { i => a[i] + (b[i] - a[i]) * t })
    }

    /**
     * @brief[zh-cn] 两点间距离
     * @param[zh-cn] a 起点
     * @param[zh-cn] b 终点
     * @return[zh-cn] Float32 距离值
     *
     * @brief[en] Distance between two points
     * @param[en] a Start point
     * @param[en] b End point
     * @return[en] Float32 distance value
     */
    public func distance(a: Array<Float32>, b: Array<Float32>): Float32 {
        let dx = b[0] - a[0]
        let dy = b[1] - a[1]
        let dz = b[2] - a[2]
        sqrt(dx * dx + dy * dy + dz * dz)
    }

    /**
     * @brief[zh-cn] 向量取反：result = -v
     *
     * @brief[en] Vector negation: result = -v
     */
    public func negate(v: Array<Float32>): Array<Float32> {
        Array<Float32>(3, { i => -v[i] })
    }

    /**
     * @brief[zh-cn] 逐元素最小值
     *
     * @brief[en] Element-wise minimum
     */
    public func min(a: Array<Float32>, b: Array<Float32>): Array<Float32> {
        Array<Float32>(3, { i => min(a[i], b[i]) })
    }

    /**
     * @brief[zh-cn] 逐元素最大值
     *
     * @brief[en] Element-wise maximum
     */
    public func max(a: Array<Float32>, b: Array<Float32>): Array<Float32> {
        Array<Float32>(3, { i => max(a[i], b[i]) })
    }

    /**
     * @brief[zh-cn] 零向量
     *
     * @brief[en] Zero vector
     */
    public static func zero(): Array<Float32> {
        Array<Float32>(3, { _ => 0.0f32})
    }

    /**
     * @brief[zh-cn] 单位向量 (1, 1, 1)
     *
     * @brief[en] Unit vector (1, 1, 1)
     */
    public static func one(): Array<Float32> {
        Array<Float32>(3, { _ => 1.0f32})
    }
}
