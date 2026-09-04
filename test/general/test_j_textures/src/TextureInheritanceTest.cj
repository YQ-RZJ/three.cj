/**
 * @file TextureInheritanceTest
 * @brief 迁移 three.js test/unit/src/textures 目录 tests.js 的 Extending 断言
 *
 * 对照 JS:
 *   new DataTexture() instanceof Texture → true
 *   new CompressedTexture() instanceof Texture → true
 *   等（各纹理类均 extends Texture）
 */
package test_j_textures

import std.unittest.*
import three.rendering.textures.*

public class TextureInheritanceTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("TextureInheritanceTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_all_extend_texture(); () }
            suiteBuilder.add(UnitTestCase.create("test_all_extend_texture", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_all_extend_texture() {
        // 对照 JS QUnit: object instanceof Texture 断言
        let canvas = CanvasTexture(Array<UInt8>(16 * 16 * 4, { _ => 0u8 }), 16, 16)
        assertEqual("CanvasTexture is Texture", "true", (canvas is Texture).toString(), "true")

        let compressed = CompressedTexture(Array<UInt8>(16 * 16 * 4, { _ => 0u8 }), 16, 16)
        assertEqual("CompressedTexture is Texture", "true", (compressed is Texture).toString(), "true")

        let cube = CubeTexture(images: Array<Array<UInt8>>(6, { _ => Array<UInt8>(4, { _ => 0u8 }) }))
        assertEqual("CubeTexture is Texture", "true", (cube is Texture).toString(), "true")

        let cubeDepth = CubeDepthTexture(64, 64)
        assertEqual("CubeDepthTexture is Texture", "true", (cubeDepth is Texture).toString(), "true")

        let data = DataTexture(Array<UInt8>(16 * 16 * 4, { _ => 0u8 }), 16, 16)
        assertEqual("DataTexture is Texture", "true", (data is Texture).toString(), "true")

        let data3d = Data3DTexture(Array<UInt8>(16 * 16 * 4 * 2, { _ => 0u8 }), 16, 16, 2)
        assertEqual("Data3DTexture is Texture", "true", (data3d is Texture).toString(), "true")

        let dataArr = DataArrayTexture(Array<UInt8>(16 * 16 * 4 * 2, { _ => 0u8 }), 16, 16, 2)
        assertEqual("DataArrayTexture is Texture", "true", (dataArr is Texture).toString(), "true")

        let depth = DepthTexture(64, 64)
        assertEqual("DepthTexture is Texture", "true", (depth is Texture).toString(), "true")

        let fb = FramebufferTexture(64, 64)
        assertEqual("FramebufferTexture is Texture", "true", (fb is Texture).toString(), "true")

        let video = VideoTexture(Array<UInt8>(16 * 16 * 4, { _ => 0u8 }))
        assertEqual("VideoTexture is Texture", "true", (video is Texture).toString(), "true")

        let compArr = CompressedArrayTexture(Array<UInt8>(16 * 16 * 4 * 2, { _ => 0u8 }), 16, 16, 2)
        assertEqual("CompressedArrayTexture is Texture", "true", (compArr is Texture).toString(), "true")
    }
}
