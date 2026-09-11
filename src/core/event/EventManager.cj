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
 * @file[zh-cn] EventManager
 * @brief[zh-cn] 事件总线
 * @explain[zh-cn] 提供基于事件名称 + 目标对象的事件分发能力。与 three.core.EventDispatcher 的职责区分：EventDispatcher 用于对象内事件分发（绑定到具体对象，标准 JS 事件 API）；EventManager 用于全局事件总线（独立运行，支持 name+target 二维过滤与对象池复用）。设计要点：1. 双索引 _idToEvent 主存储 + _nameToIds 名称索引，O(1) 查找；2. 句柄式 API：addEvent 返回 EventRecord 实例，调用方保存后用于精确 remove（仓颉函数类型无法引用比较，故不提供按 callback 移除的 API）；3. send 时先快照回调函数引用，再移除 once 监听器，最后调用回调——避免迭代中修改索引；避免回调中触发状态变更导致并发修改；4. 单线程版本，不加锁；跨线程使用需调用方自行加锁。
 *
 * @file[en] EventManager
 * @brief[en] Event bus
 * @explain[en] Provides event dispatching based on event name + target object. Distinction from three.core.EventDispatcher: EventDispatcher is for intra-object event dispatching (bound to specific objects, standard JS event API); EventManager is a global event bus (runs independently, supports name+target two-dimensional filtering and object pool reuse). Design notes: 1. Dual index: _idToEvent primary storage + _nameToIds name index, O(1) lookup; 2. Handle-based API: addEvent returns an EventRecord instance, caller saves it for precise remove (Cangjie function types cannot be compared by reference, so no callback-based removal API); 3. send snapshots callback function references first, then removes once listeners, then invokes callbacks — avoiding index modification during iteration and concurrent modification from callback-triggered state changes; 4. Single-threaded version, no locking; cross-thread use requires caller-side locking.
 */
package three.core.event

import std.collection.*

/**
 * @brief[zh-cn] 事件管理器（全局事件总线）
 * @explain[zh-cn] 用法示例：
 * ```
 * let bus = EventManager()
 * let listener = bus.addEvent("click", { args =>
 * // 处理点击事件
 * })
 * bus.send("click")
 * bus.remove(listener)
 * ```
 *
 * @brief[en] Event manager (global event bus)
 * @explain[en] Usage example:
 * ```
 * let bus = EventManager()
 * let listener = bus.addEvent("click", { args =>
 * // Handle click event
 * })
 * bus.send("click")
 * bus.remove(listener)
 * ```
 */
public class EventManager {
    /**
     * @brief[zh-cn] ID → EventRecord 主存储
     *
     * @brief[en] ID → EventRecord primary storage
     */
    private var _idToEvent: HashMap<Int64, EventRecord>
    /**
     * @brief[zh-cn] 名称 → ID 集合索引
     *
     * @brief[en] Name → ID set index
     */
    private var _nameToIds: HashMap<String, HashSet<Int64>>
    /**
     * @brief[zh-cn] 对象池
     *
     * @brief[en] Object pool
     */
    private var _factory: EventFactory

    /**
     * @brief[zh-cn] 默认构造器，使用默认对象池容量
     *
     * @brief[en] Default constructor, uses default object pool capacity
     */
    public init() {
        this._idToEvent = HashMap<Int64, EventRecord>()
        this._nameToIds = HashMap<String, HashSet<Int64>>()
        this._factory = EventFactory()
    }

    /**
     * @brief[zh-cn] 指定对象池初始容量的构造器
     * @param[zh-cn] poolCapacity 对象池预热容量，热路径调用前预热可减少首次分配开销
     *
     * @brief[en] Constructor with initial object pool capacity
     * @param[en] poolCapacity Object pool warm-up capacity; warming up before hot-path calls reduces first allocation overhead
     */
    public init(poolCapacity: Int64) {
        this._idToEvent = HashMap<Int64, EventRecord>()
        this._nameToIds = HashMap<String, HashSet<Int64>>()
        this._factory = EventFactory(poolCapacity)
    }

    /**
     * @brief[zh-cn] 添加事件监听器
     * @param[zh-cn] name 事件名称
     * callback 回调函数，参数数组由 send 时传入
     * target 目标对象（用于 send 时过滤），None 表示不绑定目标
     * @return[zh-cn] EventRecord 句柄，用于精确 remove
     *
     * @brief[en] Add an event listener
     * @param[en] name Event name
     * callback Callback function, parameter array passed in by send
     * target Target object (for send filtering), None means no target binding
     * @return[en] EventRecord handle, for precise removal
     */
    public func addEvent(name: String, callback: (Array<Object>) -> Unit, target!: ?Object = None): EventRecord {
        return _addEvent(name, callback, false, target)
    }

