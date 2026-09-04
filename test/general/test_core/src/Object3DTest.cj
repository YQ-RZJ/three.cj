/**
 * @file Object3DTest
 * @brief test_core: Object3D 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.core.Object3D 能力：
 * - 构造（position/scale 默认值）
 * - add/remove（父子关系）
 * - updateMatrixWorld（矩阵更新）
 */
package test_core

import std.unittest.*
import std.collection.*
import std.core.*
import three.scene.objects.Object3D

public class Object3DTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("Object3DTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_object3d_construct(); () }
            suiteBuilder.add(UnitTestCase.create("test_object3d_construct", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_object3d_add_remove(); () }
            suiteBuilder.add(UnitTestCase.create("test_object3d_add_remove", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_object3d_matrix(); () }
            suiteBuilder.add(UnitTestCase.create("test_object3d_matrix", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_object3d_construct() {
        let obj = Object3D()
        // 默认位置 (0,0,0)、缩放 (1,1,1)
        assertEqual("obj.position.x == 0.0", "true", obj.position.x == 0.0, true)
        assertEqual("obj.position.y == 0.0", "true", obj.position.y == 0.0, true)
        assertEqual("obj.position.z == 0.0", "true", obj.position.z == 0.0, true)
        assertEqual("obj.scale.x == 1.0", "true", obj.scale.x == 1.0, true)
        assertEqual("obj.scale.y == 1.0", "true", obj.scale.y == 1.0, true)
        assertEqual("obj.scale.z == 1.0", "true", obj.scale.z == 1.0, true)
    }

    func test_object3d_add_remove() {
        let parent = Object3D()
        let child = Object3D()
        parent.add(child)
        // add 后 child 的 parent 被设置
        assertEqual("child.parent.isSome()", "true", child.parent.isSome(), true)
        parent.remove(child)
        // remove 后 child 的 parent 被清除
        assertEqual("child.parent.isNone()", "true", child.parent.isNone(), true)
    }

    func test_object3d_matrix() {
        let obj = Object3D()
        obj.updateMatrixWorld(true)
        // 矩阵更新后 matrixAutoUpdate 保持默认 true（调用不崩溃）
        assertEqual("obj.matrixAutoUpdate == true", "true", obj.matrixAutoUpdate, true)
    }
}
