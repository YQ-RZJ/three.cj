/**
 * @file TGALoaderTest
 * @brief test_loaders: TGALoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.TGALoader 能力（对照 JS TGALoader.parse）：
 * - 24 位 RGB 非 RLE 解析 → RGBA8
 * - 非法头（无数据）返回空 texData
 */
package test_loaders

import std.unittest.*
import std.collection.*
import three.resource.loader.TGALoader
import three.utils.constants.*

public class TGALoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("TGALoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_rgb24(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_rgb24", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_invalid_header(); () }
            suiteBuilder.add(UnitTestCase.create("test_invalid_header", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // 构造 2x1 的 24 位 RGB TGA（左上原点，像素顺序 BGR）
    // 像素0 = 红色（BGR: 00 00 FF），像素1 = 绿色（BGR: 00 FF 00）
    func buildRGB24TGA(): Array<UInt8> {
        let bytes = ArrayList<UInt8>()
        // id_length, colormap_type, image_type=2(RGB)
        bytes.add(0u8); bytes.add(0u8); bytes.add(2u8)
        // colormap_index(2), colormap_length(2), colormap_size
        bytes.add(0u8); bytes.add(0u8); bytes.add(0u8); bytes.add(0u8); bytes.add(0u8)
        // origin_x(2), origin_y(2)
        bytes.add(0u8); bytes.add(0u8); bytes.add(0u8); bytes.add(0u8)
        // width=2, height=1
        bytes.add(2u8); bytes.add(0u8); bytes.add(1u8); bytes.add(0u8)
        // pixel_size=24, flags=0（左上原点）
        bytes.add(24u8); bytes.add(0u8)
        // 像素0 红（BGR）
        bytes.add(0u8); bytes.add(0u8); bytes.add(255u8)
        // 像素1 绿（BGR）
        bytes.add(0u8); bytes.add(255u8); bytes.add(0u8)
        return bytes.toArray()
    }

    func test_parse_rgb24() {
        let loader = TGALoader()
        let texData = loader.parse(buildRGB24TGA())
        assertEqual("解析成功", "true", texData.size > 0, true)
        // width/height
        match (texData.get("width")) {
            case Some(v) => match (v) { case i: Int64 => assertEqual("width == 2", "true", i == 2, true); case _ => () }
            case None => ()
        }
        match (texData.get("height")) {
            case Some(v) => match (v) { case i: Int64 => assertEqual("height == 1", "true", i == 1, true); case _ => () }
            case None => ()
        }
        // data：2*1*4 = 8 字节 RGBA
        match (texData.get("data")) {
            case Some(v) =>
                match (v) {
                    case d: Array<UInt8> =>
                        assertEqual("data size == 8", "true", d.size == 8, true)
                        if (d.size == 8) {
                            // 像素0 红：R=255 G=0 B=0 A=255
                            assertEqual("像素0 R", "true", d[0] == 255u8, true)
                            assertEqual("像素0 G", "true", d[1] == 0u8, true)
                            assertEqual("像素0 B", "true", d[2] == 0u8, true)
                            assertEqual("像素0 A", "true", d[3] == 255u8, true)
                            // 像素1 绿：R=0 G=255 B=0 A=255
                            assertEqual("像素1 G", "true", d[5] == 255u8, true)
                        }
                    case _ => ()
                }
            case None => ()
        }
        // flipY / generateMipmaps（对照 JS 返回结构）
        match (texData.get("flipY")) {
            case Some(v) => match (v) { case b: Bool => assertEqual("flipY == true", "true", b, true); case _ => () }
            case None => ()
        }
    }

    func test_invalid_header() {
        // 对照 JS: 头不足 19 字节 → 空 texData
        let loader = TGALoader()
        let bad = [0x00u8, 0x01u8, 0x02u8]
        let texData = loader.parse(bad)
        assertEqual("头不足返回空 texData", "true", texData.size == 0, true)
    }
}
