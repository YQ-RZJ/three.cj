/**
 * @file main
 * @brief test_j_helpers 独立测试项目入口（迁移自 three.js test/unit/src/helpers）
 */
package test_j_helpers

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_j_helpers")
    testPackage.registerSuite({ => HelpersInheritanceTest().asTestSuite() })
    testPackage.registerSuite({ => HelpersInstancingTest().asTestSuite() })
    return entryMain(testPackage)
}
