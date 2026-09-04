/**
 * @file[zh-cn] SHA SHA 系列安全摘要算法工具
 * @brief[zh-cn] 本文件提供 FIPS 180-4 标准的 SHA-1/224/256/384/512 实现（纯仓颉）
 * @explain[zh-cn] 对外 API（与 MD5.cj 风格一致）：
 * - sha1/sha224/sha256/sha384/sha512(data: Array<UInt8>): String → 小写 hex
 * - sha1/sha224/sha256/sha384/sha512(message: String): String → UTF-8 编码输入
 * - sha1Raw / sha256Raw / sha512Raw(...): Array<UInt8> → 原始摘要字节
 * 实现要点：
 * - SHA-1/224/256 共享 32 位消息调度与工作字 a..h
 * - SHA-384/512 共享 64 位消息调度与工作字 a..h，仅初始哈希值与最终截断长度不同
 * - 大端序填充：0x80 起始，末 8/16 字节存 bit 长度，总长对齐 64/128 字节
 * - 常量 K 取自 FIPS 180-4 表（素数立方根小数部分前 N 位）
 *
 * @file[en] SHA SHA family secure digest algorithm utilities
 * @brief[en] This file provides FIPS 180-4 SHA-1/224/256/384/512 implementations (pure Cangjie)
 * @explain[en] Public API (consistent with MD5.cj):
 * - sha1/sha224/sha256/sha384/sha512(data: Array<UInt8>): String → lowercase hex
 * - sha1/sha224/sha256/sha384/sha512(message: String): String → UTF-8 encoded input
 * - sha1Raw / sha256Raw / sha512Raw(...): Array<UInt8> → raw digest bytes
 * Implementation notes:
 * - SHA-1/224/256 share the 32-bit message schedule and working words a..h
 * - SHA-384/512 share the 64-bit schedule and working words a..h, differing only in
 * initial hash values and final truncation length
 * - Big-endian padding: starts with 0x80, last 8/16 bytes hold the bit length,
 * total length aligned to 64/128 bytes
 * - Constants K come from the FIPS 180-4 table (leading bits of prime cube roots)
 *
 * @package three.utils.encode
 */
package three.utils.encode

import std.collection.*
import std.overflow.*

/**
 * @brief[zh-cn] SHA 系列安全摘要算法工具类
 * @explain[zh-cn] 提供 SHA-1/224/256/384/512 的静态摘要方法，输入可为字节数组或字符串（UTF-8）。
 *
 * @brief[en] SHA family secure digest algorithm utility class
 * @explain[en] Provides static digest methods for SHA-1/224/256/384/512, accepting either
 * a byte array or a UTF-8 string as input.
 */
public class SHA {

    // ========================================================================
    // ===== SHA-1 =====
    // ========================================================================

    /**
     * @brief[zh-cn] 计算 SHA-1 摘要（小写 hex），输入字节数组
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 40 字符小写 16 进制 SHA-1 摘要
     *
     * @brief[en] Computes the SHA-1 digest (lowercase hex) of a byte array
     * @param[en] data The input byte array
     * @return[en] The SHA-1 digest as a 40-character lowercase hex string
     */
    public static func sha1(data: Array<UInt8>): String {
        return _toHex(_sha1Raw(data))
    }

    /**
     * @brief[zh-cn] 计算 SHA-1 摘要（小写 hex），输入字符串（UTF-8 编码）
     * @param[zh-cn] message 输入字符串
     * @return[zh-cn] 40 字符小写 16 进制 SHA-1 摘要
     *
     * @brief[en] Computes the SHA-1 digest (lowercase hex) of a string (UTF-8 encoded)
     * @param[en] message The input string
     * @return[en] The SHA-1 digest as a 40-character lowercase hex string
     */
    public static func sha1(message: String): String {
        return sha1(message.toArray())
    }

    /**
     * @brief[zh-cn] 计算 SHA-1 摘要（原始 20 字节），输入字节数组
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 20 字节 SHA-1 原始摘要
     *
     * @brief[en] Computes the SHA-1 digest (raw 20 bytes) of a byte array
     * @param[en] data The input byte array
     * @return[en] The raw 20-byte SHA-1 digest
     */
    public static func sha1Raw(data: Array<UInt8>): Array<UInt8> {
        return _sha1Raw(data)
    }

