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
 * @file[zh-cn] GroupVarint
 * @brief[zh-cn] Group Varint 编解码工具
 * @explain[zh-cn] 实现 Google Group Varint 编码（参见 Jeff Dean WSDM09 keynote），
 *                  每 4 个 UInt32 值用 1 字节前缀 + 变长字节编码（1-4 字节/值），
 *                  用于骨骼动画关键帧索引压缩，减少内存占用。
 *                  算法参照 ozz-animation/include/ozz/base/encode/group_varint.h 移植。
 *
 * @file[en] GroupVarint
 * @brief[en] Group Varint encoding/decoding utility
 * @explain[en] Implements Google Group Varint encoding (see Jeff Dean WSDM09 keynote).
 *              Every 4 UInt32 values are encoded with a 1-byte prefix + variable-length
 *              bytes (1-4 bytes per value). Used for skeletal animation keyframe index
 *              compression. Ported from ozz-animation group_varint.h.
 */
package three.utils.encode

public class GroupVarint {
    private static let kMask0: UInt32 = 0xFFu32
    private static let kMask1: UInt32 = 0xFFFFu32
    private static let kMask2: UInt32 = 0xFFFFFFu32
    private static let kMask3: UInt32 = 0xFFFFFFFFu32

    private static func tag(v: UInt32): UInt32 {
        var t: UInt32 = 0
        if (v >= 0x01000000u32) { t += 1u32 }
        if (v >= 0x00010000u32) { t += 1u32 }
        if (v >= 0x00000100u32) { t += 1u32 }
        t
    }

    private static func store(v: UInt32, buf: Array<UInt8>, offset: Int): Unit {
        buf[offset] = UInt8(v & 0xFFu32)
        buf[offset + 1] = UInt8((v >> 8) & 0xFFu32)
        buf[offset + 2] = UInt8((v >> 16) & 0xFFu32)
        buf[offset + 3] = UInt8((v >> 24) & 0xFFu32)
    }

    private static func load(buf: Array<UInt8>, offset: Int): UInt32 {
        // ozz 原版依赖调用方预留 4 字节填充，此处改为边界安全读取：
        // 越界字节按 0 处理，后续 mask 会按 tag 截断无效高位。
        var v: UInt32 = 0
        let n = buf.size
        if (offset < n) {
            v = v | UInt32(buf[offset])
        }
        if (offset + 1 < n) {
            v = v | (UInt32(buf[offset + 1]) << 8)
        }
        if (offset + 2 < n) {
            v = v | (UInt32(buf[offset + 2]) << 16)
        }
        if (offset + 3 < n) {
            v = v | (UInt32(buf[offset + 3]) << 24)
        }
        v
    }

    /**
     * @brief[zh-cn] 编码 4 个 UInt32 值到缓冲区
     * @param[zh-cn] input 4 个 UInt32 值的数组（长度须为 4）
     * @param[zh-cn] output 输出字节缓冲区（需至少 17 字节）
     * @return[zh-cn] 写入的字节数
     *
     * @brief[en] Encode 4 UInt32 values into a buffer
     * @param[en] input Array of 4 UInt32 values (must be length 4)
     * @param[en] output Output byte buffer (at least 17 bytes)
     * @return[en] Number of bytes written
     */
    public static func encodeGroup(input: Array<UInt32>, output: Array<UInt8>): Int {
        let aTag = tag(input[0])
        let bTag = tag(input[1])
        let cTag = tag(input[2])
        let dTag = tag(input[3])

        output[0] = UInt8((dTag << 6) | (cTag << 4) | (bTag << 2) | aTag)

        var offset = 1
        store(input[0], output, offset)
        offset += Int64(aTag) + 1
        store(input[1], output, offset)
        offset += Int64(bTag) + 1
        store(input[2], output, offset)
        offset += Int64(cTag) + 1
        store(input[3], output, offset)
        offset += Int64(dTag) + 1

        offset
    }

