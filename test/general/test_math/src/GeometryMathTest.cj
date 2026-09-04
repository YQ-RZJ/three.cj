/**
 * @file GeometryMathTest
 * @brief test_math: Box3/Sphere/Plane/Ray/Line3/Triangle 单元测试（含新增方法）
 */
package test_math

import std.unittest.*
import std.math.*
import three.core.math.*

public class GeometryMathTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("GeometryMathTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_box3(); () }
            suiteBuilder.add(UnitTestCase.create("test_box3", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_line3_distances(); () }
            suiteBuilder.add(UnitTestCase.create("test_line3_distances", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_line3_applyMatrix4(); () }
            suiteBuilder.add(UnitTestCase.create("test_line3_applyMatrix4", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_triangle(); () }
            suiteBuilder.add(UnitTestCase.create("test_triangle", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_box3() {
        let box = Box3().setFromCenterAndSize(Vector3(0.0, 0.0, 0.0), Vector3(2.0, 2.0, 2.0))
        assertEqual("box min.x == -1", "true", box.min.x == -1.0, true)
        assertEqual("box max.x == 1", "true", box.max.x == 1.0, true)
        // 点包含
        assertEqual("containsPoint 内点", "true", box.containsPoint(Vector3(0.5, 0.5, 0.5)), true)
        assertEqual("containsPoint 外点", "true", !box.containsPoint(Vector3(2.0, 0.0, 0.0)), true)
        // union
        let b2 = Box3().setFromCenterAndSize(Vector3(3.0, 0.0, 0.0), Vector3(2.0, 2.0, 2.0))
        let u = Box3().copy(box).union(b2)
        assertEqual("union min.x == -1", "true", u.min.x == -1.0, true)
        assertEqual("union max.x == 4", "true", u.max.x == 4.0, true)
    }

    func test_line3_distances() {
        // 平行线段（间距 1）：沿 X 轴的两条线
        let l1 = Line3(Vector3(0.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0))
        let l2 = Line3(Vector3(0.0, 1.0, 0.0), Vector3(1.0, 1.0, 0.0))
        let c1 = Vector3(); let c2 = Vector3()
        let d = l1.distanceSqToLine3(l2, c1, c2)
        assertEqual("平行线距离平方 == 1", "true", abs(d - 1.0) < 1e-9, true)
        // 退化：两点（点 (5,5,5) 到线段 [0,1]×X 轴的最近点 (1,0,0)，距离平方 = 4²+5²+5² = 66）
        let l3 = Line3(Vector3(5.0, 5.0, 5.0), Vector3(5.0, 5.0, 5.0))
        let c3 = Vector3(); let c4 = Vector3()
        let d2 = l1.distanceSqToLine3(l3, c3, c4)
        assertEqual("点线距离平方 == 66", "true", abs(d2 - 66.0) < 1e-9, true)
    }

    func test_line3_applyMatrix4() {
        let l = Line3(Vector3(0.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0))
        let m = Matrix4().makeTranslation(10.0, 20.0, 30.0)
        l.applyMatrix4(m)
        assertEqual("起点平移 x == 10", "true", l.start.x == 10.0, true)
        assertEqual("终点平移 y == 20", "true", l.end.y == 20.0, true)
        assertEqual("终点平移 z == 30", "true", l.end.z == 30.0, true)
    }

    func test_triangle() {
        // 面积：底 2 高 2 的三角形 → 面积 2
        let tri = Triangle(Vector3(0.0, 0.0, 0.0), Vector3(2.0, 0.0, 0.0), Vector3(0.0, 2.0, 0.0))
        assertEqual("三角形面积 == 2", "true", abs(tri.getArea() - 2.0) < 1e-9, true)
        // 法线 +Z
        let n = tri.getNormal()
        assertEqual("法线 z == 1", "true", abs(n.z - 1.0) < 1e-9, true)
        // 重心坐标：三角形内点 (0.5, 0.5, 0) 的 barycoord 各分量 > 0
        let bc = tri.getBarycoord(Vector3(0.5, 0.5, 0.0), Vector3())
        match (bc) {
            case Some(b) =>
                assertEqual("barycoord x > 0", "true", b.x > 0.0, true)
                assertEqual("barycoord y > 0", "true", b.y > 0.0, true)
                assertEqual("barycoord z > 0", "true", b.z > 0.0, true)
            case None =>
                assertEqual("barycoord 存在", "true", false, true)
        }
    }
}
