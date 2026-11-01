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
 * @file[zh-cn] SPSCQueue 单生产者单消费者无锁队列
 * @brief[zh-cn] 定长环形缓冲 + 单调序号，push/pop 全程无锁（无 CAS、无 Mutex）
 * @explain[zh-cn] 依据《多线程改造计划》阶段 0 设计：
 * - head/tail 为**单调递增序列号**（AtomicInt64，自增不回绕），槽位索引 = seq % capacity。
 *   与"head/tail 直接当索引回绕"相比，容量满判定 `tail - head >= capacity` 无需取模，
 *   也天然支持 Abandoned 序号空间（退出时按提交-完成缺口推进栅栏）。
 * - push：写槽位 → `tail.store(t+1)`（默认顺序一致性，等效 release：数据先于 tail 可见）。
 * - pop：读 `tail` 判空 → 读槽位 → `head.store(h+1)`（默认顺序一致性，等效 acquire）。
 * - 满返回 false、空返回 None；多生产者/多消费者场景**不可使用本类**（需外部队列或 MPMC）。
 *
 * @file[en] SPSCQueue single-producer single-consumer lock-free queue
 * @brief[en] Fixed-size ring buffer with monotonic sequence numbers, lock-free push/pop (no CAS, no Mutex)
 * @explain[en] Per Phase 0 of the multi-threading refactoring plan:
 * - head/tail are *monotonic* sequence numbers (AtomicInt64, never wrap); slot index = seq % capacity.
 *   Compared with wrapping indices, full-test `tail - head >= capacity` needs no borrow/modulo,
 *   and abandoned sequence space is supported (exit advances the fence by the submit-done gap).
 * - push: write slot then `tail.store(t+1)` (default sequential consistency, release-equivalent:
 *   the datum is visible before tail advances).
 * - pop: read tail to test empty, read the slot, then `head.store(h+1)` (acquire-equivalent).
 * - Returns false when full, None when empty. Multi-producer / multi-consumer use is NOT supported
 *   (use an external queue or MPMC instead).
 */
package three.core.thread

import std.sync.AtomicInt64

/**
 * @brief[zh-cn] 单生产者单消费者无锁定长队列
 * @explain[zh-cn] 用法与 RingBuffer 相似但跨线程安全且无锁：
 * - 一个生产者线程 push、一个消费者线程 pop，角色不能互换；
 * - 容量满时 push 返回 false（调用方自旋/等待策略自行决定）；
 * - size() 为近似值（两次原子读之间可能有偏差），仅用于诊断。
 * 典型用途：逻辑线程向渲染线程投递命令（见 ThreeRenderer._renderQueue）。
 *
 * @brief[en] Lock-free fixed-capacity single-producer single-consumer queue
 * @explain[en] Same shape as RingBuffer but cross-thread safe and lock-free:
 * - one producer thread pushes and one consumer thread pops; roles must not swap;
 * - push returns false when the queue is full (spin/wait policy is up to the caller);
 * - size() is approximate (two atomic reads may skew), for diagnostics only.
 * Typical use: the logic thread posts commands to the render thread (see ThreeRenderer._renderQueue).
 */
public class SPSCQueue<T> {
    /**
     * @brief[zh-cn] 槽位数组（Option 包装，null 表示已消费）
     *
     * @brief[en] Slot array (Option-wrapped; null means consumed)
     */
    private let _buf: Array<?T>

    /**
     * @brief[zh-cn] 容量（槽位数）
     *
     * @brief[en] Capacity (number of slots)
     */
    private let _capacity: Int64

    /**
     * @brief[zh-cn] 消费者读位置（单调序号，下一个待 pop 的元素）
     *
     * @brief[en] Consumer read position (monotonic; next element to pop)
     */
    private let _head = AtomicInt64(0)

    /**
     * @brief[zh-cn] 生产者写位置（单调序号，下一个 push 的写入位）
     *
     * @brief[en] Producer write position (monotonic; next slot to push)
     */
    private let _tail = AtomicInt64(0)

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] capacity 槽位数（<=0 时默认 1024）。建议选择不小于单帧最大命令数
     *
     * @brief[en] Constructor
     * @param[en] capacity Number of slots (defaults to 1024 when <=0). Prefer >= peak per-frame traffic
     */
    public init(capacity!: Int64 = 1024) {
        let cap = if (capacity <= 0) { 1024 } else { capacity }
        _capacity = cap
        _buf = Array<?T>(cap, { _ => None })
    }

    /**
     * @brief[zh-cn] 入队
     * @param[zh-cn] v 元素
     * @return[zh-cn] true 入队成功；false 队列已满（调用方需重试或策略决断）
     *
     * @brief[en] Enqueue
     * @param[en] v Element
     * @return[en] true on success; false when full (retry or decide by policy)
     */
    public func push(v: T): Bool {
        let t = this._tail.load()
        // 满判定：head 与 tail 均为单调序号，无需取模（消费更快时 tail-head 即积压量）
        if (t - this._head.load() >= this._capacity) { return false }
        this._buf[t % this._capacity] = Some(v)
        // 先写槽位再推进 tail：消费者观察到新 tail 后必然能读到该槽位数据
        this._tail.store(t + 1)
        return true
    }

    /**
     * @brief[zh-cn] 出队
     * @return[zh-cn] 队首元素；队列为空返回 null
     *
     * @brief[en] Dequeue
     * @return[en] The front element, or null when empty
     */
    public func pop(): ?T {
        let h = this._head.load()
        // 空判定：head 追上 tail
        if (h >= this._tail.load()) { return None }
        let v: ?T = this._buf[h % this._capacity]
        // 清槽并推进 head：槽位归还给生产者（push 的满判定基于 head，按序允许覆盖）
        this._buf[h % this._capacity] = None
        this._head.store(h + 1)
        return v
    }

    /**
     * @brief[zh-cn] 是否为空（近似：两次原子读可能不同步，仅供诊断）
     * @return[zh-cn] 是否为空
     *
     * @brief[en] Whether the queue is empty (approximate: the two atomic reads may skew; diagnostics only)
     * @return[en] Whether empty
     */
    public func isEmpty(): Bool {
        return this._head.load() >= this._tail.load()
    }

    /**
     * @brief[zh-cn] 当前元素数量（近似值，仅诊断用）
     * @return[zh-cn] 近似元素数量
     *
     * @brief[en] Approximate number of elements (diagnostics only)
     * @return[en] Approximate element count
     */
    public func size(): Int64 {
        return this._tail.load() - this._head.load()
    }

    /**
     * @brief[zh-cn] 固定容量（槽位数）
     *
     * @brief[en] Fixed capacity (number of slots)
     */
    public prop capacity: Int64 {
        get() { this._capacity }
    }
}