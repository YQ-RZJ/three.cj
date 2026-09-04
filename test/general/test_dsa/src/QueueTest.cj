/**
 * @file QueueTest
 * @brief test_dsa: Queue 单元测试
 *
 * 检测 three.infra.dsa.Queue 能力：
 * - add/remove/peek
 * - size/isEmpty/clear
 * - contains
 * - FIFO 顺序
 * - 扩容行为
 */
package test_dsa

import std.unittest.*
import three.core.dsa.Queue

public class QueueTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("QueueTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_fifo_order(); () }
            suiteBuilder.add(UnitTestCase.create("test_fifo_order", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_peek(); () }
            suiteBuilder.add(UnitTestCase.create("test_peek", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_size_isEmpty_clear(); () }
            suiteBuilder.add(UnitTestCase.create("test_size_isEmpty_clear", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_contains(); () }
            suiteBuilder.add(UnitTestCase.create("test_contains", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_empty_remove_peek(); () }
            suiteBuilder.add(UnitTestCase.create("test_empty_remove_peek", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_expand(); () }
            suiteBuilder.add(UnitTestCase.create("test_expand", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_fifo_order() {
        let q = Queue<Int64>(capacity: 4)
        q.add(10)
        q.add(20)
        q.add(30)
        assertEqual("remove 1", "10", q.remove().getOrThrow(), 10)
        assertEqual("remove 2", "20", q.remove().getOrThrow(), 20)
        assertEqual("remove 3", "30", q.remove().getOrThrow(), 30)
    }

    func test_peek() {
        let q = Queue<Int64>()
        q.add(42)
        assertEqual("peek", "42", q.peek().getOrThrow(), 42)
        assertEqual("size unchanged after peek", "1", q.size, 1)
    }

    func test_size_isEmpty_clear() {
        let q = Queue<Int64>()
        assertEqual("empty", "true", q.isEmpty(), true)
        q.add(1)
        q.add(2)
        assertEqual("size 2", "2", q.size, 2)
        q.clear()
        assertEqual("empty after clear", "true", q.isEmpty(), true)
    }

    func test_contains() {
        let q = Queue<Int64>()
        q.add(10)
        q.add(20)
        assertEqual("contains 10", "true", q.contains(10), true)
        assertEqual("contains 20", "true", q.contains(20), true)
        assertEqual("not contains 99", "false", q.contains(99), false)
    }

    func test_empty_remove_peek() {
        let q = Queue<Int64>()
        assertEqual("remove empty", "true", q.remove().isNone(), true)
        assertEqual("peek empty", "true", q.peek().isNone(), true)
    }

    /// 超过初始容量后自动扩容
    func test_expand() {
        let q = Queue<Int64>(capacity: 2)
        q.add(1)
        q.add(2)
        q.add(3) // 触发扩容
        assertEqual("size after expand", "3", q.size, 3)
        assertEqual("remove 1", "1", q.remove().getOrThrow(), 1)
        assertEqual("remove 2", "2", q.remove().getOrThrow(), 2)
        assertEqual("remove 3", "3", q.remove().getOrThrow(), 3)
    }
}
