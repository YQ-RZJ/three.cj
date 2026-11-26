/**
 * @file bx 随机数生成器
 * @brief bx 库的随机数生成器实现（MWC / SHR3）
 * @explain 本文件包含纯仓颉实现的两种随机数生成器：Marsaglia 的 MWC
 *         （Multiply-with-Carry）和 SHR3（Shift Register），以及随机点
 *         生成辅助函数（单位圆、单位球、单位半球等）。
 * @note RNG 用于 3D 图形中的蒙特卡洛积分、采样、程序化生成和抗锯齿抖动。
 */
protected package three._vendor.bgfx4cj.bx

import std.math.*

// =============================================================================
// RngMwc - George Marsaglia's Multiply-with-Carry
// =============================================================================

/**
 * @brief Marsaglia 的 MWC（Multiply-with-Carry）随机数生成器
 * @explain 使用两个 32 位状态（z 和 w）实现快速、高质量的伪随机数生成。
 *         周期约为 2^60。
 */
public class RngMwc {
    private var m_z: UInt32
    private var m_w: UInt32

    /**
     * @brief 创建 MWC 随机数生成器
     * @param z 初始种子值，默认为 12345
     * @param w 初始种子值，默认为 65435
     */
    public init(z!: UInt32 = 12345u32, w!: UInt32 = 65435u32) {
        m_z = z
        m_w = w
    }

    /**
     * @brief 重置生成器状态
     * @param z 初始种子值，默认为 12345
     * @param w 初始种子值，默认为 65435
     */
    public func reset(z!: UInt32 = 12345u32, w!: UInt32 = 65435u32): Unit {
        m_z = z
        m_w = w
    }

    /**
     * @brief 生成下一个 32 位随机数
     * @return 32 位无符号随机整数
     */
    public func gen(): UInt32 {
        m_z = 36969u32 * (m_z & 65535u32) + (m_z >> 16)
        m_w = 18000u32 * (m_w & 65535u32) + (m_w >> 16)
        return (m_z << 16) + m_w
    }
}

// =============================================================================
// RngShr3 - George Marsaglia's SHR3
// =============================================================================

/**
 * @brief Marsaglia 的 SHR3（Shift Register）随机数生成器
 * @explain 使用 XOR 和移位操作实现极快的伪随机数生成。周期约为 2^32。
 */
public class RngShr3 {
    private var m_jsr: UInt32

    /**
     * @brief 创建 SHR3 随机数生成器
     * @param jsr 初始种子值，默认为 34221
     */
    public init(jsr!: UInt32 = 34221u32) {
        m_jsr = jsr
    }

    /**
     * @brief 重置生成器状态
     * @param jsr 初始种子值，默认为 34221
     */
    public func reset(jsr!: UInt32 = 34221u32): Unit {
        m_jsr = jsr
    }

    /**
     * @brief 生成下一个 32 位随机数
     * @return 32 位无符号随机整数
     */
    public func gen(): UInt32 {
        m_jsr ^= m_jsr << 17
        m_jsr ^= m_jsr >> 13
        m_jsr ^= m_jsr << 5
        return m_jsr
    }
}

// =============================================================================
// Random float helpers (generic over RNG type)
// =============================================================================

/**
 * @brief 生成 [0, 1] 范围内的随机浮点数
 * @param rng MWC 随机数生成器
 * @return [0, 1] 范围内的 Float32
 */
public func frnd(rng: RngMwc): Float32 {
    let rnd = rng.gen() & 65535u32
    return Float32(rnd) * (1.0f32 / Float32(65535u32))
}

/**
 * @brief 生成 [0, 1] 范围内的随机浮点数
 * @param rng SHR3 随机数生成器
 * @return [0, 1] 范围内的 Float32
 */
public func frnd(rng: RngShr3): Float32 {
    let rnd = rng.gen() & 65535u32
    return Float32(rnd) * (1.0f32 / Float32(65535u32))
}

/**
 * @brief 生成 [-1, 1] 范围内的随机浮点数
 * @param rng MWC 随机数生成器
 * @return [-1, 1] 范围内的 Float32
 */
public func frndh(rng: RngMwc): Float32 {
    return 2.0f32 * frnd(rng) - 1.0f32
}

/**
 * @brief 生成 [-1, 1] 范围内的随机浮点数
 * @param rng SHR3 随机数生成器
 * @return [-1, 1] 范围内的 Float32
 */
public func frndh(rng: RngShr3): Float32 {
    return 2.0f32 * frnd(rng) - 1.0f32
}

// =============================================================================
// Random point generators
// =============================================================================

/**
 * @brief 在 XZ 平面上的单位圆上生成随机点
 * @param rng MWC 随机数生成器
 * @return 单位圆上的 Vec3（y=0）
 */
public func randUnitCircle(rng: RngMwc): Vec3 {
    let angle = frnd(rng) * BX_PI2
    return Vec3(cos(angle), 0.0f32, sin(angle))
}

