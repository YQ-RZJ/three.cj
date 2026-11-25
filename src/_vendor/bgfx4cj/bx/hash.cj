/**
 * @file bx 哈希算法
 * @brief bx 库的哈希算法实现（Adler32/CRC32/Murmur2A/Murmur3）
 * @explain 本文件包含纯仓颉实现的四种哈希算法，用于 3D 渲染管线中的
 *         资源缓存、资源标识和运行时 ID 生成。
 * @note 提供流式（begin/add/end）和便捷（一次性计算）两种使用方式。
 */
protected package three._vendor.bgfx4cj.bx

// =============================================================================
// HashAdler32 - 32-bit Adler checksum
// =============================================================================

/**
 * @brief 32 位 Adler 校验和哈希
 * @explain 使用 Adler-32 算法计算数据的校验和，比 CRC32 更快但碰撞率略高。
 *         适用于非加密场景的快速完整性检查。
 */
public class HashAdler32 {
    private static let MOD_ADLER: UInt32 = 65521u32

    private var m_a: UInt32
    private var m_b: UInt32

    /** @brief 创建新的 Adler32 哈希实例，初始化为默认值 */
    public init() {
        m_a = 1u32
        m_b = 0u32
    }

    /** @brief 重置哈希状态，开始新的计算 */
    public func begin(): Unit {
        m_a = 1u32
        m_b = 0u32
    }

    /** @brief 添加完整数据数组到哈希计算 */
    public func add(data: Array<UInt8>): Unit {
        var i = 0
        let n = data.size
        while (i < n) {
            m_a = (m_a + UInt32(data[i])) % HashAdler32.MOD_ADLER
            m_b = (m_b + m_a) % HashAdler32.MOD_ADLER
            i++
        }
    }

    /** @brief 添加数据数组的指定片段到哈希计算 */
    public func add(data: Array<UInt8>, offset: Int64, length: Int64): Unit {
        var i = offset
        let end = offset + length
        while (i < end) {
            m_a = (m_a + UInt32(data[i])) % HashAdler32.MOD_ADLER
            m_b = (m_b + m_a) % HashAdler32.MOD_ADLER
            i++
        }
    }

    /** @brief 完成哈希计算，返回 32 位哈希值 */
    public func end(): UInt32 {
        return m_a | (m_b << 16)
    }
}

// =============================================================================
// HashCrc32 - 32-bit cyclic redundancy checksum
// =============================================================================

/**
 * @brief CRC32 多项式变体类型
 * @explain 选择不同的多项式以兼容不同的 CRC32 实现。
 */
public enum Crc32Variant {
    /** @brief IEEE 标准多项式（0xedb88320），最常用 */
    | Ieee
    /** @brief Castagnoli 多项式（0x82f63b78），用于 iSCSI */
    | Castagnoli
    /** @brief Koopman 多项式（0xeb31d82e） */
    | Koopman

