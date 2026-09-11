/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] FrameTask
 * @brief[zh-cn] 帧任务与执行上下文
 * @explain[zh-cn] FrameTask 是分帧调度的最小执行单元，包含唯一 ID、优先级（用于 BinaryHeap 排序）、执行模式（CONSUME/LOOP/ONCE）、参数队列（ICircularQueue，支持消耗与循环两种取数方式）、回调函数（接收 FrameTaskContext）和耗时统计（lastTime / EWMA 平均耗时）。HeapNode 实现：priority 越小越优先（最小堆），0 表示强制队列。设计要点：params 字段统一为 ICircularQueue 类型，确保 LOOP 模式可直接调用 next()；run(deltaTime) 返回 Bool：true 表示本帧可继续执行；false 表示停止本帧调度；ONCE 模式执行一次后自动标记 finished；耗时用 MonoTime 测量，纳秒转毫秒用 Float64 保留精度。
 *
 * @file[en] FrameTask
 * @brief[en] Frame task and execution context
 * @explain[en] FrameTask is the smallest execution unit for frame-based scheduling, containing a unique ID, priority (for BinaryHeap sorting), execution mode (CONSUME/LOOP/ONCE), parameter queue (ICircularQueue, supporting both consume and cycle retrieval), callback function (receiving FrameTaskContext), and time statistics (lastTime / EWMA average). HeapNode implementation: lower priority value means higher priority (min-heap), 0 means forced queue. Design notes: the params field is unified as ICircularQueue type to ensure LOOP mode can call next() directly; run(deltaTime) returns Bool: true means continue execution this frame; false means stop this frame's scheduling; ONCE mode auto-marks finished after one execution; timing uses MonoTime, nanoseconds to milliseconds converted with Float64 precision.
 */
package three.core.dispatch

import std.collection.*
import std.time.*
import three.core.dsa.*
import three.core.interfaces.*

/**
 * @brief[zh-cn] 帧任务模式
 * @explain[zh-cn] CONSUME: 消耗型，每次 run pop 一个参数执行，参数队列空时自动结束；LOOP: 循环型，每次 run next() 不消耗参数，由 callback 决定何时停止本帧；ONCE: 一次性，执行一次 callback 后自动 unregister，不使用参数队列。
 *
 * @brief[en] Frame task mode
 * @explain[en] CONSUME: consume mode, each run pops one parameter for execution, auto-ends when the parameter queue is empty; LOOP: loop mode, each run calls next() without consuming parameters, callback decides when to stop this frame; ONCE: one-shot mode, executes callback once then auto-unregisters, no parameter queue used.
 */
public enum FrameTaskMode {
    /**
     * @brief[zh-cn] 消耗型：每次 run pop 一个参数执行，参数队列空时自动结束
     *
     * @brief[en] CONSUME: each run pops one parameter for execution, auto-ends when the parameter queue is empty
     */
    | CONSUME
    /**
     * @brief[zh-cn] 循环型：每次 run next() 不消耗参数，由 callback 决定何时停止本帧
     *
     * @brief[en] LOOP: each run calls next() without consuming parameters; the callback decides when to stop this frame
     */
    | LOOP
    /**
     * @brief[zh-cn] 一次性：执行一次 callback 后自动 unregister，不使用参数队列
     *
     * @brief[en] ONCE: executes the callback once then auto-unregisters; no parameter queue used
     */
    | ONCE
}

/**
 * @brief[zh-cn] 帧任务执行上下文
 * @explain[zh-cn] 在 callback 调用时创建，传递任务相关信息：task（当前任务实例）、deltaTime（当前帧间隔时间，毫秒）、idx（任务执行次数计数，从 0 开始递增）、args（本次执行的参数组）。
 *
 * @brief[en] Frame task execution context
 * @explain[en] Created when a callback is invoked, passing task-related information: task (current task instance), deltaTime (current frame interval in milliseconds), idx (execution count, incrementing from 0), args (parameter group for this execution).
 */
public class FrameTaskContext {
    /**
     * @brief[zh-cn] 当前任务
     *
     * @brief[en] Current task
     */
    public let task: FrameTask
    /**
     * @brief[zh-cn] 帧间隔时间（毫秒）
     *
     * @brief[en] Frame interval time (milliseconds)
     */
    public let deltaTime: Float64
    /**
     * @brief[zh-cn] 执行次数计数
     *
     * @brief[en] Execution count
     */
    public let idx: Int64
    /**
     * @brief[zh-cn] 本次执行参数
     *
     * @brief[en] Parameters for this execution
     */
    public let args: Array<Any>

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] task 当前任务
     * deltaTime 帧间隔时间（毫秒）
     * idx 执行次数计数
     * args 本次执行参数
     *
     * @brief[en] Constructor
     * @param[en] task Current task
     * deltaTime Frame interval time (milliseconds)
     * idx Execution count
     * args Parameters for this execution
     */
    public init(task: FrameTask, deltaTime: Float64, idx: Int64, args: Array<Any>) {
        this.task = task
        this.deltaTime = deltaTime
        this.idx = idx
        this.args = args
    }
}

