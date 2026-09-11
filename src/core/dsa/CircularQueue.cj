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
 * @file[zh-cn] CircularQueue
 * @brief[zh-cn] 循环队列（通用基础设施）
 * @explain[zh-cn] 本实现基于 ArrayList<T>，统一提供 add(element) 尾部入队、remove() 尾部出队（LIFO 消耗）、peek() 查看当前 next 指向的元素（不消耗）、next() 环形遍历不消耗元素。单线程使用，无加锁。
 *
 * @file[en] CircularQueue
 * @brief[en] Circular queue (general-purpose infrastructure)
 * @explain[en] Based on ArrayList<T>, providing add(element) for tail enqueue, remove() for tail dequeue (LIFO consumption), peek() for viewing the current next-pointed element (no consumption), and next() for circular traversal without consuming elements. Single-threaded, no locking.
 */
package three.core.dsa

import std.collection.*
import three.core.interfaces.*

/**
 * @brief[zh-cn] 循环队列
 * @explain[zh-cn] 同时支持两种使用模式：消耗型 push/pop 配对使用（LIFO 顺序）；循环型 push 入队后调用 next 环形遍历，不消耗元素。
 * @param[zh-cn] T 元素类型
 *
 * @brief[en] Circular queue
 * @explain[en] Supports two usage modes: consume mode using push/pop pairs (LIFO order); cycle mode using push to enqueue then calling next for circular traversal without consuming elements.
 * @param[en] T Element type
 */
public class CircularQueue<T> <: ICircularQueue<T> {
    /**
     * @brief[zh-cn] 内部存储
     *
     * @brief[en] Internal storage
     */
    private let _data: ArrayList<T>
    /**
     * @brief[zh-cn] 当前 next 指向的索引，-1 表示未初始化
     *
     * @brief[en] Index the current next points to, -1 means uninitialized
     */
    private var _idx: Int64

    /**
     * @brief[zh-cn] 默认构造器
     *
     * @brief[en] Default constructor
     */
    public init() {
        _data = ArrayList<T>()
        _idx = -1
    }

    /**
     * @brief[zh-cn] 指定初始容量的构造器
     * @param[zh-cn] capacity 初始容量
     *
     * @brief[en] Constructor with initial capacity
     * @param[en] capacity Initial capacity
     */
    public init(capacity: Int64) {
        _data = ArrayList<T>(capacity)
        _idx = -1
    }

    /**
     * @brief[zh-cn] 入队（尾部）
     * @param[zh-cn] element 元素
     *
     * @brief[en] Enqueue (tail)
     * @param[en] element Element
     */
    public func add(element: T): Unit {
        _data.add(element)
    }

    /**
     * @brief[zh-cn] 出队（尾部，LIFO 消耗）
     * @return[zh-cn] 队尾元素；空时返回 None
     *
     * @brief[en] Dequeue (tail, LIFO consumption)
     * @return[en] Tail element; None if empty
     */
    public func remove(): ?T {
        if (_data.size == 0) {
            return None
        }
        let last = _data.size - 1
        let e = _data[last]
        _data.remove(at: last)
        // 出队后索引可能越界，重置到合法范围
        if (_idx >= _data.size) {
            _idx = if (_data.size > 0) { _data.size - 1 } else { -1 }
        }
        return Some(e)
    }

    /**
     * @brief[zh-cn] 查看当前 next 指向的元素（不消耗）
     * @return[zh-cn] 元素；空时返回 None
     *
     * @brief[en] Peek at the current next-pointed element (no consumption)
     * @return[en] Element; None if empty
     */
    public func peek(): ?T {
        if (_data.size == 0) {
            return None
        }
        let i = if (_idx < 0 || _idx >= _data.size) { _data.size - 1 } else { _idx }
        return _data[i]
    }

    /**
     * @brief[zh-cn] 循环获取下一个元素（不消耗）
     * @explain[zh-cn] 队列非空时按环形顺序返回元素，每次调用推进索引。队列为空时返回 None。
     * @return[zh-cn] 下一个元素；空时返回 None
     *
     * @brief[en] Circularly get the next element (without consuming)
     * @explain[en] When the queue is non-empty, returns elements in ring order, advancing the index on each call. Returns None when the queue is empty.
     * @return[en] Next element; None if empty
     */
    public func next(): ?T {
        if (_data.size == 0) {
            return None
        }
        _idx = (_idx + 1) % _data.size
        return _data[_idx]
    }

    /**
     * @brief[zh-cn] 当前元素数量
     *
     * @brief[en] Current number of elements
     */
    public prop size: Int64 {
        get() { _data.size }
    }

    /**
     * @brief[zh-cn] 是否为空
     *
     * @brief[en] Whether the queue is empty
     */
    public func isEmpty(): Bool {
        return _data.size == 0
    }

    /**
     * @brief[zh-cn] 清空
     *
     * @brief[en] Clear the queue
     */
    public func clear(): Unit {
        _data.clear()
        _idx = -1
    }

    /**
     * @brief[zh-cn] 转为数组（入队顺序）
     *
     * @brief[en] Convert to an array (in enqueue order)
     */
    public func toArray(): Array<T> {
        return _data.toArray()
    }
}
