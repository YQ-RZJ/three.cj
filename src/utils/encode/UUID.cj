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
 * @file[zh-cn] UUID UUID 生成工具
 * @brief[zh-cn] 生成 RFC 4122 v4（随机）UUID 字符串
 * @explain[zh-cn] 生成的 UUID 格式为 xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx：
 * - 第 14 位固定为 '4'（版本号）
 * - 第 19 位高 2 位为 10（变体标识），即 8/9/a/b 之一
 * 项目内 three.core.math.MathUtils.generateUUID() 是更高性能的实现（256 查找表 + 位运算），
 * 本文件按原版风格独立实现。
 *
 * @file[en] UUID  UUID generation utility
 * @brief[en] Generates RFC 4122 v4 (random) UUID strings
 * @explain[en] Generates UUIDs in the format xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx:
 * - bit 14 is fixed to '4' (the version)
 * - the top two bits of bit 19 are 10 (the variant), i.e. one of 8/9/a/b
 * Note that three.core.math.MathUtils.generateUUID() in this project is a
 * higher-performance implementation (256-entry lookup table + bitwise ops);
 * this file is a standalone port.
 *
 * @package three.utils.encode
 */
package three.utils.encode

import std.random.*

/**
 * @brief[zh-cn] UUID 生成工具
 * @explain[zh-cn] 提供 RFC 4122 v4（随机）UUID 字符串生成能力。
 *
 * @brief[en] UUID generation utility
 * @explain[en] Provides RFC 4122 v4 (random) UUID string generation.
 */
public class UUID {
    /** 16 进制字符表 */
    private static let _hexDigits: Array<Rune> = "0123456789abcdef".toRuneArray()

    /**
     * @brief[zh-cn] 生成一个 UUID 字符串
     * @return[zh-cn] 36 字符 UUID 字符串（含 4 个连字符）
     *
     * @brief[en] Generates a UUID string
     * @return[en] A 36-character UUID string (including 4 hyphens)
     */
    public static func uuid(): String {
        let random = Random()
        let s = Array<Rune>(36, { _ => r'0' })

        for (i in 0..36) {
            // 仓颉 Random 无 next(min, max) 区间 API，使用 nextUInt64() 取模
            let start = Int64(random.nextUInt64() % 16u64)
            s[i] = _hexDigits[start]
        }
        // bits 12-15 of the time_hi_and_version field to 0010
        s[14] = r'4'
        // bits 6-7 of the clock_seq_hi_and_reserved to 01：取高 2 位为 10，即 8/9/a/b
        // 与 TS 一致：基于已生成的 s[19] 进行 & 0x3 | 0x8
        let v19 = _hexToInt(s[19])
        s[19] = _hexDigits[(v19 & 0x3) | 0x8]
        s[8] = r'-'
        s[13] = r'-'
        s[18] = r'-'
        s[23] = r'-'

        return String(s)
    }

    /** 将 16 进制字符（'0'..'9','a'..'f'）转为整数 */
    private static func _hexToInt(r: Rune): Int64 {
        // Rune 不支持减法运算，需先转为 UInt32（Unicode 标量值）后再相减
        if (r >= r'0' && r <= r'9') {
            return Int64(UInt32(r) - UInt32(r'0'))
        }
        if (r >= r'a' && r <= r'f') {
            return Int64(UInt32(r) - UInt32(r'a')) + 10
        }
        if (r >= r'A' && r <= r'F') {
            return Int64(UInt32(r) - UInt32(r'A')) + 10
        }
        return 0
    }
}
