/**
 * @file MaterialBehaviorTest
 * @brief 补充迁移 three.js test/unit/src/materials/Material.tests.js 的 dispose/type 断言
 *
 * 对照 JS:
 *   new Material() → object.type === 'Material'
 *   dispose() 可调用
 */
package test_j_materials

import std.unittest.*
import three.rendering.materials.*

public class MaterialBehaviorTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("MaterialBehaviorTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_type_dispose(); () }
            suiteBuilder.add(UnitTestCase.create("test_type_dispose", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_type_dispose() {
        // 对照 JS: new Material() → type 'Material'（仓颉用 kind）
        let m = Material()
        assertEqual("Material kind", "Material", m.kind, "Material")
        // dispose 可调用
        m.dispose()
        assertEqual("Material dispose ok", "true", (m is Material).toString(), "true")
    }
}
