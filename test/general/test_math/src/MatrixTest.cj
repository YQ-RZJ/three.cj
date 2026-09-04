/**
 * @file MatrixTest
 * @brief test_math: Matrix3/Matrix4 单元测试（含新增 rotate/translate）
 */
package test_math

import std.unittest.*
import std.math.*
import three.core.math.*

public class MatrixTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("MatrixTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_matrix4_transform(); () }
            suiteBuilder.add(UnitTestCase.create("test_matrix4_transform", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_matrix4_compose_decompose(); () }
            suiteBuilder.add(UnitTestCase.create("test_matrix4_compose_decompose", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_matrix3_rotate_translate(); () }
            suiteBuilder.add(UnitTestCase.create("test_matrix3_rotate_translate", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_matrix4_transform() {
        // 平移 (1,2,3) 后点 (0,0,0) → (1,2,3)
        let m = Matrix4().makeTranslation(1.0, 2.0, 3.0)
        let p = Vector3().applyMatrix4(m)
        assertEqual("平移后 x == 1", "true", abs(p.x - 1.0) < 1e-9, true)
        assertEqual("平移后 y == 2", "true", abs(p.y - 2.0) < 1e-9, true)
        assertEqual("平移后 z == 3", "true", abs(p.z - 3.0) < 1e-9, true)
        // 单位矩阵不变
        let id = Matrix4()
        let v = Vector3(5.0, 6.0, 7.0).applyMatrix4(id)
        assertEqual("单位矩阵 x 不变", "true", v.x == 5.0, true)
    }

    func test_matrix4_compose_decompose() {
        // compose 后 decompose 还原
        let pos = Vector3(1.0, 2.0, 3.0)
        let quat = Quaternion().setFromAxisAngle(Vector3(0.0, 1.0, 0.0), 0.7)
        let scale = Vector3(2.0, 3.0, 4.0)
        let m = Matrix4().compose(pos, quat, scale)
        let p2 = Vector3(); let q2 = Quaternion(); let s2 = Vector3()
        m.decompose(p2, q2, s2)
        assertEqual("decompose pos x", "true", abs(p2.x - 1.0) < 1e-6, true)
        assertEqual("decompose pos y", "true", abs(p2.y - 2.0) < 1e-6, true)
        assertEqual("decompose pos z", "true", abs(p2.z - 3.0) < 1e-6, true)
        assertEqual("decompose scale x", "true", abs(s2.x - 2.0) < 1e-6, true)
        assertEqual("decompose quat w", "true", abs(q2.w - quat.w) < 1e-6, true)
    }

    func test_matrix3_rotate_translate() {
        // 对照 JS: Matrix3.rotate(theta) = premultiply(makeRotation(-theta))
        let m = Matrix3()
        m.rotate(0.5)
        // 旋转矩阵应有 cos/sin 特征
        assertEqual("rotate 后 m[0] == cos", "true", abs(m.elements[0] - cos(0.5)) < 1e-9, true)
        // translate 后为 2D 平移：作用点 (0,0) → (tx,ty)
        let t = Matrix3().translate(3.0, 4.0)
        let v2 = Vector2().applyMatrix3(t)
        assertEqual("translate 后 x == 3", "true", abs(v2.x - 3.0) < 1e-9, true)
        assertEqual("translate 后 y == 4", "true", abs(v2.y - 4.0) < 1e-9, true)
    }
}