    /**
     * @brief[zh-cn] 解码 4 个 UInt32 值
     * @param[zh-cn] input 编码后的字节缓冲区
     * @param[zh-cn] baseOffset 本组数据在缓冲区中的起始偏移（字节）
     * @param[zh-cn] output 输出 4 个 UInt32 值的数组（长度须为 4）
     * @return[zh-cn] 读取的字节数
     *
     * @brief[en] Decode 4 UInt32 values from a buffer
     * @param[en] input Encoded byte buffer
     * @param[en] baseOffset Start offset of this group in the buffer (bytes)
     * @param[en] output Output array of 4 UInt32 values (must be length 4)
     * @return[en] Number of bytes read
     */
    public static func decodeGroup(input: Array<UInt8>, baseOffset: Int, output: Array<UInt32>): Int {
        let prefix = input[baseOffset]
        var offset = baseOffset + 1

        let k0 = prefix & 0x03u8
        output[0] = load(input, offset) & getMask(Int64(k0))
        offset += Int64(k0) + 1

        let k1 = (prefix >> 2) & 0x03u8
        output[1] = load(input, offset) & getMask(Int64(k1))
        offset += Int64(k1) + 1

        let k2 = (prefix >> 4) & 0x03u8
        output[2] = load(input, offset) & getMask(Int64(k2))
        offset += Int64(k2) + 1

        let k3 = prefix >> 6
        output[3] = load(input, offset) & getMask(Int64(k3))
        offset += Int64(k3) + 1

        offset - baseOffset
    }

    /**
     * @brief[zh-cn] 编码 UInt32 流（输入大小须为 4 的倍数）
     * @param[zh-cn] stream 输入 UInt32 数组（长度须为 4 的倍数）
     * @return[zh-cn] 编码后的字节数组
     *
     * @brief[en] Encode a UInt32 stream (input size must be multiple of 4)
     * @param[en] stream Input UInt32 array (length must be multiple of 4)
     * @return[en] Encoded byte array
     */
    public static func encodeStream(stream: Array<UInt32>): Array<UInt8> {
        let numGroups = stream.size / 4
        let worstSize = stream.size * 4 + numGroups
        let output = Array<UInt8>(worstSize, { _ => 0u8 })
        var written = 0

        for (g in 0..numGroups) {
            let inputGroup = Array<UInt32>(4, { i => stream[g * 4 + i] })
            let outputGroup = Array<UInt8>(17, { _ => 0u8 })
            let bytesWritten = encodeGroup(inputGroup, outputGroup)
            for (j in 0..bytesWritten) {
                output[written + j] = outputGroup[j]
            }
            written += bytesWritten
        }

        Array<UInt8>(written, { i => output[i] })
    }

    /**
     * @brief[zh-cn] 解码 UInt32 流
     * @param[zh-cn] data 编码后的字节数组
     * @param[zh-cn] count 预期解码的 UInt32 值数量（须为 4 的倍数）
     * @return[zh-cn] 解码后的 UInt32 数组
     *
     * @brief[en] Decode a UInt32 stream
     * @param[en] data Encoded byte array
     * @param[en] count Expected number of UInt32 values (must be multiple of 4)
     * @return[en] Decoded UInt32 array
     */
    public static func decodeStream(data: Array<UInt8>, count: Int): Array<UInt32> {
        let result = Array<UInt32>(count, { _ => 0u32 })
        var readOffset = 0
        let numGroups = count / 4

        for (g in 0..numGroups) {
            let outputGroup = Array<UInt32>(4, { _ => 0u32 })
            let bytesRead = decodeGroup(data, readOffset, outputGroup)
            for (i in 0..4) {
                result[g * 4 + i] = outputGroup[i]
            }
            readOffset += bytesRead
        }

        result
    }

    /**
     * @brief[zh-cn] 计算最坏情况下的缓冲区大小
     * @param[zh-cn] count UInt32 值的数量
     * @return[zh-cn] 最大所需字节数
     *
     * @brief[en] Compute worst-case buffer size
     * @param[en] count Number of UInt32 values
     * @return[en] Maximum required bytes
     */
    public static func worstBufferSize(count: Int): Int {
        count * 4 + count / 4
    }

    private static func getMask(k: Int): UInt32 {
        match (k) {
            case 0 => GroupVarint.kMask0
            case 1 => GroupVarint.kMask1
            case 2 => GroupVarint.kMask2
            case _ => GroupVarint.kMask3
        }
    }
}
