/**
 * @file[zh-cn] BinaryHeap
 * @brief[zh-cn] 二叉堆（默认最小堆），支持最大堆和最小堆
 * @explain[zh-cn] 底层使用 ArrayList<T> 存储堆节点，通过节点自带的 index 字段实现 O(log n) 的 push/pop/remove/update 操作。
 *
 * @file[en] BinaryHeap
 * @brief[en] Binary heap (default min-heap), supports both max-heap and min-heap
 * @explain[en] Uses ArrayList<T> internally to store heap nodes, achieving O(log n) push/pop/remove/update operations through the node's built-in index field.
 */
package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] 堆节点接口
 * @explain[zh-cn] 堆节点需要维护自身在堆中的索引（index），以便支持 O(log n) 的 remove/update。
 *
 * @brief[en] Heap node interface
 * @explain[en] Heap nodes need to maintain their index in the heap to support O(log n) remove/update operations.
 */
public interface HeapNode {
    /**
     * @brief[zh-cn] 在堆中的索引，-1 表示不在堆中
     */
    mut prop index: Int64

    /**
     * @brief[zh-cn] 比较函数
     * @param[zh-cn] other 另一个节点
     * @return[zh-cn] true 表示 this 比 other 更优先（应排在更前面）
     *
     * @brief[en] Comparison function
     * @param[en] other Another node
     * @return[en] true means this has higher priority than other (should be placed ahead)
     */
    func lessThan(other: HeapNode): Bool
}

/**
 * @brief[zh-cn] 二叉堆（默认最小堆）
 * @explain[zh-cn] 通过 HeapNode.lessThan 决定堆的性质：lessThan 返回 true 表示 this 更优先 → 最小堆；若需最大堆，让 lessThan 返回 this > other 的判断。
 *
 * @brief[en] Binary heap (default min-heap)
 * @explain[en] The heap property is determined by HeapNode.lessThan: lessThan returning true means this has higher priority → min-heap; for max-heap, have lessThan return the this > other comparison.
 */
