/**
 * @file[zh-cn] Manager 实体/组件/系统管理器与系统-实体映射
 * @brief[zh-cn] 包含 EntityManager、ComponentManager、SystemManager 以及两种系统-实体映射管理器
 * @explain[zh-cn] - EntityManager：以 etyId 为键管理实体，删除时触发 destruct（自动回收 ID）
 * - ComponentManager：按 cptId 维护组件对象池，createComponent/recycle
 * - SystemManager：以 sysId 为键管理系统，驱动 onUpdate
 * - ArrSysEtyMapManager / TreeSysEtyMapManager：系统 <-> 实体的掩码匹配关系维护
 * （策略接口 ISysEtyMapManager 位于 three.interfaces，可注入 World 更换模式）
 * 对照 TS: ry-ecs Manager.ts
 * - TS 用稀疏数组以 ID 为下标存储；仓颉改用 HashMap（ID 语义不变）
 * - TS 的 getSystemEntitys 返回活迭代器；仓颉返回当轮快照（TS 文档本就声明
 * 当轮遍历语义不确定，快照语义更明确）
 * - TreeSysEtyMapManager（前缀树模式）基于 three.core.dsa.BinaryPatriciaTrie 移植
 *
 * @file[en] Manager  Entity/Component/System managers and system-entity mapping
 * @brief[en] Contains EntityManager, ComponentManager, SystemManager, and two system-entity mapping managers
 * @explain[en] - EntityManager: manages entities keyed by etyId; deletion triggers destruct (auto-release ID)
 * - ComponentManager: maintains component object pools by cptId; createComponent/recycle
 * - SystemManager: manages systems keyed by sysId; drives onUpdate
 * - ArrSysEtyMapManager / TreeSysEtyMapManager: system <-> entity mask matching relationship
 * (strategy interface ISysEtyMapManager located in three.interfaces, injectable into World)
 * TS counterpart: ry-ecs Manager.ts
 * - TS uses sparse arrays indexed by ID; Cangjie uses HashMap (ID semantics unchanged)
 * - TS getSystemEntitys returns live iterator; Cangjie returns snapshot per round
 * - TreeSysEtyMapManager (prefix tree mode) ported from three.core.dsa.BinaryPatriciaTrie
 */
package three.scene.ecs

import std.collection.*
import std.sort.*
import three.core.dsa.BinaryPatriciaTrie
import three.core.interfaces.ISysEtyMapManager
import three.utils.pool.ObjectPool

/**
 * @brief[zh-cn] 实体管理类
 * @explain[zh-cn] 以 etyId 为键管理实体的增删查清
 *
 * @brief[en] Entity manager class
 * @explain[en] Manages entity CRUD keyed by etyId
 */
public class EntityManager {
    /**
     * @brief[zh-cn] 所有实体：etyId -> 实体
     */
    private let _entitys: HashMap<EntityId, Entity> = HashMap<EntityId, Entity>()

    /**
     * @brief[zh-cn] 所有实体（内部表引用，供映射管理器挂接）
     *
     * @brief[en] All entities (internal table reference for mapping manager binding)
     */
    public prop entitys: HashMap<EntityId, Entity> {
        get() { _entitys }
    }

    /**
     * @brief[zh-cn] 内部管理的总量
     *
     * @brief[en] Total managed count
     */
    public prop size: Int64 {
        get() { _entitys.size }
    }

    /**
     * @brief[zh-cn] 添加实体
     * @param[zh-cn] e 实体
     * @return[zh-cn] 实体 ID
     *
     * @brief[en] Add an entity
     * @param[en] e Entity
     * @return[en] Entity ID
     */
    public func addEntity(e: Entity): EntityId {
        _entitys.add(e.etyId, e)
        e.etyId
    }

