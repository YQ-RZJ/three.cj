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
 * @file[zh-cn] PacketCodec 游戏协议包编解码（three.network.protocol 子包）
 * @brief[zh-cn] PacketWriter / PacketReader —— 面向游戏消息的大端序（网络字节序）读写器
 * @explain[zh-cn] 设计：
 *         - 编解码统一走 std.binary 的 BigEndianOrder 扩展（网络字节序 = 大端），
 *           不手写位运算；支持 Bool / Int8~Int64 / UInt8~UInt64 / Float32 / Float64。
 *         - PacketWriter 内部用 ArrayList<UInt8> 累积 + 8 字节 scratch 复用，
 *           避免每个字段分配临时数组；PacketReader 持只读数据 + 游标，切片零拷贝读取。
 *         - writeString / readString 采用 [u32 字节长度 + UTF-8 字节] 编码，
 *           单字符串上限 MAX_STRING_BYTES（16MB）防恶意长度声明炸内存。
 *         - 越界读取统一抛 IllegalStateException（对齐仓库既有异常风格），
 *           由上层按需捕获转为错误包处理。
 * 典型用法：
 * let w = PacketWriter()
 * w.writeU16(7)             // 消息类型
 * w.writeString("hello")
 * w.writeF32(0.5)
 * let bytes = w.toArray()   // 发送到 Connection.send(bytes)
 * // 接收端
 * let r = PacketReader(bytes)
 * let msgType = r.readU16()
 * let text = r.readString()
 *
 * @file[en] PacketCodec  Game protocol packet codec (three.network.protocol sub-package)
 * @brief[en] PacketWriter / PacketReader - big-endian (network byte order) readers/writers
 * for game messages
 * @explain[en] Design:
 *         - Encoding/decoding goes through std.binary BigEndianOrder extensions
 *           (network byte order = big-endian); no hand-written bit twiddling; supports
 *           Bool / Int8~Int64 / UInt8~UInt64 / Float32 / Float64.
 *         - PacketWriter accumulates into an ArrayList<UInt8> with a reused 8-byte scratch
 *           buffer to avoid per-field temporary allocations; PacketReader holds read-only
 *           data plus a cursor, slicing without copying on reads.
 *         - writeString / readString use [u32 byte length + UTF-8 bytes]; a per-string cap
 *           of MAX_STRING_BYTES (16MB) guards against malicious length declarations.
 *         - Out-of-bounds reads throw IllegalStateException (matching the repo's existing
 *           exception style); the upper layer may catch and turn them into error packets.
 * Usage:
 * let w = PacketWriter()
 * w.writeU16(7)             // message type
 * w.writeString("hello")
 * w.writeF32(0.5)
 * let bytes = w.toArray()   // feed to Connection.send(bytes)
 * // receiver side
 * let r = PacketReader(bytes)
 * let msgType = r.readU16()
 * let text = r.readString()
 */
package three.network.protocol

import std.collection.ArrayList
import std.binary.*

/** 单个字符串编码的最大字节数（16MB，防恶意长度声明） */
public const MAX_STRING_BYTES: Int64 = 16 * 1024 * 1024

/**
 * @brief[zh-cn] 协议包写出器
 * @explain[zh-cn] 大端序累积写出；字段按写入顺序编码。线程不安全（单线程构造完整包后发送）。
 *
 * @brief[en] Packet writer
 * @explain[en] Big-endian accumulating writer; fields are encoded in write order.
 * Not thread-safe (build a full packet on one thread, then send).
 */
public class PacketWriter {
    /** 累积缓冲区 */
    private var _buf: ArrayList<UInt8>

    /** 8 字节复用暂存（writeBigEndian 从索引 0 写入，再按宽度追加） */
    private var _scratch: Array<UInt8>

    /**
     * @brief[zh-cn] 构造写出器
     *
     * @brief[en] Constructs a writer
     */
    public init() {
        this._buf = ArrayList<UInt8>()
        this._scratch = Array<UInt8>(8, repeat: 0u8)
    }

    /**
     * @brief[zh-cn] 当前已累积的字节数
     *
     * @brief[en] Current accumulated byte count
     */
    public prop size: Int64 {
        get() { _buf.size }
    }

    /**
     * @brief[zh-cn] 写入单个字节
     * @param[zh-cn] v 字节值
     *
     * @brief[en] Writes a single byte
     * @param[en] v Byte value
     */
    public func writeU8(v: UInt8): Unit {
        _buf.add(v)
    }

    /**
     * @brief[zh-cn] 写入 UInt16（2 字节大端）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes a UInt16 (2 bytes, big-endian)
     * @param[en] v Value
     */
    public func writeU16(v: UInt16): Unit {
        let n = v.writeBigEndian(_scratch)
        _append(_scratch, n)
    }

    /**
     * @brief[zh-cn] 写入 UInt32（4 字节大端）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes a UInt32 (4 bytes, big-endian)
     * @param[en] v Value
     */
    public func writeU32(v: UInt32): Unit {
        let n = v.writeBigEndian(_scratch)
        _append(_scratch, n)
    }

