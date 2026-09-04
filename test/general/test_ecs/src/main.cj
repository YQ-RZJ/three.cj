/**
 * @file main — ECS 单元测试
 * @brief 验证 three.infra.ecs 运行时与 three.infra.ecs.macros 三个装饰宏的正确性：
 *  1. 组件类 ID 登记（唯一性/幂等性/继承链隔离/实例与类级一致）
 *  2. 实体 ID 无感分配与回收（new 分配 / delEntity 回收 / 回收复用）
 *  3. 系统 ID 无感分配与回收 + 重复添加防御
 *  4. 组件挂载/卸载（掩码维护、异常防御、析构联动）
 *  5. 组件对象池复用 + 在册组件回收防御
 *  6. 系统-实体掩码匹配（哈希模式：动态命中/移除/删除实体）
 *  7. 系统-实体掩码匹配（前缀树模式）
 *  8. 系统掩码继承链叠加（@System 多层 super 链）
 *  9. 完整流程（MoveSystem 位移驱动）
 *
 * 运行方式：cjpm run（退出码为失败用例数，0 为全部通过）
 *
 * @package test_ecs
 */
package test_ecs

import three.scene.ecs.*
import three.scene.ecs.macros.*
import three.core.dsa.*

//! ------------------------------------------------ 测试用组件/实体/系统定义

/** 位置组件 */
@Component
public class PositionCpt <: Component {
    public var x: Float64 = 0.0
    public var y: Float64 = 0.0
}

/** 速度组件 */
@Component
public class VelocityCpt <: Component {
    public var vx: Float64 = 0.0
    public var vy: Float64 = 0.0
}

/** 生命组件（继承链唯一性验证 - 父） */
@Component
public open class HealthCpt <: Component {
    public var hp: Int64 = 100
}

/** 强化生命组件（继承链唯一性验证 - 子） */
@Component
public class BuffedHealthCpt <: HealthCpt {
    public var extra: Int64 = 0
}

/** 未使用宏的组件（未登记防御验证） */
public class RawCpt <: Component {}

/** 玩家实体 */
@Entity
public class Player <: Entity {}

/** 计数系统：统计每轮命中的实体数（需求 PositionCpt） */
@System[PositionCpt]
public class CountSystem <: System {
    /** 累计命中次数 */
    public var seen: Int64 = 0

    public override func onUpdate(entities: Iterator<Entity>, dt: Float64): Unit {
        while (entities.next().isSome()) {
            seen += 1
        }
    }
}

/** 继承链掩码验证 - 父系统（需求 PositionCpt） */
@System[PositionCpt]
public open class BaseCountSystem <: System {}

/** 继承链掩码验证 - 子系统（追加需求 VelocityCpt） */
@System[VelocityCpt]
public class DerivedCountSystem <: BaseCountSystem {}

/** 移动系统：需求 PositionCpt + VelocityCpt */
@System[PositionCpt, VelocityCpt]
public class MoveSystem <: System {
    public override func onUpdate(entities: Iterator<Entity>, dt: Float64): Unit {
        while (let Some(e) <- entities.next()) {
            match ((e.getComponent<PositionCpt>(PositionCpt.typeId()),
                e.getComponent<VelocityCpt>(VelocityCpt.typeId()))) {
                case (Some(p), Some(v)) =>
                    p.x += v.vx * dt
                    p.y += v.vy * dt
                case _ => ()
            }
        }
    }
}

//! ------------------------------------------------ 测试框架（极简断言）

var _passed: Int64 = 0
var _failed: Int64 = 0

/** 断言 */
func check(cond: Bool, name: String): Unit {
    if (cond) {
        _passed += 1
        println("  [PASS] ${name}")
    } else {
        _failed += 1
        println("  [FAIL] ${name}")
    }
}

/** 断言抛出 EcsException */
func expectEcsException(f: () -> Unit, name: String): Unit {
    var threw = false
    try {
        f()
    } catch (e: EcsException) {
        threw = true
    }
    check(threw, name)
}

//! ------------------------------------------------ 用例

