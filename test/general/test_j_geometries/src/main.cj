/**
 * @file main
 * @brief test_j_geometries 独立测试项目入口（迁移自上游 JS 库 test/unit/src/geometries）
 */
package test_j_geometries

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_j_geometries")
    testPackage.registerSuite({ => GeometriesInheritanceTest().asTestSuite() })
    testPackage.registerSuite({ => GeometriesInstancingTest().asTestSuite() })
    return entryMain(testPackage)
}
