/**
 * @file DataTextureLoaderTest
 * @brief test_loaders: DataTextureLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.DataTextureLoader 能力（对照 JS _applyTexData/createDataTexture）：
 * - parse 结果应用到 DataTexture（width/height/data/format/type）
 * - mipmapCount === 1 时 minFilter 设为 LinearFilter
 */
package test_loaders

import std.unittest.*
import std.collection.*
import three.resource.loader.DataTextureLoader
import three.utils.constants.*

// 测试用 DataTextureLoader 子类：parse 返回固定 texData
public class TestDataTextureLoader <: DataTextureLoader {
    public override func parse(buffer: Array<UInt8>): HashMap<String, Any> {
        let td = HashMap<String, Any>()
        td.add("width", Int64(2))
        td.add("height", Int64(2))
        td.add("data", Array<UInt8>(16, { _ => 0u8 }))
        td.add("format", RGBAFormat)
        td.add("type", UnsignedByteType)
        td.add("mipmapCount", Int64(1))
        return td
    }
}

public class DataTextureLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("DataTextureLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_create_data_texture(); () }
            suiteBuilder.add(UnitTestCase.create("test_create_data_texture", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_create_data_texture() {
        // 对照 JS: createDataTexture(buffer) — `_applyTexData(texture, parse(buffer))`
        let loader = TestDataTextureLoader()
        let texture = loader.createDataTexture(Array<UInt8>())
        // width/height 应用
        assertEqual("width 应用", "true", texture.width == 2, true)
        assertEqual("height 应用", "true", texture.height == 2, true)
        // data 应用为 image
        assertEqual("data 应用", "true", texture.image.size == 16, true)
        // format/type 应用
        assertEqual("format 应用", "true", texture.format == RGBAFormat, true)
        assertEqual("type 应用", "true", texture.`type` == UnsignedByteType, true)
        // 对照 JS: mipmapCount === 1 → minFilter = LinearFilter
        assertEqual("mipmapCount==1 minFilter LinearFilter", "true", texture.minFilter == LinearFilter, true)
        // needsUpdate 置位
        assertEqual("needsUpdate 置位", "true", texture.needsUpdate, true)
    }
}
