/**
 * @file OrthographicCameraTest
 * @brief test_cameras: OrthographicCamera 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.cameras.OrthographicCamera 能力：
 * - 构造（默认/带参 left/right/top/bottom/near/far）
 * - updateProjectionMatrix（投影矩阵更新）
 */
package test_cameras

import std.unittest.*
import std.collection.*
import three.rendering.cameras.OrthographicCamera

public class OrthographicCameraTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("OrthographicCameraTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_ortho_construct(); () }
            suiteBuilder.add(UnitTestCase.create("test_ortho_construct", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_ortho_projection(); () }
            suiteBuilder.add(UnitTestCase.create("test_ortho_projection", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_ortho_construct() {
        // 默认构造（left=-1, right=1, top=1, bottom=-1, near=0.1, far=2000）
        let cam = OrthographicCamera()
        assertEqual("cam.left == -1.0", "true", cam.left == -1.0, true)
        assertEqual("cam.right == 1.0", "true", cam.right == 1.0, true)
        assertEqual("cam.top == 1.0", "true", cam.top == 1.0, true)
        assertEqual("cam.bottom == -1.0", "true", cam.bottom == -1.0, true)
        assertEqual("cam.near == 0.1", "true", cam.near == 0.1, true)
        assertEqual("cam.far == 2000.0", "true", cam.far == 2000.0, true)
        // 带参构造
        let cam2 = OrthographicCamera(left: -10.0, right: 10.0, top: 5.0, bottom: -5.0, near: 1.0, far: 100.0)
        assertEqual("cam2.left == -10.0", "true", cam2.left == -10.0, true)
        assertEqual("cam2.right == 10.0", "true", cam2.right == 10.0, true)
        assertEqual("cam2.top == 5.0", "true", cam2.top == 5.0, true)
        assertEqual("cam2.bottom == -5.0", "true", cam2.bottom == -5.0, true)
    }

    func test_ortho_projection() {
        let cam = OrthographicCamera(left: -10.0, right: 10.0, top: 5.0, bottom: -5.0, near: 1.0, far: 100.0)
        cam.updateProjectionMatrix()
        // 投影矩阵更新后类型判断为 OrthographicCamera（调用不崩溃）
        assertEqual("cam is OrthographicCamera", "true", cam is OrthographicCamera, true)
    }
}
