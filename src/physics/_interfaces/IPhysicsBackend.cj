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
 * @file[zh-cn] IPhysicsBackend 可插拔物理后端抽象接口
 * @brief[zh-cn] 定义后端无关的物理抽象类型与后端接口
 * @explain[zh-cn] 设计目标：three.physics 上层（PhysicsWorld/RigidBody/Binding）只依赖本接口与
 * PhysicsShape/PhysicsBodyDesc/PhysicsQueryResult 等抽象类型，不直接依赖任何具体
 * 物理库。替换底层物理计算库（JoltPhysics/PhysX/Bullet/…）只需新写一个实现本接口
 * 的 backend 包，PhysicsWorld.setBackend 切换即可。
 * 命名约定：后端实现以 XxxBackend 命名；所有抽象类型冠 Physics 前缀以与
 * 渲染侧 Geometry/Shape 区分。后端实例由具体 backend 包构造，由 PhysicsWorld 持有。
 * 线程约定：本接口所有方法均在 PhysicsWorld 的专用物理线程内被调用（由
 * PhysicsWorld._execPhysics 序列化），实现内部无需额外加锁；但实现持有的底层
 * 句柄在物理线程外不可触碰。
 * 能力覆盖：Collision/RigidBody/Character/Constraint 所需能力均由本接口方法集表达。
 *
 * @file[en] IPhysicsBackend Pluggable physics backend abstraction interface
 * @brief[en] Defines backend-agnostic physics abstractions and the backend interface
 * @explain[en] Design goal: the upper three.physics layers (PhysicsWorld/RigidBody/Binding)
 * depend only on this interface and the abstract types such as PhysicsShape,
 * PhysicsBodyDesc and the query results, never on any concrete physics library.
 * Swapping the underlying engine (JoltPhysics/PhysX/Bullet/…) only requires a new
 * backend package implementing this interface and a PhysicsWorld.setBackend call.
 * Naming: backend implementations are named XxxBackend; all abstract types carry
 * the Physics prefix to distinguish them from renderers-side Geometry/Shape.
 * Backend instances are constructed by the concrete backend package and owned by
 * PhysicsWorld.
 * Threading: every method here is invoked on PhysicsWorld's dedicated physics
 * thread (serialized via PhysicsWorld._execPhysics), so implementations need no
 * internal locking; however their underlying handles must not be touched outside
 * that thread.
 * Capabilities: everything needed by Collision/RigidBody/Character/Constraint is
 * expressed by the method set of this interface.
 */
protected package three.physics._interfaces

import three.core.math.*
import std.collection.*
import three.physics.common.*

// =============================================================================
// 枚举：刚体运动类型 / 激活策略 / 物理层
// =============================================================================

/**
 * @brief[zh-cn] 传感器回调（后端无关）
 * @explain[zh-cn] 覆盖 Jolt 的 ContactListener / BodyActivationListener。
 * 由后端在物理线程内调用（回调内禁止调用走 _execPhysics 的方法，防死锁）。
 * 注意：传感器回调依赖底层库的回调机制（joltc 的 Procs 表），
 * 接入方法随后端实现而定；JoltBackend 通过 setContactListener 等注册。
 *
 * @brief[en] Sensor callbacks (backend-agnostic)
 * @explain[en] Mirrors Jolt's ContactListener / BodyActivationListener.
 * Called by the backend on the physics thread (do not call methods that go through
 * _execPhysics from inside a callback, to avoid deadlock).
 * Note: these callbacks rely on the underlying library's callback mechanism
 * (joltc's Procs table); wiring them up depends on the backend implementation, e.g.
 * JoltBackend registers via setContactListener.
 */
