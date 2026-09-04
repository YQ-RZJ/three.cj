/**
 * @file ScenesInstancingTest
 * @brief 迁移 three.js test/unit/src/scenes 目录 tests.js 的 Instancing / isXxx 断言
 *
 * 对照 JS:
 *   new Scene() → object.isScene === true
 *   new Fog() → object.isFog === true
 *   new FogExp2() → object.isFogExp2 === true
 */
package test_j_scenes

import std.unittest.*
import three.scene.scenegraph.*
import three.core.math.Color

public class ScenesInstancingTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ScenesInstancingTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_is_flags(); () }
            suiteBuilder.add(UnitTestCase.create("test_is_flags", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_is_flags() {
        // 对照 JS QUnit: object.isXxx 断言
        let scene = Scene()
        assertEqual("Scene isScene", "true", (scene is Scene).toString(), "true")

        let fog = Fog(Color(0xffffff))
        assertEqual("Fog isFog", "true", (fog is Fog).toString(), "true")

        let fogExp2 = FogExp2(Color(0xffffff))
        assertEqual("FogExp2 isFogExp2", "true", (fogExp2 is FogExp2).toString(), "true")
    }
}
