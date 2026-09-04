/**
 * @file[zh-cn] System 系统基类
 * @brief[zh-cn] 实例 ID 自动分配/回收；组件需求掩码由 @System 宏注入收集逻辑
 * @explain[zh-cn] 设计要点：
 * - 实例 ID 池语义与 Entity 相同（全 System 层级共享静态分配器）
 * - 组件掩码为实例级（TS 为类级静态 _cptMask；仓颉静态成员无多态，
 * 改为实例字段 + init 期收集，匹配语义等价）
 * - collectCptMask 在 init 中被调用：宏注入的 override 只触碰静态成员
 * （各组件类的 typeId()），不依赖子类实例字段，init 期虚分派是安全的
 * 对照 TS: ry-ecs System.ts（@RySystem([...]) 装饰器填充静态 _cptMask）
 *
 * @file[en] System  Base system class
 * @brief[en] Instance ID auto-allocation/release; component requirement mask injected by @System macro
 * @explain[en] Design notes:
 * - Instance ID pool semantics are the same as Entity (shared static allocator across all System levels)
 * - Component mask is instance-level (TS uses class-level static _cptMask; Cangjie static members
 * have no polymorphism, changed to instance field + init-time collection, semantically equivalent)
 * - collectCptMask is called in init: macro-injected override only touches static members
 * (typeId() of each component class), does not depend on subclass instance fields, init-time
 * virtual dispatch is safe
 * TS counterpart: ry-ecs System.ts (@RySystem([...]) decorator filling static _cptMask)
 */
package three.scene.ecs

import three.core.dsa.BitArray
import three.utils.allocator.IdAllocator

/**
 * @brief[zh-cn] 系统标识符类型别名
 *
 * @brief[en] System identifier type alias
 */
public type SystemId = Int64

/**
 * @brief[zh-cn] 系统基类
 * @explain[zh-cn] 用法：
 *
 * @brief[en] Base system class
 * @explain[en] Usage:
 *
 * @System[PositionCpt, VelocityCpt]
 * public class MoveSystem <: System {
 * public override func onUpdate(entities: Iterator<Entity>, dt: Float64): Unit {
 * while (let Some(e) <- entities.next()) { ... }
 * }
 * }
 * @System[PositionCpt, VelocityCpt]
 * public class MoveSystem <: System {
 * public override func onUpdate(entities: Iterator<Entity>, dt: Float64): Unit {
 * while (let Some(e) <- entities.next()) { ... }
 * }
 * }
 */
public open class System <: EcsObject {
    /**
     * @brief[zh-cn] 实例 ID 分配器（全层级共享）
     *
     * @brief[en] Instance ID allocator (shared across all levels)
     */
    private static let _idAlloc: IdAllocator = IdAllocator()

    /**
     * @brief[zh-cn] 系统 ID（NUM_NONE 表示已回收）
     *
     * @brief[en] System ID (NUM_NONE indicates recycled)
     */
    private var _sysId: SystemId = NUM_NONE

    /**
     * @brief[zh-cn] 系统是否激活（需要被更新）
     *
     * @brief[en] Whether the system is active (needs updating)
     */
    public var isActive: Bool = true

    /**
     * @brief[zh-cn] 系统所需的所有组件标记
     *
     * @brief[en] All component flags required by the system
     */
    protected let _cptMask: BitArray = BitArray(0, value: false)

    /**
     * @brief[zh-cn] 组件需求掩码是否已收集
     *
     * @brief[en] Whether the component requirement mask has been collected
     */
    private var _maskReady: Bool = false

    /**
     * @brief[zh-cn] 构造器，new 即分配系统 ID；组件需求掩码在首次访问 cptMask 时惰性收集
     * @explain[zh-cn] open 类构造函数中禁止调用实例成员函数，故 collectCptMask 不在 init 中分派
     *
     * @brief[en] Constructor; new allocates system ID; component requirement mask lazily collected on first cptMask access
     * @explain[en] Open class constructors cannot call instance member functions, so collectCptMask is not dispatched in init
     */
    public init() {
        _sysId = _idAlloc.allocate()
        _constructed = true
    }

    /**
     * @brief[zh-cn] 系统 ID
     *
     * @brief[en] System ID
     */
    public prop sysId: SystemId {
        get() { _sysId }
    }

    /**
     * @brief[zh-cn] 系统所需的所有组件标记
     *
     * @brief[en] All component flags required by the system
     */
    public prop cptMask: BitArray {
        get() {
            if (!_maskReady) {
                _maskReady = true
                collectCptMask(_cptMask)
            }
            _cptMask
        }
    }

    /**
     * @brief[zh-cn] 收集系统所需组件掩码
     * @explain[zh-cn] 由 @System 宏在子类注入 override（设置各位后调用 super），
     * 用户请勿手动实现；基类默认为空实现（无组件需求）
     * @param[zh-cn] mask 掩码数组
     *
     * @brief[en] Collect system component requirement mask
     * @explain[en] Injected as override in subclasses by @System macro (sets bits then calls super);
     * users should not implement manually; base class defaults to empty implementation (no component requirements)
     * @param[en] mask Mask array
     */
    protected open func collectCptMask(mask: BitArray): Unit {}

    /**
     * @brief[zh-cn] 构造钩子：池复用时按需重新分配 ID
     * @explain[zh-cn] 子类重写时必须调用 super.onConstruct()
     *
     * @brief[en] Construction hook: re-allocate ID on demand during pool reuse
     * @explain[en] Must call super.onConstruct() when overriding
     */
    protected override func onConstruct(): Unit {
        if (_sysId == NUM_NONE) {
            _sysId = _idAlloc.allocate()
        }
    }

    /**
     * @brief[zh-cn] 析构钩子：回收 ID
     * @explain[zh-cn] 子类重写时必须调用 super.onDestruct()
     *
     * @brief[en] Destruction hook: release ID
     * @explain[en] Must call super.onDestruct() when overriding
     */
    protected override func onDestruct(): Unit {
        if (_sysId != NUM_NONE) {
            _idAlloc.release(_sysId)
            _sysId = NUM_NONE
        }
    }

    /**
     * @brief[zh-cn] 系统更新事件
     * @param[zh-cn] entities 命中组件掩码的实体迭代器（当轮快照）
     * dt 帧间隔（秒）
     *
     * @brief[en] System update event
     * @param[en] entities Entity iterator matching the component mask (snapshot of current round)
     * dt Frame interval (seconds)
     */
    public open func onUpdate(entities: Iterator<Entity>, dt: Float64): Unit {}
}
