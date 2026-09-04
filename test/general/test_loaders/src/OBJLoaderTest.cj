/**
 * @file OBJLoaderTest
 * @brief test_loaders: OBJLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.OBJLoader 能力（对照 JS OBJLoader.parse）：
 * - v/vt/vn 顶点数据解析
 * - f 面三角剖分与属性构建
 * - usemtl 材质段
 */
package test_loaders

import std.unittest.*
import std.collection.*
import three.resource.loader.OBJLoader
import three.scene.scenegraph.Group
import three.scene.entity.Mesh
import three.rendering.materials.MeshPhongMaterial

public class OBJLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("OBJLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_simple_triangle(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_simple_triangle", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_usemtl(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_usemtl", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_parse_simple_triangle() {
        // 对照 JS: OBJLoader.parse(text) — 一个三角形
        let loader = OBJLoader()
        let objText = #"""
v 0 0 0
v 1 0 0
v 0 1 0
f 1 2 3
"""#
        let group = loader.parse(objText)
        // 输出 Group
        assertEqual("输出 Group", "true", group is Group, true)
        assertEqual("一个 Mesh", "true", group.children.size == 1, true)
        if (group.children.size == 1) {
            match (group.children[0]) {
                case m: Mesh =>
                    // 对照 JS: position 属性（3 顶点 × 3 分量）
                    let pos = m.geometry.getAttribute("position")
                    assertEqual("position 存在", "true", pos.isSome(), true)
                    match (pos) {
                        case Some(p) =>
                            assertEqual("position itemSize == 3", "true", p.itemSize == 3, true)
                            assertEqual("position count == 3", "true", p.count == 3, true)
                            // 第一个顶点 (0,0,0)
                            assertEqual("v1 x == 0", "true", p.array[0] == 0.0, true)
                        case None => ()
                    }
                case _ => assertEqual("子对象是 Mesh", "true", false, true)
            }
        }
    }

    func test_parse_usemtl() {
        // 对照 JS: usemtl 声明 → 材质段（未设置 MaterialCreator 时使用默认 MeshPhongMaterial 并命名）
        let loader = OBJLoader()
        let objText = #"""
usemtl material_1
v 0 0 0
v 1 0 0
v 0 1 0
f 1 2 3
"""#
        let group = loader.parse(objText)
        assertEqual("输出 Group", "true", group is Group, true)
        assertEqual("一个 Mesh", "true", group.children.size == 1, true)
        if (group.children.size == 1) {
            match (group.children[0]) {
                case m: Mesh =>
                    match (m.material) {
                        case p: MeshPhongMaterial =>
                            assertEqual("材质名来自 usemtl", "true", p.name == "material_1", true)
                        case _ => assertEqual("默认 MeshPhongMaterial", "true", false, true)
                    }
                case _ => ()
            }
        }
    }
}
