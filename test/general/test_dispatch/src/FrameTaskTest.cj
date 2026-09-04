/**
 * @file FrameTaskTest
 * @brief test_dispatch: FrameTask 单元测试
 *
 * 检测 three.infra.dispatch.FrameTask 能力：
 * - CONSUME 模式：逐个消耗参数，参数空时 finished
 * - LOOP 模式：循环遍历参数，callback 返回 false 时停止
 * - ONCE 模式：执行一次后 finished
 * - HeapNode 实现：lessThan 按优先级比较，index 追踪
 * - notEmpty / run / reset / paused / executionCount
 */
package test_dispatch

import std.unittest.*
import std.collection.*
import three.core.dsa.CircularQueue
import three.core.dispatch.FrameTask
import three.core.dispatch.FrameTaskMode
import three.core.dispatch.FrameTaskContext

public class FrameTaskTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("FrameTaskTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_consume_mode(); () }
            suiteBuilder.add(UnitTestCase.create("test_consume_mode", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_loop_mode(); () }
            suiteBuilder.add(UnitTestCase.create("test_loop_mode", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_once_mode(); () }
            suiteBuilder.add(UnitTestCase.create("test_once_mode", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_heap_node_lessThan(); () }
            suiteBuilder.add(UnitTestCase.create("test_heap_node_lessThan", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_notEmpty_and_finished(); () }
            suiteBuilder.add(UnitTestCase.create("test_notEmpty_and_finished", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_reset(); () }
            suiteBuilder.add(UnitTestCase.create("test_reset", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_execution_count(); () }
            suiteBuilder.add(UnitTestCase.create("test_execution_count", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// CONSUME 模式：逐个消耗参数，参数空时 finished
    /// 注意：CircularQueue.remove() 是 LIFO（尾部出队），消费顺序与入队顺序相反
    func test_consume_mode() {
        let params = CircularQueue<Array<Any>>()
        params.add([1])
        params.add([2])
        params.add([3])

        let results = ArrayList<Int64>()
        let task = FrameTask(
            1,
            FrameTaskMode.CONSUME,
            1,
            { ctx: FrameTaskContext =>
                match (ctx.args[0] as Int64) {
                    case Some(v) => results.add(v)
                    case None => ()
                }
                return true
            },
            params
        )

        assertEqual("notEmpty initially", "true", task.notEmpty(), true)
        assertEqual("not finished initially", "false", task.finished, false)

        // 第 1 次 run：LIFO 消耗 [3]
        let cont1 = task.run(16.0)
        assertEqual("consume run 1 continue", "true", cont1, true)
        assertEqual("results size 1", "1", results.size, 1)
        assertEqual("consume value 3", "3", results[0], 3)

        // 第 2 次 run：LIFO 消耗 [2]
        let cont2 = task.run(16.0)
        assertEqual("consume run 2 continue", "true", cont2, true)
        assertEqual("results size 2", "2", results.size, 2)
        assertEqual("consume value 2", "2", results[1], 2)

        // 第 3 次 run：LIFO 消耗 [1]，参数空后返回 false（但 finished 尚未设置）
        let cont3 = task.run(16.0)
        assertEqual("consume run 3 no more args", "false", cont3, false)
        assertEqual("results size 3", "3", results.size, 3)
        assertEqual("consume value 1", "1", results[2], 1)
        // 消耗最后参数后 notEmpty 为 false（params 空），但 finished 需下次 run 才设置
        assertEqual("notEmpty false after params empty", "false", task.notEmpty(), false)
        assertEqual("not finished yet (need extra run)", "false", task.finished, false)

        // 第 4 次 run：触发 params.isEmpty() 检查，设置 finished
        let cont4 = task.run(16.0)
        assertEqual("consume run 4 finished", "false", cont4, false)
        assertEqual("finished after extra run", "true", task.finished, true)
    }

    /// LOOP 模式：循环遍历参数，callback 返回 false 时停止本帧
    func test_loop_mode() {
        let params = CircularQueue<Array<Any>>()
        params.add([10])
        params.add([20])

        let count = Box<Int64>(0)
        let task = FrameTask(
            2,
            FrameTaskMode.LOOP,
            1,
            { ctx: FrameTaskContext =>
                count.value = count.value + 1
                // 执行 4 次后停止本帧
                return count.value < 4
            },
            params
        )

        assertEqual("notEmpty loop", "true", task.notEmpty(), true)

        // 循环执行：callback 返回 false 后 run 也返回 false
        var cont = true
        while (cont) {
            cont = task.run(16.0)
        }
        assertEqual("loop executed 4 times", "4", count.value, 4)
        assertEqual("not finished (loop can continue next frame)", "false", task.finished, false)
    }

    /// ONCE 模式：执行一次后 finished
    func test_once_mode() {
        let executed = Box<Bool>(false)
        let params = CircularQueue<Array<Any>>()
        let task = FrameTask(
            3,
            FrameTaskMode.ONCE,
            1,
            { ctx: FrameTaskContext =>
                executed.value = true
                return true
            },
            params
        )

        assertEqual("notEmpty ONCE before run", "true", task.notEmpty(), true)
        let cont = task.run(16.0)
        assertEqual("ONCE returns false", "false", cont, false)
        assertEqual("ONCE executed", "true", executed.value, true)
        assertEqual("ONCE finished", "true", task.finished, true)
        assertEqual("notEmpty ONCE after run", "false", task.notEmpty(), false)
    }

    /// HeapNode lessThan：priority 小的更优先
    func test_heap_node_lessThan() {
        let params = CircularQueue<Array<Any>>()
        let t1 = FrameTask(1, FrameTaskMode.ONCE, 5, { _ => true }, params)
        let t2 = FrameTask(2, FrameTaskMode.ONCE, 2, { _ => true }, params)
        let t3 = FrameTask(3, FrameTaskMode.ONCE, 10, { _ => true }, params)

        // lessThan: this.priority < other.priority → this 更优先
        assertEqual("t2 < t1 (priority 2 < 5)", "true", t2.lessThan(t1), true)
        assertEqual("t1 < t3 (priority 5 < 10)", "true", t1.lessThan(t3), true)
        assertEqual("t3 not < t1 (priority 10 > 5)", "false", t3.lessThan(t1), false)

        // index 初始值
        assertEqual("initial index -1", "-1", t1.index, -1)
        t1.index = 0
        assertEqual("index set to 0", "0", t1.index, 0)
    }

    /// notEmpty 与 finished 状态
    /// 注意：CONSUME 消耗最后参数后 finished 尚未设置，需再次 run() 触发
    func test_notEmpty_and_finished() {
        let params = CircularQueue<Array<Any>>()
        params.add([1])
        let task = FrameTask(
            10,
            FrameTaskMode.CONSUME,
            1,
            { _ => true },
            params
        )

        assertEqual("notEmpty before run", "true", task.notEmpty(), true)
        assertEqual("not finished before run", "false", task.finished, false)

        // 消耗唯一参数，run 返回 false 但 finished 尚未设置
        task.run(16.0)
        assertEqual("notEmpty false after consume", "false", task.notEmpty(), false)
        assertEqual("not finished yet", "false", task.finished, false)

        // 再次 run 触发 params.isEmpty() 检查，设置 finished
        task.run(16.0)
        assertEqual("finished after extra run", "true", task.finished, true)

        // CONSUME 空参数：首次 run 即触发 params.isEmpty()
        let emptyParams = CircularQueue<Array<Any>>()
        let emptyTask = FrameTask(
            11,
            FrameTaskMode.CONSUME,
            1,
            { _ => true },
            emptyParams
        )
        assertEqual("notEmpty false on empty CONSUME", "false", emptyTask.notEmpty(), false)
    }

    /// reset 清空状态
    /// 注意：CONSUME 消耗最后参数后 finished 尚未设置，需再次 run() 触发
    func test_reset() {
        let params = CircularQueue<Array<Any>>()
        params.add([1])
        let task = FrameTask(
            20,
            FrameTaskMode.CONSUME,
            1,
            { _ => true },
            params
        )

        // 消耗参数后，再 run 一次触发 finished
        task.run(16.0)
        task.run(16.0)
        assertEqual("finished before reset", "true", task.finished, true)

        task.reset()
        assertEqual("not finished after reset", "false", task.finished, false)
        assertEqual("executionCount 0 after reset", "0", task.executionCount, 0)
        assertEqual("index -1 after reset", "-1", task.index, -1)
        assertEqual("not paused after reset", "false", task.paused, false)
        // params 被清空，所以 CONSUME 模式 notEmpty 为 false
        assertEqual("notEmpty false after reset (params cleared)", "false", task.notEmpty(), false)
    }

    /// executionCount 递增
    func test_execution_count() {
        let params = CircularQueue<Array<Any>>()
        params.add([1])
        params.add([2])
        let task = FrameTask(
            30,
            FrameTaskMode.CONSUME,
            1,
            { _ => true },
            params
        )

        assertEqual("count 0", "0", task.executionCount, 0)
        task.run(16.0)
        assertEqual("count 1", "1", task.executionCount, 1)
        task.run(16.0)
        assertEqual("count 2", "2", task.executionCount, 2)
    }
}
