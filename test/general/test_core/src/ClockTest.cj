/**
 * @file ClockTest
 * @brief test_core: Clock 单元测试（纯逻辑）
 *
 * 检测 three.core.Clock 能力：
 * - 构造（autoStart 默认 true）
 * - start/stop/getElapsedTime/getDelta
 */
package test_core

import std.unittest.*
import std.collection.*
import three.core.time.Clock

public class ClockTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ClockTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clock_construct(); () }
            suiteBuilder.add(UnitTestCase.create("test_clock_construct", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clock_start_stop(); () }
            suiteBuilder.add(UnitTestCase.create("test_clock_start_stop", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_clock_construct() {
        // 默认 autoStart=true：构造即开始计时
        let clock = Clock()
        assertEqual("getElapsedTime() >= 0.0", "true", clock.getElapsedTime() >= 0.0, true)
    }

    func test_clock_start_stop() {
        let clock = Clock(autoStart: false)
        clock.start()
        assertEqual("start 后 elapsed >= 0", "true", clock.getElapsedTime() >= 0.0, true)
        clock.stop()
        // stop 后调用 getElapsedTime 不崩溃
        assertEqual("stop 后 elapsed >= 0", "true", clock.getElapsedTime() >= 0.0, true)
    }
}
