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
 * otherwise be required by Sections 4(a), 5(b) and 6(d) of the License.
 *
 * @file[zh-cn] LRU 缓存
 * @brief[zh-cn] 定容量的最近最少使用缓存（哈希表 + 侵入式双向链表，O(1) 全操作）
 * @explain[zh-cn] 引擎里多处使用 HashMap 做"只增不减"的缓存（渲染对象缓存、材质状态、
 *             program 变体缓存等）。场景频繁增删对象时，这些缓存会无界增长：
 *             键是 (mesh.id, material.id, camera.id) 组合，mesh 被移除后其条目永远
 *             留着，RenderObject 又持有 mesh / geometry / material / camera / scene
 *             的强引用 —— 对象无法回收，表现为"场景改了之后内存一直涨"。
 *
 *             本类提供定容量的 LRU 语义：超过容量时淘汰最久未使用的条目，
 *             被淘汰对象随之释放引用。
 *
 * @file[en] LRU cache
 * @brief[en] Fixed-capacity least-recently-used cache (hash map + intrusive doubly linked list, O(1) for all operations)
 * @explain[en] The engine uses HashMap in several "grow-only" caches (render object
 *             cache, material states, program variant cache, ...). When objects are
 *             frequently added to and removed from the scene, those caches grow
 *             without bound: the key is the (mesh.id, material.id, camera.id)
 *             combination, and once a mesh is removed its entry stays forever while
 *             the RenderObject still holds strong references to the mesh, geometry,
 *             material, camera and scene — so the objects can never be reclaimed.
 *
 *             This class provides fixed-capacity LRU semantics: the least recently
 *             used entry is evicted when the capacity is exceeded, releasing its
 *             references.
 */

package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] LRU 链表节点（文件级私有类：仓颉不允许 class 内嵌套 class）
 *
 * @brief[en] LRU list node (file-level private class: Cangjie forbids nested class declarations)
 */
private class LruNode<K, V> {
    /** 键 */
    var key: K
    /** 值 */
    var value: V
    /** 前驱（更久未使用的一侧） */
    var prev: ?LruNode<K, V> = None
    /** 后继（最近使用的一侧） */
    var next: ?LruNode<K, V> = None

    init(key: K, value: V) {
        this.key = key
        this.value = value
    }
}

/**
 * @brief[zh-cn] 定容量 LRU 缓存
 * @explain[zh-cn] 哈希表负责 O(1) 查找，侵入式双向链表负责 O(1) 的"移到最新"与
 *             "淘汰最旧"。容量 <= 0 表示不限制（此时退化为普通哈希表）。
 *             用法：
 * ```
 * let cache = LruCache<Int64, String>(1024)
 * match (cache.get(7)) {
 *     case Some(v) => println(v)
 *     case None => cache.put(7, "seven")
 * }
 * ```
 *
 * @brief[en] Fixed-capacity LRU cache
 * @explain[en] A hash map provides O(1) lookup while an intrusive doubly linked list
 *             provides O(1) "move to newest" and "evict oldest". A capacity <= 0 means
 *             unlimited (the cache then degenerates into a plain hash map). Usage:
 * ```
 * let cache = LruCache<Int64, String>(1024)
 * match (cache.get(7)) {
 *     case Some(v) => println(v)
 *     case None => cache.put(7, "seven")
 * }
 * ```
 *
 * @param[zh-cn] K 键类型（须满足 Hashable & Equatable<K>）
 * V 值类型
 *
 * @brief[en] K Key type (must satisfy Hashable & Equatable<K>)
 * V Value type
 */
