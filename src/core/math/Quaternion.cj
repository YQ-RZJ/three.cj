/**
 * @file[zh-cn] Quaternion
 * @brief[zh-cn] 四元数
 * @explain[zh-cn] 表示三维空间中的旋转，使用四元数 (x, y, z, w) 表示，其中 w 为标量部分。Three.js 假设四元数始终为单位四元数（长度为 1）。
 *
 * @file[en] Quaternion
 * @brief[en] Quaternion
 * @explain[en] Represents rotation in 3D space using quaternion (x, y, z, w), where w is the scalar part. Three.js assumes quaternions are always unit quaternions (length 1).
 */
package three.core.math

import std.math.*
import std.random.*
import three.core.interfaces.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 四元数类，用于表示三维旋转
 * @explain[zh-cn] 格式为 (x, y, z, w)，其中 w 为标量部分
 *
 * @brief[en] Quaternion class for representing 3D rotations
 * @explain[en] Format is (x, y, z, w), where w is the scalar part
 */
@JsonAdapter
public class Quaternion {
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
     * @brief[zh-cn] w 分量（标量部分）
     *
     * @brief[en] w component (scalar part)
     */
    public var w: Float64

    /**
     * @brief[zh-cn] 变更回调函数，当四元数值改变时调用（函数类型，不支持序列化）
     */
    @JsonIgnore
    private var _onChangeCallback: () -> Unit