    private static func _sha1Raw(data: Array<UInt8>): Array<UInt8> {
        // 初始哈希值（FIPS 180-4 §5.3.1）
        var h0: UInt32 = 0x67452301u32
        var h1: UInt32 = 0xefcdab89u32
        var h2: UInt32 = 0x98badcfeu32
        var h3: UInt32 = 0x10325476u32
        var h4: UInt32 = 0xc3d2e1f0u32

        let padded = _pad32(data)
        let blockCount = padded.size / 64

        for (b in 0..blockCount) {
            let base = b * 64
            let w = Array<UInt32>(80, { _ => 0u32 })
            for (i in 0..16) {
                let off = base + i * 4
                w[i] = (UInt32(padded[off]) << 24) |
                    (UInt32(padded[off + 1]) << 16) |
                    (UInt32(padded[off + 2]) << 8) |
                    UInt32(padded[off + 3])
            }
            for (i in 16..80) {
                w[i] = _rotl32(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1)
            }

            var a = h0
            var b1 = h1
            var c = h2
            var d = h3
            var e = h4

            for (i in 0..80) {
                var f: UInt32 = 0u32
                var k: UInt32 = 0u32
                if (i < 20) {
                    f = (b1 & c) | ((!b1) & d)
                    k = 0x5a827999u32
                } else if (i < 40) {
                    f = b1 ^ c ^ d
                    k = 0x6ed9eba1u32
                } else if (i < 60) {
                    f = (b1 & c) | (b1 & d) | (c & d)
                    k = 0x8f1bbcdcu32
                } else {
                    f = b1 ^ c ^ d
                    k = 0xca62c1d6u32
                }
                let tmp = _rotl32(a, 5).wrappingAdd(f).wrappingAdd(e).wrappingAdd(k).wrappingAdd(w[i])
                e = d
                d = c
                c = _rotl32(b1, 30)
                b1 = a
                a = tmp
            }

            h0 = h0.wrappingAdd(a)
            h1 = h1.wrappingAdd(b1)
            h2 = h2.wrappingAdd(c)
            h3 = h3.wrappingAdd(d)
            h4 = h4.wrappingAdd(e)
        }

        let out = Array<UInt8>(20, { _ => 0u8 })
        _u32ToBigEndian(h0, out, 0)
        _u32ToBigEndian(h1, out, 4)
        _u32ToBigEndian(h2, out, 8)
        _u32ToBigEndian(h3, out, 12)
        _u32ToBigEndian(h4, out, 16)
        return out
    }

    // ========================================================================
    // ===== SHA-224 / SHA-256（共享核心） =====
    // ========================================================================

    /**
     * @brief[zh-cn] 计算 SHA-224 摘要（小写 hex），输入字节数组
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 56 字符小写 16 进制 SHA-224 摘要
     *
     * @brief[en] Computes the SHA-224 digest (lowercase hex) of a byte array
     * @param[en] data The input byte array
     * @return[en] The SHA-224 digest as a 56-character lowercase hex string
     */
    public static func sha224(data: Array<UInt8>): String {
        return _toHex(_sha224Raw(data))
    }

    /**
     * @brief[zh-cn] 计算 SHA-224 摘要（小写 hex），输入字符串（UTF-8 编码）
     * @param[zh-cn] message 输入字符串
     * @return[zh-cn] 56 字符小写 16 进制 SHA-224 摘要
     *
     * @brief[en] Computes the SHA-224 digest (lowercase hex) of a string (UTF-8 encoded)
     * @param[en] message The input string
     * @return[en] The SHA-224 digest as a 56-character lowercase hex string
     */
    public static func sha224(message: String): String {
        return sha224(message.toArray())
    }

    /**
     * @brief[zh-cn] 计算 SHA-256 摘要（小写 hex），输入字节数组
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 64 字符小写 16 进制 SHA-256 摘要
     *
     * @brief[en] Computes the SHA-256 digest (lowercase hex) of a byte array
     * @param[en] data The input byte array
     * @return[en] The SHA-256 digest as a 64-character lowercase hex string
     */
    public static func sha256(data: Array<UInt8>): String {
        return _toHex(_sha256Raw(data))
    }

    /**
     * @brief[zh-cn] 计算 SHA-256 摘要（小写 hex），输入字符串（UTF-8 编码）
     * @param[zh-cn] message 输入字符串
     * @return[zh-cn] 64 字符小写 16 进制 SHA-256 摘要
     *
     * @brief[en] Computes the SHA-256 digest (lowercase hex) of a string (UTF-8 encoded)
     * @param[en] message The input string
     * @return[en] The SHA-256 digest as a 64-character lowercase hex string
     */
    public static func sha256(message: String): String {
        return sha256(message.toArray())
    }