public class LruCache<K, V> where K <: Hashable & Equatable<K> {
    /**
     * @brief[zh-cn] 键 -> 链表节点
     *
     * @brief[en] Key -> list node
     */
    private var _map: HashMap<K, LruNode<K, V>> = HashMap<K, LruNode<K, V>>()
    /**
     * @brief[zh-cn] 最久未使用的节点（淘汰端）
     *
     * @brief[en] Least recently used node (eviction end)
     */
    private var _head: ?LruNode<K, V> = None
    /**
     * @brief[zh-cn] 最近使用的节点
     *
     * @brief[en] Most recently used node
     */
    private var _tail: ?LruNode<K, V> = None
    /**
     * @brief[zh-cn] 容量上限（<= 0 表示不限制）
     *
     * @brief[en] Capacity limit (<= 0 means unlimited)
     */
    private var _capacity: Int64
    /**
     * @brief[zh-cn] 命中次数
     *
     * @brief[en] Number of hits
     */
    private var _hits: Int64 = 0
    /**
     * @brief[zh-cn] 未命中次数
     *
     * @brief[en] Number of misses
     */
    private var _misses: Int64 = 0
    /**
     * @brief[zh-cn] 累计淘汰次数
     *
     * @brief[en] Total number of evictions
     */
    private var _evictions: Int64 = 0

    /**
     * @brief[zh-cn] 构造 LRU 缓存
     * @param[zh-cn] capacity 容量上限（<= 0 表示不限制）
     *
     * @brief[en] Constructs an LRU cache
     * @param[en] capacity Capacity limit (<= 0 means unlimited)
     */
    public init(capacity: Int64) {
        this._capacity = capacity
    }

    /**
     * @brief[zh-cn] 构造不限容量的 LRU 缓存
     *
     * @brief[en] Constructs an LRU cache with unlimited capacity
     */
    public init() {
        this._capacity = 0
    }

    /**
     * @brief[zh-cn] 容量上限
     *
     * @brief[en] Capacity limit
     */
    public prop capacity: Int64 {
        get() { this._capacity }
    }

    /**
     * @brief[zh-cn] 设置容量上限
     * @explain[zh-cn] 缩小容量时立即淘汰最久未使用的条目，直到条目数不超过新容量。
     * @param[zh-cn] value 新容量（<= 0 表示不限制）
     *
     * @brief[en] Sets the capacity limit
     * @explain[en] When the capacity shrinks, the least recently used entries are
     *               evicted immediately until the entry count fits the new capacity.
     * @param[en] value New capacity (<= 0 means unlimited)
     */
    public func setCapacity(value: Int64): Unit {
        this._capacity = value
        this._evictIfNeeded()
    }

    /**
     * @brief[zh-cn] 当前条目数
     *
     * @brief[en] Current number of entries
     */
    public prop size: Int64 {
        get() { this._map.size }
    }

    /**
     * @brief[zh-cn] 是否为空
     *
     * @brief[en] Whether the cache is empty
     */
    public func isEmpty(): Bool {
        return this._map.isEmpty()
    }

    /**
     * @brief[zh-cn] 命中次数
     *
     * @brief[en] Number of hits
     */
    public prop hits: Int64 {
        get() { this._hits }
    }

    /**
     * @brief[zh-cn] 未命中次数
     *
     * @brief[en] Number of misses
     */
    public prop misses: Int64 {
        get() { this._misses }
    }

    /**
     * @brief[zh-cn] 累计淘汰次数
     *
     * @brief[en] Total number of evictions
     */
    public prop evictions: Int64 {
        get() { this._evictions }
    }

    /**
     * @brief[zh-cn] 查询键对应的值（命中时把该条目移到"最近使用"端）
     * @param[zh-cn] key 键
     * @return[zh-cn] 命中返回 Some(值)，未命中返回 None
     *
     * @brief[en] Looks up the value for a key (on a hit the entry moves to the most-recently-used end)
     * @param[en] key Key
     * @return[en] Some(value) on a hit, None on a miss
     */
    public func get(key: K): ?V {
        if (let Some(node) <- this._map.get(key)) {
            this._hits += 1
            this._moveToTail(node)
            return Some(node.value)
        } else {
            this._misses += 1
            return None
        }
    }

    /**
     * @brief[zh-cn] 查询键对应的值但不改变使用顺序
     * @param[zh-cn] key 键
     * @return[zh-cn] 命中返回 Some(值)，未命中返回 None
     *
     * @brief[en] Looks up the value for a key without changing the recency order
     * @param[en] key Key
     * @return[en] Some(value) on a hit, None on a miss
     */
    public func peek(key: K): ?V {
        if (let Some(node) <- this._map.get(key)) {
            return Some(node.value)
        } else {
            return None
        }
    }