    /**
     * @brief[zh-cn] 默认构造函数，初始化为单位四元数 (0,0,0,1)
     *
     * @brief[en] Default constructor, initializes to identity quaternion (0,0,0,1)
     */
    public init() {
        this.x = 0.0
        this.y = 0.0
        this.z = 0.0
        this.w = 1.0
        this._onChangeCallback = { => }
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
    public init(x: Float64, y: Float64, z: Float64, w: Float64) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
        this._onChangeCallback = { => }
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
    public func set(x: Float64, y: Float64, z: Float64, w: Float64): Quaternion {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前四元数
     * @return[zh-cn] 新的四元数实例
     *
     * @brief[en] Clone this quaternion
     * @return[en] A new quaternion instance
     */
    public func clone(): Quaternion {
        return Quaternion(this.x, this.y, this.z, this.w)
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
    public func copy(q: Quaternion): Quaternion {
        this.x = q.x
        this.y = q.y
        this.z = q.z
        this.w = q.w
        this._onChangeCallback()
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
    public func lengthSq(): Float64 {
        return this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w
    }

    /**
     * @brief[zh-cn] 计算四元数的欧几里得长度
     * @return[zh-cn] 长度
     *
     * @brief[en] Calculate the Euclidean length of the quaternion
     * @return[en] Length
     */
    public func length(): Float64 {
        return sqrt(this.lengthSq())
    }

    /**
     * @brief[zh-cn] 将四元数归一化为单位长度，如果长度为 0 则设置为单位四元数 (0,0,0,1)
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Normalize the quaternion to unit length; if length is 0, set to identity (0,0,0,1)
     * @return[en] This instance
     */
    public func normalize(): Quaternion {
        let len = this.length()
        if (len == 0.0) {
            this.x = 0.0
            this.y = 0.0
            this.z = 0.0
            this.w = 1.0
        } else {
            this.multiplyScalar(1.0 / len)
        }
        this._onChangeCallback()
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
    public func multiplyScalar(s: Float64): Quaternion {
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
    public func multiply(q: Quaternion): Quaternion {
        return this.multiplyQuaternions(this, q)
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
    public func premultiply(q: Quaternion): Quaternion {
        return this.multiplyQuaternions(q, this)
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
    public func multiplyQuaternions(a: Quaternion, b: Quaternion): Quaternion {
        let qax = a.x; let qay = a.y; let qaz = a.z; let qaw = a.w
        let qbx = b.x; let qby = b.y; let qbz = b.z; let qbw = b.w
        this.x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby
        this.y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz
        this.z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx
        this.w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 计算四元数的共轭（反转旋转方向），假设四元数为单位四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Calculate the conjugate of the quaternion (reverse rotation direction), assuming unit quaternion
     * @return[en] This instance
     */
    public func conjugate(): Quaternion {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 反转四元数（假设为单位四元数，等价于共轭）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Invert the quaternion (equivalent to conjugate for unit quaternions)
     * @return[en] This instance
     */
    public func invert(): Quaternion {
        return this.conjugate()
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
    public func dot(q: Quaternion): Float64 {
        return this.x * q.x + this.y * q.y + this.z * q.z + this.w * q.w
    }

    // ===== 旋转设置 =====

    /**
     * @brief[zh-cn] 从旋转矩阵设置四元数
     * @param[zh-cn] m 4x4 旋转矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set quaternion from rotation matrix
     * @param[en] m 4x4 rotation matrix
     * @return[en] This instance
     */
    public func setFromRotationMatrix(m: Matrix4): Quaternion {
        let te = m.elements
        let m11 = te[0]; let m12 = te[4]; let m13 = te[8]
        let m21 = te[1]; let m22 = te[5]; let m23 = te[9]
        let m31 = te[2]; let m32 = te[6]; let m33 = te[10]
        let trace = m11 + m22 + m33

        if (trace > 0.0) {
            let s = 0.5 / sqrt(trace + 1.0)
            this.w = 0.25 / s
            this.x = (m32 - m23) * s
            this.y = (m13 - m31) * s
            this.z = (m21 - m12) * s
        } else if (m11 > m22 && m11 > m33) {
            let s = 2.0 * sqrt(1.0 + m11 - m22 - m33)
            this.w = (m32 - m23) / s
            this.x = 0.25 * s
            this.y = (m12 + m21) / s
            this.z = (m13 + m31) / s
        } else if (m22 > m33) {
            let s = 2.0 * sqrt(1.0 + m22 - m11 - m33)
            this.w = (m13 - m31) / s
            this.x = (m12 + m21) / s
            this.y = 0.25 * s
            this.z = (m23 + m32) / s
        } else {
            let s = 2.0 * sqrt(1.0 + m33 - m11 - m22)
            this.w = (m21 - m12) / s
            this.x = (m13 + m31) / s
            this.y = (m23 + m32) / s
            this.z = 0.25 * s
        }

        this._onChangeCallback()
        return this
    }

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
    public func setFromAxisAngle(axis: Vector3, angle: Float64): Quaternion {
        let half = angle / 2.0
        let s = sin(half)
        this.x = axis.x * s
        this.y = axis.y * s
        this.z = axis.z * s
        this.w = cos(half)
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 从欧拉角设置四元数
     * @param[zh-cn] euler 欧拉角
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set quaternion from Euler angles
     * @param[en] euler Euler angles
     * @return[en] This instance
     */
    public func setFromEuler(euler: Euler): Quaternion {
             let c1 = cos(euler.x / 2.0); let c2 = cos(euler.y / 2.0); let c3 = cos(euler.z / 2.0)
             let s1 = sin(euler.x / 2.0); let s2 = sin(euler.y / 2.0); let s3 = sin(euler.z / 2.0)

             match (euler.order) {
                 case EulerOrder.XYZ =>
                     this.x = s1 * c2 * c3 + c1 * s2 * s3
                     this.y = c1 * s2 * c3 - s1 * c2 * s3
                     this.z = c1 * c2 * s3 + s1 * s2 * c3
                     this.w = c1 * c2 * c3 - s1 * s2 * s3
                 case EulerOrder.YXZ =>
                     this.x = s1 * c2 * c3 + c1 * s2 * s3
                     this.y = c1 * s2 * c3 - s1 * c2 * s3
                     this.z = c1 * c2 * s3 - s1 * s2 * c3
                     this.w = c1 * c2 * c3 + s1 * s2 * s3
                 case EulerOrder.ZXY =>
                     this.x = s1 * c2 * c3 - c1 * s2 * s3
                     this.y = c1 * s2 * c3 + s1 * c2 * s3
                     this.z = c1 * c2 * s3 + s1 * s2 * c3
                     this.w = c1 * c2 * c3 - s1 * s2 * s3
                 case EulerOrder.ZYX =>
                     this.x = s1 * c2 * c3 - c1 * s2 * s3
                     this.y = c1 * s2 * c3 + s1 * c2 * s3
                     this.z = c1 * c2 * s3 - s1 * c2 * c3
                     this.w = c1 * c2 * c3 + s1 * s2 * s3
                 case EulerOrder.YZX =>
                     this.x = s1 * c2 * c3 + c1 * s2 * s3
                     this.y = c1 * s2 * c3 + s1 * c2 * s3
                     this.z = c1 * c2 * s3 - s1 * s2 * c3
                     this.w = c1 * c2 * c3 + s1 * s2 * s3
                 case EulerOrder.XZY =>
                     this.x = s1 * c2 * c3 - c1 * s2 * s3
                     this.y = c1 * s2 * c3 - s1 * c2 * s3
                     this.z = c1 * c2 * s3 + s1 * s2 * c3
                     this.w = c1 * c2 * c3 + s1 * s2 * s3
             }

             return this
         }

    /**
     * @brief[zh-cn] 从两个单位向量设置四元数旋转
     * @param[zh-cn] vFrom 起始方向向量（应为单位向量）
     * vTo 目标方向向量（应为单位向量）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set quaternion rotation from two unit vectors
     * @param[en] vFrom Source direction vector (should be a unit vector)
     * vTo Target direction vector (should be a unit vector)
     * @return[en] This instance
     */
    public func setFromUnitVectors(vFrom: Vector3, vTo: Vector3): Quaternion {
        let r = vFrom.dot(vTo) + 1.0

        if (r < 0.000001) {
            // vFrom 和 vTo 方向相反
            if (abs(vFrom.x) > abs(vFrom.z)) {
                this.set(-vFrom.y, vFrom.x, 0.0, 0.0)
            } else {
                this.set(0.0, -vFrom.z, vFrom.x, 0.0)
            }
        } else {
            this.set(
                vFrom.y * vTo.z - vFrom.z * vTo.y,
                vFrom.z * vTo.x - vFrom.x * vTo.z,
                vFrom.x * vTo.y - vFrom.y * vTo.x,
                r
            )
        }

        return this.normalize()
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
    public func slerp(qb: Quaternion, t: Float64): Quaternion {
        if (t == 0.0) { return this }
        if (t == 1.0) { return this.copy(qb) }

        var cosHalfTheta = this.dot(qb)

        if (cosHalfTheta < 0.0) {
            this.negate()
            cosHalfTheta = -cosHalfTheta
        }

        if (cosHalfTheta >= 1.0) { return this }

        let sinHalfTheta = sqrt(1.0 - cosHalfTheta * cosHalfTheta)

        if (sinHalfTheta < 0.001) {
            // 角度很小，使用线性插值
            this.x = (this.x + qb.x) * 0.5
            this.y = (this.y + qb.y) * 0.5
            this.z = (this.z + qb.z) * 0.5
            this.w = (this.w + qb.w) * 0.5
            return this
        }

        let halfTheta = acos(cosHalfTheta)
        let ratioA = sin((1.0 - t) * halfTheta) / sinHalfTheta
        let ratioB = sin(t * halfTheta) / sinHalfTheta

        this.x = this.x * ratioA + qb.x * ratioB
        this.y = this.y * ratioA + qb.y * ratioB
        this.z = this.z * ratioA + qb.z * ratioB
        this.w = this.w * ratioA + qb.w * ratioB

        this._onChangeCallback()
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
    public func slerpQuaternions(qa: Quaternion, qb: Quaternion, t: Float64): Quaternion {
        return this.copy(qa).slerp(qb, t)
    }

    // ===== 其他操作 =====

    /**
     * @brief[zh-cn] 取反四元数的所有分量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Negate all components of the quaternion
     * @return[en] This instance
     */
    public func negate(): Quaternion {
        this.x = -this.x
        this.y = -this.y
        this.z = -this.z
        this.w = -this.w
        return this
    }

    /**
     * @brief[zh-cn] 计算当前四元数与给定四元数之间的角度（弧度）
     * @param[zh-cn] q 另一个四元数
     * @return[zh-cn] 角度（弧度）
     *
     * @brief[en] Calculate the angle in radians between this quaternion and the given quaternion
     * @param[en] q Another quaternion
     * @return[en] Angle in radians
     */
    public func angleTo(q: Quaternion): Float64 {
        return 2.0 * acos(abs(clamp(this.dot(q), -1.0, 1.0)))
    }

    /**
     * @brief[zh-cn] 使用当前四元数旋转向量
     * @param[zh-cn] v 要旋转的向量
     * @return[zh-cn] 旋转后的新向量
     *
     * @brief[en] Rotate a vector using this quaternion
     * @param[en] v Vector to rotate
     * @return[en] New rotated vector
     */
    public func rotateVector(v: Vector3): Vector3 {
        return v.clone().applyQuaternion(this)
    }

    /**
     * @brief[zh-cn] 旋转当前四元数朝向目标四元数，最大步长为 step（弧度）
     * @param[zh-cn] q 目标四元数
     * step 最大旋转角度（弧度）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rotate this quaternion towards the target quaternion with a maximum step in radians
     * @param[en] q Target quaternion
     * step Maximum rotation angle in radians
     * @return[en] This instance
     */
    public func rotateTowards(q: Quaternion, step: Float64): Quaternion {
        let angle = this.angleTo(q)
        if (angle == 0.0) {
            return this
        }
        let t = min(1.0, step / angle)
        return this.slerp(q, t)
    }

    /**
     * @brief[zh-cn] 将四元数设置为单位四元数（无旋转）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the quaternion to identity (no rotation)
     * @return[en] This instance
     */
    public func identity(): Quaternion {
        return this.set(0.0, 0.0, 0.0, 1.0)
    }

    /**
     * @brief[zh-cn] 判断当前四元数是否与给定四元数相等
     * @param[zh-cn] q 另一个四元数
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if this quaternion equals the given quaternion
     * @param[en] q Another quaternion
     * @return[en] Whether equal
     */
    public func equals(q: Quaternion): Bool {
        return this.x == q.x && this.y == q.y && this.z == q.z && this.w == q.w
    }

    /**
     * @brief[zh-cn] 将四元数设置为随机单位四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the quaternion to a random unit quaternion
     * @return[en] This instance
     */
    public func random(): Quaternion {
        let theta = Random().nextFloat64() * PI * 2.0
        let u1 = Random().nextFloat64()
        let u2 = Random().nextFloat64()
        let sqrt1MinusU1 = sqrt(1.0 - u1)
        let sqrtU1 = sqrt(u1)
        this.x = sqrt1MinusU1 * sin(theta)
        this.y = sqrt1MinusU1 * cos(theta)
        this.z = sqrtU1 * sin(u2 * PI * 2.0)
        this.w = sqrtU1 * cos(u2 * PI * 2.0)
        this._onChangeCallback()
        return this
    }

    // ===== 数组操作 =====

    /**
     * @brief[zh-cn] 从顶点属性读取四元数分量
     * @param[zh-cn] attribute 顶点属性（AttributeReader 接口，由 BufferAttribute 实现）
     * index 顶点索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Read quaternion components from vertex attribute (aligned with JS: Quaternion.fromBufferAttribute)
     * @param[en] attribute Vertex attribute (AttributeReader interface, implemented by BufferAttribute)
     * index Vertex index
     * @return[en] This instance
     */
    public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Quaternion {
        this.x = attribute.getX(index)
        this.y = attribute.getY(index)
        this.z = attribute.getZ(index)
        this.w = attribute.getW(index)
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 从数组设置四元数分量
     * @param[zh-cn] array 包含分量值的数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set quaternion components from an array
     * @param[en] array Array containing component values
     * offset Starting index, defaults to 0
     * @return[en] This instance
     */
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Quaternion {
        this.x = array[offset]
        this.y = array[offset + 1]
        this.z = array[offset + 2]
        this.w = array[offset + 3]
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 将四元数分量写入数组
     * @param[zh-cn] array 目标数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 包含分量值的数组
     *
     * @brief[en] Write quaternion components to an array
     * @param[en] array Target array
     * offset Starting index, defaults to 0
     * @return[en] Array containing component values
     */
    public func toArray(array: Array<Float64>, offset!: Int64 = 0): Array<Float64> {
        array[offset] = this.x
        array[offset + 1] = this.y
        array[offset + 2] = this.z
        array[offset + 3] = this.w
        return array
    }

    // ===== 回调 =====

    /**
     * @brief[zh-cn] 设置变更回调函数，当四元数的值被修改时回调函数将被调用
     * @param[zh-cn] callback 回调函数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the change callback function, which will be called when the quaternion value is modified
     * @param[en] callback Callback function
     * @return[en] This instance
     */
    public func onChange(callback: () -> Unit): Quaternion {
        this._onChangeCallback = callback
        return this
    }

    // ===== 静态方法 =====

    /**
     * @brief[zh-cn] 在两个四元数之间进行球面线性插值（扁平数组版本）
     * @param[zh-cn] dst 目标数组
     * dstOffset 目标偏移
     * src0 第一个源数组
     * srcOffset0 第一个源偏移
     * src1 第二个源数组
     * srcOffset1 第二个源偏移
     * t 插值因子
     *
     * @brief[en] Perform spherical linear interpolation between two quaternions (flat array version)
     * @param[en] dst Destination array
     * dstOffset Destination offset
     * src0 First source array
     * srcOffset0 First source offset
     * src1 Second source array
     * srcOffset1 Second source offset
     * t Interpolation factor
     */
    public static func slerpFlat(dst: Array<Float64>, dstOffset: Int64, src0: Array<Float64>, srcOffset0: Int64, src1: Array<Float64>, srcOffset1: Int64, t: Float64): Unit {
        var x0 = src0[srcOffset0 + 0]
        var y0 = src0[srcOffset0 + 1]
        var z0 = src0[srcOffset0 + 2]
        var w0 = src0[srcOffset0 + 3]

        var x1 = src1[srcOffset1 + 0]
        var y1 = src1[srcOffset1 + 1]
        var z1 = src1[srcOffset1 + 2]
        var w1 = src1[srcOffset1 + 3]

        if (w0 != w1 || x0 != x1 || y0 != y1 || z0 != z1) {
            var dot = x0 * x1 + y0 * y1 + z0 * z1 + w0 * w1

            if (dot < 0.0) {
                x1 = -x1; y1 = -y1; z1 = -z1; w1 = -w1
                dot = -dot
            }

            var s = 1.0 - t

            if (dot < 0.9995) {
                let theta = acos(dot)
                let sinTheta = sin(theta)
                let s2 = sin(s * theta) / sinTheta
                let t2 = sin(t * theta) / sinTheta

                x0 = x0 * s2 + x1 * t2
                y0 = y0 * s2 + y1 * t2
                z0 = z0 * s2 + z1 * t2
                w0 = w0 * s2 + w1 * t2
            } else {
                x0 = x0 * s + x1 * t
                y0 = y0 * s + y1 * t
                z0 = z0 * s + z1 * t
                w0 = w0 * s + w1 * t

                let f = 1.0 / sqrt(x0 * x0 + y0 * y0 + z0 * z0 + w0 * w0)
                x0 *= f; y0 *= f; z0 *= f; w0 *= f
            }
        }

        dst[dstOffset] = x0
        dst[dstOffset + 1] = y0
        dst[dstOffset + 2] = z0
        dst[dstOffset + 3] = w0
    }

    /**
     * @brief[zh-cn] 将两个四元数相乘（扁平数组版本）
     * @param[zh-cn] dst 目标数组
     * dstOffset 目标偏移
     * src0 第一个源数组
     * srcOffset0 第一个源偏移
     * src1 第二个源数组
     * srcOffset1 第二个源偏移
     *
     * @brief[en] Multiply two quaternions (flat array version)
     * @param[en] dst Destination array
     * dstOffset Destination offset
     * src0 First source array
     * srcOffset0 First source offset
     * src1 Second source array
     * srcOffset1 Second source offset
     */
    public static func multiplyQuaternionsFlat(dst: Array<Float64>, dstOffset: Int64, src0: Array<Float64>, srcOffset0: Int64, src1: Array<Float64>, srcOffset1: Int64): Unit {
        let x0 = src0[srcOffset0]; let y0 = src0[srcOffset0 + 1]; let z0 = src0[srcOffset0 + 2]; let w0 = src0[srcOffset0 + 3]
        let x1 = src1[srcOffset1]; let y1 = src1[srcOffset1 + 1]; let z1 = src1[srcOffset1 + 2]; let w1 = src1[srcOffset1 + 3]
        dst[dstOffset] = x0 * w1 + w0 * x1 + y0 * z1 - z0 * y1
        dst[dstOffset + 1] = y0 * w1 + w0 * y1 + z0 * x1 - x0 * z1
        dst[dstOffset + 2] = z0 * w1 + w0 * z1 + x0 * y1 - y0 * x1
        dst[dstOffset + 3] = w0 * w1 - x0 * x1 - y0 * y1 - z0 * z1
    }
}
