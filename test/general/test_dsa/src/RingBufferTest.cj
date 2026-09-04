/**
 * @file RingBufferTest
 * @brief test_dsa: RingBuffer 单元测试
 *
 * 检测 three.infra.dsa.RingBuffer 能力：
 * - add/remove/peek（FIFO 顺序）
 * - capacity/size/isEmpty/isFull
 * - 覆盖模式（overwrite=true）
 * - 非覆盖模式（overwrite=false）
 * - get/peekLast
 * - clear
 */
package test_dsa

import std.unittest.*
import three.core.dsa.RingBuffer

public class RingBufferTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("RingBufferTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_fifo_order(); () }
            suiteBuilder.add(UnitTestCase.create("test_fifo_order", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_capacity_size_isEmpty_isFull(); () }
            suiteBuilder.add(UnitTestCase.create("test_capacity_size_isEmpty_isFull", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_overwrite_mode(); () }
            suiteBuilder.add(UnitTestCase.create("test_overwrite_mode", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_no_overwrite_mode(); () }
            suiteBuilder.add(UnitTestCase.create("test_no_overwrite_mode", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_peek_peekLast(); () }
            suiteBuilder.add(UnitTestCase.create("test_peek_peekLast", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_get(); () }
            suiteBuilder.add(UnitTestCase.create("test_get", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clear(); () }
            suiteBuilder.add(UnitTestCase.create("test_clear", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_fifo_order() {
        let rb = RingBuffer<Int64>(3, overwrite: true)
        rb.add(10)
        rb.add(20)
        rb.add(30)
        assertEqual("remove 1", "10", rb.remove().getOrThrow(), 10)
        assertEqual("remove 2", "20", rb.remove().getOrThrow(), 20)
        assertEqual("remove 3", "30", rb.remove().getOrThrow(), 30)
    }

    func test_capacity_size_isEmpty_isFull() {
        let rb = RingBuffer<Int64>(2, overwrite: false)
        assertEqual("capacity", "2", rb.capacity, 2)
        assertEqual("empty initially", "true", rb.isEmpty(), true)
        rb.add(1)
        assertEqual("size 1", "1", rb.size, 1)
        assertEqual("not full", "false", rb.isFull(), false)
        rb.add(2)
        assertEqual("size 2", "2", rb.size, 2)
        assertEqual("full", "true", rb.isFull(), true)
    }

    /// 覆盖模式下，满时 add 会覆盖最旧元素
    func test_overwrite_mode() {
        let rb = RingBuffer<Int64>(3, overwrite: true)
        rb.add(1)
        rb.add(2)
        rb.add(3)
        // 已满，再 add 将覆盖最旧的 1
        rb.add(4)
        assertEqual("size still 3", "3", rb.size, 3)
        assertEqual("first is 2 (1 overwritten)", "2", rb.remove().getOrThrow(), 2)
        assertEqual("second is 3", "3", rb.remove().getOrThrow(), 3)
        assertEqual("third is 4", "4", rb.remove().getOrThrow(), 4)
    }

    /// 非覆盖模式下，满时 add 返回 false
    func test_no_overwrite_mode() {
        let rb = RingBuffer<Int64>(2, overwrite: false)
        let r1 = rb.add(1)
        let r2 = rb.add(2)
        let r3 = rb.add(3) // 满了，应返回 false
        assertEqual("add 1 success", "true", r1, true)
        assertEqual("add 2 success", "true", r2, true)
        assertEqual("add 3 fail (full)", "false", r3, false)
        assertEqual("size still 2", "2", rb.size, 2)
    }

    func test_peek_peekLast() {
        let rb = RingBuffer<Int64>(5, overwrite: true)
        rb.add(10)
        rb.add(20)
        rb.add(30)
        assertEqual("peek first", "10", rb.peek().getOrThrow(), 10)
        assertEqual("peekLast", "30", rb.peekLast().getOrThrow(), 30)
        // peek 不影响 size
        assertEqual("size unchanged", "3", rb.size, 3)
    }

    func test_get() {
        let rb = RingBuffer<Int64>(5, overwrite: true)
        rb.add(100)
        rb.add(200)
        rb.add(300)
        assertEqual("get(0)", "100", rb.get(0).getOrThrow(), 100)
        assertEqual("get(1)", "200", rb.get(1).getOrThrow(), 200)
        assertEqual("get(2)", "300", rb.get(2).getOrThrow(), 300)
        assertEqual("get out of range", "true", rb.get(5).isNone(), true)
    }

    func test_clear() {
        let rb = RingBuffer<Int64>(3, overwrite: true)
        rb.add(1)
        rb.add(2)
        rb.clear()
        assertEqual("empty after clear", "true", rb.isEmpty(), true)
        assertEqual("size 0", "0", rb.size, 0)
    }
}
