/**
 * @file main
 * @brief test_objects 独立测试项目入口
 *
 * 迁移自 three.js test/unit/src/objects 目录的 tests.js 测试：
 * Mesh/Points/Line/LineLoop/LineSegments/Group/Bone/Sprite/InstancedMesh/
 * SkinnedMesh/Skeleton/LOD/BatchedMesh
 * 核心断言：继承关系（Extending）、可实例化（Instancing）、isXxx 类型标志、type/kind。
 */
package test_j_objects

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_j_objects")
    testPackage.registerSuite({ => ObjectsInheritanceTest().asTestSuite() })
    testPackage.registerSuite({ => ObjectsInstancingTest().asTestSuite() })
    testPackage.registerSuite({ => MeshBehaviorTest().asTestSuite() })
    testPackage.registerSuite({ => ParticleBehaviorTest().asTestSuite() })
    return entryMain(testPackage)
}
