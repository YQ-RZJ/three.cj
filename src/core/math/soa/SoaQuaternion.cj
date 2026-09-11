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
 * @file[zh-cn] SoaQuaternion
 * @brief[zh-cn] SoA 格式的四元组四元数
 * @explain[zh-cn] 将 4 个四元数的 x/y/z/w 分量分别连续存储，便于顺序遍历时保持 cache 友好性。
 *
 * @file[en] SoaQuaternion
 * @brief[en] Structure-of-Arrays layout for 4 quaternions
 * @explain[en] Stores x/y/z/w components of 4 quaternions contiguously for cache-friendly access.
 */
package three.core.math.soa

import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] SoA 四元数结构体，存储 4 个四元数
 * @explain[zh-cn] layout: [x0, x1, x2, x3, y0, y1, y2, y3, z0, z1, z2, z3, w0, w1, w2, w3]
 *
 * @brief[en] SoA quaternion struct storing 4 quaternions
 * @explain[en] Layout: [x0, x1, x2, x3, y0, y1, y2, y3, z0, z1, z2, z3, w0, w1, w2, w3]
 */
public class SoaQuaternion {
    /**
     * @brief[zh-cn] 4 个四元数的 x 分量
     *
     * @brief[en] x components of 4 quaternions
     */
    public var x: Array<Float32>

    /**
     * @brief[zh-cn] 4 个四元数的 y 分量
     *
     * @brief[en] y components of 4 quaternions
     */
    public var y: Array<Float32>

    /**
     * @brief[zh-cn] 4 个四元数的 z 分量
     *
     * @brief[en] z components of 4 quaternions
     */
    public var z: Array<Float32>

    /**
     * @brief[zh-cn] 4 个四元数的 w 分量
     *
     * @brief[en] w components of 4 quaternions
     */
    public var w: Array<Float32>

    /**
     * @brief[zh-cn] 默认构造函数，初始化为 4 个单位四元数
     *
     * @brief[en] Default constructor, initializes to 4 identity quaternions (0,0,0,1)
     */
    public init() {
        this.x = Array<Float32>(4, { _ => 0.0f32})
        this.y = Array<Float32>(4, { _ => 0.0f32})
        this.z = Array<Float32>(4, { _ => 0.0f32})
        this.w = Array<Float32>(4, { _ => 1.0f32})
    }