    /**
     * @brief[zh-cn] 计算 SHA-256 摘要（原始 32 字节），输入字节数组
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 32 字节 SHA-256 原始摘要
     *
     * @brief[en] Computes the SHA-256 digest (raw 32 bytes) of a byte array
     * @param[en] data The input byte array
     * @return[en] The raw 32-byte SHA-256 digest
     */
    public static func sha256Raw(data: Array<UInt8>): Array<UInt8> {
        return _sha256Raw(data)
    }

    /** SHA-224 原始 28 字节摘要 */
    private static func _sha224Raw(data: Array<UInt8>): Array<UInt8> {
        // 初始哈希值（FIPS 180-4 §5.3.2）
        var h0: UInt32 = 0xc1059ed8u32
        var h1: UInt32 = 0x367cd507u32
        var h2: UInt32 = 0x3070dd17u32
        var h3: UInt32 = 0xf70e5939u32
        var h4: UInt32 = 0xffc00b31u32
        var h5: UInt32 = 0x68581511u32
        var h6: UInt32 = 0x64f98fa7u32
        var h7: UInt32 = 0xbefa4fa4u32

        let (nh0, nh1, nh2, nh3, nh4, nh5, nh6, nh7) = _sha256Core(data, h0, h1, h2, h3, h4, h5, h6, h7)

        // SHA-224 截取前 28 字节（h0..h6）
        let out = Array<UInt8>(28, { _ => 0u8 })
        _u32ToBigEndian(nh0, out, 0)
        _u32ToBigEndian(nh1, out, 4)
        _u32ToBigEndian(nh2, out, 8)
        _u32ToBigEndian(nh3, out, 12)
        _u32ToBigEndian(nh4, out, 16)
        _u32ToBigEndian(nh5, out, 20)
        _u32ToBigEndian(nh6, out, 24)
        return out
    }

    /** SHA-256 原始 32 字节摘要 */
    private static func _sha256Raw(data: Array<UInt8>): Array<UInt8> {
        // 初始哈希值（FIPS 180-4 §5.3.3）
        var h0: UInt32 = 0x6a09e667u32
        var h1: UInt32 = 0xbb67ae85u32
        var h2: UInt32 = 0x3c6ef372u32
        var h3: UInt32 = 0xa54ff53au32
        var h4: UInt32 = 0x510e527fu32
        var h5: UInt32 = 0x9b05688cu32
        var h6: UInt32 = 0x1f83d9abu32
        var h7: UInt32 = 0x5be0cd19u32

        let (nh0, nh1, nh2, nh3, nh4, nh5, nh6, nh7) = _sha256Core(data, h0, h1, h2, h3, h4, h5, h6, h7)

        let out = Array<UInt8>(32, { _ => 0u8 })
        _u32ToBigEndian(nh0, out, 0)
        _u32ToBigEndian(nh1, out, 4)
        _u32ToBigEndian(nh2, out, 8)
        _u32ToBigEndian(nh3, out, 12)
        _u32ToBigEndian(nh4, out, 16)
        _u32ToBigEndian(nh5, out, 20)
        _u32ToBigEndian(nh6, out, 24)
        _u32ToBigEndian(nh7, out, 28)
        return out
    }

