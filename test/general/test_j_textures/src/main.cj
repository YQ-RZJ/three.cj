/**
 * @file main
 * @brief test_textures 独立测试项目入口
 *
 * 迁移自 three.js test/unit/src/textures 目录的 tests.js 测试：
 * - Texture / Source / CanvasTexture / CompressedTexture / CompressedArrayTexture /
 *   CubeTexture / CubeDepthTexture / DataTexture / Data3DTexture / DataArrayTexture /
 *   DepthTexture / FramebufferTexture / VideoTexture
 * 核心断言：继承关系（Extending）、可实例化（Instancing）、isXxx 类型标志。
 */
package test_j_textures

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_j_textures")
    testPackage.registerSuite({ => TextureInheritanceTest().asTestSuite() })
    testPackage.registerSuite({ => TextureInstancingTest().asTestSuite() })
    testPackage.registerSuite({ => TextureBehaviorTest().asTestSuite() })
    return entryMain(testPackage)
}
