/**
 * @file[zh-cn] World 世界类
 * @brief[zh-cn] ECS 顶层门面：聚合实体/组件/系统管理器与系统-实体映射
 * @explain[zh-cn] 对照 TS: ry-ecs World.ts
 *
 * @file[en] World  World class
 * @brief[en] ECS top-level facade: aggregates entity/component/system managers and system-entity mapping
 * @explain[en] TS counterpart: ry-ecs World.ts
 */
package three.scene.ecs

import std.collection.*
import three.core.interfaces.ISysEtyMapManager

/**
 * @brief[zh-cn] 世界类，ECS 顶层门面
 * @explain[zh-cn] 用法：
 * let world = World()
 * world.addSystem(MoveSystem())
 * let e = world.createEntity()
 * world.addEntity(e)
 * let pos = world.createComponent<PositionCpt>(PositionCpt.typeId())
 * ...
 * world.onUpdate(dt)
 *
 * @brief[en] World class, ECS top-level facade
 * @explain[en] Usage:
 * let world = World()
 * world.addSystem(MoveSystem())
 * let e = world.createEntity()
 * world.addEntity(e)
 * let pos = world.createComponent<PositionCpt>(PositionCpt.typeId())
 * ...
 * world.onUpdate(dt)
 */
public class World {
    /**
     * @brief[zh-cn] 实体管理器
     *
     * @brief[en] Entity manager
     */
    private let _entityMgr: EntityManager = EntityManager()
    /**
     * @brief[zh-cn] 组件管理器
     *
     * @brief[en] Component manager
     */
    private let _componentMgr: ComponentManager = ComponentManager()
    /**
     * @brief[zh-cn] 系统-实体映射管理器
     *
     * @brief[en] System-entity mapping manager
     */
    private let _sysMapMgr: ISysEtyMapManager<System, Entity>
    /**
     * @brief[zh-cn] 系统管理器
     *
     * @brief[en] System manager
     */
    private let _systemMgr: SystemManager

    /**
     * @brief[zh-cn] 构造器（默认哈希模式映射管理器）
     *
     * @brief[en] Constructor (default hash-mode mapping manager)
     */
    public init() {
        _sysMapMgr = ArrSysEtyMapManager()
        _systemMgr = SystemManager(_entityMgr, _sysMapMgr)
    }

    /**
     * @brief[zh-cn] 构造器（自定义映射管理器）
     * @explain[zh-cn] 系统数量大、实体组件变更频繁时，可注入前缀树模式：World(TreeSysEtyMapManager())
     * @param[zh-cn] sysMapMgr 系统-实体映射管理器实现
     *
     * @brief[en] Constructor (custom mapping manager)
     * @explain[en] When system count is large and entity component changes are frequent, inject prefix tree mode: World(TreeSysEtyMapManager())
     * @param[en] sysMapMgr System-entity mapping manager implementation
     */
    public init(sysMapMgr: ISysEtyMapManager<System, Entity>) {
        _sysMapMgr = sysMapMgr
        _systemMgr = SystemManager(_entityMgr, _sysMapMgr)
    }

    /**
     * @brief[zh-cn] 实体管理器
     *
     * @brief[en] Entity manager
     */
    public prop entityMgr: EntityManager {
        get() { _entityMgr }
    }

    /**
     * @brief[zh-cn] 组件管理器
     *
     * @brief[en] Component manager
     */
    public prop componentMgr: ComponentManager {
        get() { _componentMgr }
    }

    /**
     * @brief[zh-cn] 系统管理器
     *
     * @brief[en] System manager
     */
    public prop systemMgr: SystemManager {
        get() { _systemMgr }
    }

    //! ------------------------------------------------ 实体部分

    /**
     * @brief[zh-cn] 创建一个实体（init 自动分配实体 ID）
     * @return[zh-cn] 新建的实体
     *
     * @brief[en] Create an entity (init auto-allocates entity ID)
     * @return[en] The newly created entity
     */
    public func createEntity(): Entity {
        Entity()
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
        let id = _entityMgr.addEntity(e)
        _sysMapMgr.addEntity(e)
        // 挂接组件变更监听：组件增删时调整实体和系统的映射关系
        e.monitorComponentChanges = { oldMask: Array<UInt8>, ety: Entity => _sysMapMgr.changeEntity(oldMask, ety) }
        id
    }