    /** SHA-256 核心：接收初始哈希值，返回更新后的哈希值 */
    private static func _sha256Core(
        data: Array<UInt8>,
        h0: UInt32, h1: UInt32, h2: UInt32, h3: UInt32,
        h4: UInt32, h5: UInt32, h6: UInt32, h7: UInt32
    ): (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32) {
        var v0 = h0
        var v1 = h1
        var v2 = h2
        var v3 = h3
        var v4 = h4
        var v5 = h5
        var v6 = h6
        var v7 = h7

        // SHA-256 常量 K（FIPS 180-4 §4.2.2）
        let k = [
            0x428a2f98u32, 0x71374491u32, 0xb5c0fbcfu32, 0xe9b5dba5u32,
            0x3956c25bu32, 0x59f111f1u32, 0x923f82a4u32, 0xab1c5ed5u32,
            0xd807aa98u32, 0x12835b01u32, 0x243185beu32, 0x550c7dc3u32,
            0x72be5d74u32, 0x80deb1feu32, 0x9bdc06a7u32, 0xc19bf174u32,
            0xe49b69c1u32, 0xefbe4786u32, 0x0fc19dc6u32, 0x240ca1ccu32,
            0x2de92c6fu32, 0x4a7484aau32, 0x5cb0a9dcu32, 0x76f988dau32,
            0x983e5152u32, 0xa831c66du32, 0xb00327c8u32, 0xbf597fc7u32,
            0xc6e00bf3u32, 0xd5a79147u32, 0x06ca6351u32, 0x14292967u32,
            0x27b70a85u32, 0x2e1b2138u32, 0x4d2c6dfcu32, 0x53380d13u32,
            0x650a7354u32, 0x766a0abbu32, 0x81c2c92eu32, 0x92722c85u32,
            0xa2bfe8a1u32, 0xa81a664bu32, 0xc24b8b70u32, 0xc76c51a3u32,
            0xd192e819u32, 0xd6990624u32, 0xf40e3585u32, 0x106aa070u32,
            0x19a4c116u32, 0x1e376c08u32, 0x2748774cu32, 0x34b0bcb5u32,
            0x391c0cb3u32, 0x4ed8aa4au32, 0x5b9cca4fu32, 0x682e6ff3u32,
            0x748f82eeu32, 0x78a5636fu32, 0x84c87814u32, 0x8cc70208u32,
            0x90befffau32, 0xa4506cebu32, 0xbef9a3f7u32, 0xc67178f2u32
        ]

        let padded = _pad32(data)
        let blockCount = padded.size / 64

        for (b in 0..blockCount) {
            let base = b * 64
            let w = Array<UInt32>(64, { _ => 0u32 })
            for (i in 0..16) {
                let off = base + i * 4
                w[i] = (UInt32(padded[off]) << 24) |
                    (UInt32(padded[off + 1]) << 16) |
                    (UInt32(padded[off + 2]) << 8) |
                    UInt32(padded[off + 3])
            }
            for (i in 16..64) {
                let s0 = _rotr32(w[i - 15], 7) ^ _rotr32(w[i - 15], 18) ^ (w[i - 15] >> 3)
                let s1 = _rotr32(w[i - 2], 17) ^ _rotr32(w[i - 2], 19) ^ (w[i - 2] >> 10)
                w[i] = w[i - 16].wrappingAdd(s0).wrappingAdd(w[i - 7]).wrappingAdd(s1)
            }

            var a = v0
            var b1 = v1
            var c = v2
            var d = v3
            var e = v4
            var f1 = v5
            var g = v6
            var h = v7

            for (i in 0..64) {
                let s1 = _rotr32(e, 6) ^ _rotr32(e, 11) ^ _rotr32(e, 25)
                let ch = (e & f1) ^ ((!e) & g)
                let t1 = h.wrappingAdd(s1).wrappingAdd(ch).wrappingAdd(k[i]).wrappingAdd(w[i])
                let s0 = _rotr32(a, 2) ^ _rotr32(a, 13) ^ _rotr32(a, 22)
                let maj = (a & b1) ^ (a & c) ^ (b1 & c)
                let t2 = s0.wrappingAdd(maj)
                h = g
                g = f1
                f1 = e
                e = d.wrappingAdd(t1)
                d = c
                c = b1
                b1 = a
                a = t1.wrappingAdd(t2)
            }

            v0 = v0.wrappingAdd(a)
            v1 = v1.wrappingAdd(b1)
            v2 = v2.wrappingAdd(c)
            v3 = v3.wrappingAdd(d)
            v4 = v4.wrappingAdd(e)
            v5 = v5.wrappingAdd(f1)
            v6 = v6.wrappingAdd(g)
            v7 = v7.wrappingAdd(h)
        }

        return (v0, v1, v2, v3, v4, v5, v6, v7)
    }

    // ========================================================================
    // ===== SHA-384 / SHA-512（共享核心，64 位） =====
    // ========================================================================

    /**
     * @brief[zh-cn] 计算 SHA-384 摘要（小写 hex），输入字节数组
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 96 字符小写 16 进制 SHA-384 摘要
     *
     * @brief[en] Computes the SHA-384 digest (lowercase hex) of a byte array
     * @param[en] data The input byte array
     * @return[en] The SHA-384 digest as a 96-character lowercase hex string
     */
    public static func sha384(data: Array<UInt8>): String {
        return _toHex(_sha384Raw(data))
    }

