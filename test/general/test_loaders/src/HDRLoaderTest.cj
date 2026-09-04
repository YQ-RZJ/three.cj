/**
 * @file HDRLoaderTest
 * @brief test_loaders: HDRLoader/RGBELoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.HDRLoader（对照 JS HDRLoader/RGBELoader.parse）：
 * - RGBE 头解析（#?RADIANCE / FORMAT / -Y +X）
 * - 非 RLE 平坦像素解码 → FloatType 数据
 */
package test_loaders

import std.unittest.*
import std.collection.*
import three.resource.loader.HDRLoader
import three.resource.loader.RGBELoader
import three.utils.constants.*

public class HDRLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("HDRLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_rgbe_flat(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_rgbe_flat", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_rgbe_loader_alias(); () }
            suiteBuilder.add(UnitTestCase.create("test_rgbe_loader_alias", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // 构造 2x2 的 RGBE HDR（宽 <8 → 非 RLE 平坦路径）
    // 头 + 16 字节像素（每像素 4 字节 R,G,B,E）
    func buildMinHDR(): Array<UInt8> {
        let bytes = ArrayList<UInt8>()
        // 头文本
        for (b in "#?RADIANCE\n".toArray()) { bytes.add(b) }
        for (b in "FORMAT=32-bit_rle_rgbe\n".toArray()) { bytes.add(b) }
        for (b in "\n".toArray()) { bytes.add(b) }
        for (b in "-Y 2 +X 2\n".toArray()) { bytes.add(b) }
        // 4 像素：R=200 G=100 B=50 E=128（scale = 2^0/255）
        for (_ in 0..4) {
            bytes.add(200u8); bytes.add(100u8); bytes.add(50u8); bytes.add(128u8)
        }
        return bytes.toArray()
    }

    func test_parse_rgbe_flat() {
        let loader = HDRLoader()
        let texData = loader.parse(buildMinHDR())
        assertEqual("解析成功", "true", texData.size > 0, true)
        // 对照 JS: width/height
        match (texData.get("width")) {
            case Some(v) => match (v) { case i: Int64 => assertEqual("width == 2", "true", i == 2, true); case _ => () }
            case None => ()
        }
        match (texData.get("height")) {
            case Some(v) => match (v) { case i: Int64 => assertEqual("height == 2", "true", i == 2, true); case _ => () }
            case None => ()
        }
        // 对照 JS: type = FloatType，data = 4 像素 × RGBA × Float32(4B)
        match (texData.get("type")) {
            case Some(v) => match (v) { case i: Int64 => assertEqual("type == FloatType", "true", i == FloatType, true); case _ => () }
            case None => ()
        }
        match (texData.get("data")) {
            case Some(v) =>
                match (v) {
                    case d: Array<UInt8> =>
                        assertEqual("data size == 64", "true", d.size == 64, true)
                    case _ => ()
                }
            case None => ()
        }
        // 对照 JS: 输出结构字段
        match (texData.get("flipY")) {
            case Some(v) => match (v) { case b: Bool => assertEqual("flipY == true", "true", b, true); case _ => () }
            case None => ()
        }
        match (texData.get("generateMipmaps")) {
            case Some(v) => match (v) { case b: Bool => assertEqual("generateMipmaps == false", "true", !b, true); case _ => () }
            case None => ()
        }
    }

    func test_rgbe_loader_alias() {
        // 对照 JS: RGBELoader 为 HDRLoader 的兼容子类
        let loader = RGBELoader()
        let texData = loader.parse(buildMinHDR())
        assertEqual("RGBELoader 解析成功", "true", texData.size > 0, true)
    }
}