/**
 * @brief 在 XZ 平面上的单位圆上生成随机点
 * @param rng SHR3 随机数生成器
 * @return 单位圆上的 Vec3（y=0）
 */
public func randUnitCircle(rng: RngShr3): Vec3 {
    let angle = frnd(rng) * BX_PI2
    return Vec3(cos(angle), 0.0f32, sin(angle))
}

/**
 * @brief 在单位球面上生成随机点
 * @param rng MWC 随机数生成器
 * @return 单位球面上的 Vec3
 */
public func randUnitSphere(rng: RngMwc): Vec3 {
    let rand0 = frnd(rng) * 2.0f32 - 1.0f32
    let rand1 = frnd(rng) * BX_PI2
    let sqrtf1 = sqrt(1.0f32 - rand0 * rand0)
    return Vec3(
        sqrtf1 * cos(rand1),
        sqrtf1 * sin(rand1),
        rand0
    )
}

/**
 * @brief 在单位球面上生成随机点
 * @param rng SHR3 随机数生成器
 * @return 单位球面上的 Vec3
 */
public func randUnitSphere(rng: RngShr3): Vec3 {
    let rand0 = frnd(rng) * 2.0f32 - 1.0f32
    let rand1 = frnd(rng) * BX_PI2
    let sqrtf1 = sqrt(1.0f32 - rand0 * rand0)
    return Vec3(
        sqrtf1 * cos(rand1),
        sqrtf1 * sin(rand1),
        rand0
    )
}

/**
 * @brief 在朝向指定法线的单位半球面上生成随机点
 * @param rng MWC 随机数生成器
 * @param normal 半球朝向的法线方向
 * @return 单位半球面上的 Vec3
 */
public func randUnitHemisphere(rng: RngMwc, normal: Vec3): Vec3 {
    let dir = randUnitSphere(rng)
    let ddotn = dot(dir, normal)
    if (0.0f32 > ddotn) {
        return neg(dir)
    }
    return dir
}

/**
 * @brief 在朝向指定法线的单位半球面上生成随机点
 * @param rng SHR3 随机数生成器
 * @param normal 半球朝向的法线方向
 * @return 单位半球面上的 Vec3
 */
public func randUnitHemisphere(rng: RngShr3, normal: Vec3): Vec3 {
    let dir = randUnitSphere(rng)
    let ddotn = dot(dir, normal)
    if (0.0f32 > ddotn) {
        return neg(dir)
    }
    return dir
}

// =============================================================================
// Hammersley point generation for sphere sampling
// =============================================================================

/**
 * @brief 生成球面上的 Hammersley 采样点（用于 IBL 采样）
 * @param num 采样点数量
 * @param scale 输出缩放因子，默认为 1.0
 * @return 缩放后的单位球面采样点数组
 */
public func generateSphereHammersley(num: UInt32, scale!: Float32 = 1.0f32): Array<Vec3> {
    let result = Array<Vec3>(Int64(num), repeat: Vec3())
    var ii = 0u32
    while (ii < num) {
        var tt = 0.0f32
        var pp = 0.5f32
        var jj = ii
        while (jj != 0u32) {
            if ((jj & 1u32) != 0u32) {
                tt += pp
            }
            pp *= 0.5f32
            jj = jj >> 1
        }

        tt = 2.0f32 * tt - 1.0f32

        let phi = (Float32(ii) + 0.5f32) / Float32(num)
        let phirad = phi * BX_PI2
        let st = sqrt(1.0f32 - tt * tt) * scale

        result[Int64(ii)] = Vec3(
            st * cos(phirad),
            st * sin(phirad),
            tt * scale
        )
        ii++
    }
    return result
}

// =============================================================================
// Fisher-Yates shuffle
// =============================================================================

/**
 * @brief Fisher-Yates 洗牌算法（使用 MWC RNG）
 * @param rng MWC 随机数生成器
 * @param array 待洗牌的数组
 * @param num 参与洗牌的元素数量
 */
public func shuffle<T>(rng: RngMwc, array: Array<T>, num: UInt32): Unit {
    if (num == 0u32) {
        return
    }
    var ii = 0u32
    let limit = num - 1u32
    while (ii < limit) {
        let jj = ii + 1u32 + (rng.gen() % (limit - ii))
        let tmp = array[Int64(ii)]
        array[Int64(ii)] = array[Int64(jj)]
        array[Int64(jj)] = tmp
        ii++
    }
}

/**
 * @brief Fisher-Yates 洗牌算法（使用 SHR3 RNG）
 * @param rng SHR3 随机数生成器
 * @param array 待洗牌的数组
 * @param num 参与洗牌的元素数量
 */
public func shuffle<T>(rng: RngShr3, array: Array<T>, num: UInt32): Unit {
    if (num == 0u32) {
        return
    }
    var ii = 0u32
    let limit = num - 1u32
    while (ii < limit) {
        let jj = ii + 1u32 + (rng.gen() % (limit - ii))
        let tmp = array[Int64(ii)]
        array[Int64(ii)] = array[Int64(jj)]
        array[Int64(jj)] = tmp
        ii++
    }
}