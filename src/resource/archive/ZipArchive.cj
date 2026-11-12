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
 * require the License.
 *
 * @file[zh-cn] ZipArchive ZIP 资源包解析与解压
 * @brief[zh-cn] 解析 ZIP 归档（中央目录），逐条目解压（stored/deflate）并做 CRC32 完整性校验
 * @explain[zh-cn] 为引擎补齐"远端下载压缩包 → 校验 → 解压"链路中的解包环节：
 *         - 容器解析在仓颉侧完成：定位 EOCD → 遍历中央目录 → 经本地头定位条目数据；
 *         - 解压复用 bgfx4cj.miniz 的封装导出：raw deflate 用
 *           mz_inflateInit2_cj(windowBits=-15) + mz_inflate_cj + mz_inflateEnd_cj；
 *         - CRC32 校验复用 mz_crc32_cj，与中央目录登记值比对（verify 开关控制）；
 *         - extractAll 支持落盘展开（File.writeTo / Directory.create），带 zip-slip 防护。
 *         注意：bgfx4cj 链接的 miniz 以 MINIZ_NO_ARCHIVE_APIS 裁剪，无 mz_zip_* 归档 API，
 *         故 ZIP 容器逻辑在本仓颉侧实现，仅复用其 zlib 原语。
 * @note[zh-cn] 安全约束：拒绝加密条目（flag bit0）、不支持的压缩方法与 zip-slip 路径
 *         （绝对路径 / .. 段 / 盘符）。
 *
 * @file[en] ZipArchive ZIP resource package parsing and extraction
 * @brief[en] Parses ZIP archives (central directory), extracts entries (stored/deflate)
 *            and verifies per-entry CRC32 integrity
 * @explain[en] Completes the engine's "remote package download → verify → extract" pipeline:
 *         - container parsing is done Cangjie-side: locate EOCD → walk the central
 *           directory → locate entry data via local headers;
 *         - decompression reuses bgfx4cj.miniz exports: raw deflate via
 *           mz_inflateInit2_cj(windowBits=-15) + mz_inflate_cj + mz_inflateEnd_cj;
 *         - CRC32 verification reuses mz_crc32_cj, compared against the value recorded
 *           in the central directory (gated by the verify flag);
 *         - extractAll writes entries to disk (File.writeTo / Directory.create) with
 *           zip-slip protection.
 *         Note: the miniz linked by bgfx4cj is built with MINIZ_NO_ARCHIVE_APIS (no
 *         mz_zip_* archive APIs), so the ZIP container logic lives here Cangjie-side and
 *         only the zlib primitives are reused.
 * @note[en] Security constraints: encrypted entries (flag bit0), unsupported compression
 *         methods and zip-slip paths (absolute / ".." segments / drive letters) are rejected.
 *
 * @package three.resource.archive
 */
package three.resource.archive

import std.collection.*
import std.fs.*
import three.utils.memory.AutoFreePtr
import three.utils.log.*
import three.utils.log.macros.*
import bgfx4cj.miniz.*

/** 本地文件头签名 Local file header signature */
const ZIP_LOCAL_SIG: UInt32 = 0x04034b50
/** 中央目录条目签名 Central directory entry signature */
const ZIP_CENTRAL_SIG: UInt32 = 0x02014b50
/** EOCD 签名 End-of-central-directory signature */
const ZIP_EOCD_SIG: UInt32 = 0x06054b50
/** EOCD 固定部分长度（不含注释） Fixed EOCD size without comment */
const ZIP_EOCD_SIZE: Int64 = 22
/** 中央目录条目固定部分长度 Fixed central directory entry size without variable fields */
const ZIP_CENTRAL_SIZE: Int64 = 46
/** 本地文件头固定部分长度 Fixed local file header size without name/extra */
const ZIP_LOCAL_SIZE: Int64 = 30
/** ZIP 压缩方法：存储（不压缩） ZIP method: stored */
const ZIP_METHOD_STORED: UInt16 = 0
/** ZIP 压缩方法：deflate ZIP method: deflate */
const ZIP_METHOD_DEFLATED: UInt16 = 8
/** 通用标志位 bit0：加密 General purpose flag bit0: encrypted */
const ZIP_FLAG_ENCRYPTED: UInt16 = 0x0001

