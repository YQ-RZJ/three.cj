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
 * @file[zh-cn] Vector4F
 * @brief[zh-cn] Float32 精度的 4D 向量
 * @explain[zh-cn] 与 Vector4 (Float64) 功能等价，但使用 Float32 存储以减少内存占用。
 *
 * @file[en] Vector4F
 * @brief[en] Float32-precision 4D vector
 * @explain[en] Equivalent to Vector4 (Float64) but uses Float32 storage.
 */
package three.core.math

import std.math.*

/**
 * @brief[zh-cn] Float32 4D 向量类
 *
 * @brief[en] Float32 4D vector class
 */
public class Vector4F {
    public var x: Float32
    public var y: Float32
    public var z: Float32
    public var w: Float32

    public init() {
        this.x = 0.0f32
        this.y = 0.0f32
        this.z = 0.0f32
        this.w = 1.0f32
    }

    public init(x: Float32, y: Float32, z: Float32, w: Float32) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }

    // ===== Setters =====

    public func set(x: Float32, y: Float32, z: Float32, w: Float32): Vector4F {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
        return this
    }

    public func setScalar(s: Float32): Vector4F {
        this.x = s
        this.y = s
        this.z = s
        this.w = s
        return this
    }

    public func clone(): Vector4F {
        Vector4F(this.x, this.y, this.z, this.w)
    }

    public func copy(v: Vector4F): Vector4F {
        this.x = v.x
        this.y = v.y
        this.z = v.z
        this.w = v.w
        return this
    }

    // ===== Arithmetic =====

    public func add(v: Vector4F): Vector4F {
        this.x += v.x
        this.y += v.y
        this.z += v.z
        this.w += v.w
        return this
    }

    public func addScalar(s: Float32): Vector4F {
        this.x += s
        this.y += s
        this.z += s
        this.w += s
        return this
    }

    public func sub(v: Vector4F): Vector4F {
        this.x -= v.x
        this.y -= v.y
        this.z -= v.z
        this.w -= v.w
        return this
    }

    public func subScalar(s: Float32): Vector4F {
        this.x -= s
        this.y -= s
        this.z -= s
        this.w -= s
        return this
    }

    public func multiply(v: Vector4F): Vector4F {
        this.x *= v.x
        this.y *= v.y
        this.z *= v.z
        this.w *= v.w
        return this
    }

    public func multiplyScalar(s: Float32): Vector4F {
        this.x *= s
        this.y *= s
        this.z *= s
        this.w *= s
        return this
    }

    public func divideScalar(s: Float32): Vector4F {
        let inv = 1.0f32/ s
        this.x *= inv
        this.y *= inv
        this.z *= inv
        this.w *= inv
        return this
    }

    // ===== Products =====

    public func dot(v: Vector4F): Float32 {
        this.x * v.x + this.y * v.y + this.z * v.z + this.w * v.w
    }

    public func lengthSq(): Float32 {
        this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w
    }

    public func length(): Float32 {
        sqrt(this.lengthSq())
    }

    public func normalize(): Vector4F {
        let len = this.length()
        if (len > 0.0f32) {
            this.divideScalar(len)
        }
        return this
    }

    // ===== Interpolation =====

    public func lerp(v: Vector4F, alpha: Float32): Vector4F {
        this.x += (v.x - this.x) * alpha
        this.y += (v.y - this.y) * alpha
        this.z += (v.z - this.z) * alpha
        this.w += (v.w - this.w) * alpha
        return this
    }

    // ===== Misc =====

    public func negate(): Vector4F {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        this.w = -this.w
        return this
    }

    public func equals(v: Vector4F): Bool {
        this.x == v.x && this.y == v.y && this.z == v.z && this.w == v.w
    }

    // ===== Conversion =====

    /**
     * @brief[zh-cn] 转换为 Array<Float32>（长度4）
     *
     * @brief[en] Convert to Array<Float32> (length 4)
     */
    public func toArray(): Array<Float32> {
        Array<Float32>(4, { i =>
            match (i) {
                case 0 => this.x
                case 1 => this.y
                case 2 => this.z
                case _ => this.w
            }
        })
    }

    /**
     * @brief[zh-cn] 从 Array<Float32>（长度4）构造
     *
     * @brief[en] Construct from Array<Float32> (length 4)
     */
    public static func fromArray(arr: Array<Float32>): Vector4F {
        Vector4F(arr[0], arr[1], arr[2], arr[3])
    }
}
