/**
 * @file ConstantsTest
 * @brief 迁移 three.js test/unit/src/constants.tests.js 的 default values 断言
 *
 * 对照 JS QUnit:
 *   assert.equal( Constants.CullFaceNone, 0 )
 *   assert.equal( Constants.FrontSide, 0 ); BackSide=1; DoubleSide=2
 *   assert.equal( Constants.NoBlending, 0 )
 *   assert.equal( Constants.AddEquation, 100 ) 等
 */
package test_j_core

import std.unittest.*
import three.utils.constants.*

public class ConstantsTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ConstantsTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_default_values(); () }
            suiteBuilder.add(UnitTestCase.create("test_default_values", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_default_values() {
        // 对照 JS constants.tests.js default values 断言
        assertEqual("CullFaceNone=0", "true", (CullFaceNone == 0).toString(), "true")
        assertEqual("FrontSide=0", "true", (FrontSide == 0).toString(), "true")
        assertEqual("BackSide=1", "true", (BackSide == 1).toString(), "true")
        assertEqual("DoubleSide=2", "true", (DoubleSide == 2).toString(), "true")
        assertEqual("NoBlending=0", "true", (NoBlending == 0).toString(), "true")
        assertEqual("AddEquation=100", "true", (AddEquation == 100).toString(), "true")
        assertEqual("SubtractEquation=101", "true", (SubtractEquation == 101).toString(), "true")
    }
}
