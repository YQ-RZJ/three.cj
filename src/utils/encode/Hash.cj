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
 * @file[zh-cn] Hash 非加密哈希算法工具
 * @brief[zh-cn] 本文件提供 FNV-1a 32 位与 MurmurHash3 32 位（x86 版）两种非加密哈希算法
 * @explain[zh-cn] 两种算法适用场景不同：
 * - fnv1a32：小数据（< 1KB）场景，实现简单
 * - murmurHash32：中大型数据性能更优，雪崩效应更好
 * 均为非加密用途（缓存键生成、对象去重、网络同步校验等）。
 *
 * @file[en] Hash Non-cryptographic hash algorithm utilities
 * @brief[en] This file provides FNV-1a 32-bit and MurmurHash3 32-bit (x86) non-cryptographic hash algorithms
 * @explain[en] The two algorithms suit different scenarios:
 * - fnv1a32: simple implementation for small data (< 1KB)
 * - murmurHash32: better performance on medium/large data with stronger avalanche effect
 * Both are for non-cryptographic use (cache keys, object dedup, sync checksums, etc.).
 *
 * @package three.utils.encode
 */
package three.utils.encode

import std.overflow.*

/**
 * @brief[zh-cn] 非加密哈希算法工具类
 * @explain[zh-cn] 提供 FNV-1a 32 位与 MurmurHash3 32 位（x86 版）两种静态哈希方法，
 * 均为非加密用途。
 *
 * @brief[en] Non-cryptographic hash algorithm utility class
 * @explain[en] Provides two static hash methods: FNV-1a 32-bit and MurmurHash3 32-bit (x86),
 * both intended for non-cryptographic use.
 */
public class Hash {
    /**
     * @brief[zh-cn] 计算 FNV-1a 32 位哈希值
     * @explain[zh-cn] 适用场景（数据量小于 1KB 时）：缓存键生成、对象去重、网络同步校验等非加密用途。
     * @param[zh-cn] data 待哈希的字节数组
     * @return[zh-cn] 32 位无符号整数哈希值（用 Int64 容纳，保留位模式）
     *
     * @brief[en] Computes an FNV-1a 32-bit hash value
     * @explain[en] Suitable for non-cryptographic use (cache key generation, object dedup,
     * sync checksums, etc.) when the data is smaller than 1KB.
     * @param[en] data The byte array to hash
     * @return[en] The 32-bit unsigned hash value (stored in an Int64, preserving the bit pattern)
     */
    public static func fnv1a32(data: Array<UInt8>): Int64 {
        var hash: UInt32 = 2166136261u32 // FNV offset basis
        for (i in 0..data.size) {
            hash ^= UInt32(data[i])
            hash = hash.wrappingMul(16777619u32) // FNV prime，32 位高位截断回绕
        }
        return Int64(hash)
    }

    /**
     * @brief[zh-cn] 计算 MurmurHash3 32 位哈希值（x86 版本）
     * @explain[zh-cn] 特点：无外部依赖、跨平台结果一致、对中大型数据性能优异。
     * 适用场景：缓存键生成、对象去重、网络同步校验等非加密用途。
     * @param[zh-cn] data 待哈希的字节数组
     * seed 哈希种子（默认 1102），用于生成不同哈希空间
     * @return[zh-cn] 32 位无符号整数哈希值（用 Int64 容纳，保留位模式）
     *
     * @brief[en] Computes a MurmurHash3 32-bit hash value (x86 variant)
     * @explain[en] Features: no external dependencies, consistent cross-platform results, and
     * excellent performance on medium/large data. Suitable for non-cryptographic use
     * such as cache keys, object dedup and sync checksums.
     * @param[en] data The byte array to hash
     * seed Hash seed (default 1102) used to derive different hash spaces
     * @return[en] The 32-bit unsigned hash value (stored in an Int64, preserving the bit pattern)
     */
    public static func murmurHash32(data: Array<UInt8>, seed!: UInt32 = 1102u32): Int64 {
        var h1: UInt32 = seed
        let len = data.size

        // 完整的 4 字节块数量（每块 32 位）
        let blockCount = len >> 2
        // 尾部字节起始索引
        let tailIndex = blockCount << 2

        let c1: UInt32 = 0xcc9e2d51u32
        let c2: UInt32 = 0x1b873593u32

        // ===== 主体：处理完整的 4 字节块 =====
        for (i in 0..blockCount) {
            // 小端序读取 32 位整数
            var k1: UInt32 = UInt32(data[i * 4]) |
                (UInt32(data[i * 4 + 1]) << 8) |
                (UInt32(data[i * 4 + 2]) << 16) |
                (UInt32(data[i * 4 + 3]) << 24)

            // 混合阶段 1：k1 = k1 * c1（32 位高位截断回绕）
            k1 = k1.wrappingMul(c1)
            // 循环左移 15 位
            k1 = (k1 << 15) | (k1 >> 17)
            // 混合阶段 2：k1 = k1 * c2
            k1 = k1.wrappingMul(c2)

            h1 = h1 ^ k1
            // 对 h1 循环左移 13 位
            h1 = (h1 << 13) | (h1 >> 19)
            // h1 = h1 * 5 + 0xe6546b64（回绕乘加）
            h1 = h1.wrappingMul(5u32).wrappingAdd(0xe6546b64u32)
        }

        // ===== 尾部：处理不足 4 字节的剩余数据 =====
        var k1: UInt32 = 0u32
        let tailLen = len - tailIndex

        // 等价 TS switch 穿透：按 tailLen 依次处理
        if (tailLen >= 3) {
            k1 = k1 ^ (UInt32(data[tailIndex + 2]) << 16)
        }
        if (tailLen >= 2) {
            k1 = k1 ^ (UInt32(data[tailIndex + 1]) << 8)
        }
        if (tailLen >= 1) {
            k1 = k1 ^ UInt32(data[tailIndex])
            k1 = k1.wrappingMul(c1)
            k1 = (k1 << 15) | (k1 >> 17)
            k1 = k1.wrappingMul(c2)
            h1 = h1 ^ k1
        }

        // ===== 最终混合（Finalization）=====
        h1 = h1 ^ UInt32(len)
        // 三次混合，提升雪崩效应
        h1 = h1 ^ (h1 >> 16)
        h1 = h1.wrappingMul(0x85ebca6bu32)
        h1 = h1 ^ (h1 >> 13)
        h1 = h1.wrappingMul(0xc2b2ae35u32)
        h1 = h1 ^ (h1 >> 16)

        return Int64(h1)
    }
}
