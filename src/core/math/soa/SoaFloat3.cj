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
 * @file[zh-cn] SoaFloat3
 * @brief[zh-cn] SoA 格式的四元组三分量向量
 * @explain[zh-cn] 将 4 个三分量向量的 x/y/z 分量分别连续存储，便于顺序遍历时保持 cache 友好性。
 *
 * @file[en] SoaFloat3
 * @brief[en] Structure-of-Arrays layout for 4 float3 vectors
 * @explain[en] Stores x/y/z components of 4 vectors contiguously for cache-friendly access.
 */
package three.core.math.soa

import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] SoA 三分量向量结构体，存储 4 个向量
 * @explain[zh-cn] layout: [x0, x1, x2, x3, y0, y1, y2, y3, z0, z1, z2, z3]
 *
 * @brief[en] SoA float3 struct storing 4 vectors
 * @explain[en] Layout: [x0, x1, x2, x3, y0, y1, y2, y3, z0, z1, z2, z3]
 */
public class SoaFloat3 {
    /**
     * @brief[zh-cn] 4 个向量的 x 分量
     *
     * @brief[en] x components of 4 vectors
     */
    public var x: Array<Float32>

    /**
     * @brief[zh-cn] 4 个向量的 y 分量
     *
     * @brief[en] y components of 4 vectors
     */
    public var y: Array<Float32>

    /**
     * @brief[zh-cn] 4 个向量的 z 分量
     *
     * @brief[en] z components of 4 vectors
     */
    public var z: Array<Float32>

    /**
     * @brief[zh-cn] 默认构造函数，初始化为零向量
     *
     * @brief[en] Default constructor, initializes to zero vectors
     */
    public init() {
        this.x = Array<Float32>(4, { _ => 0.0f32})
        this.y = Array<Float32>(4, { _ => 0.0f32})
        this.z = Array<Float32>(4, { _ => 0.0f32})
    }

    /**
     * @brief[zh-cn] 从原始数组构造
     * @param[zh-cn] x x 分量数组（4 个元素）
     * @param[zh-cn] y y 分量数组（4 个元素）
     * @param[zh-cn] z z 分量数组（4 个元素）
     *
     * @brief[en] Construct from raw arrays
     * @param[en] x x-component array (4 elements)
     * @param[en] y y-component array (4 elements)
     * @param[en] z z-component array (4 elements)
     */
    public init(x: Array<Float32>, y: Array<Float32>, z: Array<Float32>) {
        this.x = x
        this.y = y
        this.z = z
    }

    // --- Slot accessors ---

    /**
     * @brief[zh-cn] 获取指定槽位的三分量向量
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @return[zh-cn] (x, y, z)
     *
     * @brief[en] Get the float3 vector for a given slot
     * @param[en] slot Slot index (0-3)
     * @return[en] (x, y, z)
     */
    public func get(slot: Int): Vector3F {
        Vector3F(this.x[slot], this.y[slot], this.z[slot])
    }

    /**
     * @brief[zh-cn] 设置指定槽位的三分量向量
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @param[zh-cn] vx x 分量
     * @param[zh-cn] vy y 分量
     * @param[zh-cn] vz z 分量
     *
     * @brief[en] Set the float3 vector for a given slot
     * @param[en] slot Slot index (0-3)
     * @param[en] vx x component
     * @param[en] vy y component
     * @param[en] vz z component
     */
    public func set(slot: Int, vx: Float32, vy: Float32, vz: Float32): Unit {
        this.x[slot] = vx
        this.y[slot] = vy
        this.z[slot] = vz
    }

    // --- Arithmetic operations (in-place) ---

    /**
     * @brief[zh-cn] 加法：this += rhs（逐元素）
     *
     * @brief[en] Add rhs element-wise
     */
    public func add(rhs: SoaFloat3): Unit {
        for (i in 0..4) {
            this.x[i] += rhs.x[i]
            this.y[i] += rhs.y[i]
            this.z[i] += rhs.z[i]
        }
    }

    /**
     * @brief[zh-cn] 减法：this -= rhs（逐元素）
     *
     * @brief[en] Subtract rhs element-wise
     */
    public func sub(rhs: SoaFloat3): Unit {
        for (i in 0..4) {
            this.x[i] -= rhs.x[i]
            this.y[i] -= rhs.y[i]
            this.z[i] -= rhs.z[i]
        }
    }

    /**
     * @brief[zh-cn] 标量乘法：this *= scalar（逐元素）
     *
     * @brief[en] Multiply by scalar element-wise
     */
    public func scale(scalar: Float32): Unit {
        for (i in 0..4) {
            this.x[i] *= scalar
            this.y[i] *= scalar
            this.z[i] *= scalar
        }
    }

