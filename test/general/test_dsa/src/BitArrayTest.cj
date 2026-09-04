/**
 * @file BitArrayTest
 * @brief test_dsa: BitArray 单元测试
 *
 * 检测 three.infra.dsa.BitArray 能力：
 * - 构造、get/set
 * - setIdxs 批量设置
 * - and/or/not 位运算
 * - equal/cover 比较
 * - copy/assign/clear
 * - toBinaryString
 */
package test_dsa

import std.unittest.*
import three.core.dsa.BitArray

public class BitArrayTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("BitArrayTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_set_get(); () }
            suiteBuilder.add(UnitTestCase.create("test_set_get", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_setIdxs(); () }
            suiteBuilder.add(UnitTestCase.create("test_setIdxs", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_and(); () }
            suiteBuilder.add(UnitTestCase.create("test_and", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_or(); () }
            suiteBuilder.add(UnitTestCase.create("test_or", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_not(); () }
            suiteBuilder.add(UnitTestCase.create("test_not", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_equal(); () }
            suiteBuilder.add(UnitTestCase.create("test_equal", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_cover(); () }
            suiteBuilder.add(UnitTestCase.create("test_cover", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_copy_assign(); () }
            suiteBuilder.add(UnitTestCase.create("test_copy_assign", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clear(); () }
            suiteBuilder.add(UnitTestCase.create("test_clear", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_set_get() {
        let ba = BitArray(15, value: false)
        // 初始：只有 bit 15 为 true（构造器 index=15, value=true → 但 value=false 不设置）
        // 实际上构造器 BitArray(15, value: false) 会扩容到 index=15，但不设置
        assertEqual("bit 0 default false", "false", ba.get(0), false)
        ba.set(3, value: true)
        assertEqual("bit 3 set true", "true", ba.get(3), true)
        ba.set(3, value: false)
        assertEqual("bit 3 clear false", "false", ba.get(3), false)
        // 越界访问返回 false
        assertEqual("bit 100 out of range", "false", ba.get(100), false)
    }

    func test_setIdxs() {
        let ba = BitArray(20, value: false)
        ba.setIdxs([1, 3, 5, 7], value: true)
        assertEqual("bit 1", "true", ba.get(1), true)
        assertEqual("bit 3", "true", ba.get(3), true)
        assertEqual("bit 5", "true", ba.get(5), true)
        assertEqual("bit 7", "true", ba.get(7), true)
        assertEqual("bit 0 not set", "false", ba.get(0), false)
        assertEqual("bit 2 not set", "false", ba.get(2), false)
    }

    func test_and() {
        let ba1 = BitArray(7, value: false)
        ba1.setIdxs([0, 1, 2, 3], value: true)
        let ba2 = BitArray(7, value: false)
        ba2.setIdxs([2, 3, 4, 5], value: true)
        ba1.and(ba2)
        assertEqual("and bit 0", "false", ba1.get(0), false)
        assertEqual("and bit 1", "false", ba1.get(1), false)
        assertEqual("and bit 2", "true", ba1.get(2), true)
        assertEqual("and bit 3", "true", ba1.get(3), true)
        assertEqual("and bit 4", "false", ba1.get(4), false)
    }

    func test_or() {
        let ba1 = BitArray(7, value: false)
        ba1.setIdxs([0, 1], value: true)
        let ba2 = BitArray(7, value: false)
        ba2.setIdxs([2, 3], value: true)
        ba1.or(ba2)
        assertEqual("or bit 0", "true", ba1.get(0), true)
        assertEqual("or bit 1", "true", ba1.get(1), true)
        assertEqual("or bit 2", "true", ba1.get(2), true)
        assertEqual("or bit 3", "true", ba1.get(3), true)
        assertEqual("or bit 4", "false", ba1.get(4), false)
    }

    func test_not() {
        let ba = BitArray(7, value: false)
        ba.setIdxs([0, 2, 4, 6], value: true)
        ba.not()
        assertEqual("not bit 0", "false", ba.get(0), false)
        assertEqual("not bit 1", "true", ba.get(1), true)
        assertEqual("not bit 2", "false", ba.get(2), false)
        assertEqual("not bit 3", "true", ba.get(3), true)
    }

    func test_equal() {
        let ba1 = BitArray(7, value: false)
        ba1.setIdxs([1, 3, 5], value: true)
        let ba2 = BitArray(7, value: false)
        ba2.setIdxs([1, 3, 5], value: true)
        let ba3 = BitArray(7, value: false)
        ba3.setIdxs([1, 3], value: true)
        assertEqual("equal same", "true", ba1.equal(ba2), true)
        assertEqual("not equal diff", "false", ba1.equal(ba3), false)
    }

    func test_cover() {
        let ba1 = BitArray(7, value: false)
        ba1.setIdxs([0, 1, 2, 3], value: true)
        let ba2 = BitArray(7, value: false)
        ba2.setIdxs([1, 2], value: true)
        let ba3 = BitArray(7, value: false)
        ba3.setIdxs([4, 5], value: true)
        // ba1 覆盖 ba2（ba1 的 1 位包含 ba2 的 1 位）
        assertEqual("ba1 covers ba2", "true", ba1.cover(ba2), true)
        // ba1 不覆盖 ba3
        assertEqual("ba1 not covers ba3", "false", ba1.cover(ba3), false)
    }

    func test_copy_assign() {
        let ba1 = BitArray(7, value: false)
        ba1.setIdxs([1, 3, 5], value: true)
        let ba2 = ba1.copy()
        assertEqual("copy equal", "true", ba1.equal(ba2), true)
        // 修改 ba2 不影响 ba1
        ba2.set(1, value: false)
        assertEqual("copy independent", "false", ba1.equal(ba2), false)

        let ba3 = BitArray(7, value: false)
        ba3.assign(ba1)
        assertEqual("assign equal", "true", ba1.equal(ba3), true)
    }

    func test_clear() {
        let ba = BitArray(7, value: false)
        ba.setIdxs([0, 2, 4, 6], value: true)
        ba.clear()
        assertEqual("length 0 after clear", "0", ba.length, 0)
    }
}
