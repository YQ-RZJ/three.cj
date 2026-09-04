/**
 * @file UniformsUtilsTest
 * @brief 迁移 three.js test/unit/src/renderers/shaders/UniformsUtils.tests.js 核心断言
 *
 * 对照 JS: UniformsUtils.merge( base, extra ) 合并 uniform 数组
 * 仓颉侧 UniformsUtils.merge 实现于 ShaderLibs.cj。
 */
package test_j_renderers

import std.unittest.*
import three.rendering.shaders.UniformsUtils

public class UniformsUtilsTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("UniformsUtilsTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_merge(); () }
            suiteBuilder.add(UnitTestCase.create("test_merge", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_merge() {
        // 对照 JS: merge(base, extra) → base 在前 extra 在后
        // 注：Float64.toString() 输出 6 位小数（1.000000），故用数值比较断言
        let base = [1.0, 2.0]
        let extra = [3.0, 4.0]
        let merged = UniformsUtils.merge(base, extra)
        assertEqual("merge size", "4", merged.size.toString(), "4")
        assertEqual("merge[0]", "true", (merged[0] == 1.0).toString(), "true")
        assertEqual("merge[1]", "true", (merged[1] == 2.0).toString(), "true")
        assertEqual("merge[2]", "true", (merged[2] == 3.0).toString(), "true")
        assertEqual("merge[3]", "true", (merged[3] == 4.0).toString(), "true")
    }
}
