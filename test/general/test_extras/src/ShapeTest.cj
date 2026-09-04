/**
 * @file ShapeTest
 * @brief test_extras: Shape 单元测试（纯逻辑）
 *
 * 检测 three.extras.core.Shape 能力：
 * - 构造（默认/带轮廓点）与继承链（Shape → Path → CurvePath → Curve）
 * - extractPoints（轮廓提取）
 */
package test_extras

import std.unittest.*
import std.collection.*
import three.rendering.geometry.Shape
import three.rendering.geometry.Path
import three.core.math.Vector3

public class ShapeTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ShapeTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_shape_construct(); () }
            suiteBuilder.add(UnitTestCase.create("test_shape_construct", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_shape_extract(); () }
            suiteBuilder.add(UnitTestCase.create("test_shape_extract", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_shape_construct() {
        // 继承链对齐（Shape → Path → CurvePath → Curve）
        let shape = Shape()
        assertEqual("shape is Path", "true", shape is Path, true)
        // 带轮廓点构造
        let shape2 = Shape([Vector3(0.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(1.0, 1.0, 0.0)])
        assertEqual("shape2 构造成功", "true", shape2 is Shape, true)
    }

    func test_shape_extract() {
        // 矩形轮廓
        let shape = Shape([Vector3(0.0, 0.0, 0.0), Vector3(2.0, 0.0, 0.0), Vector3(2.0, 2.0, 0.0), Vector3(0.0, 2.0, 0.0)])
        let data = shape.extractPoints(5)
        // extractPoints 返回 { shape, holes }
        assertEqual("extractPoints 含 shape 键", "true", data.contains("shape"), true)
    }
}
