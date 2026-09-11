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
 * @file[zh-cn] IQueue
 * @brief[zh-cn] 队列接口
 * @explain[zh-cn] 分帧调度器（dispatch 包）需要可替换的参数队列策略（LIFO 消耗型、循环型等）。将队列抽象为接口放在独立接口包内，避免 dispatch 直接依赖 dsa 的具体实现，便于跨包引用与单元测试替换。命名对齐仓颉 std.collection Queue / Stack 规范：add(T) 入队、remove() 出队、peek() 查看、size 元素数量、isEmpty() 是否为空、clear() 清空。
 *
 * @file[en] IQueue
 * @brief[en] Queue interface
 * @explain[en] The frame dispatcher (dispatch package) requires replaceable parameter queue strategies (LIFO consumable, circular etc.). The queue is abstracted as an interface in the independent interface package, preventing dispatch from directly depending on dsa's concrete implementations, facilitating cross-package references and unit test replacement. Naming aligns with Cangjie std.collection Queue / Stack conventions: add(T) enqueue, remove() dequeue, peek() peek, size element count, isEmpty() check empty, clear() clear all.
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 队列接口
 * @explain[zh-cn] 抽象元素的存储与获取方式。泛型 T 通常为 Array<Object>（一组帧函数参数）。
 *
 * @brief[en] Queue interface
 * @explain[en] Abstracts element storage and retrieval. Generic T is typically Array<Object> (a set of frame function parameters).
 */
public interface IQueue<T> {
    /**
     * @brief[zh-cn] 入队
     * @param[zh-cn] element 元素
     *
     * @brief[en] Enqueue
     * @param[en] element Element
     */
    func add(element: T): Unit

    /**
     * @brief[zh-cn] 出队（消耗一个元素）
     * @return[zh-cn] 队首元素；空时返回 None
     *
     * @brief[en] Dequeue (consume one element)
     * @return[en] Front element; None if empty
     */
    func remove(): ?T

    /**
     * @brief[zh-cn] 查看队首元素（不消耗）
     * @return[zh-cn] 队首元素；空时返回 None
     *
     * @brief[en] Peek at the front element (without consuming)
     * @return[en] Front element; None if empty
     */
    func peek(): ?T

    /**
     * @brief[zh-cn] 当前元素数量
     *
     * @brief[en] Current element count
     */
    prop size: Int64

    /**
     * @brief[zh-cn] 是否为空
     * @return[zh-cn] 为空返回 true
     *
     * @brief[en] Whether the queue is empty
     * @return[en] true if empty
     */
    func isEmpty(): Bool

    /**
     * @brief[zh-cn] 清空队列
     *
     * @brief[en] Clear the queue
     */
    func clear(): Unit
}

/**
 * @brief[zh-cn] 循环队列接口
 * @explain[zh-cn] 扩展 IQueue，提供 next() 循环获取（不消耗）。用于循环型帧任务（LOOP 模式）。
 *
 * @brief[en] Circular queue interface
 * @explain[en] Extends IQueue, providing next() for circular retrieval (without consuming). Used for circular frame tasks (LOOP mode).
 */
public interface ICircularQueue<T> <: IQueue<T> {
    /**
     * @brief[zh-cn] 循环获取下一个元素（不消耗）
     * @explain[zh-cn] 队列非空时按环形顺序返回元素，每次调用推进索引。队列为空时返回 None。
     * @return[zh-cn] 下一个元素；空时返回 None
     *
     * @brief[en] Circularly get the next element (without consuming)
     * @explain[en] When the queue is non-empty, returns elements in ring order, advancing the index on each call. Returns None when the queue is empty.
     * @return[en] Next element; None if empty
     */
    func next(): ?T
}