public interface IPhysicsSensorListener {
    /**
     * @brief[zh-cn] 接触事件回调（Added/Persisted/Removed）
     * @param[zh-cn] bodyID1 刚体 1 的 BodyID
     * bodyID2 刚体 2 的 BodyID
     * event 接触事件类型
     *
     * @brief[en] Contact event callback (Added/Persisted/Removed)
     * @param[en] bodyID1 The BodyID of body 1
     * bodyID2 The BodyID of body 2
     * event The contact event type
     */
    func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit
    /**
     * @brief[zh-cn] 刚体被激活（开始模拟）
     * @param[zh-cn] bodyID 被激活刚体的 BodyID
     *
     * @brief[en] A body was activated (starts simulating)
     * @param[en] bodyID The activated body's BodyID
     */
    func onBodyActivated(bodyID: UInt32): Unit
    /**
     * @brief[zh-cn] 刚体休眠（停止模拟）
     * @param[zh-cn] bodyID 休眠刚体的 BodyID
     *
     * @brief[en] A body went to sleep (stops simulating)
     * @param[en] bodyID The sleeping body's BodyID
     */
    func onBodyDeactivated(bodyID: UInt32): Unit
}

// =============================================================================
// 后端句柄类型
// =============================================================================

/**
 * @brief[zh-cn] 可插拔物理后端接口
 * @explain[zh-cn] 实现方职责：
 * - 管理底层物理库的全局初始化/卸载（JPH_Init/JPH_Shutdown 等）；
 * - 创建/销毁物理系统（含作业系统、层过滤）；
 * - 创建/销毁碰撞形状与刚体；
 * - 步进物理世界（update）；
 * - 读写刚体 transform/速度/摩擦/弹性/运动类型/对象层；
 * - 射线与碰撞查询。
 * 调用方（PhysicsWorld）职责：
 * - 在专用物理线程内调用本接口所有方法；
 * - 维护 Object3D ↔ PhysicsBodyHandle 绑定映射；
 * - 步进后读回刚体 transform 同步到绑定的 Object3D。
 * 线程安全：实现不需要线程安全（单线程物理线程内调用）；
 * 但实现的底层句柄在物理线程外不可访问。
 *
 * @brief[en] Pluggable physics backend interface
 * @explain[en] Implementer responsibilities:
 * - manage the underlying library's global init/shutdown (JPH_Init/JPH_Shutdown, etc.);
 * - create/destroy the physics system (including the job system and layer filter);
 * - create/destroy collision shapes and bodies;
 * - step the physics world (update);
 * - read/write body transform/velocity/friction/restitution/motion type/object layer;
 * - ray and collision queries.
 * Caller (PhysicsWorld) responsibilities:
 * - call every method of this interface on a dedicated physics thread;
 * - maintain the Object3D ↔ PhysicsBodyHandle binding map;
 * - read back body transforms after stepping to sync the bound Object3D.
 * Thread safety: the implementation need not be thread-safe (all calls happen on a
 * single physics thread); however, the implementation's underlying handles must not
 * be accessed outside that thread.
 */
public interface IPhysicsBackend {
    // ===== 生命周期 =====

    /**
     * @brief[zh-cn] 初始化后端（全局初始化 + 创建物理系统/作业系统/层过滤）
     * @param[zh-cn] maxBodies 世界最多刚体数
     * gravity 全局重力向量（如 (0, -9.81, 0)）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Initializes the backend (global init + creates the physics system/job system/layer filter)
     * @param[en] maxBodies Maximum number of bodies in the world
     * gravity The global gravity vector (e.g. (0, -9.81, 0))
     * @return[en] true on success
     */
    func initialize(maxBodies: UInt32, gravity: Vector3): Bool

    /**
     * @brief[zh-cn] 释放后端
     * @return[zh-cn] 本次调用真正执行了释放返回 true；重复调用返回 false
     *
     * @brief[en] Releases the backend
     *            and de-initializes the library)
     * @return[en] true if this call actually released; false on repeated calls
     */
    func release(): Bool

    /**
     * @brief[zh-cn] 是否已初始化
     * @return[zh-cn] 已初始化返回 true
     *
     * @brief[en] Whether the backend is initialized
     * @return[en] true if initialized
     */
    func isInitialized(): Bool

    // ===== 世界设置 =====

    /**
     * @brief[zh-cn] 设置全局重力
     * @param[zh-cn] gravity 重力向量（如 (0, -9.81, 0)）
     *
     * @brief[en] Sets the global gravity
     * @param[en] gravity The gravity vector (e.g. (0, -9.81, 0))
     */
    func setGravity(gravity: Vector3): Unit

