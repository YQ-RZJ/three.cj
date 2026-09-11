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
 * @file[zh-cn] Vector3
 * @brief[zh-cn] 3D 向量
 * @explain[zh-cn] 表示三维空间中的点或方向向量。
 *
 * @file[en] Vector3
 * @brief[en] 3D vector
 * @explain[en] Represents a point or direction vector in 3D space.
 */
package three.core.math

import std.math.*
import std.random.*
import three.core.interfaces.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 3D 向量类，表示有序三元组 (x, y, z)
 * @explain[zh-cn] 可用于表示三维空间中的点、方向和长度，或任意有序三元组。
 *
 * @brief[en] 3D vector class, represents an ordered triple (x, y, z)
 * @explain[en] Can be used to represent points, directions and lengths in 3D space, or any ordered triple.
 */
@JsonAdapter
public class Vector3 {
    /**
     * @brief[zh-cn] x 分量
     *
     * @brief[en] x component
     */
    public var x: Float64
    /**
     * @brief[zh-cn] y 分量
     *
     * @brief[en] y component
     */
    public var y: Float64
    /**
     * @brief[zh-cn] z 分量
     *
     * @brief[en] z component
     */
    public var z: Float64

    /**
     * @brief[zh-cn] 默认构造函数，初始化为零向量 (0, 0, 0)
     *
     * @brief[en] Default constructor, initializes to zero vector (0, 0, 0)
     */
    public init() {
        this.x = 0.0
        this.y = 0.0
        this.z = 0.0
    }

    /**
     * @brief[zh-cn] 使用指定分量值构造向量
     * @param[zh-cn] x x 分量值
     * y y 分量值
     * z z 分量值
     *
     * @brief[en] Constructs a vector with specified component values
     * @param[en] x x component value
     * y y component value
     * z z component value
     */
    public init(x: Float64, y: Float64, z: Float64) {
        this.x = x
        this.y = y
        this.z = z
    }

    // ===== 设置 =====

    /**
     * @brief[zh-cn] 设置向量分量
     * @param[zh-cn] x x 分量值
     * y y 分量值
     * z z 分量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components
     * @param[en] x x component value
     * y y component value
     * z z component value
     * @return[en] This instance
     */
    public func set(x: Float64, y: Float64, z: Float64): Vector3 {
        this.x = x
        this.y = y
        this.z = z
        return this
    }

    /**
     * @brief[zh-cn] 将所有分量设置为相同值
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets all components to the same value
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func setScalar(s: Float64): Vector3 {
        this.x = s
        this.y = s
        this.z = s
        return this
    }

    /**
     * @brief[zh-cn] 设置 x 分量
     * @param[zh-cn] x x 分量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets the x component
     * @param[en] x x component value
     * @return[en] This instance
     */
    public func setX(x: Float64): Vector3 {
        this.x = x
        return this
    }

    /**
     * @brief[zh-cn] 设置 y 分量
     * @param[zh-cn] y y 分量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets the y component
     * @param[en] y y component value
     * @return[en] This instance
     */
    public func setY(y: Float64): Vector3 {
        this.y = y
        return this
    }

    /**
     * @brief[zh-cn] 设置 z 分量
     * @param[zh-cn] z z 分量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets the z component
     * @param[en] z z component value
     * @return[en] This instance
     */
    public func setZ(z: Float64): Vector3 {
        this.z = z
        return this
    }

    /**
     * @brief[zh-cn] 通过索引设置分量值（0=x, 1=y, 2=z）
     * @param[zh-cn] index 分量索引
     * value 要设置的值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets component value by index (0=x, 1=y, 2=z)
     * @param[en] index Component index
     * value Value to set
     * @return[en] This instance
     */
    public func setComponent(index: Int64, value: Float64): Vector3 {
        if (index == 0) {
            this.x = value
        } else if (index == 1) {
            this.y = value
        } else if (index == 2) {
            this.z = value
        } else {
            throw Exception("THREE.Vector3: index is out of range: " + index.toString())
        }
        return this
    }

    /**
     * @brief[zh-cn] 通过索引获取分量值（0=x, 1=y, 2=z）
     * @param[zh-cn] index 分量索引
     * @return[zh-cn] 分量值
     *
     * @brief[en] Gets component value by index (0=x, 1=y, 2=z)
     * @param[en] index Component index
     * @return[en] Component value
     */
    public func getComponent(index: Int64): Float64 {
        if (index == 0) {
            return this.x
        } else if (index == 1) {
            return this.y
        } else if (index == 2) {
            return this.z
        } else {
            throw Exception("THREE.Vector3: index is out of range: " + index.toString())
        }
    }

