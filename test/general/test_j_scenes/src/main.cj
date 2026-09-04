/**
 * @file main
 * @brief test_scenes 独立测试项目入口
 *
 * 迁移自 three.js test/unit/src/scenes 目录的 tests.js 测试：
 * Scene / Fog / FogExp2
 * 核心断言：继承关系（Extending）、可实例化（Instancing）、isXxx 类型标志。
 */
package test_j_scenes

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_j_scenes")
    testPackage.registerSuite({ => ScenesInheritanceTest().asTestSuite() })
    testPackage.registerSuite({ => ScenesInstancingTest().asTestSuite() })
    testPackage.registerSuite({ => SceneBehaviorTest().asTestSuite() })
    return entryMain(testPackage)
}
