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
 * @file[zh-cn] Vector3F
 * @brief[zh-cn] Float32 精度的 3D 向量
 * @explain[zh-cn] 与 Vector3 (Float64) 功能等价，但使用 Float32 存储以减少内存占用。
 *                  主要用于骨骼动画内部计算。可与 Vector3 双向转换。
 *
 * @file[en] Vector3F
 * @brief[en] Float32-precision 3D vector
 * @explain[en] Equivalent to Vector3 (Float64) but uses Float32 storage for reduced memory.
 *              Primarily used for skeletal animation internal computation.
 */
package three.core.math

import std.math.*

/**
 * @brief[zh-cn] Float32 3D 向量类
 *
 * @brief[en] Float32 3D vector class
 */
public class Vector3F {
    public var x: Float32
    public var y: Float32
    public var z: Float32

    public init() {
        this.x = 0.0f32
        this.y = 0.0f32
        this.z = 0.0f32
    }

    public init(x: Float32, y: Float32, z: Float32) {
        this.x = x
        this.y = y
        this.z = z
    }

    // ===== Setters =====

    public func set(x: Float32, y: Float32, z: Float32): Vector3F {
        this.x = x
        this.y = y
        this.z = z
        return this
    }

    public func setScalar(s: Float32): Vector3F {
        this.x = s
        this.y = s
        this.z = s
        return this
    }

    public func setX(x: Float32): Vector3F {
        this.x = x
        return this
    }

    public func setY(y: Float32): Vector3F {
        this.y = y
        return this
    }

    public func setZ(z: Float32): Vector3F {
        this.z = z
        return this
    }

    public func clone(): Vector3F {
        Vector3F(this.x, this.y, this.z)
    }

    public func copy(v: Vector3F): Vector3F {
        this.x = v.x
        this.y = v.y
        this.z = v.z
        return this
    }

    // ===== Arithmetic =====

    public func add(v: Vector3F): Vector3F {
        this.x += v.x
        this.y += v.y
        this.z += v.z
        return this
    }

    public func addScalar(s: Float32): Vector3F {
        this.x += s
        this.y += s
        this.z += s
        return this
    }

    public func addVectors(a: Vector3F, b: Vector3F): Vector3F {
        this.x = a.x + b.x
        this.y = a.y + b.y
        this.z = a.z + b.z
        return this
    }

    public func addScaledVector(v: Vector3F, s: Float32): Vector3F {
        this.x += v.x * s
        this.y += v.y * s
        this.z += v.z * s
        return this
    }

    public func sub(v: Vector3F): Vector3F {
        this.x -= v.x
        this.y -= v.y
        this.z -= v.z
        return this
    }

    public func subScalar(s: Float32): Vector3F {
        this.x -= s
        this.y -= s
        this.z -= s
        return this
    }

    public func subVectors(a: Vector3F, b: Vector3F): Vector3F {
        this.x = a.x - b.x
        this.y = a.y - b.y
        this.z = a.z - b.z
        return this
    }

    public func multiply(v: Vector3F): Vector3F {
        this.x *= v.x
        this.y *= v.y
        this.z *= v.z
        return this
    }

    public func multiplyScalar(s: Float32): Vector3F {
        this.x *= s
        this.y *= s
        this.z *= s
        return this
    }

    public func divide(v: Vector3F): Vector3F {
        this.x /= v.x
        this.y /= v.y
        this.z /= v.z
        return this
    }

    public func divideScalar(s: Float32): Vector3F {
        let inv = 1.0f32/ s
        this.x *= inv
        this.y *= inv
        this.z *= inv
        return this
    }

    // ===== Products =====

    public func dot(v: Vector3F): Float32 {
        this.x * v.x + this.y * v.y + this.z * v.z
    }

    public func cross(v: Vector3F): Vector3F {
        let ax = this.x
        let ay = this.y
        let az = this.z
        this.x = ay * v.z - az * v.y
        this.y = az * v.x - ax * v.z
        this.z = ax * v.y - ay * v.x
        return this
    }

    public func crossVectors(a: Vector3F, b: Vector3F): Vector3F {
        this.x = a.y * b.z - a.z * b.y
        this.y = a.z * b.x - a.x * b.z
        this.z = a.x * b.y - a.y * b.x
        return this
    }

    // ===== Length =====

    public func lengthSq(): Float32 {
        this.x * this.x + this.y * this.y + this.z * this.z
    }

    public func length(): Float32 {
        sqrt(this.lengthSq())
    }

    public func normalize(): Vector3F {
        let len = this.length()
        if (len > 0.0f32) {
            this.divideScalar(len)
        }
        return this
    }

    public func setLength(length: Float32): Vector3F {
        this.normalize()
        this.multiplyScalar(length)
        return this
    }

    // ===== Distance =====

    public func distanceTo(v: Vector3F): Float32 {
        sqrt(this.distanceToSquared(v))
    }

    public func distanceToSquared(v: Vector3F): Float32 {
        let dx = this.x - v.x
        let dy = this.y - v.y
        let dz = this.z - v.z
        dx * dx + dy * dy + dz * dz
    }

    // ===== Interpolation =====

    public func lerp(v: Vector3F, alpha: Float32): Vector3F {
        this.x += (v.x - this.x) * alpha
        this.y += (v.y - this.y) * alpha
        this.z += (v.z - this.z) * alpha
        return this
    }

    public func lerpVectors(v1: Vector3F, v2: Vector3F, alpha: Float32): Vector3F {
        this.x = v1.x + (v2.x - v1.x) * alpha
        this.y = v1.y + (v2.y - v1.y) * alpha
        this.z = v1.z + (v2.z - v1.z) * alpha
        return this
    }

    // ===== Misc =====

    public func negate(): Vector3F {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        return this
    }

    public func equals(v: Vector3F): Bool {
        this.x == v.x && this.y == v.y && this.z == v.z
    }

    public func min(v: Vector3F): Vector3F {
        this.x = min(this.x, v.x)
        this.y = min(this.y, v.y)
        this.z = min(this.z, v.z)
        return this
    }

    public func max(v: Vector3F): Vector3F {
        this.x = max(this.x, v.x)
        this.y = max(this.y, v.y)
        this.z = max(this.z, v.z)
        return this
    }

    // ===== Conversion =====

    /**
     * @brief[zh-cn] 从 Vector3 (Float64) 转换为 Vector3F
     * @param[zh-cn] v Float64 向量
     * @return[zh-cn] Float32 向量
     *
     * @brief[en] Convert from Vector3 (Float64) to Vector3F
     * @param[en] v Float64 vector
     * @return[en] Float32 vector
     */
    public static func fromVector3(v: Vector3): Vector3F {
        Vector3F(Float32(v.x), Float32(v.y), Float32(v.z))
    }

    /**
     * @brief[zh-cn] 转换为 Array<Float32>（长度3）
     *
     * @brief[en] Convert to Array<Float32> (length 3)
     */
    public func toArray(): Array<Float32> {
        Array<Float32>(3, { i =>
            match (i) {
                case 0 => this.x
                case 1 => this.y
                case _ => this.z
            }
        })
    }

    /**
     * @brief[zh-cn] 从 Array<Float32>（长度3）构造
     *
     * @brief[en] Construct from Array<Float32> (length 3)
     */
    public static func fromArray(arr: Array<Float32>): Vector3F {
        Vector3F(arr[0], arr[1], arr[2])
    }
}
