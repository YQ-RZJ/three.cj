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
 * @file[zh-cn] AssetBundle 资源包
 * @brief[zh-cn] AssetBundle 式资源打包/读取：把多个资源文件打包为单个二进制档案
 * @explain[zh-cn] 对照 Unity AssetBundle 的打包-加载工作流，提供游戏资源的一次性打包与按名读取：
 * - 打包侧：AssetBundleBuilder 逐个 add(name, bytes) 后 build() 产出单文件档案，可 writeTo 落盘。
 * - 加载侧：AssetBundle.loadFromFile / loadFromBytes 一次性读入档案，get/read 按资源名零拷贝切片读取。
 * 档案格式（小端序）：
 *   magic[4] = 'C','J','A','B'
 *   version  : UInt32（当前 1）
 *   count    : UInt32 条目数
 *   entries  : count × { nameLen: UInt32, name: UTF-8 字节, offset: UInt32（数据区相对起点）, size: UInt32, crc32: UInt32 }
 *   data     : 各条目原始字节依次排列
 * 配合 AssetManager.loadFromBundle 可从包内异步分发资源；CRC32 用于加载后完整性校验。
 *
 * @file[en] AssetBundle  Resource bundle
 * @brief[en] AssetBundle-style packing/reading: packs multiple resource files into a single binary archive
 * @explain[en] Mirrors the Unity AssetBundle pack-and-load workflow:
 * - Pack side: AssetBundleBuilder accumulates add(name, bytes) then build() produces a single-file archive, writable via writeTo.
 * - Load side: AssetBundle.loadFromFile / loadFromBytes reads the archive once; get/read slices entries by name.
 * Archive format (little-endian):
 *   magic[4] = 'C','J','A','B'
 *   version  : UInt32 (currently 1)
 *   count    : UInt32 entry count
 *   entries  : count × { nameLen: UInt32, name: UTF-8 bytes, offset: UInt32 (relative to data section), size: UInt32, crc32: UInt32 }
 *   data     : raw bytes of each entry in order
 * Use with AssetManager.loadFromBundle to dispatch bundled assets; CRC32 verifies integrity after load.
 */
package three.resource.pipeline

import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] 资源包档案头中单条资源的索引信息
 *
 * @brief[en] Index info of a single entry in the bundle archive header
 */
public struct BundleEntry {
    /**
     * @brief[zh-cn] 资源名（打包时的 key，通常为相对路径）
     *
     * @brief[en] Entry name (the packing key, usually a relative path)
     */
    public var name: String
    /**
     * @brief[zh-cn] 数据区相对偏移（字节）
     *
     * @brief[en] Offset relative to the data section (bytes)
     */
    public var offset: UInt32
    /**
     * @brief[zh-cn] 数据字节数
     *
     * @brief[en] Data size in bytes
     */
    public var size: UInt32
    /**
     * @brief[zh-cn] 数据 CRC32 校验值
     *
     * @brief[en] CRC32 checksum of the data
     */
    public var crc32: UInt32

    public init(name: String, offset: UInt32, size: UInt32, crc32: UInt32) {
        this.name = name
        this.offset = offset
        this.size = size
        this.crc32 = crc32
    }
}

/**
 * @brief[zh-cn] 资源包（只读档案）
 * @explain[zh-cn] 由 AssetBundleBuilder 产出或从文件/字节加载。内部持有完整数据字节数组与
 * 名称→条目索引表；read(name) 按条目切片返回副本（避免外部修改内部数据）。
 *
 * @brief[en] Read-only resource bundle
 * @explain[en] Produced by AssetBundleBuilder or loaded from file/bytes. Holds the full data
 * byte array and a name→entry index; read(name) returns a copy of the entry slice
 * (to prevent external mutation of internal data).
 */
