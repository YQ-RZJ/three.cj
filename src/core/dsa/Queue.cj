/**
 * @file[zh-cn] Queue
 * @brief[zh-cn] 动态队列（先进先出）
 * @explain[zh-cn] 底层使用 Array<?T> + 头尾指针实现环形缓冲区，出队时只需移动 head 指针，避免数组元素搬移。当 head 超过半数时执行一次紧凑压缩。
 *
 * @file[en] Queue
 * @brief[en] Dynamic queue (first-in-first-out)
 * @explain[en] Uses Array<?T> + head/tail pointers for ring buffer implementation; dequeue only moves the head pointer, avoiding array element shifting. Performs compaction when head exceeds half the capacity.
 */
package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] 动态队列（先进先出）
 * @explain[zh-cn]，使用 Array<?T> + 头尾索引实现。使用 Array<?T> 而非 Array<T> 以避免泛型 T 需要无参构造函数的限制。类型参数约束：T <: Equatable<T>（仅用于 contains 方法）。
 *
 * @brief[en] Dynamic queue (first-in-first-out)
 * @explain[en] Modeled after Cangjie std.collection.ArrayQueue, using Array<?T> + head/tail indices. Uses Array<?T> instead of Array<T> to avoid the limitation that generic T requires a parameterless constructor. Type parameter constraint: T <: Equatable<T> (only for the contains method).
 */
public class Queue<T> where T <: Equatable<T> {
    /**
     * @brief[zh-cn] 内部存储数组（Option 包装）
     */
    private var _data: Array<?T>
    /**
     * @brief[zh-cn] 队首索引
     */
    private var _head: Int64
    /**
     * @brief[zh-cn] 队尾索引（下一个写入位置）
     */
    private var _tail: Int64
    /**
     * @brief[zh-cn] 元素数量
     */
    private var _size: Int64
    /**
     * @brief[zh-cn] 数组容量
     */
    private var _capacity: Int64

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] capacity 初始容量（<=0 时默认 16）
     *
     * @brief[en] Constructor
     * @param[en] capacity Initial capacity (defaults to 16 when <=0)
     */
    public init(capacity!: Int64 = 16) {
        _capacity = if (capacity <= 0) { 16 } else { capacity }
        _data = Array<?T>(_capacity, { _ => None })
        _head = 0
        _tail = 0
        _size = 0
    }

    /**
     * @brief[zh-cn] 入队
     * @param[zh-cn] element 元素
     *
     * @brief[en] Enqueue
     * @param[en] element Element
     */
    public func add(element: T): Unit {
        if (_size >= _capacity) {
            _expand()
        }
        _data[_tail] = Some(element)
        _tail = (_tail + 1) % _capacity
        _size += 1
    }

    /**
     * @brief[zh-cn] 出队
     * @return[zh-cn] 队首元素，队列为空时返回 None
     *
     * @brief[en] Dequeue
     * @return[en] Front element, or None if the queue is empty
     */
    public func remove(): ?T {
        if (_size == 0) { return None }
        let element = _data[_head]
        _data[_head] = None
        _head = (_head + 1) % _capacity
        _size -= 1
        // 当 head 移动超过容量一半时，紧凑数组
        if (_head > _capacity / 2 && _size > 0) {
            _compact()
        }
        return element
    }

    /**
     * @brief[zh-cn] 查看队首元素（不出队）
     * @return[zh-cn] 队首元素，队列为空时返回 None
     *
     * @brief[en] Peek at the front element without dequeuing
     * @return[en] Front element, or None if the queue is empty
     */
    public func peek(): ?T {
        if (_size == 0) { return None }
        return _data[_head]
    }

    /**
     * @brief[zh-cn] 是否包含元素
     * @param[zh-cn] element 要查找的元素
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Check if the queue contains the specified element
     * @param[en] element Element to find
     * @return[en] Whether the element is contained
     */
    public func contains(element: T): Bool {
        for (i in 0.._size) {
            let idx = (_head + i) % _capacity
            match (_data[idx]) {
                case Some(e) => if (e == element) { return true }
                case None => ()
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 元素数量
     *
     * @brief[en] Number of elements
     */
    public prop size: Int64 {
        get() { _size }
    }

    /**
     * @brief[zh-cn] 是否为空
     * @return[zh-cn] 是否为空
     *
     * @brief[en] Check if the queue is empty
     * @return[en] Whether the queue is empty
     */
    public func isEmpty(): Bool {
        return _size == 0
    }

    /**
     * @brief[zh-cn] 清空队列
     *
     * @brief[en] Clear the queue
     */
    public func clear(): Unit {
        for (i in 0.._capacity) {
            _data[i] = None
        }
        _head = 0
        _tail = 0
        _size = 0
    }

    /**
     * @brief[zh-cn] 转为数组
     * @return[zh-cn] 包含所有元素的数组
     *
     * @brief[en] Convert to array
     * @return[en] Array containing all elements
     */
    public func toArray(): Array<T> {
        let result = ArrayList<T>()
        for (i in 0.._size) {
            let idx = (_head + i) % _capacity
            match (_data[idx]) {
                case Some(e) => result.add(e)
                case None => ()
            }
        }
        let size = result.size
        return Array<T>(size, { i => result[i] })
    }

    /**
     * @brief[zh-cn] 扩容
     */
    private func _expand(): Unit {
        let newCapacity = _capacity * 2
        let newData = Array<?T>(newCapacity, { _ => None })
        for (i in 0.._size) {
            let idx = (_head + i) % _capacity
            newData[i] = _data[idx]
        }
        _data = newData
        _head = 0
        _tail = _size
        _capacity = newCapacity
    }

    /**
     * @brief[zh-cn] 紧凑压缩
     */
    private func _compact(): Unit {
        let newData = Array<?T>(_capacity, { _ => None })
        for (i in 0.._size) {
            let idx = (_head + i) % _capacity
            newData[i] = _data[idx]
        }
        _data = newData
        _head = 0
        _tail = _size
    }

    /**
     * @brief[zh-cn] 迭代器
     * @return[zh-cn] 迭代器
     *
     * @brief[en] Iterator
     * @return[en] Iterator
     */
    public func iterator(): Iterator<T> {
        let snapshot = toArray()
        return snapshot.iterator()
    }
}