/**
 * @brief[zh-cn] 帧任务
 * @explain[zh-cn] 帧任务，分帧调度的最小执行单元。用法示例：
 * ```
 * let task = FrameTask(
 * id = 1,
 * mode = FrameTaskMode.CONSUME,
 * priority = 1,
 * callback = { ctx =>
 * Logger.info(["FrameTask", "execute idx=${ctx.idx}, args=${ctx.args}"])
 * return true  // 继续执行
 * },
 * params = CircularQueue<Array<Any>>()
 * )
 * task.params.add([1])  // 添加参数组
 * ```
 *
 * @brief[en] Frame task
 * @explain[en] Frame task, the smallest execution unit for frame-based scheduling.
 */
public class FrameTask <: HeapNode {
    /**
     * @brief[zh-cn] 唯一 ID（由调度器分配，调用方不应直接修改）
     *
     * @brief[en] Unique ID (assigned by the dispatcher; callers should not modify it directly)
     */
    public var id: Int64
    /**
     * @brief[zh-cn] 任务模式
     *
     * @brief[en] Task mode
     */
    public let mode: FrameTaskMode
    /**
     * @brief[zh-cn] 优先级，0=强制队列；>0 进入 BinaryHeap 优先级队列，值越小优先级越高
     *
     * @brief[en] Priority: 0=forced queue; >0 enters the BinaryHeap priority queue, lower value means higher priority
     */
    public var priority: Int64
    /**
     * @brief[zh-cn] 是否暂停（暂停时不参与调度，但保留状态）
     *
     * @brief[en] Whether paused (paused tasks are excluded from scheduling but keep their state)
     */
    public var paused: Bool
    /**
     * @brief[zh-cn] 共享值，可在多个 callback 之间共享数据
     *
     * @brief[en] Shared value, can share data among multiple callbacks
     */
    public var shareValue: ?Any
    /**
     * @brief[zh-cn] 回调函数，返回 true 表示本帧继续；false 表示本帧停止
     *
     * @brief[en] Callback function: returning true means continue this frame; false means stop this frame
     */
    public let callback: (FrameTaskContext) -> Bool
    /**
     * @brief[zh-cn] 参数队列
     *
     * @brief[en] Parameter queue
     */
    public let params: ICircularQueue<Array<Any>>