    /**
     * @brief[zh-cn] 移除实体（不触发析构，ID 不回收）
     * @param[zh-cn] id 实体 ID
     * @return[zh-cn] 被移除的实体，不存在返回 None
     *
     * @brief[en] Remove an entity (does not trigger destruct; ID not released)
     * @param[en] id Entity ID
     * @return[en] The removed entity, or None if not found
     */
    public func removeEntity(id: EntityId): ?Entity {
        let e = _entitys.get(id)
        _entitys.remove(id)
        e
    }

    /**
     * @brief[zh-cn] 删除实体（触发析构，ID 自动回收）
     * @param[zh-cn] id 实体 ID
     * @return[zh-cn] 被删除的实体，不存在返回 None
     *
     * @brief[en] Delete an entity (triggers destruct; ID auto-released)
     * @param[en] id Entity ID
     * @return[en] The deleted entity, or None if not found
     */
    public func delEntity(id: EntityId): ?Entity {
        if (let Some(e) <- _entitys.get(id)) {
            e.destruct()
            _entitys.remove(id)
            return e
        }
        None
    }

    /**
     * @brief[zh-cn] 获取实体
     * @param[zh-cn] id 实体 ID
     * @return[zh-cn] 实体实例，不存在返回 None
     *
     * @brief[en] Get an entity by ID
     * @param[en] id Entity ID
     * @return[en] Entity instance, or None if not found
     */
    public func getEntity(id: EntityId): ?Entity {
        _entitys.get(id)
    }

    /**
     * @brief[zh-cn] 清理（析构全部实体，ID 全部回收）
     *
     * @brief[en] Clear (destruct all entities; all IDs released)
     */
    public func clear(): Unit {
        for ((_, e) in _entitys) {
            e.destruct()
        }
        _entitys.clear()
    }
}

/**
 * @brief[zh-cn] 组件管理类
 * @explain[zh-cn] 按 cptId 维护组件对象池，createComponent/recycle
 *
 * @brief[en] Component manager class
 * @explain[en] Maintains component object pools by cptId; createComponent/recycle
 */
public class ComponentManager {
    /**
     * @brief[zh-cn] 组件对象池：cptId -> 池
     */
    private let _pools: HashMap<ComponentId, ObjectPool<Component>> = HashMap<ComponentId, ObjectPool<Component>>()

    /**
     * @brief[zh-cn] 创建组件（池化）
     * @explain[zh-cn] 首次使用某组件类时按 ComponentRegistry 登记的工厂建池；
     * 复用对象时 ObjectPool 自动调用 construct（无感重置）
     * @param[zh-cn] cptId 组件类 ID（XxxCpt.typeId()）
     * @return[zh-cn] 组件实例，组件类未注册返回 None
     *
     * @brief[en] Create a component (pooled)
     * @explain[en] On first use of a component class, a pool is created using the factory registered in ComponentRegistry;
     * ObjectPool automatically calls construct on reuse (seamless reset)
     * @param[en] cptId Component class ID (XxxCpt.typeId())
     * @return[en] Component instance, or None if component class not registered
     */
    public func createComponent<T>(cptId: ComponentId): ?T where T <: Component {
        match (_ensurePool(cptId)) {
            case Some(pool) => pool.allocate() as T
            case None => None
        }
    }

    /**
     * @brief[zh-cn] 获取或按登记工厂创建组件池
     */
    private func _ensurePool(cptId: ComponentId): ?ObjectPool<Component> {
        if (let Some(pool) <- _pools.get(cptId)) {
            return pool
        }
        if (let Some(factory) <- ComponentRegistry.factoryOf(cptId)) {
            let pool = ObjectPool<Component>(0, factory)
            _pools.add(cptId, pool)
            return pool
        }
        None
    }