    /**
     * @brief[zh-cn] 移除实体（不触发析构，ID 不回收）
     * @param[zh-cn] id 实体 ID
     *
     * @brief[en] Remove an entity (does not trigger destruct; ID not released)
     * @param[en] id Entity ID
     */
    public func removeEntity(id: EntityId): Unit {
        if (let Some(e) <- _entityMgr.removeEntity(id)) {
            e.monitorComponentChanges = None
            _sysMapMgr.delEntity(e)
        }
    }

    /**
     * @brief[zh-cn] 删除实体（触发析构，ID 自动回收，组件全部卸载）
     * @param[zh-cn] id 实体 ID
     *
     * @brief[en] Delete an entity (triggers destruct; ID auto-released; all components unloaded)
     * @param[en] id Entity ID
     */
    public func delEntity(id: EntityId): Unit {
        if (let Some(e) <- _entityMgr.delEntity(id)) {
            e.monitorComponentChanges = None
            _sysMapMgr.delEntity(e)
        }
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
        _entityMgr.getEntity(id)
    }

    //! ------------------------------------------------ 组件部分

    /**
     * @brief[zh-cn] 创建组件（池化）
     * @param[zh-cn] cptId 组件类 ID（XxxCpt.typeId()）
     * @return[zh-cn] 组件实例，组件类未注册返回 None
     *
     * @brief[en] Create a component (pooled)
     * @param[en] cptId Component class ID (XxxCpt.typeId())
     * @return[en] Component instance, or None if component class not registered
     */
    public func createComponent<T>(cptId: ComponentId): ?T where T <: Component {
        _componentMgr.createComponent<T>(cptId)
    }

    /**
     * @brief[zh-cn] 回收组件
     * @param[zh-cn] c 组件实例
     *
     * @brief[en] Recycle a component
     * @param[en] c Component instance
     */
    public func recycle(c: Component): Unit {
        _componentMgr.recycle(c)
    }

    //! ------------------------------------------------ 系统部分

    /**
     * @brief[zh-cn] 系统遍历顺序（为空时按 sysId 升序）
     *
     * @brief[en] System traversal order (ascending by sysId when empty)
     */
    public prop updateOrder: ArrayList<SystemId> {
        get() { _systemMgr.updateOrder }
    }

    /**
     * @brief[zh-cn] 添加系统到管理器中
     * @param[zh-cn] sys 系统
     * @return[zh-cn] 系统 ID
     *
     * @brief[en] Add a system to the manager
     * @param[en] sys System
     * @return[en] System ID
     */
    public func addSystem(sys: System): SystemId {
        _systemMgr.addSystem(sys)
    }

    /**
     * @brief[zh-cn] 删除系统（触发析构，ID 自动回收）
     * @param[zh-cn] id 系统 ID
     *
     * @brief[en] Delete a system (triggers destruct; ID auto-released)
     * @param[en] id System ID
     */
    public func delSystemById(id: SystemId): Unit {
        _systemMgr.delSystemById(id)
    }

    /**
     * @brief[zh-cn] 更新所有系统
     * @param[zh-cn] dt 帧间隔（秒）
     *
     * @brief[en] Update all systems
     * @param[en] dt Frame interval (seconds)
     */
    public func onUpdate(dt: Float64): Unit {
        _systemMgr.onUpdate(dt)
    }

    //! ------------------------------------------------ World自带部分

    /**
     * @brief[zh-cn] 清理整个世界（组件池清空，实体/系统全部析构，ID 全部回收）
     *
     * @brief[en] Clear the entire world (component pools cleared; all entities/systems destructed; all IDs released)
     */
    public func clear(): Unit {
        _componentMgr.clear()
        _entityMgr.clear()
        _systemMgr.clear()
    }
}