    /**
     * @brief[zh-cn] 计算 SHA-384 摘要（小写 hex），输入字符串（UTF-8 编码）
     * @param[zh-cn] message 输入字符串
     * @return[zh-cn] 96 字符小写 16 进制 SHA-384 摘要
     *
     * @brief[en] Computes the SHA-384 digest (lowercase hex) of a string (UTF-8 encoded)
     * @param[en] message The input string
     * @return[en] The SHA-384 digest as a 96-character lowercase hex string
     */
    public static func sha384(message: String): String {
        return sha384(message.toArray())
    }

    /** SHA-384 原始 48 字节摘要 */
    private static func _sha384Raw(data: Array<UInt8>): Array<UInt8> {
        // 初始哈希值（FIPS 180-4 §5.3.4）
        var h0: UInt64 = 0xcbbb9d5dc1059ed8u64
        var h1: UInt64 = 0x629a292a367cd507u64
        var h2: UInt64 = 0x9159015a3070dd17u64
        var h3: UInt64 = 0x152fecd8f70e5939u64
        var h4: UInt64 = 0x67332667ffc00b31u64
        var h5: UInt64 = 0x8eb44a8768581511u64
        var h6: UInt64 = 0xdb0c2e0d64f98fa7u64
        var h7: UInt64 = 0x47b5481dbefa4fa4u64

        let (nh0, nh1, nh2, nh3, nh4, nh5, nh6, nh7) = _sha512Core(data, h0, h1, h2, h3, h4, h5, h6, h7)

        // SHA-384 截取前 48 字节（h0..h5）
        let out = Array<UInt8>(48, { _ => 0u8 })
        _u64ToBigEndian(nh0, out, 0)
        _u64ToBigEndian(nh1, out, 8)
        _u64ToBigEndian(nh2, out, 16)
        _u64ToBigEndian(nh3, out, 24)
        _u64ToBigEndian(nh4, out, 32)
        _u64ToBigEndian(nh5, out, 40)
        return out
    }

    /**
     * @brief[zh-cn] 计算 SHA-512 摘要（小写 hex），输入字节数组
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 128 字符小写 16 进制 SHA-512 摘要
     *
     * @brief[en] Computes the SHA-512 digest (lowercase hex) of a byte array
     * @param[en] data The input byte array
     * @return[en] The SHA-512 digest as a 128-character lowercase hex string
     */
    public static func sha512(data: Array<UInt8>): String {
        return _toHex(_sha512Raw(data))
    }

    /**
     * @brief[zh-cn] 计算 SHA-512 摘要（小写 hex），输入字符串（UTF-8 编码）
     * @param[zh-cn] message 输入字符串
     * @return[zh-cn] 128 字符小写 16 进制 SHA-512 摘要
     *
     * @brief[en] Computes the SHA-512 digest (lowercase hex) of a string (UTF-8 encoded)
     * @param[en] message The input string
     * @return[en] The SHA-512 digest as a 128-character lowercase hex string
     */
    public static func sha512(message: String): String {
        return sha512(message.toArray())
    }

    /**
     * @brief[zh-cn] 计算 SHA-512 摘要（原始 64 字节），输入字节数组
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 64 字节 SHA-512 原始摘要
     *
     * @brief[en] Computes the SHA-512 digest (raw 64 bytes) of a byte array
     * @param[en] data The input byte array
     * @return[en] The raw 64-byte SHA-512 digest
     */
    public static func sha512Raw(data: Array<UInt8>): Array<UInt8> {
        return _sha512Raw(data)
    }

    /** SHA-512 原始 64 字节摘要 */
    private static func _sha512Raw(data: Array<UInt8>): Array<UInt8> {
        // 初始哈希值（FIPS 180-4 §5.3.5）
        var h0: UInt64 = 0x6a09e667f3bcc908u64
        var h1: UInt64 = 0xbb67ae8584caa73bu64
        var h2: UInt64 = 0x3c6ef372fe94f82bu64
        var h3: UInt64 = 0xa54ff53a5f1d36f1u64
        var h4: UInt64 = 0x510e527fade682d1u64
        var h5: UInt64 = 0x9b05688c2b3e6c1fu64
        var h6: UInt64 = 0x1f83d9abfb41bd6bu64
        var h7: UInt64 = 0x5be0cd19137e2179u64

        let (nh0, nh1, nh2, nh3, nh4, nh5, nh6, nh7) = _sha512Core(data, h0, h1, h2, h3, h4, h5, h6, h7)

        let out = Array<UInt8>(64, { _ => 0u8 })
        _u64ToBigEndian(nh0, out, 0)
        _u64ToBigEndian(nh1, out, 8)
        _u64ToBigEndian(nh2, out, 16)
        _u64ToBigEndian(nh3, out, 24)
        _u64ToBigEndian(nh4, out, 32)
        _u64ToBigEndian(nh5, out, 40)
        _u64ToBigEndian(nh6, out, 48)
        _u64ToBigEndian(nh7, out, 56)
        return out
    }

