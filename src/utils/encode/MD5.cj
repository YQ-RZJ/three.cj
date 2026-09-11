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
 * @file[zh-cn] MD5 MD5 摘要算法工具
 * @brief[zh-cn] 本文件提供纯仓颉实现的 MD5 摘要算法
 * @explain[zh-cn] 不依赖 std.crypto.digest 扩展库。
 * 仅用于非加密用途（如文件指纹、缓存键、网络同步校验）。
 * MD5 已不适用于安全加密场景。
 *
 * @file[en] MD5 MD5 digest algorithm utility
 * @brief[en] This file provides a pure Cangjie implementation of the MD5 digest algorithm
 * @explain[en] Does not depend on the std.crypto.digest extension library.
 * Intended only for non-cryptographic use (file fingerprints, cache keys,
 * network sync checksums). MD5 is no longer suitable for security-sensitive use.
 *
 * @package three.utils.encode
 */
package three.utils.encode

import std.collection.*
import std.overflow.*

/**
 * @brief[zh-cn] MD5 摘要算法工具类
 * @explain[zh-cn] 提供对字符串（UTF-8）或字节数组计算 MD5 摘要的静态方法。
 * 注意：MD5 已不适用于安全加密场景，仅用于非加密用途。
 *
 * @brief[en] MD5 digest algorithm utility class
 * @explain[en] Provides static methods to compute an MD5 digest over a string (UTF-8)
 * or a byte array. Note: MD5 is not suitable for security-sensitive scenarios
 * and should only be used for non-cryptographic purposes.
 */
public class MD5 {
    /**
     * @brief[zh-cn] 对字符串执行 MD5 处理（UTF-8 编码）
     * @param[zh-cn] message 要处理的字符串
     * @return[zh-cn] 32 字符小写 16 进制 MD5 摘要
     *
     * @brief[en] Computes the MD5 digest of a string (UTF-8 encoded)
     * @param[en] message The string to process
     * @return[en] The MD5 digest as a 32-character lowercase hex string
     */
    public static func compute(message: String): String {
        // String.toArray() 返回 UTF-8 字节序列 Array<UInt8>
        let bytes = message.toArray()
        return _md5Bytes(bytes)
    }

    /**
     * @brief[zh-cn] 对字节数组执行 MD5 处理
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 32 字符小写 16 进制 MD5 摘要
     *
     * @brief[en] Computes the MD5 digest of a byte array
     * @param[en] data The input byte array
     * @return[en] The MD5 digest as a 32-character lowercase hex string
     */
    public static func compute(data: Array<UInt8>): String {
        return _md5Bytes(data)
    }

