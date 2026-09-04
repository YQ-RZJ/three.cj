/**
 * @file[zh-cn] Entity 实体基类
 * @brief[zh-cn] 实例 ID 在 init 中自动分配、在 destruct 中自动回收，使用者无感
 * @explain[zh-cn] 设计要点：
 * - 实例 ID 池为全 Entity 层级共享的静态分配器（对照 TS EntityInner 的 IdMgr：
 * TS 中所有 Entity 子类也共享同一个静态池；EntityManager 以 etyId 为索引，
 * 若每个子类独立计数会导致 ID 冲突）
 * - 分配时机：init 直接分配（不经过 onConstruct 虚分派，保证子类字段未初始化
 * 阶段的安全）；池复用时由 onConstruct 按需再分配（NUM_NONE 守卫保证幂等）
 * - 回收时机：destruct -> onDestruct 释放 ID 并卸载全部组件，由
 * EntityManager.delEntity/clear 或对象池 recycle 触发
 * 对照 TS: ry-ecs Entity.ts
 *
 * @file[en] Entity  Base entity class
 * @brief[en] Instance ID is auto-allocated in init and auto-released in destruct, transparent to users
 * @explain[en] Design notes:
 * - Instance ID pool is a static allocator shared across all Entity levels
 * (TS counterpart: EntityInner IdMgr; all Entity subclasses share the same static pool;
 * EntityManager indexes by etyId, per-subclass counters would cause ID conflicts)
 * - Allocation timing: init allocates directly (bypasses onConstruct virtual dispatch,
 * ensuring safety before subclass fields are initialized); pool reuse re-allocates
 * on demand via onConstruct (NUM_NONE guard ensures idempotency)
 * - Release timing: destruct -> onDestruct releases ID and unloads all components,
 * triggered by EntityManager.delEntity/clear or object pool recycle
 * TS counterpart: ry-ecs Entity.ts
 */
package three.scene.ecs

import std.collection.*
import three.core.dsa.BitArray
import three.utils.allocator.IdAllocator

/**
 * @brief[zh-cn] 实体标识符类型别名
 *
 * @brief[en] Entity identifier type alias
 */
public type EntityId = Int64

/**
 * @brief[zh-cn] 实体基类
 * @explain[zh-cn] 用法：
 *
 * @brief[en] Base entity class
 * @explain[en] Usage:
 *
 * @Entity
 * public class Player <: Entity {}
 * let e = Player()        // init 中自动分配 etyId
 * world.addEntity(e)
 * world.delEntity(e.etyId) // 自动回收 etyId
 * @Entity
 * public class Player <: Entity {}
 * let e = Player()        // etyId auto-allocated in init
 * world.addEntity(e)
 * world.delEntity(e.etyId) // auto-release etyId
 */
public open class Entity <: EcsObject {
    /**
     * @brief[zh-cn] 实例 ID 分配器（全层级共享）
     */
    private static let _idAlloc: IdAllocator = IdAllocator()

    /**
     * @brief[zh-cn] 实体 ID（NUM_NONE 表示已回收）
     */
    private var _etyId: EntityId = NUM_NONE

    /**
     * @brief[zh-cn] 实体拥有的所有组件掩码
     */
    protected let _cptMask: BitArray = BitArray(0, value: false)

    /**
     * @brief[zh-cn] 组件表：cptId -> 组件实例
     */
    private let _components: HashMap<ComponentId, Component> = HashMap<ComponentId, Component>()

    /**
     * @brief[zh-cn] 组件变更监听（oldMask, entity），由 World.addEntity 挂接
     */
    public var monitorComponentChanges: ?(Array<UInt8>, Entity) -> Unit = None

    /**
     * @brief[zh-cn] 构造器，new 即分配实体 ID 并置位 _constructed
     * @explain[zh-cn] open 类构造函数中禁止调用实例成员函数，故不经 markConstructed
     *
     * @brief[en] Constructor; new allocates entity ID and sets _constructed
     * @explain[en] Open class constructors cannot call instance member functions, so markConstructed is bypassed
     */
    public init() {
        _etyId = _idAlloc.allocate()
        _constructed = true
    }

    /**
     * @brief[zh-cn] 实体 ID
     *
     * @brief[en] Entity ID
     */
    public prop etyId: EntityId {
        get() { _etyId }
    }

    /**
     * @brief[zh-cn] 实体拥有的所有组件掩码
     *
     * @brief[en] Component mask of all components owned by this entity
     */
    public prop cptMask: BitArray {
        get() { _cptMask }
    }

    /**
     * @brief[zh-cn] 所有组件（cptId -> 组件实例）
     *
     * @brief[en] All components (cptId -> component instance)
     */
    public prop components: HashMap<ComponentId, Component> {
        get() { _components }
    }

    /**
     * @brief[zh-cn] 构造钩子：池复用时按需重新分配 ID
     * @explain[zh-cn] 子类重写时必须调用 super.onConstruct()
     *
     * @brief[en] Construction hook: re-allocate ID on demand during pool reuse
     * @explain[en] Must call super.onConstruct() when overriding
     */
    protected override func onConstruct(): Unit {
        if (_etyId == NUM_NONE) {
            _etyId = _idAlloc.allocate()
        }
    }

