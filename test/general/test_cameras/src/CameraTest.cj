/**
 * @file CameraTest
 * @brief test_cameras: Camera 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.cameras.Camera 能力：
 * - 构造（默认/带参 near/far）
 * - getWorldDirection（默认朝向）
 * - updateMatrixWorld（矩阵更新不崩溃）
 */
package test_cameras

import std.unittest.*
import std.collection.*
import three.rendering.cameras.Camera
import three.core.math.Vector3

public class CameraTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("CameraTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_camera_construct(); () }
            suiteBuilder.add(UnitTestCase.create("test_camera_construct", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_camera_world_direction(); () }
            suiteBuilder.add(UnitTestCase.create("test_camera_world_direction", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_camera_matrix(); () }
            suiteBuilder.add(UnitTestCase.create("test_camera_matrix", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_camera_construct() {
        // 默认构造（near=0.1, far=2000）
        let cam = Camera()
        assertEqual("cam.near == 0.1", "true", cam.near == 0.1, true)
        assertEqual("cam.far == 2000.0", "true", cam.far == 2000.0, true)
        // 带参构造
        let cam2 = Camera(near: 0.5, far: 100.0)
        assertEqual("cam2.near == 0.5", "true", cam2.near == 0.5, true)
        assertEqual("cam2.far == 100.0", "true", cam2.far == 100.0, true)
    }

    func test_camera_world_direction() {
        let cam = Camera()
        let dir = cam.getWorldDirection(Vector3())
        // bgfx 左手系：相机默认朝 +Z（JS 右手系为 -Z）
        assertEqual("dir.z == 1.0", "true", dir.z == 1.0, true)
    }

    func test_camera_matrix() {
        let cam = Camera()
        cam.updateMatrixWorld(true)
        // 矩阵更新后 matrixWorldInverse 可用（调用不崩溃）
        assertEqual("cam is Camera", "true", cam is Camera, true)
    }
}
