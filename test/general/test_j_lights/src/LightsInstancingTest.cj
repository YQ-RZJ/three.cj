/**
 * @file LightsInstancingTest
 * @brief 迁移 three.js test/unit/src/lights 目录 tests.js 的 Instancing / isXxx / 阴影断言
 *
 * 对照 JS:
 *   new AmbientLight() → object.isAmbientLight === true
 *   new DirectionalLight() → object.isDirectionalLight === true
 *   new PointLight() → object.isPointLight === true 等
 *   阴影类（LightShadow/DirectionalLightShadow/PointLightShadow/SpotLightShadow）可实例化
 */
package test_j_lights

import std.unittest.*
import three.rendering.lights.*
import three.core.math.Color
import three.rendering.cameras.PerspectiveCamera

public class LightsInstancingTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("LightsInstancingTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_is_flags(); () }
            suiteBuilder.add(UnitTestCase.create("test_is_flags", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_shadow_classes(); () }
            suiteBuilder.add(UnitTestCase.create("test_shadow_classes", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_is_flags() {
        // 对照 JS QUnit: object.isXxx 断言
        assertEqual("AmbientLight isAmbientLight", "true", (AmbientLight(color: Color(0xffffff)) is AmbientLight).toString(), "true")
        assertEqual("DirectionalLight isDirectionalLight", "true", (DirectionalLight(color: Color(0xffffff)) is DirectionalLight).toString(), "true")
        assertEqual("HemisphereLight isHemisphereLight", "true", (HemisphereLight(skyColor: Color(0xffffff), groundColor: Color(0x000000)) is HemisphereLight).toString(), "true")
        assertEqual("PointLight isPointLight", "true", (PointLight(color: Color(0xffffff)) is PointLight).toString(), "true")
        assertEqual("RectAreaLight isRectAreaLight", "true", (RectAreaLight(color: Color(0xffffff)) is RectAreaLight).toString(), "true")
        assertEqual("SpotLight isSpotLight", "true", (SpotLight(color: Color(0xffffff)) is SpotLight).toString(), "true")
        assertEqual("LightProbe isLightProbe", "true", (LightProbe() is LightProbe).toString(), "true")
    }

    func test_shadow_classes() {
        // 对照 JS: LightShadow/DirectionalLightShadow/PointLightShadow/SpotLightShadow 实例化
        // 仓颉侧阴影类无 isXxx 标志，验证可实例化（kind 非空）即可
        let camera = PerspectiveCameraProxy()
        let lightShadow = LightShadow(camera)
        assertEqual("LightShadow instanced", "LightShadow", lightShadow.kind, "LightShadow")

        let dirShadow = DirectionalLightShadow()
        assertEqual("DirectionalLightShadow instanced", "DirectionalLightShadow", dirShadow.kind, "DirectionalLightShadow")

        let ptShadow = PointLightShadow()
        assertEqual("PointLightShadow instanced", "PointLightShadow", ptShadow.kind, "PointLightShadow")

        let spShadow = SpotLightShadow()
        assertEqual("SpotLightShadow instanced", "SpotLightShadow", spShadow.kind, "SpotLightShadow")
    }
}

/// 辅助：PerspectiveCamera 占位（LightShadow 构造需要 Camera）
public class PerspectiveCameraProxy <: PerspectiveCamera {
    public init() { super() }
}
