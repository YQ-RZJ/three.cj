/**
 * @file MaterialsInstancingTest
 * @brief 迁移 three.js test/unit/src/materials 目录 tests.js 的 Instancing / isXxx 断言
 *
 * 对照 JS:
 *   new MeshBasicMaterial() → object.isMeshBasicMaterial === true
 *   new MeshPhongMaterial() → object.isMeshPhongMaterial === true 等
 */
package test_j_materials

import std.unittest.*
import three.rendering.materials.*

public class MaterialsInstancingTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("MaterialsInstancingTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_is_flags(); () }
            suiteBuilder.add(UnitTestCase.create("test_is_flags", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_is_flags() {
        // 对照 JS QUnit: object.isXxx 断言
        // 注：仓颉侧部分材质无 isXxx 字段（MeshPhysical/MeshDepth/MeshDistance/
        // LineDashed/Shadow/RawShader），改用 kind 字符串断言（对照 JS type 断言）。
        assertEqual("MeshBasic isMeshBasicMaterial", "true", (MeshBasicMaterial() is MeshBasicMaterial).toString(), "true")
        assertEqual("MeshLambert isMeshLambertMaterial", "true", (MeshLambertMaterial() is MeshLambertMaterial).toString(), "true")
        assertEqual("MeshPhong isMeshPhongMaterial", "true", (MeshPhongMaterial() is MeshPhongMaterial).toString(), "true")
        assertEqual("MeshStandard isMeshStandardMaterial", "true", (MeshStandardMaterial() is MeshStandardMaterial).toString(), "true")
        assertEqual("MeshPhysical kind", "MeshPhysicalMaterial", MeshPhysicalMaterial().kind, "MeshPhysicalMaterial")
        assertEqual("MeshToon isMeshToonMaterial", "true", (MeshToonMaterial() is MeshToonMaterial).toString(), "true")
        assertEqual("MeshMatcap isMeshMatcapMaterial", "true", (MeshMatcapMaterial() is MeshMatcapMaterial).toString(), "true")
        assertEqual("MeshNormal isMeshNormalMaterial", "true", (MeshNormalMaterial() is MeshNormalMaterial).toString(), "true")
        assertEqual("MeshDepth kind", "MeshDepthMaterial", MeshDepthMaterial().kind, "MeshDepthMaterial")
        assertEqual("MeshDistance kind", "MeshDistanceMaterial", MeshDistanceMaterial().kind, "MeshDistanceMaterial")
        assertEqual("Points isPointsMaterial", "true", (PointsMaterial() is PointsMaterial).toString(), "true")
        assertEqual("LineBasic isLineBasicMaterial", "true", (LineBasicMaterial() is LineBasicMaterial).toString(), "true")
        assertEqual("LineDashed kind", "LineDashedMaterial", LineDashedMaterial().kind, "LineDashedMaterial")
        assertEqual("Sprite isSpriteMaterial", "true", (SpriteMaterial() is SpriteMaterial).toString(), "true")
        assertEqual("Shadow kind", "ShadowMaterial", ShadowMaterial().kind, "ShadowMaterial")
        assertEqual("Shader isShaderMaterial", "true", (ShaderMaterial("", "") is ShaderMaterial).toString(), "true")
        assertEqual("RawShader kind", "RawShaderMaterial", RawShaderMaterial().kind, "RawShaderMaterial")
    }
}
