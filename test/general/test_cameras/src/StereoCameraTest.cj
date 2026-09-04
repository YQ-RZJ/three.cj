/**
 * @file StereoCameraTest
 * @brief test_cameras: StereoCamera 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.cameras.StereoCamera 能力：
 * - 构造（左右相机创建）
 * - update（用 PerspectiveCamera 更新左右相机参数）
 */
package test_cameras

import std.unittest.*
import std.collection.*
import three.rendering.cameras.StereoCamera
import three.rendering.cameras.PerspectiveCamera

public class StereoCameraTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("StereoCameraTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_stereo_construct(); () }
            suiteBuilder.add(UnitTestCase.create("test_stereo_construct", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_stereo_update(); () }
            suiteBuilder.add(UnitTestCase.create("test_stereo_update", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_stereo_construct() {
        let stereo = StereoCamera()
        // 左右相机已创建（PerspectiveCamera 实例）
        assertEqual("stereo.cameraL is PerspectiveCamera", "true", stereo.cameraL is PerspectiveCamera, true)
        assertEqual("stereo.cameraR is PerspectiveCamera", "true", stereo.cameraR is PerspectiveCamera, true)
    }

    func test_stereo_update() {
        let stereo = StereoCamera()
        let cam = PerspectiveCamera(fov: 60.0, aspect: 1.5, near: 0.1, far: 100.0)
        stereo.update(cam)
        // update 后左右相机 near 与源相机一致（调用不崩溃）
        assertEqual("stereo.cameraL.near == 0.1", "true", stereo.cameraL.near == 0.1, true)
    }
}
