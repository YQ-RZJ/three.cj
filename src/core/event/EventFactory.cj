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
 * @file[zh-cn] EventFactory
 * @brief[zh-cn] 事件记录与对象池
 * @explain[zh-cn] EventRecord 包装事件回调及其元数据（名称、目标、单次标志）。EventFactory 通过自由链表复用 EventRecord 实例，减少 GC 压力。设计要点：EventRecord 字段公开可读，但调用方应将其视为不透明句柄，仅通过 EventManager.remove(listener) 进行移除；对象池用 ArrayList 自由栈实现：allocate 弹出尾部空闲实例，recycle 清空字段并压回；当池空时自动 new 新实例；recycled 标志用于防止重复入池。
 *
 * @file[en] EventFactory
 * @brief[en] Event record and object pool
 * @explain[en] EventRecord wraps event callbacks and their metadata (name, target, once flag). EventFactory reuses EventRecord instances via a free list to reduce GC pressure. Design notes: EventRecord fields are publicly readable but callers should treat them as opaque handles, only removing them via EventManager.remove(listener); the object pool uses an ArrayList free stack: allocate pops a free instance from the tail, recycle clears fields and pushes it back; when the pool is empty, new instances are created automatically; the recycled flag prevents duplicate recycling.
 */
package three.core.event

import std.collection.*

/**
 * @brief[zh-cn] 事件记录（监听器句柄）
 * @explain[zh-cn] 每次 addEvent/addEventOnce 创建一个实例并返回。调用方保存返回的 EventRecord 实例，用于后续调用 remove(listener) 精确移除。字段说明：id 为全局自增唯一标识（由 EventFactory 分配），name 为事件名称，target 为目标对象（用于 send 时过滤，None 表示不分目标），once 为是否仅触发一次，callback 为回调函数（接收参数数组），recycled 为是否在池中（内部使用）。
 *
 * @brief[en] Event record (listener handle)
 * @explain[en] Each addEvent/addEventOnce call creates an instance and returns it. The caller saves the returned EventRecord instance for precise removal via remove(listener). Fields: id is a globally incrementing unique identifier (assigned by EventFactory), name is the event name, target is the target object (for send filtering, None means no target binding), once indicates whether it triggers only once, callback is the callback function (receives a parameter array), recycled indicates whether it is in the pool (internal use).
 */
public class EventRecord {
    /**
     * @brief[zh-cn] 唯一 ID
     *
     * @brief[en] Unique ID
     */
    public var id: Int64
    /**
     * @brief[zh-cn] 事件名称
     *
     * @brief[en] Event name
     */
    public var name: String
    /**
     * @brief[zh-cn] 目标对象（用于过滤分发）
     *
     * @brief[en] Target object (used to filter dispatching)
     */
    public var target: ?Object
    /**
     * @brief[zh-cn] 是否仅触发一次
     *
     * @brief[en] Whether it triggers only once
     */
    public var once: Bool
    /**
     * @brief[zh-cn] 回调函数
     *
     * @brief[en] Callback function
     */
    public var callback: (Array<Object>) -> Unit
    /**
     * @brief[zh-cn] 是否已回收（在池中）—内部使用
     *
     * @brief[en] Whether already recycled (in the pool) — internal use
     */
    internal var recycled: Bool

    /**
     * @brief[zh-cn] 默认构造器
     * @explain[zh-cn] 创建的实例默认 recycled=true，可直接放入对象池。
     *
     * @brief[en] Default constructor
     * @explain[en] The created instance defaults to recycled=true and can be placed directly into the object pool.
     */
    public init() {
        this.id = 0
        this.name = ""
        this.target = None
        this.once = false
        this.callback = { _ => }
        this.recycled = true
    }

    /**
     * @brief[zh-cn] 重置所有字段为默认值
     * @explain[zh-cn] 回收前调用，避免持有大对象引用（如 target、callback 闭包）造成内存泄漏。
     *
     * @brief[en] Reset all fields to default values
     * @explain[en] Called before recycling to avoid holding large object references (such as target, callback closures) causing memory leaks.
     */
    internal func reset(): Unit {
        this.id = 0
        this.name = ""
        this.target = None
        this.once = false
        this.callback = { _ => }
        this.recycled = true
    }
}