    /**
     * @brief[zh-cn] 写入 UInt64（8 字节大端）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes a UInt64 (8 bytes, big-endian)
     * @param[en] v Value
     */
    public func writeU64(v: UInt64): Unit {
        let n = v.writeBigEndian(_scratch)
        _append(_scratch, n)
    }

    /**
     * @brief[zh-cn] 写入 Int16（2 字节大端补码）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes an Int16 (2 bytes, big-endian two's complement)
     * @param[en] v Value
     */
    public func writeI16(v: Int16): Unit {
        let n = v.writeBigEndian(_scratch)
        _append(_scratch, n)
    }

    /**
     * @brief[zh-cn] 写入 Int32（4 字节大端补码）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes an Int32 (4 bytes, big-endian two's complement)
     * @param[en] v Value
     */
    public func writeI32(v: Int32): Unit {
        let n = v.writeBigEndian(_scratch)
        _append(_scratch, n)
    }

    /**
     * @brief[zh-cn] 写入 Int64（8 字节大端补码）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes an Int64 (8 bytes, big-endian two's complement)
     * @param[en] v Value
     */
    public func writeI64(v: Int64): Unit {
        let n = v.writeBigEndian(_scratch)
        _append(_scratch, n)
    }

    /**
     * @brief[zh-cn] 写入布尔值（1 字节：true=1，false=0）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes a Bool (1 byte: true=1, false=0)
     * @param[en] v Value
     */
    public func writeBool(v: Bool): Unit {
        _buf.add(if (v) { 1u8 } else { 0u8 })
    }

    /**
     * @brief[zh-cn] 写入 Float32（4 字节大端 IEEE 754）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes a Float32 (4 bytes, big-endian IEEE 754)
     * @param[en] v Value
     */
    public func writeF32(v: Float32): Unit {
        let n = v.writeBigEndian(_scratch)
        _append(_scratch, n)
    }

    /**
     * @brief[zh-cn] 写入 Float64（8 字节大端 IEEE 754）
     * @param[zh-cn] v 值
     *
     * @brief[en] Writes a Float64 (8 bytes, big-endian IEEE 754)
     * @param[en] v Value
     */
    public func writeF64(v: Float64): Unit {
        let n = v.writeBigEndian(_scratch)
        _append(_scratch, n)
    }

    /**
     * @brief[zh-cn] 写入原始字节（不带长度前缀）
     * @param[zh-cn] data 字节数组
     *
     * @brief[en] Writes raw bytes (no length prefix)
     * @param[en] data Byte array
     */
    public func writeBytes(data: Array<UInt8>): Unit {
        for (b in data) {
            _buf.add(b)
        }
    }

    /**
     * @brief[zh-cn] 写入字符串（u32 字节长度 + UTF-8 字节）
     * @param[zh-cn] s 文本（空串编码为长度 0）
     *
     * @brief[en] Writes a string (u32 byte length + UTF-8 bytes)
     * @param[en] s Text (empty string encodes as length 0)
     */
    public func writeString(s: String): Unit {
        let bytes = s.toArray()
        writeU32(UInt32(bytes.size))
        writeBytes(bytes)
    }

    /**
     * @brief[zh-cn] 取出完整包字节
     * @return[zh-cn] 已累积内容的副本
     *
     * @brief[en] Takes the full packet bytes
     * @return[en] Copy of the accumulated content
     */
    public func toArray(): Array<UInt8> {
        return _buf.toArray()
    }

    /**
     * @brief[zh-cn] 清空缓冲区（复用写出器构造下一个包）
     *
     * @brief[en] Clears the buffer (reuse the writer for the next packet)
     */
    public func clear(): Unit {
        _buf.clear()
    }

    /** 把 scratch 前 n 字节追加进累积缓冲 */
    private func _append(src: Array<UInt8>, n: Int64): Unit {
        for (i in 0..n) {
            _buf.add(src[i])
        }
    }
}

/**
 * @brief[zh-cn] 协议包读取器
 * @explain[zh-cn] 大端序顺序读取；游标只前进（remaining 之外读取抛 IllegalStateException）。
 * 线程不安全（单线程消费一个包）。
 *
 * @brief[en] Packet reader
 * @explain[en] Big-endian sequential reads; the cursor only moves forward (reads beyond
 * remaining throw IllegalStateException). Not thread-safe (consume one packet on one thread).
 */
public class PacketReader {
    /** 只读数据 */
    private let _data: Array<UInt8>

    /** 游标（下一读取位置） */
    private var _pos: Int64

    /**
     * @brief[zh-cn] 构造读取器
     * @param[zh-cn] data 包字节（持有引用，不拷贝）
     *
     * @brief[en] Constructs a reader
     * @param[en] data Packet bytes (held by reference, not copied)
     */
    public init(data: Array<UInt8>) {
        this._data = data
        this._pos = 0
    }

    /**
     * @brief[zh-cn] 剩余未读字节数
     *
     * @brief[en] Remaining unread byte count
     */
    public prop remaining: Int64 {
        get() { _data.size - _pos }
    }

    /**
     * @brief[zh-cn] 是否还有未读字节
     *
     * @brief[en] Whether unread bytes remain
     */
    public prop hasMore: Bool {
        get() { _pos < _data.size }
    }

