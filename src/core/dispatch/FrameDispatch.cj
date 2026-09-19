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
 * @file[zh-cn] FrameDispatch
 * @brief[zh-cn] 帧调度器
 * @explain[zh-cn] 核心思路：强制队列（priority=0）每帧全部执行，无视时间预算；优先级队列（priority>0）基于 BinaryHeap 按优先级排序，每帧按优先级顺序处理，遇到时间预算超限则剩余任务延后到下一帧。调度流程 frameEvent(deltaTime)：1. 处理强制队列：每个 task 循环执行 run() 直到 notEmpty()=false 或 run()=false；2. 处理优先级队列：从 heap pop 全部到临时列表（按优先级排序）→ 按顺序处理，每个 task 循环执行 run() → 时间预算超限时把剩余 push 回 heap。单线程使用，无加锁；跨线程使用需调用方加锁。
 *
 * @file[en] FrameDispatch
 * @brief[en] Frame dispatcher
 * @explain[en] Core idea: forced queue (priority=0) executes all tasks every frame, ignoring time budget; priority queue (priority>0) is sorted by BinaryHeap, processing tasks in priority order each frame, with remaining tasks deferred when the time budget is exceeded. Dispatch flow frameEvent(deltaTime): 1. Process forced queue: each task runs run() in a loop until notEmpty()=false or run()=false; 2. Process priority queue: pop all from heap to a temporary list (sorted by priority) → process in order, each task runs run() in a loop → push remaining back to heap when time budget is exceeded. Single-threaded, no locking; callers must provide locking for cross-thread use.
 */
package three.core.dispatch

import std.collection.*
import std.time.*
import three.core.dsa.*
import three.core.interfaces.*

/**
 * @brief[zh-cn] 帧调度器
 * @explain[zh-cn] 帧调度器，管理强制队列与优先级队列，按时间预算裁剪优先级队列任务。用法示例：
 * ```
 * let dispatch = FrameDispatch(maximum: 5.0)
 * // 注册一个消耗型任务
 * let params = CircularQueue<Array<Any>>()
 * params.add([1])
 * params.add([2])
 * let id = dispatch.registerTask(
 * FrameTaskMode.CONSUME,
 * 1,
 * { ctx =>
 * @LogInfo(["FrameDispatch", "execute idx=${ctx.idx}, args=${ctx.args}"])
 * return true
 * },
 * params: params
 * )
 * // 每帧调度
 * dispatch.frameEvent(deltaTime: 16.67)
 * // 取消注册
 * dispatch.unregister(id)
 * ```
 *
 * @brief[en] Frame dispatcher
 * @explain[en] Frame dispatcher that manages a forced queue and a priority queue, trimming priority queue tasks based on time budget.
 */
public class FrameDispatch {
    /**
     * @brief[zh-cn] 强制执行队列（priority<=0，无视时间预算）
     *
     * @brief[en] Forced execution queue (priority<=0, ignores time budget)
     */
    private var _forceList: ArrayList<FrameTask>
    /**
     * @brief[zh-cn] 优先级队列（priority>0）
     *
     * @brief[en] Priority queue (priority>0)
     */
    private var _heap: BinaryHeap<FrameTask>
    /**
     * @brief[zh-cn] ID → Task 映射，用于 unregister/pause/resume 查找
     *
     * @brief[en] ID → Task mapping, used for unregister/pause/resume lookup
     */
    private var _idToTask: HashMap<Int64, FrameTask>
    /**
     * @brief[zh-cn] 暂停的任务 ID 集合（不在调度中，但仍在 _idToTask 中保留以便 resume）
     *
     * @brief[en] Set of paused task IDs (excluded from scheduling, but still kept in _idToTask for resume)
     */
    private var _pausedIds: HashSet<Int64>

