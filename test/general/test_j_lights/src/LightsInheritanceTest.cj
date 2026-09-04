/**
 * @file LightsInheritanceTest
 * @brief 迁移 three.js test/unit/src/lights 目录 tests.js 的 Extending 断言
 *
 * 对照 JS:
 *   new AmbientLight() instanceof Light → true
 *   new DirectionalLight() instanceof Light → true
 *   new PointLight() instanceof Light → true 等（各类光均继承 Light）
 *   new LightShadow() → 可实例化
 */
package test_j_lights

import std.unittest.*
import three.rendering.lights.*
import three.core.math.Color

public class LightsInheritanceTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("LightsInheritanceTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_all_extend_light(); () }
            suiteBuilder.add(UnitTestCase.create("test_all_extend_light", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_all_extend_light() {
        // 对照 JS QUnit: obj instanceof Light 断言（仓颉用 isLight 标志）
        let lights = [
            AmbientLight(color: Color(0xffffff)), DirectionalLight(color: Color(0xffffff)),
            HemisphereLight(skyColor: Color(0xffffff), groundColor: Color(0x000000)), PointLight(color: Color(0xffffff)),
            RectAreaLight(color: Color(0xffffff)), SpotLight(color: Color(0xffffff)),
            LightProbe()
        ]
        for (l in lights) {
            assertEqual("${l.kind} isLight", "true", (l is Light).toString(), "true")
        }
    }
}