public class BinaryHeap<T> where T <: HeapNode {
    /**
     * @brief[zh-cn] 内部节点数组
     */
    private let _nodes: ArrayList<T>
    /**
     * @brief[zh-cn] 当前堆大小
     */
    private var _size: Int64
    /**
     * @brief[zh-cn] 当前容量
     */
    private var _capacity: Int64

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] capacity 初始容量（<=0 时默认 4）
     *
     * @brief[en] Constructor
     * @param[en] capacity Initial capacity (defaults to 4 when <=0)
     */
    public init(capacity: Int64) {
        _size = 0
        _capacity = if (capacity <= 0) { 4 } else { capacity }
        _nodes = ArrayList<T>(_capacity)
    }

    /**
     * @brief[zh-cn] 默认构造器，容量 4
     */
    public init() {
        _size = 0
        _capacity = 4
        _nodes = ArrayList<T>(4)
    }

    /**
     * @brief[zh-cn] 清空堆
     *
     * @brief[en] Clear the heap
     */
    public func clear(): Unit {
        _size = 0
    }

    /**
     * @brief[zh-cn] 获取节点
     * @param[zh-cn] index 节点索引
     * @return[zh-cn] 节点
     *
     * @brief[en] Get a node
     * @param[en] index Node index
     * @return[en] Node
     */
    public func get(index: Int64): T {
        return _nodes[index]
    }

    /**
     * @brief[zh-cn] 获取顶部节点（堆顶）
     * @return[zh-cn] 堆顶节点
     *
     * @brief[en] Get the top node (heap top)
     * @return[en] Top node
     */
    public func top(): T {
        return _nodes[0]
    }

    /**
     * @brief[zh-cn] 是否包含节点
     * @param[zh-cn] node 节点
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Whether the heap contains the node
     * @param[en] node Node
     * @return[en] Whether contained
     */
    public func contains(node: T): Bool {
        let idx = node.index
        return idx >= 0 && idx < _size
    }

    /**
     * @brief[zh-cn] Push 节点到堆中
     * @param[zh-cn] node 节点
     *
     * @brief[en] Push a node into the heap
     * @param[en] node Node
     */
    public func push(node: T): Unit {
        _size += 1
        if (_size > _capacity) {
            _capacity = _capacity * 2
            _nodes.add(node)
        } else {
            if (_size - 1 < _nodes.size) {
                _nodes[_size - 1] = node
            } else {
                _nodes.add(node)
            }
        }
        _sortUp(node, _size - 1)
    }

    /**
     * @brief[zh-cn] Pop 堆顶节点
     * @return[zh-cn] 堆顶节点，堆为空时返回 None
     *
     * @brief[en] Pop the top node from the heap
     * @return[en] Top node, or None if the heap is empty
     */
    public func pop(): ?T {
        if (_size == 0) {
            return None
        }
        var node = _nodes[0]
        node.index = -1
        _size -= 1
        if (_size > 0) {
            // 将最后一个元素移到堆顶，然后下沉调整
            var finalNode = _nodes[_size]
            finalNode.index = 0
            _nodes[0] = finalNode
            _sortDown(finalNode, 0)
        }
        return Some(node)
    }

    /**
     * @brief[zh-cn] 移除指定节点
     * @param[zh-cn] node 要移除的节点
     *
     * @brief[en] Remove a specified node
     * @param[en] node Node to remove
     */
    public func remove(node: T): Unit {
        if (!contains(node)) { return }
        _size -= 1
        var newNode = _nodes[_size]
        _nodes[node.index] = newNode
        newNode.index = node.index
        update(newNode)
        var rmNode = node
        rmNode.index = -1
    }

    /**
     * @brief[zh-cn] 更新节点位置（节点优先级变化后调用）
     * @param[zh-cn] node 要更新的节点
     * @return[zh-cn] true 表示更新成功
     *
     * @brief[en] Update node position (call after node priority changes)
     * @param[en] node Node to update
     * @return[en] true if update succeeded
     */
    public func update(node: T): Bool {
        if (!contains(node)) { return false }
        let index = node.index
        if (index > 0 && node.lessThan(_nodes[_parent(index)])) {
            _sortUp(node, index)
        } else {
            _sortDown(node, index)
        }
        return true
    }

    /**
     * @brief[zh-cn] 当前元素数量
     */
    public prop size: Int64 {
        get() { _size }
    }

    /**
     * @brief[zh-cn] 是否为空
     */
    public func isEmpty(): Bool {
        return _size == 0
    }

    // ===== 内部方法 =====

    /**
     * @brief[zh-cn] 父节点索引
     */
    private func _parent(index: Int64): Int64 {
        return (index - 1) >> 1
    }

    /**
     * @brief[zh-cn] 上浮调整
     */
    private func _sortUp(node: T, index: Int64): Unit {
        var idx = index
        var parentIndex = _parent(idx)
        var mutableNode = node
        while (idx > 0 && mutableNode.lessThan(_nodes[parentIndex])) {
            var parent = _nodes[parentIndex]
            parent.index = idx
            _nodes[idx] = parent
            idx = parentIndex
            parentIndex = _parent(parentIndex)
        }
        mutableNode.index = idx
        _nodes[idx] = mutableNode
    }

    /**
     * @brief[zh-cn] 下沉调整
     */
    private func _sortDown(node: T, index: Int64): Unit {
        var idx = index
        var childIndex = (idx << 1) + 1
        var mutableNode = node
        while (childIndex < _size) {
            var bestChild: T = mutableNode
            var bestIndex = idx
            // 左子
            if (_nodes[childIndex].lessThan(bestChild)) {
                bestChild = _nodes[childIndex]
                bestIndex = childIndex
            }
            // 右子
            if (childIndex + 1 < _size && _nodes[childIndex + 1].lessThan(bestChild)) {
                bestChild = _nodes[childIndex + 1]
                bestIndex = childIndex + 1
            }
            // 没有更优的子节点，停止下沉
            if (bestIndex == idx) {
                break
            }
            // 交换下沉
            bestChild.index = idx
            _nodes[idx] = bestChild
            idx = bestIndex
            childIndex = (idx << 1) + 1
        }
        mutableNode.index = idx
        _nodes[idx] = mutableNode
    }
}
