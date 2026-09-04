/**
 * @file AnimationMixerTest
 * @brief animation_test: AnimationMixer 单元测试
 *
 * 检测 three.animation.AnimationMixer 能力：
 * - 构造（root Object3D）
 * - clipAction / existingAction / stopAllAction
 */
package animation_test

import std.unittest.*
import std.collection.*
import std.core.*
import three.animation.clip.AnimationClip
import three.animation.blend.AnimationMixer
import three.animation.blend.AnimationAction
import three.scene.objects.Object3D

public class AnimationMixerTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("AnimationMixerTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_mixer_create(); () }
            suiteBuilder.add(UnitTestCase.create("test_mixer_create", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_mixer_clip_action(); () }
            suiteBuilder.add(UnitTestCase.create("test_mixer_clip_action", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_mixer_existing_action(); () }
            suiteBuilder.add(UnitTestCase.create("test_mixer_existing_action", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_mixer_stop_all(); () }
            suiteBuilder.add(UnitTestCase.create("test_mixer_stop_all", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_mixer_create() {
        let root = Object3D()
        let mixer = AnimationMixer(root)
        assertEqual("mixer.getRoot() 与 root 引用相等", "true", refEq(mixer.getRoot(), root), true)
    }

    func test_mixer_clip_action() {
        let root = Object3D()
        let mixer = AnimationMixer(root)
        let clip = AnimationClip(name: "walk", duration: 1.0, tracks: [])
        let action = mixer.clipAction(clip)
        assertEqual("action is AnimationAction", "true", action is AnimationAction, true)
    }

    func test_mixer_existing_action() {
        let root = Object3D()
        let mixer = AnimationMixer(root)
        let clip = AnimationClip(name: "walk", duration: 1.0, tracks: [])
        mixer.clipAction(clip)
        let existing = mixer.existingAction(clip)
        assertEqual("existing.isSome()", "true", existing.isSome(), true)
    }

    func test_mixer_stop_all() {
        let root = Object3D()
        let mixer = AnimationMixer(root)
        let ret = mixer.stopAllAction()
        assertEqual("stopAllAction 返回 mixer", "true", refEq(ret, mixer), true)
    }
}
