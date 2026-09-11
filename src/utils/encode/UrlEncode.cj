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
 * @file[zh-cn] UrlEncode URL 查询串/表单编码工具
 * @brief[zh-cn] 提供 URL 查询串与表单的百分号编码/解码工具（纯仓颉实现，无 stdx 依赖）
 * @explain[zh-cn] 对外 API：
 * - encodeQuery(pairs: Array<(String, String)>): String  → 表单/查询串编码
 * - decodeQuery(query: String): Array<(String, String)>  → 查询串解码（多值展平）
 * - percentEncode(s: String): String                     → 单值百分号编码（表单语义）
 * - percentDecode(s: String): String                     → 单值百分号解码
 * 实现要点（RFC 3986 unreserved = ALPHA / DIGIT / "-" / "." / "_" / "~"）：
 * - percentEncode：非 unreserved 字符按 UTF-8 字节百分号编码；空格编码为 '+'（表单语义）
 * - percentDecode：'%XX' 解码为对应字节，'+' 解码为空格；其余原样保留
 * - encodeQuery：对每个键值分别 percentEncode 后用 '=' 与 '&' 拼接
 * - decodeQuery：去掉前导 '?'，按 '&' 拆段，每段按首个 '=' 拆键值；无 '=' 则仅 key
 *
 * @file[en] UrlEncode  URL query-string / form encoding utilities
 * @brief[en] Provides percent-encoding/decoding for URL query strings and forms
 * (pure Cangjie implementation, no stdx dependency)
 * @explain[en] Public API:
 * - encodeQuery(pairs: Array<(String, String)>): String  → form/query-string encoding
 * - decodeQuery(query: String): Array<(String, String)>  → query-string decoding (flattens multi-values)
 * - percentEncode(s: String): String                     → single-value percent-encoding (form semantics)
 * - percentDecode(s: String): String                     → single-value percent-decoding
 * Implementation notes (RFC 3986 unreserved = ALPHA / DIGIT / "-" / "." / "_" / "~"):
 * - percentEncode percent-encodes non-unreserved characters as UTF-8 bytes; spaces
 * become '+' (form semantics)
 * - percentDecode turns '%XX' back into bytes and '+' into a space; other chars pass through
 * - encodeQuery percent-encodes each key/value and joins them with '=' and '&'
 * - decodeQuery strips a leading '?', splits on '&', then splits each segment on the first '=';
 * segments without '=' yield a bare key
 *
 * @package three.utils.encode
 */
package three.utils.encode

import std.collection.*

/**
 * @brief[zh-cn] URL 查询串/表单编码工具
 * @explain[zh-cn] 以静态方法形式提供查询串编解码与单值百分号编解码能力，遵循 RFC 3986。
 *
 * @brief[en] URL query-string / form encoding utility
 * @explain[en] Provides query-string and single-value percent encoding/decoding via
 * static methods, following RFC 3986.
 */
public class UrlEncode {

    /** unreserved 字符集合（RFC 3986），这些字符在 percentEncode 中原样保留 */
    private static let _unreserved: Array<Bool> = _buildUnreserved()

    /** 大写 hex 字符，用于 percentEncode 的 %XX 输出（对齐 JS encodeURIComponent 行为） */
    private static let _hexUpper: Array<Rune> = "0123456789ABCDEF".toRuneArray()

    private static func _buildUnreserved(): Array<Bool> {
        // 128 项 ASCII 表，默认 false（需编码）
        let t = Array<Bool>(128, { _ => false })
        // ALPHA (A-Z, a-z) 原样
        for (i in 0..26) {
            t[65 + i] = true // 'A'..'Z'
            t[97 + i] = true // 'a'..'z'
        }
        // DIGIT (0-9) 原样
        for (i in 0..10) {
            t[48 + i] = true
        }
        // 特殊 unreserved 字符
        t[45] = true // '-'
        t[46] = true // '.'
        t[95] = true // '_'
        t[126] = true // '~'
        return t
    }

    /**
     * @brief[zh-cn] 编码键值对数组为 URL 查询串
     * @param[zh-cn] pairs 键值对数组
     * @return[zh-cn] 编码后的查询串（如 "a=1&b=hello+world"）
     *
     * @brief[en] Encodes an array of key-value pairs into a URL query string
     * @param[en] pairs The array of key-value pairs
     * @return[en] The encoded query string (e.g. "a=1&b=hello+world")
     *
     * @note[zh-cn] 键值各自经 percentEncode 编码（空格→'+'），用 '=' 与 '&' 拼接。
     * @note[en] Each key and value is passed through percentEncode (space→'+') and joined with '=' and '&'.
     */
    public static func encodeQuery(pairs: Array<(String, String)>): String {
        let sb = StringBuilder()
        var first = true
        for ((k, v) in pairs) {
            if (!first) {
                sb.append("&")
            }
            first = false
            sb.append(percentEncode(k))
            sb.append("=")
            sb.append(percentEncode(v))
        }
        return sb.toString()
    }

