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
 * @file[zh-cn] ObjectPool 通用泛型对象池
 * @brief[zh-cn] 提供单类型对象的缓存与复用，T 约束为 Object（仓颉所有 class 隐式继承 Object）
 * @explain[zh-cn] 设计要点：
 * - 不要求 T 实现任何接口，任意仓颉 class 可直接作为泛型参数使用
 * - 通过工厂函数 `factory` 创建新对象
 * - 通过可选回调 `onRecycle` / `onReuse` 通知对象状态变化（仅在需要时传入）
 * - 当 T 实现 IPoolObject（通常由 \@PoolObject 宏注入）时，自动调用 construct/destruct
 * - 容量 <= 0 表示不限制
 *
 * @file[en] ObjectPool  Generic typed object pool
 * @brief[en] Provides caching and reuse of objects of a single type; T is bounded by
 * Object (every Cangjie class implicitly inherits Object)
 * @explain[en] Design notes:
 * - T is not required to implement any interface; any Cangjie class can be used
 * - New objects are created through the factory function `factory`
 * - Optional callbacks `onRecycle` / `onReuse` notify object state changes
 * (only when needed)
 * - When T implements IPoolObject (usually injected by the \@PoolObject macro),
 * construct/destruct are invoked automatically
 * - A capacity <= 0 means unlimited
 *
 * @package three.utils.pool
 */
package three.utils.pool

import std.collection.*

/**
 * @brief[zh-cn] 通用对象池
 * @explain[zh-cn] 以栈结构（后进先出）缓存对象；池空时 allocate 调用工厂函数创建新对象，
 * 池满时 recycle 返回 false。当 T 实现 IPoolObject（通常由 \@PoolObject 宏注入）时，
 * allocate/recycle 会自动调用 construct/destruct。用法：
 * ```
 * \@PoolObject
 * class Particle {
 * var x = 0.0
 * public func construct(): Unit { x = 0.0 }  // 可选：重用前重置
 * }
 * let pool = ObjectPool<Particle>(128, { => Particle() })
 * let p = pool.allocate()   // 若池非空，自动调用 p.construct()
 * pool.recycle(p)           // 自动调用 p.destruct()
 * ```
 * @param[zh-cn] T 对象类型，约束为 Object（所有仓颉 class 隐式满足）
 *
 * @brief[en] Generic object pool
 * @explain[en] Caches objects in a stack (LIFO). When the pool is empty, allocate()
 * creates a new object via the factory; when full, recycle() returns false. If T
 * implements IPoolObject (usually injected by the \@PoolObject macro),
 * construct/destruct are invoked automatically on allocate/recycle. Usage:
 * ```
 * \@PoolObject
 * class Particle {
 * var x = 0.0
 * public func construct(): Unit { x = 0.0 }  // optional: reset before reuse
 * }
 * let pool = ObjectPool<Particle>(128, { => Particle() })
 * let p = pool.allocate()   // calls p.construct() when the pool is non-empty
 * pool.recycle(p)           // calls p.destruct()
 * ```
 * @param[en] T Object type, bounded by Object (satisfied by all Cangjie classes)
 */
public class ObjectPool<T> where T <: Object {
    /** 对象工厂 */
    private let _factory: () -> T
    /** 最大容量（<=0 表示不限制） */
    private let _maxCapacity: Int64
    /** 对象池（栈结构，后进先出） */
    private let _stack: ArrayList<T> = ArrayList<T>()
    /** 回收回调（可选） */
    private let _onRecycle: ?(T) -> Unit
    /** 复用回调（可选） */
    private let _onReuse: ?(T) -> Unit

    /**
     * @brief[zh-cn] 构造对象池（不带回调）
     * @param[zh-cn] capacity 最大缓存容量（<= 0 表示不限制）
     * factory 对象工厂，返回新创建的实例
     *
     * @brief[en] Constructs an object pool (without callbacks)
     * @param[en] capacity Maximum cache capacity (<= 0 means unlimited)
     * factory Object factory returning a new instance
     */
    public init(capacity: Int64, factory: () -> T) {
        this(capacity, factory, None, None)
    }

