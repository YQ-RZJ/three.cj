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
 * @file[zh-cn] QuaternionF
 * @brief[zh-cn] Float32 精度的四元数
 * @explain[zh-cn] 与 Quaternion (Float64) 功能等价，但使用 Float32 存储以减少内存占用。
 *                  主要用于骨骼动画内部计算（SoaTransform 旋转、采样、IK 等）。
 *                  不含 onChangeCallback（动画管线内部不需要变更通知）。
 *                  可与 Quaternion 双向转换。
 *
 * @file[en] QuaternionF
 * @brief[en] Float32-precision quaternion
 * @explain[en] Equivalent to Quaternion (Float64) but uses Float32 storage for reduced memory.
 *              Used for skeletal animation internal computation (SoaTransform rotation, sampling, IK, etc.).
 *              Does not include onChangeCallback (not needed inside animation pipeline).
 */
package three.core.math

import std.math.*

/**
 * @brief[zh-cn] Float32 四元数类，用于表示三维旋转
 * @explain[zh-cn] 格式为 (x, y, z, w)，其中 w 为标量部分。
 *                  用于骨骼动画内部计算，与 Quaternion (Float64) 功能等价。
 *
 * @brief[en] Float32 quaternion class for representing 3D rotations
 * @explain[en] Format is (x, y, z, w), where w is the scalar part.
 *              Used for skeletal animation internal computation, equivalent to Quaternion (Float64).
 */
public class QuaternionF {
    /**
     * @brief[zh-cn] x 分量
     *
     * @brief[en] x component
     */
    public var x: Float32

    /**
     * @brief[zh-cn] y 分量
     *
     * @brief[en] y component
     */
    public var y: Float32

    /**
     * @brief[zh-cn] z 分量
     *
     * @brief[en] z component
     */
    public var z: Float32

    /**
     * @brief[zh-cn] w 分量（标量部分）
     *
     * @brief[en] w component (scalar part)
     */
    public var w: Float32

    /**
     * @brief[zh-cn] 默认构造函数，初始化为单位四元数 (0,0,0,1)
     *
     * @brief[en] Default constructor, initializes to identity quaternion (0,0,0,1)
     */
    public init() {
        this.x = 0.0f32
        this.y = 0.0f32
        this.z = 0.0f32
        this.w = 1.0f32
    }