public class AssetBundle {
    /**
     * @brief[zh-cn] 档案魔数（"CJAB"）
     *
     * @brief[en] Archive magic ("CJAB")
     */
    public static let MAGIC: Array<UInt8> = [0x43u8, 0x4Au8, 0x41u8, 0x42u8]
    /**
     * @brief[zh-cn] 当前档案格式版本
     *
     * @brief[en] Current archive format version
     */
    public static const VERSION: UInt32 = 1u32

    /** 档案原始字节（含头部） */
    private var _data: Array<UInt8>
    /** 名称 → 条目索引 */
    private var _entries: HashMap<String, BundleEntry>
    /** 数据区在档案中的起始偏移 */
    private var _dataBase: Int64

    private init(data: Array<UInt8>, entries: HashMap<String, BundleEntry>, dataBase: Int64) {
        this._data = data
        this._entries = entries
        this._dataBase = dataBase
    }

    /**
     * @brief[zh-cn] 条目数量
     *
     * @brief[en] Entry count
     */
    public prop entryCount: Int64 {
        get() { _entries.size }
    }

    /**
     * @brief[zh-cn] 是否包含指定资源
     * @param[zh-cn] name 资源名
     * @return[zh-cn] 包含返回 true
     *
     * @brief[en] Whether the bundle contains the named entry
     * @param[en] name Entry name
     * @return[en] True when contained
     */
    public func contains(name: String): Bool {
        return _entries.contains(name)
    }

    /**
     * @brief[zh-cn] 获取指定资源的索引信息
     * @param[zh-cn] name 资源名
     * @return[zh-cn] 条目信息，不存在时返回 None
     *
     * @brief[en] Gets the index info of the named entry
     * @param[en] name Entry name
     * @return[en] Entry info, or None when absent
     */
    public func get(name: String): Option<BundleEntry> {
        return _entries.get(name)
    }

    /**
     * @brief[zh-cn] 读取指定资源的字节内容（返回切片副本）
     * @param[zh-cn] name 资源名
     * @return[zh-cn] 资源字节；资源不存在时返回 None
     *
     * @brief[en] Reads the named entry bytes (returns a slice copy)
     * @param[en] name Entry name
     * @return[en] Entry bytes, or None when absent
     */
    public func read(name: String): Option<Array<UInt8>> {
        if (let Some(e) <- _entries.get(name)) {
            let start = _dataBase + Int64(e.offset)
            let size = Int64(e.size)
            if (start + size > _data.size) {
                return None
            }
            let out = Array<UInt8>(size, { i => _data[start + i] })
            return Some(out)
        } else {
            return None
        }
    }

    /**
     * @brief[zh-cn] 遍历全部资源名
     * @return[zh-cn] 资源名列表（顺序为打包顺序）
     *
     * @brief[en] Iterates all entry names
     * @return[en] Entry name list (in packing order)
     */
    public func getNames(): ArrayList<String> {
        let names = ArrayList<String>()
        // HashMap 无序，按数据区 offset 排序输出，保证确定性
        let list = ArrayList<BundleEntry>()
        for ((_, e) in _entries) {
            list.add(e)
        }
        // 简单插入排序（条目数通常很小）
        for (i in 0..list.size) {
            var j = i
            while (j > 0 && list[j - 1].offset > list[j].offset) {
                let tmp = list[j - 1]
                list[j - 1] = list[j]
                list[j] = tmp
                j -= 1
            }
        }
        for (e in list) {
            names.add(e.name)
        }
        return names
    }

