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
 * @file[zh-cn] IdAllocator ID 分配器
 * @brief[zh-cn] 提供唯一 ID 的分配与回收复用能力，独立工具类，不绑定类继承结构
 * @explain[zh-cn] 维护一个递增计数器与一个空闲 ID 栈：allocate 优先复用已回收的 ID，
 * 否则从计数器取新 ID；release 将 ID 回收进空闲栈供后续复用。
 *
 * @file[en] IdAllocator  ID allocator
 * @brief[en] Provides allocation and reuse of unique IDs; an independent utility class
 * not tied to any class hierarchy
 * @explain[en] Maintains a monotonic counter and a free-ID stack: allocate() reuses a
 * recycled ID first, otherwise returns a fresh one from the counter; release()
 * pushes the ID back into the free stack for later reuse.
 *
 * @package three.utils.allocator
 */
package three.utils.allocator

import std.collection.*

/**
 * @brief[zh-cn] ID 分配器
 * @explain[zh-cn] 为对象实例分配/回收唯一 ID，避免每次新建都重新编号。用法：
 * ```
 * class Entity {
 * static let idGen = IdAllocator(0)
 * let id: Int64
 * init() { id = idGen.allocate() }
 * func release() { idGen.release(id) }
 * }
 * ```
 *
 * @brief[en] ID allocator
 * @explain[en] Allocates/recycles unique IDs for object instances to avoid renumbering on
 * every creation. Usage:
 * ```
 * class Entity {
 * static let idGen = IdAllocator(0)
 * let id: Int64
 * init() { id = idGen.allocate() }
 * func release() { idGen.release(id) }
 * }
 * ```
 *
 * @note[zh-cn] 起始 ID 在构造时指定（默认 0）；不是线程安全的，多线程场景需外部加锁。
 * @note[en] The start ID is given at construction (default 0); not thread-safe, so an
 * external lock is required in multi-threaded scenarios.
 */
public class IdAllocator {
    /** 下一个待分配的 ID */
    private var _nextId: Int64
    /** 已回收的空闲 ID 池（栈结构） */
    private let _freeIds: ArrayList<Int64> = ArrayList<Int64>()

    /**
     * @brief[zh-cn] 构造分配器
     * @param[zh-cn] startId 起始 ID（默认 0）
     *
     * @brief[en] Constructs an allocator
     * @param[en] startId The start ID (default 0)
     */
    public init(startId!: Int64 = 0) {
        _nextId = startId
    }

    /**
     * @brief[zh-cn] 分配一个新 ID（优先复用已回收的 ID）
     * @return[zh-cn] 新分配的 ID
     *
     * @brief[en] Allocates a new ID (reuses a recycled one first)
     * @return[en] The newly allocated ID
     */
    public func allocate(): Int64 {
        if (_freeIds.size > 0) {
            let last = _freeIds.size - 1
            let id = _freeIds.get(last).getOrThrow()
            _freeIds.remove(last..last + 1)
            return id
        }
        let id = _nextId
        _nextId = _nextId + 1
        return id
    }

    /**
     * @brief[zh-cn] 回收 ID，供后续复用
     * @param[zh-cn] id 待回收的 ID
     *
     * @brief[en] Recycles an ID for later reuse
     * @param[en] id The ID to recycle
     */
    public func release(id: Int64): Unit {
        _freeIds.add(id)
    }

    /**
     * @brief[zh-cn] 重置分配器（清空空闲池，重置起始计数）
     *
     * @brief[en] Resets the allocator (clears the free pool and resets the counter)
     */
    public func reset(): Unit {
        _nextId = 0
        _freeIds.clear()
    }

    /**
     * @brief[zh-cn] 当前空闲 ID 数量
     * @return[zh-cn] 空闲 ID 数量
     *
     * @brief[en] Number of currently free (recycled) IDs
     * @return[en] The number of free IDs
     */
    public func freeCount(): Int64 {
        return _freeIds.size
    }
}
