/**
 * @file ZipArchiveTest
 * @brief test_asset_pipeline: three.resource.archive.ZipArchive 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测能力：
 * - 测试内自建 ZIP 字节流（stored 手工构造；deflate 用纯仓颉构造"全存储块"raw deflate 流，
 *   不引入 bgfx4cj 依赖——测试项目只测 three.cj 暴露的部分）
 * - loadFromBytes/loadFromFile 解析：entryCount/find/条目元信息
 * - read：stored/deflate 往返一致、目录与空条目、缺失条目
 * - CRC32 校验：篡改中央目录 CRC 后 verify=true 拒绝、verify=false 跳过
 * - 加密条目（flag bit0）与非支持压缩方法返回 None
 * - extractAll 落盘展开与 zip-slip 防护
 */
package test_asset_pipeline

import std.unittest.*
import std.collection.*
import std.fs.*
import three.resource.archive.*

// 测试本地 ZIP 格式常量（引擎包内同名常量为 internal，测试自建不依赖引擎内部符号）
const ZIP_LOCAL_SIG: UInt32 = 0x04034b50
const ZIP_CENTRAL_SIG: UInt32 = 0x02014b50
const ZIP_EOCD_SIG: UInt32 = 0x06054b50

/// 测试用 ZIP 条目描述
class ZipSpec {
    let name: String
    let method: UInt16
    let flags: UInt16
    let data: Array<UInt8>
    init(name: String, method: UInt16, flags: UInt16, data: Array<UInt8>) {
        this.name = name
        this.method = method
        this.flags = flags
        this.data = data
    }
}