    /**
     * @brief[zh-cn] 对字节数组执行 MD5 处理，返回 16 字节原始摘要
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 16 字节 MD5 摘要
     *
     * @brief[en] Computes the MD5 digest of a byte array and returns the raw 16-byte digest
     * @param[en] data The input byte array
     * @return[en] The 16-byte MD5 digest
     */
    public static func computeRaw(data: Array<UInt8>): Array<UInt8> {
        let words = _bytesToWords(data)
        let len = data.size * 8

        // 交换端序：bytes → 大端 32 位 words
        for (i in 0..words.size) {
            words[i] = ((words[i] << 8) | (words[i] >> 24)) & 0x00ff00ffu32 |
                ((words[i] << 24) | (words[i] >> 8)) & 0xff00ff00u32
        }

        // 填充：在 bit 长度对应位置加 1
        words[len >> 5] = words[len >> 5] | (0x80u32 << UInt32(len % 32))
        words[(((len + 64) >> 9) << 4) + 14] = UInt32(len)

        var a: UInt32 = 0x67452301u32 // 1732584193
        var b: UInt32 = 0xefcdab89u32 // -271733879
        var c: UInt32 = 0x98badcfeu32 // -1732584194
        var d: UInt32 = 0x10325476u32 // 271733878

        // 真实参与运算的 16-word 块数（words 数组含填充余量，不能直接以 size 为上限）
        let blockCount = ((len + 64) >> 9) + 1
        let ml = blockCount * 16
        var i = 0
        while (i < ml) {
            let aa = a
            let bb = b
            let cc = c
            let dd = d

            // Round 1 (FF)
            a = _ff(a, b, c, d, words[i + 0], 7u32, 0xd76aa478u32)
            d = _ff(d, a, b, c, words[i + 1], 12u32, 0xe8c7b756u32)
            c = _ff(c, d, a, b, words[i + 2], 17u32, 0x242070dbu32)
            b = _ff(b, c, d, a, words[i + 3], 22u32, 0xc1bdceeeu32)
            a = _ff(a, b, c, d, words[i + 4], 7u32, 0xf57c0fafu32)
            d = _ff(d, a, b, c, words[i + 5], 12u32, 0x4787c62au32)
            c = _ff(c, d, a, b, words[i + 6], 17u32, 0xa8304613u32)
            b = _ff(b, c, d, a, words[i + 7], 22u32, 0xfd469501u32)
            a = _ff(a, b, c, d, words[i + 8], 7u32, 0x698098d8u32)
            d = _ff(d, a, b, c, words[i + 9], 12u32, 0x8b44f7afu32)
            c = _ff(c, d, a, b, words[i + 10], 17u32, 0xffff5bb1u32)
            b = _ff(b, c, d, a, words[i + 11], 22u32, 0x895cd7beu32)
            a = _ff(a, b, c, d, words[i + 12], 7u32, 0x6b901122u32)
            d = _ff(d, a, b, c, words[i + 13], 12u32, 0xfd987193u32)
            c = _ff(c, d, a, b, words[i + 14], 17u32, 0xa679438eu32)
            b = _ff(b, c, d, a, words[i + 15], 22u32, 0x49b40821u32)

            // Round 2 (GG)
            a = _gg(a, b, c, d, words[i + 1], 5u32, 0xf61e2562u32)
            d = _gg(d, a, b, c, words[i + 6], 9u32, 0xc040b340u32)
            c = _gg(c, d, a, b, words[i + 11], 14u32, 0x265e5a51u32)
            b = _gg(b, c, d, a, words[i + 0], 20u32, 0xe9b6c7aau32)
            a = _gg(a, b, c, d, words[i + 5], 5u32, 0xd62f105du32)
            d = _gg(d, a, b, c, words[i + 10], 9u32, 0x02441453u32)
            c = _gg(c, d, a, b, words[i + 15], 14u32, 0xd8a1e681u32)
            b = _gg(b, c, d, a, words[i + 4], 20u32, 0xe7d3fbc8u32)
            a = _gg(a, b, c, d, words[i + 9], 5u32, 0x21e1cde6u32)
            d = _gg(d, a, b, c, words[i + 14], 9u32, 0xc33707d6u32)
            c = _gg(c, d, a, b, words[i + 3], 14u32, 0xf4d50d87u32)
            b = _gg(b, c, d, a, words[i + 8], 20u32, 0x455a14edu32)
            a = _gg(a, b, c, d, words[i + 13], 5u32, 0xa9e3e905u32)
            d = _gg(d, a, b, c, words[i + 2], 9u32, 0xfcefa3f8u32)
            c = _gg(c, d, a, b, words[i + 7], 14u32, 0x676f02d9u32)
            b = _gg(b, c, d, a, words[i + 12], 20u32, 0x8d2a4c8au32)

            // Round 3 (HH)
            a = _hh(a, b, c, d, words[i + 5], 4u32, 0xfffa3942u32)
            d = _hh(d, a, b, c, words[i + 8], 11u32, 0x8771f681u32)
            c = _hh(c, d, a, b, words[i + 11], 16u32, 0x6d9d6122u32)
            b = _hh(b, c, d, a, words[i + 14], 23u32, 0xfde5380cu32)
            a = _hh(a, b, c, d, words[i + 1], 4u32, 0xa4beea44u32)
            d = _hh(d, a, b, c, words[i + 4], 11u32, 0x4bdecfa9u32)
            c = _hh(c, d, a, b, words[i + 7], 16u32, 0xf6bb4b60u32)
            b = _hh(b, c, d, a, words[i + 10], 23u32, 0xbebfbc70u32)
            a = _hh(a, b, c, d, words[i + 13], 4u32, 0x289b7ec6u32)
            d = _hh(d, a, b, c, words[i + 0], 11u32, 0xeaa127fau32)
            c = _hh(c, d, a, b, words[i + 3], 16u32, 0xd4ef3085u32)
            b = _hh(b, c, d, a, words[i + 6], 23u32, 0x04881d05u32)
            a = _hh(a, b, c, d, words[i + 9], 4u32, 0xd9d4d039u32)
            d = _hh(d, a, b, c, words[i + 12], 11u32, 0xe6db99e5u32)
            c = _hh(c, d, a, b, words[i + 15], 16u32, 0x1fa27cf8u32)
            b = _hh(b, c, d, a, words[i + 2], 23u32, 0xc4ac5665u32)

            // Round 4 (II)
            a = _ii(a, b, c, d, words[i + 0], 6u32, 0xf4292244u32)
            d = _ii(d, a, b, c, words[i + 7], 10u32, 0x432aff97u32)
            c = _ii(c, d, a, b, words[i + 14], 15u32, 0xab9423a7u32)
            b = _ii(b, c, d, a, words[i + 5], 21u32, 0xfc93a039u32)
            a = _ii(a, b, c, d, words[i + 12], 6u32, 0x655b59c3u32)
            d = _ii(d, a, b, c, words[i + 3], 10u32, 0x8f0ccc92u32)
            c = _ii(c, d, a, b, words[i + 10], 15u32, 0xffeff47du32)
            b = _ii(b, c, d, a, words[i + 1], 21u32, 0x85845dd1u32)
            a = _ii(a, b, c, d, words[i + 8], 6u32, 0x6fa87e4fu32)
            d = _ii(d, a, b, c, words[i + 15], 10u32, 0xfe2ce6e0u32)
            c = _ii(c, d, a, b, words[i + 6], 15u32, 0xa3014314u32)
            b = _ii(b, c, d, a, words[i + 13], 21u32, 0x4e0811a1u32)
            a = _ii(a, b, c, d, words[i + 4], 6u32, 0xf7537e82u32)
            d = _ii(d, a, b, c, words[i + 11], 10u32, 0xbd3af235u32)
            c = _ii(c, d, a, b, words[i + 2], 15u32, 0x2ad7d2bbu32)
            b = _ii(b, c, d, a, words[i + 9], 21u32, 0xeb86d391u32)

            a = a.wrappingAdd(aa)
            b = b.wrappingAdd(bb)
            c = c.wrappingAdd(cc)
            d = d.wrappingAdd(dd)
            i += 16
        }

        // 输出摘要：a、b、c、d 各 4 字节，按 MD5 规范小端序写入（RFC 1321 输出字节序）
        let out = Array<UInt8>(16, { _ => 0u8 })
        _u32LE(a, out, 0)
        _u32LE(b, out, 4)
        _u32LE(c, out, 8)
        _u32LE(d, out, 12)
        return out
    }

