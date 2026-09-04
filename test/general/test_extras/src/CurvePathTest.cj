/**
 * @file CurvePathTest
 * @brief test_extras: CurvePath 单元测试（纯逻辑）
 *
 * 检测 three.extras.core.CurvePath 能力：
 * - add（添加子曲线）
 * - getLength / getPoints（采样）
 */
package test_extras

import std.unittest.*
import std.collection.*
import three.rendering.geometry.CurvePath
import three.rendering.geometry.LineCurve
import three.core.math.Vector3

public class CurvePathTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("CurvePathTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_curve_path_length(); () }
            suiteBuilder.add(UnitTestCase.create("test_curve_path_length", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_curve_path_points(); () }
            suiteBuilder.add(UnitTestCase.create("test_curve_path_points", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_curve_path_length() {
        let path = CurvePath()
        // 0→1 的线段，长度 1.0
        path.add(LineCurve(v1: Vector3(0.0, 0.0, 0.0), v2: Vector3(1.0, 0.0, 0.0)))
        assertEqual("getLength == 1.0", "true", path.getLength() == 1.0, true)
    }

    func test_curve_path_points() {
        let path = CurvePath()
        path.add(LineCurve(v1: Vector3(0.0, 0.0, 0.0), v2: Vector3(1.0, 0.0, 0.0)))
        // LineCurve 分辨率固定 1（每曲线 1 点），去重后至少 1 点
        let pts = path.getPoints(2)
        assertEqual("getPoints(2).size >= 1", "true", pts.size >= 1, true)
    }
}
