/**
 * @file AnimationClipTest
 * @brief animation_test: AnimationClip 单元测试
 *
 * 检测 three.animation.AnimationClip 能力：
 * - 构造（默认/带参）
 * - resetDuration / validate / clone
 */
package animation_test

import std.unittest.*
import std.collection.*
import three.animation.clip.AnimationClip
import three.animation.blend.KeyframeTrack

public class AnimationClipTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("AnimationClipTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clip_create(); () }
            suiteBuilder.add(UnitTestCase.create("test_clip_create", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clip_reset_duration(); () }
            suiteBuilder.add(UnitTestCase.create("test_clip_reset_duration", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clip_validate(); () }
            suiteBuilder.add(UnitTestCase.create("test_clip_validate", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clip_clone(); () }
            suiteBuilder.add(UnitTestCase.create("test_clip_clone", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_clip_create() {
        // 默认构造
        let clip = AnimationClip()
        assertEqual("clip.name == \"\"", "true", clip.name == "", true)
        // 默认 duration=-1.0 < 0 → init 内 resetDuration()；空 tracks → duration=0.0
        assertEqual("clip.duration == 0.0", "true", clip.duration == 0.0, true)
        assertEqual("clip.tracks.size == 0", "true", clip.tracks.size == 0, true)
        // 带参构造
        let clip2 = AnimationClip(name: "walk", duration: 2.0, tracks: [])
        assertEqual("clip2.name == \"walk\"", "true", clip2.name == "walk", true)
        assertEqual("clip2.duration == 2.0", "true", clip2.duration == 2.0, true)
        assertEqual("clip2.tracks.size == 0", "true", clip2.tracks.size == 0, true)
    }

    func test_clip_reset_duration() {
        let clip = AnimationClip(name: "walk", duration: 2.0, tracks: [])
        clip.resetDuration()
        // 空 tracks：无轨道可计算时长 → duration = 0.0（resetDuration 以 0 起始）
        assertEqual("clip.duration == 0.0", "true", clip.duration == 0.0, true)
    }

    func test_clip_validate() {
        // 空 clip（无轨道）validate 通过
        let clip = AnimationClip()
        assertEqual("clip.validate() == true", "true", clip.validate(), true)
    }

    func test_clip_clone() {
        let clip = AnimationClip(name: "walk", duration: 2.0, tracks: [])
        let copy = clip.clone()
        assertEqual("copy.name == \"walk\"", "true", copy.name == "walk", true)
        assertEqual("copy.duration == 2.0", "true", copy.duration == 2.0, true)
        assertEqual("copy.tracks.size == 0", "true", copy.tracks.size == 0, true)
    }
}