    /**
     * @brief[zh-cn] 克隆当前向量
     * @return[zh-cn] 新的向量实例
     *
     * @brief[en] Clones the current vector
     * @return[en] New vector instance
     */
    public func clone(): Vector3 {
        return Vector3(this.x, this.y, this.z)
    }

    /**
     * @brief[zh-cn] 复制另一个向量的值到当前实例
     * @param[zh-cn] v 源向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copies another vector's values to this instance
     * @param[en] v Source vector
     * @return[en] This instance
     */
    public func copy(v: Vector3): Vector3 {
        this.x = v.x
        this.y = v.y
        this.z = v.z
        return this
    }

    // ===== 加法 =====

    /**
     * @brief[zh-cn] 将给定向量加到当前实例
     * @param[zh-cn] v 要添加的向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Adds the given vector to this instance
     * @param[en] v Vector to add
     * @return[en] This instance
     */
    public func add(v: Vector3): Vector3 {
        this.x += v.x
        this.y += v.y
        this.z += v.z
        return this
    }

    /**
     * @brief[zh-cn] 将给定标量值加到所有分量
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Adds a scalar value to all components
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func addScalar(s: Float64): Vector3 {
        this.x += s
        this.y += s
        this.z += s
        return this
    }

    /**
     * @brief[zh-cn] 将两个向量相加并将结果存储在当前实例
     * @param[zh-cn] a 第一个向量
     * b 第二个向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Adds two vectors and stores the result in this instance
     * @param[en] a First vector
     * b Second vector
     * @return[en] This instance
     */
    public func addVectors(a: Vector3, b: Vector3): Vector3 {
        this.x = a.x + b.x
        this.y = a.y + b.y
        this.z = a.z + b.z
        return this
    }

    /**
     * @brief[zh-cn] 将给定向量按给定因子缩放后加到当前实例
     * @param[zh-cn] v 向量
     * s 缩放因子
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Adds the given vector scaled by a factor to this instance
     * @param[en] v Vector
     * s Scale factor
     * @return[en] This instance
     */
    public func addScaledVector(v: Vector3, s: Float64): Vector3 {
        this.x += v.x * s
        this.y += v.y * s
        this.z += v.z * s
        return this
    }

    // ===== 减法 =====

    /**
     * @brief[zh-cn] 从当前实例减去给定向量
     * @param[zh-cn] v 要减去的向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Subtracts the given vector from this instance
     * @param[en] v Vector to subtract
     * @return[en] This instance
     */
    public func sub(v: Vector3): Vector3 {
        this.x -= v.x
        this.y -= v.y
        this.z -= v.z
        return this
    }

    /**
     * @brief[zh-cn] 从所有分量减去给定标量值
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Subtracts a scalar value from all components
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func subScalar(s: Float64): Vector3 {
        this.x -= s
        this.y -= s
        this.z -= s
        return this
    }

    /**
     * @brief[zh-cn] 将两个向量相减并将结果存储在当前实例
     * @param[zh-cn] a 被减向量
     * b 减向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Subtracts two vectors and stores the result in this instance
     * @param[en] a Minuend vector
     * b Subtrahend vector
     * @return[en] This instance
     */
    public func subVectors(a: Vector3, b: Vector3): Vector3 {
        this.x = a.x - b.x
        this.y = a.y - b.y
        this.z = a.z - b.z
        return this
    }

    // ===== 乘法 =====

    /**
     * @brief[zh-cn] 将当前实例与给定向量逐分量相乘
     * @param[zh-cn] v 乘数向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies this instance by the given vector component-wise
     * @param[en] v Multiplier vector
     * @return[en] This instance
     */
    public func multiply(v: Vector3): Vector3 {
        this.x *= v.x
        this.y *= v.y
        this.z *= v.z
        return this
    }

    /**
     * @brief[zh-cn] 将所有分量乘以给定标量
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies all components by a scalar
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func multiplyScalar(s: Float64): Vector3 {
        this.x *= s
        this.y *= s
        this.z *= s
        return this
    }

    /**
     * @brief[zh-cn] 将两个向量逐分量相乘并将结果存储在当前实例
     * @param[zh-cn] a 第一个向量
     * b 第二个向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies two vectors component-wise and stores the result in this instance
     * @param[en] a First vector
     * b Second vector
     * @return[en] This instance
     */
    public func multiplyVectors(a: Vector3, b: Vector3): Vector3 {
        this.x = a.x * b.x
        this.y = a.y * b.y
        this.z = a.z * b.z
        return this
    }