    /**
     * @brief[zh-cn] 从原始数组构造
     * @param[zh-cn] x x 分量数组（4 个元素）
     * @param[zh-cn] y y 分量数组（4 个元素）
     * @param[zh-cn] z z 分量数组（4 个元素）
     * @param[zh-cn] w w 分量数组（4 个元素）
     *
     * @brief[en] Construct from raw arrays
     * @param[en] x x-component array (4 elements)
     * @param[en] y y-component array (4 elements)
     * @param[en] z z-component array (4 elements)
     * @param[en] w w-component array (4 elements)
     */
    public init(x: Array<Float32>, y: Array<Float32>, z: Array<Float32>, w: Array<Float32>) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }

    // --- Slot accessors (slot = 0..3) ---

    /**
     * @brief[zh-cn] 获取指定槽位的四元数分量
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @return[zh-cn] (x, y, z, w)
     *
     * @brief[en] Get quaternion components for a given slot
     * @param[en] slot Slot index (0-3)
     * @return[en] (x, y, z, w)
     */
    public func get(slot: Int): QuaternionF {
        QuaternionF(this.x[slot], this.y[slot], this.z[slot], this.w[slot])
    }

    /**
     * @brief[zh-cn] 设置指定槽位的四元数分量
     * @param[zh-cn] slot 槽位索引 (0-3)
     * @param[zh-cn] qx x 分量
     * @param[zh-cn] qy y 分量
     * @param[zh-cn] qz z 分量
     * @param[zh-cn] qw w 分量
     *
     * @brief[en] Set quaternion components for a given slot
     * @param[en] slot Slot index (0-3)
     * @param[en] qx x component
     * @param[en] qy y component
     * @param[en] qz z component
     * @param[en] qw w component
     */
    public func set(slot: Int, qx: Float32, qy: Float32, qz: Float32, qw: Float32): Unit {
        this.x[slot] = qx
        this.y[slot] = qy
        this.z[slot] = qz
        this.w[slot] = qw
    }

    // --- Arithmetic operations (in-place) ---

    /**
     * @brief[zh-cn] 归一化：将 4 个四元数各自归一化
     *
     * @brief[en] Normalize all 4 quaternions in place
     */
    public func normalize(): Unit {
        for (i in 0..4) {
            let lenSq = this.x[i] * this.x[i] + this.y[i] * this.y[i] + this.z[i] * this.z[i] + this.w[i] * this.w[i]
            if (lenSq > 1e-12f32) {
                let invLen = 1.0f32/ sqrt(lenSq)
                this.x[i] *= invLen
                this.y[i] *= invLen
                this.z[i] *= invLen
                this.w[i] *= invLen
            }
        }
    }

    /**
     * @brief[zh-cn] 共轭：将 4 个四元数各自取共轭（-x, -y, -z, w）
     *
     * @brief[en] Conjugate all 4 quaternions in place
     */
    public func conjugate(): Unit {
        for (i in 0..4) {
            this.x[i] = -this.x[i]
            this.y[i] = -this.y[i]
            this.z[i] = -this.z[i]
        }
    }

    /**
     * @brief[zh-cn] 逐槽位乘法：this[i] = this[i] * rhs[i]
     * @param[zh-cn] rhs 右操作数
     *
     * @brief[en] Per-slot quaternion multiplication: this[i] = this[i] * rhs[i]
     * @param[en] rhs Right-hand operand
     */
    public func mul(rhs: SoaQuaternion): Unit {
        for (i in 0..4) {
            let lx = this.x[i]
            let ly = this.y[i]
            let lz = this.z[i]
            let lw = this.w[i]
            let rx = rhs.x[i]
            let ry = rhs.y[i]
            let rz = rhs.z[i]
            let rw = rhs.w[i]
            this.x[i] = lw * rx + lx * rw + ly * rz - lz * ry
            this.y[i] = lw * ry - lx * rz + ly * rw + lz * rx
            this.z[i] = lw * rz + lx * ry - ly * rx + lz * rw
            this.w[i] = lw * rw - lx * rx - ly * ry - lz * rz
        }
    }

    /**
     * @brief[zh-cn] 逐槽位 nlerp（归一化线性插值）
     * @param[zh-cn] rhs 右操作数
     * @param[zh-cn] t 插值因子数组（4 个元素，每个槽位独立）
     *
     * @brief[en] Per-slot normalized linear interpolation
     * @param[en] rhs Right-hand operand
     * @param[en] t Interpolation factor array (4 elements, independent per slot)
     */
    public static func nlerp(a: SoaQuaternion, b: SoaQuaternion, t: Array<Float32>): SoaQuaternion {
        var result = SoaQuaternion()
        for (i in 0..4) {
            // 确保取最短路径
            let dot = a.x[i] * b.x[i] + a.y[i] * b.y[i] + a.z[i] * b.z[i] + a.w[i] * b.w[i]
            let sign = if (dot < 0.0f32) { -1.0f32} else { 1.0f32}
            let ti = t[i]
            let ax = a.x[i]
            let ay = a.y[i]
            let az = a.z[i]
            let aw = a.w[i]
            let bx = b.x[i] * sign
            let by = b.y[i] * sign
            let bz = b.z[i] * sign
            let bw = b.w[i] * sign
            result.x[i] = ax + (bx - ax) * ti
            result.y[i] = ay + (by - ay) * ti
            result.z[i] = az + (bz - az) * ti
            result.w[i] = aw + (bw - aw) * ti
        }
        result.normalize()
        return result
    }

    // --- Static helpers ---

    /**
     * @brief[zh-cn] 创建 4 个单位四元数
     *
     * @brief[en] Create 4 identity quaternions
     */
    public static func identity(): SoaQuaternion {
        SoaQuaternion()
    }

    /**
     * @brief[zh-cn] 从 4 个单四元数值构造
     * @param[zh-cn] x0..w3 各四元数分量
     *
     * @brief[en] Construct from 4 individual quaternions
     * @param[en] x0..w3 Individual quaternion components
     */
    public static func fromFour(
        x0: Float32, y0: Float32, z0: Float32, w0: Float32,
        x1: Float32, y1: Float32, z1: Float32, w1: Float32,
        x2: Float32, y2: Float32, z2: Float32, w2: Float32,
        x3: Float32, y3: Float32, z3: Float32, w3: Float32
    ): SoaQuaternion {
        let xv = Array<Float32>(4, { _ => 0.0f32 })
        let yv = Array<Float32>(4, { _ => 0.0f32 })
        let zv = Array<Float32>(4, { _ => 0.0f32 })
        let wv = Array<Float32>(4, { _ => 0.0f32 })
        xv[0] = x0; xv[1] = x1; xv[2] = x2; xv[3] = x3
        yv[0] = y0; yv[1] = y1; yv[2] = y2; yv[3] = y3
        zv[0] = z0; zv[1] = z1; zv[2] = z2; zv[3] = z3
        wv[0] = w0; wv[1] = w1; wv[2] = w2; wv[3] = w3
        SoaQuaternion(xv, yv, zv, wv)
    }
}
