/**
 * @file[zh-cn] Constraint 约束/关节便捷封装（three.physics.constraint 子包）
 * @brief[zh-cn] 提供约束/关节的便捷创建与运行时控制 API
 * @explain[zh-cn] 在 IPhysicsBackend.createConstraint 之上提供后端无关的便捷层，
 * 让"两个刚体之间加关节"一行完成（全部为类内静态方法）：
 * // 铰链门（世界空间锚点 + 轴）
 * let hinge = PhysicsConstraint.hinge(world, doorBody, frameBody,
 * Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0), -3.14, 3.14)
 * // 固定焊接
 * let fixed = PhysicsConstraint.fixed(world, aBody, bBody)
 * 支持的约束类型：
 * Fixed / Point / Hinge / Slider / Distance / Cone / SwingTwist / SixDOF / Gear
 * 设计要点：
 * - PhysicsConstraint 包装 PhysicsConstraintHandle，持有 world 引用，dispose() 销毁。
 * - 便捷构造以 PhysicsConstraint 类内静态方法呈现（fixed/point/hinge/slider/...）。
 * - 所有操作经 PhysicsWorld 的物理线程序列化，线程安全。
 *
 * @file[en] Constraint Constraint/joint convenience wrappers (three.physics.constraint sub-package)
 * @brief[en] Provides convenient constraint/joint creation and runtime control APIs
 * @explain[en] Provides a backend-agnostic convenience layer on top of
 * IPhysicsBackend.createConstraint, so adding a joint between two rigid bodies
 * is a one-liner (all exposed as static methods on the class):
 * // Hinge door (world-space anchor + axis)
 * let hinge = PhysicsConstraint.hinge(world, doorBody, frameBody,
 * Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, 1.0), -3.14, 3.14)
 * // Fixed weld
 * let fixed = PhysicsConstraint.fixed(world, aBody, bBody)
 * Supported constraint types:
 * Fixed / Point / Hinge / Slider / Distance / Cone / SwingTwist / SixDOF / Gear
 * Design notes:
 * - PhysicsConstraint wraps a PhysicsConstraintHandle, keeps a reference to the
 * world and disposes in dispose().
 * - Convenience constructors are exposed as static methods on PhysicsConstraint
 * (fixed/point/hinge/slider/...).
 * - All operations are serialized through the PhysicsWorld physics thread and are
 * thread-safe.
 */
package three.physics.constraint

import three.core.math.*
import three.physics.interfaces.*
import three.physics.world.*

/**
 * @brief[zh-cn] 约束运行时句柄封装
 * @explain[zh-cn] 用法：
 * let c = PhysicsConstraint.hinge(world, a, b, anchor, axis, -3.14, 3.14)
 * c.isEnabled()          // 查询是否启用
 * c.setEnabled(false)    // 临时断开约束
 * c.dispose()            // 销毁约束
 *
 * @brief[en] Runtime handle wrapper for a constraint
 * @explain[en] Usage:
 * let c = PhysicsConstraint.hinge(world, a, b, anchor, axis, -3.14, 3.14)
 * c.isEnabled()          // query whether it is enabled
 * c.setEnabled(false)    // temporarily disable the constraint
 * c.dispose()            // destroy the constraint
 */
public class PhysicsConstraint {
    /// 所属物理世界
    private var _world: PhysicsWorld
    /// 约束句柄
    private var _handle: PhysicsConstraintHandle

    /// 是否已销毁
    private var _disposed: Bool = false

    /**
     * @brief[zh-cn] 创建约束封装（通常由静态构造方法创建，无需直接调用）
     * @param[zh-cn] world 所属物理世界
     * handle 底层约束句柄
     *
     * @brief[en] Creates a constraint wrapper (normally created by the static constructors; no need to call directly)
     * @param[en] world The owning physics world
     * handle The underlying constraint handle
     */
    public init(world!: PhysicsWorld, handle!: PhysicsConstraintHandle) {
        this._world = world
        this._handle = handle
    }