    /**
     * @brief[zh-cn] 从字节构建资源包并做完整性校验
     * @param[zh-cn] bytes 档案字节
     * verify 是否校验各条目 CRC32（默认 true）
     * @return[zh-cn] 解析成功返回 Some(AssetBundle)；魔数/版本不合法或 CRC 校验失败返回 None
     *
     * @brief[en] Builds a bundle from bytes with integrity verification
     * @param[en] bytes Archive bytes
     * verify Whether to verify per-entry CRC32 (default true)
     * @return[en] Some(AssetBundle) on success; None on bad magic/version or CRC mismatch
     */
    public static func loadFromBytes(bytes: Array<UInt8>, verify!: Bool = true): Option<AssetBundle> {
        let r = BundleReader(bytes)
        // 1. magic
        for (i in 0..4) {
            if (i >= bytes.size || bytes[i] != AssetBundle.MAGIC[i]) {
                return None
            }
        }
        // 2. version
        if (!r.skip(4)) { return None }
        let version = r.readU32()
        if (version != AssetBundle.VERSION) { return None }
        let count = r.readU32()
        let entries = HashMap<String, BundleEntry>()
        var maxEnd: UInt32 = 0u32
        var i: UInt32 = 0u32
        while (i < count) {
            let nameLen = r.readU32()
            if (nameLen == 0u32 || nameLen > 0xFFFFu32) { return None }
            let nameBytes = r.readBytes(Int64(nameLen))
            if (nameBytes.size != Int64(nameLen)) { return None }
            let name = String.fromUtf8(nameBytes)
            let offset = r.readU32()
            let size = r.readU32()
            let crc = r.readU32()
            if (entries.contains(name)) { return None }
            entries.add(name, BundleEntry(name, offset, size, crc))
            let end = offset + size
            if (end > maxEnd) { maxEnd = end }
            i += 1u32
        }
        let dataBase = r.position()
        // 3. 数据区长度校验
        if (dataBase + Int64(maxEnd) > bytes.size) { return None }
        // 4. CRC 校验
        if (verify) {
            for ((_, e) in entries) {
                let start = dataBase + Int64(e.offset)
                var crc = 0u32
                var p = start
                while (p < start + Int64(e.size)) {
                    crc = Crc32.update(crc, bytes[p])
                    p += 1
                }
                if (crc != e.crc32) { return None }
            }
        }
        return Some(AssetBundle(bytes, entries, dataBase))
    }

    /**
     * @brief[zh-cn] 从本地文件加载资源包
     * @param[zh-cn] path 档案文件路径
     * verify 是否校验各条目 CRC32（默认 true）
     * @return[zh-cn] 成功返回 Some(AssetBundle)；文件不存在/格式错误返回 None
     *
     * @brief[en] Loads a bundle from a local file
     * @param[en] path Archive file path
     * verify Whether to verify per-entry CRC32 (default true)
     * @return[en] Some(AssetBundle) on success; None when the file is missing or malformed
     */
    public static func loadFromFile(path: String, verify!: Bool = true): Option<AssetBundle> {
        try {
            let bytes = File.readFrom(path)
            return AssetBundle.loadFromBytes(bytes, verify: verify)
        } catch (e: Exception) {
            return None
        }
    }
}

/**
 * @brief[zh-cn] 资源包构建器
 * @explain[zh-cn] 用法：逐个 add(name, bytes)，最后 build()（内存档案）或 writeTo(path)（落盘）。
 * 同名资源重复 add 会覆盖先前数据。
 *
 * @brief[en] Asset bundle builder
 * @explain[en] Usage: add(name, bytes) repeatedly, then build() (in-memory archive) or
 * writeTo(path) (write to disk). Re-adding a name overwrites the previous data.
 */
public class AssetBundleBuilder {
    private var _items: ArrayList<(String, Array<UInt8>)>

    public init() {
        this._items = ArrayList<(String, Array<UInt8>)>()
    }

    /**
     * @brief[zh-cn] 添加一个资源条目
     * @param[zh-cn] name 资源名（档案内唯一，重复添加覆盖）
     * bytes 资源字节
     * @return[zh-cn] 自身引用（链式调用）
     *
     * @brief[en] Adds one entry
     * @param[en] name Entry name (unique in archive; re-adding overwrites)
     * bytes Entry bytes
     * @return[en] Self reference (for chaining)
     */
    public func add(name: String, bytes: Array<UInt8>): AssetBundleBuilder {
        // 覆盖同名条目
        var i = 0
        while (i < _items.size) {
            if (_items[i][0] == name) {
                _items.remove(at: i)
                break
            }
            i += 1
        }
        _items.add((name, bytes))
        return this
    }