    /**
     * @brief[zh-cn] 解码 URL 查询串为键值对数组
     * @param[zh-cn] query 编码后的查询串（如 "a=1&b=hello+world"；可含前导 '?'）
     * @return[zh-cn] 键值对数组（多值键展平为多条）
     *
     * @brief[en] Decodes a URL query string into an array of key-value pairs
     * @param[en] query The encoded query string (e.g. "a=1&b=hello+world"; may start with '?')
     * @return[en] The array of key-value pairs (multi-value keys are flattened into separate entries)
     */
    public static func decodeQuery(query: String): Array<(String, String)> {
        var q = query
        if (q.size > 0 && q[0] == b'?') {
            q = q[1..q.size]
        }
        let out = ArrayList<(String, String)>()
        if (q.size == 0) {
            return out.toArray()
        }
        let pairs = q.split("&")
        for (pair in pairs) {
            match (pair.indexOf('=')) {
                case None =>
                    // 无 '='：仅 key（value 为空串），对照 JS URLSearchParams 行为
                    out.add((percentDecode(pair), ""))
                case Some(eq) =>
                    let k = pair[0..eq]
                    let v = pair[(eq + 1)..pair.size]
                    out.add((percentDecode(k), percentDecode(v)))
            }
        }
        return out.toArray()
    }

    /**
     * @brief[zh-cn] 单值百分号编码（表单语义）
     * @explain[zh-cn] 非 unreserved 字符按 UTF-8 字节做 %XX 编码；空格编码为 '+'（表单语义，
     * 区别于 encodeURIComponent 输出 %20）。
     * @param[zh-cn] s 待编码字符串
     * @return[zh-cn] 编码后的字符串
     *
     * @brief[en] Single-value percent-encoding (form semantics)
     * @explain[en] Non-unreserved characters are percent-encoded (%XX) as UTF-8 bytes;
     * spaces become '+' (form semantics, unlike encodeURIComponent which outputs %20).
     * @param[en] s The string to encode
     * @return[en] The encoded string
     */
    public static func percentEncode(s: String): String {
        // 直接对 String 取 UTF-8 字节序列
        let bytes = s.toArray()
        // capacity 至少 1：空串时 bytes.size * 3 == 0 会导致 StringBuilder 抛异常
        let sb = StringBuilder(if (bytes.size == 0) { 1 } else { bytes.size * 3 })
        for (i in 0..bytes.size) {
            let b = bytes[i]
            if (b == 0x20u8) {
                // 空格 → '+'（表单语义）
                sb.append("+")
            } else if (Int64(b) < 128 && _unreserved[Int64(b)]) {
                // unreserved ASCII 原样输出
                sb.append(Rune(UInt32(b)))
            } else {
                // 其余按 %XX 编码（大写 hex，对齐 JS encodeURIComponent）
                sb.append("%")
                sb.append(_hexUpper[Int64((b >> 4) & 0x0Fu8)])
                sb.append(_hexUpper[Int64(b & 0x0Fu8)])
            }
        }
        return sb.toString()
    }

    /**
     * @brief[zh-cn] 单值百分号解码
     * @explain[zh-cn] '%XX' 解码为对应字节；'+' 解码为空格；其余原样保留。解码按字节序列重组为 UTF-8 字符串。
     * @param[zh-cn] s 已编码字符串（如 "hello+world"）
     * @return[zh-cn] 解码后的字符串
     *
     * @brief[en] Single-value percent-decoding
     * @explain[en] Turns '%XX' back into the corresponding byte and '+' into a space;
     * everything else is kept as-is. The bytes are reassembled into a UTF-8 string.
     * @param[en] s The encoded string (e.g. "hello+world")
     * @return[en] The decoded string
     */
    public static func percentDecode(s: String): String {
        let runes = s.toRuneArray()
        let n = runes.size
        let bytes = ArrayList<UInt8>()
        var i = 0
        while (i < n) {
            let r = runes[i]
            if (r == r'+') {
                // '+' → 空格
                bytes.add(0x20u8)
                i += 1
            } else if (r == r'%' && i + 2 < n) {
                // '%XX' → 对应字节
                let hi = _nibble(runes[i + 1])
                let lo = _nibble(runes[i + 2])
                if (hi >= 0 && lo >= 0) {
                    bytes.add(UInt8((hi << 4) | lo))
                    i += 3
                } else {
                    // 非法 %XX：原样保留 '%'
                    bytes.add(0x25u8)
                    i += 1
                }
            } else {
                // 其余字符：按 UTF-8 字节序列输出
                let cp = UInt32(r)
                if (cp < 0x80u32) {
                    bytes.add(UInt8(cp))
                } else if (cp < 0x800u32) {
                    bytes.add(UInt8(0xc0u32 | (cp >> 6)))
                    bytes.add(UInt8(0x80u32 | (cp & 0x3fu32)))
                } else if (cp < 0x10000u32) {
                    bytes.add(UInt8(0xe0u32 | (cp >> 12)))
                    bytes.add(UInt8(0x80u32 | ((cp >> 6) & 0x3fu32)))
                    bytes.add(UInt8(0x80u32 | (cp & 0x3fu32)))
                } else {
                    // 4 字节 UTF-8（U+10000..U+10FFFF）
                    bytes.add(UInt8(0xf0u32 | (cp >> 18)))
                    bytes.add(UInt8(0x80u32 | ((cp >> 12) & 0x3fu32)))
                    bytes.add(UInt8(0x80u32 | ((cp >> 6) & 0x3fu32)))
                    bytes.add(UInt8(0x80u32 | (cp & 0x3fu32)))
                }
                i += 1
            }
        }
        // 字节序列 → String（std.String 支持从 UTF-8 字节构造）
        return String.fromUtf8(Array<UInt8>(bytes.size, { idx => bytes[idx] }))
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