    /** SHA-512 核心：接收初始哈希值，返回更新后的哈希值 */
    private static func _sha512Core(
        data: Array<UInt8>,
        h0: UInt64, h1: UInt64, h2: UInt64, h3: UInt64,
        h4: UInt64, h5: UInt64, h6: UInt64, h7: UInt64
    ): (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64) {
        var v0 = h0
        var v1 = h1
        var v2 = h2
        var v3 = h3
        var v4 = h4
        var v5 = h5
        var v6 = h6
        var v7 = h7

        // SHA-512 常量 K（FIPS 180-4 §4.2.3）
        let k = [
            0x428a2f98d728ae22u64, 0x7137449123ef65cd_u64, 0xb5c0fbcfec4d3b2f_u64, 0xe9b5dba58189dbbc_u64,
            0x3956c25bf348b538u64, 0x59f111f1b605d019_u64, 0x923f82a4af194f9b_u64, 0xab1c5ed5da6d8118_u64,
            0xd807aa98a3030242u64, 0x12835b0145706fbe_u64, 0x243185be4ee4b28c_u64, 0x550c7dc3d5ffb4e2_u64,
            0x72be5d74f27b896fu64, 0x80deb1fe3b1696b1_u64, 0x9bdc06a725c71235_u64, 0xc19bf174cf692694_u64,
            0xe49b69c19ef14ad2u64, 0xefbe4786384f25e3_u64, 0x0fc19dc68b8cd5b5_u64, 0x240ca1cc77ac9c65_u64,
            0x2de92c6f592b0275u64, 0x4a7484aa6ea6e483_u64, 0x5cb0a9dcbd41fbd4_u64, 0x76f988da831153b5_u64,
            0x983e5152ee66dfabu64, 0xa831c66d2db43210_u64, 0xb00327c898fb213f_u64, 0xbf597fc7beef0ee4_u64,
            0xc6e00bf33da88fc2u64, 0xd5a79147930aa725_u64, 0x06ca6351e003826f_u64, 0x142929670a0e6e70_u64,
            0x27b70a8546d22ffcu64, 0x2e1b21385c26c926_u64, 0x4d2c6dfc5ac42aed_u64, 0x53380d139d95b3df_u64,
            0x650a73548baf63deu64, 0x766a0abb3c77b2a8_u64, 0x81c2c92e47edaee6_u64, 0x92722c851482353b_u64,
            0xa2bfe8a14cf10364u64, 0xa81a664bbc423001_u64, 0xc24b8b70d0f89791_u64, 0xc76c51a30654be30_u64,
            0xd192e819d6ef5218u64, 0xd69906245565a910_u64, 0xf40e35855771202a_u64, 0x106aa07032bbd1b8_u64,
            0x19a4c116b8d2d0c8u64, 0x1e376c085141ab53_u64, 0x2748774cdf8eeb99_u64, 0x34b0bcb5e19b48a8_u64,
            0x391c0cb3c5c95a63u64, 0x4ed8aa4ae3418acb_u64, 0x5b9cca4f7763e373_u64, 0x682e6ff3d6b2b8a3_u64,
            0x748f82ee5defb2fcu64, 0x78a5636f43172f60_u64, 0x84c87814a1f0ab72_u64, 0x8cc702081a6439ec_u64,
            0x90befffa23631e28_u64, 0xa4506cebde82bde9_u64, 0xbef9a3f7b2c67915_u64, 0xc67178f2e372532b_u64,
            0xca273eceea26619cu64, 0xd186b8c721c0c207_u64, 0xeada7dd6cde0eb1e_u64, 0xf57d4f7fee6ed178_u64,
            0x06f067aa72176fba_u64, 0x0a637dc5a2c898a6_u64, 0x113f9804bef90dae_u64, 0x1b710b35131c471b_u64,
            0x28db77f523047d84_u64, 0x32caab7b40c72493_u64, 0x3c9ebe0a15c9bebc_u64, 0x431d67c49c100d4c_u64,
            0x4cc5d4becb3e42b6_u64, 0x597f299cfc657e2a_u64, 0x5fcb6fab3ad6faec_u64, 0x6c44198c4a475817_u64
        ]

        let padded = _pad64(data)
        let blockCount = padded.size / 128

        for (b in 0..blockCount) {
            let base = b * 128
            let w = Array<UInt64>(80, { _ => 0u64 })
            for (i in 0..16) {
                let off = base + i * 8
                w[i] = (UInt64(padded[off]) << 56) |
                    (UInt64(padded[off + 1]) << 48) |
                    (UInt64(padded[off + 2]) << 40) |
                    (UInt64(padded[off + 3]) << 32) |
                    (UInt64(padded[off + 4]) << 24) |
                    (UInt64(padded[off + 5]) << 16) |
                    (UInt64(padded[off + 6]) << 8) |
                    UInt64(padded[off + 7])
            }
            for (i in 16..80) {
                let s0 = _rotr64(w[i - 15], 1) ^ _rotr64(w[i - 15], 8) ^ (w[i - 15] >> 7)
                let s1 = _rotr64(w[i - 2], 19) ^ _rotr64(w[i - 2], 61) ^ (w[i - 2] >> 6)
                w[i] = w[i - 16].wrappingAdd(s0).wrappingAdd(w[i - 7]).wrappingAdd(s1)
            }

            var a = v0
            var b1 = v1
            var c = v2
            var d = v3
            var e = v4
            var f1 = v5
            var g = v6
            var h = v7

            for (i in 0..80) {
                let s1 = _rotr64(e, 14) ^ _rotr64(e, 18) ^ _rotr64(e, 41)
                let ch = (e & f1) ^ ((!e) & g)
                let t1 = h.wrappingAdd(s1).wrappingAdd(ch).wrappingAdd(k[i]).wrappingAdd(w[i])
                let s0 = _rotr64(a, 28) ^ _rotr64(a, 34) ^ _rotr64(a, 39)
                let maj = (a & b1) ^ (a & c) ^ (b1 & c)
                let t2 = s0.wrappingAdd(maj)
                h = g
                g = f1
                f1 = e
                e = d.wrappingAdd(t1)
                d = c
                c = b1
                b1 = a
                a = t1.wrappingAdd(t2)
            }

            v0 = v0.wrappingAdd(a)
            v1 = v1.wrappingAdd(b1)
            v2 = v2.wrappingAdd(c)
            v3 = v3.wrappingAdd(d)
            v4 = v4.wrappingAdd(e)
            v5 = v5.wrappingAdd(f1)
            v6 = v6.wrappingAdd(g)
            v7 = v7.wrappingAdd(h)
        }

        return (v0, v1, v2, v3, v4, v5, v6, v7)
    }