    /**
     * @brief[zh-cn] 逐槽位点积，返回 4 个点积结果
     * @param[zh-cn] rhs 右操作数
     * @return[zh-cn] SimdFloat 包含 4 个点积值
     *
     * @brief[en] Per-slot dot product, returns 4 results as SimdFloat
     * @param[en] rhs Right-hand operand
     * @return[en] SimdFloat containing the 4 dot product values
     */
    public func dot(rhs: SoaFloat3): SimdFloat {
        let result = SimdFloat()
        for (i in 0..4) {
            result.values[i] = this.x[i] * rhs.x[i] + this.y[i] * rhs.y[i] + this.z[i] * rhs.z[i]
        }
        return result
    }

    /**
     * @brief[zh-cn] 逐槽位叉积
     * @param[zh-cn] rhs 右操作数
     * @return[zh-cn] SoaFloat3 包含 4 个叉积结果
     *
     * @brief[en] Per-slot cross product
     * @param[en] rhs Right-hand operand
     * @return[en] SoaFloat3 containing the 4 cross product results
     */
    public func cross(rhs: SoaFloat3): SoaFloat3 {
        let result = SoaFloat3()
        for (i in 0..4) {
            result.x[i] = this.y[i] * rhs.z[i] - this.z[i] * rhs.y[i]
            result.y[i] = this.z[i] * rhs.x[i] - this.x[i] * rhs.z[i]
            result.z[i] = this.x[i] * rhs.y[i] - this.y[i] * rhs.x[i]
        }
        return result
    }

    /**
     * @brief[zh-cn] 逐槽位归一化
     *
     * @brief[en] Normalize all 4 vectors in place
     */
    public func normalize(): Unit {
        for (i in 0..4) {
            let lenSq = this.x[i] * this.x[i] + this.y[i] * this.y[i] + this.z[i] * this.z[i]
            if (lenSq > 1e-12f32) {
                let invLen = 1.0f32/ sqrt(lenSq)
                this.x[i] *= invLen
                this.y[i] *= invLen
                this.z[i] *= invLen
            }
        }
    }

    /**
     * @brief[zh-cn] 逐槽位取反
     *
     * @brief[en] Negate all 4 vectors
     */
    public func negate(): Unit {
        for (i in 0..4) {
            this.x[i] = -this.x[i]
            this.y[i] = -this.y[i]
            this.z[i] = -this.z[i]
        }
    }

    /**
     * @brief[zh-cn] 逐槽位 length（向量长度）
     * @return[zh-cn] SimdFloat 包含 4 个长度值
     *
     * @brief[en] Per-slot vector length
     * @return[en] SimdFloat containing the 4 length values
     */
    public func length(): SimdFloat {
        this.dot(this).sqrt()
    }

    // --- Static helpers ---

    /**
     * @brief[zh-cn] 创建零向量
     *
     * @brief[en] Create zero vectors
     */
    public static func zero(): SoaFloat3 {
        SoaFloat3()
    }

    /**
     * @brief[zh-cn] 从 4 个单向量构造
     * @param[zh-cn] x0..z3 各向量分量
     *
     * @brief[en] Construct from 4 individual float3 vectors
     * @param[en] x0..z3 Individual vector components
     */
    public static func fromFour(
        x0: Float32, y0: Float32, z0: Float32,
        x1: Float32, y1: Float32, z1: Float32,
        x2: Float32, y2: Float32, z2: Float32,
        x3: Float32, y3: Float32, z3: Float32
    ): SoaFloat3 {
        let xv = Array<Float32>(4, { _ => 0.0f32 })
        let yv = Array<Float32>(4, { _ => 0.0f32 })
        let zv = Array<Float32>(4, { _ => 0.0f32 })
        xv[0] = x0; xv[1] = x1; xv[2] = x2; xv[3] = x3
        yv[0] = y0; yv[1] = y1; yv[2] = y2; yv[3] = y3
        zv[0] = z0; zv[1] = z1; zv[2] = z2; zv[3] = z3
        SoaFloat3(xv, yv, zv)
    }

    /**
     * @brief[zh-cn] 线性插值：result = a + (b - a) * t
     * @param[zh-cn] a 起始值
     * @param[zh-cn] b 目标值
     * @param[zh-cn] t 插值因子（SimdFloat，每槽独立）
     * @return[zh-cn] 插值结果
     *
     * @brief[en] Per-slot linear interpolation: result = a + (b - a) * t
     * @param[en] a Start value
     * @param[en] b Target value
     * @param[en] t Interpolation factor (SimdFloat, independent per slot)
     * @return[en] Interpolation result
     */
    public static func lerp(a: SoaFloat3, b: SoaFloat3, t: SimdFloat): SoaFloat3 {
        let result = SoaFloat3()
        for (i in 0..4) {
            let ti = t.values[i]
            result.x[i] = a.x[i] + (b.x[i] - a.x[i]) * ti
            result.y[i] = a.y[i] + (b.y[i] - a.y[i]) * ti
            result.z[i] = a.z[i] + (b.z[i] - a.z[i]) * ti
        }
        return result
    }
}
