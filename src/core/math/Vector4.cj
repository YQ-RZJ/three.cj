/**
 * @file[zh-cn] Vector4
 * @brief[zh-cn] 4D 向量
 * @explain[zh-cn] 表示四维空间中的点或方向向量。
 *
 * @file[en] Vector4
 * @brief[en] 4D vector
 * @explain[en] Represents a point or direction vector in 4D space.
 */
package three.core.math

import std.math.*
import std.random.*
import three.core.interfaces.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 4D 向量类，表示有序四元组 (x, y, z, w)
 * @explain[zh-cn] 默认 w=1，可用于表示齐次坐标。
 *
 * @brief[en] 4D vector class, represents an ordered quadruple (x, y, z, w)
 * @explain[en] Defaults to w=1, can be used to represent homogeneous coordinates.
 */
@JsonAdapter
public class Vector4 {
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
     * @brief[zh-cn] w 分量
     *
     * @brief[en] w component
     */
    public var w: Float64

    /**
     * @brief[zh-cn] 默认构造函数，初始化为 (0, 0, 0, 1)
     *
     * @brief[en] Default constructor, initializes to (0, 0, 0, 1)
     */
    public init() {
        this.x = 0.0
        this.y = 0.0
        this.z = 0.0
        this.w = 1.0
    }

