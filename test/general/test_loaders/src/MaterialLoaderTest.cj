/**
 * @file MaterialLoaderTest
 * @brief test_loaders: MaterialLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.MaterialLoader 能力（对照 JS parse/createMaterialFromType）：
 * - createMaterialFromType 按类型创建材质
 * - parse 应用 fromJSON 字段（color/opacity）
 */
package test_loaders

import std.unittest.*
import std.collection.*
import std.math.*
import three.resource.loader.MaterialLoader
import three.rendering.materials.*

public class MaterialLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("MaterialLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_create_material_from_type(); () }
            suiteBuilder.add(UnitTestCase.create("test_create_material_from_type", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_from_json(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_from_json", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_create_material_from_type() {
        let loader = MaterialLoader()
        // 对照 JS: createMaterialFromType('MeshStandardMaterial') → MeshStandardMaterial 实例
        let m1 = loader.createMaterialFromType("MeshStandardMaterial")
        match (m1) {
            case s: MeshStandardMaterial => assertEqual("MeshStandardMaterial 类型", "true", s.kind == "MeshStandardMaterial", true)
            case _ => assertEqual("MeshStandardMaterial 类型", "true", false, true)
        }
        let m2 = loader.createMaterialFromType("MeshBasicMaterial")
        match (m2) {
            case b: MeshBasicMaterial => assertEqual("MeshBasicMaterial 类型", "true", true, true)
            case _ => assertEqual("MeshBasicMaterial 类型", "true", false, true)
        }
        let m3 = loader.createMaterialFromType("LineBasicMaterial")
        match (m3) {
            case l: LineBasicMaterial => assertEqual("LineBasicMaterial 类型", "true", true, true)
            case _ => assertEqual("LineBasicMaterial 类型", "true", false, true)
        }
    }

    func test_parse_from_json() {
        let loader = MaterialLoader()
        let json = HashMap<String, Any>()
        json.add("type", "MeshBasicMaterial")
        json.add("color", Int64(0x00ff00))
        json.add("opacity", 0.5)
        json.add("transparent", true)

        let material = loader.parse(json)
        // 对照 JS: parse 返回对应类型材质并应用 fromJSON
        match (material) {
            case b: MeshBasicMaterial =>
                assertEqual("类型为 MeshBasicMaterial", "true", true, true)
                assertEqual("opacity 应用", "true", abs(b.opacity - 0.5) < 1e-9, true)
                assertEqual("transparent 应用", "true", b.transparent, true)
                assertEqual("color 应用", "true", b.color.getHex() == 0x00ff00, true)
            case _ => assertEqual("类型为 MeshBasicMaterial", "true", false, true)
        }
    }
}
