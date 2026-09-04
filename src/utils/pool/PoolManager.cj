/**
 * @file[zh-cn] PoolManager 多类型对象池管理器
 * @brief[zh-cn] 通过 ID 索引多个 ObjectPool，按类型注册/注销/获取/回收对象
 * @explain[zh-cn] 以 HashMap<Int64, ObjectPool<Object>> 维护多个对象池。由于
 * T <: Object 已涵盖所有 class，对象统一存为 Object 元类型，取对象时
 * 由调用方自行 match 转回具体类型。
 *
 * @file[en] PoolManager  Multi-type object pool manager
 * @brief[en] Indexes multiple ObjectPool instances by ID to register/unregister/get
 * and recycle objects per type
 * @explain[en] Maintains multiple pools via HashMap<Int64, ObjectPool<Object>>. Because
 * T <: Object already covers all classes, objects are stored uniformly as the
 * Object metatype and callers match them back to concrete types.
 *
 * @package three.utils.pool
 */
package three.utils.pool

import std.collection.*

/**
 * @brief[zh-cn] 多类型对象池管理
 * @explain[zh-cn] 为不同对象类型注册独立的 ObjectPool，并通过 ID 进行注册、获取与回收。
 * 用法：
 * ```
 * class ComponentA { ... }
 * let mgr = PoolManager(128)
 * mgr.register(1, { => ComponentA() })
 * let a = mgr.get<ComponentA>(1)
 * mgr.recycle(1, a)
 * ```
 *
 * @brief[en] Multi-type object pool management
 * @explain[en] Registers a dedicated ObjectPool per object type and uses IDs to register,
 * acquire and recycle objects. Usage:
 * ```
 * class ComponentA { ... }
 * let mgr = PoolManager(128)
 * mgr.register(1, { => ComponentA() })
 * let a = mgr.get<ComponentA>(1)
 * mgr.recycle(1, a)
 * ```
 *
 * @note[zh-cn] 各类型对象池的最大缓存容量在构造时统一指定。
 * @note[en] The maximum cache capacity of each per-type pool is set uniformly at
 * construction time.
 */
public class PoolManager {
    /** 默认容量 */
    private let _maxCapacity: Int64
    /** 已注册的对象池 @internal */
    private let _pools: HashMap<Int64, ObjectPool<Object>> = HashMap<Int64, ObjectPool<Object>>()

    /**
     * @brief[zh-cn] 构造管理器（默认容量 128）
     *
     * @brief[en] Constructs a manager with the default capacity of 128
     */
    public init() {
        _maxCapacity = 128
    }

    /**
     * @brief[zh-cn] 构造管理器
     * @param[zh-cn] capacity 各类型对象池最大缓存容量
     *
     * @brief[en] Constructs a manager
     * @param[en] capacity Maximum cache capacity of each per-type pool
     */
    public init(capacity: Int64) {
        _maxCapacity = capacity
    }

    /**
     * @brief[zh-cn] 注册指定 ID 的对象池
     * @param[zh-cn] id 对象类型 ID
     * factory 对象工厂
     *
     * @brief[en] Registers a pool for the given ID
     * @param[en] id Object-type ID
     * factory Object factory
     *
     * @throws[zh-cn] IllegalStateException 当该 ID 已注册时
     * @throws[en] IllegalStateException When the ID is already registered
     */
    public func register(id: Int64, factory: () -> Object): Unit {
        if (_pools.contains(id)) {
            throw IllegalStateException("object type already registered: id=${id}")
        }
        _pools.add(id, ObjectPool<Object>(_maxCapacity, factory))
    }

    /**
     * @brief[zh-cn] 注册带回调的对象池
     * @param[zh-cn] id 对象类型 ID
     * factory 对象工厂
     * onRecycle 回收回调
     * onReuse 复用回调
     *
     * @brief[en] Registers a pool with callbacks
     * @param[en] id Object-type ID
     * factory Object factory
     * onRecycle Recycle callback
     * onReuse Reuse callback
     *
     * @throws[zh-cn] IllegalStateException 当该 ID 已注册时
     * @throws[en] IllegalStateException When the ID is already registered
     */
    public func register(
        id: Int64,
        factory: () -> Object,
        onRecycle: ?(Object) -> Unit,
        onReuse: ?(Object) -> Unit
    ): Unit {
        if (_pools.contains(id)) {
            throw IllegalStateException("object type already registered: id=${id}")
        }
        _pools.add(id, ObjectPool<Object>(_maxCapacity, factory, onRecycle, onReuse))
    }

    /**
     * @brief[zh-cn] 注销指定类型
     * @param[zh-cn] id 对象类型 ID
     *
     * @brief[en] Unregisters the given type
     * @param[en] id Object-type ID
     */
    public func unregister(id: Int64): Unit {
        _pools.remove(id)
    }

    /**
     * @brief[zh-cn] 是否注册了指定类型
     * @param[zh-cn] id 对象类型 ID
     * @return[zh-cn] 已注册返回 true，否则返回 false
     *
     * @brief[en] Checks whether the given type is registered
     * @param[en] id Object-type ID
     * @return[en] true if registered, false otherwise
     */
    public func isRegister(id: Int64): Bool {
        return _pools.contains(id)
    }

    /**
     * @brief[zh-cn] 尝试从池里获取指定对象实例
     * @param[zh-cn] id 对象类型 ID
     * @return[zh-cn] 新建或复用的对象
     *
     * @brief[en] Tries to get an object instance from the pool for the given ID
     * @param[en] id Object-type ID
     * @return[en] A newly created or reused object
     *
     * @throws[zh-cn] IllegalStateException 当该 ID 未注册时
     * @throws[en] IllegalStateException When the ID is not registered
     */
    public func get(id: Int64): Object {
        match (_pools.get(id)) {
            case Some(pool) => return pool.allocate()
            case None => throw IllegalStateException("object type not registered: id=${id}")
        }
    }

    /**
     * @brief[zh-cn] 回收对象
     * @param[zh-cn] id 对象类型 ID
     * obj 待回收对象
     *
     * @brief[en] Recycles an object back to the pool for the given ID
     * @param[en] id Object-type ID
     * obj The object to recycle
     *
     * @throws[zh-cn] IllegalStateException 当该 ID 未注册时
     * @throws[en] IllegalStateException When the ID is not registered
     */
    public func recycle(id: Int64, obj: Object): Unit {
        match (_pools.get(id)) {
            case Some(pool) => pool.recycle(obj)
            case None => throw IllegalStateException("object type not registered: id=${id}")
        }
    }

    /**
     * @brief[zh-cn] 清理所有缓存
     *
     * @brief[en] Clears all caches
     */
    public func clear(): Unit {
        for ((_, pool) in _pools) {
            pool.clear()
        }
        _pools.clear()
    }
}
