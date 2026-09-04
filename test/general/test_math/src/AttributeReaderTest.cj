/**
 * @file AttributeReaderTest
 * @brief test_math: three.interfaces 接口包 + fromBufferAttribute 系列单元测试
 */
package test_math

import std.unittest.*
import std.math.*
import three.core.math.*
import three.rendering.buffer.*
import three.core.interfaces.*

public class AttributeReaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("AttributeReaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_buffer_attribute_implements_interface(); () }
            suiteBuilder.add(UnitTestCase.create("test_buffer_attribute_implements_interface", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_vector_fromBufferAttribute(); () }
            suiteBuilder.add(UnitTestCase.create("test_vector_fromBufferAttribute", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_box3_setFromBufferAttribute(); () }
            suiteBuilder.add(UnitTestCase.create("test_box3_setFromBufferAttribute", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_triangle_fromAttribute(); () }
            suiteBuilder.add(UnitTestCase.create("test_triangle_fromAttribute", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_buffer_attribute_implements_interface() {
        // BufferAttribute 应可视为 AttributeReader 接口
        let attr = BufferAttribute([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 3)
        let reader: AttributeReader = attr
        assertEqual("接口 count == 2", "true", reader.count == 2, true)
        assertEqual("接口 getX(0) == 1", "true", reader.getX(0) == 1.0, true)
        assertEqual("接口 getY(0) == 2", "true", reader.getY(0) == 2.0, true)
        assertEqual("接口 getZ(1) == 6", "true", reader.getZ(1) == 6.0, true)
    }

    func test_vector_fromBufferAttribute() {
        // itemSize=4：顶点0=(10,20,30,40)，顶点1=(50,60,70,80)
        let attr = BufferAttribute([10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0], 4)
        // Vector2 读前 2 分量
        let v2 = Vector2().fromBufferAttribute(attr, 0)
        assertEqual("Vector2 x == 10", "true", v2.x == 10.0, true)
        assertEqual("Vector2 y == 20", "true", v2.y == 20.0, true)
        // Vector3 读前 3 分量（索引 1 → 50,60,70）
        let v3 = Vector3().fromBufferAttribute(attr, 1)
        assertEqual("Vector3 x == 50", "true", v3.x == 50.0, true)
        assertEqual("Vector3 y == 60", "true", v3.y == 60.0, true)
        assertEqual("Vector3 z == 70", "true", v3.z == 70.0, true)
        // Vector4 读 4 分量
        let v4 = Vector4().fromBufferAttribute(attr, 0)
        assertEqual("Vector4 w == 40", "true", v4.w == 40.0, true)
        // Color 读 RGB
        let c = Color().fromBufferAttribute(attr, 0)
        assertEqual("Color r == 10", "true", c.r == 10.0, true)
        assertEqual("Color b == 30", "true", c.b == 30.0, true)
    }

    func test_box3_setFromBufferAttribute() {
        // 顶点：(-1,-1,-1) (1,1,1) → box min/max
        let attr = BufferAttribute([-1.0, -1.0, -1.0, 1.0, 1.0, 1.0], 3)
        let box = Box3().setFromBufferAttribute(attr)
        assertEqual("box min.x == -1", "true", box.min.x == -1.0, true)
        assertEqual("box max.x == 1", "true", box.max.x == 1.0, true)
        assertEqual("box max.y == 1", "true", box.max.y == 1.0, true)
        assertEqual("box max.z == 1", "true", box.max.z == 1.0, true)
    }

    func test_triangle_fromAttribute() {
        // 三角形顶点来自属性
        let attr = BufferAttribute([0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 2.0, 0.0], 3)
        let tri = Triangle().setFromAttributeAndIndices(attr, 0, 1, 2)
        assertEqual("tri.a == (0,0,0)", "true", tri.a.x == 0.0 && tri.a.y == 0.0 && tri.a.z == 0.0, true)
        assertEqual("tri.b.x == 2", "true", tri.b.x == 2.0, true)
        assertEqual("tri.c.y == 2", "true", tri.c.y == 2.0, true)
        // getInterpolatedAttribute：重心 (0.5,0.5,0) → 插值 = 0.5*(0,0,0)+0.5*(2,0,0)+0*(0,2,0) = (1,0,0)
        let bary = Vector3(0.5, 0.5, 0.0)
        let target = Triangle.getInterpolatedAttribute(attr, 0, 1, 2, bary, Vector3())
        assertEqual("插值 x == 1", "true", abs(target.x - 1.0) < 1e-9, true)
        assertEqual("插值 y == 0", "true", abs(target.y - 0.0) < 1e-9, true)
    }
}