    // ===== 除法 =====

    /**
     * @brief[zh-cn] 将当前实例除以给定向量（逐分量）
     * @param[zh-cn] v 除数向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Divides this instance by the given vector component-wise
     * @param[en] v Divisor vector
     * @return[en] This instance
     */
    public func divide(v: Vector3): Vector3 {
        this.x /= v.x
        this.y /= v.y
        this.z /= v.z
        return this
    }

    /**
     * @brief[zh-cn] 将当前向量除以给定标量
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Divides this vector by a scalar
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func divideScalar(s: Float64): Vector3 {
        return this.multiplyScalar(1.0 / s)
    }

    // ===== 点积/叉积 =====

    /**
     * @brief[zh-cn] 计算与给定向量的点积
     * @param[zh-cn] v 另一个向量
     * @return[zh-cn] 点积结果
     *
     * @brief[en] Computes the dot product with the given vector
     * @param[en] v Another vector
     * @return[en] Dot product result
     */
    public func dot(v: Vector3): Float64 {
        return this.x * v.x + this.y * v.y + this.z * v.z
    }

    /**
     * @brief[zh-cn] 计算与给定向量的叉积，结果存储在当前实例
     * @param[zh-cn] v 另一个向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Computes the cross product with the given vector, storing the result in this instance
     * @param[en] v Another vector
     * @return[en] This instance
     */
    public func cross(v: Vector3): Vector3 {
        return this.crossVectors(this, v)
    }

    /**
     * @brief[zh-cn] 计算两个向量的叉积并将结果存储在当前实例
     * @param[zh-cn] a 第一个向量
     * b 第二个向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Computes the cross product of two vectors and stores the result in this instance
     * @param[en] a First vector
     * b Second vector
     * @return[en] This instance
     */
    public func crossVectors(a: Vector3, b: Vector3): Vector3 {
        let ax = a.x; let ay = a.y; let az = a.z
        let bx = b.x; let by = b.y; let bz = b.z
        this.x = ay * bz - az * by
        this.y = az * bx - ax * bz
        this.z = ax * by - ay * bx
        return this
    }

    // ===== 长度 =====

    /**
     * @brief[zh-cn] 计算向量长度的平方
     * @return[zh-cn] 长度的平方
     *
     * @brief[en] Computes the squared length of the vector
     * @return[en] Squared length
     */
    public func lengthSq(): Float64 {
        return this.x * this.x + this.y * this.y + this.z * this.z
    }

    /**
     * @brief[zh-cn] 计算向量的欧几里得长度
     * @return[zh-cn] 向量长度
     *
     * @brief[en] Computes the Euclidean length of the vector
     * @return[en] Vector length
     */
    public func length(): Float64 {
        return sqrt(this.lengthSq())
    }

    /**
     * @brief[zh-cn] 计算向量的曼哈顿长度
     * @return[zh-cn] 曼哈顿长度
     *
     * @brief[en] Computes the Manhattan length of the vector
     * @return[en] Manhattan length
     */
    public func manhattanLength(): Float64 {
        return abs(this.x) + abs(this.y) + abs(this.z)
    }

    // ===== 归一化 =====

    /**
     * @brief[zh-cn] 将当前向量转换为单位向量（长度为 1）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Converts this vector to a unit vector (length of 1)
     * @return[en] This instance
     */
    public func normalize(): Vector3 {
        let len = this.length()
        return this.divideScalar(if (len == 0.0) { 1.0 } else { len })
    }

    /**
     * @brief[zh-cn] 将当前向量设置为指定长度的同方向向量
     * @param[zh-cn] length 新长度
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets this vector to the specified length in the same direction
     * @param[en] length New length
     * @return[en] This instance
     */
    public func setLength(length: Float64): Vector3 {
        return this.normalize().multiplyScalar(length)
    }

    // ===== 距离 =====

    /**
     * @brief[zh-cn] 计算到给定向量的距离
     * @param[zh-cn] v 目标向量
     * @return[zh-cn] 距离
     *
     * @brief[en] Computes the distance to the given vector
     * @param[en] v Target vector
     * @return[en] Distance
     */
    public func distanceTo(v: Vector3): Float64 {
        return sqrt(this.distanceToSquared(v))
    }