    /**
     * @brief[zh-cn] 使用指定分量值构造向量
     * @param[zh-cn] x x 分量值
     * y y 分量值
     * z z 分量值
     * w w 分量值
     *
     * @brief[en] Constructs a vector with specified component values
     * @param[en] x x component value
     * y y component value
     * z z component value
     * w w component value
     */
    public init(x: Float64, y: Float64, z: Float64, w: Float64) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }

    /**
     * @brief[zh-cn] width 属性，z 的别名
     *
     * @brief[en] width property, alias for z
     */
    @JsonIgnore
    public mut prop width: Float64 {
        get() { this.z }
        set(v) { this.z = v }
    }

    /**
     * @brief[zh-cn] height 属性，w 的别名
     *
     * @brief[en] height property, alias for w
     */
    @JsonIgnore
    public mut prop height: Float64 {
        get() { this.w }
        set(v) { this.w = v }
    }

    /**
     * @brief[zh-cn] 设置向量分量
     * @param[zh-cn] x x 分量值
     * y y 分量值
     * z z 分量值
     * w w 分量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets vector components
     * @param[en] x x component value
     * y y component value
     * z z component value
     * w w component value
     * @return[en] This instance
     */
    public func set(x: Float64, y: Float64, z: Float64, w: Float64): Vector4 {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
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
    public func setScalar(s: Float64): Vector4 {
        this.x = s
        this.y = s
        this.z = s
        this.w = s
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
    public func setX(x: Float64): Vector4 {
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
    public func setY(y: Float64): Vector4 {
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
    public func setZ(z: Float64): Vector4 {
        this.z = z
        return this
    }

    /**
     * @brief[zh-cn] 设置 w 分量
     * @param[zh-cn] w w 分量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets the w component
     * @param[en] w w component value
     * @return[en] This instance
     */
    public func setW(w: Float64): Vector4 {
        this.w = w
        return this
    }

    /**
     * @brief[zh-cn] 通过索引设置分量值（0=x, 1=y, 2=z, 3=w）
     * @param[zh-cn] index 分量索引
     * value 要设置的值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets component value by index (0=x, 1=y, 2=z, 3=w)
     * @param[en] index Component index
     * value Value to set
     * @return[en] This instance
     */
    public func setComponent(index: Int64, value: Float64): Vector4 {
        if (index == 0) {
            this.x = value
        } else if (index == 1) {
            this.y = value
        } else if (index == 2) {
            this.z = value
        } else if (index == 3) {
            this.w = value
        } else {
            throw Exception("THREE.Vector4: index is out of range: " + index.toString())
        }
        return this
    }

    /**
     * @brief[zh-cn] 通过索引获取分量值（0=x, 1=y, 2=z, 3=w）
     * @param[zh-cn] index 分量索引
     * @return[zh-cn] 分量值
     *
     * @brief[en] Gets component value by index (0=x, 1=y, 2=z, 3=w)
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
        } else if (index == 3) {
            return this.w
        } else {
            throw Exception("THREE.Vector4: index is out of range: " + index.toString())
        }
    }

    /**
     * @brief[zh-cn] 克隆当前向量
     * @return[zh-cn] 新的向量实例
     *
     * @brief[en] Clones the current vector
     * @return[en] New vector instance
     */
    public func clone(): Vector4 {
        return Vector4(this.x, this.y, this.z, this.w)
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
    public func copy(v: Vector4): Vector4 {
        this.x = v.x
        this.y = v.y
        this.z = v.z
        this.w = v.w
        return this
    }

    /**
     * @brief[zh-cn] 将给定向量加到当前实例
     * @param[zh-cn] v 要添加的向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Adds the given vector to this instance
     * @param[en] v Vector to add
     * @return[en] This instance
     */
    public func add(v: Vector4): Vector4 {
        this.x += v.x
        this.y += v.y
        this.z += v.z
        this.w += v.w
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
    public func addScalar(s: Float64): Vector4 {
        this.x += s
        this.y += s
        this.z += s
        this.w += s
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
    public func addVectors(a: Vector4, b: Vector4): Vector4 {
        this.x = a.x + b.x
        this.y = a.y + b.y
        this.z = a.z + b.z
        this.w = a.w + b.w
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
    public func addScaledVector(v: Vector4, s: Float64): Vector4 {
        this.x += v.x * s
        this.y += v.y * s
        this.z += v.z * s
        this.w += v.w * s
        return this
    }

    /**
     * @brief[zh-cn] 从当前实例减去给定向量
     * @param[zh-cn] v 要减去的向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Subtracts the given vector from this instance
     * @param[en] v Vector to subtract
     * @return[en] This instance
     */
    public func sub(v: Vector4): Vector4 {
        this.x -= v.x
        this.y -= v.y
        this.z -= v.z
        this.w -= v.w
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
    public func subScalar(s: Float64): Vector4 {
        this.x -= s
        this.y -= s
        this.z -= s
        this.w -= s
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
    public func subVectors(a: Vector4, b: Vector4): Vector4 {
        this.x = a.x - b.x
        this.y = a.y - b.y
        this.z = a.z - b.z
        this.w = a.w - b.w
        return this
    }

    /**
     * @brief[zh-cn] 将当前实例与给定向量逐分量相乘
     * @param[zh-cn] v 乘数向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies this instance by the given vector component-wise
     * @param[en] v Multiplier vector
     * @return[en] This instance
     */
    public func multiply(v: Vector4): Vector4 {
        this.x *= v.x
        this.y *= v.y
        this.z *= v.z
        this.w *= v.w
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
    public func multiplyScalar(s: Float64): Vector4 {
        this.x *= s
        this.y *= s
        this.z *= s
        this.w *= s
        return this
    }

    /**
     * @brief[zh-cn] 将当前实例除以给定向量（逐分量）
     * @param[zh-cn] v 除数向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Divides this instance by the given vector component-wise
     * @param[en] v Divisor vector
     * @return[en] This instance
     */
    public func divide(v: Vector4): Vector4 {
        this.x /= v.x
        this.y /= v.y
        this.z /= v.z
        this.w /= v.w
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
    public func divideScalar(s: Float64): Vector4 {
        return this.multiplyScalar(1.0 / s)
    }

    /**
     * @brief[zh-cn] 将当前向量乘以给定 4x4 矩阵（按行向量乘法，无透视除法）
     * @param[zh-cn] m 4x4 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies this vector by the given 4x4 matrix (row vector multiplication, no perspective division)
     * @param[en] m 4x4 matrix
     * @return[en] This instance
     */
    public func applyMatrix4(m: Matrix4): Vector4 {
        let x = this.x; let y = this.y; let z = this.z; let w = this.w
        let e = m.elements
        this.x = e[0] * x + e[4] * y + e[8] * z + e[12] * w
        this.y = e[1] * x + e[5] * y + e[9] * z + e[13] * w
        this.z = e[2] * x + e[6] * y + e[10] * z + e[14] * w
        this.w = e[3] * x + e[7] * y + e[11] * z + e[15] * w
        return this
    }

    /**
     * @brief[zh-cn] 将各分量替换为当前向量与给定向量对应分量的较小值
     * @param[zh-cn] v 比较向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Replaces each component with the minimum of this and the given vector's corresponding component
     * @param[en] v Vector to compare
     * @return[en] This instance
     */
    public func min(v: Vector4): Vector4 {
        this.x = min(this.x, v.x)
        this.y = min(this.y, v.y)
        this.z = min(this.z, v.z)
        this.w = min(this.w, v.w)
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
    public func max(v: Vector4): Vector4 {
        this.x = max(this.x, v.x)
        this.y = max(this.y, v.y)
        this.z = max(this.z, v.z)
        this.w = max(this.w, v.w)
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
    public func clamp(min: Vector4, max: Vector4): Vector4 {
        this.x = clamp(this.x, min.x, max.x)
        this.y = clamp(this.y, min.y, max.y)
        this.z = clamp(this.z, min.z, max.z)
        this.w = clamp(this.w, min.w, max.w)
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
    public func clampScalar(minVal: Float64, maxVal: Float64): Vector4 {
        this.x = clamp(this.x, minVal, maxVal)
        this.y = clamp(this.y, minVal, maxVal)
        this.z = clamp(this.z, minVal, maxVal)
        this.w = clamp(this.w, minVal, maxVal)
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
    public func clampLength(min: Float64, max: Float64): Vector4 {
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
    public func floor(): Vector4 {
        this.x = floor(this.x)
        this.y = floor(this.y)
        this.z = floor(this.z)
        this.w = floor(this.w)
        return this
    }

    /**
     * @brief[zh-cn] 将分量向上取整
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components up to the nearest integer
     * @return[en] This instance
     */
    public func ceil(): Vector4 {
        this.x = ceil(this.x)
        this.y = ceil(this.y)
        this.z = ceil(this.z)
        this.w = ceil(this.w)
        return this
    }

    /**
     * @brief[zh-cn] 将分量四舍五入到最近整数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components to the nearest integer
     * @return[en] This instance
     */
    public func round(): Vector4 {
        this.x = round(this.x)
        this.y = round(this.y)
        this.z = round(this.z)
        this.w = round(this.w)
        return this
    }

    /**
     * @brief[zh-cn] 将分量向零取整（负数向上，正数向下）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rounds components toward zero (negative up, positive down)
     * @return[en] This instance
     */
    public func roundToZero(): Vector4 {
        this.x = if (this.x < 0.0) { ceil(this.x) } else { floor(this.x) }
        this.y = if (this.y < 0.0) { ceil(this.y) } else { floor(this.y) }
        this.z = if (this.z < 0.0) { ceil(this.z) } else { floor(this.z) }
        this.w = if (this.w < 0.0) { ceil(this.w) } else { floor(this.w) }
        return this
    }

    /**
     * @brief[zh-cn] 反转向量，即设置 x = -x, y = -y, z = -z, w = -w
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Negates the vector, setting x = -x, y = -y, z = -z, w = -w
     * @return[en] This instance
     */
    public func negate(): Vector4 {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        this.w = -this.w
        return this
    }

    /**
     * @brief[zh-cn] 计算与给定向量的点积
     * @param[zh-cn] v 另一个向量
     * @return[zh-cn] 点积结果
     *
     * @brief[en] Computes the dot product with the given vector
     * @param[en] v Another vector
     * @return[en] Dot product result
     */
    public func dot(v: Vector4): Float64 {
        return this.x * v.x + this.y * v.y + this.z * v.z + this.w * v.w
    }

    /**
     * @brief[zh-cn] 计算向量长度的平方
     * @return[zh-cn] 长度的平方
     *
     * @brief[en] Computes the squared length of the vector
     * @return[en] Squared length
     */
    public func lengthSq(): Float64 {
        return this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w
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
        return abs(this.x) + abs(this.y) + abs(this.z) + abs(this.w)
    }

    /**
     * @brief[zh-cn] 将当前向量转换为单位向量（长度为 1）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Converts this vector to a unit vector (length of 1)
     * @return[en] This instance
     */
    public func normalize(): Vector4 {
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
    public func setLength(length: Float64): Vector4 {
        return this.normalize().multiplyScalar(length)
    }

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
    public func lerp(v: Vector4, alpha: Float64): Vector4 {
        this.x += (v.x - this.x) * alpha
        this.y += (v.y - this.y) * alpha
        this.z += (v.z - this.z) * alpha
        this.w += (v.w - this.w) * alpha
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
    public func lerpVectors(v1: Vector4, v2: Vector4, alpha: Float64): Vector4 {
        this.x = v1.x + (v2.x - v1.x) * alpha
        this.y = v1.y + (v2.y - v1.y) * alpha
        this.z = v1.z + (v2.z - v1.z) * alpha
        this.w = v1.w + (v2.w - v1.w) * alpha
        return this
    }

    /**
     * @brief[zh-cn] 判断当前向量是否与给定向量相等
     * @param[zh-cn] v 比较向量
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Checks if this vector equals the given vector
     * @param[en] v Vector to compare
     * @return[en] Whether equal
     */
    public func equals(v: Vector4): Bool {
        return this.x == v.x && this.y == v.y && this.z == v.z && this.w == v.w
    }

    /**
     * @brief[zh-cn] 从顶点属性读取向量分量
     * @param[zh-cn] attribute 顶点属性（AttributeReader 接口，由 BufferAttribute 实现）
     * index 顶点索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Reads vector components from a vertex attribute (cf. JS: Vector4.fromBufferAttribute)
     * @param[en] attribute Vertex attribute (AttributeReader interface, implemented by BufferAttribute)
     * index Vertex index
     * @return[en] This instance
     */
    public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Vector4 {
        this.x = attribute.getX(index)
        this.y = attribute.getY(index)
        this.z = attribute.getZ(index)
        this.w = attribute.getW(index)
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
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Vector4 {
        this.x = array[offset]
        this.y = array[offset + 1]
        this.z = array[offset + 2]
        this.w = array[offset + 3]
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
        array[offset + 3] = this.w
        return array
    }

    /**
     * @brief[zh-cn] 将每个分量设置为 [0, 1) 之间的伪随机值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets each component to a pseudo-random value in [0, 1)
     * @return[en] This instance
     */
    public func random(): Vector4 {
        this.x = Random().nextFloat64()
        this.y = Random().nextFloat64()
        this.z = Random().nextFloat64()
        this.w = Random().nextFloat64()
        return this
    }

    /**
     * @brief[zh-cn] 从四元数设置轴角
     * @explain[zh-cn] 将四元数转换为轴角表示，结果存储在当前向量的 x, y, z 分量中，旋转角度存储在 w 分量中。
     * @param[zh-cn] q 四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets axis-angle from a quaternion
     * @explain[en] Converts a quaternion to axis-angle representation, storing the result in x, y, z components and the rotation angle in the w component.
     * @param[en] q Quaternion
     * @return[en] This instance
     */
    public func setAxisAngleFromQuaternion(q: Quaternion): Vector4 {
        // 假设四元数已归一化
        let s = sqrt(1.0 - q.w * q.w)
        if (s < 0.0001) {
            this.x = 1.0
            this.y = 0.0
            this.z = 0.0
            this.w = 0.0
        } else {
            this.x = q.x / s
            this.y = q.y / s
            this.z = q.z / s
            this.w = 2.0 * acos(q.w)
        }
        return this
    }

    /**
     * @brief[zh-cn] 从旋转矩阵设置轴角
     * @param[zh-cn] m 4x4 旋转矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets axis-angle from a rotation matrix
     * @param[en] m 4x4 rotation matrix
     * @return[en] This instance
     */
    public func setAxisAngleFromRotationMatrix(m: Matrix4): Vector4 {
        let te = m.elements
        let m11 = te[0]; let m12 = te[4]; let m13 = te[8]
        let m21 = te[1]; let m22 = te[5]; let m23 = te[9]
        let m31 = te[2]; let m32 = te[6]; let m33 = te[10]

        let epsilon = 0.01
        let epsilon2 = 0.1

        if (abs(m12 - m21) < epsilon && abs(m13 - m31) < epsilon && abs(m23 - m32) < epsilon) {
            // 对称矩阵情况
            if (abs(m12 + m21) < epsilon2 && abs(m13 + m31) < epsilon2 && abs(m23 + m32) < epsilon2 && abs(m11 + m22 + m33 - 3.0) < epsilon) {
                // 单位矩阵，无旋转
                this.w = 0.0
                this.x = 1.0
                this.y = 0.0
                this.z = 0.0
            } else {
                // 180度旋转
                this.w = PI
                let xx = (m11 + 1.0) / 2.0
                let yy = (m22 + 1.0) / 2.0
                let zz = (m33 + 1.0) / 2.0
                let xy = (m12 + m21) / 4.0
                let xz = (m13 + m31) / 4.0
                let yz = (m23 + m32) / 4.0

                if (xx > yy && xx > zz) {
                    this.x = sqrt(xx)
                    this.y = xy / this.x
                    this.z = xz / this.x
                } else if (yy > zz) {
                    this.y = sqrt(yy)
                    this.x = xy / this.y
                    this.z = yz / this.y
                } else {
                    this.z = sqrt(zz)
                    this.x = xz / this.z
                    this.y = yz / this.z
                }
            }
        } else {
            // 一般情况
            this.w = acos((m11 + m22 + m33 - 1.0) / 2.0)
            var s = sqrt((m32 - m23) * (m32 - m23) + (m13 - m31) * (m13 - m31) + (m21 - m12) * (m21 - m12))
            if (s < 0.001) { s = 1.0 }
            this.x = (m32 - m23) / s
            this.y = (m13 - m31) / s
            this.z = (m21 - m12) / s
        }

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
    public func setFromMatrixPosition(m: Matrix4): Vector4 {
        let e = m.elements
        this.x = e[12]
        this.y = e[13]
        this.z = e[14]
        this.w = 1.0
        return this
    }

    // ===== 运算符重载 =====

    public operator func +(v: Vector4): Vector4 {
        return Vector4(this.x + v.x, this.y + v.y, this.z + v.z, this.w + v.w)
    }

    public operator func -(v: Vector4): Vector4 {
        return Vector4(this.x - v.x, this.y - v.y, this.z - v.z, this.w - v.w)
    }

    public operator func *(s: Float64): Vector4 {
        return Vector4(this.x * s, this.y * s, this.z * s, this.w * s)
    }

    public operator func /(s: Float64): Vector4 {
        return Vector4(this.x / s, this.y / s, this.z / s, this.w / s)
    }

    public operator func -(): Vector4 {
        return Vector4(-this.x, -this.y, -this.z, -this.w)
    }
}
