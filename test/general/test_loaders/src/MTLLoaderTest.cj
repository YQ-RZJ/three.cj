/**
 * @file MTLLoaderTest
 * @brief test_loaders: MTLLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.MTLLoader / MaterialCreator 能力（对照 JS MTLLoader.parse）：
 * - newmtl 材质声明
 * - Kd/Ks/Ns/d 材质属性解析
 */
package test_loaders

import std.unittest.*
import std.collection.*
import std.math.*
import three.resource.loader.MTLLoader
import three.resource.loader.MaterialCreator
import three.rendering.materials.MeshPhongMaterial

public class MTLLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("MTLLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_material(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_material", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_parse_material() {
        // 对照 JS: MTLLoader.parse(text) → MaterialCreator
        let loader = MTLLoader()
        let mtlText = #"""
newmtl material_1
Kd 1.0 0.5 0.0
Ks 0.5 0.5 0.5
Ns 100.0
d 0.5
"""#
        let creator = loader.parse(mtlText, "")
        assertEqual("返回 MaterialCreator", "true", creator is MaterialCreator, true)
        // 对照 JS: creator.create(name) 创建材质
        let material = creator.create("material_1")
        assertEqual("材质创建成功", "true", material.isSome(), true)
        match (material) {
            case Some(m) =>
                match (m) {
                    case p: MeshPhongMaterial =>
                        // Kd → color（1.0, 0.5, 0.0）
                        assertEqual("Kd color 应用", "true", p.color.r == 1.0 && p.color.g == 0.5 && p.color.b == 0.0, true)
                        // Ks → specular
                        assertEqual("Ks specular 应用", "true", p.specular.r == 0.5, true)
                        // Ns → shininess
                        assertEqual("Ns shininess 应用", "true", p.shininess == 100.0, true)
                        // d → opacity / transparent
                        assertEqual("d opacity 应用", "true", abs(p.opacity - 0.5) < 1e-9, true)
                        assertEqual("d transparent 应用", "true", p.transparent, true)
                    case _ => assertEqual("MeshPhongMaterial", "true", false, true)
                }
            case None => ()
        }
        // 未声明的材质名返回 None
        assertEqual("未知材质返回 None", "true", creator.create("unknown").isNone(), true)
    }
}