    /**
     * @brief[zh-cn] 优化 BroadPhase 包围盒树
     * @note[zh-cn] 在批量插入刚体后、正式模拟前调用一次。
     *
     * @brief[en] Optimizes the BroadPhase bounding-volume tree
     * @note[en] Call once after bulk-inserting bodies and before the main simulation.
     */
    func optimizeBroadPhase(): Unit

    // ===== 形状/刚体 =====

    /**
     * @brief[zh-cn] 创建刚体并加入物理世界（一步完成）
     * @param[zh-cn] desc 刚体创建描述
     * @return[zh-cn] 刚体句柄；失败返回 INVALID
     *
     * @brief[en] Creates a body and adds it to the physics world (single step)
     * @param[en] desc The body creation description
     * @return[en] The body handle, or INVALID on failure
     */
    func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle

    /**
     * @brief[zh-cn] 移除并销毁刚体（一步完成，句柄立即失效）
     * @param[zh-cn] handle 刚体句柄
     *
     * @brief[en] Removes and destroys a body (single step; the handle becomes invalid immediately)
     * @param[en] handle The body handle
     */
    func destroyBody(handle: PhysicsBodyHandle): Unit

    /**
     * @brief[zh-cn] 查询刚体是否处于活动（模拟）状态
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 活动返回 true
     *
     * @brief[en] Queries whether a body is in the active (simulating) state
     * @param[en] handle The body handle
     * @return[en] true if active
     */
    func isBodyActive(handle: PhysicsBodyHandle): Bool

    /**
     * @brief[zh-cn] 设置刚体是否为传感器
     * @param[zh-cn] handle 刚体句柄
     * isSensor 是否传感器（只检测碰撞、不产生物理响应）
     *
     * @brief[en] Sets whether a body is a sensor
     * @param[en] handle The body handle
     * isSensor Whether the body is a sensor (collision-only, no physical response)
     */
    func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit

    // ===== Transform 读写 =====

    /**
     * @brief[zh-cn] 设置刚体位置（世界坐标）
     * @param[zh-cn] handle 刚体句柄
     * position 新位置
     * activation 激活策略
     *
     * @brief[en] Sets the body position (world coordinates)
     * @param[en] handle The body handle
     * position The new position
     * activation The activation strategy
     */
    func setPosition(handle: PhysicsBodyHandle, position: Vector3,
                     activation: PhysicsActivation): Unit

    /**
     * @brief[zh-cn] 获取刚体位置（世界坐标）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前位置
     *
     * @brief[en] Gets the body position (world coordinates)
     * @param[en] handle The body handle
     * @return[en] The body's current position
     */
    func getPosition(handle: PhysicsBodyHandle): Vector3

