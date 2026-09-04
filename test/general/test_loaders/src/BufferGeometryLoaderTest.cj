/**
 * @file BufferGeometryLoaderTest
 * @brief test_loaders: BufferGeometryLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.BufferGeometryLoader.parse 能力（对照 JS parse）：
 * - index / attributes（含 name）解析
 * - groups 解析
 * - boundingSphere 解析
 * - name 解析
 */
package test_loaders

import std.unittest.*
import std.collection.*
import std.math.*
import three.resource.loader.BufferGeometryLoader
import three.rendering.buffer.BufferAttribute

public class BufferGeometryLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("BufferGeometryLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_attributes_index(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_attributes_index", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_groups_bounding_sphere(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_groups_bounding_sphere", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_parse_attributes_index() {
        // 构造与 BufferGeometry.toJSON() 一致的 JSON 结构
        let loader = BufferGeometryLoader()
        let json = HashMap<String, Any>()

        let data = HashMap<String, Any>()

        // attributes: position (itemSize=3)
        let attrs = HashMap<String, Any>()
        let posAttr = HashMap<String, Any>()
        posAttr.add("itemSize", Int64(3))
        posAttr.add("type", "Float32Array")
        posAttr.add("array", [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0])
        attrs.add("position", posAttr)
        data.add("attributes", attrs)

        // index: 3 个索引
        let idx = HashMap<String, Any>()
        idx.add("type", "Uint16Array")
        idx.add("array", [0, 1, 2])
        data.add("index", idx)

        json.add("data", data)
        json.add("name", "testGeo")

        let geometry = loader.parse(json)

        // name
        assertEqual("解析 name", "true", geometry.name == "testGeo", true)
        // index
        assertEqual("解析 index", "true", geometry.index.isSome(), true)
        // attributes
        let pos = geometry.attributes.get("position")
        assertEqual("解析 position 属性", "true", pos.isSome(), true)
        match (pos) {
            case Some(p) =>
                assertEqual("position itemSize", "true", p.itemSize == 3, true)
                assertEqual("position count", "true", p.count == 3, true)
            case None => ()
        }
    }

    func test_parse_groups_bounding_sphere() {
        let loader = BufferGeometryLoader()
        let json = HashMap<String, Any>()

        let data = HashMap<String, Any>()

        // groups
        let groups = ArrayList<Any>()
        let group = HashMap<String, Any>()
        group.add("start", Int64(0))
        group.add("count", Int64(3))
        group.add("materialIndex", Int64(1))
        groups.add(group)
        data.add("groups", groups)

        // boundingSphere
        let bs = HashMap<String, Any>()
        bs.add("radius", 1.5)
        bs.add("center", [0.0, 0.0, 0.0])
        data.add("boundingSphere", bs)

        json.add("data", data)

        let geometry = loader.parse(json)

        // groups（BufferGeometryGroup 已字段化：start/count/materialIndex）
        assertEqual("解析 groups 数量", "true", geometry.groups.size == 1, true)
        if (geometry.groups.size == 1) {
            let g = geometry.groups[0]
            assertEqual("group start", "true", g.start == 0, true)
            assertEqual("group materialIndex", "true", g.materialIndex == 1, true)
        }
        // boundingSphere
        assertEqual("解析 boundingSphere", "true", geometry.boundingSphere.isSome(), true)
        match (geometry.boundingSphere) {
            case Some(s) => assertEqual("boundingSphere radius", "true", abs(s.radius - 1.5) < 1e-9, true)
            case None => ()
        }
    }
}