/**
 * @brief[zh-cn] 事件对象池
 * @explain[zh-cn] 通过自由栈实现简单的对象复用：allocate 从空闲栈弹出一个 EventRecord，分配新 ID，标记为已分配；recycle 调用 reset() 清空字段，压回空闲栈。当池空时自动 new 新实例；不预先创建对象，避免启动开销。性能特性：allocate/recycle 均摊 O(1)；不加锁，单线程使用；多线程需调用方加锁。
 *
 * @brief[en] Event object pool
 * @explain[en] Implements simple object reuse via a free stack: allocate pops a free EventRecord from the stack, assigns a new ID, and marks it as allocated; recycle calls reset() to clear fields and pushes it back to the free stack. When the pool is empty, new instances are created automatically; no pre-creation of objects to avoid startup overhead. Performance: allocate/recycle are amortized O(1); no locking, single-threaded use; multi-threaded use requires caller-side locking.
 */
public class EventFactory {
    /**
     * @brief[zh-cn] 自增 ID 计数器（下一个分配的 ID）
     *
     * @brief[en] Auto-incrementing ID counter (next ID to be assigned)
     */
    private var _nextId: Int64
    /**
     * @brief[zh-cn] 空闲对象栈
     *
     * @brief[en] Free object stack
     */
    private var _free: ArrayList<EventRecord>
    /**
     * @brief[zh-cn] 已分配数量
     *
     * @brief[en] Number of allocated objects
     */
    private var _allocated: Int64

    /**
     * @brief[zh-cn] 默认构造器
     *
     * @brief[en] Default constructor
     */
    public init() {
        this._nextId = 1
        this._free = ArrayList<EventRecord>()
        this._allocated = 0
    }

    /**
     * @brief[zh-cn] 指定初始预分配容量的构造器
     * @param[zh-cn] capacity 预先创建的对象数量，热路径调用前预热
     *
     * @brief[en] Constructor with initial pre-allocation capacity
     * @param[en] capacity Number of objects to pre-create, warm up before hot-path calls
     */
    public init(capacity: Int64) {
        this._nextId = 1
        this._free = ArrayList<EventRecord>(capacity)
        this._allocated = 0
        // 预热：预先创建对象放入空闲栈
        for (_ in 0..capacity) {
            this._free.add(EventRecord())
        }
    }

    /**
     * @brief[zh-cn] 分配一个 EventRecord 实例
     * @explain[zh-cn] 从池中弹出一个空闲实例（池空则 new 新实例），分配新 ID 并标记为已分配。
     * @return[zh-cn] 已分配 ID 的 EventRecord，调用方需立即设置 name/target/once/callback
     *
     * @brief[en] Allocate an EventRecord instance
     * @explain[en] Pops a free instance from the pool (creates a new instance if the pool is empty), assigns a new ID, and marks it as allocated.
     * @return[en] EventRecord with assigned ID; caller should immediately set name/target/once/callback
     */
    public func allocate(): EventRecord {
        let record: EventRecord
        if (_free.size > 0) {
            record = _free.remove(at: _free.size - 1)
        } else {
            record = EventRecord()
        }
        record.id = _nextId
        _nextId += 1
        record.recycled = false
        _allocated += 1
        return record
    }

    /**
     * @brief[zh-cn] 回收 EventRecord 实例
     * @explain[zh-cn] 清空字段并压回空闲栈，避免重复入池。
     * @param[zh-cn] record 待回收的实例
     *
     * @brief[en] Recycle an EventRecord instance
     * @explain[en] Clears fields and pushes back to the free stack, preventing duplicate recycling.
     * @param[en] record Instance to recycle
     */
    public func recycle(record: EventRecord): Unit {
        if (record.recycled) {
            return
        }
        record.reset()
        _free.add(record)
        _allocated -= 1
    }

    /**
     * @brief[zh-cn] 已分配数量
     *
     * @brief[en] Number of allocated objects
     */
    public prop allocatedCount: Int64 {
        get() { _allocated }
    }

    /**
     * @brief[zh-cn] 池中空闲数量
     *
     * @brief[en] Number of free objects in the pool
     */
    public prop freeCount: Int64 {
        get() { _free.size }
    }

    /**
     * @brief[zh-cn] 清空对象池
     * @explain[zh-cn] 释放所有空闲实例。已分配的实例不受影响，但不应再被 recycle 回此池。
     *
     * @brief[en] Clear the object pool
     * @explain[en] Releases all free instances. Allocated instances are not affected but should not be recycled back to this pool.
     */
    public func clear(): Unit {
        _free.clear()
    }
}
