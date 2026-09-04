/**
 * @file VectorTest
 * @brief test_math: Vector2/3/4 与 Quaternion 单元测试
 */
package test_math

import std.unittest.*
import std.math.*
import three.core.math.*
import three.rendering.buffer.*
import three.core.interfaces.*

public class VectorTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("VectorTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_vector3_ops(); () }
            suiteBuilder.add(UnitTestCase.create("test_vector3_ops", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_vector3_cross_dot(); () }
            suiteBuilder.add(UnitTestCase.create("test_vector3_cross_dot", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_quaternion_rotation(); () }
            suiteBuilder.add(UnitTestCase.create("test_quaternion_rotation", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_vector3_fromBufferAttribute(); () }
            suiteBuilder.add(UnitTestCase.create("test_vector3_fromBufferAttribute", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_vector3_ops() {
        let a = Vector3(1.0, 2.0, 3.0)
        let b = Vector3(4.0, 5.0, 6.0)
        // 加法
        let c = Vector3().addVectors(a, b)
        assertEqual("addVectors x == 5", "true", c.x == 5.0, true)
        assertEqual("addVectors y == 7", "true", c.y == 7.0, true)
        assertEqual("addVectors z == 9", "true", c.z == 9.0, true)
        // 归一化
        let n = Vector3(3.0, 0.0, 4.0).normalize()
        assertEqual("normalize length == 1", "true", abs(n.length() - 1.0) < 1e-9, true)
        // clamp
        let cl = Vector3(5.0, -5.0, 0.5).clamp(Vector3(0.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))
        assertEqual("clamp x == 1", "true", cl.x == 1.0, true)
        assertEqual("clamp y == -1", "true", cl.y == -1.0, true)
    }

    func test_vector3_cross_dot() {
        // 右手系叉积：X × Y = Z
        let x = Vector3(1.0, 0.0, 0.0)
        let y = Vector3(0.0, 1.0, 0.0)
        let z = Vector3().crossVectors(x, y)
        assertEqual("X×Y = Z x", "true", abs(z.x - 0.0) < 1e-9, true)
        assertEqual("X×Y = Z y", "true", abs(z.y - 0.0) < 1e-9, true)
        assertEqual("X×Y = Z z == 1", "true", abs(z.z - 1.0) < 1e-9, true)
        // 点积
        assertEqual("dot == 0 (垂直)", "true", x.dot(y) == 0.0, true)
        assertEqual("dot == 1 (平行)", "true", x.dot(x) == 1.0, true)
    }

    func test_quaternion_rotation() {
        // 绕 Z 轴旋转 90°：X 轴上的点 → Y 轴
        let q = Quaternion().setFromAxisAngle(Vector3(0.0, 0.0, 1.0), PI / 2.0)
        let v = Vector3(1.0, 0.0, 0.0).applyQuaternion(q)
        assertEqual("旋转后 x ≈ 0", "true", abs(v.x) < 1e-9, true)
        assertEqual("旋转后 y ≈ 1", "true", abs(v.y - 1.0) < 1e-9, true)
        // slerp 半程 → 单位四元数
        let q1 = Quaternion()
        let q2 = Quaternion().setFromAxisAngle(Vector3(0.0, 0.0, 1.0), PI)
        let half = Quaternion().slerpQuaternions(q1, q2, 0.5)
        assertEqual("slerp 半程长度 ≈ 1", "true", abs(half.length() - 1.0) < 1e-6, true)
    }

    func test_vector3_fromBufferAttribute() {
        // 构造顶点属性（3 分量，2 顶点）
        let array = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
        let attr = BufferAttribute(array, 3)
        let v = Vector3().fromBufferAttribute(attr, 1)
        assertEqual("fromBufferAttribute x == 4", "true", v.x == 4.0, true)
        assertEqual("fromBufferAttribute y == 5", "true", v.y == 5.0, true)
        assertEqual("fromBufferAttribute z == 6", "true", v.z == 6.0, true)
    }
}
