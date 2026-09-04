/**
 * @file[zh-cn] LinkedList
 * @brief[zh-cn] 双向链表
 * @explain[zh-cn] 命名遵循仓颉 std.collection LinkedList 规范：addFirst/addLast 头尾插入、removeFirst/removeLast 头尾删除、first/last 链首链尾元素、addBefore/addAfter 在指定节点前后插入、remove 删除指定节点、clear 清空、iterator 迭代器。不使用哨兵节点（避免泛型 T 无无参构造的问题）。
 *
 * @file[en] LinkedList
 * @brief[en] Doubly linked list
 * @explain[en] Naming follows the Cangjie std.collection LinkedList specification: addFirst/addLast for head/tail insertion, removeFirst/removeLast for head/tail deletion, first/last for head/tail elements, addBefore/addAfter for insertion before/after a specified node, remove for deleting a specified node, clear, and iterator. Does not use sentinel nodes (avoiding the issue of generic T lacking a parameterless constructor).
 */
package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] 链表节点
 *
 * @brief[en] Linked list node
 */
public class LinkedListNode<T> {
    /**
     * @brief[zh-cn] 节点值
     */
    public var value: T
    /**
     * @brief[zh-cn] 前驱节点
     */
    private var _prev: ?LinkedListNode<T>
    /**
     * @brief[zh-cn] 后继节点
     */
    private var _next: ?LinkedListNode<T>

    internal init(value: T) {
        this.value = value
        this._prev = None
        this._next = None
    }

    /**
     * @brief[zh-cn] 前驱节点
     */
    public prop prev: ?LinkedListNode<T> {
        get() { _prev }
    }

    /**
     * @brief[zh-cn] 后继节点
     */
    public prop next: ?LinkedListNode<T> {
        get() { _next }
    }

    internal func setPrev(node: ?LinkedListNode<T>): Unit { _prev = node }
    internal func setNext(node: ?LinkedListNode<T>): Unit { _next = node }
}

/**
 * @brief[zh-cn] 双向链表
 * @explain[zh-cn]，不使用哨兵节点（避免泛型 T 无无参构造的问题）。
 *
 * @brief[en] Doubly linked list
 * @explain[en] Modeled after Cangjie std.collection.LinkedList, does not use sentinel nodes (avoiding the issue of generic T lacking a parameterless constructor).
 */
public class LinkedList<T> {
    /**
     * @brief[zh-cn] 头节点
     */
    private var _head: ?LinkedListNode<T>
    /**
     * @brief[zh-cn] 尾节点
     */
    private var _tail: ?LinkedListNode<T>
    /**
     * @brief[zh-cn] 元素数量
     */
    private var _size: Int64

    /**
     * @brief[zh-cn] 默认构造器
     *
     * @brief[en] Default constructor
     */
    public init() {
        _head = None
        _tail = None
        _size = 0
    }

    /**
     * @brief[zh-cn] 头部插入
     * @param[zh-cn] element 元素
     * @return[zh-cn] 新节点
     *
     * @brief[en] Insert at the head
     * @param[en] element Element
     * @return[en] New node
     */
    public func addFirst(element: T): LinkedListNode<T> {
        let node = LinkedListNode<T>(element)
        match (_head) {
            case None =>
                _head = node
                _tail = node
            case Some(oldHead) =>
                node.setNext(oldHead)
                oldHead.setPrev(node)
                _head = node
        }
        _size += 1
        return node
    }

    /**
     * @brief[zh-cn] 尾部插入
     * @param[zh-cn] element 元素
     * @return[zh-cn] 新节点
     *
     * @brief[en] Insert at the tail
     * @param[en] element Element
     * @return[en] New node
     */
    public func addLast(element: T): LinkedListNode<T> {
        let node = LinkedListNode<T>(element)
        match (_tail) {
            case None =>
                _head = node
                _tail = node
            case Some(oldTail) =>
                node.setPrev(oldTail)
                oldTail.setNext(node)
                _tail = node
        }
        _size += 1
        return node
    }

