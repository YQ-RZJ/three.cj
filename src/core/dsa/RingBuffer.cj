/**
 * @file[zh-cn] RingBuffer
 * @brief[zh-cn] 环形队列（固定容量，先进先出）
 * @explain[zh-cn] 底层使用固定容量 Array<?T> + 环形指针实现，无需扩容，入队/出队均为 O(1)。适合流式数据、音频缓冲、帧缓冲等场景。使用 Array<?T> 而非 Array<T> 以避免泛型 T 需要无参构造函数的限制。
 *
 * @file[en] RingBuffer
 * @brief[en] Ring buffer (fixed capacity, first-in-first-out)
 * @explain[en] Uses fixed-capacity Array<?T> + ring pointers, no expansion needed, enqueue/dequeue are both O(1). Suitable for streaming data, audio buffers, frame buffers, etc. Uses Array<?T> instead of Array<T> to avoid the limitation that generic T requires a parameterless constructor.
 */
package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] 环形队列（固定容量）
 * @explain[zh-cn] 与 Queue 不同，RingBuffer 容量固定不可扩容。入队时若队列已满，可选择覆盖最旧元素或返回 false。
 *
 * @brief[en] Ring buffer (fixed capacity)
 * @explain[en] Unlike Queue, RingBuffer has a fixed capacity that cannot be expanded. When the queue is full, you can choose to overwrite the oldest element or return false.
 */
public class RingBuffer<T> {
    /**
     * @brief[zh-cn] 内部存储数组（Option 包装）
     */
    private let _data: Array<?T>
    /**
     * @brief[zh-cn] 容量
     */
    private let _capacity: Int64
    /**
     * @brief[zh-cn] 队首索引
     */
    private var _head: Int64
    /**
     * @brief[zh-cn] 元素数量
     */
    private var _size: Int64
    /**
     * @brief[zh-cn] 是否覆盖模式（队列满时覆盖最旧元素）
     */
    private let _overwrite: Bool

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] capacity 固定容量（<=0 时默认 16）
     * overwrite 队列满时是否覆盖最旧元素（默认 true）
     *
     * @brief[en] Constructor
     * @param[en] capacity Fixed capacity (defaults to 16 when <=0)
     * overwrite Whether to overwrite the oldest element when the queue is full (default true)
     */
    public init(capacity: Int64, overwrite!: Bool = true) {
        _capacity = if (capacity <= 0) { 16 } else { capacity }
        _data = Array<?T>(_capacity, { _ => None })
        _head = 0
        _size = 0
        _overwrite = overwrite
    }

    /**
     * @brief[zh-cn] 入队
     * @param[zh-cn] element 元素
     * @return[zh-cn] true 入队成功；false 队列已满且不覆盖
     *
     * @brief[en] Enqueue
     * @param[en] element Element
     * @return[en] true if enqueued successfully; false if the queue is full and overwrite is disabled
     */
    public func add(element: T): Bool {
        if (_size >= _capacity) {
            if (!_overwrite) { return false }
            // 覆盖最旧元素：head 前移
            _data[_head] = Some(element)
            _head = (_head + 1) % _capacity
            return true
        }
        // 正常入队
        let tail = (_head + _size) % _capacity
        _data[tail] = Some(element)
        _size += 1
        return true
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
     * @brief[zh-cn] 查看队尾元素（不出队）
     * @return[zh-cn] 队尾元素，队列为空时返回 None
     *
     * @brief[en] Peek at the last element without dequeuing
     * @return[en] Last element, or None if the queue is empty
     */
    public func peekLast(): ?T {
        if (_size == 0) { return None }
        let tail = (_head + _size - 1) % _capacity
        return _data[tail]
    }

    /**
     * @brief[zh-cn] 当前元素数量
     *
     * @brief[en] Current number of elements
     */
    public prop size: Int64 {
        get() { _size }
    }

    /**
     * @brief[zh-cn] 固定容量
     *
     * @brief[en] Fixed capacity
     */
    public prop capacity: Int64 {
        get() { _capacity }
    }

    /**
     * @brief[zh-cn] 是否为空
     * @return[zh-cn] 是否为空
     *
     * @brief[en] Check if the buffer is empty
     * @return[en] Whether the buffer is empty
     */
    public func isEmpty(): Bool {
        return _size == 0
    }

    /**
     * @brief[zh-cn] 是否已满
     * @return[zh-cn] 是否已满
     *
     * @brief[en] Check if the buffer is full
     * @return[en] Whether the buffer is full
     */
    public func isFull(): Bool {
        return _size >= _capacity
    }

    /**
     * @brief[zh-cn] 清空
     *
     * @brief[en] Clear the buffer
     */
    public func clear(): Unit {
        for (i in 0.._capacity) {
            _data[i] = None
        }
        _head = 0
        _size = 0
    }

    /**
     * @brief[zh-cn] 按索引获取元素（0=队首，size-1=队尾）
     * @param[zh-cn] index 索引
     * @return[zh-cn] 元素，索引越界时返回 None
     *
     * @brief[en] Get element by index (0=front, size-1=back)
     * @param[en] index Index
     * @return[en] Element, or None if index is out of bounds
     */
    public func get(index: Int64): ?T {
        if (index < 0 || index >= _size) {
            return None
        }
        let actualIdx = (_head + index) % _capacity
        return _data[actualIdx]
    }

    /**
     * @brief[zh-cn] 转为数组（队首到队尾顺序）
     * @return[zh-cn] 包含所有元素的数组
     *
     * @brief[en] Convert to array (front to back order)
     * @return[en] Array containing all elements
     */
    public func toArray(): Array<T> {
        let list = ArrayList<T>()
        for (i in 0.._size) {
            match (_data[(_head + i) % _capacity]) {
                case Some(e) => list.add(e)
                case None => ()
            }
        }
        return Array<T>(list.size, { i => list[i] })
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