    /** 计算并返回 16 字节摘要后转为 32 字符 16 进制字符串 */
    private static func _md5Bytes(bytes: Array<UInt8>): String {
        let raw = computeRaw(bytes)
        return _bytesToHex(raw)
    }

    /** FF 轮函数 */
    private static func _ff(a: UInt32, b: UInt32, c: UInt32, d: UInt32, x: UInt32, s: UInt32, t: UInt32): UInt32 {
        var n: UInt32 = a.wrappingAdd((b & c) | (!b & d)).wrappingAdd(x).wrappingAdd(t)
        return ((n << s) | (n >> (32u32 - s))).wrappingAdd(b)
    }

    /** GG 轮函数 */
    private static func _gg(a: UInt32, b: UInt32, c: UInt32, d: UInt32, x: UInt32, s: UInt32, t: UInt32): UInt32 {
        var n: UInt32 = a.wrappingAdd((b & d) | (c & !d)).wrappingAdd(x).wrappingAdd(t)
        return ((n << s) | (n >> (32u32 - s))).wrappingAdd(b)
    }

    /** HH 轮函数 */
    private static func _hh(a: UInt32, b: UInt32, c: UInt32, d: UInt32, x: UInt32, s: UInt32, t: UInt32): UInt32 {
        var n: UInt32 = a.wrappingAdd(b ^ c ^ d).wrappingAdd(x).wrappingAdd(t)
        return ((n << s) | (n >> (32u32 - s))).wrappingAdd(b)
    }