    /**
     * @brief[zh-cn] 计算到给定向量的距离的平方
     * @param[zh-cn] v 目标向量
     * @return[zh-cn] 距离的平方
     *
     * @brief[en] Computes the squared distance to the given vector
     * @param[en] v Target vector
     * @return[en] Squared distance
     */
    public func distanceToSquared(v: Vector3): Float64 {
        let dx = this.x - v.x
        let dy = this.y - v.y
        let dz = this.z - v.z
        return dx * dx + dy * dy + dz * dz
    }

    /**
     * @brief[zh-cn] 计算到给定向量的曼哈顿距离
     * @param[zh-cn] v 目标向量
     * @return[zh-cn] 曼哈顿距离
     *
     * @brief[en] Computes the Manhattan distance to the given vector
     * @param[en] v Target vector
     * @return[en] Manhattan distance
     */
    public func manhattanDistanceTo(v: Vector3): Float64 {
        return abs(this.x - v.x) + abs(this.y - v.y) + abs(this.z - v.z)
    }

    // ===== 线性插值 =====

    /**
     * @brief[zh-cn] 在当前向量与给定向量之间进行线性插值
     * @param[zh-cn] v 目标向量
     * alpha 插值因子，闭区间 [0, 1]
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Performs linear interpolation between this vector and the given vector
     * @param[en] v Target vector
     * alpha Interpolation factor, closed interval [0, 1]
     * @return[en] This instance
     */
    public func lerp(v: Vector3, alpha: Float64): Vector3 {
        this.x += (v.x - this.x) * alpha
        this.y += (v.y - this.y) * alpha
        this.z += (v.z - this.z) * alpha
        return this
    }

    /**
     * @brief[zh-cn] 在两个给定向量之间进行线性插值，结果存储在当前实例
     * @param[zh-cn] v1 第一个向量
     * v2 第二个向量
     * alpha 插值因子，闭区间 [0, 1]
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Performs linear interpolation between two given vectors, storing result in this instance
     * @param[en] v1 First vector
     * v2 Second vector
     * alpha Interpolation factor, closed interval [0, 1]
     * @return[en] This instance
     */
    public func lerpVectors(v1: Vector3, v2: Vector3, alpha: Float64): Vector3 {
        this.x = v1.x + (v2.x - v1.x) * alpha
        this.y = v1.y + (v2.y - v1.y) * alpha
        this.z = v1.z + (v2.z - v1.z) * alpha
        return this
    }

    // ===== 取负 =====

    /**
     * @brief[zh-cn] 反转向量，即设置 x = -x, y = -y, z = -z
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Negates the vector, setting x = -x, y = -y, z = -z
     * @return[en] This instance
     */
    public func negate(): Vector3 {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        return this
    }

    // ===== 比较 =====

    /**
     * @brief[zh-cn] 判断当前向量是否与给定向量相等
     * @param[zh-cn] v 比较向量
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Checks if this vector equals the given vector
     * @param[en] v Vector to compare
     * @return[en] Whether equal
     */
    public func equals(v: Vector3): Bool {
        return this.x == v.x && this.y == v.y && this.z == v.z
    }

    // ===== 极值 =====

    /**
     * @brief[zh-cn] 将各分量替换为当前向量与给定向量对应分量的较小值
     * @param[zh-cn] v 比较向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Replaces each component with the minimum of this and the given vector's corresponding component
     * @param[en] v Vector to compare
     * @return[en] This instance
     */
    public func min(v: Vector3): Vector3 {
        this.x = min(this.x, v.x)
        this.y = min(this.y, v.y)
        this.z = min(this.z, v.z)
        return this
    }

    /**
     * @brief[zh-cn] 将各分量替换为当前向量与给定向量对应分量的较大值
     * @param[zh-cn] v 比较向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Replaces each component with the maximum of this and the given vector's corresponding component
     * @param[en] v Vector to compare
     * @return[en] This instance
     */
    public func max(v: Vector3): Vector3 {
        this.x = max(this.x, v.x)
        this.y = max(this.y, v.y)
        this.z = max(this.z, v.z)
        return this
    }

    /**
     * @brief[zh-cn] 将当前向量的分量限制在 [min, max] 范围内
     * @param[zh-cn] min 最小值向量
     * max 最大值向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Clamps the components of this vector within [min, max]
     * @param[en] min Minimum vector
     * max Maximum vector
     * @return[en] This instance
     */
    public func clamp(min: Vector3, max: Vector3): Vector3 {
        this.x = clamp(this.x, min.x, max.x)
        this.y = clamp(this.y, min.y, max.y)
        this.z = clamp(this.z, min.z, max.z)
        return this
    }

