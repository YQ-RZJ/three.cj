/**
 * @file main
 * @brief test_j_audio 独立测试项目入口（迁移自 three.js test/unit/src/audio）
 */
package test_j_audio

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_j_audio")
    testPackage.registerSuite({ => AudioInstancingTest().asTestSuite() })
    return entryMain(testPackage)
}