    /**
     * @brief[zh-cn] 构造对象池（带回收/复用回调）
     * @param[zh-cn] capacity 最大缓存容量（<= 0 表示不限制）
     * factory 对象工厂，返回新创建的实例
     * onRecycle 回收时回调（可选，用于重置状态）
     * onReuse 复用时回调（可选，用于初始化状态）
     *
     * @brief[en] Constructs an object pool (with recycle/reuse callbacks)
     * @param[en] capacity Maximum cache capacity (<= 0 means unlimited)
     * factory Object factory returning a new instance
     * onRecycle Callback on recycle (optional, for resetting state)
     * onReuse Callback on reuse (optional, for initializing state)
     */
    public init(
        capacity: Int64,
        factory: () -> T,
        onRecycle: ?(T) -> Unit,
        onReuse: ?(T) -> Unit
    ) {
        _maxCapacity = capacity
        _factory = factory
        _onRecycle = onRecycle
        _onReuse = onReuse
    }

    /**
     * @brief[zh-cn] 获取对象（池空则调用工厂新建）
     * @explain[zh-cn] 若对象实现了 IPoolObject（通常通过 \@PoolObject 宏注入），
     * 从池中复用时会自动调用 construct() 进行重置。
     * @return[zh-cn] 新建或复用的对象
     *
     * @brief[en] Gets an object (creates a new one via the factory when the pool is empty)
     * @explain[en] If the object implements IPoolObject (usually injected by the
     * \@PoolObject macro), construct() is invoked automatically when reused.
     * @return[en] A newly created or reused object
     */
    public func allocate(): T {
        if (_stack.size == 0) {
            return _factory()
        }
        let last = _stack.size - 1
        // get 返回 ?T，栈非空时一定存在，直接 getOrThrow
        let ret = _stack.get(last).getOrThrow()
        _stack.remove(last..last + 1)
        // IPoolObject 自动构造（无感）
        _tryConstruct(ret)
        match (_onReuse) {
            case Some(fn) => fn(ret)
            case None => ()
        }
        return ret
    }

    /**
     * @brief[zh-cn] 回收对象
     * @explain[zh-cn] 若对象实现了 IPoolObject（通常通过 \@PoolObject 宏注入），
     * 回收时会自动调用 destruct() 进行清理。
     * @param[zh-cn] obj 待回收对象
     * @return[zh-cn] 是否回收成功（容量已满返回 false）
     *
     * @brief[en] Recycles an object back into the pool
     * @explain[en] If the object implements IPoolObject (usually injected by the
     * \@PoolObject macro), destruct() is invoked automatically on recycle.
     * @param[en] obj The object to recycle
     * @return[en] Whether the recycle succeeded (false when the pool is full)
     */
    public func recycle(obj: T): Bool {
        if (_maxCapacity > 0 && _stack.size >= _maxCapacity) {
            return false
        }
        // IPoolObject 自动析构（无感）
        _tryDestruct(obj)
        match (_onRecycle) {
            case Some(fn) => fn(obj)
            case None => ()
        }
        _stack.add(obj)
        return true
    }

    /**
     * @brief[zh-cn] 清理缓存
     *
     * @brief[en] Clears the cache
     */
    public func clear(): Unit {
        _stack.clear()
    }

    /**
     * @brief[zh-cn] 当前池内缓存数量
     * @return[zh-cn] 缓存数量
     *
     * @brief[en] Number of objects currently cached in the pool
     * @return[en] The number of cached objects
     */
    public func size(): Int64 {
        return _stack.size
    }

    /**
     * 若 obj 实现了 IPoolObject，则调用其 construct
     * @internal
     */
    private func _tryConstruct(obj: T): Unit {
        if (let Some(poolObj) <- (obj as IPoolObject)) {
            poolObj.construct()
        }
    }

    /**
     * 若 obj 实现了 IPoolObject，则调用其 destruct
     * @internal
     */
    private func _tryDestruct(obj: T): Unit {
        if (let Some(poolObj) <- (obj as IPoolObject)) {
            poolObj.destruct()
        }
    }
}