    /**
     * @brief[zh-cn] 设置刚体旋转（四元数）
     * @param[zh-cn] handle 刚体句柄
     * rotation 新旋转
     * activation 激活策略
     *
     * @brief[en] Sets the body rotation (quaternion)
     * @param[en] handle The body handle
     * rotation The new rotation
     * activation The activation strategy
     */
    func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion,
                     activation: PhysicsActivation): Unit

    /**
     * @brief[zh-cn] 获取刚体旋转（四元数）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前旋转
     *
     * @brief[en] Gets the body rotation (quaternion)
     * @param[en] handle The body handle
     * @return[en] The body's current rotation
     */
    func getRotation(handle: PhysicsBodyHandle): Quaternion

    // ===== 速度读写 =====

    /**
     * @brief[zh-cn] 设置刚体线速度（世界空间，米/秒）
     * @param[zh-cn] handle 刚体句柄
     * velocity 线速度
     *
     * @brief[en] Sets the body linear velocity (world space, m/s)
     * @param[en] handle The body handle
     * velocity The linear velocity
     */
    func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit

    /**
     * @brief[zh-cn] 获取刚体线速度（世界空间，米/秒）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前线速度
     *
     * @brief[en] Gets the body linear velocity (world space, m/s)
     * @param[en] handle The body handle
     * @return[en] The body's current linear velocity
     */
    func getLinearVelocity(handle: PhysicsBodyHandle): Vector3

    /**
     * @brief[zh-cn] 设置刚体角速度（世界空间，弧度/秒）
     * @param[zh-cn] handle 刚体句柄
     * angularVelocity 角速度
     *
     * @brief[en] Sets the body angular velocity (world space, rad/s)
     * @param[en] handle The body handle
     * angularVelocity The angular velocity
     */
    func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit

    /**
     * @brief[zh-cn] 获取刚体角速度（世界空间，弧度/秒）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前角速度
     *
     * @brief[en] Gets the body angular velocity (world space, rad/s)
     * @param[en] handle The body handle
     * @return[en] The body's current angular velocity
     */
    func getAngularVelocity(handle: PhysicsBodyHandle): Vector3

    // ===== 物理 material 读写 =====

    /**
     * @brief[zh-cn] 设置刚体摩擦系数（0~1）
     * @param[zh-cn] handle 刚体句柄
     * friction 摩擦系数
     *
     * @brief[en] Sets the body friction coefficient (0~1)
     * @param[en] handle The body handle
     * friction The friction coefficient
     */
    func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit

    /**
     * @brief[zh-cn] 获取刚体摩擦系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前摩擦系数
     *
     * @brief[en] Gets the body friction coefficient
     * @param[en] handle The body handle
     * @return[en] The body's current friction coefficient
     */
    func getFriction(handle: PhysicsBodyHandle): Float64

    /**
     * @brief[zh-cn] 设置刚体弹性系数（0~1）
     * @param[zh-cn] handle 刚体句柄
     * restitution 弹性系数
     *
     * @brief[en] Sets the body restitution coefficient (0~1)
     * @param[en] handle The body handle
     * restitution The restitution coefficient
     */
    func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit

    /**
     * @brief[zh-cn] 获取刚体弹性系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前弹性系数
     *
     * @brief[en] Gets the body restitution coefficient
     * @param[en] handle The body handle
     * @return[en] The body's current restitution coefficient
     */
    func getRestitution(handle: PhysicsBodyHandle): Float64

    // ===== 运动属性 =====

    /**
     * @brief[zh-cn] 设置刚体运动类型（运行时切换 Static/Kinematic/Dynamic）
     * @param[zh-cn] handle 刚体句柄
     * motionType 目标运动类型
     * activation 激活策略
     *
     * @brief[en] Sets the body motion type (switch Static/Kinematic/Dynamic at runtime)
     * @param[en] handle The body handle
     * motionType The target motion type
     * activation The activation strategy
     */
    func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType,
                       activation: PhysicsActivation): Unit

    /**
     * @brief[zh-cn] 获取刚体运动类型
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前运动类型
     *
     * @brief[en] Gets the body motion type
     * @param[en] handle The body handle
     * @return[en] The body's current motion type
     */
    func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType

    /**
     * @brief[zh-cn] 设置刚体对象层（运行时改变碰撞分组）
     * @param[zh-cn] handle 刚体句柄
     * layer 目标对象层
     *
     * @brief[en] Sets the body object layer (changes the collision grouping at runtime)
     * @param[en] handle The body handle
     * layer The target object layer
     */
    func setObjectLayer(handle: PhysicsBodyHandle, layer: PhysicsLayer): Unit

    /**
     * @brief[zh-cn] 获取刚体对象层
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前对象层
     *
     * @brief[en] Gets the body object layer
     * @param[en] handle The body handle
     * @return[en] The body's current object layer
     */
    func getObjectLayer(handle: PhysicsBodyHandle): PhysicsLayer

    // ===== 力 / 力矩 / 冲量 =====

    /**
     * @brief[zh-cn] 在刚体质心施加力（牛顿）
     * @param[zh-cn] handle 刚体句柄
     * force 力向量
     *
     * @brief[en] Applies a force at the body's center of mass (newtons)
     * @param[en] handle The body handle
     * force The force vector
     */
    func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit

    /**
     * @brief[zh-cn] 在刚体指定世界位置施加力（牛顿）
     * @param[zh-cn] handle 刚体句柄
     * force 力向量
     * point 作用点（世界坐标）
     *
     * @brief[en] Applies a force at a specified world position on the body (newtons)
     * @param[en] handle The body handle
     * force The force vector
     * point The point of application (world coordinates)
     */
    func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit

    /**
     * @brief[zh-cn] 施加力矩（牛顿·米）
     * @param[zh-cn] handle 刚体句柄
     * torque 力矩向量
     *
     * @brief[en] Applies a torque (newton-meters)
     * @param[en] handle The body handle
     * torque The torque vector
     */
    func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit

    /**
     * @brief[zh-cn] 在刚体质心施加冲量（冲量 = 力 × 时间）
     * @param[zh-cn] handle 刚体句柄
     * impulse 冲量向量
     *
     * @brief[en] Applies an impulse at the body's center of mass (impulse = force × time)
     * @param[en] handle The body handle
     * impulse The impulse vector
     */
    func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit

    /**
     * @brief[zh-cn] 施加角冲量
     * @param[zh-cn] handle 刚体句柄
     * angularImpulse 角冲量向量
     *
     * @brief[en] Applies an angular impulse
     * @param[en] handle The body handle
     * angularImpulse The angular impulse vector
     */
    func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit

    // ===== 质量 / 惯量 =====

    /**
     * @brief[zh-cn] 获取刚体质量（千克）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前质量
     *
     * @brief[en] Gets the body mass (kilograms)
     * @param[en] handle The body handle
     * @return[en] The body's current mass
     */
    func getMass(handle: PhysicsBodyHandle): Float64

    /**
     * @brief[zh-cn] 设置刚体质量（千克）
     * @param[zh-cn] handle 刚体句柄
     * mass 目标质量
     *
     * @brief[en] Sets the body mass (kilograms)
     * @param[en] handle The body handle
     * mass The target mass
     */
    func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit

    /**
     * @brief[zh-cn] 获取刚体逆惯量（3x3，输出 4x4 矩阵左上角）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前逆惯量矩阵
     *
     * @brief[en] Gets the body inverse inertia (3x3, in the top-left of the returned 4x4)
     * @param[en] handle The body handle
     * @return[en] The body's current inverse-inertia matrix
     */
    func getInverseInertia(handle: PhysicsBodyHandle): Matrix4

    /**
     * @brief[zh-cn] 设置刚体重力因子（1 = 正常重力，0 = 无重力）
     * @param[zh-cn] handle 刚体句柄
     * gravityFactor 重力因子
     *
     * @brief[en] Sets the body gravity factor (1 = normal gravity, 0 = no gravity)
     * @param[en] handle The body handle
     * gravityFactor The gravity factor
     */
    func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit

    /**
     * @brief[zh-cn] 获取刚体重力因子
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前重力因子
     *
     * @brief[en] Gets the body gravity factor
     * @param[en] handle The body handle
     * @return[en] The body's current gravity factor
     */
    func getGravityFactor(handle: PhysicsBodyHandle): Float64

    // ===== 运动学 =====

    /**
     * @brief[zh-cn] 运动学刚体移动到指定位置/旋转
     * @param[zh-cn] handle 刚体句柄
     * position 目标位置（世界坐标）
     * rotation 目标旋转
     * deltaTime 时间步长（秒）
     * @note[zh-cn] 每帧调用，由 deltaTime 步长驱动。
     *
     * @brief[en] Moves a kinematic body to the given position/rotation
     * @param[en] handle The body handle
     * position The target position (world coordinates)
     * rotation The target rotation
     * deltaTime The time step (seconds)
     * @note[en] Call every frame; driven by the deltaTime step.
     */
    func moveKinematic(handle: PhysicsBodyHandle, position: Vector3,
                       rotation: Quaternion, deltaTime: Float32): Unit

    // ===== 约束 =====

    /**
     * @brief[zh-cn] 创建约束并加入世界（连接两个刚体）
     * @param[zh-cn] desc 约束创建描述
     * bodyA 约束刚体 1
     * bodyB 约束刚体 2
     * @return[zh-cn] 约束句柄；失败返回 INVALID
     *
     * @brief[en] Creates a constraint and adds it to the world (connecting two bodies)
     * @param[en] desc The constraint creation description
     * bodyA The first constrained body
     * bodyB The second constrained body
     * @return[en] The constraint handle, or INVALID on failure
     */
    func createConstraint(desc: PhysicsConstraintDesc,
                          bodyA: PhysicsBodyHandle,
                          bodyB: PhysicsBodyHandle): PhysicsConstraintHandle

    /**
     * @brief[zh-cn] 销毁约束并从世界移除（句柄立即失效）
     * @param[zh-cn] handle 约束句柄
     *
     * @brief[en] Destroys a constraint and removes it from the world (the handle becomes invalid immediately)
     * @param[en] handle The constraint handle
     */
    func destroyConstraint(handle: PhysicsConstraintHandle): Unit

    /**
     * @brief[zh-cn] 约束是否启用
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 启用返回 true
     *
     * @brief[en] Whether the constraint is enabled
     * @param[en] handle The constraint handle
     * @return[en] true if enabled
     */
    func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool

    /**
     * @brief[zh-cn] 设置约束是否启用
     * @param[zh-cn] handle 约束句柄
     * enabled 是否启用
     *
     * @brief[en] Sets whether the constraint is enabled
     * @param[en] handle The constraint handle
     * enabled Whether to enable the constraint
     */
    func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit

    /**
     * @brief[zh-cn] 设置约束电机状态（Hinge/Slider 约束）
     * @param[zh-cn] handle 约束句柄
     * state 电机状态（Off/Velocity/Position）
     * @note[zh-cn] 仅对 Hinge/Slider 约束有效；SixDOF 请用六自由度专用接口
     *
     * @brief[en] Sets the constraint motor state (Hinge/Slider)
     * @param[en] handle The constraint handle
     * state The motor state (Off/Velocity/Position)
     * @note[en] Only valid for Hinge/Slider constraints; use the SixDOF-specific API for SixDOF
     */
    func setConstraintMotorState(handle: PhysicsConstraintHandle, state: PhysicsMotorState): Unit

    /**
     * @brief[zh-cn] 设置铰链约束目标角速度（电机速度模式，弧度/秒）
     * @param[zh-cn] handle 约束句柄
     * angularVelocity 目标角速度（弧度/秒）
     *
     * @brief[en] Sets the hinge constraint target angular velocity (motor velocity mode, rad/s)
     * @param[en] handle The constraint handle
     * angularVelocity The target angular velocity (rad/s)
     */
    func setConstraintTargetAngularVelocity(handle: PhysicsConstraintHandle, angularVelocity: Float64): Unit

    /**
     * @brief[zh-cn] 设置铰链约束目标角度（电机位置模式，弧度）
     * @param[zh-cn] handle 约束句柄
     * angle 目标角度（弧度）
     *
     * @brief[en] Sets the hinge constraint target angle (motor position mode, radians)
     * @param[en] handle The constraint handle
     * angle The target angle (radians)
     */
    func setConstraintTargetAngle(handle: PhysicsConstraintHandle, angle: Float64): Unit

    /**
     * @brief[zh-cn] 获取铰链约束当前角度（弧度）
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 当前角度（弧度）；无效句柄返回 0
     *
     * @brief[en] Gets the hinge constraint current angle (radians)
     * @param[en] handle The constraint handle
     * @return[en] The current angle (radians); 0 for an invalid handle
     */
    func getConstraintCurrentAngle(handle: PhysicsConstraintHandle): Float64

    /**
     * @brief[zh-cn] 设置滑块约束目标速度（电机速度模式，米/秒）
     * @param[zh-cn] handle 约束句柄
     * velocity 目标速度（米/秒）
     *
     * @brief[en] Sets the slider constraint target velocity (motor velocity mode, m/s)
     * @param[en] handle The constraint handle
     * velocity The target velocity (m/s)
     */
    func setSliderTargetVelocity(handle: PhysicsConstraintHandle, velocity: Float64): Unit

    /**
     * @brief[zh-cn] 设置滑块约束目标位置（电机位置模式，米）
     * @param[zh-cn] handle 约束句柄
     * position 目标位置（米）
     *
     * @brief[en] Sets the slider constraint target position (motor position mode, meters)
     * @param[en] handle The constraint handle
     * position The target position (meters)
     */
    func setSliderTargetPosition(handle: PhysicsConstraintHandle, position: Float64): Unit

    /**
     * @brief[zh-cn] 获取滑块约束当前位置（米）
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 当前位置（米）；无效句柄返回 0
     *
     * @brief[en] Gets the slider constraint current position (meters)
     * @param[en] handle The constraint handle
     * @return[en] The current position (meters); 0 for an invalid handle
     */
    func getSliderCurrentPosition(handle: PhysicsConstraintHandle): Float64

    /**
     * @brief[zh-cn] 运行时修改约束限位（Hinge/Slider，弧度或米）
     * @param[zh-cn] handle 约束句柄
     * limitMin 限位最小值
     * limitMax 限位最大值
     * @note[zh-cn] 仅对 Hinge/Slider 约束有效
     *
     * @brief[en] Updates constraint limits at runtime (Hinge/Slider, radians or meters)
     * @param[en] handle The constraint handle
     * limitMin The minimum limit
     * limitMax The maximum limit
     * @note[en] Only valid for Hinge/Slider constraints
     */
    func setConstraintLimits(handle: PhysicsConstraintHandle, limitMin: Float64, limitMax: Float64): Unit

    /**
     * @brief[zh-cn] 设置约束最大摩擦（Hinge 为力矩，Slider 为力）
     * @param[zh-cn] handle 约束句柄
     * friction 最大摩擦值
     *
     * @brief[en] Sets the constraint max friction (torque for Hinge, force for Slider)
     * @param[en] handle The constraint handle
     * friction The maximum friction value
     */
    func setConstraintMaxFriction(handle: PhysicsConstraintHandle, friction: Float64): Unit

    /**
     * @brief[zh-cn] 设置六自由度约束指定轴的电机状态
     * @param[zh-cn] handle 约束句柄
     * axis 轴索引（0=X 平移,1=Y,2=Z,3=X 旋转,4=Y,5=Z）
     * state 电机状态
     *
     * @brief[en] Sets the motor state of one axis of a SixDOF constraint
     * @param[en] handle The constraint handle
     * axis The axis index (0=X translation, 1=Y, 2=Z, 3=X rotation, 4=Y, 5=Z)
     * state The motor state
     */
    func setSixDOFMotorState(handle: PhysicsConstraintHandle, axis: Int64, state: PhysicsMotorState): Unit

    /**
     * @brief[zh-cn] 设置六自由度约束约束空间目标位置（平移电机）
     * @param[zh-cn] handle 约束句柄
     * target 约束空间目标位置
     *
     * @brief[en] Sets the SixDOF constraint-space target position (translation motors)
     * @param[en] handle The constraint handle
     * target The target position in constraint space
     */
    func setSixDOFTargetPosition(handle: PhysicsConstraintHandle, target: Vector3): Unit

    /**
     * @brief[zh-cn] 设置六自由度约束约束空间目标速度（平移电机）
     * @param[zh-cn] handle 约束句柄
     * target 约束空间目标速度
     *
     * @brief[en] Sets the SixDOF constraint-space target velocity (translation motors)
     * @param[en] handle The constraint handle
     * target The target velocity in constraint space
     */
    func setSixDOFTargetVelocity(handle: PhysicsConstraintHandle, target: Vector3): Unit

    // ===== 步进 =====

    /**
     * @brief[zh-cn] 步进物理世界一帧
     * @param[zh-cn] deltaTime 时间步长（秒），典型 1/60
     * collisionSteps 每步内的碰撞细分次数（1/60s 一步取 1）
     * @return[zh-cn] 更新错误标志（0 = 完整完成）
     *
     * @brief[en] Steps the physics world by one frame
     * @param[en] deltaTime The time step (seconds), typically 1/60
     * collisionSteps The number of collision substeps per step (1 for a 1/60s step)
     * @return[en] The update error flags (0 = completed fully)
     */
    func update(deltaTime: Float32, collisionSteps: Int32): UInt32

    // ===== 射线查询 =====

    /**
     * @brief[zh-cn] 世界射线检测（最近命中）
     * @param[zh-cn] origin 射线起点（世界坐标）
     * direction 射线方向（长度即最大检测距离）
     * hit 命中结果输出（命中时有效）
     * @return[zh-cn] 是否命中
     *
     * @brief[en] World ray cast (closest hit)
     * @param[en] origin The ray origin (world coordinates)
     * direction The ray direction (its length is the max cast distance)
     * hit The hit-result output (valid when a hit occurs)
     * @return[en] true if anything was hit
     */
    func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool

    // ===== 碰撞查询（完整能力） =====

    /**
     * @brief[zh-cn] 世界射线批量检测（收集所有命中，按距离升序）
     * @param[zh-cn] origin 射线起点（世界坐标）
     * direction 射线方向（长度即最大检测距离）
     * hits 命中结果输出（调用方传入空列表，后端按距离升序填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] World ray batch cast (collects all hits, sorted by distance ascending)
     * @param[en] origin The ray origin (world coordinates)
     * direction The ray direction (its length is the max cast distance)
     * hits The hit-result output (pass an empty list; the backend fills it sorted by distance)
     * @return[en] The number of hits
     */
    func raycastAll(origin: Vector3, direction: Vector3,
                    hits: ArrayList<PhysicsRayHit>): Int64

    /**
     * @brief[zh-cn] 世界点碰撞检测（检测点位于哪些形状内部/表面）
     * @param[zh-cn] point 世界坐标检测点
     * hits 命中结果输出（后端填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] World point collision test (which shapes contain or touch the point)
     * @param[en] point The test point in world coordinates
     * hits The hit-result output (filled by the backend)
     * @return[en] The number of hits
     */
    func collidePoint(point: Vector3, hits: ArrayList<PhysicsPointHit>): Int64

    /**
     * @brief[zh-cn] 形状 vs 世界碰撞检测（查询形状摆到 pose 后与场景求交）
     * @param[zh-cn] shape 查询形状描述
     * position 查询形状位置（世界坐标）
     * rotation 查询形状旋转
     * hits 命中结果输出（后端填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] Shape-vs-world collision test (intersects the scene with the query shape placed at the pose)
     * @param[en] shape The query shape description
     * position The query shape position (world coordinates)
     * rotation The query shape rotation
     * hits The hit-result output (filled by the backend)
     * @return[en] The number of hits
     */
    func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion,
                      hits: ArrayList<PhysicsShapeHit>): Int64

    /**
     * @brief[zh-cn] 形状投射（shape 沿 direction 扫掠，检测首个/全部阻挡）
     * @param[zh-cn] shape 投射形状描述
     * position 投射起点位置（世界坐标）
     * rotation 投射形状旋转
     * direction 投射方向（长度即最大扫掠距离）
     * hits 命中结果输出（按 fraction 升序）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] Shape cast (sweeps shape along direction, detecting the first/all blockers)
     * @param[en] shape The cast shape description
     * position The cast start position (world coordinates)
     * rotation The cast shape rotation
     * direction The cast direction (its length is the max sweep distance)
     * hits The hit-result output (sorted by fraction ascending)
     * @return[en] The number of hits
     */
    func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion,
                   direction: Vector3, hits: ArrayList<PhysicsShapeHit>): Int64

    // ===== 接触监听（ContactListener） =====

    /**
     * @brief[zh-cn] 注册碰撞事件监听器（接触回调 + 激活/休眠回调）
     * @param[zh-cn] listener 监听器；None 注销
     *
     * @brief[en] Registers a collision event listener (contact + activation/sleep callbacks)
     * @param[en] listener The listener, or None to unregister
     */
    func setContactListener(listener: Option<IPhysicsSensorListener>): Unit

    // ===== 后端标识 =====

    /**
     * @brief[zh-cn] 后端名称（如 "JoltPhysics"），用于日志/调试
     * @return[zh-cn] 后端名称字符串
     *
     * @brief[en] The backend name (e.g. "JoltPhysics"), for logging/debugging
     * @return[en] The backend name string
     */
    func backendName(): String
}