    /**
     * @brief[zh-cn] 回收组件
     * @explain[zh-cn] ObjectPool.recycle 会自动调用 destruct（无感清理）
     * @param[zh-cn] c 组件实例
     *
     * @brief[en] Recycle a component
     * @explain[en] ObjectPool.recycle automatically calls destruct (seamless cleanup)
     * @param[en] c Component instance
     *
     * @throws[zh-cn] EcsException 组件仍挂在实体上
     * @throws[en] EcsException Component is still attached to an entity
     */
    public func recycle(c: Component): Unit {
        if (c.entity.isSome()) {
            throw EcsException("ecs.instanceIsInUse: cptId=${c.cptId}")
        }
        // 未注册的组件不入池，直接丢弃
        if (let Some(pool) <- _ensurePool(c.cptId)) {
            pool.recycle(c)
        }
    }

    /**
     * @brief[zh-cn] 释放清理（清空全部池缓存）
     *
     * @brief[en] Release and clear (clear all pool caches)
     */
    public func clear(): Unit {
        for ((_, pool) in _pools) {
            pool.clear()
        }
    }
}

/**
 * @brief[zh-cn] 系统-实体映射管理（哈希模式）
 * @explain[zh-cn] 对照 TS: ArrSysEtyMapManager
 *
 * @brief[en] System-entity mapping manager (hash mode)
 * @explain[en] TS counterpart: ArrSysEtyMapManager
 */
public class ArrSysEtyMapManager <: ISysEtyMapManager<System, Entity> {
    /**
     * @brief[zh-cn] 记录区：sysId -> (etyId -> 实体)
     */
    private let _mapping: HashMap<SystemId, HashMap<EntityId, Entity>> = HashMap<SystemId, HashMap<EntityId, Entity>>()
    /**
     * @brief[zh-cn] 系统表引用（bind 挂接）
     */
    private var _systems: HashMap<SystemId, System> = HashMap<SystemId, System>()
    /**
     * @brief[zh-cn] 实体表引用（bind 挂接）
     */
    private var _entitys: HashMap<EntityId, Entity> = HashMap<EntityId, Entity>()

    /**
     * @brief[zh-cn] 绑定系统表与实体表
     * @param[zh-cn] systems 系统表
     * entitys 实体表
     *
     * @brief[en] Bind system and entity tables
     * @param[en] systems System table
     * entitys Entity table
     */
    public func bind(systems: HashMap<SystemId, System>, entitys: HashMap<EntityId, Entity>): Unit {
        _systems = systems
        _entitys = entitys
    }

    /**
     * @brief[zh-cn] 添加系统到映射
     * @param[zh-cn] sys 系统
     *
     * @brief[en] Add a system to the mapping
     * @param[en] sys System
     */
    public func addSystem(sys: System): Unit {
        let set = HashMap<EntityId, Entity>()
        for ((_, ety) in _entitys) {
            if (ety.cptMask.cover(sys.cptMask)) {
                set.add(ety.etyId, ety)
            }
        }
        _mapping.add(sys.sysId, set)
    }

    /**
     * @brief[zh-cn] 从映射中删除系统
     * @param[zh-cn] sys 系统
     *
     * @brief[en] Remove a system from the mapping
     * @param[en] sys System
     */
    public func delSystem(sys: System): Unit {
        _mapping.remove(sys.sysId)
    }

    /**
     * @brief[zh-cn] 获取系统关联的实体迭代器
     * @param[zh-cn] sys 系统
     * @return[zh-cn] (实体数量, 实体迭代器)
     *
     * @brief[en] Get entities associated with a system
     * @param[en] sys System
     * @return[en] (entity count, entity iterator)
     */
    public func getSystemEntitys(sys: System): (Int64, Iterator<Entity>) {
        if (let Some(set) <- _mapping.get(sys.sysId)) {
            let arr = ArrayList<Entity>()
            for ((_, ety) in set) {
                arr.add(ety)
            }
            return (arr.size, arr.iterator())
        }
        (0, ArrayList<Entity>().iterator())
    }

