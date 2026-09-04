/**
 * @file[zh-cn] Base64 Base64 编解码工具
 * @brief[zh-cn] 本文件提供标准 RFC 4648 Base64 编解码能力
 * @explain[zh-cn] 实现标准 RFC 4648 Base64 编码（含 `+/` 字符表，`=` 填充）。
 * 解码时兼容跳过 `\r` `\n`（折行兼容）。
 * 编码每 76 字符加 `\r\n` 折行。
 * 输入输出：仓颉 `Array<UInt8>` 与 `String` 互转。
 *
 * @file[en] Base64 Base64 encoding/decoding utility
 * @brief[en] This file provides standard RFC 4648 Base64 encoding and decoding
 * @explain[en] Implements standard RFC 4648 Base64 encoding (with the `+/` alphabet and
 * `=` padding). Decoding tolerates skipping `\r` and `\n` (line-wrap friendly).
 * A `\r\n` line break is inserted every 76 encoded characters.
 * Converts between Cangjie `Array<UInt8>` and `String`.
 *
 * @package three.utils.encode
 */
package three.utils.encode

import std.collection.*

/**
 * @brief[zh-cn] Base64 编解码工具
 * @explain[zh-cn] 提供静态方法在字节数组与 Base64 字符串之间互转。
 *
 * @brief[en] Base64 encoding/decoding utility
 * @explain[en] Provides static methods to convert between byte arrays and Base64 strings.
 */
