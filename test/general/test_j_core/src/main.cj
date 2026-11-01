/**
 * @file main
 * @brief test_j_core 独立测试项目入口（迁移自上游 JS 库 test/unit/src/constants.tests.js / utils.tests.js）
 */
package test_j_core

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_j_core")
    testPackage.registerSuite({ => ConstantsTest().asTestSuite() })
    return entryMain(testPackage)
}