    /**
     * @brief[zh-cn] 添加一次性事件监听器
     * @explain[zh-cn] 监听器在 send 触发后自动移除并回收到对象池。
     * @param[zh-cn] name 事件名称
     * callback 回调函数
     * target 目标对象，None 表示不绑定目标
     * @return[zh-cn] EventRecord 句柄
     *
     * @brief[en] Add a one-time event listener
     * @explain[en] The listener is automatically removed and recycled to the object pool after being triggered by send.
     * @param[en] name Event name
     * callback Callback function
     * target Target object, None means no target binding
     * @return[en] EventRecord handle
     */
    public func addEventOnce(name: String, callback: (Array<Object>) -> Unit, target!: ?Object = None): EventRecord {
        return _addEvent(name, callback, true, target)
    }

    /**
     * @brief[zh-cn] 分发事件
     * @explain[zh-cn] 按 name 查找监听器，可选按 target 过滤。once 监听器在分发前先从索引移除并回收，再统一调用回调。过滤规则：若 target=None，触发所有该 name 的监听器；若 target=Some(t)，仅触发 listener.target==Some(t) 的监听器。
     * @param[zh-cn] name 事件名称
     * data 传递给回调的参数数组，默认空数组
     * target 目标对象过滤，None 表示不过滤
     *
     * @brief[en] Dispatch an event
     * @explain[en] Looks up listeners by name, optionally filtering by target. Once listeners are removed from the index and recycled before dispatching, then callbacks are invoked uniformly. Filtering rules: if target=None, triggers all listeners for the name; if target=Some(t), only triggers listeners where listener.target==Some(t).
     * @param[en] name Event name
     * data Parameter array passed to callbacks, default empty array
     * target Target object filter, None means no filtering
     */
    public func send(name: String, data!: Array<Object> = Array<Object>(), target!: ?Object = None): Unit {
        let nameToIds = _nameToIds
        if (!nameToIds.contains(name)) {
            return
        }
        let ids = nameToIds.get(name).getOrThrow()
        if (ids.isEmpty()) {
            return
        }

        // 第一阶段：快照回调函数 + 收集 once 监听器 ID
        // 在迭代期间不修改任何索引，避免并发修改异常
        let callbacks = ArrayList<(Array<Object>) -> Unit>()
        let onceIds = ArrayList<Int64>()
        for (id in ids) {
            match (_idToEvent.get(id)) {
                case None => continue
                case Some(listener) =>
                    if (listener.recycled) {
                        continue
                    }
                    let targetMatch = match (target) {
                        case None => true
                        case Some(t) => _targetEquals(listener.target, t)
                    }
                    if (targetMatch) {
                        callbacks.add(listener.callback)
                        if (listener.once) {
                            onceIds.add(id)
                        }
                    }
            }
        }

        // 第二阶段：移除 once 监听器（索引清除 + 对象池回收）
        // 此时已脱离第一阶段迭代，可安全修改 ids 集合
        for (id in onceIds) {
            _remove(id)
        }

        // 第三阶段：调用所有回调（已快照函数引用，即使 listener 已被回收也能调用）
        // 回调内部若调用 addEvent/send/remove 等修改状态的操作也不会影响本次快照
        for (cb in callbacks) {
            cb(data)
        }
    }

    /**
     * @brief[zh-cn] 按 EventRecord 句柄精确移除
     * @param[zh-cn] listener addEvent/addEventOnce 返回的句柄
     *
     * @brief[en] Precisely remove by EventRecord handle
     * @param[en] listener Handle returned by addEvent/addEventOnce
     */
    public func remove(listener: EventRecord): Unit {
        _remove(listener.id)
    }

    /**
     * @brief[zh-cn] 按名称与目标对象移除所有匹配的监听器
     * @param[zh-cn] name 事件名称
     * target 目标对象（引用相等匹配）
     *
     * @brief[en] Remove all matching listeners by name and target object
     * @param[en] name Event name
     * target Target object (reference equality matching)
     */
    public func removeByNameAndTarget(name: String, target: Object): Unit {
        let nameToIds = _nameToIds
        if (!nameToIds.contains(name)) {
            return
        }
        let ids = nameToIds.get(name).getOrThrow()
        if (ids.isEmpty()) {
            return
        }
        // 快照待移除 ID，避免迭代中修改 ids
        let needRemoveIds = ArrayList<Int64>()
        for (id in ids) {
            match (_idToEvent.get(id)) {
                case None => continue
                case Some(listener) =>
                    if (_targetEquals(listener.target, target)) {
                        needRemoveIds.add(id)
                    }
            }
        }
        for (id in needRemoveIds) {
            _remove(id)
        }
    }

