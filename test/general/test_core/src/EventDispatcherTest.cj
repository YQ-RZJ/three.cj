/**
 * @file EventDispatcherTest
 * @brief test_core: EventDispatcher 单元测试（纯逻辑）
 *
 * 检测 three.core.EventDispatcher 能力：
 * - addEventListener / hasEventListener / removeEventListener
 * - dispatchEvent（监听器触发）
 */
package test_core

import std.unittest.*
import std.collection.*
import std.core.*
import three.core.event.EventDispatcher
import three.core.event.Event

public class EventDispatcherTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("EventDispatcherTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_event_add_remove(); () }
            suiteBuilder.add(UnitTestCase.create("test_event_add_remove", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_event_dispatch(); () }
            suiteBuilder.add(UnitTestCase.create("test_event_dispatch", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_event_add_remove() {
        let dispatcher = EventDispatcher()
        let handle = dispatcher.addEventListener("test", { ev => () })
        assertEqual("hasEventListener true", "true", dispatcher.hasEventListener("test"), true)
        dispatcher.removeEventListener("test", handle)
        assertEqual("hasEventListener false", "true", dispatcher.hasEventListener("test"), false)
    }

    func test_event_dispatch() {
        let dispatcher = EventDispatcher()
        let fired = Box(false)
        dispatcher.addEventListener("test", { ev => fired.value = true })
        dispatcher.dispatchEvent(Event("test"))
        assertEqual("listener fired", "true", fired.value, true)
    }
}