    /**
     * @brief[zh-cn] 获取约束句柄（销毁后为 INVALID）
     *
     * @brief[en] Gets the constraint handle (INVALID after disposal)
     */
    public prop handle: PhysicsConstraintHandle {
        get() { this._handle }
    }

    /**
     * @brief[zh-cn] 约束是否有效（已创建且未销毁）
     * @return[zh-cn] 有效返回 true
     *
     * @brief[en] Whether the constraint is valid (created and not disposed)
     * @return[en] true if valid
     */
    public func isValid(): Bool {
        return !this._disposed && this._handle.isValid()
    }

    /**
     * @brief[zh-cn] 约束是否启用
     * @return[zh-cn] 启用返回 true
     *
     * @brief[en] Whether the constraint is enabled
     * @return[en] true if enabled
     */
    public func isEnabled(): Bool {
        if (!this.isValid()) { return false }
        return this._world.isConstraintEnabled(this._handle)
    }

    /**
     * @brief[zh-cn] 设置约束是否启用
     * @param[zh-cn] enabled true 启用，false 临时断开约束
     * @return[zh-cn] 返回 this，便于链式调用
     *
     * @brief[en] Sets whether the constraint is enabled
     * @param[en] enabled true to enable, false to temporarily disable the constraint
     * @return[en] Returns this for chaining
     */
    public func setEnabled(enabled: Bool): PhysicsConstraint {
        if (this.isValid()) {
            this._world.setConstraintEnabled(this._handle, enabled)
        }
        return this
    }

    /**
     * @brief[zh-cn] 销毁约束并从世界移除
     *
     * @brief[en] Disposes the constraint and removes it from the world
     */
    public func dispose(): Unit {
        if (this._disposed) { return }
        if (this._handle.isValid()) {
            this._world.destroyConstraint(this._handle)
        }
        this._handle = PhysicsConstraintHandle.INVALID
        this._disposed = true
    }

    // =========================================================================
    // 静态便捷构造（用法：PhysicsConstraint.fixed(world, a, b)）
    // =========================================================================

