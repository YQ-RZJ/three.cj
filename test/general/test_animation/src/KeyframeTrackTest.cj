/**
 * @file KeyframeTrackTest
 * @brief animation_test: KeyframeTrack 单元测试
 *
 * 检测 three.animation.KeyframeTrack 能力：
 * - 构造（name/times/values）
 * - setInterpolation/getInterpolation
 * - getValueSize / shift
 * - 插值工厂（InterpolantFactoryMethodLinear）
 */
package animation_test

import std.unittest.*
import std.collection.*
import three.animation.blend.KeyframeTrack
import three.utils.constants.InterpolateLinear
import three.utils.constants.InterpolateDiscrete
import three.core.math.Interpolant

public class KeyframeTrackTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("KeyframeTrackTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_track_create(); () }
            suiteBuilder.add(UnitTestCase.create("test_track_create", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_track_interpolation(); () }
            suiteBuilder.add(UnitTestCase.create("test_track_interpolation", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_track_value_size(); () }
            suiteBuilder.add(UnitTestCase.create("test_track_value_size", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_track_shift(); () }
            suiteBuilder.add(UnitTestCase.create("test_track_shift", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_interpolant_factory(); () }
            suiteBuilder.add(UnitTestCase.create("test_interpolant_factory", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_track_create() {
        let track = KeyframeTrack("position", [0.0, 1.0, 2.0], [0.0, 1.0, 2.0])
        assertEqual("track.name == \"position\"", "true", track.name == "position", true)
        assertEqual("track.times.size == 3", "true", track.times.size == 3, true)
        assertEqual("track.values.size == 3", "true", track.values.size == 3, true)
    }

    func test_track_interpolation() {
        let track = KeyframeTrack("position", [0.0, 1.0, 2.0], [0.0, 1.0, 2.0])
        track.setInterpolation(InterpolateDiscrete)
        assertEqual("track.getInterpolation() == InterpolateDiscrete", "true", track.getInterpolation() == InterpolateDiscrete, true)
    }

    func test_track_value_size() {
        // times=3, values=3 → 值大小 1（JS: values.length / times.length）
        let track = KeyframeTrack("position", [0.0, 1.0, 2.0], [0.0, 1.0, 2.0])
        assertEqual("track.getValueSize() == 1", "true", track.getValueSize() == 1, true)
    }

    func test_track_shift() {
        let track = KeyframeTrack("position", [0.0, 1.0, 2.0], [0.0, 1.0, 2.0])
        let shifted = track.shift(1.0)
        assertEqual("shifted.times[0] == 1.0", "true", shifted.times[0] == 1.0, true)
        assertEqual("shifted.times[1] == 2.0", "true", shifted.times[1] == 2.0, true)
    }

    func test_interpolant_factory() {
        let track = KeyframeTrack("position", [0.0, 1.0, 2.0], [0.0, 1.0, 2.0])
        let interp = track.InterpolantFactoryMethodLinear(None)
        assertEqual("interp is Interpolant", "true", interp is Interpolant, true)
    }
}