    /**
     * @brief[zh-cn] 是否包含键（不改变使用顺序）
     * @param[zh-cn] key 键
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Whether the key is present (without changing the recency order)
     * @param[en] key Key
     * @return[en] Whether the key is present
     */
    public func contains(key: K): Bool {
        return this._map.contains(key)
    }

    /**
     * @brief[zh-cn] 写入键值对（已存在则更新值并移到"最近使用"端）
     * @explain[zh-cn] 写入后若条目数超过容量，淘汰最久未使用的条目。
     * @param[zh-cn] key 键
     * value 值
     *
     * @brief[en] Puts a key/value pair (an existing key is updated and moved to the most-recently-used end)
     * @explain[en] When the number of entries exceeds the capacity, the least recently used entry is evicted.
     * @param[en] key Key
     * value Value
     */
    public func put(key: K, value: V): Unit {
        if (let Some(node) <- this._map.get(key)) {
            node.value = value
            this._moveToTail(node)
            return
        }
        let node = LruNode<K, V>(key, value)
        this._map.add(key, node)
        this._pushBack(node)
        this._evictIfNeeded()
    }

    /**
     * @brief[zh-cn] 移除指定键
     * @param[zh-cn] key 键
     * @return[zh-cn] 被移除的值（不存在则 None）
     *
     * @brief[en] Removes the given key
     * @param[en] key Key
     * @return[en] The removed value (None if the key was absent)
     */
    public func remove(key: K): ?V {
        if (let Some(node) <- this._map.get(key)) {
            this._unlink(node)
            this._map.remove(key)
            return Some(node.value)
        } else {
            return None
        }
    }

    /**
     * @brief[zh-cn] 清空缓存
     *
     * @brief[en] Clears the cache
     */
    public func clear(): Unit {
        this._map.clear()
        this._head = None
        this._tail = None
    }

    /**
     * @brief[zh-cn] 重置统计计数（命中/未命中/淘汰）
     *
     * @brief[en] Resets the statistics counters (hits/misses/evictions)
     */
    public func resetStats(): Unit {
        this._hits = 0
        this._misses = 0
        this._evictions = 0
    }

    /**
     * @brief[zh-cn] 超出容量时淘汰最久未使用的条目
     *
     * @brief[en] Evicts the least recently used entry when the capacity is exceeded
     */
    private func _evictIfNeeded(): Unit {
        if (this._capacity <= 0) { return }
        while (this._map.size > this._capacity) {
            if (let Some(oldest) <- this._head) {
                this._unlink(oldest)
                this._map.remove(oldest.key)
                this._evictions += 1
            } else {
                return
            }
        }
    }

    /**
     * @brief[zh-cn] 把节点移到链表尾部（最近使用端）
     * @param[zh-cn] node 节点
     *
     * @brief[en] Moves a node to the tail of the list (most recently used end)
     * @param[en] node Node
     */
    private func _moveToTail(node: LruNode<K, V>): Unit {
        if (refEq(this._tail.getOrThrow(), node)) { return }
        this._unlink(node)
        this._pushBack(node)
    }

    /**
     * @brief[zh-cn] 把节点追加到链表尾部
     * @param[zh-cn] node 节点
     *
     * @brief[en] Appends a node to the tail of the list
     * @param[en] node Node
     */
    private func _pushBack(node: LruNode<K, V>): Unit {
        node.prev = this._tail
        node.next = None
        if (let Some(t) <- this._tail) {
            t.next = Some(node)
        } else {
            this._head = Some(node)
        }
        this._tail = Some(node)
    }

    /**
     * @brief[zh-cn] 把节点从链表中摘除
     * @param[zh-cn] node 节点
     *
     * @brief[en] Unlinks a node from the list
     * @param[en] node Node
     */
    private func _unlink(node: LruNode<K, V>): Unit {
        if (let Some(p) <- node.prev) {
            p.next = node.next
        } else {
            this._head = node.next
        }
        if (let Some(n) <- node.next) {
            n.prev = node.prev
        } else {
            this._tail = node.prev
        }
        node.prev = None
        node.next = None
    }
}