    /**
     * @brief[zh-cn] 析构钩子：卸载全部组件并回收 ID
     * @explain[zh-cn] 顺序与 TS 一致（destruct 沿继承链自子向父）：
     * 先卸组件（此时 etyId 仍有效，changeEntity 能按 ID 把实体移出各系统记录区），再回收 ID。
     * 子类重写时必须调用 super.onDestruct()
     *
     * @brief[en] Destruction hook: unload all components and release ID
     * @explain[en] Order matches TS (destruct walks inheritance chain from child to parent):
     * Unload components first (etyId still valid, changeEntity can remove entity from system records by ID),
     * then release ID. Must call super.onDestruct() when overriding
     */
    protected override func onDestruct(): Unit {
        removeAllComponents()
        if (_etyId != NUM_NONE) {
            _idAlloc.release(_etyId)
            _etyId = NUM_NONE
        }
    }

    /**
     * @brief[zh-cn] 获取组件
     * @param[zh-cn] cptId 组件类 ID（通常为 XxxCpt.typeId()）
     * @return[zh-cn] 组件实例，不存在返回 None
     *
     * @brief[en] Get a component
     * @param[en] cptId Component class ID (typically XxxCpt.typeId())
     * @return[en] Component instance, or None if not found
     */
    public func getComponent<T>(cptId: ComponentId): ?T where T <: Component {
        match (_components.get(cptId)) {
            case Some(c) => c as T
            case None => None
        }
    }

    /**
     * @brief[zh-cn] 是否包含组件
     * @param[zh-cn] cptId 组件类 ID
     * @return[zh-cn] 包含返回 true
     *
     * @brief[en] Whether the entity has a component
     * @param[en] cptId Component class ID
     * @return[en] true if the component exists
     */
    public func hasComponent(cptId: ComponentId): Bool {
        _cptMask.get(cptId)
    }

    /**
     * @brief[zh-cn] 添加组件
     * @param[zh-cn] c 组件实例
     *
     * @brief[en] Add a component
     * @param[en] c Component instance
     *
     * @throws[zh-cn] EcsException 组件未注册（无 cptId）或实体内已存在同类型组件
     * @throws[en] EcsException Component not registered (no cptId) or duplicate component type in entity
     */
    public func addComponent(c: Component): Unit {
        let oldMask = _cptMask.copyInnerData()
        let id = c.cptId
        if (id == NUM_NONE) {
            throw EcsException("ecs.componentNotRegistered: component without cptId (missing @Component?)")
        }
        if (hasComponent(id)) {
            throw EcsException("ecs.dupComponentWithinEntity: cptId=${id}")
        }
        c.entity = this
        _cptMask.set(id, value: true) // 登记组件掩码
        _components.add(id, c)
        // 尝试构造组件（未构造过时；对照 TS 的 restruct 语义）
        if (!c.constructed) {
            c.restruct()
        }
        _notifyChanged(oldMask)
    }

    /**
     * @brief[zh-cn] 删除组件
     * @param[zh-cn] cptId 组件类 ID
     * @return[zh-cn] 被删除的组件（已析构），不存在返回 None
     *
     * @brief[en] Remove a component by ID
     * @param[en] cptId Component class ID
     * @return[en] The removed component (destructed), or None if not found
     */
    public func removeComponentById(cptId: ComponentId): ?Component {
        let oldMask = _cptMask.copyInnerData()
        if (let Some(c) <- _components.get(cptId)) {
            _cptMask.set(cptId, value: false) // 清理组件掩码
            _components.remove(cptId)
            c.entity = None
            c.destruct()
            _notifyChanged(oldMask)
            return c
        }
        None
    }

    /**
     * @brief[zh-cn] 删除组件（泛型便捷形式）
     * @param[zh-cn] cptId 组件类 ID
     * @return[zh-cn] 被删除的组件，不存在返回 None
     *
     * @brief[en] Remove a component (generic convenience form)
     * @param[en] cptId Component class ID
     * @return[en] The removed component, or None if not found
     */
    public func removeComponent<T>(cptId: ComponentId): ?T where T <: Component {
        match (removeComponentById(cptId)) {
            case Some(c) => c as T
            case None => None
        }
    }

    /**
     * @brief[zh-cn] 删除所有组件
     *
     * @brief[en] Remove all components
     */
    public func removeAllComponents(): Unit {
        let oldMask = _cptMask.copyInnerData()
        for ((_, c) in _components) {
            c.entity = None
            c.destruct()
        }
        _cptMask.clear()
        _components.clear()
        _notifyChanged(oldMask)
    }

    /**
     * @brief[zh-cn] 触发组件变更监听
     */
    private func _notifyChanged(oldMask: Array<UInt8>): Unit {
        match (monitorComponentChanges) {
            case Some(f) => f(oldMask, this)
            case None => ()
        }
    }
}
