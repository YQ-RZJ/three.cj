/**
 * @file BinaryHeapTest
 * @brief test_dsa: BinaryHeap 单元测试
 *
 * 检测 three.infra.dsa.BinaryHeap 能力：
 * - 构造、push/pop/top
 * - 堆序性质（最小堆）
 * - remove/update
 * - contains/isEmpty/size/clear
 */
package test_dsa

import std.unittest.*
import std.collection.*
import three.core.dsa.BinaryHeap
import three.core.dsa.HeapNode

/** 测试用堆节点：Int64 值，最小堆 */
class IntHeapNode <: HeapNode {
    let val: Int64
    private var _index: Int64

    init(val: Int64) {
        this.val = val
        this._index = -1
    }

    public mut prop index: Int64 {
        get() { _index }
        set(v) { _index = v }
    }

    public func lessThan(other: HeapNode): Bool {
        let o = other as IntHeapNode
        return this.val < o.getOrThrow().val
    }
}

public class BinaryHeapTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("BinaryHeapTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_push_pop_min(); () }
            suiteBuilder.add(UnitTestCase.create("test_push_pop_min", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_top(); () }
            suiteBuilder.add(UnitTestCase.create("test_top", configuration: caseConfig, body: testFunc))
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
            let testFunc = { => test_remove(); () }
            suiteBuilder.add(UnitTestCase.create("test_remove", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_pop_empty(); () }
            suiteBuilder.add(UnitTestCase.create("test_pop_empty", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// push 后 pop 应按升序出列（最小堆）
    func test_push_pop_min() {
        let heap = BinaryHeap<IntHeapNode>()
        let n5 = IntHeapNode(5)
        let n3 = IntHeapNode(3)
        let n8 = IntHeapNode(8)
        let n1 = IntHeapNode(1)
        let n7 = IntHeapNode(7)
        heap.push(n5)
        heap.push(n3)
        heap.push(n8)
        heap.push(n1)
        heap.push(n7)

        let v1 = heap.pop().getOrThrow().val
        let v2 = heap.pop().getOrThrow().val
        let v3 = heap.pop().getOrThrow().val
        let v4 = heap.pop().getOrThrow().val
        let v5 = heap.pop().getOrThrow().val
        assertEqual("pop order 1", "1", v1, 1)
        assertEqual("pop order 2", "3", v2, 3)
        assertEqual("pop order 3", "5", v3, 5)
        assertEqual("pop order 4", "7", v4, 7)
        assertEqual("pop order 5", "8", v5, 8)
    }

    /// top 返回最小元素但不移除
    func test_top() {
        let heap = BinaryHeap<IntHeapNode>()
        let n5 = IntHeapNode(5)
        let n3 = IntHeapNode(3)
        heap.push(n5)
        heap.push(n3)
        assertEqual("top is min", "3", heap.top().val, 3)
        assertEqual("size unchanged after top", "2", heap.size, 2)
    }

    /// size / isEmpty / clear
    func test_size_isEmpty_clear() {
        let heap = BinaryHeap<IntHeapNode>()
        assertEqual("empty initially", "true", heap.isEmpty(), true)
        assertEqual("size 0", "0", heap.size, 0)
        heap.push(IntHeapNode(1))
        heap.push(IntHeapNode(2))
        assertEqual("size 2", "2", heap.size, 2)
        assertEqual("not empty", "false", heap.isEmpty(), false)
        heap.clear()
        assertEqual("empty after clear", "true", heap.isEmpty(), true)
        assertEqual("size 0 after clear", "0", heap.size, 0)
    }

    /// contains
    func test_contains() {
        let heap = BinaryHeap<IntHeapNode>()
        let n1 = IntHeapNode(1)
        let n2 = IntHeapNode(2)
        heap.push(n1)
        assertEqual("contains pushed node", "true", heap.contains(n1), true)
        assertEqual("not contains unpushed node", "false", heap.contains(n2), false)
        heap.pop()
        assertEqual("not contains after pop", "false", heap.contains(n1), false)
    }

    /// remove 中间元素后堆序仍正确
    func test_remove() {
        let heap = BinaryHeap<IntHeapNode>()
        let n5 = IntHeapNode(5)
        let n3 = IntHeapNode(3)
        let n8 = IntHeapNode(8)
        heap.push(n5)
        heap.push(n3)
        heap.push(n8)
        heap.remove(n5)
        assertEqual("size after remove", "2", heap.size, 2)
        assertEqual("top after remove", "3", heap.top().val, 3)
        let v1 = heap.pop().getOrThrow().val
        let v2 = heap.pop().getOrThrow().val
        assertEqual("pop 1 after remove", "3", v1, 3)
        assertEqual("pop 2 after remove", "8", v2, 8)
    }

    /// 空堆 pop 返回 None
    func test_pop_empty() {
        let heap = BinaryHeap<IntHeapNode>()
        let result = heap.pop()
        assertEqual("pop empty is None", "true", result.isNone(), true)
    }
}
