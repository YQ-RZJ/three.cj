/**
 * @file FrameDispatchTest
 * @brief test_dispatch: FrameDispatch 单元测试
 *
 * 检测 three.infra.dispatch.FrameDispatch 能力：
 * - 构造（maximum 时间预算）
 * - registerTask 返回 ID
 * - 强制队列（priority=0）每帧全部执行
 * - 优先级队列（priority>0）按优先级顺序执行
 * - unregister 取消注册
 * - pause / resume 暂停与恢复
 * - clear 清空所有任务
 * - activeTaskCount / pausedTaskCount
 * - 时间预算限制（priority 任务被延后）
 */
package test_dispatch

import std.unittest.*
import std.collection.*
import three.core.dsa.CircularQueue
import three.core.dispatch.FrameDispatch
import three.core.dispatch.FrameTask
import three.core.dispatch.FrameTaskMode
import three.core.dispatch.FrameTaskContext

public class FrameDispatchTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("FrameDispatchTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_register_and_force_queue(); () }
            suiteBuilder.add(UnitTestCase.create("test_register_and_force_queue", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_priority_queue_order(); () }
            suiteBuilder.add(UnitTestCase.create("test_priority_queue_order", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_unregister(); () }
            suiteBuilder.add(UnitTestCase.create("test_unregister", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_pause_resume(); () }
            suiteBuilder.add(UnitTestCase.create("test_pause_resume", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_clear(); () }
            suiteBuilder.add(UnitTestCase.create("test_clear", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_active_paused_count(); () }
            suiteBuilder.add(UnitTestCase.create("test_active_paused_count", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_once_mode_auto_unregister(); () }
            suiteBuilder.add(UnitTestCase.create("test_once_mode_auto_unregister", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_consume_mode_finish_removes_from_dispatch(); () }
            suiteBuilder.add(UnitTestCase.create("test_consume_mode_finish_removes_from_dispatch", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// 强制队列（priority=0）每帧全部执行
    /// 注意：CircularQueue.remove() 是 LIFO（尾部出队），消费顺序与入队顺序相反
    func test_register_and_force_queue() {
        let dispatch = FrameDispatch(maximum: 100.0)
        let results = ArrayList<Int64>()

        let params = CircularQueue<Array<Any>>()
        params.add([10])
        params.add([20])
        params.add([30])

        let id = dispatch.registerTask(
            FrameTaskMode.CONSUME,
            0, // 强制队列
            { ctx: FrameTaskContext =>
                match (ctx.args[0] as Int64) {
                    case Some(v) => results.add(v)
                    case None => ()
                }
                return true
            },
            params
        )

        assertEqual("id > 0", "true", id > 0, true)

        // 一帧调度应执行全部参数（LIFO 顺序：30, 20, 10）
        dispatch.frameEvent(deltaTime: 16.0)
        assertEqual("force queue consumes all", "3", results.size, 3)
        assertEqual("value 30 (LIFO first)", "30", results[0], 30)
        assertEqual("value 20 (LIFO second)", "20", results[1], 20)
        assertEqual("value 10 (LIFO third)", "10", results[2], 10)
    }

    /// 优先级队列按优先级顺序执行（priority 越小越先执行）
    func test_priority_queue_order() {
        let dispatch = FrameDispatch(maximum: 10000.0) // 大预算，确保全部执行
        let order = ArrayList<Int64>()

        // 注册 3 个 ONCE 任务，优先级分别为 3, 1, 2
        // 期望执行顺序：priority=1 先执行，然后 2，然后 3
        dispatch.registerTask(
            FrameTaskMode.ONCE,
            3,
            { _ => order.add(3); return true },
            CircularQueue<Array<Any>>()
        )
        dispatch.registerTask(
            FrameTaskMode.ONCE,
            1,
            { _ => order.add(1); return true },
            CircularQueue<Array<Any>>()
        )
        dispatch.registerTask(
            FrameTaskMode.ONCE,
            2,
            { _ => order.add(2); return true },
            CircularQueue<Array<Any>>()
        )

        dispatch.frameEvent(deltaTime: 16.0)
        assertEqual("order[0] = 1 (highest priority)", "1", order[0], 1)
        assertEqual("order[1] = 2", "2", order[1], 2)
        assertEqual("order[2] = 3", "3", order[2], 3)
    }

    /// unregister 取消注册后任务不再执行
    func test_unregister() {
        let dispatch = FrameDispatch(maximum: 100.0)
        let count = Box<Int64>(0)

        let params = CircularQueue<Array<Any>>()
        params.add([1])

        let id = dispatch.registerTask(
            FrameTaskMode.LOOP,
            1,
            { _ => count.value = count.value + 1; return count.value < 5 },
            params
        )

        // 第 1 帧执行
        dispatch.frameEvent(deltaTime: 16.0)
        assertEqual("executed in frame 1", "true", count.value > 0, true)

        // 取消注册
        dispatch.unregister(id)

        // 第 2 帧不应再执行
        let countBeforeFrame2 = count.value
        dispatch.frameEvent(deltaTime: 16.0)
        assertEqual("not executed after unregister", "true", count.value == countBeforeFrame2, true)
    }

    /// pause/resume 暂停与恢复
    func test_pause_resume() {
        let dispatch = FrameDispatch(maximum: 100.0)
        let count = Box<Int64>(0)

        let params = CircularQueue<Array<Any>>()
        params.add([1])

        let id = dispatch.registerTask(
            FrameTaskMode.LOOP,
            1,
            { _ => count.value = count.value + 1; return count.value < 3 },
            params
        )

        // 第 1 帧
        dispatch.frameEvent(deltaTime: 16.0)
        assertEqual("executed frame 1", "true", count.value > 0, true)

        // 暂停
        dispatch.pause(id)
        assertEqual("paused count 1", "1", dispatch.pausedTaskCount, 1)

        // 暂停后不执行
        count.value = 0
        dispatch.frameEvent(deltaTime: 16.0)
        assertEqual("not executed while paused", "0", count.value, 0)

        // 恢复
        dispatch.resume(id)
        assertEqual("paused count 0 after resume", "0", dispatch.pausedTaskCount, 0)

        // 恢复后应执行（注册新 ONCE 任务验证调度正常）
        let executed = Box<Bool>(false)
        dispatch.registerTask(
            FrameTaskMode.ONCE,
            1,
            { _ => executed.value = true; return true },
            CircularQueue<Array<Any>>()
        )
        dispatch.frameEvent(deltaTime: 16.0)
        assertEqual("executed after resume", "true", executed.value, true)
    }

    /// clear 清空所有任务
    func test_clear() {
        let dispatch = FrameDispatch(maximum: 100.0)

        dispatch.registerTask(
            FrameTaskMode.ONCE,
            0,
            { _ => return true },
            CircularQueue<Array<Any>>()
        )
        dispatch.registerTask(
            FrameTaskMode.ONCE,
            1,
            { _ => return true },
            CircularQueue<Array<Any>>()
        )

        assertEqual("active tasks before clear > 0", "true", dispatch.activeTaskCount > 0, true)
        dispatch.clear()
        assertEqual("active tasks after clear = 0", "0", dispatch.activeTaskCount, 0)
    }

    /// activeTaskCount / pausedTaskCount
    func test_active_paused_count() {
        let dispatch = FrameDispatch(maximum: 100.0)

        let params = CircularQueue<Array<Any>>()
        params.add([1])

        let id1 = dispatch.registerTask(
            FrameTaskMode.LOOP,
            1,
            { _ => return false },
            params
        )
        let id2 = dispatch.registerTask(
            FrameTaskMode.LOOP,
            2,
            { _ => return false },
            params
        )

        assertEqual("active 2", "2", dispatch.activeTaskCount, 2)
        assertEqual("paused 0", "0", dispatch.pausedTaskCount, 0)

        dispatch.pause(id1)
        assertEqual("active 1 after pause", "1", dispatch.activeTaskCount, 1)
        assertEqual("paused 1", "1", dispatch.pausedTaskCount, 1)

        dispatch.pause(id2)
        assertEqual("active 0 after both paused", "0", dispatch.activeTaskCount, 0)
        assertEqual("paused 2", "2", dispatch.pausedTaskCount, 2)

        dispatch.resume(id1)
        assertEqual("active 1 after resume", "1", dispatch.activeTaskCount, 1)
        assertEqual("paused 1 after resume", "1", dispatch.pausedTaskCount, 1)
    }

    /// ONCE 模式任务执行后自动从调度器移除
    func test_once_mode_auto_unregister() {
        let dispatch = FrameDispatch(maximum: 100.0)
        let executed = Box<Bool>(false)

        dispatch.registerTask(
            FrameTaskMode.ONCE,
            1,
            { _ => executed.value = true; return true },
            CircularQueue<Array<Any>>()
        )

        assertEqual("active 1 before frame", "1", dispatch.activeTaskCount, 1)

        dispatch.frameEvent(deltaTime: 16.0)
        assertEqual("ONCE executed", "true", executed.value, true)
        // ONCE 执行后自动从 idToTask 移除
        assertEqual("active 0 after ONCE frame", "0", dispatch.activeTaskCount, 0)
    }

    /// CONSUME 模式参数消耗完后自动从调度器移除
    func test_consume_mode_finish_removes_from_dispatch() {
        let dispatch = FrameDispatch(maximum: 100.0)

        let params = CircularQueue<Array<Any>>()
        params.add([42])

        dispatch.registerTask(
            FrameTaskMode.CONSUME,
            0, // 强制队列
            { _ => return true },
            params
        )

        assertEqual("active 1 before frame", "1", dispatch.activeTaskCount, 1)

        dispatch.frameEvent(deltaTime: 16.0)
        // 参数消耗完后任务应被移除
        assertEqual("active 0 after consume all", "0", dispatch.activeTaskCount, 0)
    }
}