    /**
     * @brief[zh-cn] 从本地文件添加资源条目
     * @param[zh-cn] name 资源名
     * path 本地文件路径
     * @return[zh-cn] 读取成功返回自身引用；失败返回 None（条目不加入）
     *
     * @brief[en] Adds one entry from a local file
     * @param[en] name Entry name
     * path Local file path
     * @return[en] Self reference on success; None when reading fails (entry not added)
     */
    public func addFile(name: String, path: String): Option<AssetBundleBuilder> {
        try {
            let bytes = File.readFrom(path)
            return Some(this.add(name, bytes))
        } catch (e: Exception) {
            return None
        }
    }

    /**
     * @brief[zh-cn] 构建档案字节
     * @return[zh-cn] 完整档案字节（可直接写入 AssetBundle.loadFromBytes）
     *
     * @brief[en] Builds the archive bytes
     * @return[en] Full archive bytes (feed directly to AssetBundle.loadFromBytes)
     */
    public func build(): Array<UInt8> {
        // 1. 计算头部大小：magic(4) + version(4) + count(4) + Σ(nameLen + name + 12)
        var headerSize: Int64 = 12
        for ((name, _) in _items) {
            headerSize += 4 + Int64(name.toArray().size) + 12
        }
        // 2. 计算数据区
        var total: Int64 = headerSize
        var offset: UInt32 = 0u32
        let encoded = ArrayList<(BundleEntry, Array<UInt8>)>()
        for ((name, bytes) in _items) {
            let nameBytes = name.toArray()
            var crc = 0u32
            for (b in bytes) {
                crc = Crc32.update(crc, b)
            }
            encoded.add((BundleEntry(name, offset, UInt32(bytes.size), crc), bytes))
            offset += UInt32(bytes.size)
            total += Int64(bytes.size)
        }
        // 3. 写出
        let w = BundleWriter()
        // magic
        for (b in AssetBundle.MAGIC) { w.writeU8(b) }
        w.writeU32(AssetBundle.VERSION)
        w.writeU32(UInt32(_items.size))
        // 条目表
        for ((e, _) in encoded) {
            let nameBytes = e.name.toArray()
            w.writeU32(UInt32(nameBytes.size))
            for (b in nameBytes) { w.writeU8(b) }
            w.writeU32(e.offset)
            w.writeU32(e.size)
            w.writeU32(e.crc32)
        }
        // 数据区
        for ((_, bytes) in encoded) {
            for (b in bytes) { w.writeU8(b) }
        }
        return w.toArray()
    }

    /**
     * @brief[zh-cn] 构建档案并写入本地文件
     * @param[zh-cn] path 输出文件路径
     * @return[zh-cn] 写入成功返回 true
     *
     * @brief[en] Builds the archive and writes it to a local file
     * @param[en] path Output file path
     * @return[en] True on success
     */
    public func writeTo(path: String): Bool {
        try {
            File.writeTo(path, this.build())
            return true
        } catch (e: Exception) {
            return false
        }
    }
}

/**
 * @brief[zh-cn] CRC32（IEEE 802.3，多项式 0xEDB88320）
 * @explain[zh-cn] 查表实现，首次使用时惰性构建 256 项表；供资源包条目完整性校验使用。
 *
 * @brief[en] CRC32 (IEEE 802.3, polynomial 0xEDB88320)
 * @explain[en] Table-driven implementation; the 256-entry table is built lazily.
 * Used for bundle entry integrity checks.
 */
internal class Crc32 {
    private static var _table: Array<UInt32> = Array<UInt32>()
    private static let _POLY: UInt32 = 0xEDB88320u32