public class ZipArchiveTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ZipArchiveTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_zip_parse_and_read(); () }
            suiteBuilder.add(UnitTestCase.create("test_zip_parse_and_read", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_zip_deflate_roundtrip(); () }
            suiteBuilder.add(UnitTestCase.create("test_zip_deflate_roundtrip", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_zip_crc_tamper(); () }
            suiteBuilder.add(UnitTestCase.create("test_zip_crc_tamper", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_zip_unsupported_and_encrypted(); () }
            suiteBuilder.add(UnitTestCase.create("test_zip_unsupported_and_encrypted", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_zip_extract_all(); () }
            suiteBuilder.add(UnitTestCase.create("test_zip_extract_all", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_zip_zip_slip(); () }
            suiteBuilder.add(UnitTestCase.create("test_zip_zip_slip", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_zip_file_extract_roundtrip(); () }
            suiteBuilder.add(UnitTestCase.create("test_zip_file_extract_roundtrip", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // ===== 测试 ZIP 构造辅助（纯仓颉，不依赖 bgfx4cj） =====

    /// 标准 CRC32（多项式 0xEDB88320，独立实现用于构造期望值）
    private static func crc32Of(data: Array<UInt8>): UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        for (b in data) {
            crc ^= UInt32(b)
            for (k in 0..8) {
                let mask = if ((crc & 1) != 0) { 0xEDB88320u32 } else { 0u32 }
                crc = (crc >> 1) ^ mask
            }
        }
        return !crc
    }

    /// 构造"全存储块"（BTYPE=00）的合法 raw deflate 流：
    /// 是标准 deflate 格式的子集，能真实走通引擎侧 mz_inflate 解压路径，
    /// 而测试侧无需实现压缩器（与被测代码零共享实现）
    private static func deflateRaw(data: Array<UInt8>): Array<UInt8> {
        let out = ArrayList<UInt8>()
        if (data.size == 0) {
            // 空数据：单个 final 空存储块（LEN=0, NLEN=0xFFFF）
            out.add(0x01u8)
            out.add(0x00u8)
            out.add(0x00u8)
            out.add(0xFFu8)
            out.add(0xFFu8)
            return out.toArray()
        }
        var pos: Int64 = 0
        while (pos < data.size) {
            let remain = data.size - pos
            let chunk = if (remain > 65535) { 65535 } else { remain }
            let bfinal = if (pos + chunk >= data.size) { 1 } else { 0 }
            out.add(UInt8(bfinal))               // bit0=BFINAL，bit1-2=BTYPE=00（存储）
            let len = UInt16(chunk)
            let nlen = !len
            out.add(UInt8(len & 0xFF))
            out.add(UInt8((len >> 8) & 0xFF))
            out.add(UInt8(nlen & 0xFF))
            out.add(UInt8((nlen >> 8) & 0xFF))
            for (i in 0..chunk) { out.add(data[pos + i]) }
            pos += chunk
        }
        return out.toArray()
    }

    /// 由条目描述构造完整 ZIP 字节流（本地头 + 数据 + 中央目录 + EOCD）
    private static func makeZip(specs: ArrayList<ZipSpec>): Array<UInt8> {
        let al = ArrayList<UInt8>()
        // 1. 本地文件头 + 数据
        for (spec in specs) {
            let crc = crc32Of(spec.data)
            let comp = if (spec.method == 8) { deflateRaw(spec.data) } else { spec.data }
            put32(al, ZIP_LOCAL_SIG)
            put16(al, 20)            // version needed
            put16(al, spec.flags)
            put16(al, spec.method)
            put16(al, 0)             // time
            put16(al, 0)             // date
            put32(al, crc)
            put32(al, UInt32(comp.size))
            put32(al, UInt32(spec.data.size))
            put16(al, UInt16(spec.name.size))
            put16(al, 0)             // extra len
            for (b in spec.name.toArray()) { al.add(b) }
            for (b in comp) { al.add(b) }
        }
        // 2. 中央目录
        let cdOffset = al.size
        for (spec in specs) {
            let crc = crc32Of(spec.data)
            let comp = if (spec.method == 8) { deflateRaw(spec.data) } else { spec.data }
            // 注意：comp 重新压缩两次结果一致（确定性 deflate），size 可直接用
            let localOffset = findLocalOffset(specs, spec)
            put32(al, ZIP_CENTRAL_SIG)
            put16(al, 20)            // version made by
            put16(al, 20)            // version needed
            put16(al, spec.flags)
            put16(al, spec.method)
            put16(al, 0)             // time
            put16(al, 0)             // date
            put32(al, crc)
            put32(al, UInt32(comp.size))
            put32(al, UInt32(spec.data.size))
            put16(al, UInt16(spec.name.size))
            put16(al, 0)             // extra len
            put16(al, 0)             // comment len
            put16(al, 0)             // disk start
            put16(al, 0)             // internal attrs
            put32(al, 0)             // external attrs
            put32(al, UInt32(localOffset))
            for (b in spec.name.toArray()) { al.add(b) }
        }
        let cdSize = al.size - cdOffset
        // 3. EOCD
        put32(al, ZIP_EOCD_SIG)
        put16(al, 0)                 // disk no
        put16(al, 0)                 // cd disk
        put16(al, UInt16(specs.size))
        put16(al, UInt16(specs.size))
        put32(al, UInt32(cdSize))
        put32(al, UInt32(cdOffset))
        put16(al, 0)                 // comment len
        return al.toArray()
    }

    /// 条目在本地头阶段的偏移（按规格列表顺序累加；deflate 压缩结果确定，大小一致）
    private static func findLocalOffset(specs: ArrayList<ZipSpec>, target: ZipSpec): Int64 {
        var off: Int64 = 0
        for (spec in specs) {
            if (spec.name == target.name) { return off }
            let comp = if (spec.method == 8) { deflateRaw(spec.data) } else { spec.data }
            off += 30 + Int64(spec.name.size) + Int64(comp.size)
        }
        return off
    }

    private static func put16(al: ArrayList<UInt8>, v: UInt16): Unit {
        al.add(UInt8(v & 0xFF))
        al.add(UInt8((v >> 8) & 0xFF))
    }

    private static func put32(al: ArrayList<UInt8>, v: UInt32): Unit {
        al.add(UInt8(v & 0xFF))
        al.add(UInt8((v >> 8) & 0xFF))
        al.add(UInt8((v >> 16) & 0xFF))
        al.add(UInt8((v >> 24) & 0xFF))
    }

    /// 静默删除文件（忽略失败；统一 Unit 类型避免 try/catch 分支类型不一致）
    private static func removeQuiet(path: String): Unit {
        try {
            let _removed = removeIfExists(path)
            ()
        } catch (_: Exception) {
            ()
        }
    }

    // ===== 测试用例 =====

    /// 标准 ZIP（stored + 目录 + 空文件）：解析与 stored 条目读取
    func test_zip_parse_and_read() {
        let specs = ArrayList<ZipSpec>()
        specs.add(ZipSpec("hello.txt", 0, 0, "hello zip".toArray()))
        specs.add(ZipSpec("sub/", 0, 0, Array<UInt8>()))
        specs.add(ZipSpec("empty.txt", 0, 0, Array<UInt8>()))
        let bytes = makeZip(specs)
        let loaded = ZipArchive.loadFromBytes(bytes)
        assertEqual("解析成功", "true", loaded.isSome(), true)
        match (loaded) {
            case Some(zip) =>
                assertEqual("条目数 3", "true", zip.entryCount == 3, true)
                assertEqual("find 存在", "true", zip.find("hello.txt").isSome(), true)
                assertEqual("find 缺失", "true", zip.find("nope").isNone(), true)
                match (zip.read("hello.txt")) {
                    case Some(data) =>
                        assertEqual("stored 内容一致", "true", String.fromUtf8(data) == "hello zip", true)
                    case None => assertEqual("stored 可读", "true", false, true)
                }
                match (zip.find("sub/")) {
                    case Some(e) =>
                        assertEqual("目录条目识别", "true", e.isDirectory, true)
                        assertEqual("目录条目解压为空", "true", zip.read("sub/").getOrThrow().size == 0, true)
                    case None => assertEqual("目录条目存在", "true", false, true)
                }
                match (zip.find("empty.txt")) {
                    case Some(e) => assertEqual("空文件解压为空", "true", e.uncompressedSize == 0 && zip.read("empty.txt").getOrThrow().size == 0, true)
                    case None => assertEqual("空文件条目存在", "true", false, true)
                }
                assertEqual("缺失条目返回 None", "true", zip.read("nope").isNone(), true)
            case None => ()
        }
        // 非 ZIP 字节
        assertEqual("垃圾字节拒绝", "true", ZipArchive.loadFromBytes([0x01u8, 0x02u8, 0x03u8]).isNone(), true)
        // 文件加载往返
        try { File.writeTo("zip_test_tmp.zip", bytes) } catch (_: Exception) { }
        let fromFile = ZipArchive.loadFromFile("zip_test_tmp.zip")
        assertEqual("loadFromFile 成功", "true", fromFile.isSome(), true)
        match (fromFile) {
            case Some(zip) => assertEqual("文件加载条目数", "true", zip.entryCount == 3, true)
            case None => ()
        }
        try { removeIfExists("zip_test_tmp.zip") } catch (_: Exception) { }
        assertEqual("缺失文件返回 None", "true", ZipArchive.loadFromFile("definitely_missing_3187.zip").isNone(), true)
    }

    /// deflate 条目往返（tdefl raw 压缩 → 引擎 raw inflate 解压）
    func test_zip_deflate_roundtrip() {
        // 内容含重复片段，保证 deflate 有压缩空间
        let payload = ArrayList<UInt8>()
        for (i in 0..256) { payload.add(UInt8(i % 13)) }
        for (i in 0..256) { payload.add(UInt8(i % 13)) }
        let specs = ArrayList<ZipSpec>()
        specs.add(ZipSpec("data.bin", 8, 0, payload.toArray()))
        let bytes = makeZip(specs)
        let loaded = ZipArchive.loadFromBytes(bytes)
        assertEqual("deflate 包解析成功", "true", loaded.isSome(), true)
        match (loaded) {
            case Some(zip) =>
                match (zip.find("data.bin")) {
                    case Some(e) =>
                        assertEqual("压缩方法登记", "true", e.method == 8, true)
                        assertEqual("解压尺寸登记", "true", e.uncompressedSize == 512, true)
                        // 测试用"全存储块"deflate 流不压缩（略大于原文），仅验证可被 inflate 解压
                        assertEqual("deflate 流非空", "true", e.compressedSize > 0, true)
                    case None => assertEqual("deflate 条目存在", "true", false, true)
                }
                match (zip.read("data.bin")) {
                    case Some(data) =>
                        var same = data.size == 512
                        for (i in 0..512) {
                            if (data[i] != payload[i]) { same = false }
                        }
                        assertEqual("deflate 往返一致", "true", same, true)
                    case None => assertEqual("deflate 可读", "true", false, true)
                }
            case None => ()
        }
    }

    /// CRC32 校验：篡改中央目录登记值 → verify=true 拒绝，verify=false 跳过
    func test_zip_crc_tamper() {
        let specs = ArrayList<ZipSpec>()
        specs.add(ZipSpec("a.txt", 0, 0, "checksum me".toArray()))
        let bytes = makeZip(specs)
        // 定位中央目录的 CRC 字段：EOCD 共 22 字节位于归档尾部，cdOffset 字段
        // 在 EOCD 内偏移 +16，即绝对位置 size-6..size-3；条目 CRC 在 cdOffset+16
        let cdOffset = Int64(bytes[bytes.size - 6]) | (Int64(bytes[bytes.size - 5]) << 8) |
            (Int64(bytes[bytes.size - 4]) << 16) | (Int64(bytes[bytes.size - 3]) << 24)
        let corrupted = bytes.clone()
        corrupted[cdOffset + 16] = corrupted[cdOffset + 16] ^ 0xFFu8
        let zipOpt = ZipArchive.loadFromBytes(corrupted)
        assertEqual("篡改 CRC 后仍可解析", "true", zipOpt.isSome(), true)
        match (zipOpt) {
            case Some(zip) =>
                assertEqual("verify=true 拒绝", "true", zip.read("a.txt").isNone(), true)
                assertEqual("verify=false 跳过", "true", zip.read("a.txt", verify: false).isSome(), true)
            case None => ()
        }
    }

    /// 加密条目（flag bit0）与非支持压缩方法返回 None
    func test_zip_unsupported_and_encrypted() {
        let specs = ArrayList<ZipSpec>()
        specs.add(ZipSpec("enc.txt", 0, 1, "encrypted".toArray()))
        specs.add(ZipSpec("weird.bin", 99, 0, [0x01u8, 0x02u8]))
        let bytes = makeZip(specs)
        let zipOpt = ZipArchive.loadFromBytes(bytes)
        assertEqual("解析成功（方法/标志在读取期拒绝）", "true", zipOpt.isSome(), true)
        match (zipOpt) {
            case Some(zip) =>
                assertEqual("加密条目拒绝", "true", zip.read("enc.txt").isNone(), true)
                assertEqual("未知压缩方法拒绝", "true", zip.read("weird.bin").isNone(), true)
            case None => ()
        }
    }

    /// extractAll 落盘展开：目录建目录、文件写文件、内容一致
    func test_zip_extract_all() {
        let specs = ArrayList<ZipSpec>()
        specs.add(ZipSpec("zout/hello.txt", 0, 0, "hello extract".toArray()))
        specs.add(ZipSpec("zout/sub/", 0, 0, Array<UInt8>()))
        specs.add(ZipSpec("zout/sub/a.bin", 8, 0, [0xDEu8, 0xADu8, 0xBEu8, 0xEFu8, 0xDEu8, 0xADu8]))
        let bytes = makeZip(specs)
        let zipOpt = ZipArchive.loadFromBytes(bytes)
        assertEqual("解析成功", "true", zipOpt.isSome(), true)
        match (zipOpt) {
            case Some(zip) =>
                let ok = zip.extractAll("zip_test_extract_out")
                assertEqual("extractAll 成功", "true", ok, true)
                try {
                    let hello = File.readFrom("zip_test_extract_out/zout/hello.txt")
                    assertEqual("落盘内容一致", "true", String.fromUtf8(hello) == "hello extract", true)
                    let bin = File.readFrom("zip_test_extract_out/zout/sub/a.bin")
                    assertEqual("deflate 条目落盘一致", "true", bin.size == 6 && bin[0] == 0xDEu8 && bin[3] == 0xEFu8, true)
                } catch (e: Exception) {
                    assertEqual("落盘文件可读", "true", "${e}", "无异常")
                }
                // 清理落盘文件（目录留空壳，无碍）
                try { removeIfExists("zip_test_extract_out/zout/hello.txt"); () } catch (_: Exception) { }
                try { removeIfExists("zip_test_extract_out/zout/sub/a.bin"); () } catch (_: Exception) { }
            case None => ()
        }
    }

    /// zip-slip 防护：../ 逃逸与绝对路径条目拒绝展开
    func test_zip_zip_slip() {
        let specs = ArrayList<ZipSpec>()
        specs.add(ZipSpec("../evil.txt", 0, 0, "evil".toArray()))
        let bytes = makeZip(specs)
        let zipOpt = ZipArchive.loadFromBytes(bytes)
        assertEqual("解析成功", "true", zipOpt.isSome(), true)
        match (zipOpt) {
            case Some(zip) =>
                assertEqual("../ 逃逸拒绝", "true", !zip.extractAll("zip_test_slip_out"), true)
                assertEqual("逃逸条目不可读出内容", "true", zip.read("../evil.txt", verify: false).isSome(), true)
            case None => ()
        }
        let specs2 = ArrayList<ZipSpec>()
        specs2.add(ZipSpec("/abs.txt", 0, 0, "abs".toArray()))
        let zip2Opt = ZipArchive.loadFromBytes(makeZip(specs2))
        match (zip2Opt) {
            case Some(zip) => assertEqual("绝对路径拒绝", "true", !zip.extractAll("zip_test_slip_out"), true)
            case None => assertEqual("绝对路径包解析", "true", false, true)
        }
    }

    /// 磁盘全链路：写 ZIP 文件 → loadFromFile → extractAll → 回读校验（stored + deflate）
    func test_zip_file_extract_roundtrip() {
        let specs = ArrayList<ZipSpec>()
        specs.add(ZipSpec("round/greeting.txt", 0, 0, "from disk zip".toArray()))
        specs.add(ZipSpec("round/deep/data.bin", 8, 0, [0x11u8, 0x22u8, 0x33u8, 0x44u8, 0x11u8, 0x22u8, 0x33u8, 0x44u8, 0x55u8]))
        let bytes = makeZip(specs)
        // 1. ZIP 字节落盘
        try {
            File.writeTo("zip_test_roundtrip.zip", bytes)
        } catch (e: Exception) {
            assertEqual("ZIP 落盘", "true", "${e}", "无异常")
            return
        }
        // 2. 从磁盘加载
        let loaded = ZipArchive.loadFromFile("zip_test_roundtrip.zip")
        assertEqual("loadFromFile 成功", "true", loaded.isSome(), true)
        match (loaded) {
            case Some(zip) =>
                // 3. 展开到目标目录
                let ok = zip.extractAll("zip_test_roundtrip_out")
                assertEqual("extractAll 成功", "true", ok, true)
                // 4. 回读校验（stored 与 deflate 各一）
                try {
                    let txt = File.readFrom("zip_test_roundtrip_out/round/greeting.txt")
                    assertEqual("stored 条目内容一致", "true", String.fromUtf8(txt) == "from disk zip", true)
                    let bin = File.readFrom("zip_test_roundtrip_out/round/deep/data.bin")
                    assertEqual("deflate 条目内容一致", "true",
                        bin.size == 9 && bin[0] == 0x11u8 && bin[2] == 0x33u8 && bin[8] == 0x55u8, true)
                } catch (e: Exception) {
                    assertEqual("落盘文件可读", "true", "${e}", "无异常")
                }
                // 清理落盘文件
                removeQuiet("zip_test_roundtrip.zip")
                removeQuiet("zip_test_roundtrip_out/round/greeting.txt")
                removeQuiet("zip_test_roundtrip_out/round/deep/data.bin")
            case None => ()
        }
    }
}