    /**
     * @brief[zh-cn] 将当前向量的分量限制在 [minVal, maxVal] 范围内
     * @param[zh-cn] minVal 最小值
     * maxVal 最大值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Clamps the components of this vector within [minVal, maxVal]
     * @param[en] minVal Minimum value
     * maxVal Maximum value
     * @return[en] This instance
     */
    public func clampScalar(minVal: Float64, maxVal: Float64): Vector3 {
        this.x = clamp(this.x, minVal, maxVal)
        this.y = clamp(this.y, minVal, maxVal)
        this.z = clamp(this.z, minVal, maxVal)
        return this
    }

    /**
     * @brief[zh-cn] 将当前向量的长度限制在 [min, max] 范围内
     * @param[zh-cn] min 最小长度
     * max 最大长度
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Clamps the length of this vector within [min, max]
     * @param[en] min Minimum length
     * max Maximum length
     * @return[en] This instance
     */
    public func clampLength(min: Float64, max: Float64): Vector3 {
        let len = this.length()
        let divisor = if (len == 0.0) { 1.0 } else { len }
        return this.divideScalar(divisor).multiplyScalar(clamp(len, min, max))
    }

    /**
     * @brief[zh-cn] 将分量向下取整
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components down to the nearest integer
     * @return[en] This instance
     */
    public func floor(): Vector3 {
        this.x = floor(this.x)
        this.y = floor(this.y)
        this.z = floor(this.z)
        return this
    }

    /**
     * @brief[zh-cn] 将分量向上取整
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components up to the nearest integer
     * @return[en] This instance
     */
    public func ceil(): Vector3 {
        this.x = ceil(this.x)
        this.y = ceil(this.y)
        this.z = ceil(this.z)
        return this
    }

    /**
     * @brief[zh-cn] 将分量四舍五入到最近整数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components to the nearest integer
     * @return[en] This instance
     */
    public func round(): Vector3 {
        this.x = round(this.x)
        this.y = round(this.y)
        this.z = round(this.z)
        return this
    }

    /**
     * @brief[zh-cn] 将分量向零取整（负数向上，正数向下）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components toward zero (negative up, positive down)
     * @return[en] This instance
     */
    public func roundToZero(): Vector3 {
        this.x = if (this.x < 0.0) { ceil(this.x) } else { floor(this.x) }
        this.y = if (this.y < 0.0) { ceil(this.y) } else { floor(this.y) }
        this.z = if (this.z < 0.0) { ceil(this.z) } else { floor(this.z) }
        return this
    }

    // ===== 矩阵变换 =====

    /**
     * @brief[zh-cn] 将当前向量乘以给定 3x3 矩阵
     * @param[zh-cn] m 3x3 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies this vector by the given 3x3 matrix
     * @param[en] m 3x3 matrix
     * @return[en] This instance
     */
    public func applyMatrix3(m: Matrix3): Vector3 {
        let x = this.x; let y = this.y; let z = this.z
        let e = m.elements
        this.x = e[0] * x + e[3] * y + e[6] * z
        this.y = e[1] * x + e[4] * y + e[7] * z
        this.z = e[2] * x + e[5] * y + e[8] * z
        return this
    }

    /**
     * @brief[zh-cn] 将当前向量乘以给定法线矩阵并归一化
     * @param[zh-cn] m 法线矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies this vector by the given normal matrix and normalizes
     * @param[en] m Normal matrix
     * @return[en] This instance
     */
    public func applyNormalMatrix(m: Matrix3): Vector3 {
        return this.applyMatrix3(m).normalize()
    }

    /**
     * @brief[zh-cn] 将当前向量（隐含 1 作为第 4 分量）乘以给定 4x4 矩阵，并进行透视除法
     * @param[zh-cn] m 4x4 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies this vector (with implied 1 as 4th component) by the given 4x4 matrix with perspective division
     * @param[en] m 4x4 matrix
     * @return[en] This instance
     */
    public func applyMatrix4(m: Matrix4): Vector3 {
        let x = this.x; let y = this.y; let z = this.z
        let e = m.elements
        let w = 1.0 / (e[3] * x + e[7] * y + e[11] * z + e[15])
        this.x = (e[0] * x + e[4] * y + e[8] * z + e[12]) * w
        this.y = (e[1] * x + e[5] * y + e[9] * z + e[13]) * w
        this.z = (e[2] * x + e[6] * y + e[10] * z + e[14]) * w
        return this
    }

