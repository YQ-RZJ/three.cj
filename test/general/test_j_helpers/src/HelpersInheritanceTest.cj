/**
 * @file HelpersInheritanceTest
 * @brief 迁移 three.js test/unit/src/helpers 目录 tests.js 的 Extending 断言
 *
 * 对照 JS:
 *   new ArrowHelper() instanceof Object3D → true
 *   new AxesHelper() instanceof Object3D → true 等（helper 均继承 Object3D）
 */
package test_j_helpers

import std.unittest.*
import three.rendering.helpers.*
import three.scene.objects.Object3D
import three.core.math.Vector3
import three.core.math.Plane

public class HelpersInheritanceTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("HelpersInheritanceTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_all_extend_object3d(); () }
            suiteBuilder.add(UnitTestCase.create("test_all_extend_object3d", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_all_extend_object3d() {
        // 对照 JS QUnit: obj instanceof Object3D 断言（仓颉用 isObject3D）
        let helpers = [
            ArrowHelper(dir: Vector3(1.0, 0.0, 0.0)),
            AxesHelper(size: 1.0),
            GridHelper(size: 10.0, divisions: 10),
            PlaneHelper(Plane(), size: 1.0)
        ]
        for (h in helpers) {
            assertEqual("${h.name} isObject3D", "true", (h is Object3D).toString(), "true")
        }
    }
}