/**
 * @brief[zh-cn] ZIP 条目元信息（来自中央目录）
 * @explain[zh-cn] 描述归档内单个条目的路径、尺寸、CRC32、压缩方法与标志位，
 *         由 ZipArchive.loadFromBytes 解析中央目录时构建，供 find/read/extractAll 使用。
 *
 * @brief[en] ZIP entry metadata (from the central directory)
 * @explain[en] Describes a single archive entry's path, sizes, CRC32, compression method
 *         and flags; built by ZipArchive.loadFromBytes when parsing the central directory,
 *         consumed by find/read/extractAll.
 */
public class ZipEntry {
    /**
     * @brief[zh-cn] 条目路径（ZIP 内部相对路径，'/' 分隔）
     *
     * @brief[en] Entry path inside the archive (relative, '/' separated)
     */
    public let name: String
    /**
     * @brief[zh-cn] 是否目录条目（名称以 '/' 结尾）
     *
     * @brief[en] Whether this is a directory entry (name ends with '/')
     */
    public let isDirectory: Bool
    /**
     * @brief[zh-cn] 压缩后字节大小
     *
     * @brief[en] Compressed size in bytes
     */
    public let compressedSize: Int64
    /**
     * @brief[zh-cn] 解压后字节大小
     *
     * @brief[en] Uncompressed size in bytes
     */
    public let uncompressedSize: Int64
    /**
     * @brief[zh-cn] 解压后数据的 CRC32（中央目录登记值）
     *
     * @brief[en] CRC32 of the uncompressed data (as recorded in the central directory)
     */
    public let crc32: UInt32
    /**
     * @brief[zh-cn] 压缩方法（0=stored，8=deflate）
     *
     * @brief[en] Compression method (0=stored, 8=deflate)
     */
    public let method: UInt16
    /**
     * @brief[zh-cn] 通用标志位（bit0=加密）
     *
     * @brief[en] General purpose flags (bit0 = encrypted)
     */
    public let flags: UInt16
    /** 本地文件头在归档中的偏移（内部使用） Local header offset (internal) */
    internal let localOffset: Int64

    /**
     * @brief[zh-cn] 创建条目元信息
     * @param[zh-cn] name 条目路径（ZIP 内部相对路径，'/' 分隔）
     * @param[zh-cn] isDirectory 是否目录条目（名称以 '/' 结尾）
     * @param[zh-cn] compressedSize 压缩后字节大小
     * @param[zh-cn] uncompressedSize 解压后字节大小
     * @param[zh-cn] crc32 解压后数据的 CRC32（中央目录登记值）
     * @param[zh-cn] method 压缩方法（0=stored，8=deflate）
     * @param[zh-cn] flags 通用标志位（bit0=加密）
     * @param[zh-cn] localOffset 本地文件头在归档中的偏移
     *
     * @brief[en] Creates entry metadata
     * @param[en] name Entry path inside the archive (relative, '/' separated)
     * @param[en] isDirectory Whether this is a directory entry (name ends with '/')
     * @param[en] compressedSize Compressed size in bytes
     * @param[en] uncompressedSize Uncompressed size in bytes
     * @param[en] crc32 CRC32 of the uncompressed data (as recorded in the central directory)
     * @param[en] method Compression method (0=stored, 8=deflate)
     * @param[en] flags General purpose flags (bit0 = encrypted)
     * @param[en] localOffset Local header offset inside the archive
     */
    public init(name: String, isDirectory: Bool, compressedSize: Int64,
                uncompressedSize: Int64, crc32: UInt32, method: UInt16,
                flags: UInt16, localOffset: Int64) {
        this.name = name
        this.isDirectory = isDirectory
        this.compressedSize = compressedSize
        this.uncompressedSize = uncompressedSize
        this.crc32 = crc32
        this.method = method
        this.flags = flags
        this.localOffset = localOffset
    }
}