    /**
     * @brief[zh-cn] 将给定四元数应用到当前向量
     * @param[zh-cn] q 四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Applies the given quaternion to this vector
     * @param[en] q Quaternion
     * @return[en] This instance
     */
    public func applyQuaternion(q: Quaternion): Vector3 {
        // 假设四元数 q 具有单位长度
        let vx = this.x; let vy = this.y; let vz = this.z
        let qx = q.x; let qy = q.y; let qz = q.z; let qw = q.w
        // t = 2 * cross(q.xyz, v)
        let tx = 2.0 * (qy * vz - qz * vy)
        let ty = 2.0 * (qz * vx - qx * vz)
        let tz = 2.0 * (qx * vy - qy * vx)
        // v + q.w * t + cross(q.xyz, t)
        this.x = vx + qw * tx + qy * tz - qz * ty
        this.y = vy + qw * ty + qz * tx - qx * tz
        this.z = vz + qw * tz + qx * ty - qy * tx
        return this
    }

    /**
     * @brief[zh-cn] 用给定 4x4 矩阵的左上 3x3 子矩阵变换当前向量，并归一化结果
     * @param[zh-cn] m 4x4 仿射矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Transforms this vector by the upper-left 3x3 submatrix of the given 4x4 matrix and normalizes the result
     * @param[en] m 4x4 affine matrix
     * @return[en] This instance
     */
    public func transformDirection(m: Matrix4): Vector3 {
        let x = this.x; let y = this.y; let z = this.z
        let e = m.elements
        this.x = e[0] * x + e[4] * y + e[8] * z
        this.y = e[1] * x + e[5] * y + e[9] * z
        this.z = e[2] * x + e[6] * y + e[10] * z
        return this.normalize()
    }

    // ===== 角度 =====

    /**
     * @brief[zh-cn] 计算当前向量与给定向量之间的角度（弧度）
     * @param[zh-cn] v 另一个向量
     * @return[zh-cn] 角度（弧度）
     *
     * @brief[en] Computes the angle between this vector and the given vector (radians)
     * @param[en] v Another vector
     * @return[en] Angle in radians
     */
    public func angleTo(v: Vector3): Float64 {
        let denominator = sqrt(this.lengthSq() * v.lengthSq())
        if (denominator == 0.0) {
            return PI / 2.0
        }
        let theta = this.dot(v) / denominator
        // 钳制以处理数值问题
        return acos(clamp(theta, -1.0, 1.0))
    }

    // ===== 投影 =====

    /**
     * @brief[zh-cn] 将当前向量投影到给定向量上
     * @param[zh-cn] v 投影目标向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Projects this vector onto the given vector
     * @param[en] v Target vector to project onto
     * @return[en] This instance
     */
    public func projectOnVector(v: Vector3): Vector3 {
        let denominator = v.lengthSq()
        if (denominator == 0.0) {
            return this.set(0.0, 0.0, 0.0)
        }
        let scalar = v.dot(this) / denominator
        return this.copy(v).multiplyScalar(scalar)
    }

    /**
     * @brief[zh-cn] 将当前向量投影到给定法线的平面上
     * @param[zh-cn] planeNormal 平面法线
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Projects this vector onto the plane defined by the given normal
     * @param[en] planeNormal Plane normal
     * @return[en] This instance
     */
    public func projectOnPlane(planeNormal: Vector3): Vector3 {
        let v = Vector3().copy(this).projectOnVector(planeNormal)
        return this.sub(v)
    }

    /**
     * @brief[zh-cn] 将当前向量沿给定法线反射
     * @param[zh-cn] normal （归一化的）法线向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Reflects this vector along the given normal
     * @param[en] normal Normalized normal vector
     * @return[en] This instance
     */
    public func reflect(normal: Vector3): Vector3 {
        let v = Vector3().copy(normal).multiplyScalar(2.0 * this.dot(normal))
        return this.sub(v)
    }

    // ===== 坐标设置 =====

    /**
     * @brief[zh-cn] 从球坐标设置向量分量
     * @param[zh-cn] s 球坐标对象
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from spherical coordinates
     * @param[en] s Spherical coordinate object
     * @return[en] This instance
     */
    public func setFromSpherical(s: Spherical): Vector3 {
        return this.setFromSphericalCoords(s.radius, s.phi, s.theta)
    }

    /**
     * @brief[zh-cn] 从球坐标参数设置向量分量
     * @param[zh-cn] radius 半径
     * phi 极角（弧度）
     * theta 方位角（弧度）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from spherical coordinate parameters
     * @param[en] radius Radius
     * phi Polar angle in radians
     * theta Azimuthal angle in radians
     * @return[en] This instance
     */
    public func setFromSphericalCoords(radius: Float64, phi: Float64, theta: Float64): Vector3 {
        let sinPhiRadius = sin(phi) * radius
        this.x = sinPhiRadius * sin(theta)
        this.y = cos(phi) * radius
        this.z = sinPhiRadius * cos(theta)
        return this
    }

