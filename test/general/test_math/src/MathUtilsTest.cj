/**
 * @file MathUtilsTest
 * @brief test_math: MathUtils 静态工具单元测试
 */
package test_math

import std.unittest.*
import std.math.*
import three.core.math.*
import three.core.math.MathUtils

public class MathUtilsTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("MathUtilsTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clamp_lerp(); () }
            suiteBuilder.add(UnitTestCase.create("test_clamp_lerp", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_pow2(); () }
            suiteBuilder.add(UnitTestCase.create("test_pow2", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_angle_convert(); () }
            suiteBuilder.add(UnitTestCase.create("test_angle_convert", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_euclidean_modulo(); () }
            suiteBuilder.add(UnitTestCase.create("test_euclidean_modulo", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_clamp_lerp() {
        assertEqual("clamp 1.5→1.0", "true", MathUtils.clamp(1.5, 0.0, 1.0) == 1.0, true)
        assertEqual("clamp -0.5→0.0", "true", MathUtils.clamp(-0.5, 0.0, 1.0) == 0.0, true)
        assertEqual("lerp 0.5 半程", "true", MathUtils.lerp(0.0, 10.0, 0.5) == 5.0, true)
        assertEqual("inverseLerp 中点 0.5", "true", MathUtils.inverseLerp(0.0, 10.0, 5.0) == 0.5, true)
    }

    func test_pow2() {
        assertEqual("isPowerOfTwo 4", "true", MathUtils.isPowerOfTwo(4), true)
        assertEqual("isPowerOfTwo 6", "true", !MathUtils.isPowerOfTwo(6), true)
        assertEqual("ceilPowerOfTwo 7 → 8", "true", MathUtils.ceilPowerOfTwo(7) == 8, true)
        assertEqual("floorPowerOfTwo 7 → 4", "true", MathUtils.floorPowerOfTwo(7) == 4, true)
    }

    func test_angle_convert() {
        assertEqual("degToRad 180 → π", "true", abs(MathUtils.degToRad(180.0) - PI) < 1e-9, true)
        assertEqual("radToDeg π → 180", "true", abs(MathUtils.radToDeg(PI) - 180.0) < 1e-9, true)
        // DEG2RAD 常量
        assertEqual("DEG2RAD 精度", "true", abs(DEG2RAD - PI / 180.0) < 1e-15, true)
    }

    func test_euclidean_modulo() {
        // 欧几里得取模：结果恒非负
        assertEqual("euclideanModulo(-1, 4) == 3", "true", MathUtils.euclideanModulo(-1, 4) == 3, true)
        assertEqual("euclideanModulo(7, 4) == 3", "true", MathUtils.euclideanModulo(7, 4) == 3, true)
        assertEqual("euclideanModulo 浮点", "true", MathUtils.euclideanModulo(-2.5, 2.0) == 1.5, true)
    }
}