    /**
     * @brief[zh-cn] 追加一个字节到校验值
     * @param[zh-cn] crc 当前校验值（首个字节传 0）
     * byte 追加的字节
     * @return[zh-cn] 更新后的校验值
     *
     * @brief[en] Feeds one byte into the checksum
     * @param[en] crc Current checksum (start with 0)
     * byte Byte to append
     * @return[en] Updated checksum
     */
    public static func update(crc: UInt32, byte: UInt8): UInt32 {
        if (_table.size == 0) {
            _buildTable()
        }
        let idx = Int64(((crc ^ UInt32(byte)) & 0xFFu32))
        return (crc >> 8u32) ^ _table[idx]
    }

    private static func _buildTable(): Unit {
        let table = Array<UInt32>(256, { _ => 0u32 })
        var i: UInt32 = 0u32
        while (i < 256u32) {
            var c = i
            var k = 0u32
            while (k < 8u32) {
                if ((c & 1u32) != 0u32) {
                    c = _POLY ^ (c >> 1u32)
                } else {
                    c = c >> 1u32
                }
                k += 1u32
            }
            table[Int64(i)] = c
            i += 1u32
        }
        _table = table
    }
}

// ===== 包内字节读写辅助 =====

/**
 * @brief[zh-cn] 小端序字节写出器（包内使用）
 *
 * @brief[en] Little-endian byte writer (package-internal)
 */
internal class BundleWriter {
    private var _buf: ArrayList<UInt8>

    public init() {
        this._buf = ArrayList<UInt8>()
    }

    public func writeU8(b: UInt8): Unit {
        _buf.add(b)
    }

    public func writeU32(v: UInt32): Unit {
        _buf.add(UInt8(v & 0xFFu32))
        _buf.add(UInt8((v >> 8u32) & 0xFFu32))
        _buf.add(UInt8((v >> 16u32) & 0xFFu32))
        _buf.add(UInt8((v >> 24u32) & 0xFFu32))
    }

    public func toArray(): Array<UInt8> {
        return _buf.toArray()
    }
}

/**
 * @brief[zh-cn] 小端序字节读取器（包内使用）
 *
 * @brief[en] Little-endian byte reader (package-internal)
 */
internal class BundleReader {
    private let _data: Array<UInt8>
    private var _pos: Int64

    public init(data: Array<UInt8>) {
        this._data = data
        this._pos = 0
    }

    /**
     * @brief[zh-cn] 当前读取位置
     *
     * @brief[en] Current read position
     */
    public func position(): Int64 {
        return _pos
    }

    /**
     * @brief[zh-cn] 跳过 n 字节
     * @param[zh-cn] n 跳过字节数
     * @return[zh-cn] 未越界返回 true
     *
     * @brief[en] Skips n bytes
     * @param[en] n Byte count to skip
     * @return[en] True when not out of bounds
     */
    public func skip(n: Int64): Bool {
        if (_pos + n > _data.size) { return false }
        _pos += n
        return true
    }

    /**
     * @brief[zh-cn] 读取一个 U32（小端序）
     * @return[zh-cn] 数值；越界返回 0
     *
     * @brief[en] Reads one U32 (little-endian)
     * @return[en] The value; 0 when out of bounds
     */
    public func readU32(): UInt32 {
        if (_pos + 4 > _data.size) { return 0u32 }
        let v = UInt32(_data[_pos]) | (UInt32(_data[_pos + 1]) << 8u32) |
            (UInt32(_data[_pos + 2]) << 16u32) | (UInt32(_data[_pos + 3]) << 24u32)
        _pos += 4
        return v
    }

    /**
     * @brief[zh-cn] 读取 n 字节切片副本
     * @param[zh-cn] n 字节数
     * @return[zh-cn] 字节切片（不足时返回实际可读部分）
     *
     * @brief[en] Reads a copy of n bytes
     * @param[en] n Byte count
     * @return[en] Byte slice (truncated to available bytes)
     */
    public func readBytes(n: Int64): Array<UInt8> {
        var avail = _data.size - _pos
        if (n < avail) { avail = n }
        let out = Array<UInt8>(avail, { i => _data[_pos + i] })
        _pos += avail
        return out
    }
}