    /**
     * @brief[zh-cn] 使用指定分量构造四元数
     * @param[zh-cn] x x 分量
     * y y 分量
     * z z 分量
     * w w 分量
     *
     * @brief[en] Construct quaternion with specified components
     * @param[en] x x component
     * y y component
     * z z component
     * w w component
     */
    public init(x: Float32, y: Float32, z: Float32, w: Float32) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }

    // ===== 设置 =====

    /**
     * @brief[zh-cn] 设置四元数分量
     * @param[zh-cn] x x 分量
     * y y 分量
     * z z 分量
     * w w 分量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set quaternion components
     * @param[en] x x component
     * y y component
     * z z component
     * w w component
     * @return[en] This instance
     */
    public func set(x: Float32, y: Float32, z: Float32, w: Float32): QuaternionF {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前四元数
     * @return[zh-cn] 新的四元数实例
     *
     * @brief[en] Clone this quaternion
     * @return[en] A new quaternion instance
     */
    public func clone(): QuaternionF {
        QuaternionF(this.x, this.y, this.z, this.w)
    }

    /**
     * @brief[zh-cn] 复制另一个四元数的值到当前实例
     * @param[zh-cn] q 源四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy another quaternion's values to this instance
     * @param[en] q Source quaternion
     * @return[en] This instance
     */
    public func copy(q: QuaternionF): QuaternionF {
        this.x = q.x
        this.y = q.y
        this.z = q.z
        this.w = q.w
        return this
    }

    // ===== 基本运算 =====

    /**
     * @brief[zh-cn] 计算四元数长度的平方
     * @return[zh-cn] 长度的平方
     *
     * @brief[en] Calculate the squared length of the quaternion
     * @return[en] Squared length
     */
    public func lengthSq(): Float32 {
        this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w
    }

    /**
     * @brief[zh-cn] 计算四元数的欧几里得长度
     * @return[zh-cn] 长度
     *
     * @brief[en] Calculate the Euclidean length of the quaternion
     * @return[en] Length
     */
    public func length(): Float32 {
        sqrt(this.lengthSq())
    }

    /**
     * @brief[zh-cn] 将四元数归一化为单位长度，如果长度为 0 则设置为单位四元数 (0,0,0,1)
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Normalize the quaternion to unit length; if length is 0, set to identity (0,0,0,1)
     * @return[en] This instance
     */
    public func normalize(): QuaternionF {
        let len = this.length()
        if (len == 0.0f32) {
            this.x = 0.0f32
            this.y = 0.0f32
            this.z = 0.0f32
            this.w = 1.0f32
        } else {
            this.multiplyScalar(1.0f32 / len)
        }
        return this
    }

    /**
     * @brief[zh-cn] 将四元数的每个分量乘以标量
     * @param[zh-cn] s 标量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiply each component of the quaternion by a scalar
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func multiplyScalar(s: Float32): QuaternionF {
        this.x *= s
        this.y *= s
        this.z *= s
        this.w *= s
        return this
    }

    /**
     * @brief[zh-cn] 将当前四元数乘以给定四元数
     * @param[zh-cn] q 四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiply this quaternion by the given quaternion
     * @param[en] q Quaternion
     * @return[en] This instance
     */
    public func multiply(q: QuaternionF): QuaternionF {
        this.multiplyQuaternions(this, q)
    }

    /**
     * @brief[zh-cn] 将给定四元数乘以当前四元数（前乘）
     * @param[zh-cn] q 四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Pre-multiply the given quaternion with this quaternion
     * @param[en] q Quaternion
     * @return[en] This instance
     */
    public func premultiply(q: QuaternionF): QuaternionF {
        this.multiplyQuaternions(q, this)
    }

    /**
     * @brief[zh-cn] 将两个四元数相乘并将结果存储在当前实例
     * @param[zh-cn] a 第一个四元数
     * b 第二个四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiply two quaternions and store the result in this instance
     * @param[en] a First quaternion
     * b Second quaternion
     * @return[en] This instance
     */
    public func multiplyQuaternions(a: QuaternionF, b: QuaternionF): QuaternionF {
        let qax = a.x; let qay = a.y; let qaz = a.z; let qaw = a.w
        let qbx = b.x; let qby = b.y; let qbz = b.z; let qbw = b.w
        this.x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby
        this.y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz
        this.z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx
        this.w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz
        return this
    }

    /**
     * @brief[zh-cn] 计算四元数的共轭（反转旋转方向），假设四元数为单位四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Calculate the conjugate of the quaternion (reverse rotation direction), assuming unit quaternion
     * @return[en] This instance
     */
    public func conjugate(): QuaternionF {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        return this
    }

    /**
     * @brief[zh-cn] 反转四元数（假设为单位四元数，等价于共轭）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Invert the quaternion (equivalent to conjugate for unit quaternions)
     * @return[en] This instance
     */
    public func invert(): QuaternionF {
        this.conjugate()
    }

    /**
     * @brief[zh-cn] 计算与给定四元数的点积
     * @param[zh-cn] q 另一个四元数
     * @return[zh-cn] 点积结果
     *
     * @brief[en] Calculate the dot product with the given quaternion
     * @param[en] q Another quaternion
     * @return[en] Dot product result
     */
    public func dot(q: QuaternionF): Float32 {
        this.x * q.x + this.y * q.y + this.z * q.z + this.w * q.w
    }

    // ===== 旋转设置 =====

    /**
     * @brief[zh-cn] 从轴角设置四元数
     * @param[zh-cn] axis 旋转轴（应为单位向量）
     * angle 旋转角度（弧度）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set quaternion from axis-angle
     * @param[en] axis Rotation axis (should be a unit vector)
     * angle Rotation angle in radians
     * @return[en] This instance
     */
    public func setFromAxisAngle(axis: Vector3F, angle: Float32): QuaternionF {
        let half = angle * 0.5f32
        let s = sin(half)
        this.x = axis.x * s
        this.y = axis.y * s
        this.z = axis.z * s
        this.w = cos(half)
        return this
    }

    /**
     * @brief[zh-cn] 从旋转矩阵设置四元数
     * @param[zh-cn] m 4x4 旋转矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set quaternion from rotation matrix
     * @param[en] m 4x4 rotation matrix
     * @return[en] This instance
     */
    public func setFromRotationMatrix(m: Matrix4F): QuaternionF {
        let te = m.elements
        let m11 = te[0]; let m12 = te[4]; let m13 = te[8]
        let m21 = te[1]; let m22 = te[5]; let m23 = te[9]
        let m31 = te[2]; let m32 = te[6]; let m33 = te[10]
        let trace = m11 + m22 + m33

        if (trace > 0.0f32) {
            let s = 0.5f32 / sqrt(trace + 1.0f32)
            this.w = 0.25f32 / s
            this.x = (m32 - m23) * s
            this.y = (m13 - m31) * s
            this.z = (m21 - m12) * s
        } else if (m11 > m22 && m11 > m33) {
            let s = 2.0f32 * sqrt(1.0f32 + m11 - m22 - m33)
            this.w = (m32 - m23) / s
            this.x = 0.25f32 * s
            this.y = (m12 + m21) / s
            this.z = (m13 + m31) / s
        } else if (m22 > m33) {
            let s = 2.0f32 * sqrt(1.0f32 + m22 - m11 - m33)
            this.w = (m13 - m31) / s
            this.x = (m12 + m21) / s
            this.y = 0.25f32 * s
            this.z = (m23 + m32) / s
        } else {
            let s = 2.0f32 * sqrt(1.0f32 + m33 - m11 - m22)
            this.w = (m21 - m12) / s
            this.x = (m13 + m31) / s
            this.y = (m23 + m32) / s
            this.z = 0.25f32 * s
        }

        return this
    }

    // ===== 插值 =====

    /**
     * @brief[zh-cn] 球面线性插值（SLERP）
     * @param[zh-cn] qb 目标四元数
     * t 插值因子，闭区间 [0, 1]
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Spherical linear interpolation (SLERP)
     * @param[en] qb Target quaternion
     * t Interpolation factor, closed interval [0, 1]
     * @return[en] This instance
     */
    public func slerp(qb: QuaternionF, t: Float32): QuaternionF {
        if (t == 0.0f32) { return this }
        if (t == 1.0f32) { return this.copy(qb) }

        var cosHalfTheta = this.dot(qb)

        if (cosHalfTheta < 0.0f32) {
            this.negate()
            cosHalfTheta = -cosHalfTheta
        }

        if (cosHalfTheta >= 1.0f32) { return this }

        let sinHalfTheta = sqrt(1.0f32 - cosHalfTheta * cosHalfTheta)

        if (sinHalfTheta < 0.001f32) {
            // 角度很小，使用线性插值
            this.x = (this.x + qb.x) * 0.5f32
            this.y = (this.y + qb.y) * 0.5f32
            this.z = (this.z + qb.z) * 0.5f32
            this.w = (this.w + qb.w) * 0.5f32
            return this
        }

        let halfTheta = acos(cosHalfTheta)
        let ratioA = sin((1.0f32 - t) * halfTheta) / sinHalfTheta
        let ratioB = sin(t * halfTheta) / sinHalfTheta

        this.x = this.x * ratioA + qb.x * ratioB
        this.y = this.y * ratioA + qb.y * ratioB
        this.z = this.z * ratioA + qb.z * ratioB
        this.w = this.w * ratioA + qb.w * ratioB

        return this
    }

    /**
     * @brief[zh-cn] 在两个四元数之间进行球面线性插值，结果存储在当前实例
     * @param[zh-cn] qa 第一个四元数
     * qb 第二个四元数
     * t 插值因子
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Perform spherical linear interpolation between two quaternions, store result in this instance
     * @param[en] qa First quaternion
     * qb Second quaternion
     * t Interpolation factor
     * @return[en] This instance
     */
    public func slerpQuaternions(qa: QuaternionF, qb: QuaternionF, t: Float32): QuaternionF {
        this.copy(qa).slerp(qb, t)
    }

    // ===== 其他操作 =====

    /**
     * @brief[zh-cn] 取反四元数的所有分量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Negate all components of the quaternion
     * @return[en] This instance
     */
    public func negate(): QuaternionF {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        this.w = -this.w
        return this
    }

    /**
     * @brief[zh-cn] 计算与另一个四元数之间的角度
     * @param[zh-cn] q 另一个四元数
     * @return[zh-cn] 两个四元数之间的角度（弧度）
     *
     * @brief[en] Calculate the angle between this and another quaternion
     * @param[en] q Another quaternion
     * @return[en] Angle between the two quaternions in radians
     */
    public func angleTo(q: QuaternionF): Float32 {
        let d = min(abs(this.dot(q)), 1.0f32)
        2.0f32 * acos(d)
    }

    /**
     * @brief[zh-cn] 设置为单位四元数 (0,0,0,1)
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set to identity quaternion (0,0,0,1)
     * @return[en] This instance
     */
    public func identity(): QuaternionF {
        this.set(0.0f32, 0.0f32, 0.0f32, 1.0f32)
    }

    /**
     * @brief[zh-cn] 比较两个四元数是否相等
     * @param[zh-cn] q 另一个四元数
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Compare two quaternions for equality
     * @param[en] q Another quaternion
     * @return[en] Whether equal
     */
    public func equals(q: QuaternionF): Bool {
        this.x == q.x && this.y == q.y && this.z == q.z && this.w == q.w
    }

    // ===== 转换 =====

    /**
     * @brief[zh-cn] 从 Quaternion (Float64) 转换为 QuaternionF
     * @param[zh-cn] q Float64 四元数
     * @return[zh-cn] Float32 四元数
     *
     * @brief[en] Convert from Quaternion (Float64) to QuaternionF
     * @param[en] q Float64 quaternion
     * @return[en] Float32 quaternion
     */
    public static func fromQuaternion(q: Quaternion): QuaternionF {
        QuaternionF(Float32(q.x), Float32(q.y), Float32(q.z), Float32(q.w))
    }

    /**
     * @brief[zh-cn] 转换为 Quaternion (Float64)
     * @return[zh-cn] Float64 四元数
     *
     * @brief[en] Convert to Quaternion (Float64)
     * @return[en] Float64 quaternion
     */
    public func toQuaternion(): Quaternion {
        Quaternion(Float64(this.x), Float64(this.y), Float64(this.z), Float64(this.w))
    }

    /**
     * @brief[zh-cn] 转换为 Array<Float32>（长度4）
     * @return[zh-cn] Float32 数组
     *
     * @brief[en] Convert to Array<Float32> (length 4)
     * @return[en] Float32 array
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
     * @param[zh-cn] arr Float32 数组
     * @return[zh-cn] QuaternionF 实例
     *
     * @brief[en] Construct from Array<Float32> (length 4)
     * @param[en] arr Float32 array
     * @return[en] QuaternionF instance
     */
    public static func fromArray(arr: Array<Float32>): QuaternionF {
        QuaternionF(arr[0], arr[1], arr[2], arr[3])
    }
}