/**
 * @brief[zh-cn] ZIP 归档：解析中央目录并按条目解压
 * @explain[zh-cn] 面向"远端下载压缩包 → 校验 → 解压"链路的 ZIP 只读解析器：
 *         容器结构（EOCD/中央目录/本地头）在仓颉侧解析，条目解压与 CRC32
 *         校验复用 bgfx4cj.miniz 的封装导出。
 * @example[zh-cn] 基本用法
 * ```
 * let zipOpt = ZipArchive.loadFromBytes(bytes)          // 或 loadFromFile(path)
 * let zip = zipOpt.getOrThrow()
 * let data = zip.read("assets/model.glb")               // 解压单条目（默认 CRC32 校验）
 * zip.extractAll("./extracted")                          // 全量落盘展开
 * ```
 * @note[zh-cn] loadFromBytes 只解析目录（开销与条目数成正比，不做解压）；
 *         解压与 CRC32 校验发生在每次 read()/extractAll()。
 *
 * @brief[en] ZIP archive: parses the central directory and extracts entries on demand
 * @explain[en] A read-only ZIP parser for the "remote package download → verify → extract"
 *         pipeline: the container structure (EOCD/central directory/local headers) is parsed
 *         Cangjie-side, while entry decompression and CRC32 verification reuse the
 *         bgfx4cj.miniz wrapper exports.
 * @example[en] Basic usage
 * ```
 * let zipOpt = ZipArchive.loadFromBytes(bytes)          // or loadFromFile(path)
 * let zip = zipOpt.getOrThrow()
 * let data = zip.read("assets/model.glb")               // extract one entry (CRC32 by default)
 * zip.extractAll("./extracted")                          // extract everything to disk
 * ```
 * @note[en] loadFromBytes only parses the directory (cost proportional to the entry count,
 * no decompression); decompression and CRC32 verification happen per read()/extractAll().
 */
public class ZipArchive {
    /** 归档原始字节 Raw archive bytes */
    private let _bytes: Array<UInt8>
    /** 中央目录条目（按归档顺序） Central directory entries (in archive order) */
    private let _entries: ArrayList<ZipEntry>
    /** name → 条目索引（重复名取最后出现者，与主流解压器一致） */
    private let _index: HashMap<String, Int64>

    private init(bytes: Array<UInt8>, entries: ArrayList<ZipEntry>) {
        this._bytes = bytes
        this._entries = entries
        this._index = HashMap<String, Int64>()
        for (i in 0..entries.size) {
            this._index[entries[i].name] = i
        }
    }

    /**
     * @brief[zh-cn] 归档内全部条目（按归档顺序，只读视图）
     *
     * @brief[en] All entries in the archive (in archive order, read-only view)
     */
    public prop entries: ArrayList<ZipEntry> {
        get() { this._entries }
    }

    /**
     * @brief[zh-cn] 条目数量
     *
     * @brief[en] Number of entries
     */
    public prop entryCount: Int64 {
        get() { this._entries.size }
    }

