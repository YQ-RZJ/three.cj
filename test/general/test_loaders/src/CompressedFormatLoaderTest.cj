/**
 * @file CompressedFormatLoaderTest
 * @brief test_loaders: EXRLoader/KTXLoader/PVRLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测三个 Loader 的非法魔数拒绝路径（对照 JS parse 的头部校验）：
 * - EXRLoader: 魔数非 0x013f2a76 → 空 texData
 * - KTXLoader: 魔数非 0xAB4B5458 → 空 texData
 * - PVRLoader: 版本非 0x03525650 → 空 texData
 */
package test_loaders

import std.unittest.*
import std.collection.*
import three.resource.loader.EXRLoader
import three.resource.loader.KTXLoader
import three.resource.loader.PVRLoader

public class CompressedFormatLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("CompressedFormatLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_exr_invalid_magic(); () }
            suiteBuilder.add(UnitTestCase.create("test_exr_invalid_magic", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_ktx_invalid_magic(); () }
            suiteBuilder.add(UnitTestCase.create("test_ktx_invalid_magic", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_pvr_invalid_magic(); () }
            suiteBuilder.add(UnitTestCase.create("test_pvr_invalid_magic", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_exr_invalid_magic() {
        // 对照 JS: EXRLoader.parse — 非法魔数拒绝
        let loader = EXRLoader()
        let bad = [0x00u8, 0x01u8, 0x02u8, 0x03u8, 0x04u8, 0x05u8, 0x06u8, 0x07u8]
        let texData = loader.parse(bad)
        assertEqual("EXR 非法魔数返回空 texData", "true", texData.size == 0, true)
    }

    func test_ktx_invalid_magic() {
        // 对照 JS: KTXLoader.parse — 非法魔数拒绝
        let loader = KTXLoader()
        let bad = [0x00u8, 0x01u8, 0x02u8, 0x03u8]
        let texData = loader.parse(bad, false)
        assertEqual("KTX 非法魔数返回空 texData", "true", texData.size == 0, true)
    }

    func test_pvr_invalid_magic() {
        // 对照 JS: PVRLoader.parse — 非法版本拒绝
        let loader = PVRLoader()
        let bad = [0x00u8, 0x01u8, 0x02u8, 0x03u8]
        let texData = loader.parse(bad, false)
        assertEqual("PVR 非法版本返回空 texData", "true", texData.size == 0, true)
    }
}