    /**
     * @brief[zh-cn] 添加实体到匹配系统的记录区
     * @param[zh-cn] ety 实体
     *
     * @brief[en] Add entity to matching system records
     * @param[en] ety Entity
     */
    public func addEntity(ety: Entity): Unit {
        for ((sysId, sys) in _systems) {
            if (ety.cptMask.cover(sys.cptMask)) {
                if (let Some(set) <- _mapping.get(sysId)) {
                    set.add(ety.etyId, ety)
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 从所有系统记录区中移除实体
     * @param[zh-cn] ety 实体
     *
     * @brief[en] Remove entity from all system records
     * @param[en] ety Entity
     */
    public func delEntity(ety: Entity): Unit {
        for ((_, set) in _mapping) {
            set.remove(ety.etyId)
        }
    }

    /**
     * @brief[zh-cn] 实体组件变更后调整映射
     * @param[zh-cn] _oldMask 旧组件掩码
     * ety 变更的实体
     *
     * @brief[en] Adjust mapping after entity component change
     * @param[en] _oldMask Old component mask
     * ety Changed entity
     */
    public func changeEntity(_oldMask: Array<UInt8>, ety: Entity): Unit {
        for ((sysId, sys) in _systems) {
            if (let Some(set) <- _mapping.get(sysId)) {
                if (ety.cptMask.cover(sys.cptMask)) {
                    set.add(ety.etyId, ety)
                } else {
                    set.remove(ety.etyId)
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 清空所有映射
     *
     * @brief[en] Clear all mappings
     */
    public func clear(): Unit {
        _mapping.clear()
    }
}

/**
 * @brief[zh-cn] 系统-实体映射管理（前缀树模式）
 * @explain[zh-cn] 以系统组件需求掩码为键、命中实体列表为值，挂到 BinaryPatriciaTrie 上：
 * - addEntity/delEntity/changeEntity 通过 fBitSubsetOf 按位子集查询，
 * 只访问"需求掩码 ⊆ 实体掩码"的系统桶，无需遍历全部系统；
 * 系统数量大、实体组件变更频繁时显著优于哈希模式
 * - getSystemEntitys 为掩码精确查找
 * 注意：记录区按"掩码"聚合，需求掩码相同的不同系统共享同一记录区；
 * delSystem 会按掩码删除整个记录区，同掩码的其他系统需重新 addSystem
 *
 * @brief[en] System-entity mapping manager (prefix tree mode)
 * @explain[en] Keys are system component requirement masks, values are matched entity lists, stored in a BinaryPatriciaTrie:
 * - addEntity/delEntity/changeEntity use fBitSubsetOf for bit-subset queries,
 * only accessing system buckets where "requirement mask ⊆ entity mask", no need to traverse all systems;
 * significantly outperforms hash mode when system count is large and entity component changes are frequent
 * - getSystemEntitys performs exact mask lookup
 * Note: records are aggregated by mask; systems with the same requirement mask share the same record area;
 * delSystem removes the entire record area by mask, other systems with the same mask need re-addSystem
 */
public class TreeSysEtyMapManager <: ISysEtyMapManager<System, Entity> {
    /**
     * @brief[zh-cn] 记录区：需求掩码 -> 命中实体列表
     */
    private let _sysMappingEntity: BinaryPatriciaTrie<ArrayList<Entity>> = BinaryPatriciaTrie<ArrayList<Entity>>()
    /**
     * @brief[zh-cn] 系统表引用（bind 挂接）
     */
    private var _systems: HashMap<SystemId, System> = HashMap<SystemId, System>()
    /**
     * @brief[zh-cn] 实体表引用（bind 挂接）
     */
    private var _entitys: HashMap<EntityId, Entity> = HashMap<EntityId, Entity>()

    /**
     * @brief[zh-cn] 绑定系统表与实体表
     * @param[zh-cn] systems 系统表
     * entitys 实体表
     *
     * @brief[en] Bind system and entity tables
     * @param[en] systems System table
     * entitys Entity table
     */
    public func bind(systems: HashMap<SystemId, System>, entitys: HashMap<EntityId, Entity>): Unit {
        _systems = systems
        _entitys = entitys
    }

    /**
     * @brief[zh-cn] 添加系统到映射
     * @param[zh-cn] sys 系统
     *
     * @brief[en] Add a system to the mapping
     * @param[en] sys System
     */
    public func addSystem(sys: System): Unit {
        let key = sys.cptMask.copyInnerData()
        if (!_sysMappingEntity.has(key)) {
            let arr = ArrayList<Entity>()
            for ((_, ety) in _entitys) {
                if (ety.cptMask.cover(sys.cptMask)) {
                    arr.add(ety)
                }
            }
            _sysMappingEntity.set(key, arr)
        }
    }

    /**
     * @brief[zh-cn] 从映射中删除系统
     * @param[zh-cn] sys 系统
     *
     * @brief[en] Remove a system from the mapping
     * @param[en] sys System
     */
    public func delSystem(sys: System): Unit {
        _sysMappingEntity.delete(sys.cptMask.copyInnerData())
    }

    /**
     * @brief[zh-cn] 获取系统关联的实体迭代器
     * @param[zh-cn] sys 系统
     * @return[zh-cn] (实体数量, 实体迭代器)
     *
     * @brief[en] Get entities associated with a system
     * @param[en] sys System
     * @return[en] (entity count, entity iterator)
     */
    public func getSystemEntitys(sys: System): (Int64, Iterator<Entity>) {
        match (_sysMappingEntity.get(sys.cptMask.copyInnerData())) {
            case Some(arr) => (arr.size, arr.iterator())
            case None => (0, ArrayList<Entity>().iterator())
        }
    }

    /**
     * @brief[zh-cn] 添加实体到匹配系统的记录区
     * @param[zh-cn] ety 实体
     *
     * @brief[en] Add entity to matching system records
     * @param[en] ety Entity
     */
    public func addEntity(ety: Entity): Unit {
        for ((_, set) in _sysMappingEntity.fBitSubsetOf(ety.cptMask.copyInnerData())) {
            set.add(ety)
        }
    }

    /**
     * @brief[zh-cn] 从所有系统记录区中移除实体
     * @param[zh-cn] ety 实体
     *
     * @brief[en] Remove entity from all system records
     * @param[en] ety Entity
     */
    public func delEntity(ety: Entity): Unit {
        _delEntity(ety.etyId, ety.cptMask.copyInnerData())
    }

    /**
     * @brief[zh-cn] 实体组件变更后调整映射
     * @param[zh-cn] oldMask 旧组件掩码
     * ety 变更的实体
     *
     * @brief[en] Adjust mapping after entity component change
     * @param[en] oldMask Old component mask
     * ety Changed entity
     */
    public func changeEntity(oldMask: Array<UInt8>, ety: Entity): Unit {
        _delEntity(ety.etyId, oldMask)
        addEntity(ety)
    }

    /**
     * @brief[zh-cn] 删除实体成员（倒序就地删除）
     */
    private func _delEntity(id: EntityId, cptMask: Array<UInt8>): Unit {
        for ((_, set) in _sysMappingEntity.fBitSubsetOf(cptMask)) {
            var i = set.size - 1
            while (i >= 0) {
                if (set[i].etyId == id) {
                    set.remove(at: i)
                }
                i -= 1
            }
        }
    }

    /**
     * @brief[zh-cn] 清空所有映射
     *
     * @brief[en] Clear all mappings
     */
    public func clear(): Unit {
        _sysMappingEntity.clear()
    }
}

/**
 * @brief[zh-cn] 系统管理类
 * @explain[zh-cn] 以 sysId 为键管理系统，驱动 onUpdate
 *
 * @brief[en] System manager class
 * @explain[en] Manages systems keyed by sysId; drives onUpdate
 */
public class SystemManager {
    /**
     * @brief[zh-cn] 所有系统：sysId -> 系统
     */
    private let _systems: HashMap<SystemId, System> = HashMap<SystemId, System>()

    /**
     * @brief[zh-cn] 系统遍历顺序（为空时按 sysId 升序）
     *
     * @brief[en] System traversal order (ascending by sysId when empty)
     */
    public let updateOrder: ArrayList<SystemId> = ArrayList<SystemId>()

    /**
     * @brief[zh-cn] 系统所需要更新的所有实体
     */
    private let _sysMap: ISysEtyMapManager<System, Entity>

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] etyMgr 实体管理器
     * sysMap 系统-实体映射管理器
     *
     * @brief[en] Constructor
     * @param[en] etyMgr Entity manager
     * sysMap System-entity mapping manager
     */
    public init(etyMgr: EntityManager, sysMap: ISysEtyMapManager<System, Entity>) {
        _sysMap = sysMap
        // 挂接系统表与实体表（引用共享）
        sysMap.bind(_systems, etyMgr.entitys)
    }

    /**
     * @brief[zh-cn] 所有系统
     *
     * @brief[en] All systems
     */
    public prop systems: HashMap<SystemId, System> {
        get() { _systems }
    }

    /**
     * @brief[zh-cn] 内部管理的总量
     *
     * @brief[en] Total managed count
     */
    public prop size: Int64 {
        get() { _systems.size }
    }

    /**
     * @brief[zh-cn] 添加系统到管理器中
     * @param[zh-cn] sys 系统
     * @return[zh-cn] 系统 ID
     *
     * @brief[en] Add a system to the manager
     * @param[en] sys System
     * @return[en] System ID
     *
     * @throws[zh-cn] EcsException 同 ID 系统已存在
     * @throws[en] EcsException System with same ID already exists
     */
    public func addSystem(sys: System): SystemId {
        if (_systems.contains(sys.sysId)) {
            throw EcsException("ecs.systemAlreadyExists: sysId=${sys.sysId}")
        }
        _systems.add(sys.sysId, sys)
        // 加入系统相关记录区
        _sysMap.addSystem(sys)
        sys.sysId
    }

    /**
     * @brief[zh-cn] 删除系统（触发析构，ID 自动回收）
     * @param[zh-cn] id 系统 ID
     * @return[zh-cn] 被删除的系统，不存在返回 None
     *
     * @brief[en] Delete a system (triggers destruct; ID auto-released)
     * @param[en] id System ID
     * @return[en] The deleted system, or None if not found
     */
    public func delSystemById(id: SystemId): ?System {
        if (let Some(sys) <- _systems.get(id)) {
            _sysMap.delSystem(sys)
            sys.destruct()
            _systems.remove(id)
            return sys
        }
        None
    }

    /**
     * @brief[zh-cn] 更新所有系统
     * @param[zh-cn] dt 帧间隔（秒）
     *
     * @brief[en] Update all systems
     * @param[en] dt Frame interval (seconds)
     */
    public func onUpdate(dt: Float64): Unit {
        if (updateOrder.size > 0) {
            for (id in updateOrder) {
                _tick(id, dt)
            }
        } else {
            // 无指定顺序时按 sysId 升序（对照 TS 的数组下标顺序）
            let ids = ArrayList<SystemId>()
            for ((id, _) in _systems) {
                ids.add(id)
            }
            sort(ids)
            for (id in ids) {
                _tick(id, dt)
            }
        }
    }

    /**
     * @brief[zh-cn] 清理（析构全部系统）
     *
     * @brief[en] Clear (destruct all systems)
     */
    public func clear(): Unit {
        for ((_, sys) in _systems) {
            sys.destruct()
        }
        _systems.clear()
        _sysMap.clear()
        updateOrder.clear()
    }

    /**
     * @brief[zh-cn] 驱动单个系统
     */
    private func _tick(id: SystemId, dt: Float64): Unit {
        if (let Some(sys) <- _systems.get(id)) {
            let (count, entities) = _sysMap.getSystemEntitys(sys)
            if (sys.isActive && count > 0) {
                sys.onUpdate(entities, dt)
            }
        }
    }
}
