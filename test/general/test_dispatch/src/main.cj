/**
 * @file main
 * @brief test_dispatch 独立测试项目入口
 *
 * 直接使用 std.unittest 框架手动注册测试套件并运行：
 * - 在测试子项目内 cjpm run（触发编译 + 运行）
 * - 测试文件命名为普通 .cj（避免 _test.cj 后缀在普通构建模式下被 cjpm 排除）
 */
package test_dispatch

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_dispatch")
    testPackage.registerSuite({ => FrameTaskTest().asTestSuite() })
    testPackage.registerSuite({ => FrameDispatchTest().asTestSuite() })
    return entryMain(testPackage)
}
