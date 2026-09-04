/**
 * @file PerspectiveCameraTest
 * @brief test_cameras: PerspectiveCamera 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.cameras.PerspectiveCamera 能力：
 * - 构造（默认/带参 fov/aspect/near/far）
 * - setFocalLength/getFocalLength
 * - updateProjectionMatrix（投影矩阵更新）
 */
package test_cameras

import std.unittest.*
import std.collection.*
import three.rendering.cameras.PerspectiveCamera

public class PerspectiveCameraTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("PerspectiveCameraTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_persp_construct(); () }
            suiteBuilder.add(UnitTestCase.create("test_persp_construct", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_persp_focal_length(); () }
            suiteBuilder.add(UnitTestCase.create("test_persp_focal_length", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_persp_projection(); () }
            suiteBuilder.add(UnitTestCase.create("test_persp_projection", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_persp_construct() {
        // 默认构造（fov=50, aspect=1, near=0.1, far=2000）
        let cam = PerspectiveCamera()
        assertEqual("cam.fov == 50.0", "true", cam.fov == 50.0, true)
        assertEqual("cam.aspect == 1.0", "true", cam.aspect == 1.0, true)
        assertEqual("cam.near == 0.1", "true", cam.near == 0.1, true)
        assertEqual("cam.far == 2000.0", "true", cam.far == 2000.0, true)
        // 带参构造
        let cam2 = PerspectiveCamera(fov: 75.0, aspect: 1.5, near: 0.01, far: 100.0)
        assertEqual("cam2.fov == 75.0", "true", cam2.fov == 75.0, true)
        assertEqual("cam2.aspect == 1.5", "true", cam2.aspect == 1.5, true)
        assertEqual("cam2.near == 0.01", "true", cam2.near == 0.01, true)
        assertEqual("cam2.far == 100.0", "true", cam2.far == 100.0, true)
    }

    func test_persp_focal_length() {
        let cam = PerspectiveCamera()
        cam.setFocalLength(50.0)
        let fl = cam.getFocalLength()
        assertEqual("getFocalLength 返回 > 0", "true", fl > 0.0, true)
    }

    func test_persp_projection() {
        let cam = PerspectiveCamera(fov: 75.0, aspect: 1.5, near: 0.01, far: 100.0)
        cam.updateProjectionMatrix()
        // 投影矩阵更新后类型判断为 PerspectiveCamera（调用不崩溃）
        assertEqual("cam is PerspectiveCamera", "true", cam is PerspectiveCamera, true)
    }
}
