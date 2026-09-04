/**
 * @file TextureInstancingTest
 * @brief 迁移 three.js test/unit/src/textures 目录 tests.js 的 Instancing / isXxx 断言
 *
 * 对照 JS:
 *   new DataTexture() → object 可实例化且 object.isDataTexture === true
 *   等（各纹理类 isXxx 类型标志）
 */
package test_j_textures

import std.unittest.*
import three.rendering.textures.*

public class TextureInstancingTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("TextureInstancingTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_is_flags(); () }
            suiteBuilder.add(UnitTestCase.create("test_is_flags", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_is_flags() {
        // 对照 JS QUnit: object.isXxx 断言
        let canvas = CanvasTexture(Array<UInt8>(16 * 16 * 4, { _ => 0u8 }), 16, 16)
        assertEqual("CanvasTexture isCanvasTexture", "true", (canvas is CanvasTexture).toString(), "true")

        let compressed = CompressedTexture(Array<UInt8>(16 * 16 * 4, { _ => 0u8 }), 16, 16)
        assertEqual("CompressedTexture isCompressedTexture", "true", (compressed is CompressedTexture).toString(), "true")

        let cube = CubeTexture(images: Array<Array<UInt8>>(6, { _ => Array<UInt8>(4, { _ => 0u8 }) }))
        assertEqual("CubeTexture isCubeTexture", "true", (cube is CubeTexture).toString(), "true")

        let cubeDepth = CubeDepthTexture(64, 64)
        assertEqual("CubeDepthTexture isCubeDepthTexture", "true", (cubeDepth is CubeDepthTexture).toString(), "true")

        let data = DataTexture(Array<UInt8>(16 * 16 * 4, { _ => 0u8 }), 16, 16)
        assertEqual("DataTexture isDataTexture", "true", (data is DataTexture).toString(), "true")

        let data3d = Data3DTexture(Array<UInt8>(16 * 16 * 4 * 2, { _ => 0u8 }), 16, 16, 2)
        assertEqual("Data3DTexture isData3DTexture", "true", (data3d is Data3DTexture).toString(), "true")

        let dataArr = DataArrayTexture(Array<UInt8>(16 * 16 * 4 * 2, { _ => 0u8 }), 16, 16, 2)
        assertEqual("DataArrayTexture isDataArrayTexture", "true", (dataArr is DataArrayTexture).toString(), "true")

        let depth = DepthTexture(64, 64)
        assertEqual("DepthTexture isDepthTexture", "true", (depth is DepthTexture).toString(), "true")

        let fb = FramebufferTexture(64, 64)
        assertEqual("FramebufferTexture isFramebufferTexture", "true", (fb is FramebufferTexture).toString(), "true")

        let video = VideoTexture(Array<UInt8>(16 * 16 * 4, { _ => 0u8 }))
        assertEqual("VideoTexture isVideoTexture", "true", (video is VideoTexture).toString(), "true")

        let compArr = CompressedArrayTexture(Array<UInt8>(16 * 16 * 4 * 2, { _ => 0u8 }), 16, 16, 2)
        assertEqual("CompressedArrayTexture isCompressedArrayTexture", "true", (compArr is CompressedArrayTexture).toString(), "true")
    }
}