    /**
     * @brief[zh-cn] 移除与指定目标关联的所有监听器
     * @explain[zh-cn] 遍历 _idToEvent 收集匹配项，再统一移除。不维护 _targetToIds 反向索引，避免 Object 不保证 Hashable 的限制。典型事件量下 O(n) 可接受；若成为性能瓶颈可后续引入弱引用 map 优化。
     * @param[zh-cn] target 目标对象（引用相等匹配）
     *
     * @brief[en] Remove all listeners associated with the specified target
     * @explain[en] Iterates through _idToEvent to collect matches, then removes them uniformly. Does not maintain a _targetToIds reverse index to avoid the limitation that Object does not guarantee Hashable. O(n) is acceptable for typical event volumes; if it becomes a performance bottleneck, a weak reference map optimization can be introduced later.
     * @param[en] target Target object (reference equality matching)
     */
    public func removeList(target: Object): Unit {
        let needRemoveIds = ArrayList<Int64>()
        for ((id, listener) in _idToEvent) {
            if (_targetEquals(listener.target, target)) {
                needRemoveIds.add(id)
            }
        }
        for (id in needRemoveIds) {
            _remove(id)
        }
    }

    /**
     * @brief[zh-cn] 清空所有监听器
     * @explain[zh-cn] 回收所有 EventRecord 到对象池，清空索引。
     *
     * @brief[en] Clear all listeners
     * @explain[en] Recycles all EventRecords to the object pool and clears the index.
     */
    public func clear(): Unit {
        for ((_, listener) in _idToEvent) {
            _factory.recycle(listener)
        }
        _idToEvent.clear()
        _nameToIds.clear()
    }

    /**
     * @brief[zh-cn] 当前注册的监听器数量
     *
     * @brief[en] Number of currently registered listeners
     */
    public prop listenerCount: Int64 {
        get() { _idToEvent.size }
    }

    /**
     * @brief[zh-cn] 指定名称的监听器数量
     * @param[zh-cn] name 事件名称
     * @return[zh-cn] 该名称下的监听器数量；不存在时返回 0
     *
     * @brief[en] Number of listeners for the specified name
     * @param[en] name Event name
     * @return[en] Number of listeners under this name; returns 0 if not found
     */
    public func countByName(name: String): Int64 {
        match (_nameToIds.get(name)) {
            case None => return 0
            case Some(ids) => return ids.size
        }
    }

    // ===== 内部实现 =====

    /**
     * @brief[zh-cn] 内部：添加事件
     *
     * @brief[en] Internal: add event
     */
    private func _addEvent(name: String, callback: (Array<Object>) -> Unit, once: Bool, target: ?Object): EventRecord {
        let listener = _factory.allocate()
        listener.name = name
        listener.target = target
        listener.once = once
        listener.callback = callback
        _idToEvent.add(listener.id, listener)

        // name 索引（不存在则创建）
        if (!_nameToIds.contains(name)) {
            _nameToIds.add(name, HashSet<Int64>())
        }
        _nameToIds.get(name).getOrThrow().add(listener.id)

        return listener
    }

    /**
     * @brief[zh-cn] 内部：按 ID 移除
     * @explain[zh-cn] 从 _idToEvent 移除并回收；同步从 _nameToIds 中删除对应 ID。
     *
     * @brief[en] Internal: remove by ID
     * @explain[en] Removes from _idToEvent and recycles; synchronously deletes the corresponding ID from _nameToIds.
     */
    private func _remove(id: Int64): Unit {
        let optListener = _idToEvent.get(id)
        match (optListener) {
            case None => return
            case Some(listener) =>
                let name = listener.name
                _idToEvent.remove(id)
                _factory.recycle(listener)
                // 从 name 索引移除（listener 已 recycle，name 字段已被清空，
                // 但本地变量 name 仍持有原值，安全使用）
                match (_nameToIds.get(name)) {
                    case None => ()
                    case Some(ids) => ids.remove(id)
                }
        }
    }

    /**
     * @brief[zh-cn] 目标对象比较（引用相等）
     * @explain[zh-cn] 由于 Object 默认不保证实现 Equatable，使用 refEq 做引用比较。
     * @param[zh-cn] a 监听器绑定的目标（None 表示未绑定）
     * b send/remove 时指定的目标（非 None）
     * @return[zh-cn] a 与 b 是否引用相等；a 为 None 时返回 false
     *
     * @brief[en] Target object comparison (reference equality)
     * @explain[en] Since Object does not guarantee implementing Equatable, refEq is used for reference comparison.
     * @param[en] a Target bound to the listener (None means unbound)
     * b Target specified during send/remove (non-None)
     * @return[en] Whether a and b are reference-equal; returns false when a is None
     */
    private func _targetEquals(a: ?Object, b: Object): Bool {
        match (a) {
            case None => return false
            case Some(objA) => return refEq(objA, b)
        }
    }
}
