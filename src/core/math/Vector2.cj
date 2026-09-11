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
 * @file[zh-cn] Vector2
 * @brief[zh-cn] 2D 向量
 * @explain[zh-cn] 表示二维空间中的点或方向向量。
 *
 * @file[en] Vector2
 * @brief[en] 2D vector
 * @explain[en] Represents a point or direction vector in 2D space.
 */
package three.core.math

import std.math.*
import std.random.*
import three.core.interfaces.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 2D 向量类，表示有序对 (x, y)
 * @explain[zh-cn] 可用于表示二维空间中的点、方向和长度，或任意有序数对。
 *
 * @brief[en] 2D vector class, represents an ordered pair (x, y)
 * @explain[en] Can be used to represent points, directions and lengths in 2D space, or any ordered pair.
 */
@JsonAdapter
public class Vector2 {
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
     * @brief[zh-cn] 默认构造函数，初始化为零向量 (0, 0)
     *
     * @brief[en] Default constructor, initializes to zero vector (0, 0)
     */
    public init() {
        this.x = 0.0
        this.y = 0.0
    }

    /**
     * @brief[zh-cn] 使用指定分量值构造向量
     * @param[zh-cn] x x 分量值
     * y y 分量值
     *
     * @brief[en] Constructs a vector with specified component values
     * @param[en] x x component value
     * y y component value
     */
    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }

    // ===== 属性 =====

    /**
     * @brief[zh-cn] width 属性，x 的别名
     *
     * @brief[en] width property, alias for x
     */
    @JsonIgnore
    public mut prop width: Float64 {
        get() { this.x }
        set(v) { this.x = v }
    }

    /**
     * @brief[zh-cn] height 属性，y 的别名
     *
     * @brief[en] height property, alias for y
     */
    @JsonIgnore
    public mut prop height: Float64 {
        get() { this.y }
        set(v) { this.y = v }
    }

    // ===== 设置 =====

    /**
     * @brief[zh-cn] 设置向量分量
     * @param[zh-cn] x x 分量值
     * y y 分量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components
     * @param[en] x x component value
     * y y component value
     * @return[en] This instance
     */
    public func set(x: Float64, y: Float64): Vector2 {
        this.x = x
        this.y = y
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
    public func setScalar(s: Float64): Vector2 {
        this.x = s
        this.y = s
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
    public func setX(x: Float64): Vector2 {
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
    public func setY(y: Float64): Vector2 {
        this.y = y
        return this
    }

    /**
     * @brief[zh-cn] 通过索引设置分量值（0=x, 1=y）
     * @param[zh-cn] index 分量索引
     * value 要设置的值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets component value by index (0=x, 1=y)
     * @param[en] index Component index
     * value Value to set
     * @return[en] This instance
     */
    public func setComponent(index: Int64, value: Float64): Vector2 {
        if (index == 0) {
            this.x = value
        } else if (index == 1) {
            this.y = value
        } else {
            throw Exception("THREE.Vector2: index is out of range: " + index.toString())
        }
        return this
    }

    /**
     * @brief[zh-cn] 通过索引获取分量值（0=x, 1=y）
     * @param[zh-cn] index 分量索引
     * @return[zh-cn] 分量值
     *
     * @brief[en] Gets component value by index (0=x, 1=y)
     * @param[en] index Component index
     * @return[en] Component value
     */
    public func getComponent(index: Int64): Float64 {
        if (index == 0) {
            return this.x
        } else if (index == 1) {
            return this.y
        } else {
            throw Exception("THREE.Vector2: index is out of range: " + index.toString())
        }
    }

    /**
     * @brief[zh-cn] 克隆当前向量
     * @return[zh-cn] 新的向量实例
     *
     * @brief[en] Clones the current vector
     * @return[en] New vector instance
     */
    public func clone(): Vector2 {
        return Vector2(this.x, this.y)
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
    public func copy(v: Vector2): Vector2 {
        this.x = v.x
        this.y = v.y
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
    public func add(v: Vector2): Vector2 {
        this.x += v.x
        this.y += v.y
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
    public func addScalar(s: Float64): Vector2 {
        this.x += s
        this.y += s
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
    public func addVectors(a: Vector2, b: Vector2): Vector2 {
        this.x = a.x + b.x
        this.y = a.y + b.y
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
    public func addScaledVector(v: Vector2, s: Float64): Vector2 {
        this.x += v.x * s
        this.y += v.y * s
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
    public func sub(v: Vector2): Vector2 {
        this.x -= v.x
        this.y -= v.y
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
    public func subScalar(s: Float64): Vector2 {
        this.x -= s
        this.y -= s
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
    public func subVectors(a: Vector2, b: Vector2): Vector2 {
        this.x = a.x - b.x
        this.y = a.y - b.y
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
    public func multiply(v: Vector2): Vector2 {
        this.x *= v.x
        this.y *= v.y
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
    public func multiplyScalar(s: Float64): Vector2 {
        this.x *= s
        this.y *= s
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
    public func divide(v: Vector2): Vector2 {
        this.x /= v.x
        this.y /= v.y
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
    public func divideScalar(s: Float64): Vector2 {
        return this.multiplyScalar(1.0 / s)
    }

    /**
     * @brief[zh-cn] 将当前向量（隐含 1 作为第三分量）乘以给定 3x3 矩阵
     * @param[zh-cn] m 3x3 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies this vector (with implied 1 as third component) by the given 3x3 matrix
     * @param[en] m 3x3 matrix
     * @return[en] This instance
     */
    public func applyMatrix3(m: Matrix3): Vector2 {
        let x = this.x
        let y = this.y
        let e = m.elements
        this.x = e[0] * x + e[3] * y + e[6]
        this.y = e[1] * x + e[4] * y + e[7]
        return this
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
    public func dot(v: Vector2): Float64 {
        return this.x * v.x + this.y * v.y
    }

    /**
     * @brief[zh-cn] 计算与给定向量的叉积（2D 叉积返回标量）
     * @param[zh-cn] v 另一个向量
     * @return[zh-cn] 叉积结果
     *
     * @brief[en] Computes the cross product with the given vector (2D cross product returns a scalar)
     * @param[en] v Another vector
     * @return[en] Cross product result
     */
    public func cross(v: Vector2): Float64 {
        return this.x * v.y - this.y * v.x
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
        return this.x * this.x + this.y * this.y
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
        return abs(this.x) + abs(this.y)
    }

    // ===== 归一化 =====

    /**
     * @brief[zh-cn] 将当前向量转换为单位向量（长度为 1）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Converts this vector to a unit vector (length of 1)
     * @return[en] This instance
     */
    public func normalize(): Vector2 {
        let len = this.length()
        return this.divideScalar(if (len == 0.0) { 1.0 } else { len })
    }

    // ===== 角度 =====

    /**
     * @brief[zh-cn] 计算当前向量相对于正 x 轴的角度（弧度）
     * @return[zh-cn] 角度（弧度）
     *
     * @brief[en] Computes the angle of this vector relative to the positive x-axis (radians)
     * @return[en] Angle in radians
     */
    public func angle(): Float64 {
        let angle = atan2(-this.y, -this.x) + PI
        return angle
    }

    /**
     * @brief[zh-cn] 计算当前向量与给定向量之间的角度（弧度）
     * @param[zh-cn] v 另一个向量
     * @return[zh-cn] 角度（弧度）
     *
     * @brief[en] Computes the angle between this vector and the given vector (radians)
     * @param[en] v Another vector
     * @return[en] Angle in radians
     */
    public func angleTo(v: Vector2): Float64 {
        let denominator = sqrt(this.lengthSq() * v.lengthSq())
        if (denominator == 0.0) {
            return PI / 2.0
        }
        let theta = this.dot(v) / denominator
        // 钳制以处理数值问题
        return acos(clamp(theta, -1.0, 1.0))
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
    public func distanceTo(v: Vector2): Float64 {
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
    public func distanceToSquared(v: Vector2): Float64 {
        let dx = this.x - v.x
        let dy = this.y - v.y
        return dx * dx + dy * dy
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
    public func manhattanDistanceTo(v: Vector2): Float64 {
        return abs(this.x - v.x) + abs(this.y - v.y)
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
    public func setLength(length: Float64): Vector2 {
        return this.normalize().multiplyScalar(length)
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
    public func lerp(v: Vector2, alpha: Float64): Vector2 {
        this.x += (v.x - this.x) * alpha
        this.y += (v.y - this.y) * alpha
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
    public func lerpVectors(v1: Vector2, v2: Vector2, alpha: Float64): Vector2 {
        this.x = v1.x + (v2.x - v1.x) * alpha
        this.y = v1.y + (v2.y - v1.y) * alpha
        return this
    }

    // ===== 取负/取反 =====

    /**
     * @brief[zh-cn] 反转向量，即设置 x = -x, y = -y
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Negates the vector, setting x = -x, y = -y
     * @return[en] This instance
     */
    public func negate(): Vector2 {
        this.x = -this.x
        this.y = -this.y
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
    public func equals(v: Vector2): Bool {
        return this.x == v.x && this.y == v.y
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
    public func min(v: Vector2): Vector2 {
        this.x = min(this.x, v.x)
        this.y = min(this.y, v.y)
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
    public func max(v: Vector2): Vector2 {
        this.x = max(this.x, v.x)
        this.y = max(this.y, v.y)
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
    public func clamp(min: Vector2, max: Vector2): Vector2 {
        this.x = clamp(this.x, min.x, max.x)
        this.y = clamp(this.y, min.y, max.y)
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
    public func clampScalar(minVal: Float64, maxVal: Float64): Vector2 {
        this.x = clamp(this.x, minVal, maxVal)
        this.y = clamp(this.y, minVal, maxVal)
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
    public func clampLength(min: Float64, max: Float64): Vector2 {
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
    public func floor(): Vector2 {
        this.x = floor(this.x)
        this.y = floor(this.y)
        return this
    }

    /**
     * @brief[zh-cn] 将分量向上取整
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components up to the nearest integer
     * @return[en] This instance
     */
    public func ceil(): Vector2 {
        this.x = ceil(this.x)
        this.y = ceil(this.y)
        return this
    }

    /**
     * @brief[zh-cn] 将分量四舍五入到最近整数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components to the nearest integer
     * @return[en] This instance
     */
    public func round(): Vector2 {
        this.x = round(this.x)
        this.y = round(this.y)
        return this
    }

    /**
     * @brief[zh-cn] 将分量向零取整（负数向上，正数向下）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components toward zero (negative up, positive down)
     * @return[en] This instance
     */
    public func roundToZero(): Vector2 {
        this.x = if (this.x < 0.0) { ceil(this.x) } else { floor(this.x) }
        this.y = if (this.y < 0.0) { ceil(this.y) } else { floor(this.y) }
        return this
    }

    // ===== 旋转 =====

    /**
     * @brief[zh-cn] 将当前向量绕给定中心旋转指定角度
     * @param[zh-cn] center 旋转中心
     * angle 旋转角度（弧度）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rotates this vector around the given center by the specified angle
     * @param[en] center Rotation center
     * angle Rotation angle in radians
     * @return[en] This instance
     */
    public func rotateAround(center: Vector2, angle: Float64): Vector2 {
        let c = cos(angle)
        let s = sin(angle)
        let x = this.x - center.x
        let y = this.y - center.y
        this.x = x * c - y * s + center.x
        this.y = x * s + y * c + center.y
        return this
    }

    // ===== 数组操作 =====

    /**
     * @brief[zh-cn] 从顶点属性读取向量分量
     * @param[zh-cn] attribute 顶点属性（AttributeReader 接口，由 BufferAttribute 实现）
     * index 顶点索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Reads vector components from a vertex attribute (cf. JS: Vector2.fromBufferAttribute)
     * @param[en] attribute Vertex attribute (AttributeReader interface, implemented by BufferAttribute)
     * index Vertex index
     * @return[en] This instance
     */
    public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Vector2 {
        this.x = attribute.getX(index)
        this.y = attribute.getY(index)
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
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Vector2 {
        this.x = array[offset]
        this.y = array[offset + 1]
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
    public func random(): Vector2 {
        this.x = Random().nextFloat64()
        this.y = Random().nextFloat64()
        return this
    }

    // ===== 运算符重载 =====

    public operator func +(v: Vector2): Vector2 {
        return Vector2(this.x + v.x, this.y + v.y)
    }

    public operator func -(v: Vector2): Vector2 {
        return Vector2(this.x - v.x, this.y - v.y)
    }

    public operator func *(s: Float64): Vector2 {
        return Vector2(this.x * s, this.y * s)
    }

    public operator func /(s: Float64): Vector2 {
        return Vector2(this.x / s, this.y / s)
    }

    public operator func -(): Vector2 {
        return Vector2(-this.x, -this.y)
    }
}
