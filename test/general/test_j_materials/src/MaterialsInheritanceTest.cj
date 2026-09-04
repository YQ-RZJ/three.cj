/**
 * @file MaterialsInheritanceTest
 * @brief 迁移 three.js test/unit/src/materials 目录 tests.js 的 Extending 断言
 *
 * 对照 JS:
 *   new MeshBasicMaterial() instanceof Material → true
 *   new MeshPhongMaterial() instanceof Material → true 等
 */
package test_j_materials

import std.unittest.*
import three.rendering.materials.*

public class MaterialsInheritanceTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("MaterialsInheritanceTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_all_extend_material(); () }
            suiteBuilder.add(UnitTestCase.create("test_all_extend_material", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_all_extend_material() {
        // 对照 JS QUnit: obj instanceof Material 断言（Material 基类 isMaterial=true，子类继承）
        let mats = [
            MeshBasicMaterial(), MeshLambertMaterial(), MeshPhongMaterial(),
            MeshStandardMaterial(), MeshPhysicalMaterial(), MeshToonMaterial(),
            MeshMatcapMaterial(), MeshNormalMaterial(), MeshDepthMaterial(),
            MeshDistanceMaterial(), PointsMaterial(), LineBasicMaterial(),
            LineDashedMaterial(), SpriteMaterial(), ShadowMaterial(),
            ShaderMaterial("", ""), RawShaderMaterial()
        ]
        for (m in mats) {
            assertEqual("${m.kind} isMaterial", "true", (m is Material).toString(), "true")
        }
    }
}