    // ========================================================================
    // ===== 内部辅助 =====
    // ========================================================================

    /**
     * 32 位消息填充（SHA-1/224/256 通用）。
     * 填充规则：追加 0x80，再追加 0x00 直到长度 ∡ 56 (mod 64)，
     * 末 8 字节存原始消息的 bit 长度（大端）。
     */
    private static func _pad32(data: Array<UInt8>): Array<UInt8> {
        let len = data.size
        let bitLen = UInt64(len) * 8u64
        // 填充规则：追加 0x80 后补 0x00，使 (len + 1 + padZeros + 8) ≡ 0 (mod 64)
        let mod = (len + 9) % 64
        let padZeros = if (mod == 0) { 0 } else { 64 - mod }
        // 还需追加 1 字节 0x80
        let totalPad = 1 + padZeros
        let out = Array<UInt8>(len + totalPad + 8, { _ => 0u8 })
        for (i in 0..len) {
            out[i] = data[i]
        }
        out[len] = 0x80u8
        // padZeros 字节 0x00 已由初始化保证
        // 末 8 字节存 bitLen（大端）
        let off = len + totalPad
        out[off] = UInt8((bitLen >> 56) & 0xffu64)
        out[off + 1] = UInt8((bitLen >> 48) & 0xffu64)
        out[off + 2] = UInt8((bitLen >> 40) & 0xffu64)
        out[off + 3] = UInt8((bitLen >> 32) & 0xffu64)
        out[off + 4] = UInt8((bitLen >> 24) & 0xffu64)
        out[off + 5] = UInt8((bitLen >> 16) & 0xffu64)
        out[off + 6] = UInt8((bitLen >> 8) & 0xffu64)
        out[off + 7] = UInt8(bitLen & 0xffu64)
        return out
    }

