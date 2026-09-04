/**
 * @file[zh-cn] Component 组件基类
 * @brief[zh-cn] 纯数据载体，类级唯一 ID（cptId）由 @Component 宏注入
 * @explain[zh-cn] 设计要点：
 * - cptId 为类级别 ID（非实例），基类默认返回 NUM_NONE
 * - 子类使用 @Component 宏后，宏注入：
 * private static var _cptId_<类名>_<哈希>: Int64   // 自有静态成员，避免与父类同名冲突
 * public static func typeId(): Int64                // 类级静态访问（类型上下文）
 * public open override prop cptId: Int64            // 实例级多态访问（框架上下文）
 * - 关于"静态成员同名"问题的说明：
 * 仓颉静态成员不能 open/override（仅支持 redef 静态分派），无法以静态属性
 * 做多态重载；因此实例 prop cptId 承担运行时多态读取，静态 typeId() 承担
 * 类型级读取，二者共用宏注入的每类唯一静态字段
 * - 静态访问器命名为 typeId 而非 cptId：仓颉禁止同类中静态成员与实例成员同名
 * 对照 TS: ry-ecs Component.ts（@RyComponent() 装饰器盖章 _cptId）
 *
 * @file[en] Component  Base component class
 * @brief[en] Pure data carrier whose class-level unique ID (cptId) is injected by the @Component macro
 * @explain[en] Design notes:
 * - cptId is a class-level ID (not instance-level); the base class returns NUM_NONE by default
 * - Subclasses using the @Component macro get injected:
 * private static var _cptId_<ClassName>_<hash>: Int64   // unique static member per class
 * public static func typeId(): Int64                    // class-level static access
 * public open override prop cptId: Int64                // instance-level polymorphic access
 * - Cangjie static members cannot be open/override (only redef is supported), so the instance
 * prop cptId handles runtime polymorphic reads while typeId() handles type-level reads,
 * both backed by the same per-class unique static field injected by the macro
 * - The static accessor is named typeId rather than cptId because Cangjie forbids
 * static and instance members with the same name in the same class
 * TS counterpart: ry-ecs Component.ts (@RyComponent() decorator stamping _cptId)
 */
package three.scene.ecs

/**
 * @brief[zh-cn] 组件标识符类型别名
 *
 * @brief[en] Component identifier type alias
 */
public type ComponentId = Int64

/**
 * @brief[zh-cn] 组件基类，纯数据载体
 * @explain[zh-cn] 每个组件必须提供无参构造（对象池按工厂创建实例）。
 * 用法：@Component public class PositionCpt <: Component { public var x: Float64 = 0.0 }
 * 类型上下文：PositionCpt.typeId()；实例上下文：entity.addComponent(PositionCpt()) 内部读取实例 cptId
 *
 * @brief[en] Base component class, pure data carrier
 * @explain[en] Each component must provide a no-arg constructor (object pool creates instances via factory).
 * Usage: @Component public class PositionCpt <: Component { public var x: Float64 = 0.0 }
 * Type context: PositionCpt.typeId(); instance context: entity.addComponent(PositionCpt()) reads instance cptId
 */
public open class Component <: EcsObject {
    /**
     * @brief[zh-cn] 组件类 ID
     * @explain[zh-cn] 基类返回 NUM_NONE；@Component 宏会在子类注入 override 实现
     *
     * @brief[en] Component class ID
     * @explain[en] Base class returns NUM_NONE; @Component macro injects override in subclasses
     */
    public open prop cptId: ComponentId {
        get() { NUM_NONE }
    }

    /**
     * @brief[zh-cn] 所属实体（挂载/卸载时由 Entity 维护）
     *
     * @brief[en] Owning entity (maintained by Entity on mount/unmount)
     */
    public var entity: ?Entity = None
}
