/**
 * @file main
 * @brief test_j_lights 独立测试项目入口（迁移自 three.js test/unit/src/lights）
 */
package test_j_lights

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_j_lights")
    testPackage.registerSuite({ => LightsInheritanceTest().asTestSuite() })
    testPackage.registerSuite({ => LightsInstancingTest().asTestSuite() })
    return entryMain(testPackage)
}