    /**
     * @brief[zh-cn] 执行次数计数
     *
     * @brief[en] Execution count
     */
    private var _idx: Int64
    /**
     * @brief[zh-cn] 最近一次执行耗时（毫秒）
     *
     * @brief[en] Time consumed by the most recent execution (milliseconds)
     */
    private var _lastTime: Float64
    /**
     * @brief[zh-cn] EWMA 平均耗时（毫秒）
     *
     * @brief[en] EWMA average execution time (milliseconds)
     */
    private var _avgTime: Float64
    /**
     * @brief[zh-cn] 是否已完成（参数空或 ONCE 执行完）
     *
     * @brief[en] Whether finished (parameters empty or ONCE executed once)
     */
    private var _finished: Bool
    /**
     * @brief[zh-cn] 在 BinaryHeap 中的索引，-1 表示不在堆中
     *
     * @brief[en] Index in the BinaryHeap, -1 means not in the heap
     */
    private var _index: Int64

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] id 唯一 ID，由调度器分配
     * mode 任务模式
     * priority 优先级，0=强制队列；>0 优先级队列
     * callback 回调函数
     * params 参数队列
     * shareValue 共享值（可选）
     *
     * @brief[en] Constructor
     * @param[en] id Unique ID, assigned by the dispatcher
     * mode Task mode
     * priority Priority, 0=forced queue; >0=priority queue
     * callback Callback function
     * params Parameter queue
     * shareValue Shared value (optional)
     */
    public init(
        id: Int64,
        mode: FrameTaskMode,
        priority: Int64,
        callback: (FrameTaskContext) -> Bool,
        params: ICircularQueue<Array<Any>>,
        shareValue!: ?Any = None
    ) {
        this.id = id
        this.mode = mode
        this.priority = priority
        this.callback = callback
        this.params = params
        this.shareValue = shareValue
        this.paused = false
        this._idx = 0
        this._lastTime = 0.0
        this._avgTime = 0.0
        this._finished = false
        this._index = -1
    }

    // ===== HeapNode 实现 =====

    /**
     * @brief[zh-cn] 在堆中的索引（-1 表示不在堆中）
     *
     * @brief[en] Index in the heap (-1 means not in the heap)
     */
    public mut prop index: Int64 {
        get() { _index }
        set(v) { _index = v }
    }

    /**
     * @brief[zh-cn] 比较函数：priority 越小越优先（最小堆）
     * @param[zh-cn] other 另一个堆节点
     * @return[zh-cn] this.priority < other.priority 时返回 true
     *
     * @brief[en] Comparison function: lower priority value means higher priority (min-heap)
     * @param[en] other Another heap node
     * @return[en] Returns true when this.priority < other.priority
     */
    public func lessThan(other: HeapNode): Bool {
        // 用 is + as 安全转 type，避免不同类型比较时报错
        if (other is FrameTask) {
            let otherTask = other as FrameTask
            match (otherTask) {
                case Some(t) => return this.priority < t.priority
                case None => return false
            }
        }
        return false
    }

    // ===== 状态查询 =====

    /**
     * @brief[zh-cn] 是否已完成
     *
     * @brief[en] Whether the task is finished
     */
    public prop finished: Bool {
        get() { _finished }
    }

    /**
     * @brief[zh-cn] 最近一次执行耗时（毫秒）
     *
     * @brief[en] Time consumed by the most recent execution (milliseconds)
     */
    public prop lastTimeConsume: Float64 {
        get() { _lastTime }
    }

    /**
     * @brief[zh-cn] EWMA 平均耗时（毫秒），用于调度器预算判断
     *
     * @brief[en] EWMA average execution time (milliseconds), used for the dispatcher's budget check
     */
    public prop averageTimeConsume: Float64 {
        get() { _avgTime }
    }

    /**
     * @brief[zh-cn] 执行次数计数
     *
     * @brief[en] Execution count
     */
    public prop executionCount: Int64 {
        get() { _idx }
    }

    /**
     * @brief[zh-cn] 是否还有参数可处理（未完成且参数队列非空）
     * @explain[zh-cn] ONCE 模式总是返回 true（直到执行一次后 finished 才变 false）。
     *
     * @brief[en] Whether there are still parameters to process (not finished and parameter queue is non-empty)
     * @explain[en] ONCE mode always returns true (until finished becomes false after one execution).
     */
    public func notEmpty(): Bool {
        if (_finished) {
            return false
        }
        // ONCE 模式不需要参数
        return match (mode) {
            case ONCE => true
            case _ => !params.isEmpty()
        }
    }

    // ===== 执行 =====

    /**
     * @brief[zh-cn] 执行一次任务
     * @param[zh-cn] deltaTime 当前帧间隔时间（毫秒）
     * @return[zh-cn] true 表示本帧可继续执行；false 表示本帧停止调度（参数空、callback 返回 false、ONCE 完成）
     *
     * @brief[en] Execute the task once
     * @param[en] deltaTime Current frame interval time (milliseconds)
     * @return[en] true means continue execution this frame; false means stop this frame's scheduling (empty params, callback returns false, or ONCE completed)
     */
    public func run(deltaTime: Float64): Bool {
        if (_finished) {
            return false
        }

        let start = MonoTime.now()
        var cont: Bool = false

        match (mode) {
            case ONCE =>
                let ctx = FrameTaskContext(this, deltaTime, _idx, Array<Any>())
                let _ = callback(ctx)
                _idx += 1
                cont = false
                _finished = true
            case CONSUME =>
                if (params.isEmpty()) {
                    _finished = true
                    return false
                }
                match (params.remove()) {
                    case None =>
                        _finished = true
                        return false
                    case Some(args) =>
                        let ctx = FrameTaskContext(this, deltaTime, _idx, args)
                        let result = callback(ctx)
                        _idx += 1
                        cont = result && !params.isEmpty()
                }
            case LOOP =>
                match (params.next()) {
                    case None =>
                        _finished = true
                        return false
                    case Some(args) =>
                        let ctx = FrameTaskContext(this, deltaTime, _idx, args)
                        let result = callback(ctx)
                        _idx += 1
                        cont = result
                }
        }

        // 更新耗时统计（毫秒，Float64 保留精度）
        let elapsed = MonoTime.now() - start
        _lastTime = Float64(elapsed.toNanoseconds()) / 1_000_000.0
        if (_avgTime == 0.0) {
            _avgTime = _lastTime
        } else {
            // EWMA（alpha=0.5 等价于算术平均），与 TS 原版语义一致
            _avgTime = (_avgTime + _lastTime) / 2.0
        }

        return cont
    }

    /**
     * @brief[zh-cn] 重置任务状态
     * @explain[zh-cn] 用于调度器复用任务实例（对象池场景）。清空参数队列、计数、耗时统计、暂停状态。
     *
     * @brief[en] Reset task state
     * @explain[en] Used for dispatcher reuse of task instances (object pool scenarios). Clears parameter queue, counters, time statistics, and pause state.
     */
    public func reset(): Unit {
        _idx = 0
        _lastTime = 0.0
        _avgTime = 0.0
        _finished = false
        _index = -1
        paused = false
        params.clear()
    }
}
