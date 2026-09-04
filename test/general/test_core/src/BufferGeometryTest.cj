/**
 * @file BufferGeometryTest
 * @brief test_core: BufferGeometry 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.core.BufferGeometry 能力：
 * - 构造（初始无属性）
 * - setAttribute/getAttribute/hasAttribute/deleteAttribute
 */
package test_core

import std.unittest.*
import std.collection.*
import three.rendering.geometry.BufferGeometry
import three.rendering.buffer.BufferAttribute

public class BufferGeometryTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("BufferGeometryTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_geometry_construct(); () }
            suiteBuilder.add(UnitTestCase.create("test_geometry_construct", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_geometry_attribute(); () }
            suiteBuilder.add(UnitTestCase.create("test_geometry_attribute", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_geometry_construct() {
        let geometry = BufferGeometry()
        // 初始无属性/索引
        assertEqual("hasAttribute(\"x\") == false", "true", geometry.hasAttribute("x"), false)
        assertEqual("getIndex() 为 None", "true", geometry.getIndex().isNone(), true)
    }

    func test_geometry_attribute() {
        let geometry = BufferGeometry()
        let attr = BufferAttribute([0.0, 1.0, 2.0], 3)
        geometry.setAttribute("position", attr)
        assertEqual("hasAttribute(\"position\") == true", "true", geometry.hasAttribute("position"), true)
        let got = geometry.getAttribute("position")
        assertEqual("getAttribute 非空", "true", got.isSome(), true)
        geometry.deleteAttribute("position")
        assertEqual("delete 后 hasAttribute false", "true", geometry.hasAttribute("position"), false)
    }
}