    /**
     * @brief[zh-cn] 在指定节点前插入
     * @param[zh-cn] node 目标节点
     * element 元素
     * @return[zh-cn] 新节点
     *
     * @brief[en] Insert before the specified node
     * @param[en] node Target node
     * element Element
     * @return[en] New node
     */
    public func addBefore(node: LinkedListNode<T>, element: T): LinkedListNode<T> {
        let newNode = LinkedListNode<T>(element)
        match (node.prev) {
            case None =>
                // node 是头节点
                newNode.setNext(node)
                node.setPrev(newNode)
                _head = newNode
            case Some(prev) =>
                newNode.setPrev(prev)
                newNode.setNext(node)
                prev.setNext(newNode)
                node.setPrev(newNode)
        }
        _size += 1
        return newNode
    }

    /**
     * @brief[zh-cn] 在指定节点后插入
     * @param[zh-cn] node 目标节点
     * element 元素
     * @return[zh-cn] 新节点
     *
     * @brief[en] Insert after the specified node
     * @param[en] node Target node
     * element Element
     * @return[en] New node
     */
    public func addAfter(node: LinkedListNode<T>, element: T): LinkedListNode<T> {
        let newNode = LinkedListNode<T>(element)
        match (node.next) {
            case None =>
                // node 是尾节点
                newNode.setPrev(node)
                node.setNext(newNode)
                _tail = newNode
            case Some(next) =>
                newNode.setPrev(node)
                newNode.setNext(next)
                next.setPrev(newNode)
                node.setNext(newNode)
        }
        _size += 1
        return newNode
    }

    /**
     * @brief[zh-cn] 删除头部节点
     * @return[zh-cn] 头部值，链表为空时返回 None
     *
     * @brief[en] Remove the head node
     * @return[en] Head value, or None if the list is empty
     */
    public func removeFirst(): ?T {
        match (_head) {
            case None => return None
            case Some(node) =>
                let value = node.value
                _removeNode(node)
                return Some(value)
        }
    }

    /**
     * @brief[zh-cn] 删除尾部节点
     * @return[zh-cn] 尾部值，链表为空时返回 None
     *
     * @brief[en] Remove the tail node
     * @return[en] Tail value, or None if the list is empty
     */
    public func removeLast(): ?T {
        match (_tail) {
            case None => return None
            case Some(node) =>
                let value = node.value
                _removeNode(node)
                return Some(value)
        }
    }

    /**
     * @brief[zh-cn] 删除指定节点
     * @param[zh-cn] node 要删除的节点
     *
     * @brief[en] Remove the specified node
     * @param[en] node Node to remove
     */
    public func remove(node: LinkedListNode<T>): Unit {
        _removeNode(node)
    }

    /**
     * @brief[zh-cn] 链首元素
     */
    public prop first: ?T {
        get() {
            match (_head) {
                case None => return None
                case Some(node) => return node.value
            }
        }
    }

    /**
     * @brief[zh-cn] 链尾元素
     */
    public prop last: ?T {
        get() {
            match (_tail) {
                case None => return None
                case Some(node) => return node.value
            }
        }
    }

    /**
     * @brief[zh-cn] 链首节点
     */
    public prop firstNode: ?LinkedListNode<T> {
        get() { _head }
    }

    /**
     * @brief[zh-cn] 链尾节点
     */
    public prop lastNode: ?LinkedListNode<T> {
        get() { _tail }
    }

    /**
     * @brief[zh-cn] 元素数量
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

    /**
     * @brief[zh-cn] 清空链表
     */
    public func clear(): Unit {
        _head = None
        _tail = None
        _size = 0
    }

    /**
     * @brief[zh-cn] 转为数组（从头到尾）
     */
    public func toArray(): Array<T> {
        let list = ArrayList<T>()
        var node = _head
        while (true) {
            match (node) {
                case None => break
                case Some(n) =>
                    list.add(n.value)
                    node = n.next
            }
        }
        return Array<T>(list.size, { i => list[i] })
    }

    /** 迭代器 */
    public func iterator(): Iterator<T> {
        return toArray().iterator()
    }

    // ===== 内部方法 =====

    /** 内部删除节点（断开前后链接） */
    private func _removeNode(node: LinkedListNode<T>): Unit {
        let prev = node.prev
        let next = node.next

        match (prev) {
            case None => _head = next
            case Some(p) => p.setNext(next)
        }
        match (next) {
            case None => _tail = prev
            case Some(n) => n.setPrev(prev)
        }
        node.setPrev(None)
        node.setNext(None)
        _size -= 1
    }
}