    /**
     * @brief[zh-cn] 从字节解析 ZIP 归档
     * @param[zh-cn] bytes ZIP 归档字节
     * @return[zh-cn] 解析成功返回 Some(ZipArchive)；非 ZIP 结构（找不到 EOCD /
     *         中央目录签名不符/条目越界）返回 None 并记录错误日志
     *
     * @brief[en] Parses a ZIP archive from bytes
     * @param[en] bytes ZIP archive bytes
     * @return[en] Some(ZipArchive) on success; None (with an error log) when the structure
     *         is not a ZIP (EOCD not found / bad central directory signatures / entries out of range)
     */
    public static func loadFromBytes(bytes: Array<UInt8>): Option<ZipArchive> {
        if (bytes.size < ZIP_EOCD_SIZE) {
            @LogError(["archive", "ZIP 解析失败：字节数 ${bytes.size} 不足 EOCD 最小长度"])
            return None
        }
        // 1. 从尾部向前定位 EOCD（注释区最长 65535 字节）
        var eocd = -1
        var i = bytes.size - ZIP_EOCD_SIZE
        while (i >= 0) {
            if (readU32(bytes, i) == ZIP_EOCD_SIG) {
                let commentLen = Int64(readU16(bytes, i + 20))
                if (i + ZIP_EOCD_SIZE + commentLen == bytes.size) {
                    eocd = i
                    break
                }
            }
            i--
        }
        if (eocd < 0) {
            @LogError(["archive", "ZIP 解析失败：未找到 EOCD（非 ZIP 文件或多段归档）"])
            return None
        }
        // 2. 中央目录定位（多卷字段一律要求单卷）
        let totalEntries = Int64(readU16(bytes, eocd + 10))
        let cdSize = Int64(readU32(bytes, eocd + 12))
        let cdOffset = Int64(readU32(bytes, eocd + 16))
        let diskNo = readU16(bytes, eocd + 4)
        if (diskNo != 0 || readU16(bytes, eocd + 6) != 0) {
            @LogError(["archive", "ZIP 解析失败：多卷归档不受支持"])
            return None
        }
        if (cdOffset < 0 || cdSize < 0 || cdOffset + cdSize > bytes.size) {
            @LogError(["archive", "ZIP 解析失败：中央目录越界 offset=${cdOffset} size=${cdSize}"])
            return None
        }
        // 3. 遍历中央目录条目
        let entries = ArrayList<ZipEntry>()
        var pos = cdOffset
        var parsed = 0
        while (parsed < totalEntries) {
            if (pos + ZIP_CENTRAL_SIZE > bytes.size || readU32(bytes, pos) != ZIP_CENTRAL_SIG) {
                @LogError(["archive", "ZIP 解析失败：第 ${parsed} 个中央目录条目签名/边界不符 pos=${pos}"])
                return None
            }
            let flags = readU16(bytes, pos + 8)
            let method = readU16(bytes, pos + 10)
            let crc = readU32(bytes, pos + 16)
            let compSize = Int64(readU32(bytes, pos + 20))
            let uncompSize = Int64(readU32(bytes, pos + 24))
            let nameLen = Int64(readU16(bytes, pos + 28))
            let extraLen = Int64(readU16(bytes, pos + 30))
            let commentLen = Int64(readU16(bytes, pos + 32))
            let localOffset = Int64(readU32(bytes, pos + 42))
            let nameStart = pos + ZIP_CENTRAL_SIZE
            if (nameStart + nameLen > bytes.size) {
                @LogError(["archive", "ZIP 解析失败：条目名越界 pos=${pos}"])
                return None
            }
            let name = String.fromUtf8(bytes[nameStart..nameStart + nameLen])
            let isDir = name.endsWith("/") || uncompSize == 0 && name.endsWith("\\")
            entries.add(ZipEntry(name, isDir, compSize, uncompSize, crc, method, flags, localOffset))
            pos = nameStart + nameLen + extraLen + commentLen
            parsed++
        }
        return Some(ZipArchive(bytes, entries))
    }

    /**
     * @brief[zh-cn] 从本地文件加载并解析 ZIP 归档
     * @param[zh-cn] path ZIP 文件路径
     * @return[zh-cn] 解析成功返回 Some(ZipArchive)；文件不存在或非 ZIP 返回 None
     *
     * @brief[en] Loads and parses a ZIP archive from a local file
     * @param[en] path ZIP file path
     * @return[en] Some(ZipArchive) on success; None when the file is missing or not a ZIP
     */
    public static func loadFromFile(path: String): Option<ZipArchive> {
        try {
            let bytes = File.readFrom(path)
            return ZipArchive.loadFromBytes(bytes)
        } catch (e: Exception) {
            @LogError(["archive", "ZIP 文件读取失败 path=${path}: ${e}"])
            return None
        }
    }