    /** @brief 从枚举获取对应值 */
    public func value(): UInt32 {
        match (this) {
            case Ieee => 0
            case Castagnoli => 1
            case Koopman => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Crc32Variant {
        match (v) {
            case 0 => Ieee
            case 1 => Castagnoli
            case _ => Koopman
        }
    }
}

/**
 * @brief 32 位循环冗余校验哈希
 * @explain 使用查表法高效计算 CRC32 校验和，支持多种多项式变体。
 */
public class HashCrc32 {
    private var m_hash: UInt32
    private var m_table: Array<UInt32>

    /** @brief 创建新的 CRC32 哈希实例，默认使用 IEEE 多项式 */
    public init() {
        m_hash = 0xffffffffu32
        m_table = HashCrc32.buildTable(HashCrc32.IEEE_POLY)
    }

    /**
     * @brief 重置哈希状态，可选择多项式变体
     * @param variant 多项式变体，默认为 Ieee
     */
    public func begin(variant!: Crc32Variant = Crc32Variant.Ieee): Unit {
        m_hash = 0xffffffffu32
        match (variant) {
            case Ieee => m_table = HashCrc32.buildTable(HashCrc32.IEEE_POLY)
            case Castagnoli => m_table = HashCrc32.buildTable(HashCrc32.CASTAGNOLI_POLY)
            case Koopman => m_table = HashCrc32.buildTable(HashCrc32.KOOPMAN_POLY)
        }
    }

    /** @brief 添加完整数据数组到哈希计算 */
    public func add(data: Array<UInt8>): Unit {
        var i = 0
        let n = data.size
        while (i < n) {
            let idx = Int64((m_hash ^ UInt32(data[i])) & 0xffu32)
            m_hash = m_table[idx] ^ (m_hash >> 8)
            i++
        }
    }

    /** @brief 添加数据数组的指定片段到哈希计算 */
    public func add(data: Array<UInt8>, offset: Int64, length: Int64): Unit {
        var i = offset
        let end = offset + length
        while (i < end) {
            let idx = Int64((m_hash ^ UInt32(data[i])) & 0xffu32)
            m_hash = m_table[idx] ^ (m_hash >> 8)
            i++
        }
    }

    /** @brief 完成哈希计算，返回 32 位 CRC32 值 */
    public func end(): UInt32 {
        let result = m_hash ^ 0xffffffffu32
        return result
    }

    // Polynomial constants for table generation (reflected).
    /** @brief IEEE 反射多项式常量 */
    public static let IEEE_POLY: UInt32 = 0xedb88320u32
    /** @brief Castagnoli 反射多项式常量 */
    public static let CASTAGNOLI_POLY: UInt32 = 0x82f63b78u32
    /** @brief Koopman 反射多项式常量 */
    public static let KOOPMAN_POLY: UInt32 = 0xeb31d82eu32

    /**
     * @brief 从反射多项式构建 CRC32 查表
     * @param poly 反射多项式
     * @return 256 元素的查找表
     */
    /** @brief 从反射多项式构建 CRC32 查表 */
    public static func buildTable(poly: UInt32): Array<UInt32> {
        let table = Array<UInt32>(256, repeat: 0u32)
        var i = 0
        while (i < 256) {
            var crc = UInt32(i)
            var j = 0
            while (j < 8) {
                if ((crc & 1u32) != 0u32) {
                    crc = (crc >> 1) ^ poly
                } else {
                    crc = crc >> 1
                }
                j++
            }
            table[i] = crc
            i++
        }
        return table
    }
}

// =============================================================================
// HashMurmur2A - 32-bit non-cryptographic multiply and rotate hash
// =============================================================================

/**
 * @brief 32 位 MurmurHash2A 哈希
 * @explain 非加密哈希，适用于哈希表等场景。比加密哈希快得多。
 *         使用乘法和旋转操作实现良好的分布。
 */
public class HashMurmur2A {
    private static let MUL: UInt32 = 0x5bd1e995u32

    private var m_hash: UInt32
    private var m_size: UInt32
    private var m_tail: Array<UInt8>
    private var m_count: Int32

    /** @brief 创建新的 Murmur2A 哈希实例 */
    public init() {
        m_hash = 0u32
        m_size = 0u32
        m_tail = Array<UInt8>(4, repeat: 0u8)
        m_count = 0
    }

    /**
     * @brief 重置哈希状态
     * @param seed 随机种子，默认为 0
     */
    public func begin(seed!: UInt32 = 0u32): Unit {
        m_hash = seed
        m_size = 0u32
        m_count = 0
    }

    /** @brief 添加完整数据数组到哈希计算 */
    public func add(data: Array<UInt8>): Unit {
        let len = data.size
        m_size += UInt32(len)
        var pos = 0
        var remaining = len

        while (remaining >= 4) {
            var kk = UInt32(data[pos]) |
                (UInt32(data[pos + 1]) << 8) |
                (UInt32(data[pos + 2]) << 16) |
                (UInt32(data[pos + 3]) << 24)
            mix(kk)
            pos += 4
            remaining -= 4
        }

        while (remaining > 0) {
            m_tail[Int64(m_count)] = data[pos]
            m_count++
            pos++
            remaining--
            if (m_count == 4) {
                var kk = UInt32(m_tail[0]) |
                    (UInt32(m_tail[1]) << 8) |
                    (UInt32(m_tail[2]) << 16) |
                    (UInt32(m_tail[3]) << 24)
                mix(kk)
                m_count = 0
            }
        }
    }

    /** @brief 完成哈希计算，返回 32 位 Murmur2A 哈希值 */
    public func end(): UInt32 {
        var kk = 0u32
        if (m_count >= 3) {
            kk = UInt32(m_tail[2]) << 16
        }
        if (m_count >= 2) {
            kk = kk | (UInt32(m_tail[1]) << 8)
        }
        if (m_count >= 1) {
            kk = kk | UInt32(m_tail[0])
            mix(kk)
        }

        mix(m_size)

        m_hash ^= m_hash >> 13
        m_hash = m_hash * HashMurmur2A.MUL
        m_hash ^= m_hash >> 15
        return m_hash
    }

    private func mix(k: UInt32): Unit {
        var kk = k
        kk = kk * HashMurmur2A.MUL
        kk = kk ^ (kk >> 24)
        kk = kk * HashMurmur2A.MUL
        m_hash = m_hash * HashMurmur2A.MUL
        m_hash = m_hash ^ kk
    }
}

// =============================================================================
// HashMurmur3 - 32-bit non-cryptographic Murmur3 hash
// =============================================================================

/**
 * @brief 32 位 MurmurHash3 哈希
 * @explain MurmurHash3 的 32 位变体，比 Murmur2A 有更好的分布和雪崩效应。
 *         适用于哈希表、布隆过滤器等场景。
 */
public class HashMurmur3 {
    private static let MUL1: UInt32 = 0xcc9e2d51u32
    private static let MUL2: UInt32 = 0x1b873593u32
    private static let MUL3: UInt32 = 0x85ebca6bu32
    private static let MUL4: UInt32 = 0xc2b2ae35u32
    private static let ADD: UInt32 = 0xe6546b64u32

    private var m_hash: UInt32
    private var m_size: UInt32
    private var m_tail: Array<UInt8>
    private var m_count: Int32

    /** @brief 创建新的 Murmur3 哈希实例 */
    public init() {
        m_hash = 0u32
        m_size = 0u32
        m_tail = Array<UInt8>(4, repeat: 0u8)
        m_count = 0
    }

    /**
     * @brief 重置哈希状态
     * @param seed 随机种子，默认为 0
     */
    public func begin(seed!: UInt32 = 0u32): Unit {
        m_hash = seed
        m_size = 0u32
        m_count = 0
    }

    /** @brief 添加完整数据数组到哈希计算 */
    public func add(data: Array<UInt8>): Unit {
        let len = data.size
        m_size += UInt32(len)
        var pos = 0
        var remaining = len

        while (remaining >= 4) {
            let kk = UInt32(data[pos]) |
                (UInt32(data[pos + 1]) << 8) |
                (UInt32(data[pos + 2]) << 16) |
                (UInt32(data[pos + 3]) << 24)
            mix(kk)
            pos += 4
            remaining -= 4
        }

        while (remaining > 0) {
            m_tail[Int64(m_count)] = data[pos]
            m_count++
            pos++
            remaining--
        }
    }

    /** @brief 完成哈希计算，返回 32 位 Murmur3 哈希值 */
    public func end(): UInt32 {
        if (m_count > 0) {
            var kk = 0u32
            if (m_count >= 3) {
                kk = UInt32(m_tail[2]) << 16
            }
            if (m_count >= 2) {
                kk = kk | (UInt32(m_tail[1]) << 8)
            }
            kk = kk | UInt32(m_tail[0])
            mix1(kk)
        }

        m_hash = m_hash ^ m_size

        m_hash = m_hash ^ (m_hash >> 16)
        m_hash = m_hash * HashMurmur3.MUL3
        m_hash = m_hash ^ (m_hash >> 13)
        m_hash = m_hash * HashMurmur3.MUL4
        m_hash = m_hash ^ (m_hash >> 16)
        return m_hash
    }

    private func mix1(k: UInt32): Unit {
        var kk = k
        kk = kk * HashMurmur3.MUL1
        kk = rol32(kk, 15)
        kk = kk * HashMurmur3.MUL2
        m_hash = m_hash ^ kk
    }

    private func mix(k: UInt32): Unit {
        mix1(k)
        m_hash = rol32(m_hash, 13)
        m_hash = m_hash * 5u32 + HashMurmur3.ADD
    }
}

// =============================================================================
// Convenience hash functions
// =============================================================================

/**
 * @brief 计算 Adler32 哈希（一次性便捷函数）
 * @param data 输入数据
 * @return 32 位哈希值
 */
public func hashAdler32(data: Array<UInt8>): UInt32 {
    let h = HashAdler32()
    h.begin()
    h.add(data)
    return h.end()
}

/**
 * @brief 计算 CRC32 哈希（一次性便捷函数，IEEE 多项式）
 * @param data 输入数据
 * @return 32 位哈希值
 */
public func hashCrc32(data: Array<UInt8>): UInt32 {
    let h = HashCrc32()
    h.begin()
    h.add(data)
    return h.end()
}

/**
 * @brief 计算 Murmur2A 哈希（一次性便捷函数，种子为 0）
 * @param data 输入数据
 * @return 32 位哈希值
 */
public func hashMurmur2A(data: Array<UInt8>): UInt32 {
    let h = HashMurmur2A()
    h.begin()
    h.add(data)
    return h.end()
}

/**
 * @brief 计算 Murmur2A 哈希（一次性便捷函数，指定种子）
 * @param data 输入数据
 * @param seed 随机种子
 * @return 32 位哈希值
 */
public func hashMurmur2A(data: Array<UInt8>, seed: UInt32): UInt32 {
    let h = HashMurmur2A()
    h.begin(seed:seed)
    h.add(data)
    return h.end()
}

/**
 * @brief 计算 Murmur3 哈希（一次性便捷函数，种子为 0）
 * @param data 输入数据
 * @return 32 位哈希值
 */
public func hashMurmur3(data: Array<UInt8>): UInt32 {
    let h = HashMurmur3()
    h.begin()
    h.add(data)
    return h.end()
}

/**
 * @brief 计算 Murmur3 哈希（一次性便捷函数，指定种子）
 * @param data 输入数据
 * @param seed 随机种子
 * @return 32 位哈希值
 */
public func hashMurmur3(data: Array<UInt8>, seed: UInt32): UInt32 {
    let h = HashMurmur3()
    h.begin(seed:seed)
    h.add(data)
    return h.end()
}

// =============================================================================
// Internal bit-rotation helper
// =============================================================================

internal func rol32(value: UInt32, rotation: Int32): UInt32 {
    let r = rotation & 31
    return (value << r) | (value >> (32 - r))
}