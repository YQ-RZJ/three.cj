/**
 * @file ShapeUtilsTest
 * @brief test_extras: ShapeUtils 单元测试（纯逻辑）
 *
 * 检测 three.extras.ShapeUtils 静态工具能力：
 * - area / isClockWise / triangulateShape
 */
package test_extras

import std.unittest.*
import std.collection.*
import three.rendering.geometry.ShapeUtils
import three.core.math.Vector2

public class ShapeUtilsTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ShapeUtilsTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_area(); () }
            suiteBuilder.add(UnitTestCase.create("test_area", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_is_clockwise(); () }
            suiteBuilder.add(UnitTestCase.create("test_is_clockwise", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_triangulate(); () }
            suiteBuilder.add(UnitTestCase.create("test_triangulate", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_area() {
        // 2x2 正方形（逆时针点序）→ 面积 4.0
        let contour = [Vector2(0.0, 0.0), Vector2(2.0, 0.0), Vector2(2.0, 2.0), Vector2(0.0, 2.0)]
        let a = ShapeUtils.area(contour)
        assertEqual("area == 4.0", "true", a == 4.0, true)
    }

    func test_is_clockwise() {
        // 顺时针点序
        let pts = [Vector2(0.0, 0.0), Vector2(0.0, 2.0), Vector2(2.0, 2.0), Vector2(2.0, 0.0)]
        assertEqual("isClockWise == true", "true", ShapeUtils.isClockWise(pts), true)
    }

    func test_triangulate() {
        // 矩形轮廓（无洞）三角化 → 2 个三角形
        let contour = ArrayList<Vector2>()
        contour.add(Vector2(0.0, 0.0))
        contour.add(Vector2(2.0, 0.0))
        contour.add(Vector2(2.0, 2.0))
        contour.add(Vector2(0.0, 2.0))
        let holes = ArrayList<ArrayList<Vector2>>()
        let tris = ShapeUtils.triangulateShape(contour, holes)
        assertEqual("triangulate 返回 2 三角形", "true", tris.size == 2, true)
    }
}