    /**
     * @brief[zh-cn] 按名查找条目
     * @param[zh-cn] name 条目路径（ZIP 内部相对路径，'/' 分隔）
     * @return[zh-cn] 找到返回 Some(ZipEntry)，否则 None
     *
     * @brief[en] Finds an entry by name
     * @param[en] name Entry path inside the archive
     * @return[en] Some(ZipEntry) when found, otherwise None
     */
    public func find(name: String): Option<ZipEntry> {
        if (let Some(idx) <- this._index.get(name)) {
            return Some(this._entries[idx])
        }
        return None
    }

    /**
     * @brief[zh-cn] 解压单个条目（默认做 CRC32 完整性校验）
     * @param[zh-cn] name 条目路径
     * @param[zh-cn] verify 是否校验解压结果的 CRC32（默认 true）
     * @return[zh-cn] 成功返回 Some(解压后字节)；条目不存在/加密/压缩方法不支持/
     *         解压失败/CRC 不符返回 None 并记录错误日志
     *
     * @brief[en] Extracts a single entry (CRC32 verification by default)
     * @param[en] name Entry path
     * @param[en] verify Whether to verify the extracted data's CRC32 (default true)
     * @return[en] Some(extracted bytes) on success; None (with an error log) when the entry
     *         is missing/encrypted/uses an unsupported method/decompression fails/CRC mismatch
     */
    public func read(name: String, verify!: Bool = true): Option<Array<UInt8>> {
        if (let Some(entry) <- this.find(name)) {
            return this.readEntry(entry, verify: verify)
        }
        @LogError(["archive", "ZIP 条目不存在 name=${name}"])
        return None
    }

    /**
     * @brief[zh-cn] 将全部条目解压落盘到指定目录
     * @explain[zh-cn] 目录条目建目录；文件条目写文件。任一条目失败即中止并返回 false
     *         （已写出的文件不回滚）。目标目录不存在时递归创建。
     *         带 zip-slip 防护：拒绝绝对路径、盘符与包含 ".." 段的条目名。
     * @param[zh-cn] dir 目标目录
     * @param[zh-cn] verify 是否校验每个文件条目的 CRC32（默认 true）
     * @return[zh-cn] 全部条目处理成功返回 true
     *
     * @brief[en] Extracts all entries to the target directory
     * @explain[en] Directory entries are created as directories; file entries are written as
     * files. Any failing entry aborts and returns false (already-written files are not rolled
     * back). The target directory is created recursively when missing. Zip-slip protection:
     * absolute paths, drive letters and names containing ".." segments are rejected.
     * @param[en] dir Target directory
     * @param[en] verify Whether to verify each file entry's CRC32 (default true)
     * @return[en] true when all entries are processed successfully
     */
    public func extractAll(dir: String, verify!: Bool = true): Bool {
        for (entry in this._entries) {
            if (!ZipArchive.isSafeEntryName(entry.name)) {
                @LogError(["archive", "extractAll 拒绝不安全条目名 name=${entry.name}"])
                return false
            }
            // 统一 '/' 分隔符后拼目标路径（Windows 下 std.fs 同时接受两种分隔符）
            let rel = entry.name.replace("\\", "/")
            let target = dir + "/" + rel
            if (entry.isDirectory) {
                try {
                    // 幂等创建：目录已存在时跳过（重复展开/残留目录场景）
                    if (!exists(target)) {
                        Directory.create(target, recursive: true)
                    }
                } catch (e: Exception) {
                    @LogError(["archive", "建目录失败 dir=${target}: ${e}"])
                    return false
                }
            } else {
                if (let Some(data) <- this.readEntry(entry, verify: verify)) {
                    try {
                        // 父目录可能未作为独立条目存在，写文件前先建（幂等）
                        let sep = target.lastIndexOf('/')
                        if (let Some(idx) <- sep) {
                            let parent = target[0..idx]
                            if (!exists(parent)) {
                                Directory.create(parent, recursive: true)
                            }
                        }
                        File.writeTo(target, data)
                    } catch (e: Exception) {
                        @LogError(["archive", "写文件失败 path=${target}: ${e}"])
                        return false
                    }
                } else {
                    @LogError(["archive", "条目解压失败，中止展开 name=${entry.name}"])
                    return false
                }
            }
        }
        return true
    }

