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
 * @file[zh-cn] Stack
 * @brief[zh-cn] 动态栈（后进先出）
 * @explain[zh-cn] 底层使用 ArrayList<T> 实现，入栈/出栈均为 O(1) 均摊。
 *
 * @file[en] Stack
 * @brief[en] Dynamic stack (last-in-first-out)
 * @explain[en] Uses ArrayList<T> internally, push/pop are both amortized O(1).
 */
package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] 动态栈（后进先出）
 * @explain[zh-cn] 类型参数约束：T <: Equatable<T>（仅用于 contains 方法）。
 *
 * @brief[en] Dynamic stack (last-in-first-out)
 * @explain[en] Modeled after Cangjie std.collection.ArrayStack. Type parameter constraint: T <: Equatable<T> (only for the contains method).
 */
public class Stack<T> where T <: Equatable<T> {
    /**
     * @brief[zh-cn] 内部存储
     *
     * @brief[en] Internal storage
     */
    private let _data: ArrayList<T>

    /**
     * @brief[zh-cn] 默认构造器
     *
     * @brief[en] Default constructor
     */
    public init() {
        _data = ArrayList<T>()
    }

    /**
     * @brief[zh-cn] 指定初始容量的构造器
     * @param[zh-cn] capacity 初始容量
     *
     * @brief[en] Constructor with specified initial capacity
     * @param[en] capacity Initial capacity
     */
    public init(capacity: Int64) {
        _data = ArrayList<T>(capacity)
    }

    /**
     * @brief[zh-cn] 入栈
     * @param[zh-cn] element 元素
     *
     * @brief[en] Push element onto stack
     * @param[en] element Element
     */
    public func add(element: T): Unit {
        _data.add(element)
    }

    /**
     * @brief[zh-cn] 出栈
     * @return[zh-cn] 栈顶元素，栈为空时返回 None
     *
     * @brief[en] Pop element from stack
     * @return[en] Top element, or None if the stack is empty
     */
    public func remove(): ?T {
        if (_data.size == 0) { return None }
        let element = _data[_data.size - 1]
        _data.remove(at: _data.size - 1)
        return Some(element)
    }

    /**
     * @brief[zh-cn] 查看栈顶元素（不出栈）
     * @return[zh-cn] 栈顶元素，栈为空时返回 None
     *
     * @brief[en] Peek at the top element without popping
     * @return[en] Top element, or None if the stack is empty
     */
    public func peek(): ?T {
        if (_data.size == 0) { return None }
        return _data[_data.size - 1]
    }

    /**
     * @brief[zh-cn] 是否包含元素
     * @param[zh-cn] element 要查找的元素
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Check if the stack contains the specified element
     * @param[en] element Element to find
     * @return[en] Whether the element is contained
     */
    public func contains(element: T): Bool {
        return _data.contains(element)
    }

    /** 元素数量 */
    public prop size: Int64 {
        get() { _data.size }
    }

    /**
     * @brief[zh-cn] 是否为空
     * @return[zh-cn] 是否为空
     *
     * @brief[en] Check if the stack is empty
     * @return[en] Whether the stack is empty
     */
    public func isEmpty(): Bool {
        return _data.size == 0
    }

    /**
     * @brief[zh-cn] 清空栈
     *
     * @brief[en] Clear the stack
     */
    public func clear(): Unit {
        _data.clear()
    }

    /**
     * @brief[zh-cn] 转为数组（栈底到栈顶顺序）
     * @return[zh-cn] 包含所有元素的数组
     *
     * @brief[en] Convert to array (bottom to top order)
     * @return[en] Array containing all elements
     */
    public func toArray(): Array<T> {
        return _data.toArray()
    }

    /**
     * @brief[zh-cn] 迭代器
     * @return[zh-cn] 迭代器
     *
     * @brief[en] Iterator
     * @return[en] Iterator
     */
    public func iterator(): Iterator<T> {
        return _data.iterator()
    }
}
