/**
 * @file[zh-cn] SphericalHarmonics3
 * @brief[zh-cn] 球面调和函数
 * @explain[zh-cn] 表示三阶球面调和系数，用于环境光照。
 *
 * @file[en] SphericalHarmonics3
 * @brief[en] Spherical harmonics
 * @explain[en] Represents third-order spherical harmonic coefficients, used for ambient lighting.
 */
package three.core.math

import std.math.*

/**
 * @brief[zh-cn] 球面调和系数类，包含 9 个三阶系数向量
 *
 * @brief[en] Spherical harmonics coefficient class, containing 9 third-order coefficient vectors
 */
public class SphericalHarmonics3 {
    /**
     * @brief[zh-cn] 球面调和系数数组，包含 9 个 Vector3
     *
     * @brief[en] Spherical harmonics coefficient array, containing 9 Vector3 instances
     */
    public var coefficients: Array<Vector3>

    public init() {
        this.coefficients = Array<Vector3>(9, { _ => Vector3() })
    }

    /**
     * @brief[zh-cn] 设置球面调和系数
     * @param[zh-cn] coefficients 系数数组
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set spherical harmonics coefficients
     * @param[en] coefficients Coefficient array
     * @return[en] This instance
     */
    public func set(coefficients: Array<Vector3>): SphericalHarmonics3 {
        for (i in 0..9) {
            this.coefficients[i].copy(coefficients[i])
        }
        return this
    }