/** 组件类 ID 登记 */
func testComponentRegistry(): Unit {
    println("testComponentRegistry")
    let pid = PositionCpt.typeId()
    check(pid == PositionCpt.typeId(), "同类多次访问 ID 稳定（幂等登记）")
    check(pid != VelocityCpt.typeId(), "不同组件类 ID 不同")
    check(HealthCpt.typeId() != BuffedHealthCpt.typeId(), "继承链上各组件类 ID 唯一")
    let p = PositionCpt()
    check(p.cptId == pid, "实例 cptId 与类级 typeId 一致")
    let b = BuffedHealthCpt()
    check(b.cptId == BuffedHealthCpt.typeId(), "子类实例 cptId 为子类自身 ID（多态读取）")
}

/** 实体 ID 生命周期 */
func testEntityLifecycle(): Unit {
    println("testEntityLifecycle")
    let world = World()
    let e = Player()
    let id = e.etyId
    check(id != NUM_NONE, "实体 new 即分配 ID")
    world.addEntity(e)
    check(world.getEntity(id).isSome(), "addEntity 后可按 ID 获取")
    world.delEntity(id)
    check(e.etyId == NUM_NONE, "delEntity 自动回收实体 ID（无感）")
    check(world.getEntity(id).isNone(), "delEntity 后无法获取")
    let e2 = Player()
    check(e2.etyId == id, "回收的实体 ID 被新实体复用")
    world.clear()
}

/** 系统 ID 生命周期 */
func testSystemLifecycle(): Unit {
    println("testSystemLifecycle")
    let world = World()
    let s1 = CountSystem()
    let id1 = s1.sysId
    check(id1 != NUM_NONE, "系统 new 即分配 ID")
    world.addSystem(s1)
    expectEcsException({ => world.addSystem(s1); () }, "重复添加同一系统抛 EcsException")
    world.delSystemById(id1)
    check(s1.sysId == NUM_NONE, "delSystemById 自动回收系统 ID（无感）")
    let s2 = CountSystem()
    check(s2.sysId == id1, "回收的系统 ID 被新系统复用")
    world.clear()
}

/** 组件挂载/卸载 */
func testComponentAttach(): Unit {
    println("testComponentAttach")
    let world = World()
    let e = Player()
    world.addEntity(e)
    let pid = PositionCpt.typeId()
    check(!e.hasComponent(pid), "初始无组件")
    let p = PositionCpt()
    e.addComponent(p)
    check(e.hasComponent(pid), "addComponent 后掩码命中")
    check(p.entity.isSome(), "组件回指所属实体")
    check(p.constructed, "挂载时组件自动构造")
    expectEcsException({ => e.addComponent(PositionCpt()) }, "重复添加同类组件抛 EcsException")
    expectEcsException({ => e.addComponent(RawCpt()) }, "添加未登记组件抛 EcsException")
    let removed = e.removeComponentById(pid)
    check(removed.isSome(), "removeComponentById 返回被删组件")
    check(!e.hasComponent(pid), "删除后掩码清除")
    check(!p.constructed, "被删组件自动析构")
    check(p.entity.isNone(), "被删组件实体引用清空")
    world.clear()
}

/** 组件对象池 */
func testComponentPool(): Unit {
    println("testComponentPool")
    let world = World()
    let pid = PositionCpt.typeId()
    match (world.createComponent<PositionCpt>(pid)) {
        case Some(p1) =>
            p1.x = 123.0
            world.recycle(p1)
            match (world.createComponent<PositionCpt>(pid)) {
                case Some(p2) => check(p2.x == 123.0, "对象池复用同一组件实例（哨兵值保留）")
                case None => check(false, "池化创建组件失败(复用)")
            }
        case None => check(false, "池化创建组件失败(首次)")
    }
    let e = Player()
    world.addEntity(e)
    let p = PositionCpt()
    e.addComponent(p)
    expectEcsException({ => world.recycle(p) }, "回收仍挂在实体上的组件抛 EcsException")
    world.clear()
}