    /** II 轮函数 */
    private static func _ii(a: UInt32, b: UInt32, c: UInt32, d: UInt32, x: UInt32, s: UInt32, t: UInt32): UInt32 {
        var n: UInt32 = a.wrappingAdd(c ^ (b | !d)).wrappingAdd(x).wrappingAdd(t)
        return ((n << s) | (n >> (32u32 - s))).wrappingAdd(b)
    }

    /** 字节数组转大端 32 位字数组 */
    private static func _bytesToWords(bytes: Array<UInt8>): Array<UInt32> {
        // 等价 (bytes.size + 3) / 4 + 16 余量，给填充留位置
        let wordCount = ((bytes.size + 80) >> 2) + 16
        let words = Array<UInt32>(wordCount, { _ => 0u32 })
        for (i in 0..bytes.size) {
            let b = UInt32(bytes[i])
            let w = i >> 2
            words[w] = words[w] | (b << UInt32(24 - (i % 4) * 8))
        }
        return words
    }

    /** 大端 32 位字数组转字节数组 */
    private static func _wordsToBytes(words: Array<UInt32>): Array<UInt8> {
        let bytes = Array<UInt8>(words.size * 4, { _ => 0u8 })
        for (i in 0..words.size) {
            let w = words[i]
            bytes[i * 4] = UInt8((w >> 24) & 0xffu32)
            bytes[i * 4 + 1] = UInt8((w >> 16) & 0xffu32)
            bytes[i * 4 + 2] = UInt8((w >> 8) & 0xffu32)
            bytes[i * 4 + 3] = UInt8(w & 0xffu32)
        }
        // 截取前 16 字节
        let out = Array<UInt8>(16, { _ => 0u8 })
        for (i in 0..16) {
            out[i] = bytes[i]
        }
        return out
    }

    /** 端序交换：对前 count 项做 32 位字节序反转；count = 0 表示处理全数组 */
    private static func _endianArray(arr: Array<UInt32>, count: Int64): Unit {
        let n = if (count == 0) { arr.size } else { count }
        for (i in 0..n) {
            arr[i] = ((arr[i] << 8) | (arr[i] >> 24)) & 0x00ff00ffu32 |
                ((arr[i] << 24) | (arr[i] >> 8)) & 0xff00ff00u32
        }
    }

    /** 字节数组转小写 16 进制字符串 */
    private static func _bytesToHex(bytes: Array<UInt8>): String {
        let hexChars = "0123456789abcdef".toRuneArray()
        let sb = StringBuilder()
        for (i in 0..bytes.size) {
            let b = bytes[i]
            sb.append(hexChars[Int64((b >> 4) & 0x0fu8)])
            sb.append(hexChars[Int64(b & 0x0fu8)])
        }
        return sb.toString()
    }

    /** UInt32 按小端序写入字节数组指定偏移（4 字节） */
    private static func _u32LE(v: UInt32, out: Array<UInt8>, off: Int64): Unit {
        out[off] = UInt8(v & 0xffu32)
        out[off + 1] = UInt8((v >> 8) & 0xffu32)
        out[off + 2] = UInt8((v >> 16) & 0xffu32)
        out[off + 3] = UInt8((v >> 24) & 0xffu32)
    }
}