public class Base64 {
    /** 编码表：A-Z a-z 0-9 + / */
    private static let _encodeTable: Array<String> = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
        "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
        "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
        "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"
    ]

    /** 解码表：128 项 ASCII 索引，非法字符为 0 */
    private static let _decodeTable: Array<UInt8> = _buildDecodeTable()

    /** 构建 128 项 ASCII 解码表（'+'=62、'/'=63、'0'-'9'=52-61、'A'-'Z'=0-25、'a'-'z'=26-51） */
    private static func _buildDecodeTable(): Array<UInt8> {
        // 128 项 ASCII 表，默认 0
        let t = Array<UInt8>(128, { _ => 0u8 })
        // '+' = 43 -> 62
        t[43] = 62u8
        // '/' = 47 -> 63
        t[47] = 63u8
        // '0'-'9' = 48-57 -> 52-61
        for (i in 0..10) {
            t[48 + i] = UInt8(52 + i)
        }
        // 'A'-'Z' = 65-90 -> 0-25
        for (i in 0..26) {
            t[65 + i] = UInt8(i)
        }
        // 'a'-'z' = 97-122 -> 26-51
        for (i in 0..26) {
            t[97 + i] = UInt8(26 + i)
        }
        return t
    }

    /**
     * @brief[zh-cn] 编码字节数组为 Base64 字符串
     * @param[zh-cn] data 输入字节数组
     * @return[zh-cn] Base64 编码字符串（每 76 字符加 `\r\n` 折行）
     *
     * @brief[en] Encodes a byte array into a Base64 string
     * @param[en] data The input byte array
     * @return[en] The Base64-encoded string (a `\r\n` line break is added every 76 characters)
     */
    public static func encode(data: Array<UInt8>): String {
        let dataByte = data.size
        let sb = StringBuilder()
        var lineLength = 0
        var idx = 0

        // 处理完整的 3 字节块
        let fullBlocks = dataByte / 3
        for (_ in 0..fullBlocks) {
            let b1 = data[idx]
            idx += 1
            let b2 = data[idx]
            idx += 1
            let b3 = data[idx]
            idx += 1

            sb.append(_encodeTable[Int64(b1 >> 2)])
            sb.append(_encodeTable[Int64(((b1 << 4) | (b2 >> 4)) & 0x3Fu8)])
            sb.append(_encodeTable[Int64(((b2 << 2) | (b3 >> 6)) & 0x3Fu8)])
            sb.append(_encodeTable[Int64(b3 & 0x3Fu8)])

            lineLength += 4
            if (lineLength == 76) {
                sb.append("\r\n")
                lineLength = 0
            }
        }

        // 处理剩余 1 或 2 字节
        let mod = dataByte % 3
        if (mod == 1) {
            let b1 = data[idx]
            sb.append(_encodeTable[Int64((b1 & 0xFCu8) >> 2)])
            sb.append(_encodeTable[Int64((b1 & 0x03u8) << 4)])
            sb.append("==")
        } else if (mod == 2) {
            let b1 = data[idx]
            idx += 1
            let b2 = data[idx]
            sb.append(_encodeTable[Int64((b1 & 0xFCu8) >> 2)])
            sb.append(_encodeTable[Int64(((b1 & 0x03u8) << 4) | ((b2 & 0xF0u8) >> 4))])
            sb.append(_encodeTable[Int64((b2 & 0x0Fu8) << 2)])
            sb.append("=")
        }

        return sb.toString()
    }

    /**
     * @brief[zh-cn] 解码 Base64 字符串为字节数组
     * @param[zh-cn] data Base64 字符串（兼容 `\r` `\n` 折行）
     * @return[zh-cn] 解码后的字节数组；含非法字符或 padding 不规范时返回空数组
     *
     * @brief[en] Decodes a Base64 string to a byte array
     * @param[en] data Base64 string (tolerates `\r`/`\n` line breaks)
     * @return[en] The decoded byte array, or an empty array on invalid characters or malformed padding
     */
    public static func decode(data: String): Array<UInt8> {
        let out = ArrayList<UInt8>()
        let table = _decodeTable
        let runes = data.toRuneArray() // 转 Rune 数组以便逐字符访问
        let n = runes.size

        // 第一遍：跳过折行，收集有效 ASCII 值；遇非法字符立即返回空数组
        let acc = ArrayList<UInt8>()
        for (i in 0..n) {
            let r = runes[i]
            if (r == r'\r' || r == r'\n') {
                continue
            }
            if (!_isValidBase64(r)) {
                return Array<UInt8>()
            }
            acc.add(_asciiOf(r))
        }
        let m = acc.size

        // 校验 padding：'=' 只允许出现在末尾，且最多 2 个；总长须为 4 的倍数
        var eqIdx = m
        for (i in 0..m) {
            if (acc[i] == 61u8) { // '='
                eqIdx = i
                break
            }
        }
        let eqCount = m - eqIdx
        if (eqCount > 2 || m % 4 != 0) {
            return Array<UInt8>()
        }
        for (i in eqIdx..m) {
            if (acc[i] != 61u8) {
                return Array<UInt8>()
            }
        }
        // 有效字符数（不含 '='）不能是 1 (mod 4)（那意味着 3 个 '='，非法）
        let validMod = (m - eqCount) % 4
        if (validMod == 1) {
            return Array<UInt8>()
        }

        // 解码：每 4 个字符 → 3 字节；末尾 padding 组按需输出 2 或 1 字节
        var i = 0
        while (i < eqIdx) {
            let isLastGroup = (i + 4 >= eqIdx)
            let c0 = acc[i]
            let c1 = acc[i + 1]
            let c2 = acc[i + 2]
            let c3 = acc[i + 3]
            let nValue = (UInt32(table[Int64(c0)]) << 18) +
                (UInt32(table[Int64(c1)]) << 12) +
                (UInt32(table[Int64(c2)]) << 6) +
                UInt32(table[Int64(c3)])
            out.add(UInt8((nValue >> 16) & 0xffu32))
            if (!isLastGroup || eqCount == 0) {
                // 完整组：3 字节
                out.add(UInt8((nValue >> 8) & 0xffu32))
                out.add(UInt8(nValue & 0xffu32))
            } else if (eqCount == 1) {
                // 1 个 '='：末尾组仅 2 字节
                out.add(UInt8((nValue >> 8) & 0xffu32))
            }
            // 2 个 '='：末尾组仅 1 字节（已输出）
            i += 4
        }

        return out.toArray()
    }

    /** 判断字符是否为合法 Base64 字符（A-Z a-z 0-9 + / =） */
    private static func _isValidBase64(r: Rune): Bool {
        return (r >= r'A' && r <= r'Z') || (r >= r'a' && r <= r'z') ||
            (r >= r'0' && r <= r'9') || r == r'+' || r == r'/' || r == r'='
    }

    /** 取字符的 ASCII 码点（限定 0..127） */
    private static func _asciiOf(r: Rune): UInt8 {
        // Rune 为 Unicode 标量值；Base64 字符均为 ASCII，超出范围返回 0
        let v = Int64(UInt32(r))
        if (v < 0 || v >= 128) {
            return 0u8
        }
        return UInt8(v)
    }
}
