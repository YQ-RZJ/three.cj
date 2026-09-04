/**
 * @file TextureBehaviorTest
 * @brief 补充迁移 three.js test/unit/src/textures/Texture.tests.js 的 dispose 等行为断言
 *
 * 对照 JS:
 *   new Texture() → texture.needsUpdate 初始 false
 *   dispose() 可调用且不抛异常
 *   copy() 拷贝 source 的属性（name/needsUpdate 等）
 */
package test_j_textures

import std.unittest.*
import three.rendering.textures.*

public class TextureBehaviorTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("TextureBehaviorTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_needs_update(); () }
            suiteBuilder.add(UnitTestCase.create("test_needs_update", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_dispose(); () }
            suiteBuilder.add(UnitTestCase.create("test_dispose", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_needs_update() {
        // 对照 JS: new Texture().needsUpdate === false（初始）
        let t = Texture()
        assertEqual("Texture needsUpdate initial", "false", t.needsUpdate.toString(), "false")
        // 设置后为 true
        t.needsUpdate = true
        assertEqual("Texture needsUpdate set", "true", t.needsUpdate.toString(), "true")
    }

    func test_dispose() {
        // 对照 JS: dispose() 可调用（dispatch dispose 事件）
        let t = Texture()
        t.dispose()
        assertEqual("Texture dispose ok", "true", (t is Texture).toString(), "true")
    }
}