    /**
     * @brief[zh-cn] 创建固定约束：将两刚体焊接在一起，无相对运动
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a fixed constraint: welds two bodies together with no relative motion
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * @return[en] The newly created constraint wrapper
     */
    public static func fixed(world: PhysicsWorld,
                             bodyA: PhysicsBodyHandle,
                             bodyB: PhysicsBodyHandle): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.Fixed,
            space: PhysicsConstraintSpace.WorldSpace)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }

    /**
     * @brief[zh-cn] 创建点约束（球关节）：两刚体共享一个锚点，可自由旋转
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * anchor 共享锚点（世界坐标）
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a point constraint (ball joint): both bodies share an anchor point and can rotate freely
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * anchor The shared anchor point (world coordinates)
     * @return[en] The newly created constraint wrapper
     */
    public static func point(world: PhysicsWorld,
                             bodyA: PhysicsBodyHandle,
                             bodyB: PhysicsBodyHandle,
                             anchor: Vector3): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.Point,
            space: PhysicsConstraintSpace.WorldSpace,
            anchor1: anchor, anchor2: anchor)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }

    /**
     * @brief[zh-cn] 创建铰链约束：绕单轴旋转，可设角度限位（弧度）
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * anchor 铰链锚点（世界坐标）
     * axis 旋转轴（世界方向）
     * limitMin 最小旋转角（弧度，默认 -π 无限制）
     * limitMax 最大旋转角（弧度，默认 +π 无限制）
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a hinge constraint: rotation about a single axis, with optional angle limits (radians)
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * anchor The hinge anchor point (world coordinates)
     * axis The rotation axis (world direction)
     * limitMin The minimum rotation angle (radians, default -π, no limit)
     * limitMax The maximum rotation angle (radians, default +π, no limit)
     * @return[en] The newly created constraint wrapper
     */
    public static func hinge(world: PhysicsWorld,
                             bodyA: PhysicsBodyHandle,
                             bodyB: PhysicsBodyHandle,
                             anchor: Vector3, axis: Vector3,
                             limitMin!: Float64 = -3.14159265358979,
                             limitMax!: Float64 = 3.14159265358979): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.Hinge,
            space: PhysicsConstraintSpace.WorldSpace,
            anchor1: anchor, anchor2: anchor,
            axis1: axis, axis2: axis,
            limitMin: limitMin, limitMax: limitMax)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }

    /**
     * @brief[zh-cn] 创建滑块约束：沿单轴平移（可限位），如抽屉、活塞
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * anchor 滑块锚点（世界坐标）
     * axis 滑动轴（世界方向）
     * limitMin 最小平移距离
     * limitMax 最大平移距离
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a slider constraint: translation along a single axis (with optional limits), e.g. drawers, pistons
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * anchor The slider anchor point (world coordinates)
     * axis The sliding axis (world direction)
     * limitMin The minimum translation distance
     * limitMax The maximum translation distance
     * @return[en] The newly created constraint wrapper
     */
    public static func slider(world: PhysicsWorld,
                              bodyA: PhysicsBodyHandle,
                              bodyB: PhysicsBodyHandle,
                              anchor: Vector3, axis: Vector3,
                              limitMin: Float64, limitMax: Float64): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.Slider,
            space: PhysicsConstraintSpace.WorldSpace,
            anchor1: anchor, anchor2: anchor,
            axis1: axis, axis2: axis,
            limitMin: limitMin, limitMax: limitMax)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }

    /**
     * @brief[zh-cn] 创建距离约束：保持两锚点间距离（可带弹簧范围）
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * anchor1 第一个锚点（世界坐标）
     * anchor2 第二个锚点（世界坐标）
     * minDist 最小距离
     * maxDist 最大距离
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a distance constraint: keeps the distance between two anchor points (with an optional spring range)
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * anchor1 The first anchor point (world coordinates)
     * anchor2 The second anchor point (world coordinates)
     * minDist The minimum distance
     * maxDist The maximum distance
     * @return[en] The newly created constraint wrapper
     */
    public static func distance(world: PhysicsWorld,
                                bodyA: PhysicsBodyHandle,
                                bodyB: PhysicsBodyHandle,
                                anchor1: Vector3, anchor2: Vector3,
                                minDist: Float64, maxDist: Float64): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.Distance,
            space: PhysicsConstraintSpace.WorldSpace,
            anchor1: anchor1, anchor2: anchor2,
            limitMin: minDist, limitMax: maxDist)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }

    /**
     * @brief[zh-cn] 创建锥约束：锥角限制的球关节（如肩关节）
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * anchor 锚点（世界坐标）
     * axis 锥轴方向（世界坐标）
     * halfAngle 锥半角（弧度）
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a cone constraint: a ball joint with a cone-angle limit (e.g. a shoulder joint)
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * anchor The anchor point (world coordinates)
     * axis The cone axis direction (world coordinates)
     * halfAngle The cone half-angle (radians)
     * @return[en] The newly created constraint wrapper
     */
    public static func cone(world: PhysicsWorld,
                            bodyA: PhysicsBodyHandle,
                            bodyB: PhysicsBodyHandle,
                            anchor: Vector3, axis: Vector3,
                            halfAngle: Float64): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.Cone,
            space: PhysicsConstraintSpace.WorldSpace,
            anchor1: anchor, anchor2: anchor,
            axis1: axis, axis2: axis,
            limitMin: halfAngle)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }

    /**
     * @brief[zh-cn] 创建摆动-扭转约束（肩/髋关节，扭转角限位）
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * anchor 锚点（世界坐标）
     * twistAxis 扭转轴方向
     * planeAxis 摆动平面轴方向
     * twistMin 最小扭转角（弧度）
     * twistMax 最大扭转角（弧度）
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a swing-twist constraint (shoulder/hip joint, with a twist-angle limit)
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * anchor The anchor point (world coordinates)
     * twistAxis The twist-axis direction
     * planeAxis The swing-plane axis direction
     * twistMin The minimum twist angle (radians)
     * twistMax The maximum twist angle (radians)
     * @return[en] The newly created constraint wrapper
     */
    public static func swingTwist(world: PhysicsWorld,
                                  bodyA: PhysicsBodyHandle,
                                  bodyB: PhysicsBodyHandle,
                                  anchor: Vector3,
                                  twistAxis: Vector3, planeAxis: Vector3,
                                  twistMin: Float64, twistMax: Float64): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.SwingTwist,
            space: PhysicsConstraintSpace.WorldSpace,
            anchor1: anchor, anchor2: anchor,
            axis1: twistAxis, axis2: twistAxis,
            planeAxis: planeAxis,
            limitMin: twistMin, limitMax: twistMax)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }

    /**
     * @brief[zh-cn] 创建齿轮约束：以固定比例耦合两铰链的旋转（传动）
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * anchor 锚点（世界坐标）
     * hingeAxis 铰链轴方向
     * ratio 传动比
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a gear constraint: couples the rotation of two hinges at a fixed ratio (transmission)
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * anchor The anchor point (world coordinates)
     * hingeAxis The hinge-axis direction
     * ratio The gear ratio
     * @return[en] The newly created constraint wrapper
     */
    public static func gear(world: PhysicsWorld,
                            bodyA: PhysicsBodyHandle,
                            bodyB: PhysicsBodyHandle,
                            anchor: Vector3, hingeAxis: Vector3,
                            ratio: Float64): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.Gear,
            space: PhysicsConstraintSpace.WorldSpace,
            anchor1: anchor, anchor2: anchor,
            axis1: hingeAxis, axis2: hingeAxis,
            limitMin: ratio)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }

    /**
     * @brief[zh-cn] 创建六自由度约束：共享锚点，每自由度可 Free/Limited/Locked（默认全 Free = 球关节）
     * @param[zh-cn] world 所属物理世界
     * bodyA 第一个刚体句柄
     * bodyB 第二个刚体句柄
     * anchor 共享锚点（世界坐标）
     * axisX 第一个局部轴方向（默认 X 轴）
     * @return[zh-cn] 新建的约束封装
     *
     * @brief[en] Creates a six-DOF constraint: shared anchor, each degree of freedom can be Free/Limited/Locked (all Free by default = ball joint)
     * @param[en] world The owning physics world
     * bodyA The first body handle
     * bodyB The second body handle
     * anchor The shared anchor point (world coordinates)
     * axisX The first local-axis direction (X axis by default)
     * @return[en] The newly created constraint wrapper
     */
    public static func sixDOF(world: PhysicsWorld,
                              bodyA: PhysicsBodyHandle,
                              bodyB: PhysicsBodyHandle,
                              anchor: Vector3,
                              axisX!: Vector3 = Vector3(1.0, 0.0, 0.0)): PhysicsConstraint {
        let desc = PhysicsConstraintDesc(
            constraintType: PhysicsConstraintType.SixDOF,
            space: PhysicsConstraintSpace.WorldSpace,
            anchor1: anchor, anchor2: anchor,
            axis1: axisX, axis2: axisX)
        return PhysicsConstraint(world: world,
            handle: world.createConstraint(desc, bodyA, bodyB))
    }
}

// =============================================================================
// 便捷约束构造已收拢为 PhysicsConstraint 类内静态方法：
//   PhysicsConstraint.fixed(world, a, b) / point(world, a, b, anchor)
//   / hinge(world, a, b, anchor, axis, limitMin, limitMax)
//   / slider(world, a, b, anchor, axis, limitMin, limitMax)
//   / distance(world, a, b, anchor1, anchor2, minDist, maxDist)
//   / cone(world, a, b, anchor, axis, halfAngle)
//   / swingTwist(world, a, b, anchor, twistAxis, planeAxis, twistMin, twistMax)
//   / gear(world, a, b, anchor, hingeAxis, ratio) / sixDOF(world, a, b, anchor)
// =============================================================================
