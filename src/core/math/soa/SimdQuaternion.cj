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
 * @file[zh-cn] SimdQuaternion
 * @brief[zh-cn] 4-wide 标量四元数模拟
 * @explain[zh-cn] 将 4 个四元数打包在一起，通过标量循环模拟 SIMD lanes 的行为。
 *                  用于 SoA 四元数运算的中间结果传递。
 *
 * @file[en] SimdQuaternion
 * @brief[en] 4-wide scalar quaternion simulation
 * @explain[en] Packs 4 quaternions together, simulating SIMD lanes via scalar loops.
 */
package three.core.math.soa

import std.math.*

/**
 * @brief[zh-cn] 4-wide 标量四元数
 *
 * @brief[en] 4-wide scalar quaternion
 */
public class SimdQuaternion {
    /**
     * @brief[zh-cn] 4 个 lane 的 x 分量
     *
     * @brief[en] x components of the 4 lanes
     */
    public var x: Array<Float32>

    /**
     * @brief[zh-cn] 4 个 lane 的 y 分量
     *
     * @brief[en] y components of the 4 lanes
     */
    public var y: Array<Float32>

    /**
     * @brief[zh-cn] 4 个 lane 的 z 分量
     *
     * @brief[en] z components of the 4 lanes
     */
    public var z: Array<Float32>

    /**
     * @brief[zh-cn] 4 个 lane 的 w 分量
     *
     * @brief[en] w components of the 4 lanes
     */
    public var w: Array<Float32>

    /**
     * @brief[zh-cn] 默认构造函数，初始化为 4 个单位四元数
     *
     * @brief[en] Default constructor, initializes to 4 identity quaternions
     */
    public init() {
        this.x = Array<Float32>(4, { _ => 0.0f32})
        this.y = Array<Float32>(4, { _ => 0.0f32})
        this.z = Array<Float32>(4, { _ => 0.0f32})
        this.w = Array<Float32>(4, { _ => 1.0f32})
    }

    /**
     * @brief[zh-cn] 从原始数组构造
     *
     * @brief[en] Construct from raw arrays
     */
    public init(x: Array<Float32>, y: Array<Float32>, z: Array<Float32>, w: Array<Float32>) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }

    // --- Arithmetic operations (in-place) ---

    /**
     * @brief[zh-cn] 归一化：将 4 个四元数各自归一化
     *
     * @brief[en] Normalize: normalizes each of the 4 quaternions
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
     * @brief[en] Conjugate: conjugates each of the 4 quaternions (-x, -y, -z, w)
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
     *
     * @brief[en] Per-slot multiplication: this[i] = this[i] * rhs[i]
     */
    public func mul(rhs: SimdQuaternion): Unit {
        for (i in 0..4) {
            let lx = this.x[i]
            let ly = this.y[i]
            let lz = this.z[i]
            let lw = this.w[i]
            let rx = rhs.x[i]
            let ry = rhs.y[i]
            let rz = rhs.z[i]
            let rw = rhs.w[i]
            // Hamilton product: this = this * rhs
            this.x[i] = lw * rx + lx * rw + ly * rz - lz * ry
            this.y[i] = lw * ry - lx * rz + ly * rw + lz * rx
            this.z[i] = lw * rz + lx * ry - ly * rx + lz * rw
            this.w[i] = lw * rw - lx * rx - ly * ry - lz * rz
        }
    }

    // --- Static helpers ---

    /**
     * @brief[zh-cn] 创建 4 个单位四元数
     *
     * @brief[en] Creates 4 identity quaternions
     */
    public static func identity(): SimdQuaternion {
        SimdQuaternion()
    }

    /**
     * @brief[zh-cn] 从 4 个单四元数值构造
     * @param[zh-cn] x0..w3 各四元数分量
     *
     * @brief[en] Construct from 4 individual quaternion values
     * @param[en] x0..w3 Individual quaternion components
     */
    public static func fromFour(
        x0: Float32, y0: Float32, z0: Float32, w0: Float32,
        x1: Float32, y1: Float32, z1: Float32, w1: Float32,
        x2: Float32, y2: Float32, z2: Float32, w2: Float32,
        x3: Float32, y3: Float32, z3: Float32, w3: Float32
    ): SimdQuaternion {
        let xv = Array<Float32>(4, { _ => 0.0f32 })
        let yv = Array<Float32>(4, { _ => 0.0f32 })
        let zv = Array<Float32>(4, { _ => 0.0f32 })
        let wv = Array<Float32>(4, { _ => 0.0f32 })
        xv[0] = x0; xv[1] = x1; xv[2] = x2; xv[3] = x3
        yv[0] = y0; yv[1] = y1; yv[2] = y2; yv[3] = y3
        zv[0] = z0; zv[1] = z1; zv[2] = z2; zv[3] = z3
        wv[0] = w0; wv[1] = w1; wv[2] = w2; wv[3] = w3
        SimdQuaternion(xv, yv, zv, wv)
    }

    public static func fromSoa(soa: SoaQuaternion): SimdQuaternion {
        SimdQuaternion(
            Array<Float32>(4, { i => soa.x[i] }),
            Array<Float32>(4, { i => soa.y[i] }),
            Array<Float32>(4, { i => soa.z[i] }),
            Array<Float32>(4, { i => soa.w[i] })
        )
    }

    public func toSoa(): SoaQuaternion {
        SoaQuaternion(
            Array<Float32>(4, { i => this.x[i] }),
            Array<Float32>(4, { i => this.y[i] }),
            Array<Float32>(4, { i => this.z[i] }),
            Array<Float32>(4, { i => this.w[i] })
        )
    }

    public static func splat(qx: Float32, qy: Float32, qz: Float32, qw: Float32): SimdQuaternion {
        SimdQuaternion(
            Array<Float32>(4, { _ => qx }),
            Array<Float32>(4, { _ => qy }),
            Array<Float32>(4, { _ => qz }),
            Array<Float32>(4, { _ => qw })
        )
    }
}