    /**
     * @brief[zh-cn] 从圆柱坐标设置向量分量
     * @param[zh-cn] c 圆柱坐标对象
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from cylindrical coordinates
     * @param[en] c Cylindrical coordinate object
     * @return[en] This instance
     */
    public func setFromCylindrical(c: Cylindrical): Vector3 {
        return this.setFromCylindricalCoords(c.radius, c.theta, c.y)
    }

    /**
     * @brief[zh-cn] 从圆柱坐标参数设置向量分量
     * @param[zh-cn] radius 半径
     * theta 角度（弧度）
     * y 高度
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from cylindrical coordinate parameters
     * @param[en] radius Radius
     * theta Angle in radians
     * y Height
     * @return[en] This instance
     */
    public func setFromCylindricalCoords(radius: Float64, theta: Float64, y: Float64): Vector3 {
        this.x = radius * sin(theta)
        this.y = y
        this.z = radius * cos(theta)
        return this
    }

    /**
     * @brief[zh-cn] 从 4x4 矩阵的位置元素设置向量分量
     * @param[zh-cn] m 4x4 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from the position elements of a 4x4 matrix
     * @param[en] m 4x4 matrix
     * @return[en] This instance
     */
    public func setFromMatrixPosition(m: Matrix4): Vector3 {
        let e = m.elements
        this.x = e[12]
        this.y = e[13]
        this.z = e[14]
        return this
    }

    /**
     * @brief[zh-cn] 从 4x4 矩阵的缩放元素设置向量分量
     * @param[zh-cn] m 4x4 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from the scale elements of a 4x4 matrix
     * @param[en] m 4x4 matrix
     * @return[en] This instance
     */
    public func setFromMatrixScale(m: Matrix4): Vector3 {
        let sx = Vector3().setFromMatrixColumn(m, 0).length()
        let sy = Vector3().setFromMatrixColumn(m, 1).length()
        let sz = Vector3().setFromMatrixColumn(m, 2).length()
        this.x = sx
        this.y = sy
        this.z = sz
        return this
    }

    /**
     * @brief[zh-cn] 从 4x4 矩阵的指定列设置向量分量
     * @param[zh-cn] m 4x4 矩阵
     * index 列索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from the specified column of a 4x4 matrix
     * @param[en] m 4x4 matrix
     * index Column index
     * @return[en] This instance
     */
    public func setFromMatrixColumn(m: Matrix4, index: Int64): Vector3 {
        return this.fromArray(m.elements, offset: index * 4)
    }

    /**
     * @brief[zh-cn] 从 3x3 矩阵的指定列设置向量分量
     * @param[zh-cn] m 3x3 矩阵
     * index 列索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from the specified column of a 3x3 matrix
     * @param[en] m 3x3 matrix
     * index Column index
     * @return[en] This instance
     */
    public func setFromMatrix3Column(m: Matrix3, index: Int64): Vector3 {
        return this.fromArray(m.elements, offset: index * 3)
    }

    /**
     * @brief[zh-cn] 从欧拉角设置向量分量
     * @param[zh-cn] e 欧拉角
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from Euler angles
     * @param[en] e Euler angles
     * @return[en] This instance
     */
    public func setFromEuler(e: Euler): Vector3 {
        this.x = e.x
        this.y = e.y
        this.z = e.z
        return this
    }

    /**
     * @brief[zh-cn] 从颜色的 RGB 分量设置向量分量
     * @param[zh-cn] c 颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from a color's RGB components
     * @param[en] c Color
     * @return[en] This instance
     */
    public func setFromColor(c: Color): Vector3 {
        this.x = c.r
        this.y = c.g
        this.z = c.b
        return this
    }

    // ===== 数组操作 =====

    /**
     * @brief[zh-cn] 从顶点属性读取向量分量
     * @param[zh-cn] attribute 顶点属性（AttributeReader 接口，由 BufferAttribute 实现）
     * index 顶点索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Reads vector components from a vertex attribute (cf. JS: Vector3.fromBufferAttribute)
     * @param[en] attribute Vertex attribute (AttributeReader interface, implemented by BufferAttribute)
     * index Vertex index
     * @return[en] This instance
     */
    public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Vector3 {
        this.x = attribute.getX(index)
        this.y = attribute.getY(index)
        this.z = attribute.getZ(index)
        return this
    }

