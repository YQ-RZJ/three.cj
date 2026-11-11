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
 * @file[zh-cn] Hex Hex 十六进制编解码工具
 * @brief[zh-cn] 本文件提供十六进制字符串与字节数组互转能力（纯仓颉实现）
 * @explain[zh-cn] 对外 API：
 * - encode(data: Array<UInt8>): String → 小写 hex（每字节 2 字符）
 * - decode(data: String): Array<UInt8> → 解码；非法输入返回空数组
 * 实现要点：
 * - 编码：查表法，4 位一组映射到 '0'..'9','a'..'f'
 * - 解码：逐字符查表转 4 位 nibble，两位拼一字节；奇数长度或非法字符返回空数组
 * - 大小写兼容：解码同时接受 'A'..'F' 与 'a'..'f'
 *
 * @file[en] Hex Hex encoding/decoding utility
 * @brief[en] This file provides conversion between hex strings and byte arrays (pure Cangjie)
 * @explain[en] Public API:
 * - encode(data: Array<UInt8>): String → lowercase hex (2 chars per byte)
 * - decode(data: String): Array<UInt8> → decode; invalid input returns an empty array
 * Implementation notes:
 * - Encoding uses a lookup table, mapping 4-bit groups to '0'..'9','a'..'f'
 * - Decoding maps each char to a 4-bit nibble and packs two nibbles into a byte;
 * odd lengths or invalid chars return an empty array
 * - Decoding accepts both 'A'..'F' and 'a'..'f'
 *
 * @package three.utils.encode
 */
package three.utils.encode

import std.collection.*

/**
 * @brief[zh-cn] Hex 十六进制编解码工具
 * @explain[zh-cn] 提供静态方法在字节数组与十六进制字符串之间互转。
 *
 * @brief[en] Hex encoding/decoding utility
 * @explain[en] Provides static methods to convert between byte arrays and hex strings.
 */
public class Hex {
    /** 小写 hex 编码字符表 */
    private static let _hexChars: Array<Rune> = "0123456789abcdef".toRuneArray()

    /**
     * @brief[zh-cn] 编码字节数组为小写 hex 字符串
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] 小写 hex 字符串（每字节 2 字符）
     *
     * @brief[en] Encodes a byte array into a lowercase hex string
     * @param[en] data The input byte array
     * @return[en] The lowercase hex string (2 characters per byte)
     */
    public static func encode(data: Array<UInt8>): String {
        // capacity 至少 1：空数组时 data.size * 2 == 0 会导致 StringBuilder 抛异常
        let sb = StringBuilder(if (data.size == 0) { 1 } else { data.size * 2 })
        for (i in 0..data.size) {
            let b = data[i]
            sb.append(_hexChars[Int64((b >> 4) & 0x0Fu8)])
            sb.append(_hexChars[Int64(b & 0x0Fu8)])
        }
        return sb.toString()
    }

    /**
     * @brief[zh-cn] 解码 hex 字符串为字节数组
     * @param[zh-cn] data hex 字符串（大小写均可）
     * @return[zh-cn] 解码后的字节数组（非法输入返回空数组）
     *
     * @brief[en] Decodes a hex string into a byte array
     * @param[en] data The hex string (case-insensitive)
     * @return[en] The decoded byte array (an empty array is returned for invalid input)
     */
    public static func decode(data: String): Array<UInt8> {
        let runes = data.toRuneArray()
        let n = runes.size
        // 奇数长度无法配对成字节，视为非法
        if ((n & 1) != 0) {
            return Array<UInt8>()
        }
        let out = Array<UInt8>(n / 2, { _ => 0u8 })
        var oi = 0
        var i = 0
        while (i < n) {
            let hi = _nibble(runes[i])
            let lo = _nibble(runes[i + 1])
            // 任一字符非法 → 返回空数组
            if (hi < 0 || lo < 0) {
                return Array<UInt8>()
            }
            out[oi] = UInt8((hi << 4) | lo)
            oi += 1
            i += 2
        }
        return out
    }

    /**
     * @return[zh-cn] 0..15 表示合法；-1 表示非法字符
     *
     * 将单个 hex 字符转为 4 位整数。
     *
     * @return[en] 0..15 for valid hex char; -1 for invalid character
     */
    private static func _nibble(r: Rune): Int64 {
        if (r >= r'0' && r <= r'9') {
            return Int64(UInt32(r) - UInt32(r'0'))
        }
        if (r >= r'a' && r <= r'f') {
            return Int64(UInt32(r) - UInt32(r'a')) + 10
        }
        if (r >= r'A' && r <= r'F') {
            return Int64(UInt32(r) - UInt32(r'A')) + 10
        }
        return -1
    }
}
