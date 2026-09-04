/**
 * @file SceneBehaviorTest
 * @brief 补充迁移 three.js test/unit/src/scenes/Scene.tests.js 的 copy 断言
 *
 * 对照 JS:
 *   const scene = new Scene(); scene.background = new Color();
 *   const copy = scene.copy(scene2); copy 拷贝背景等属性
 */
package test_j_scenes

import std.unittest.*
import three.scene.scenegraph.*
import three.core.math.Color

public class SceneBehaviorTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("SceneBehaviorTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_copy(); () }
            suiteBuilder.add(UnitTestCase.create("test_copy", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_copy() {
        // 对照 JS: scene.copy(source) 拷贝 background 属性
        let src = Scene()
        src.background = Some(Color(0x335577))
        let dst = Scene()
        dst.copy(src, true)
        match (dst.background) {
            case Some(c) => match (c) {
                case col: Color => assertEqual("copy background", "true", (col.getHex() == 0x335577u32).toString(), "true")
                case _ => assertEqual("copy background", "true", "false", "true")
            }
            case None => assertEqual("copy background", "true", "false", "true")
        }
    }
}