    /**
     * @brief[zh-cn] 从数组设置向量分量
     * @param[zh-cn] array 包含向量分量值的数组
     * offset 数组偏移量，默认为 0
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components from an array
     * @param[en] array Array containing vector component values
     * offset Array offset, defaults to 0
     * @return[en] This instance
     */
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Vector3 {
        this.x = array[offset]
        this.y = array[offset + 1]
        this.z = array[offset + 2]
        return this
    }

    /**
     * @brief[zh-cn] 将向量分量写入数组
     * @param[zh-cn] array 目标数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 包含向量分量的数组
     *
     * @brief[en] Writes vector components into an array
     * @param[en] array Target array
     * offset Starting index, defaults to 0
     * @return[en] Array containing vector components
     */
    public func toArray(array: Array<Float64>, offset!: Int64 = 0): Array<Float64> {
        array[offset] = this.x
        array[offset + 1] = this.y
        array[offset + 2] = this.z
        return array
    }

    // ===== 随机 =====

    /**
     * @brief[zh-cn] 将每个分量设置为 [0, 1) 之间的伪随机值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets each component to a pseudo-random value in [0, 1)
     * @return[en] This instance
     */
    public func random(): Vector3 {
        this.x = Random().nextFloat64()
        this.y = Random().nextFloat64()
        this.z = Random().nextFloat64()
        return this
    }

    /**
     * @brief[zh-cn] 将当前向量设置为单位球面上的均匀随机方向
     * @explain[zh-cn] 参考：https://mathworld.wolfram.com/SpherePointPicking.html
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets this vector to a uniformly random direction on the unit sphere surface
     * @explain[en] Reference: https://mathworld.wolfram.com/SpherePointPicking.html
     * @return[en] This instance
     */
    public func randomDirection(): Vector3 {
        let theta = Random().nextFloat64() * PI * 2.0
        let u = Random().nextFloat64() * 2.0 - 1.0
        let c = sqrt(1.0 - u * u)
        this.x = c * cos(theta)
        this.y = u
        this.z = c * sin(theta)
        return this
    }

    /**
     * @brief[zh-cn] 通过欧拉角旋转向量
     * @param[zh-cn] euler 欧拉角
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rotates this vector by Euler angles
     * @param[en] euler Euler angles
     * @return[en] This instance
     */
    public func applyEuler(euler: Euler): Vector3 {
        return this.applyQuaternion(Quaternion().setFromEuler(euler))
    }

    /**
     * @brief[zh-cn] 通过轴角旋转向量
     * @param[zh-cn] axis 旋转轴（应为单位向量）
     * angle 旋转角度（弧度）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rotates this vector by an axis-angle
     * @param[en] axis Rotation axis (should be a unit vector)
     * angle Rotation angle in radians
     * @return[en] This instance
     */
    public func applyAxisAngle(axis: Vector3, angle: Float64): Vector3 {
        return this.applyQuaternion(Quaternion().setFromAxisAngle(axis, angle))
    }

    /**
     * @brief[zh-cn] 通过相机投影矩阵投影向量
     * @param[zh-cn] cameraProjectionMatrix 相机投影矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Projects the vector through a camera projection matrix
     * @param[en] cameraProjectionMatrix Camera projection matrix
     * @return[en] This instance
     */
    public func project(cameraProjectionMatrix: Matrix4): Vector3 {
        return this.applyMatrix4(cameraProjectionMatrix)
    }

    /**
     * @brief[zh-cn] 通过相机逆投影矩阵反投影向量
     * @param[zh-cn] cameraProjectionMatrix 相机投影矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Unprojects the vector through a camera inverse projection matrix
     * @param[en] cameraProjectionMatrix Camera projection matrix
     * @return[en] This instance
     */
    public func unproject(cameraProjectionMatrix: Matrix4): Vector3 {
        return this.applyMatrix4(cameraProjectionMatrix)
    }

    // ===== 运算符重载 =====

    public operator func +(v: Vector3): Vector3 {
        return Vector3(this.x + v.x, this.y + v.y, this.z + v.z)
    }

    public operator func -(v: Vector3): Vector3 {
        return Vector3(this.x - v.x, this.y - v.y, this.z - v.z)
    }

    public operator func *(s: Float64): Vector3 {
        return Vector3(this.x * s, this.y * s, this.z * s)
    }

    public operator func /(s: Float64): Vector3 {
        return Vector3(this.x / s, this.y / s, this.z / s)
    }

    public operator func -(): Vector3 {
        return Vector3(-this.x, -this.y, -this.z)
    }
}
