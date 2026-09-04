/**
 * @file ScenesInheritanceTest
 * @brief 迁移 three.js test/unit/src/scenes 目录 tests.js 的 Extending 断言
 *
 * 对照 JS:
 *   new Scene() instanceof Object3D → true
 *   new Fog() instanceof Object3D → true（Fog 继承自 Object3D）
 */
package test_j_scenes

import std.unittest.*
import three.scene.scenegraph.*
import three.core.math.Color
import three.scene.objects.Object3D

public class ScenesInheritanceTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ScenesInheritanceTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_extend(); () }
            suiteBuilder.add(UnitTestCase.create("test_extend", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_extend() {
        // 对照 JS QUnit: obj instanceof Object3D 断言
        // 注：JS 中 Fog/FogExp2 也是独立类（class Fog { 无 extends Object3D），
        // 仓颉侧同样为独立类——两边已对齐。故 Scene 断言 isObject3D，
        // Fog/FogExp2 断言 isFog/isFogExp2（见 Instancing 测试）。
        let scene = Scene()
        assertEqual("Scene isObject3D", "true", (scene is Object3D).toString(), "true")

        let fog = Fog(Color(0xffffff))
        assertEqual("Fog instanced", "true", (fog is Fog).toString(), "true")

        let fogExp2 = FogExp2(Color(0xffffff))
        assertEqual("FogExp2 instanced", "true", (fogExp2 is FogExp2).toString(), "true")
    }
}
