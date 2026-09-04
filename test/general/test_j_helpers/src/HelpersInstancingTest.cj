/**
 * @file HelpersInstancingTest
 * @brief 迁移 three.js test/unit/src/helpers 目录 tests.js 的 Instancing 断言
 *
 * 对照 JS:
 *   new ArrowHelper() → object.isArrowHelper === true
 *   new AxesHelper() → object.isAxesHelper === true 等
 */
package test_j_helpers

import std.unittest.*
import three.rendering.helpers.*
import three.core.math.Vector3
import three.core.math.Plane
import three.rendering.cameras.PerspectiveCamera

public class HelpersInstancingTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("HelpersInstancingTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_is_flags(); () }
            suiteBuilder.add(UnitTestCase.create("test_is_flags", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_is_flags() {
        // 对照 JS QUnit: object.isXxx 断言（仓颉部分 helper 无 is 标志，用 kind 兜底）
        let arrow = ArrowHelper(dir: Vector3(1.0, 0.0, 0.0))
        assertEqual("ArrowHelper kind", "ArrowHelper", arrow.kind, "ArrowHelper")

        let axes = AxesHelper(size: 1.0)
        assertEqual("AxesHelper kind", "AxesHelper", axes.kind, "AxesHelper")

        let grid = GridHelper(size: 10.0, divisions: 10)
        assertEqual("GridHelper kind", "GridHelper", grid.kind, "GridHelper")

        let plane = PlaneHelper(Plane(), size: 1.0)
        assertEqual("PlaneHelper kind", "PlaneHelper", plane.kind, "PlaneHelper")

        let cameraHelper = CameraHelper(PerspectiveCamera())
        assertEqual("CameraHelper kind", "CameraHelper", cameraHelper.kind, "CameraHelper")
    }
}