    // ===== 内部实现 =====

    /** 解压单个条目：stored 直接拷贝；deflate 经 miniz raw inflate；可选 CRC32 校验 */
    private func readEntry(entry: ZipEntry, verify!: Bool): Option<Array<UInt8>> {
        if (entry.isDirectory) {
            return Some(Array<UInt8>())
        }
        if ((entry.flags & ZIP_FLAG_ENCRYPTED) != 0) {
            @LogError(["archive", "加密条目不受支持 name=${entry.name}"])
            return None
        }
        if ((entry.method != ZIP_METHOD_STORED) && (entry.method != ZIP_METHOD_DEFLATED)) {
            @LogError(["archive", "不支持的压缩方法 method=${entry.method} name=${entry.name}"])
            return None
        }
        // 本地文件头：取实际 nameLen/extraLen 定位数据区（可能与中央目录不一致）
        let lo = entry.localOffset
        if (lo < 0 || lo + ZIP_LOCAL_SIZE > this._bytes.size || readU32(this._bytes, lo) != ZIP_LOCAL_SIG) {
            @LogError(["archive", "本地文件头非法 offset=${lo} name=${entry.name}"])
            return None
        }
        let nameLen = Int64(readU16(this._bytes, lo + 26))
        let extraLen = Int64(readU16(this._bytes, lo + 28))
        let dataStart = lo + ZIP_LOCAL_SIZE + nameLen + extraLen
        let compSize = entry.compressedSize
        if (dataStart < 0 || compSize < 0 || dataStart + compSize > this._bytes.size) {
            @LogError(["archive", "条目数据越界 offset=${dataStart} size=${compSize} name=${entry.name}"])
            return None
        }
        if (entry.uncompressedSize < 0) {
            @LogError(["archive", "解压尺寸非法 size=${entry.uncompressedSize} name=${entry.name}"])
            return None
        }
        let uncompSize = entry.uncompressedSize
        let out = Array<UInt8>(uncompSize, repeat: 0)
        if (compSize == 0) {
            // 空文件条目：直接 CRC 校验（应登记为 0）
            if (verify && entry.crc32 != 0) {
                @LogError(["archive", "空条目 CRC 不符 name=${entry.name}"])
                return None
            }
            return Some(out)
        }
        if (entry.method == ZIP_METHOD_STORED) {
            for (k in 0..compSize) {
                out[k] = this._bytes[dataStart + k]
            }
            if (verify && !ZipArchive.crcMatches(out, uncompSize, entry.crc32, entry.name)) {
                return None
            }
            return Some(out)
        }
        // deflate 条目：复用 bgfx4cj.miniz 的 raw inflate（windowBits=-15，ZIP 无 zlib 头）
        if (!this.inflateEntry(dataStart, compSize, out, uncompSize, entry.name)) {
            return None
        }
        if (verify && !ZipArchive.crcMatches(out, uncompSize, entry.crc32, entry.name)) {
            return None
        }
        return Some(out)
    }