/** 系统-实体掩码匹配（哈希模式） */
func testSystemEntityMapping(): Unit {
    println("testSystemEntityMapping")
    let world = World()
    let sys = CountSystem()
    world.addSystem(sys)
    let e = Player()
    world.addEntity(e)

    world.onUpdate(0.016)
    check(sys.seen == 0, "无组件实体不命中系统")

    e.addComponent(PositionCpt())
    world.onUpdate(0.016)
    check(sys.seen == 1, "挂 PositionCpt 后命中系统")

    e.removeComponentById(PositionCpt.typeId())
    world.onUpdate(0.016)
    check(sys.seen == 1, "移除组件后不再命中")

    e.addComponent(PositionCpt())
    world.delEntity(e.etyId)
    world.onUpdate(0.016)
    check(sys.seen == 1, "删除实体后不再命中")

    world.clear()
}

/** 系统-实体掩码匹配（前缀树模式） */
func testTreeSysEtyMapManager(): Unit {
    println("testTreeSysEtyMapManager")
    let world = World(TreeSysEtyMapManager())
    let sys = CountSystem()
    world.addSystem(sys)
    let moveSys = MoveSystem()
    world.addSystem(moveSys)

    // 先挂系统再建实体：addEntity 经 fBitSubsetOf 命中匹配记录区
    let e = Player()
    e.addComponent(PositionCpt())
    world.addEntity(e)
    world.onUpdate(0.016)
    check(sys.seen == 1, "树模式：后建实体按掩码子集查询命中系统")

    // 组件变更：旧掩码移除 + 新掩码重挂
    e.addComponent(VelocityCpt())
    world.onUpdate(0.016)
    check(sys.seen == 2, "树模式：追加组件后仍命中原系统")

    e.removeComponentById(PositionCpt.typeId())
    world.onUpdate(0.016)
    check(sys.seen == 2, "树模式：移除组件后不再命中")

    // 删除系统：按掩码删除记录区
    world.delSystemById(sys.sysId)
    e.addComponent(PositionCpt())
    world.onUpdate(0.016)
    check(true, "树模式：删除系统后更新不崩溃")

    world.clear()
}

/** 系统掩码继承链叠加 */
func testSystemMaskInheritance(): Unit {
    println("testSystemMaskInheritance")
    let sys = DerivedCountSystem()
    check(sys.cptMask.get(PositionCpt.typeId()), "继承链：父层 @System 掩码位已收集")
    check(sys.cptMask.get(VelocityCpt.typeId()), "继承链：子层 @System 掩码位已收集")
    sys.destruct()
}

/** 完整流程（原 runEcsDemo 用例） */
func testMoveSystemFlow(): Unit {
    println("testMoveSystemFlow")
    let world = World()
    world.addSystem(MoveSystem())
    let e = Player()
    let etyId = e.etyId
    world.addEntity(e)

    match (world.createComponent<PositionCpt>(PositionCpt.typeId())) {
        case Some(p) =>
            p.x = 1.0
            e.addComponent(p)
        case None => check(false, "创建 PositionCpt 失败")
    }
    match (world.createComponent<VelocityCpt>(VelocityCpt.typeId())) {
        case Some(v) =>
            v.vx = 10.0
            e.addComponent(v)
        case None => check(false, "创建 VelocityCpt 失败")
    }

    world.onUpdate(0.1)
    match (e.getComponent<PositionCpt>(PositionCpt.typeId())) {
        case Some(p) => check(p.x > 1.0, "MoveSystem 驱动位移生效")
        case None => check(false, "获取 PositionCpt 失败")
    }

    world.delEntity(etyId)
    check(e.etyId == NUM_NONE, "流程结束删除实体自动回收 ID")
    let e2 = Player()
    check(e2.etyId == etyId, "流程结束回收 ID 被复用")

    world.clear()
}

//! ------------------------------------------------ 入口

main(): Int64 {
    println("== test_ecs ==")
    testComponentRegistry()
    testEntityLifecycle()
    testSystemLifecycle()
    testComponentAttach()
    testComponentPool()
    testSystemEntityMapping()
    testTreeSysEtyMapManager()
    testSystemMaskInheritance()
    testMoveSystemFlow()
    println("== passed=${_passed} failed=${_failed} ==")
    _failed
}