    /**
     * @brief[zh-cn] 读取单个字节
     * @return[zh-cn] 字节值
     *
     * @brief[en] Reads a single byte
     * @return[en] Byte value
     */
    public func readU8(): UInt8 {
        _need(1)
        let v = _data[_pos]
        _pos += 1
        return v
    }

    /**
     * @brief[zh-cn] 读取 UInt16（2 字节大端）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads a UInt16 (2 bytes, big-endian)
     * @return[en] Value
     */
    public func readU16(): UInt16 {
        _need(2)
        let v = UInt16.readBigEndian(_slice(2))
        return v
    }

    /**
     * @brief[zh-cn] 读取 UInt32（4 字节大端）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads a UInt32 (4 bytes, big-endian)
     * @return[en] Value
     */
    public func readU32(): UInt32 {
        _need(4)
        let v = UInt32.readBigEndian(_slice(4))
        return v
    }

    /**
     * @brief[zh-cn] 读取 UInt64（8 字节大端）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads a UInt64 (8 bytes, big-endian)
     * @return[en] Value
     */
    public func readU64(): UInt64 {
        _need(8)
        let v = UInt64.readBigEndian(_slice(8))
        return v
    }

    /**
     * @brief[zh-cn] 读取 Int16（2 字节大端补码）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads an Int16 (2 bytes, big-endian two's complement)
     * @return[en] Value
     */
    public func readI16(): Int16 {
        _need(2)
        let v = Int16.readBigEndian(_slice(2))
        return v
    }

    /**
     * @brief[zh-cn] 读取 Int32（4 字节大端补码）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads an Int32 (4 bytes, big-endian two's complement)
     * @return[en] Value
     */
    public func readI32(): Int32 {
        _need(4)
        let v = Int32.readBigEndian(_slice(4))
        return v
    }

    /**
     * @brief[zh-cn] 读取 Int64（8 字节大端补码）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads an Int64 (8 bytes, big-endian two's complement)
     * @return[en] Value
     */
    public func readI64(): Int64 {
        _need(8)
        let v = Int64.readBigEndian(_slice(8))
        return v
    }

    /**
     * @brief[zh-cn] 读取布尔值（1 字节：非 0 为 true）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads a Bool (1 byte: nonzero is true)
     * @return[en] Value
     */
    public func readBool(): Bool {
        return readU8() != 0u8
    }

    /**
     * @brief[zh-cn] 读取 Float32（4 字节大端 IEEE 754）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads a Float32 (4 bytes, big-endian IEEE 754)
     * @return[en] Value
     */
    public func readF32(): Float32 {
        _need(4)
        let v = Float32.readBigEndian(_slice(4))
        return v
    }

    /**
     * @brief[zh-cn] 读取 Float64（8 字节大端 IEEE 754）
     * @return[zh-cn] 值
     *
     * @brief[en] Reads a Float64 (8 bytes, big-endian IEEE 754)
     * @return[en] Value
     */
    public func readF64(): Float64 {
        _need(8)
        let v = Float64.readBigEndian(_slice(8))
        return v
    }

    /**
     * @brief[zh-cn] 读取长度前缀字节块（u32 长度 + 字节）
     * @return[zh-cn] 字节数组副本
     *
     * @brief[en] Reads a length-prefixed byte block (u32 length + bytes)
     * @return[en] Copy of the byte array
     */
    public func readBytes(): Array<UInt8> {
        let n = Int64(readU32())
        _need(n)
        let out = Array<UInt8>(n, { i => _data[_pos + i] })
        _pos += n
        return out
    }

    /**
     * @brief[zh-cn] 读取字符串（u32 字节长度 + UTF-8）
     * @return[zh-cn] 文本
     *
     * @brief[en] Reads a string (u32 byte length + UTF-8)
     * @return[en] Text
     */
    public func readString(): String {
        return String.fromUtf8(readBytes())
    }

    /**
     * @brief[zh-cn] 当前游标位置（字节偏移，用于调试/跳过）
     *
     * @brief[en] Current cursor position (byte offset, for debugging/skipping)
     */
    public prop position: Int64 {
        get() { _pos }
    }

    /**
     * @brief[zh-cn] 跳过 n 个字节
     * @param[zh-cn] n 跳过的字节数
     *
     * @brief[en] Skips n bytes
     * @param[en] n Number of bytes to skip
     */
    public func skip(n: Int64): Unit {
        _need(n)
        _pos += n
    }

    // ===== 内部 =====

    /** 取出 [pos, pos+n) 切片并推进游标（调用前须 _need） */
    private func _slice(n: Int64): Array<UInt8> {
        let s = _data[_pos.._pos + n]
        _pos += n
        return s
    }

    /** 越界守卫：不足 n 字节时抛 IllegalStateException */
    private func _need(n: Int64): Unit {
        if (n < 0 || _pos + n > _data.size) {
            throw IllegalStateException(
                "PacketReader: need ${n} bytes at pos ${_pos}, but only ${_data.size - _pos} remain")
        }
    }
}