    /** miniz raw inflate：数据拷入堆缓冲 → mz_inflateInit2(-15) → mz_inflate(MZ_FINISH) → mz_inflateEnd */
    private func inflateEntry(dataStart: Int64, compSize: Int64,
                              out: Array<UInt8>, uncompSize: Int64, name: String): Bool {
        // 源/输出缓冲走堆分配（匹配引擎既有 FFI 惯用法：LibC.malloc + AutoFreePtr）
        let srcHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: compSize) })
        let dstHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: uncompSize) })
        let streamHolder = AutoFreePtr<MzStream>(unsafe { LibC.malloc<MzStream>() })
        let srcPtr = srcHolder.get()
        let dstPtr = dstHolder.get()
        if (srcPtr.isNull() || dstPtr.isNull() ||
            streamHolder.get().isNull()) {
            @LogError(["archive", "FFI 缓冲分配失败 name=${name}"])
            return false
        }
        unsafe {
            for (k in 0..compSize) { (srcPtr + k).write(this._bytes[dataStart + k]) }
            let sp = CPointer<MzStream>(streamHolder.get())
            sp.write(MzStream())
            // raw deflate：windowBits 取 -15（ZIP 条目无 zlib 头尾）
            let initRet = mz_inflateInit2_cj(sp, -15)
            if (initRet != MZ_OK) {
                @LogError(["archive", "inflate 初始化失败 ret=${initRet} name=${name}"])
                mz_inflateEnd_cj(sp)
                return false
            }
            // 结构体经指针 FFI 传递：一次 read 出副本、填齐字段、整体 write 回
            var s = sp.read()
            s.next_in = CPointer<UInt8>(srcPtr)
            s.avail_in = UInt32(compSize)
            s.next_out = dstPtr
            s.avail_out = UInt32(uncompSize)
            sp.write(s)
            let ret = mz_inflate_cj(sp, MZ_FINISH)
            mz_inflateEnd_cj(sp)
            if (ret != MZ_STREAM_END) {
                @LogError(["archive", "inflate 失败 ret=${ret} name=${name}"])
                return false
            }
            let produced = sp.read().total_out
            if (Int64(produced) != uncompSize) {
                @LogError(["archive", "解压尺寸不符 produced=${produced} expect=${uncompSize} name=${name}"])
                return false
            }
            for (k in 0..uncompSize) { out[k] = (dstPtr + k).read() }
        }
        return true
    }

    /** 解压结果的 CRC32 与中央目录登记值比对（mz_crc32_cj，失败记日志） */
    private static func crcMatches(data: Array<UInt8>, size: Int64,
                                   expected: UInt32, name: String): Bool {
        // 数组拷入堆缓冲后经 mz_crc32_cj 计算（复用 bgfx4cj 封装导出）
        let holder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: size) })
        let ptr = holder.get()
        if (ptr.isNull()) {
            @LogError(["archive", "CRC 缓冲分配失败 name=${name}"])
            return false
        }
        unsafe {
            for (k in 0..size) { (ptr + k).write(data[k]) }
            let crc = mz_crc32_cj(MZ_CRC32_INIT, ptr, UIntNative(size))
            if (crc != expected) {
                @LogError(["archive", "CRC32 校验失败 got=${crc.toString()} expect=${expected.toString()} name=${name}"])
                return false
            }
        }
        return true
    }

    /** zip-slip 防护：拒绝绝对路径、盘符、反斜杠开头的 ".." 段等逃逸路径 */
    internal static func isSafeEntryName(name: String): Bool {
        if (name.size == 0) { return false }
        // 统一分隔符后按段检查
        let norm = name.replace("\\", "/")
        if (norm.startsWith("/") || norm.contains(":")) { return false }
        for (seg in norm.split("/")) {
            if (seg == "..") { return false }
        }
        return true
    }

    /** 小端读 16 位（越界返回 0，调用方先做边界检查） */
    private static func readU16(bytes: Array<UInt8>, pos: Int64): UInt16 {
        if (pos < 0 || pos + 2 > bytes.size) { return 0 }
        let lo = UInt16(bytes[pos])
        let hi = UInt16(bytes[pos + 1])
        return lo | (hi << 8)
    }

    /** 小端读 32 位（越界返回 0，调用方先做边界检查） */
    private static func readU32(bytes: Array<UInt8>, pos: Int64): UInt32 {
        if (pos < 0 || pos + 4 > bytes.size) { return 0 }
        var v: UInt32 = 0
        for (k in 0..4) {
            v |= UInt32(bytes[pos + k]) << (8 * UInt32(k))
        }
        return v
    }
}
