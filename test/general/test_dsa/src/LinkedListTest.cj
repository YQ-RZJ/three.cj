/**
 * @file LinkedListTest
 * @brief test_dsa: LinkedList 单元测试
 *
 * 检测 three.infra.dsa.LinkedList 能力：
 * - addFirst/addLast/removeFirst/removeLast
 * - addBefore/addAfter/remove
 * - first/last/size/isEmpty/clear
 * - toArray/iterator
 */
package test_dsa

import std.unittest.*
import three.core.dsa.LinkedList

public class LinkedListTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("LinkedListTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_addFirst_addLast(); () }
            suiteBuilder.add(UnitTestCase.create("test_addFirst_addLast", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_removeFirst_removeLast(); () }
            suiteBuilder.add(UnitTestCase.create("test_removeFirst_removeLast", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_addBefore_addAfter(); () }
            suiteBuilder.add(UnitTestCase.create("test_addBefore_addAfter", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_remove_node(); () }
            suiteBuilder.add(UnitTestCase.create("test_remove_node", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_size_isEmpty_clear(); () }
            suiteBuilder.add(UnitTestCase.create("test_size_isEmpty_clear", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_toArray(); () }
            suiteBuilder.add(UnitTestCase.create("test_toArray", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_empty_remove_returns_none(); () }
            suiteBuilder.add(UnitTestCase.create("test_empty_remove_returns_none", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_addFirst_addLast() {
        let list = LinkedList<Int64>()
        list.addLast(1)
        list.addLast(2)
        list.addFirst(0)
        assertEqual("first", "0", list.first.getOrThrow(), 0)
        assertEqual("last", "2", list.last.getOrThrow(), 2)
        assertEqual("size", "3", list.size, 3)
    }

    func test_removeFirst_removeLast() {
        let list = LinkedList<Int64>()
        list.addLast(10)
        list.addLast(20)
        list.addLast(30)
        let first = list.removeFirst().getOrThrow()
        let last = list.removeLast().getOrThrow()
        assertEqual("removeFirst", "10", first, 10)
        assertEqual("removeLast", "30", last, 30)
        assertEqual("size after removes", "1", list.size, 1)
        assertEqual("remaining first==last", "20", list.first.getOrThrow(), 20)
    }

    func test_addBefore_addAfter() {
        let list = LinkedList<Int64>()
        let n2 = list.addLast(2)
        let n1 = list.addBefore(n2, 1)
        let n3 = list.addAfter(n2, 3)
        let arr = list.toArray()
        assertEqual("arr[0]", "1", arr[0], 1)
        assertEqual("arr[1]", "2", arr[1], 2)
        assertEqual("arr[2]", "3", arr[2], 3)
    }

    func test_remove_node() {
        let list = LinkedList<Int64>()
        let n1 = list.addLast(1)
        let n2 = list.addLast(2)
        let n3 = list.addLast(3)
        list.remove(n2)
        assertEqual("size after remove", "2", list.size, 2)
        assertEqual("first", "1", list.first.getOrThrow(), 1)
        assertEqual("last", "3", list.last.getOrThrow(), 3)
    }

    func test_size_isEmpty_clear() {
        let list = LinkedList<Int64>()
        assertEqual("empty", "true", list.isEmpty(), true)
        list.addLast(1)
        assertEqual("not empty", "false", list.isEmpty(), false)
        list.clear()
        assertEqual("empty after clear", "true", list.isEmpty(), true)
        assertEqual("size 0 after clear", "0", list.size, 0)
    }

    func test_toArray() {
        let list = LinkedList<Int64>()
        list.addLast(10)
        list.addLast(20)
        list.addLast(30)
        let arr = list.toArray()
        assertEqual("arr size", "3", arr.size, 3)
        assertEqual("arr[0]", "10", arr[0], 10)
        assertEqual("arr[1]", "20", arr[1], 20)
        assertEqual("arr[2]", "30", arr[2], 30)
    }

    func test_empty_remove_returns_none() {
        let list = LinkedList<Int64>()
        assertEqual("removeFirst on empty", "true", list.removeFirst().isNone(), true)
        assertEqual("removeLast on empty", "true", list.removeLast().isNone(), true)
    }
}
