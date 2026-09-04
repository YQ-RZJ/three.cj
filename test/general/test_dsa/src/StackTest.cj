/**
 * @file StackTest
 * @brief test_dsa: Stack 单元测试
 *
 * 检测 three.infra.dsa.Stack 能力：
 * - add/remove/peek（LIFO 顺序）
 * - size/isEmpty/clear
 * - contains
 */
package test_dsa

import std.unittest.*
import three.core.dsa.Stack

public class StackTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("StackTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_lifo_order(); () }
            suiteBuilder.add(UnitTestCase.create("test_lifo_order", configuration: caseConfig, body: testFunc))
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

        return suiteBuilder.build()
    }

    func test_lifo_order() {
        let s = Stack<Int64>()
        s.add(1)
        s.add(2)
        s.add(3)
        assertEqual("pop 1", "3", s.remove().getOrThrow(), 3)
        assertEqual("pop 2", "2", s.remove().getOrThrow(), 2)
        assertEqual("pop 3", "1", s.remove().getOrThrow(), 1)
    }

    func test_peek() {
        let s = Stack<Int64>()
        s.add(10)
        s.add(20)
        assertEqual("peek top", "20", s.peek().getOrThrow(), 20)
        assertEqual("size unchanged", "2", s.size, 2)
    }

    func test_size_isEmpty_clear() {
        let s = Stack<Int64>()
        assertEqual("empty", "true", s.isEmpty(), true)
        s.add(1)
        s.add(2)
        assertEqual("size 2", "2", s.size, 2)
        s.clear()
        assertEqual("empty after clear", "true", s.isEmpty(), true)
    }

    func test_contains() {
        let s = Stack<Int64>()
        s.add(10)
        s.add(20)
        assertEqual("contains 10", "true", s.contains(10), true)
        assertEqual("contains 20", "true", s.contains(20), true)
        assertEqual("not contains 99", "false", s.contains(99), false)
    }

    func test_empty_remove_peek() {
        let s = Stack<Int64>()
        assertEqual("remove empty", "true", s.remove().isNone(), true)
        assertEqual("peek empty", "true", s.peek().isNone(), true)
    }
}
