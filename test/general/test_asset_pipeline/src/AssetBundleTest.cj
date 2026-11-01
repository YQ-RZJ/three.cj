/**
 * @file AssetBundleTest
 * @brief test_asset_pipeline: AssetBundle 打包/读取单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.resource.pipeline.AssetBundle 能力：
 * - Builder.add/build 产出档案字节
 * - loadFromBytes 解析：contains/get/read/getNames
 * - 往返一致（打包→读取→字节一致）
 * - CRC 校验：verify=true 损坏数据返回 None，verify=false 跳过校验
 * - 魔数/版本不合法返回 None
 * - writeTo/loadFromFile 落盘往返
 */
package test_asset_pipeline

import std.unittest.*
import std.fs.*
import three.resource.pipeline.*

public class AssetBundleTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("AssetBundleTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_bundle_build_load(); () }
            suiteBuilder.add(UnitTestCase.create("test_bundle_build_load", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_bundle_crc_verify(); () }
            suiteBuilder.add(UnitTestCase.create("test_bundle_crc_verify", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_bundle_file_roundtrip(); () }
            suiteBuilder.add(UnitTestCase.create("test_bundle_file_roundtrip", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// 构建一个两资源测试包
    private static func makeBundle(): Array<UInt8> {
        let builder = AssetBundleBuilder()
        builder.add("a.bin", [0x01u8, 0x02u8, 0x03u8])
        builder.add("b.txt", "hello".toArray())
        return builder.build()
    }

    func test_bundle_build_load() {
        let bytes = makeBundle()
        // 魔数 "CJAB"
        assertEqual("魔数 CJAB", "true", bytes[0] == 0x43u8 && bytes[1] == 0x4Au8 && bytes[2] == 0x41u8 && bytes[3] == 0x42u8, true)
        let bundle = AssetBundle.loadFromBytes(bytes)
        assertEqual("解析成功", "true", bundle.isSome(), true)
        match (bundle) {
            case Some(b) =>
                assertEqual("条目数 2", "true", b.entryCount == 2, true)
                assertEqual("contains a.bin", "true", b.contains("a.bin"), true)
                assertEqual("contains 缺失名", "true", !b.contains("nope"), true)
                match (b.read("a.bin")) {
                    case Some(data) => assertEqual("a.bin 字节一致", "true", data.size == 3 && data[0] == 0x01u8 && data[2] == 0x03u8, true)
                    case None => assertEqual("a.bin 可读", "true", false, true)
                }
                match (b.read("b.txt")) {
                    case Some(data) => assertEqual("b.txt 内容一致", "true", String.fromUtf8(data) == "hello", true)
                    case None => assertEqual("b.txt 可读", "true", false, true)
                }
                assertEqual("缺失资源返回 None", "true", b.read("nope").isNone(), true)
                let names = b.getNames()
                assertEqual("getNames 数量", "true", names.size == 2, true)
            case None => ()
        }
    }

    func test_bundle_crc_verify() {
        let bytes = makeBundle()
        // 损坏数据区末字节
        let corrupted = bytes.clone()
        corrupted[corrupted.size - 1] = corrupted[corrupted.size - 1] ^ 0xFFu8
        assertEqual("verify=true 拒绝损坏包", "true", AssetBundle.loadFromBytes(corrupted).isNone(), true)
        assertEqual("verify=false 跳过校验", "true", AssetBundle.loadFromBytes(corrupted, verify: false).isSome(), true)
        // 非法魔数
        let bad = bytes.clone()
        bad[0] = 0x00u8
        assertEqual("非法魔数拒绝", "true", AssetBundle.loadFromBytes(bad).isNone(), true)
        // 空数组
        assertEqual("空字节拒绝", "true", AssetBundle.loadFromBytes([]).isNone(), true)
    }

    func test_bundle_file_roundtrip() {
        let builder = AssetBundleBuilder()
        builder.add("x", [0xAAu8, 0xBBu8])
        let path = "test_asset_pipeline_tmp.cjab"
        let wrote = builder.writeTo(path)
        assertEqual("writeTo 成功", "true", wrote, true)
        let loaded = AssetBundle.loadFromFile(path)
        assertEqual("loadFromFile 成功", "true", loaded.isSome(), true)
        match (loaded) {
            case Some(b) =>
                match (b.read("x")) {
                    case Some(data) => assertEqual("落盘往返字节一致", "true", data.size == 2 && data[0] == 0xAAu8, true)
                    case None => assertEqual("落盘往返可读", "true", false, true)
                }
            case None => ()
        }
        // 清理临时文件（忽略失败）
        try { removeIfExists(path) } catch (_: Exception) { }
        // 不存在的文件
        assertEqual("缺失文件返回 None", "true", AssetBundle.loadFromFile("definitely_missing_8742.cjab").isNone(), true)
    }
}