    /**
     * 64 位消息填充（SHA-384/512 通用）。
     * 填充规则：追加 0x80，再追加 0x00 直到长度 ∡ 112 (mod 128)，
     * 末 16 字节存原始消息的 bit 长度（大端）。
     */
    private static func _pad64(data: Array<UInt8>): Array<UInt8> {
        let len = data.size
        let bitLen = UInt64(len) * 8u64
        // 填充规则：追加 0x80 后补 0x00，使 (len + 1 + padZeros + 16) ≡ 0 (mod 128)
        let mod = (len + 17) % 128
        let padZeros = if (mod == 0) { 0 } else { 128 - mod }
        let totalPad = 1 + padZeros
        let out = Array<UInt8>(len + totalPad + 16, { _ => 0u8 })
        for (i in 0..len) {
            out[i] = data[i]
        }
        out[len] = 0x80u8
        // 末 16 字节：高 8 字节为 0（bitLen 不会超过 2^64），低 8 字节存 bitLen
        let off = len + totalPad
        // 高 8 字节全 0（已初始化）
        out[off + 8] = UInt8((bitLen >> 56) & 0xffu64)
        out[off + 9] = UInt8((bitLen >> 48) & 0xffu64)
        out[off + 10] = UInt8((bitLen >> 40) & 0xffu64)
        out[off + 11] = UInt8((bitLen >> 32) & 0xffu64)
        out[off + 12] = UInt8((bitLen >> 24) & 0xffu64)
        out[off + 13] = UInt8((bitLen >> 16) & 0xffu64)
        out[off + 14] = UInt8((bitLen >> 8) & 0xffu64)
        out[off + 15] = UInt8(bitLen & 0xffu64)
        return out
    }

    /** 32 位循环左移 */
    private static func _rotl32(v: UInt32, n: UInt32): UInt32 {
        return (v << n) | (v >> (32u32 - n))
    }

    /** 32 位循环右移 */
    private static func _rotr32(v: UInt32, n: UInt32): UInt32 {
        return (v >> n) | (v << (32u32 - n))
    }

    /** 64 位循环右移 */
    private static func _rotr64(v: UInt64, n: UInt64): UInt64 {
        return (v >> n) | (v << (64u64 - n))
    }

    /** UInt32 写入字节数组指定偏移（大端） */
    private static func _u32ToBigEndian(v: UInt32, out: Array<UInt8>, off: Int64): Unit {
        out[off] = UInt8((v >> 24) & 0xffu32)
        out[off + 1] = UInt8((v >> 16) & 0xffu32)
        out[off + 2] = UInt8((v >> 8) & 0xffu32)
        out[off + 3] = UInt8(v & 0xffu32)
    }

    /** UInt64 写入字节数组指定偏移（大端） */
    private static func _u64ToBigEndian(v: UInt64, out: Array<UInt8>, off: Int64): Unit {
        out[off] = UInt8((v >> 56) & 0xffu64)
        out[off + 1] = UInt8((v >> 48) & 0xffu64)
        out[off + 2] = UInt8((v >> 40) & 0xffu64)
        out[off + 3] = UInt8((v >> 32) & 0xffu64)
        out[off + 4] = UInt8((v >> 24) & 0xffu64)
        out[off + 5] = UInt8((v >> 16) & 0xffu64)
        out[off + 6] = UInt8((v >> 8) & 0xffu64)
        out[off + 7] = UInt8(v & 0xffu64)
    }

    /** 字节数组转小写 hex 字符串 */
    private static func _toHex(bytes: Array<UInt8>): String {
        let hexChars = "0123456789abcdef".toRuneArray()
        let sb = StringBuilder(bytes.size * 2)
        for (i in 0..bytes.size) {
            let b = bytes[i]
            sb.append(hexChars[Int64((b >> 4) & 0x0fu8)])
            sb.append(hexChars[Int64(b & 0x0fu8)])
        }
        return sb.toString()
    }
}
