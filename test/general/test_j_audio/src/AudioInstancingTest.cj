/**
 * @file AudioInstancingTest
 * @brief 迁移 three.js test/unit/src/audio 目录 tests.js 的 Instancing 断言
 *
 * 对照 JS:
 *   new AudioListener() → 可实例化
 *   new Audio() → 可实例化（需 listener）
 *   new PositionalAudio() → 可实例化（需 listener）
 */
package test_j_audio

import std.unittest.*
import three.audio.*
import three.audio.listener.*
import three.audio.source.*

public class AudioInstancingTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("AudioInstancingTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_instancing(); () }
            suiteBuilder.add(UnitTestCase.create("test_instancing", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_instancing() {
        // 对照 JS QUnit: new AudioListener() / new Audio() / new PositionalAudio() 可实例化
        let listener = AudioListener()
        assertEqual("AudioListener kind", "AudioListener", listener.kind, "AudioListener")

        let audio = Audio(listener: listener)
        assertEqual("Audio kind", "Audio", audio.kind, "Audio")

        let positional = PositionalAudio(listener: listener)
        assertEqual("PositionalAudio kind", "PositionalAudio", positional.kind, "PositionalAudio")
    }
}