    /**
     * @brief[zh-cn] 将所有系数归零
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Zero all coefficients
     * @return[en] This instance
     */
    public func zero(): SphericalHarmonics3 {
        for (i in 0..9) {
            this.coefficients[i].set(0.0, 0.0, 0.0)
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取给定法线方向的辐射度
     * @param[zh-cn] normal 法线向量（应为单位向量）
     * target 目标向量
     * @return[zh-cn] 辐射度
     *
     * @brief[en] Get radiance at given normal direction
     * @param[en] normal Normal vector (should be unit vector)
     * target Target vector
     * @return[en] Radiance
     */
    public func getAt(normal: Vector3, target: Vector3): Vector3 {
        let x = normal.x; let y = normal.y; let z = normal.z
        let coeff = this.coefficients

        // band 0
        target.copy(coeff[0]).multiplyScalar(0.282095)

        // band 1
        target.addScaledVector(coeff[1], 0.488603 * y)
        target.addScaledVector(coeff[2], 0.488603 * z)
        target.addScaledVector(coeff[3], 0.488603 * x)

        // band 2
        target.addScaledVector(coeff[4], 1.092548 * (x * y))
        target.addScaledVector(coeff[5], 1.092548 * (y * z))
        target.addScaledVector(coeff[6], 0.315392 * (3.0 * z * z - 1.0))
        target.addScaledVector(coeff[7], 1.092548 * (x * z))
        target.addScaledVector(coeff[8], 0.546274 * (x * x - y * y))

        return target
    }

    /**
     * @brief[zh-cn] 获取给定法线方向的辐射度（创建新向量）
     * @param[zh-cn] normal 法线向量（应为单位向量）
     * @return[zh-cn] 辐射度
     *
     * @brief[en] Get radiance at given normal direction (creates new vector)
     * @param[en] normal Normal vector (should be unit vector)
     * @return[en] Radiance
     */
    public func getAt(normal: Vector3): Vector3 {
        return this.getAt(normal, Vector3())
    }

    /**
     * @brief[zh-cn] 获取给定法线方向的辐照度（辐射度与余弦波瓣的卷积）
     * @param[zh-cn] normal 法线向量（应为单位向量）
     * target 目标向量
     * @return[zh-cn] 辐照度
     *
     * @brief[en] Get irradiance at given normal direction (convolution of radiance with cosine lobe)
     * @param[en] normal Normal vector (should be unit vector)
     * target Target vector
     * @return[en] Irradiance
     */
    public func getIrradianceAt(normal: Vector3, target: Vector3): Vector3 {
        let x = normal.x; let y = normal.y; let z = normal.z
        let coeff = this.coefficients

        // band 0
        target.copy(coeff[0]).multiplyScalar(0.886227) // π * 0.282095

        // band 1
        target.addScaledVector(coeff[1], 2.0 * 0.511664 * y) // (2 * π / 3) * 0.488603
        target.addScaledVector(coeff[2], 2.0 * 0.511664 * z)
        target.addScaledVector(coeff[3], 2.0 * 0.511664 * x)

        // band 2
        target.addScaledVector(coeff[4], 2.0 * 0.429043 * x * y) // (π / 4) * 1.092548
        target.addScaledVector(coeff[5], 2.0 * 0.429043 * y * z)
        target.addScaledVector(coeff[6], 0.743125 * z * z - 0.247708) // (π / 4) * 0.315392 * 3
        target.addScaledVector(coeff[7], 2.0 * 0.429043 * x * z)
        target.addScaledVector(coeff[8], 0.429043 * (x * x - y * y)) // (π / 4) * 0.546274

        return target
    }

    /**
     * @brief[zh-cn] 获取给定法线方向的辐照度（创建新向量）
     * @param[zh-cn] normal 法线向量（应为单位向量）
     * @return[zh-cn] 辐照度
     *
     * @brief[en] Get irradiance at given normal direction (creates new vector)
     * @param[en] normal Normal vector (should be unit vector)
     * @return[en] Irradiance
     */
    public func getIrradianceAt(normal: Vector3): Vector3 {
        return this.getIrradianceAt(normal, Vector3())
    }

    /**
     * @brief[zh-cn] 添加另一个球面调和系数
     * @param[zh-cn] sh 要添加的球面调和系数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Add another spherical harmonics coefficient
     * @param[en] sh Spherical harmonics to add
     * @return[en] This instance
     */
    public func add(sh: SphericalHarmonics3): SphericalHarmonics3 {
        for (i in 0..9) {
            this.coefficients[i].add(sh.coefficients[i])
        }
        return this
    }

    /**
     * @brief[zh-cn] 添加缩放后的球面调和系数
     * @param[zh-cn] sh 要添加的球面调和系数
     * s 缩放因子
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Add scaled spherical harmonics coefficient
     * @param[en] sh Spherical harmonics to add
     * s Scale factor
     * @return[en] This instance
     */
    public func addScaledSH(sh: SphericalHarmonics3, s: Float64): SphericalHarmonics3 {
        for (i in 0..9) {
            this.coefficients[i].addScaledVector(sh.coefficients[i], s)
        }
        return this
    }

    /**
     * @brief[zh-cn] 缩放球面调和系数
     * @param[zh-cn] s 缩放因子
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Scale spherical harmonics coefficients
     * @param[en] s Scale factor
     * @return[en] This instance
     */
    public func scale(s: Float64): SphericalHarmonics3 {
        for (i in 0..9) {
            this.coefficients[i].multiplyScalar(s)
        }
        return this
    }

    /**
     * @brief[zh-cn] 在两个球面调和系数之间线性插值
     * @param[zh-cn] sh 目标球面调和系数
     * alpha 插值因子
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Linearly interpolate between two spherical harmonics coefficients
     * @param[en] sh Target spherical harmonics
     * alpha Interpolation factor
     * @return[en] This instance
     */
    public func lerp(sh: SphericalHarmonics3, alpha: Float64): SphericalHarmonics3 {
        for (i in 0..9) {
            this.coefficients[i].lerp(sh.coefficients[i], alpha)
        }
        return this
    }

    /**
     * @brief[zh-cn] 判断是否与另一个球面调和系数相等
     * @param[zh-cn] sh 比较的球面调和系数
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if equal to another spherical harmonics coefficient
     * @param[en] sh Spherical harmonics to compare
     * @return[en] Whether equal
     */
    public func equals(sh: SphericalHarmonics3): Bool {
        for (i in 0..9) {
            if (!this.coefficients[i].equals(sh.coefficients[i])) {
                return false
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 复制另一个球面调和系数的值
     * @param[zh-cn] sh 源球面调和系数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another spherical harmonics coefficient
     * @param[en] sh Source spherical harmonics
     * @return[en] This instance
     */
    public func copy(sh: SphericalHarmonics3): SphericalHarmonics3 {
        return this.set(sh.coefficients)
    }

    /**
     * @brief[zh-cn] 克隆当前球面调和系数
     * @return[zh-cn] 新的实例
     *
     * @brief[en] Clone current spherical harmonics coefficient
     * @return[en] New instance
     */
    public func clone(): SphericalHarmonics3 {
        return SphericalHarmonics3().copy(this)
    }

    /**
     * @brief[zh-cn] 从数组读取系数
     * @param[zh-cn] array 数组
     * offset 偏移量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Read coefficients from array
     * @param[en] array Array
     * offset Offset
     * @return[en] This instance
     */
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): SphericalHarmonics3 {
        let coefficients = this.coefficients
        for (i in 0..9) {
            coefficients[i].fromArray(array, offset: offset + i * 3)
        }
        return this
    }

    /**
     * @brief[zh-cn] 将系数写入数组
     * @param[zh-cn] array 目标数组
     * offset 偏移量
     * @return[zh-cn] 数组
     *
     * @brief[en] Write coefficients to array
     * @param[en] array Target array
     * offset Offset
     * @return[en] Array
     */
    public func toArray(array: Array<Float64>, offset!: Int64 = 0): Array<Float64> {
        let coefficients = this.coefficients
        for (i in 0..9) {
            coefficients[i].toArray(array, offset: offset + i * 3)
        }
        return array
    }

    /**
     * @brief[zh-cn] 静态方法：计算给定法线方向的球面调和基函数
     * @param[zh-cn] normal 法线向量（应为单位向量）
     * shBasis 目标数组，长度至少为 9
     *
     * @brief[en] Static method: compute spherical harmonics basis functions for given normal direction
     * @param[en] normal Normal vector (should be unit vector)
     * shBasis Target array, length at least 9
     */
    public static func getBasisAt(normal: Vector3, shBasis: Array<Float64>): Unit {
        let x = normal.x; let y = normal.y; let z = normal.z

        // band 0
        shBasis[0] = 0.282095

        // band 1
        shBasis[1] = 0.488603 * y
        shBasis[2] = 0.488603 * z
        shBasis[3] = 0.488603 * x

        // band 2
        shBasis[4] = 1.092548 * x * y
        shBasis[5] = 1.092548 * y * z
        shBasis[6] = 0.315392 * (3.0 * z * z - 1.0)
        shBasis[7] = 1.092548 * x * z
        shBasis[8] = 0.546274 * (x * x - y * y)
    }
}