    /**
     * @brief[zh-cn] 下一个任务 ID
     *
     * @brief[en] Next task ID
     */
    private var _nextId: Int64
    /**
     * @brief[zh-cn] 时间预算上限（毫秒），优先级队列的总执行时间上限
     *
     * @brief[en] Time budget limit (milliseconds), total execution time cap for the priority queue
     */
    public var maximum: Float64
    /**
     * @brief[zh-cn] 当前轮次帧已消耗时间（毫秒）
     *
     * @brief[en] Time consumed in the current frame round (milliseconds)
     */
    private var _frameElapsed: Float64

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] maximum 帧调度函数总执行时间上限（毫秒，默认 5.0）
     *
     * @brief[en] Constructor
     * @param[en] maximum Total execution time limit for the frame dispatch function (milliseconds, default 5.0)
     */
    public init(maximum!: Float64 = 5.0) {
        _forceList = ArrayList<FrameTask>()
        _heap = BinaryHeap<FrameTask>(16)
        _idToTask = HashMap<Int64, FrameTask>()
        _pausedIds = HashSet<Int64>()
        _nextId = 1
        this.maximum = maximum
        _frameElapsed = 0.0
    }

    /**
     * @brief[zh-cn] 当前轮次帧已消耗时间（毫秒）
     *
     * @brief[en] Time consumed in the current frame round (milliseconds)
     */
    public prop frameElapsed: Float64 {
        get() { _frameElapsed }
    }

    /**
     * @brief[zh-cn] 当前活跃任务数量（不含暂停）
     *
     * @brief[en] Number of currently active tasks (excluding paused ones)
     */
    public prop activeTaskCount: Int64 {
        get() { _idToTask.size - _pausedIds.size }
    }

    /**
     * @brief[zh-cn] 暂停任务数量
     *
     * @brief[en] Number of paused tasks
     */
    public prop pausedTaskCount: Int64 {
        get() { _pausedIds.size }
    }

    /**
     * @brief[zh-cn] 注册帧任务
     * @explain[zh-cn] 如果 task.id <= 0，调度器自动分配新 ID；否则使用 task.id（须唯一）。
     * @param[zh-cn] task 帧任务
     *
     * @brief[en] Register a frame task
     * @explain[en] If task.id <= 0, the dispatcher auto-assigns a new ID; otherwise uses task.id (must be unique).
     * @param[en] task Frame task
     */
    public func register(task: FrameTask): Unit {
        if (task.id <= 0 || _idToTask.contains(task.id)) {
            // id 无效或已存在，分配新 id
            task.id = _nextId
            _nextId += 1
        } else if (task.id >= _nextId) {
            // 防止 _nextId 落后于已注册 id
            _nextId = task.id + 1
        }
        _idToTask.add(task.id, task)
        if (task.priority <= 0) {
            _forceList.add(task)
        } else {
            _heap.push(task)
        }
    }

    /**
     * @brief[zh-cn] 创建并注册帧任务（便捷方法）
     * @param[zh-cn] mode 任务模式
     * priority 优先级（0=强制队列；>0=优先级队列，值越小优先级越高）
     * callback 回调函数
     * params 参数队列
     * shareValue 共享值（可选）
     * @return[zh-cn] 任务 ID，可用于 unregister/pause/resume
     *
     * @brief[en] Create and register a frame task (convenience method)
     * @param[en] mode Task mode
     * priority Priority (0=forced queue; >0=priority queue, lower value means higher priority)
     * callback Callback function
     * params Parameter queue
     * shareValue Shared value (optional)
     * @return[en] Task ID, can be used for unregister/pause/resume
     */
    public func registerTask(
        mode: FrameTaskMode,
        priority: Int64,
        callback: (FrameTaskContext) -> Bool,
        params: ICircularQueue<Array<Any>>,
        shareValue!: ?Any = None
    ): Int64 {
        let id = _nextId
        _nextId += 1
        let task = FrameTask(id, mode, priority, callback, params, shareValue:shareValue)
        register(task)
        return id
    }

    /**
     * @brief[zh-cn] 取消注册
     * @param[zh-cn] id 任务 ID
     *
     * @brief[en] Unregister a task
     * @param[en] id Task ID
     */
    public func unregister(id: Int64): Unit {
        match (_idToTask.get(id)) {
            case None => return
            case Some(task) =>
                _idToTask.remove(id)
                _pausedIds.remove(id)
                if (task.priority <= 0) {
                    _removeFromForceList(id)
                } else {
                    // task 若在堆中则移除；不在堆中（已 pop）则无需操作
                    _heap.remove(task)
                }
        }
    }

    /**
     * @brief[zh-cn] 暂停任务（不参与调度，保留状态）
     * @param[zh-cn] id 任务 ID
     *
     * @brief[en] Pause a task (removed from scheduling, state preserved)
     * @param[en] id Task ID
     */
    public func pause(id: Int64): Unit {
        match (_idToTask.get(id)) {
            case None => return
            case Some(task) =>
                if (task.paused) {
                    return
                }
                task.paused = true
                _pausedIds.add(id)
                if (task.priority <= 0) {
                    _removeFromForceList(id)
                } else {
                    _heap.remove(task)
                }
        }
    }

    /**
     * @brief[zh-cn] 恢复任务
     * @param[zh-cn] id 任务 ID
     *
     * @brief[en] Resume a paused task
     * @param[en] id Task ID
     */
    public func resume(id: Int64): Unit {
        match (_idToTask.get(id)) {
            case None => return
            case Some(task) =>
                if (!task.paused) {
                    return
                }
                task.paused = false
                _pausedIds.remove(id)
                if (task.priority <= 0) {
                    _forceList.add(task)
                } else {
                    // 任务重新入堆，重置 index
                    task.index = -1
                    _heap.push(task)
                }
        }
    }

    /**
     * @brief[zh-cn] 清空所有任务
     *
     * @brief[en] Clear all tasks
     */
    public func clear(): Unit {
        _forceList.clear()
        _heap.clear()
        _idToTask.clear()
        _pausedIds.clear()
    }

    /**
     * @brief[zh-cn] 帧调度
     * @explain[zh-cn] 处理强制队列与优先级队列，按时间预算裁剪优先级队列任务。
     * @param[zh-cn] deltaTime 当前帧间隔时间（毫秒，默认 0）
     *
     * @brief[en] Frame dispatch
     * @explain[en] Processes the forced queue and priority queue, trimming priority queue tasks based on time budget.
     * @param[en] deltaTime Current frame interval time (milliseconds, default 0)
     */
    public func frameEvent(deltaTime!: Float64 = 0.0): Unit {
        _frameElapsed = 0.0

        // 1. 处理强制队列（无视时间预算）
        // 倒序遍历，便于移除已结束任务
        var i = _forceList.size - 1
        while (i >= 0) {
            let task = _forceList[i]
            while (task.notEmpty()) {
                if (!task.run(deltaTime)) {
                    break
                }
            }
            // 任务结束则从列表移除并从 id 映射删除
            if (!task.notEmpty()) {
                _forceList.remove(at: i)
                _idToTask.remove(task.id)
            }
            i -= 1
        }

        // 2. 处理优先级队列
        if (!_heap.isEmpty()) {
            // 弹出所有任务到临时列表（按优先级排序，priority 小的先出）
            let pending = ArrayList<FrameTask>()
            while (!_heap.isEmpty()) {
                match (_heap.pop()) {
                    case None => break
                    case Some(task) => pending.add(task)
                }
            }

            // 按优先级顺序处理
            var idx = 0
            while (idx < pending.size) {
                let task = pending[idx]
                idx += 1

                // 度量因子：检查时间预算
                if (!_onMeasure(task)) {
                    // 时间预算超限：当前 task 与剩余 push 回堆，下一帧处理
                    _heap.push(task)
                    while (idx < pending.size) {
                        _heap.push(pending[idx])
                        idx += 1
                    }
                    break
                }

                // 内层循环：执行直到本帧停止或参数空
                while (task.notEmpty() && task.run(deltaTime)) {
                    _frameElapsed += task.lastTimeConsume
                }

                // 任务结束则从 id 映射移除，否则 push 回堆
                if (!task.notEmpty()) {
                    _idToTask.remove(task.id)
                } else {
                    _heap.push(task)
                }
            }
        }
    }

    // ===== 内部方法 =====

    /**
     * @brief[zh-cn] 度量因子：决定是否继续执行下一个任务
     * @param[zh-cn] task 待执行任务
     * @return[zh-cn] true: 继续；false: 停止（时间预算超限）
     *
     * @brief[en] Measure factor: determine whether to continue executing the next task
     * @param[en] task Task to be executed
     * @return[en] true: continue; false: stop (time budget exceeded)
     */
    protected func _onMeasure(task: FrameTask): Bool {
        // 当前轮次耗时大于等于最大上限，停止
        if (_frameElapsed >= maximum) {
            return false
        }
        // 若待调度的事件平均执行时间大于上限
        if (task.averageTimeConsume >= maximum) {
            if (_frameElapsed == 0.0) {
                // 此前没有执行任何事件，允许执行
                return true
            } else {
                // 滞留执行
                return false
            }
        }
        // 下一个待调度的事件加上已消耗的事件大于上限，停止
        if (_frameElapsed + task.averageTimeConsume >= maximum) {
            return false
        }
        return true
    }

    /**
     * @brief[zh-cn] 从强制队列中按 id 移除任务
     *
     * @brief[en] Remove a task from the forced queue by ID
     */
    private func _removeFromForceList(id: Int64): Unit {
        var i = 0
        while (i < _forceList.size) {
            if (_forceList[i].id == id) {
                _forceList.remove(at: i)
                return
            }
            i += 1
        }
    }
}
