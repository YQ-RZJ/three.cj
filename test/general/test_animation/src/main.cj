/**
 * @file main
 * @brief animation_test 独立测试项目入口
 *
 * 直接使用 std.unittest 框架手动注册测试套件并运行：
 * - 在测试子项目内 cjpm run（触发编译 + 运行）
 * - 测试文件命名为普通 .cj（避免 _test.cj 后缀在普通构建模式下被 cjpm 排除）
 */
package animation_test

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("animation_test")
    testPackage.registerSuite({ => AnimationClipTest().asTestSuite() })
    testPackage.registerSuite({ => KeyframeTrackTest().asTestSuite() })
    testPackage.registerSuite({ => AnimationMixerTest().asTestSuite() })
    testPackage.registerSuite({ => AnimationUtilsTest().asTestSuite() })
    testPackage.registerSuite({ => SkeletalAnimationTest().asTestSuite() })
    testPackage.registerSuite({ => SkeletalBenchmarkTest().asTestSuite() })
    return entryMain(testPackage)
}
