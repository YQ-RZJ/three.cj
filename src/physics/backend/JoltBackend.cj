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
 * @file[zh-cn] JoltBackend IPhysicsBackend 的 JoltPhysics 实现（封装 jolt4cj.jolt）
 * @brief[zh-cn] 本文件实现可插拔物理后端接口的具体 Jolt 后端
 * @explain[zh-cn] 可插拔后端设计：本类是 IPhysicsBackend 的具体实现，three.physics.world 的
 * PhysicsWorld 仅依赖 IPhysicsBackend 接口，替换底层物理库只需新写一个实现本接口的
 * backend（如 PhysXBackend/BulletBackend），然后通过 PhysicsWorld 构造或 setBackend 切换。
 * 职责映射（jolt4cj.jolt._cj 包装）：
 * - initialize       → JPH_Init_cj + JobSystem + Layer filters + PhysicsSystem + SetGravity
 * - shutdown          → PhysicsSystem_Destroy + JobSystem_Destroy + JPH_Shutdown_cj
 * - createBody        → Box/Sphere/Capsule/Cylinder Shape + BodyCreationSettings + CreateAndAddBody
 * - destroyBody       → RemoveAndDestroyBody + Shape_Destroy（由 joltc 引用计数管理）
 * - setPosition/Rotation/Velocity/MotionType/Layer/Friction/Restitution → BodyInterface._cj
 * - update            → JPH_PhysicsSystem_Update_cj
 * - raycast           → JPH_NarrowPhaseQuery_CastRay_cj
 * 线程约定：本类所有方法在 PhysicsWorld 的专用物理线程内被调用（PhysicsWorld 通过
 * _execPhysics 序列化）。实现内部不再加锁；底层 joltc 句柄在物理线程外不可触碰。
 * 内存约定：joltc 系列函数要求调用方用 LibC.malloc 分配 JPHVec3/JPHQuat 等 \@C 结构体
 * 缓冲区传入，调用后 LibC.free。本实现内部统一管理这些临时缓冲区，对外暴露后端无关的
 * Vector3/Quaternion。
 *
 * @file[en] JoltBackend The JoltPhysics implementation of IPhysicsBackend (wraps jolt4cj.jolt)
 * @brief[en] This file implements a concrete Jolt backend for the pluggable physics backend interface
 * @explain[en] Pluggable backend design: this class is a concrete implementation of
 * IPhysicsBackend. PhysicsWorld only depends on the IPhysicsBackend interface; swapping the
 * underlying physics library only requires writing a new backend implementing this interface
 * (e.g. PhysXBackend/BulletBackend) and switching via the PhysicsWorld constructor or setBackend.
 * Responsibility mapping (jolt4cj.jolt._cj wrappers):
 * - initialize       → JPH_Init_cj + JobSystem + Layer filters + PhysicsSystem + SetGravity
 * - shutdown          → PhysicsSystem_Destroy + JobSystem_Destroy + JPH_Shutdown_cj
 * - createBody        → Box/Sphere/Capsule/Cylinder Shape + BodyCreationSettings + CreateAndAddBody
 * - destroyBody       → RemoveAndDestroyBody + Shape_Destroy (managed by joltc reference counting)
 * - setPosition/Rotation/Velocity/MotionType/Layer/Friction/Restitution → BodyInterface._cj
 * - update            → JPH_PhysicsSystem_Update_cj
 * - raycast           → JPH_NarrowPhaseQuery_CastRay_cj
 * Threading convention: all methods are called on PhysicsWorld's dedicated physics thread
 * (serialized via _execPhysics); no additional locking inside the implementation; underlying
 * joltc handles must not be touched off the physics thread.
 * Memory convention: the joltc functions require the caller to allocate \@C struct buffers
 * such as JPHVec3/JPHQuat with LibC.malloc and free them with LibC.free afterwards. This
 * implementation manages those temporary buffers internally and exposes backend-agnostic
 * Vector3/Quaternion values to the outside.
 */
package three.physics.backend

import three.core.math.*
import three.physics.interfaces.*
import jolt4cj.jolt.*
import std.collection.*
import three.utils.log.Logger

/**
 * @brief[zh-cn] IPhysicsBackend 的 JoltPhysics 后端实现
 * @explain[zh-cn] 单实例对应一个物理世界。底层句柄：
 * - _system     : JPH_PhysicsSystem 句柄
 * - _jobSystem  : 作业系统句柄
 * - _bodyIface  : BodyInterface 句柄（由 system 持有，无需释放）
 * - _narrowQuery: NarrowPhaseQuery 句柄（由 system 持有，无需释放）
 * - _pairFilter / _bpInterface / _ovsFilter : 层过滤对象（须在 system 销毁后销毁）
 *
 * @brief[en] JoltPhysics backend implementation of IPhysicsBackend
 * @explain[en] A single instance corresponds to one physics world. Underlying handles:
 * - _system     : JPH_PhysicsSystem handle
 * - _jobSystem  : job system handle
 * - _bodyIface  : BodyInterface handle (owned by the system, no need to release)
 * - _narrowQuery: NarrowPhaseQuery handle (owned by the system, no need to release)
 * - _pairFilter / _bpInterface / _ovsFilter : layer filter objects (must be destroyed after the system)
 */
public class JoltBackend <: IPhysicsBackend {
    /// 全局初始化标志（JPH_Init_cj 进程内只调用一次）
    private static var _globalInited: Bool = false

    /// 物理系统句柄
    private var _system: CPointer<Unit> = CPointer<Unit>()
    /// 作业系统句柄
    private var _jobSystem: CPointer<Unit> = CPointer<Unit>()
    /// 刚体接口句柄
    private var _bodyIface: CPointer<Unit> = CPointer<Unit>()
    /// 窄相查询句柄
    private var _narrowQuery: CPointer<Unit> = CPointer<Unit>()

    /// 层过滤对象句柄
    private var _pairFilter: CPointer<Unit> = CPointer<Unit>()
    private var _bpInterface: CPointer<Unit> = CPointer<Unit>()
    private var _ovsFilter: CPointer<Unit> = CPointer<Unit>()

    /// 碰撞组过滤表（约束对之间禁用碰撞用；Jolt 约束默认不禁碰撞，
    /// 摆杆/支柱等约束连接体若不隔离会互相卡住）
    private var _groupFilter: CPointer<Unit> = CPointer<Unit>()

    /// 刚体 -> 碰撞子组映射（bodyID -> subGroupID）。
    /// 注意：Jolt bodyID 高 8 位含序列号（如 0x00010001），不能直接当 subGroupID 用
    /// （GroupFilterTable 内部数组会越界卡死），必须用自增小整数子组号。
    private var _bodySubGroup: HashMap<UInt32, UInt32> = HashMap<UInt32, UInt32>()
    /// 下一个可用子组号（从 1 开始递增，0 保留给"无碰撞组"）
    private var _nextSubGroup: UInt32 = 1

    /// 是否已初始化
    private var _inited: Bool = false

    /// 形状句柄缓存（bodyID -> shape 句柄），destroyBody 时一并销毁
    /// 注意：joltc 语义下 Shape 由 BodyCreationSettings 持有引用，创建后 AddBody
    /// 会让 system 也持有引用；RemoveAndDestroyBody 释放 system 引用，
    /// 我们再显式 Shape_Destroy 释放本地引用。
    private var _shapes: HashMap<UInt32, CPointer<Unit>> = HashMap<UInt32, CPointer<Unit>>()

    /// 查询回调收集器（物理线程内同步查询期间有效；CFunc 不能捕获变量，
    /// 用静态字段中转收集器，查询开始设置、查询结束清除）
    private static var _activeSink: Option<JoltQuerySink> = None

    // JPH_CollisionCollectorType 枚举值（joltc.h：AllHit=0 / AllHitSorted=1 / ClosestHit=2 / AnyHit=3）
    private static let _COLLECTOR_ALL_HIT: UInt32 = 0
    private static let _COLLECTOR_ALL_HIT_SORTED: UInt32 = 1

    /// 碰撞事件监听器（setContactListener 暂存，任务 #6 注册到 Jolt ContactListener）
    private static var _contactListener: Option<IPhysicsSensorListener> = None

    /// Jolt ContactListener 实例句柄（initialize 创建，shutdown 销毁）
    private var _contactHandle: CPointer<Unit> = CPointer<Unit>()
    /// Jolt BodyActivationListener 实例句柄（initialize 创建，shutdown 销毁）
    private var _activationHandle: CPointer<Unit> = CPointer<Unit>()

    /// ContactListener Procs 表缓冲区（joltc 只保存指针不复制，须存活到 shutdown）
    private var _contactProcs: CPointer<JPHContactListenerProcs> = CPointer<JPHContactListenerProcs>()
    /// BodyActivationListener Procs 表缓冲区（同上）
    private var _activationProcs: CPointer<JPHBodyActivationListenerProcs> = CPointer<JPHBodyActivationListenerProcs>()

    /**
     * @brief[zh-cn] 创建 Jolt 后端实例（尚未初始化，需调用 initialize）
     *
     * @brief[en] Creates a Jolt backend instance (not yet initialized; call initialize)
     */
    public init() {}

    // =========================================================================
    // 坐标系转换（three 左手系 ↔ Jolt 右手系，Y-up，Z 轴镜像）
    //
    // three 渲染为左手系（Object3D 默认朝 +Z），Jolt 为右手系（Y-up）。
    // 两者 Y 轴一致，手性差异体现在 Z 轴镜像。所有跨边界传递的坐标
    // （位置/旋转/速度/力/约束锚点轴/射线）都必须转换，否则旋转方向
    // 与 Z 向运动视觉镜像。转换均自逆（两次应用还原），可双向使用。
    //
    // 变换规则（M = diag(1,1,-1)，det = -1）：
    //   普通向量（位置/力/线速度/轴/锚点）: v' = (x, y, -z)
    //   四元数（旋转矩阵共轭 M R M）:      q' = (-x, -y, z, w)
    //   伪向量（角速度/力矩/角冲量）:       w' = det(M)·M·w = (-x, -y, z)
    // =========================================================================

    /// 左手系 → 右手系（普通向量：位置/力/线速度/轴/锚点），Z 取反
    private static func _lhToRh(v: Vector3): Vector3 {
        return Vector3(v.x, v.y, -v.z)
    }

    /// 右手系 → 左手系（普通向量），与 _lhToRh 相同（镜像自逆）
    private static func _rhToLh(v: Vector3): Vector3 {
        return Vector3(v.x, v.y, -v.z)
    }

    /// 左手系 → 右手系（四元数），x、y 取反（旋转方向镜像）
    private static func _lhToRhQuat(q: Quaternion): Quaternion {
        return Quaternion(-q.x, -q.y, q.z, q.w)
    }

    /// 右手系 → 左手系（四元数），与 _lhToRhQuat 相同（自逆）
    private static func _rhToLhQuat(q: Quaternion): Quaternion {
        return Quaternion(-q.x, -q.y, q.z, q.w)
    }

    /// 左手系 → 右手系（伪向量：角速度/力矩/角冲量），x、y 取反 + Z 取反
    private static func _lhToRhAxial(w: Vector3): Vector3 {
        return Vector3(-w.x, -w.y, w.z)
    }

    /// 右手系 → 左手系（伪向量），与 _lhToRhAxial 相同（自逆）
    private static func _rhToLhAxial(w: Vector3): Vector3 {
        return Vector3(-w.x, -w.y, w.z)
    }

    // =========================================================================
    // 生命周期
    // =========================================================================

    /**
     * @brief[zh-cn] 初始化物理系统（创建 Jolt 物理系统、作业系统、碰撞过滤与监听器）
     * @param[zh-cn] maxBodies 系统支持的最大刚体数量
     * gravity 初始重力向量（three 左手系）
     * @return[zh-cn] 初始化成功返回 true
     *
     * @brief[en] Initializes the physics system (creates the Jolt physics system, job system, collision filtering and listeners)
     * @param[en] maxBodies Maximum number of bodies the system supports
     * gravity Initial gravity vector (three left-handed coordinates)
     * @return[en] Returns true on success
     */
    public func initialize(maxBodies: UInt32, gravity: Vector3): Bool {
        if (this._inited) {
            return true
        }

        // 1. 全局初始化（进程内只调用一次）
        if (!JoltBackend._globalInited) {
            if (JPH_Init_cj() == 0) {
                Logger.error(["JoltBackend", "JPH_Init_cj 失败"])
                return false
            }
            JoltBackend._globalInited = true
        }

        // 2. 创建作业系统（默认配置：2048 作业 / 全核-1 线程）
        let cfg = unsafe { LibC.malloc<JobSystemThreadPoolConfig>() }
        unsafe {
            var c = cfg.read()
            c.maxJobs = JPH_MAX_PHYSICS_JOBS
            c.maxBarriers = JPH_MAX_PHYSICS_BARRIERS
            c.numThreads = -1
            cfg.write(c)
        }
        this._jobSystem = JPH_JobSystemThreadPool_Create_cj(cfg)
        unsafe { LibC.free(cfg) }
        if (this._jobSystem.isNull()) {
            Logger.error(["JoltBackend", "创建作业系统失败"])
            return false
        }

        // 3. 层过滤（两层模型：NonMoving=0 / Moving=1）
        this._pairFilter = JPH_ObjectLayerPairFilterTable_Create_cj(2)
        // 静态与动态可碰撞
        JPH_ObjectLayerPairFilterTable_EnableCollision_cj(this._pairFilter, 0, 1)
        JPH_ObjectLayerPairFilterTable_EnableCollision_cj(this._pairFilter, 1, 0)
        // 动态与动态可碰撞
        JPH_ObjectLayerPairFilterTable_EnableCollision_cj(this._pairFilter, 1, 1)
        // 静态与静态无需碰撞（默认禁用）

        // 4. 对象层 -> BroadPhase 层映射（2 对象层 -> 2 BroadPhase 层）
        this._bpInterface = JPH_BroadPhaseLayerInterfaceTable_Create_cj(2, 2)
        JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer_cj(this._bpInterface, 0, 0)
        JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer_cj(this._bpInterface, 1, 1)

        // 4.1 碰撞组过滤表（约束对之间禁用碰撞；默认全部可碰撞，
        //     创建约束时对 bodyA/bodyB 的两个子组调用 DisableCollision）
        this._groupFilter = JPH_GroupFilterTable_Create_cj(4096)

        // 5. 对象层 vs BroadPhase 层过滤
        this._ovsFilter = JPH_ObjectVsBroadPhaseLayerFilterTable_Create_cj(this._bpInterface, 2, this._pairFilter, 2)

        // 6. 创建物理系统
        let settings = unsafe { LibC.malloc<JPHPhysicsSystemSettings>() }
        let maxPairs: UInt32 = if (maxBodies > 1024u32) {
            maxBodies
        } else {
            1024u32
        }
        unsafe {
            var s = settings.read()
            s.maxBodies = maxBodies
            s.numBodyMutexes = 0
            s.maxBodyPairs = maxPairs
            s.maxContactConstraints = maxPairs
            s.broadPhaseLayerInterface = this._bpInterface
            s.objectLayerPairFilter = this._pairFilter
            s.objectVsBroadPhaseLayerFilter = this._ovsFilter
            settings.write(s)
        }
        this._system = JPH_PhysicsSystem_Create_cj(settings)
        unsafe { LibC.free(settings) }
        if (this._system.isNull()) {
            Logger.error(["JoltBackend", "创建物理系统失败"])
            this._cleanupHandles()
            return false
        }

        // 7. 获取 BodyInterface 与 NarrowPhaseQuery
        this._bodyIface = JPH_PhysicsSystem_GetBodyInterface_cj(this._system)
        this._narrowQuery = JPH_PhysicsSystem_GetNarrowPhaseQuery_cj(this._system)

        // 7.1 创建并注册 ContactListener（接触事件 → IPhysicsSensorListener）
        //     注意：joltc 的 SetProcs 只保存指针不复制（s_Procs = procs），
        //     回调在物理模拟期间随时触发，Procs 缓冲区必须存活到 shutdown，
        //     不能像其他临时缓冲区一样用后即释放。
        let cprocs = unsafe { LibC.malloc<JPHContactListenerProcs>() }
        unsafe {
            var p = cprocs.read()
            p.onContactValidate = {
                ud: CPointer<Unit>, b1: CPointer<Unit>, b2: CPointer<Unit>, bo: CPointer<JPHVec3>, cr: CPointer<JPHCollideShapeResult> => JoltBackend
                    ._onContactValidate()
            }
            p.onContactAdded = {
                ud: CPointer<Unit>, b1: CPointer<Unit>, b2: CPointer<Unit>, mn: CPointer<Unit>, cs: CPointer<JPHContactSettings> => JoltBackend
                    ._onContactEvent(b1, b2, PhysicsContactEvent.Added)
            }
            p.onContactPersisted = {
                ud: CPointer<Unit>, b1: CPointer<Unit>, b2: CPointer<Unit>, mn: CPointer<Unit>, cs: CPointer<JPHContactSettings> => JoltBackend
                    ._onContactEvent(b1, b2, PhysicsContactEvent.Persisted)
            }
            p.onContactRemoved = {
                ud: CPointer<Unit>, pair: CPointer<JPHSubShapeIDPair> => JoltBackend._onContactRemoved(pair)
            }
            cprocs.write(p)
        }
        JPH_ContactListener_SetProcs_cj(cprocs)
        this._contactProcs = cprocs // 保存，shutdown 释放
        this._contactHandle = JPH_ContactListener_Create_cj(CPointer<Unit>())
        JPH_PhysicsSystem_SetContactListener_cj(this._system, this._contactHandle)

        // 7.2 创建并注册 BodyActivationListener（激活/休眠 → IPhysicsSensorListener）
        //     Procs 缓冲区同样须存活到 shutdown
        let aprocs = unsafe { LibC.malloc<JPHBodyActivationListenerProcs>() }
        unsafe {
            var p = aprocs.read()
            p.onBodyActivated = {
                ud: CPointer<Unit>, id: UInt32, bodyUserData: UInt64 => JoltBackend._onBodyActivated(id)
            }
            p.onBodyDeactivated = {
                ud: CPointer<Unit>, id: UInt32, bodyUserData: UInt64 => JoltBackend._onBodyDeactivated(id)
            }
            aprocs.write(p)
        }
        JPH_BodyActivationListener_SetProcs_cj(aprocs)
        this._activationProcs = aprocs // 保存，shutdown 释放
        this._activationHandle = JPH_BodyActivationListener_Create_cj(CPointer<Unit>())
        JPH_PhysicsSystem_SetBodyActivationListener_cj(this._system, this._activationHandle)

        // 8. 设置重力
        this.setGravity(gravity)

        this._inited = true
        return true
    }

    /**
     * @brief[zh-cn] 关闭物理系统并释放全部资源（形状句柄、物理系统、监听器）
     *
     * @brief[en] Shuts down the physics system and releases all resources (shape handles, physics system, listeners)
     */
    public func shutdown(): Unit {
        if (!this._inited) {
            return
        }
        // 销毁所有缓存的形状句柄
        for ((_, sh) in this._shapes) {
            JPH_Shape_Destroy_cj(sh)
        }
        this._shapes.clear()

        // 销毁物理系统（joltc 语义：PhysicsSystem_Destroy 会一并释放层过滤对象）
        if (!this._system.isNull()) {
            JPH_PhysicsSystem_Destroy_cj(this._system)
            this._system = CPointer<Unit>()
        }
        // 销毁监听器实例（须在 system 销毁之后，避免回调悬空）
        if (!this._contactHandle.isNull()) {
            JPH_ContactListener_Destroy_cj(this._contactHandle)
            this._contactHandle = CPointer<Unit>()
        }
        if (!this._activationHandle.isNull()) {
            JPH_BodyActivationListener_Destroy_cj(this._activationHandle)
            this._activationHandle = CPointer<Unit>()
        }
        // 释放 Procs 表缓冲区（joltc 只保存指针，实例销毁后不再访问，此时可安全释放）
        if (!this._contactProcs.isNull()) {
            unsafe { LibC.free(this._contactProcs) }
            this._contactProcs = CPointer<JPHContactListenerProcs>()
        }
        if (!this._activationProcs.isNull()) {
            unsafe { LibC.free(this._activationProcs) }
            this._activationProcs = CPointer<JPHBodyActivationListenerProcs>()
        }
        if (!this._jobSystem.isNull()) {
            JPH_JobSystem_Destroy_cj(this._jobSystem)
            this._jobSystem = CPointer<Unit>()
        }
        this._bodyIface = CPointer<Unit>()
        this._narrowQuery = CPointer<Unit>()
        this._pairFilter = CPointer<Unit>()
        this._bpInterface = CPointer<Unit>()
        this._ovsFilter = CPointer<Unit>()

        // 全局卸载（进程退出时调用，此处保守地不调用 JPH_Shutdown 以避免
        // 多 backend 实例时一个关闭影响另一个；真正卸载由进程退出保证）
        this._inited = false
    }

    /**
     * @brief[zh-cn] 查询物理系统是否已成功初始化
     * @return[zh-cn] 已初始化返回 true
     *
     * @brief[en] Returns whether the physics system has been initialized
     * @return[en] Returns true if initialized
     */
    public func isInitialized(): Bool {
        return this._inited
    }

    // =========================================================================
    // 世界设置
    // =========================================================================

    /**
     * @brief[zh-cn] 设置世界重力
     * @param[zh-cn] gravity 重力向量（three 左手系）
     *
     * @brief[en] Sets the world gravity
     * @param[en] gravity Gravity vector (three left-handed coordinates)
     */
    public func setGravity(gravity: Vector3): Unit {
        // 注意：initialize 内部先调用本方法再置 _inited，故此处只检查系统句柄，
        // 不能检查 _inited（否则初始化时的重力设置会被跳过，物体不受重力）。
        if (this._system.isNull()) {
            return
        }
        let g = unsafe { LibC.malloc<JPHVec3>() }
        unsafe { g.write(JPHVec3(x: Float32(gravity.x), y: Float32(gravity.y), z: Float32(gravity.z))) }
        JPH_PhysicsSystem_SetGravity_cj(this._system, g)
        unsafe { LibC.free(g) }
    }

    /**
     * @brief[zh-cn] 优化宽相位结构（动态物体位置变化后调用，提升查询性能）
     *
     * @brief[en] Optimizes the broad phase structure (call after dynamic bodies move to improve query performance)
     */
    public func optimizeBroadPhase(): Unit {
        if (!this._inited || this._system.isNull()) {
            return
        }
        JPH_PhysicsSystem_OptimizeBroadPhase_cj(this._system)
    }

    // =========================================================================
    // 形状 / 刚体
    // =========================================================================

    /// 根据 PhysicsShape 描述创建底层 Jolt 形状句柄
    private func _createShape(shape: PhysicsShape): CPointer<Unit> {
        match (shape.shapeType) {
            case PhysicsShapeType.Box =>
                let he = shape.halfExtent
                let v = unsafe { LibC.malloc<JPHVec3>() }
                unsafe {
                    v.write(JPHVec3(x: Float32(he.x), y: Float32(he.y), z: Float32(he.z)))
                }
                let sh = JPH_BoxShape_Create_cj(v, JPH_DEFAULT_CONVEX_RADIUS)
                unsafe { LibC.free(v) }
                return sh
            case PhysicsShapeType.Sphere => return JPH_SphereShape_Create_cj(Float32(shape.radius))
            case PhysicsShapeType.Capsule => return JPH_CapsuleShape_Create_cj(Float32(shape.halfHeight),
                Float32(shape.radius))
            case PhysicsShapeType.Cylinder => return JPH_CylinderShape_Create_cj(Float32(shape.halfHeight),
                Float32(shape.radius))
            case PhysicsShapeType.Plane =>
                // Jolt 无无限平面，用 200x200x1 的大盒子近似（Y 朝上）
                let v = unsafe { LibC.malloc<JPHVec3>() }
                unsafe {
                    v.write(JPHVec3(x: 100.0f32, y: 0.5f32, z: 100.0f32))
                }
                let sh = JPH_BoxShape_Create_cj(v, JPH_DEFAULT_CONVEX_RADIUS)
                unsafe { LibC.free(v) }
                return sh
            case PhysicsShapeType.Mesh =>
                // 三角网格形状：顶点 + 索引三角形（three 左手系顶点 → Jolt 右手系）
                if (shape.vertices.size < 3 || shape.triangles.size < 3) {
                    return CPointer<Unit>()
                }
                let vcount = UInt32(shape.vertices.size)
                let tcount = UInt32(shape.triangles.size / 3)
                let verts = unsafe { LibC.malloc<JPHVec3>(count: Int64(shape.vertices.size)) }
                for (i in 0..shape.vertices.size) {
                    let jv = JoltBackend._lhToRh(shape.vertices[i])
                    unsafe { (verts + i).write(JPHVec3(x: Float32(jv.x), y: Float32(jv.y), z: Float32(jv.z))) }
                }
                let tris = unsafe { LibC.malloc<JPHIndexedTriangle>(count: Int64(tcount)) }
                for (t in 0..tcount) {
                    let ti = Int64(t) * 3
                    var tri = JPHIndexedTriangle()
                    tri.i1 = shape.triangles[ti]
                    tri.i2 = shape.triangles[ti + 1]
                    tri.i3 = shape.triangles[ti + 2]
                    unsafe { (tris + Int64(t)).write(tri) }
                }
                let settings = JPH_MeshShapeSettings_Create2_cj(verts, vcount, tris, tcount)
                unsafe {
                    LibC.free(verts);
                    LibC.free(tris)
                }
                if (settings.isNull()) {
                    return CPointer<Unit>()
                }
                let meshShape = JPH_MeshShapeSettings_CreateShape_cj(settings)
                JPH_ShapeSettings_Destroy_cj(settings)
                return meshShape
            case PhysicsShapeType.ConvexHull =>
                // 凸包形状：顶点列表（three 左手系 → Jolt 右手系）
                if (shape.vertices.size < 4) {
                    return CPointer<Unit>()
                }
                let pcount = UInt32(shape.vertices.size)
                let pts = unsafe { LibC.malloc<JPHVec3>(count: Int64(shape.vertices.size)) }
                for (i in 0..shape.vertices.size) {
                    let jv = JoltBackend._lhToRh(shape.vertices[i])
                    unsafe { (pts + i).write(JPHVec3(x: Float32(jv.x), y: Float32(jv.y), z: Float32(jv.z))) }
                }
                let csettings = JPH_ConvexHullShapeSettings_Create_cj(pts, pcount, JPH_DEFAULT_CONVEX_RADIUS)
                unsafe { LibC.free(pts) }
                if (csettings.isNull()) {
                    return CPointer<Unit>()
                }
                let hullShape = JPH_ConvexHullShapeSettings_CreateShape_cj(csettings)
                JPH_ShapeSettings_Destroy_cj(csettings)
                return hullShape
            case PhysicsShapeType.Compound =>
                // 复合形状：多个子形状 + 相对变换（three 左手系 → Jolt 右手系）
                if (shape.parts.size == 0) {
                    return CPointer<Unit>()
                }
                let csettings = JPH_StaticCompoundShapeSettings_Create_cj()
                if (csettings.isNull()) {
                    return CPointer<Unit>()
                }
                for (p in shape.parts) {
                    let sub = this._createShape(p.shape)
                    if (sub.isNull()) {
                        continue
                    }
                    let jpos = JoltBackend._lhToRh(p.position)
                    let jrot = JoltBackend._lhToRhQuat(p.rotation)
                    let posBuf = unsafe { LibC.malloc<JPHVec3>() }
                    let rotBuf = unsafe { LibC.malloc<JPHQuat>() }
                    unsafe {
                        posBuf.write(JPHVec3(x: Float32(jpos.x), y: Float32(jpos.y), z: Float32(jpos.z)))
                        rotBuf.write(
                            JPHQuat(x: Float32(jrot.x), y: Float32(jrot.y), z: Float32(jrot.z), w: Float32(jrot.w)))
                    }
                    JPH_CompoundShapeSettings_AddShape2_cj(csettings, posBuf, rotBuf, sub, 0)
                    unsafe {
                        LibC.free(posBuf);
                        LibC.free(rotBuf)
                    }
                    JPH_Shape_Destroy_cj(sub)
                }
                let compoundShape = JPH_StaticCompoundShape_Create_cj(csettings)
                JPH_ShapeSettings_Destroy_cj(csettings)
                return compoundShape
        }
    }

    /**
     * @brief[zh-cn] 按描述创建刚体并加入世界
     * @param[zh-cn] desc 刚体描述（形状、质量、运动类型、层、初始位姿等）
     * @return[zh-cn] 刚体句柄；创建失败返回 PhysicsBodyHandle.INVALID
     *
     * @brief[en] Creates a body from the description and adds it to the world
     * @param[en] desc Body description (shape, mass, motion type, layer, initial pose, etc.)
     * @return[en] Body handle; PhysicsBodyHandle.INVALID on failure
     */
    public func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle {
        if (!this._inited || this._bodyIface.isNull()) {
            return PhysicsBodyHandle.INVALID
        }

        // 1. 创建形状
        let shape = this._createShape(desc.shape)
        if (shape.isNull()) {
            Logger.error(["JoltBackend", "创建形状失败"])
            return PhysicsBodyHandle.INVALID
        }

        // 2. 创建 BodyCreationSettings（three 左手系 → Jolt 右手系）
        let pos = unsafe { LibC.malloc<JPHVec3>() }
        let jpos = JoltBackend._lhToRh(desc.position)
        unsafe {
            pos.write(JPHVec3(x: Float32(jpos.x), y: Float32(jpos.y), z: Float32(jpos.z)))
        }
        let rot = unsafe { LibC.malloc<JPHQuat>() }
        let jrot = JoltBackend._lhToRhQuat(desc.rotation)
        unsafe {
            rot.write(JPHQuat(x: Float32(jrot.x), y: Float32(jrot.y), z: Float32(jrot.z), w: Float32(jrot.w)))
        }
        let motionType: UInt32 = match (desc.motionType) {
            case PhysicsMotionType.Static => 0
            case PhysicsMotionType.Kinematic => 1
            case PhysicsMotionType.Dynamic => 2
        }
        let layer: UInt32 = match (desc.layer) {
            case PhysicsLayer.NonMoving => 0
            case PhysicsLayer.Moving => 1
        }
        let bcs = JPH_BodyCreationSettings_Create3_cj(shape, pos, rot, motionType, layer)
        unsafe {
            LibC.free(pos);
            LibC.free(rot)
        }
        if (bcs.isNull()) {
            Logger.error(["JoltBackend", "创建 BodyCreationSettings 失败"])
            JPH_Shape_Destroy_cj(shape)
            return PhysicsBodyHandle.INVALID
        }

        // 2.1 传感器标志（只检测碰撞、不产生物理响应）
        if (desc.isSensor) {
            JPH_BodyCreationSettings_SetIsSensor_cj(bcs, 1u8)
        }

        // 3. 创建并添加刚体到世界
        let activation: UInt32 = match (desc.activation) {
            case PhysicsActivation.Activate => 0
            case PhysicsActivation.DontActivate => 1
        }
        let bodyID = JPH_BodyInterface_CreateAndAddBody_cj(this._bodyIface, bcs, activation)
        JPH_BodyCreationSettings_Destroy_cj(bcs)

        if (bodyID == 0 || bodyID == 0xFFFFFFFF) {
            Logger.error(["JoltBackend", "CreateAndAddBody 失败"])
            JPH_Shape_Destroy_cj(shape)
            return PhysicsBodyHandle.INVALID
        }

        // 4. 设置摩擦/弹性
        JPH_BodyInterface_SetFriction_cj(this._bodyIface, bodyID, Float32(desc.friction))
        JPH_BodyInterface_SetRestitution_cj(this._bodyIface, bodyID, Float32(desc.restitution))

        // 4.1 质量（>0 时覆盖：经 Body 的 MotionProperties 设置逆质量）
        if (desc.mass > 0.0) {
            let bodyPtr = JPH_PhysicsSystem_GetBodyPtr_cj(this._system, bodyID)
            if (!bodyPtr.isNull()) {
                let mp = JPH_Body_GetMotionProperties_cj(bodyPtr)
                if (!mp.isNull()) {
                    JPH_MotionProperties_SetInverseMass_cj(mp, Float32(1.0 / desc.mass))
                }
            }
        }

        // 4.2 重力因子
        JPH_BodyInterface_SetGravityFactor_cj(this._bodyIface, bodyID, Float32(desc.gravityFactor))

        // 4.3 线/角阻尼（通过 Body 的 MotionProperties）
        let bodyPtr2 = JPH_PhysicsSystem_GetBodyPtr_cj(this._system, bodyID)
        if (!bodyPtr2.isNull()) {
            let motionProps = JPH_Body_GetMotionProperties_cj(bodyPtr2)
            if (!motionProps.isNull()) {
                JPH_MotionProperties_SetLinearDamping_cj(motionProps, Float32(desc.linearDamping))
                JPH_MotionProperties_SetAngularDamping_cj(motionProps, Float32(desc.angularDamping))
            }
        }

        // 5. 缓存形状句柄（销毁刚体时一并销毁）
        this._shapes[bodyID] = shape

        // 6. 设置碰撞组（自增子组号；约束对之间通过 GroupFilterTable 禁用碰撞）
        if (!this._groupFilter.isNull()) {
            let sub = this._nextSubGroup
            this._nextSubGroup++
            this._bodySubGroup[bodyID] = sub
            let cg = unsafe { LibC.malloc<JPHCollisionGroup>() }
            unsafe {
                var g = cg.read()
                g.groupFilter = this._groupFilter
                g.groupID = 0u32
                g.subGroupID = sub
                cg.write(g)
                JPH_BodyInterface_SetCollisionGroup_cj(this._bodyIface, bodyID, cg)
            }
            unsafe { LibC.free(cg) }
        }

        return PhysicsBodyHandle(bodyID: bodyID)
    }

    /**
     * @brief[zh-cn] 从世界移除并销毁刚体，释放其形状句柄
     * @param[zh-cn] handle 刚体句柄
     *
     * @brief[en] Removes and destroys the body from the world, releasing its shape handle
     * @param[en] handle Body handle
     */
    public func destroyBody(handle: PhysicsBodyHandle): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        // 移除并销毁刚体
        JPH_BodyInterface_RemoveAndDestroyBody_cj(this._bodyIface, handle.bodyID)
        // 清理碰撞子组映射
        this._bodySubGroup.remove(handle.bodyID)
        // 销毁形状句柄
        match (this._shapes.get(handle.bodyID)) {
            case Some(sh) =>
                JPH_Shape_Destroy_cj(sh)
                this._shapes.remove(handle.bodyID)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 查询刚体是否处于活动（模拟中）状态
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 活动返回 true
     *
     * @brief[en] Returns whether the body is active (being simulated)
     * @param[en] handle Body handle
     * @return[en] Returns true if active
     */
    public func isBodyActive(handle: PhysicsBodyHandle): Bool {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return false
        }
        return JPH_BodyInterface_IsActive_cj(this._bodyIface, handle.bodyID) != 0
    }

    /**
     * @brief[zh-cn] 设置刚体是否为传感器（只检测碰撞、不产生物理响应）
     * @param[zh-cn] handle 刚体句柄
     * isSensor 是否作为传感器
     *
     * @brief[en] Sets whether the body acts as a sensor (detects collisions only, produces no physical response)
     * @param[en] handle Body handle
     * isSensor Whether to act as a sensor
     */
    public func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        JPH_BodyInterface_SetIsSensor_cj(this._bodyIface, handle.bodyID, if (isSensor) {
            1u8
        } else {
            0u8
        })
    }

    // =========================================================================
    // Transform 读写
    // =========================================================================

    /**
     * @brief[zh-cn] 设置刚体世界位置
     * @param[zh-cn] handle 刚体句柄
     * position 世界位置（three 左手系）
     * activation 是否同时激活刚体
     *
     * @brief[en] Sets the body world position
     * @param[en] handle Body handle
     * position World position (three left-handed coordinates)
     * activation Whether to activate the body at the same time
     */
    public func setPosition(handle: PhysicsBodyHandle, position: Vector3, activation: PhysicsActivation): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        let jp = JoltBackend._lhToRh(position)
        unsafe {
            v.write(JPHVec3(x: Float32(jp.x), y: Float32(jp.y), z: Float32(jp.z)))
        }
        let act: UInt32 = match (activation) {
            case PhysicsActivation.Activate => 0
            case PhysicsActivation.DontActivate => 1
        }
        JPH_BodyInterface_SetPosition_cj(this._bodyIface, handle.bodyID, v, act)
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 获取刚体世界位置
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 世界位置（three 左手系）
     *
     * @brief[en] Gets the body world position
     * @param[en] handle Body handle
     * @return[en] World position (three left-handed coordinates)
     */
    public func getPosition(handle: PhysicsBodyHandle): Vector3 {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return Vector3()
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        JPH_BodyInterface_GetPosition_cj(this._bodyIface, handle.bodyID, v)
        let r = unsafe { v.read() }
        unsafe { LibC.free(v) }
        return JoltBackend._rhToLh(Vector3(Float64(r.x), Float64(r.y), Float64(r.z)))
    }

    /**
     * @brief[zh-cn] 设置刚体旋转
     * @param[zh-cn] handle 刚体句柄
     * rotation 旋转四元数（three 左手系）
     * activation 是否同时激活刚体
     *
     * @brief[en] Sets the body rotation
     * @param[en] handle Body handle
     * rotation Rotation quaternion (three left-handed coordinates)
     * activation Whether to activate the body at the same time
     */
    public func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion, activation: PhysicsActivation): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let q = unsafe { LibC.malloc<JPHQuat>() }
        let jq = JoltBackend._lhToRhQuat(rotation)
        unsafe {
            q.write(JPHQuat(x: Float32(jq.x), y: Float32(jq.y), z: Float32(jq.z), w: Float32(jq.w)))
        }
        let act: UInt32 = match (activation) {
            case PhysicsActivation.Activate => 0
            case PhysicsActivation.DontActivate => 1
        }
        JPH_BodyInterface_SetRotation_cj(this._bodyIface, handle.bodyID, q, act)
        unsafe { LibC.free(q) }
    }

    /**
     * @brief[zh-cn] 获取刚体旋转
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 旋转四元数（three 左手系）
     *
     * @brief[en] Gets the body rotation
     * @param[en] handle Body handle
     * @return[en] Rotation quaternion (three left-handed coordinates)
     */
    public func getRotation(handle: PhysicsBodyHandle): Quaternion {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return Quaternion()
        }
        let q = unsafe { LibC.malloc<JPHQuat>() }
        JPH_BodyInterface_GetRotation_cj(this._bodyIface, handle.bodyID, q)
        let r = unsafe { q.read() }
        unsafe { LibC.free(q) }
        return JoltBackend._rhToLhQuat(Quaternion(Float64(r.x), Float64(r.y), Float64(r.z), Float64(r.w)))
    }

    // =========================================================================
    // 速度读写
    // =========================================================================

    /**
     * @brief[zh-cn] 设置刚体线速度
     * @param[zh-cn] handle 刚体句柄
     * velocity 线速度（three 左手系）
     *
     * @brief[en] Sets the body linear velocity
     * @param[en] handle Body handle
     * velocity Linear velocity (three left-handed coordinates)
     */
    public func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        let jv = JoltBackend._lhToRh(velocity)
        unsafe {
            v.write(JPHVec3(x: Float32(jv.x), y: Float32(jv.y), z: Float32(jv.z)))
        }
        JPH_BodyInterface_SetLinearVelocity_cj(this._bodyIface, handle.bodyID, v)
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 获取刚体线速度
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 线速度（three 左手系）
     *
     * @brief[en] Gets the body linear velocity
     * @param[en] handle Body handle
     * @return[en] Linear velocity (three left-handed coordinates)
     */
    public func getLinearVelocity(handle: PhysicsBodyHandle): Vector3 {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return Vector3()
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        JPH_BodyInterface_GetLinearVelocity_cj(this._bodyIface, handle.bodyID, v)
        let r = unsafe { v.read() }
        unsafe { LibC.free(v) }
        return JoltBackend._rhToLh(Vector3(Float64(r.x), Float64(r.y), Float64(r.z)))
    }

    /**
     * @brief[zh-cn] 设置刚体角速度（伪向量）
     * @param[zh-cn] handle 刚体句柄
     * angularVelocity 角速度（three 左手系）
     *
     * @brief[en] Sets the body angular velocity (pseudo-vector)
     * @param[en] handle Body handle
     * angularVelocity Angular velocity (three left-handed coordinates)
     */
    public func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        let jw = JoltBackend._lhToRhAxial(angularVelocity)
        unsafe {
            v.write(JPHVec3(x: Float32(jw.x), y: Float32(jw.y), z: Float32(jw.z)))
        }
        JPH_BodyInterface_SetAngularVelocity_cj(this._bodyIface, handle.bodyID, v)
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 获取刚体角速度（伪向量）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 角速度（three 左手系）
     *
     * @brief[en] Gets the body angular velocity (pseudo-vector)
     * @param[en] handle Body handle
     * @return[en] Angular velocity (three left-handed coordinates)
     */
    public func getAngularVelocity(handle: PhysicsBodyHandle): Vector3 {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return Vector3()
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        JPH_BodyInterface_GetAngularVelocity_cj(this._bodyIface, handle.bodyID, v)
        let r = unsafe { v.read() }
        unsafe { LibC.free(v) }
        return JoltBackend._rhToLhAxial(Vector3(Float64(r.x), Float64(r.y), Float64(r.z)))
    }

    // =========================================================================
    // 物理 material 读写
    // =========================================================================

    /**
     * @brief[zh-cn] 设置刚体摩擦系数
     * @param[zh-cn] handle 刚体句柄
     * friction 摩擦系数（0.0 为无摩擦）
     *
     * @brief[en] Sets the body friction coefficient
     * @param[en] handle Body handle
     * friction Friction coefficient (0.0 for no friction)
     */
    public func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        JPH_BodyInterface_SetFriction_cj(this._bodyIface, handle.bodyID, Float32(friction))
    }

    /**
     * @brief[zh-cn] 获取刚体摩擦系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 摩擦系数
     *
     * @brief[en] Gets the body friction coefficient
     * @param[en] handle Body handle
     * @return[en] Friction coefficient
     */
    public func getFriction(handle: PhysicsBodyHandle): Float64 {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return 0.0
        }
        return Float64(JPH_BodyInterface_GetFriction_cj(this._bodyIface, handle.bodyID))
    }

    /**
     * @brief[zh-cn] 设置刚体恢复系数（弹性）
     * @param[zh-cn] handle 刚体句柄
     * restitution 恢复系数（0.0 为完全无弹性，1.0 为完全弹性）
     *
     * @brief[en] Sets the body restitution coefficient (bounciness)
     * @param[en] handle Body handle
     * restitution Restitution coefficient (0.0 fully inelastic, 1.0 fully elastic)
     */
    public func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        JPH_BodyInterface_SetRestitution_cj(this._bodyIface, handle.bodyID, Float32(restitution))
    }

    /**
     * @brief[zh-cn] 获取刚体恢复系数（弹性）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 恢复系数
     *
     * @brief[en] Gets the body restitution coefficient (bounciness)
     * @param[en] handle Body handle
     * @return[en] Restitution coefficient
     */
    public func getRestitution(handle: PhysicsBodyHandle): Float64 {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return 0.0
        }
        return Float64(JPH_BodyInterface_GetRestitution_cj(this._bodyIface, handle.bodyID))
    }

    // =========================================================================
    // 运动属性
    // =========================================================================

    /**
     * @brief[zh-cn] 设置刚体运动类型（静态/运动学/动态）
     * @param[zh-cn] handle 刚体句柄
     * motionType 运动类型
     * activation 是否同时激活刚体
     *
     * @brief[en] Sets the body motion type (static/kinematic/dynamic)
     * @param[en] handle Body handle
     * motionType Motion type
     * activation Whether to activate the body at the same time
     */
    public func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType, activation: PhysicsActivation): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let mt: UInt32 = match (motionType) {
            case PhysicsMotionType.Static => 0
            case PhysicsMotionType.Kinematic => 1
            case PhysicsMotionType.Dynamic => 2
        }
        let act: UInt32 = match (activation) {
            case PhysicsActivation.Activate => 0
            case PhysicsActivation.DontActivate => 1
        }
        JPH_BodyInterface_SetMotionType_cj(this._bodyIface, handle.bodyID, mt, act)
    }

    /**
     * @brief[zh-cn] 获取刚体运动类型（静态/运动学/动态）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 运动类型
     *
     * @brief[en] Gets the body motion type (static/kinematic/dynamic)
     * @param[en] handle Body handle
     * @return[en] Motion type
     */
    public func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return PhysicsMotionType.Static
        }
        let mt = JPH_BodyInterface_GetMotionType_cj(this._bodyIface, handle.bodyID)
        match (mt) {
            case 0 => PhysicsMotionType.Static
            case 1 => PhysicsMotionType.Kinematic
            case 2 => PhysicsMotionType.Dynamic
            case _ => PhysicsMotionType.Static
        }
    }

    /**
     * @brief[zh-cn] 设置刚体所在对象层（决定碰撞过滤）
     * @param[zh-cn] handle 刚体句柄
     * layer 对象层（NonMoving/Moving）
     *
     * @brief[en] Sets the object layer of the body (determines collision filtering)
     * @param[en] handle Body handle
     * layer Object layer (NonMoving/Moving)
     */
    public func setObjectLayer(handle: PhysicsBodyHandle, layer: PhysicsLayer): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let l: UInt32 = match (layer) {
            case PhysicsLayer.NonMoving => 0
            case PhysicsLayer.Moving => 1
        }
        JPH_BodyInterface_SetObjectLayer_cj(this._bodyIface, handle.bodyID, l)
    }

    /**
     * @brief[zh-cn] 获取刚体所在对象层（决定碰撞过滤）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 对象层（NonMoving/Moving）
     *
     * @brief[en] Gets the object layer of the body (determines collision filtering)
     * @param[en] handle Body handle
     * @return[en] Object layer (NonMoving/Moving)
     */
    public func getObjectLayer(handle: PhysicsBodyHandle): PhysicsLayer {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return PhysicsLayer.NonMoving
        }
        let l = JPH_BodyInterface_GetObjectLayer_cj(this._bodyIface, handle.bodyID)
        match (l) {
            case 0 => PhysicsLayer.NonMoving
            case 1 => PhysicsLayer.Moving
            case _ => PhysicsLayer.NonMoving
        }
    }

    // =========================================================================
    // 步进
    // =========================================================================

    /**
     * @brief[zh-cn] 步进物理世界一个时间片
     * @param[zh-cn] deltaTime 步进时间步长（秒）
     * collisionSteps 每个时间步内的碰撞求解迭代次数
     * @return[zh-cn] 本步产生的冲突数
     *
     * @brief[en] Steps the physics world by one time slice
     * @param[en] deltaTime Step time delta (seconds)
     * collisionSteps Number of collision solver iterations per step
     * @return[en] Number of collisions produced in this step
     */
    public func update(deltaTime: Float32, collisionSteps: Int32): UInt32 {
        if (!this._inited || this._system.isNull() || this._jobSystem.isNull()) {
            return 0
        }
        return JPH_PhysicsSystem_Update_cj(this._system, deltaTime, collisionSteps, this._jobSystem)
    }

    // =========================================================================
    // 射线查询
    // =========================================================================

    /**
     * @brief[zh-cn] 发射单条射线，返回最近命中
     * @param[zh-cn] origin 射线起点（three 左手系）
     * direction 射线方向（three 左手系，无需归一化）
     * hit 命中结果容器（命中时填充 bodyID/fraction/point/normal）
     * @return[zh-cn] 是否命中
     *
     * @brief[en] Casts a single ray and returns the closest hit
     * @param[en] origin Ray origin (three left-handed coordinates)
     * direction Ray direction (three left-handed coordinates, need not be normalized)
     * hit Hit result container (filled with bodyID/fraction/point/normal on hit)
     * @return[en] Whether the ray hit anything
     */
    public func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool {
        if (!this._inited || this._narrowQuery.isNull()) {
            return false
        }
        let o = unsafe { LibC.malloc<JPHVec3>() }
        let d = unsafe { LibC.malloc<JPHVec3>() }
        let h = unsafe { LibC.malloc<JPHRayCastResult>() }
        let jo = JoltBackend._lhToRh(origin)
        let jd = JoltBackend._lhToRh(direction)
        unsafe {
            o.write(JPHVec3(x: Float32(jo.x), y: Float32(jo.y), z: Float32(jo.z)))
            d.write(JPHVec3(x: Float32(jd.x), y: Float32(jd.y), z: Float32(jd.z)))
        }
        let ok = JPH_NarrowPhaseQuery_CastRay_cj(this._narrowQuery, o, d, h, CPointer<Unit>(), CPointer<Unit>(),
            CPointer<Unit>())
        if (ok != 0) {
            let r = unsafe { h.read() }
            hit.bodyID = r.bodyID
            hit.fraction = r.fraction
            // 命中点 = origin + direction * fraction（在 Jolt 右手系计算后转回左手系）
            let f = Float64(r.fraction)
            let hitJ = Vector3(jo.x + jd.x * f, jo.y + jd.y * f, jo.z + jd.z * f)
            hit.point = JoltBackend._rhToLh(hitJ)
            // 命中法线：GetBodyPtr → GetWorldSpaceSurfaceNormal（右手系 → 左手系）
            hit.normal = JoltBackend._querySurfaceNormal(this._system, r.bodyID, r.subShapeID2, hitJ)
        }
        unsafe {
            LibC.free(o);
            LibC.free(d);
            LibC.free(h)
        }
        return ok != 0
    }

    // =========================================================================
    // 碰撞查询（完整能力：批量射线 / 点碰撞 / 形状碰撞 / 形状投射）
    // =========================================================================

    /**
     * @brief[zh-cn] 发射批量射线，返回全部按距离排序的命中
     * @param[zh-cn] origin 射线起点（three 左手系）
     * direction 射线方向（three 左手系）
     * hits 接收命中结果的列表（会被清空后填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] Casts a batch ray and returns all hits sorted by distance
     * @param[en] origin Ray origin (three left-handed coordinates)
     * direction Ray direction (three left-handed coordinates)
     * hits List receiving the hit results (cleared then filled)
     * @return[en] Number of hits
     */
    public func raycastAll(origin: Vector3, direction: Vector3, hits: ArrayList<PhysicsRayHit>): Int64 {
        if (!this._inited || this._narrowQuery.isNull()) {
            return 0
        }
        hits.clear()
        let o = unsafe { LibC.malloc<JPHVec3>() }
        let d = unsafe { LibC.malloc<JPHVec3>() }
        let st = unsafe { LibC.malloc<JPHRayCastSettings>() }
        let jo = JoltBackend._lhToRh(origin)
        let jd = JoltBackend._lhToRh(direction)
        unsafe {
            o.write(JPHVec3(x: Float32(jo.x), y: Float32(jo.y), z: Float32(jo.z)))
            d.write(JPHVec3(x: Float32(jd.x), y: Float32(jd.y), z: Float32(jd.z)))
            st.write(JPHRayCastSettings())
        }
        // 设置活动收集器（回调无捕获，经静态字段中转）
        let sink = JoltQuerySink()
        sink.system = this._system
        sink.rayOrigin = jo
        sink.rayDirection = jd
        sink.rayHits = Some(hits)
        JoltBackend._activeSink = Some(sink)
        let cb: CFunc<(CPointer<Unit>, CPointer<JPHRayCastResult>) -> Unit> = {
            ctx, r => JoltBackend._onRayResult(ctx, r)
        }
        JPH_NarrowPhaseQuery_CastRay3_cj(this._narrowQuery, o, d, st, JoltBackend._COLLECTOR_ALL_HIT_SORTED, cb,
            CPointer<Unit>(), CPointer<Unit>(), CPointer<Unit>(), CPointer<Unit>(), CPointer<Unit>())
        JoltBackend._activeSink = None
        unsafe {
            LibC.free(o);
            LibC.free(d);
            LibC.free(st)
        }
        return hits.size
    }

    /**
     * @brief[zh-cn] 查询给定点所处位置的所有重叠形状（点碰撞）
     * @param[zh-cn] point 查询点（three 左手系）
     * hits 接收命中结果的列表（会被清空后填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] Finds all shapes overlapping a given point (point collision)
     * @param[en] point Query point (three left-handed coordinates)
     * hits List receiving the hit results (cleared then filled)
     * @return[en] Number of hits
     */
    public func collidePoint(point: Vector3, hits: ArrayList<PhysicsPointHit>): Int64 {
        if (!this._inited || this._narrowQuery.isNull()) {
            return 0
        }
        hits.clear()
        let p = unsafe { LibC.malloc<JPHVec3>() }
        let jp = JoltBackend._lhToRh(point)
        unsafe {
            p.write(JPHVec3(x: Float32(jp.x), y: Float32(jp.y), z: Float32(jp.z)))
        }
        let sink = JoltQuerySink()
        sink.pointHits = Some(hits)
        JoltBackend._activeSink = Some(sink)
        let cb: CFunc<(CPointer<Unit>, CPointer<JPHCollidePointResult>) -> Unit> = {
            ctx, r => JoltBackend._onCollidePointResult(ctx, r)
        }
        JPH_NarrowPhaseQuery_CollidePoint2_cj(this._narrowQuery, p, JoltBackend._COLLECTOR_ALL_HIT, cb, CPointer<Unit>(),
            CPointer<Unit>(), CPointer<Unit>(), CPointer<Unit>(), CPointer<Unit>())
        JoltBackend._activeSink = None
        unsafe { LibC.free(p) }
        return hits.size
    }

    /**
     * @brief[zh-cn] 查询给定位姿的形状与世界中的哪些形状重叠（形状碰撞）
     * @param[zh-cn] shape 查询形状描述
     * position 形状位置（three 左手系）
     * rotation 形状旋转（three 左手系）
     * hits 接收命中结果的列表（会被清空后填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] Finds shapes in the world overlapping a shape at the given pose (shape collision)
     * @param[en] shape Query shape description
     * position Shape position (three left-handed coordinates)
     * rotation Shape rotation (three left-handed coordinates)
     * hits List receiving the hit results (cleared then filled)
     * @return[en] Number of hits
     */
    public func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion,
        hits: ArrayList<PhysicsShapeHit>): Int64 {
        if (!this._inited || this._narrowQuery.isNull()) {
            return 0
        }
        hits.clear()
        // 1. 创建查询形状（临时，查询后销毁）
        let shp = this._createShape(shape)
        if (shp.isNull()) {
            return 0
        }
        // 2. scale = 单位缩放
        let scale = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            scale.write(JPHVec3(x: 1.0f32, y: 1.0f32, z: 1.0f32))
        }
        // 3. 质心变换（位置 + 旋转 → JPHMat4，右手系）
        let com = unsafe { LibC.malloc<JPHMat4>() }
        let rotBuf = unsafe { LibC.malloc<JPHQuat>() }
        let posBuf = unsafe { LibC.malloc<JPHVec3>() }
        let jpos = JoltBackend._lhToRh(position)
        let jrot = JoltBackend._lhToRhQuat(rotation)
        unsafe {
            rotBuf.write(JPHQuat(x: Float32(jrot.x), y: Float32(jrot.y), z: Float32(jrot.z), w: Float32(jrot.w)))
            posBuf.write(JPHVec3(x: Float32(jpos.x), y: Float32(jpos.y), z: Float32(jpos.z)))
            JPH_Mat4_RotationTranslation_cj(com, rotBuf, posBuf)
        }
        // 4. 设置（默认）
        let settings = unsafe { LibC.malloc<JPHCollideShapeSettings>() }
        unsafe { JPH_CollideShapeSettings_Init_cj(settings) }
        // 5. baseOffset（零偏移）
        let base = unsafe { LibC.malloc<JPHVec3>() }
        unsafe { base.write(JPHVec3(x: 0.0f32, y: 0.0f32, z: 0.0f32)) }
        // 6. 查询
        let sink = JoltQuerySink()
        sink.shapeHits = Some(hits)
        JoltBackend._activeSink = Some(sink)
        let cb: CFunc<(CPointer<Unit>, CPointer<JPHCollideShapeResult>) -> Unit> = {
            ctx, r => JoltBackend._onCollideShapeResult(ctx, r)
        }
        JPH_NarrowPhaseQuery_CollideShape2_cj(this._narrowQuery, shp, scale, com, settings, base,
            JoltBackend._COLLECTOR_ALL_HIT, cb, CPointer<Unit>(), CPointer<Unit>(), CPointer<Unit>(), CPointer<Unit>(),
            CPointer<Unit>())
        JoltBackend._activeSink = None
        unsafe {
            LibC.free(scale);
            LibC.free(com);
            LibC.free(rotBuf);
            LibC.free(posBuf)
            LibC.free(settings);
            LibC.free(base)
        }
        JPH_Shape_Destroy_cj(shp)
        return hits.size
    }

    /**
     * @brief[zh-cn] 沿给定方向投射形状，返回沿途命中的所有形状（形状扫掠）
     * @param[zh-cn] shape 投射形状描述
     * position 投射起点位置（three 左手系）
     * rotation 投射形状旋转（three 左手系）
     * direction 投射方向（three 左手系，无需归一化）
     * hits 接收命中结果的列表（会被清空后填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] Sweeps a shape along a direction and returns all shapes hit along the way (shape cast)
     * @param[en] shape Shape description to cast
     * position Start position (three left-handed coordinates)
     * rotation Shape rotation (three left-handed coordinates)
     * direction Cast direction (three left-handed coordinates, need not be normalized)
     * hits List receiving the hit results (cleared then filled)
     * @return[en] Number of hits
     */
    public func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, direction: Vector3,
        hits: ArrayList<PhysicsShapeHit>): Int64 {
        if (!this._inited || this._narrowQuery.isNull()) {
            return 0
        }
        hits.clear()
        // 1. 创建投射形状（临时）
        let shp = this._createShape(shape)
        if (shp.isNull()) {
            return 0
        }
        // 2. 世界变换（位置 + 旋转 → JPHMat4，右手系）
        let wt = unsafe { LibC.malloc<JPHMat4>() }
        let rotBuf = unsafe { LibC.malloc<JPHQuat>() }
        let posBuf = unsafe { LibC.malloc<JPHVec3>() }
        let jpos = JoltBackend._lhToRh(position)
        let jrot = JoltBackend._lhToRhQuat(rotation)
        unsafe {
            rotBuf.write(JPHQuat(x: Float32(jrot.x), y: Float32(jrot.y), z: Float32(jrot.z), w: Float32(jrot.w)))
            posBuf.write(JPHVec3(x: Float32(jpos.x), y: Float32(jpos.y), z: Float32(jpos.z)))
            JPH_Mat4_RotationTranslation_cj(wt, rotBuf, posBuf)
        }
        // 3. 投射方向（右手系）
        let dirBuf = unsafe { LibC.malloc<JPHVec3>() }
        let jdir = JoltBackend._lhToRh(direction)
        unsafe {
            dirBuf.write(JPHVec3(x: Float32(jdir.x), y: Float32(jdir.y), z: Float32(jdir.z)))
        }
        // 4. 设置（默认）
        let settings = unsafe { LibC.malloc<JPHShapeCastSettings>() }
        unsafe { JPH_ShapeCastSettings_Init_cj(settings) }
        // 5. baseOffset（零偏移）
        let base = unsafe { LibC.malloc<JPHVec3>() }
        unsafe { base.write(JPHVec3(x: 0.0f32, y: 0.0f32, z: 0.0f32)) }
        // 6. 查询
        let sink = JoltQuerySink()
        sink.shapeHits = Some(hits)
        JoltBackend._activeSink = Some(sink)
        let cb: CFunc<(CPointer<Unit>, CPointer<JPHShapeCastResult>) -> Unit> = {
            ctx, r => JoltBackend._onCastShapeResult(ctx, r)
        }
        JPH_NarrowPhaseQuery_CastShape2_cj(this._narrowQuery, shp, wt, dirBuf, settings, base,
            JoltBackend._COLLECTOR_ALL_HIT_SORTED, cb, CPointer<Unit>(), CPointer<Unit>(), CPointer<Unit>(),
            CPointer<Unit>(), CPointer<Unit>())
        JoltBackend._activeSink = None
        unsafe {
            LibC.free(wt);
            LibC.free(rotBuf);
            LibC.free(posBuf)
            LibC.free(dirBuf);
            LibC.free(settings);
            LibC.free(base)
        }
        JPH_Shape_Destroy_cj(shp)
        return hits.size
    }

    /**
     * @brief[zh-cn] 返回后端名称
     * @return[zh-cn] 后端名称字符串
     *
     * @brief[en] Returns the backend name
     * @return[en] Backend name string
     */
    public func backendName(): String {
        return "JoltPhysics"
    }

    // =========================================================================
    // 原生句柄访问（模块内部设施：供同模块 Ragdoll/Vehicle/SoftBody 等高级封装使用）
    // protected = 模块内可见、模块外仅子类可见；签名中的 CPointer 不构成公共 API。
    // 注意：以下方法返回的句柄只允许在物理线程内（world.execPhysics 闭包中）访问。
    // =========================================================================

    /**
     * @brief[zh-cn] 获取底层 JPH_PhysicsSystem 原生句柄（模块内部）
     *
     * @brief[en] Gets the underlying native JPH_PhysicsSystem handle (module-internal)
     */
    protected func nativeSystemHandle(): CPointer<Unit> {
        return this._system
    }

    /**
     * @brief[zh-cn] 获取底层 JPH_BodyInterface 原生句柄（模块内部）
     *
     * @brief[en] Gets the underlying native JPH_BodyInterface handle (module-internal)
     */
    protected func nativeBodyInterface(): CPointer<Unit> {
        return this._bodyIface
    }

    /**
     * @brief[zh-cn] 由后端无关形状描述创建一个独立的原生 JPH_Shape 句柄（模块内部）
     * @explain[zh-cn] 返回的形状由调用方负责用 destroyNativeShape 释放（引用计数）。
     *
     * @brief[en] Creates an independent native JPH_Shape handle from a shape description (module-internal)
     * @explain[en] The returned shape must be released by the caller via destroyNativeShape
     * (reference counted).
     */
    protected func createNativeShape(shape: PhysicsShape): CPointer<Unit> {
        return this._createShape(shape)
    }

    /**
     * @brief[zh-cn] 销毁 createNativeShape 创建的原生形状句柄（模块内部）
     *
     * @brief[en] Destroys a native shape handle created by createNativeShape (module-internal)
     */
    protected func destroyNativeShape(shape: CPointer<Unit>): Unit {
        if (!shape.isNull()) {
            JPH_Shape_Destroy_cj(shape)
        }
    }

    /**
     * @brief[zh-cn] 注册碰撞事件监听器（接触/激活/休眠回调）
     * @param[zh-cn] listener 传感器监听器；传 None 取消注册
     *
     * @brief[en] Registers a collision event listener (contact/activation/deactivation callbacks)
     * @param[en] listener Sensor listener; pass None to unregister
     */
    public func setContactListener(listener: Option<IPhysicsSensorListener>): Unit {
        // 暂存监听器引用，任务 #6 实现 SetProcs 注册后真正生效
        JoltBackend._contactListener = listener
    }

    // =========================================================================
    // 力 / 力矩 / 冲量
    // =========================================================================

    /**
     * @brief[zh-cn] 对刚体施加作用力（线性）
     * @param[zh-cn] handle 刚体句柄
     * force 作用力（three 左手系）
     *
     * @brief[en] Applies a force to the body (linear)
     * @param[en] handle Body handle
     * force Applied force (three left-handed coordinates)
     */
    public func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        let jf = JoltBackend._lhToRh(force)
        unsafe {
            v.write(JPHVec3(x: Float32(jf.x), y: Float32(jf.y), z: Float32(jf.z)))
        }
        JPH_BodyInterface_AddForce_cj(this._bodyIface, handle.bodyID, v)
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 在刚体指定作用点上施加作用力
     * @param[zh-cn] handle 刚体句柄
     * force 作用力（three 左手系）
     * point 作用点（刚体局部空间，three 左手系）
     *
     * @brief[en] Applies a force to the body at the specified point
     * @param[en] handle Body handle
     * force Applied force (three left-handed coordinates)
     * point Application point (body local space, three left-handed coordinates)
     */
    public func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let f = unsafe { LibC.malloc<JPHVec3>() }
        let p = unsafe { LibC.malloc<JPHVec3>() }
        let jf = JoltBackend._lhToRh(force)
        let jp = JoltBackend._lhToRh(point)
        unsafe {
            f.write(JPHVec3(x: Float32(jf.x), y: Float32(jf.y), z: Float32(jf.z)))
            p.write(JPHVec3(x: Float32(jp.x), y: Float32(jp.y), z: Float32(jp.z)))
        }
        JPH_BodyInterface_AddForce2_cj(this._bodyIface, handle.bodyID, f, p)
        unsafe {
            LibC.free(f);
            LibC.free(p)
        }
    }

    /**
     * @brief[zh-cn] 对刚体施加力矩（伪向量）
     * @param[zh-cn] handle 刚体句柄
     * torque 力矩（three 左手系）
     *
     * @brief[en] Applies a torque to the body (pseudo-vector)
     * @param[en] handle Body handle
     * torque Applied torque (three left-handed coordinates)
     */
    public func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        let jt = JoltBackend._lhToRhAxial(torque)
        unsafe {
            v.write(JPHVec3(x: Float32(jt.x), y: Float32(jt.y), z: Float32(jt.z)))
        }
        JPH_BodyInterface_AddTorque_cj(this._bodyIface, handle.bodyID, v)
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 对刚体施加线性冲量（瞬间改变线速度）
     * @param[zh-cn] handle 刚体句柄
     * impulse 冲量（three 左手系）
     *
     * @brief[en] Applies a linear impulse to the body (instant change of linear velocity)
     * @param[en] handle Body handle
     * impulse Applied impulse (three left-handed coordinates)
     */
    public func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        let ji = JoltBackend._lhToRh(impulse)
        unsafe {
            v.write(JPHVec3(x: Float32(ji.x), y: Float32(ji.y), z: Float32(ji.z)))
        }
        JPH_BodyInterface_AddImpulse_cj(this._bodyIface, handle.bodyID, v)
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 向刚体施加角冲量
     * @param[zh-cn] handle 刚体句柄
     * angularImpulse 角冲量（伪向量，three 左手系）
     *
     * @brief[en] Applies an angular impulse to the body
     * @param[en] handle Body handle
     * angularImpulse Angular impulse (pseudo-vector, three left-handed coordinates)
     */
    public func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        let ja = JoltBackend._lhToRhAxial(angularImpulse)
        unsafe {
            v.write(JPHVec3(x: Float32(ja.x), y: Float32(ja.y), z: Float32(ja.z)))
        }
        JPH_BodyInterface_AddAngularImpulse_cj(this._bodyIface, handle.bodyID, v)
        unsafe { LibC.free(v) }
    }

    // =========================================================================
    // 质量 / 惯量
    // =========================================================================

    /**
     * @brief[zh-cn] 获取刚体质量
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 质量（kg）；无效句柄或未设置时返回 0.0
     *
     * @brief[en] Gets the body mass
     * @param[en] handle Body handle
     * @return[en] Mass in kg; 0.0 for invalid handles or when unset
     */
    public func getMass(handle: PhysicsBodyHandle): Float64 {
        if (!this._inited || this._system.isNull() || !handle.isValid()) {
            return 0.0
        }
        let bodyPtr = JPH_PhysicsSystem_GetBodyPtr_cj(this._system, handle.bodyID)
        if (bodyPtr.isNull()) {
            return 0.0
        }
        let mp = JPH_Body_GetMotionProperties_cj(bodyPtr)
        if (mp.isNull()) {
            return 0.0
        }
        let invMass = JPH_MotionProperties_GetInverseMassUnchecked_cj(mp)
        if (invMass <= 0.000001f32) {
            return 0.0
        }
        return Float64(1.0f32 / invMass)
    }

    /**
     * @brief[zh-cn] 设置刚体质量（动态刚体）
     * @param[zh-cn] handle 刚体句柄
     * mass 质量（千克，必须大于 0）
     *
     * @brief[en] Sets the body mass (dynamic bodies)
     * @param[en] handle Body handle
     * mass Mass in kilograms (must be greater than 0)
     */
    public func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit {
        if (!this._inited || this._system.isNull() || !handle.isValid()) {
            return
        }
        if (mass <= 0.0) {
            return
        }
        let bodyPtr = JPH_PhysicsSystem_GetBodyPtr_cj(this._system, handle.bodyID)
        if (bodyPtr.isNull()) {
            return
        }
        let mp = JPH_Body_GetMotionProperties_cj(bodyPtr)
        if (mp.isNull()) {
            return
        }
        JPH_MotionProperties_SetInverseMass_cj(mp, Float32(1.0 / mass))
    }

    /**
     * @brief[zh-cn] 获取刚体逆惯量张量
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 逆惯量张量（Matrix4 左上 3x3，three 左手系）
     *
     * @brief[en] Gets the body inverse inertia tensor
     * @param[en] handle Body handle
     * @return[en] Inverse inertia tensor (Matrix4 top-left 3x3, three left-handed coordinates)
     */
    public func getInverseInertia(handle: PhysicsBodyHandle): Matrix4 {
        let result = Matrix4()
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return result
        }
        let m = unsafe { LibC.malloc<JPHMat4>() }
        JPH_BodyInterface_GetInverseInertia_cj(this._bodyIface, handle.bodyID, m)
        let r = unsafe { m.read() }
        unsafe { LibC.free(m) }
        // JPHMat4 按列存储，填入 Matrix4（左上 3x3）
        for (col in 0..4) {
            let c = r.column[col]
            let cols = [c.x, c.y, c.z, c.w]
            for (row in 0..4) {
                result.elements[row * 4 + col] = Float64(cols[row])
            }
        }
        // 惯量张量是 2 阶张量，镜像 M = diag(1,1,-1) 下 I' = M·I·M：
        // 第 3 行/列交叉项（(1,3)(3,1)(2,3)(3,2)）变号，其余不变。
        // （Jolt 右手系 → three 左手系）
        let e = result.elements
        let m13 = e[0 * 4 + 2]
        let m23 = e[1 * 4 + 2]
        let m31 = e[2 * 4 + 0]
        let m32 = e[2 * 4 + 1]
        e[0 * 4 + 2] = -m13
        e[1 * 4 + 2] = -m23
        e[2 * 4 + 0] = -m31
        e[2 * 4 + 1] = -m32
        return result
    }

    /**
     * @brief[zh-cn] 设置刚体重力因子（缩放施加到该刚体的重力）
     * @param[zh-cn] handle 刚体句柄
     * gravityFactor 重力因子（1.0 为正常重力，0.0 为失重）
     *
     * @brief[en] Sets the body gravity factor (scales the gravity applied to the body)
     * @param[en] handle Body handle
     * gravityFactor Gravity factor (1.0 is normal gravity, 0.0 is weightless)
     */
    public func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        JPH_BodyInterface_SetGravityFactor_cj(this._bodyIface, handle.bodyID, Float32(gravityFactor))
    }

    /**
     * @brief[zh-cn] 获取刚体重力因子
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 重力因子（1.0 为正常重力，0.0 为失重）
     *
     * @brief[en] Gets the body gravity factor
     * @param[en] handle Body handle
     * @return[en] Gravity factor (1.0 is normal gravity, 0.0 is weightless)
     */
    public func getGravityFactor(handle: PhysicsBodyHandle): Float64 {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return 1.0
        }
        return Float64(JPH_BodyInterface_GetGravityFactor_cj(this._bodyIface, handle.bodyID))
    }

    // =========================================================================
    // 运动学
    // =========================================================================

    /**
     * @brief[zh-cn] 移动运动学刚体到给定位姿（由物理系统插值，应在 update 前调用）
     * @param[zh-cn] handle 刚体句柄
     * position 目标位置（three 左手系）
     * rotation 目标旋转（three 左手系）
     * deltaTime 本帧时间步长（秒）
     *
     * @brief[en] Moves a kinematic body to the given pose (interpolated by the physics system; call before update)
     * @param[en] handle Body handle
     * position Target position (three left-handed coordinates)
     * rotation Target rotation (three left-handed coordinates)
     * deltaTime Time step of this frame (seconds)
     */
    public func moveKinematic(handle: PhysicsBodyHandle, position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit {
        if (!this._inited || this._bodyIface.isNull() || !handle.isValid()) {
            return
        }
        let p = unsafe { LibC.malloc<JPHVec3>() }
        let q = unsafe { LibC.malloc<JPHQuat>() }
        let jp = JoltBackend._lhToRh(position)
        let jq = JoltBackend._lhToRhQuat(rotation)
        unsafe {
            p.write(JPHVec3(x: Float32(jp.x), y: Float32(jp.y), z: Float32(jp.z)))
            q.write(JPHQuat(x: Float32(jq.x), y: Float32(jq.y), z: Float32(jq.z), w: Float32(jq.w)))
        }
        JPH_BodyInterface_MoveKinematic_cj(this._bodyIface, handle.bodyID, p, q, deltaTime)
        unsafe {
            LibC.free(p);
            LibC.free(q)
        }
    }

    // =========================================================================
    // 约束
    // =========================================================================

    /// 约束句柄缓存（constraintID -> Jolt 约束句柄）
    private var _constraints: HashMap<UInt32, CPointer<Unit>> = HashMap<UInt32, CPointer<Unit>>()
    /// 约束类型缓存（constraintID -> 约束类型）；电机等类型相关 API 必须按此分发，
    /// 因为 joltc 的 Hinge/Slider setter 直接 reinterpret_cast，跨类型调用会写入
    /// 错误的对象内存偏移
    private var _constraintTypes: HashMap<UInt32, PhysicsConstraintType> = HashMap<UInt32, PhysicsConstraintType>()
    /// 约束两端刚体 ID（constraintID -> (bodyA, bodyB)）；
    /// 电机状态/目标变更时需要唤醒可能已休眠的刚体：Jolt 的休眠刚体不参与约束
    /// 求解，而 SetMotorState/SetTarget* 本身不会唤醒刚体（Jolt 官方 Sample 也是
    /// 显式 ActivateBody），否则切换电机模式后电机会静默失效。
    private var _constraintBodies: HashMap<UInt32, (UInt32, UInt32)> = HashMap<UInt32, (UInt32, UInt32)>()
    /// 约束 ID 自增计数器
    private var _nextConstraintID: UInt32 = 1

    /// 将 PhysicsConstraintDesc 填充到对应 Jolt 约束 Settings 并创建约束
    private func _createJoltConstraint(
        desc: PhysicsConstraintDesc,
        bodyA: PhysicsBodyHandle,
        bodyB: PhysicsBodyHandle
    ): CPointer<Unit> {
        // 约束空间
        let space: UInt32 = match (desc.space) {
            case PhysicsConstraintSpace.LocalToBodyCOM => 0
            case PhysicsConstraintSpace.WorldSpace => 1
        }
        // 锚点/轴缓冲（three 左手系 → Jolt 右手系）
        let ja1 = JoltBackend._lhToRh(desc.anchor1)
        let ja2 = JoltBackend._lhToRh(desc.anchor2)
        let jax1 = JoltBackend._lhToRh(desc.axis1)
        let jax2 = JoltBackend._lhToRh(desc.axis2)
        let jpl = JoltBackend._lhToRh(desc.planeAxis)
        let a1 = unsafe { LibC.malloc<JPHVec3>() }
        let a2 = unsafe { LibC.malloc<JPHVec3>() }
        let ax1 = unsafe { LibC.malloc<JPHVec3>() }
        let ax2 = unsafe { LibC.malloc<JPHVec3>() }
        let pl = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            a1.write(JPHVec3(x: Float32(ja1.x), y: Float32(ja1.y), z: Float32(ja1.z)))
            a2.write(JPHVec3(x: Float32(ja2.x), y: Float32(ja2.y), z: Float32(ja2.z)))
            ax1.write(JPHVec3(x: Float32(jax1.x), y: Float32(jax1.y), z: Float32(jax1.z)))
            ax2.write(JPHVec3(x: Float32(jax2.x), y: Float32(jax2.y), z: Float32(jax2.z)))
            pl.write(JPHVec3(x: Float32(jpl.x), y: Float32(jpl.y), z: Float32(jpl.z)))
        }
        let bodyAID = JPH_PhysicsSystem_GetBodyPtr_cj(this._system, bodyA.bodyID)
        let bodyBID = JPH_PhysicsSystem_GetBodyPtr_cj(this._system, bodyB.bodyID)
        if (bodyAID.isNull() || bodyBID.isNull()) {
            unsafe {
                LibC.free(a1);
                LibC.free(a2);
                LibC.free(ax1);
                LibC.free(ax2);
                LibC.free(pl)
            }
            return CPointer<Unit>()
        }

        var constraint: CPointer<Unit> = CPointer<Unit>()
        match (desc.constraintType) {
            case PhysicsConstraintType.Fixed =>
                let s = unsafe { LibC.malloc<JPHFixedConstraintSettings>() }
                unsafe { JPH_FixedConstraintSettings_Init_cj(s) }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    s.write(cs)
                }
                constraint = JPH_FixedConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
            case PhysicsConstraintType.Point =>
                let s = unsafe { LibC.malloc<JPHPointConstraintSettings>() }
                unsafe { JPH_PointConstraintSettings_Init_cj(s) }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    cs.point1 = a1.read()
                    cs.point2 = a2.read()
                    s.write(cs)
                }
                constraint = JPH_PointConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
            case PhysicsConstraintType.Hinge =>
                let s = unsafe { LibC.malloc<JPHHingeConstraintSettings>() }
                unsafe { JPH_HingeConstraintSettings_Init_cj(s) }
                // normalAxis 必须与 hingeAxis 垂直（Jolt 用叉积建局部坐标系，
                // 平行会导致约束退化、物体沿错误方向漂移）。
                // 注意：此处用已转换到 Jolt 右手系的 hingeAxis（jax1）计算垂直向量，
                // 不能用原始 desc.axis1（左手系），否则 normalAxis 与 hingeAxis 不垂直。
                let ha = jax1
                var nAxis = jpl
                if (ha.cross(nAxis).length() < 1e-9) {
                    nAxis = Vector3(1.0, 0.0, 0.0)
                    if (ha.cross(nAxis).length() < 1e-9) {
                        nAxis = Vector3(0.0, 0.0, 1.0)
                    }
                }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    cs.point1 = a1.read()
                    cs.point2 = a2.read()
                    cs.hingeAxis1 = ax1.read()
                    cs.hingeAxis2 = ax2.read()
                    cs.normalAxis1 = JPHVec3(x: Float32(nAxis.x), y: Float32(nAxis.y), z: Float32(nAxis.z))
                    cs.normalAxis2 = JPHVec3(x: Float32(nAxis.x), y: Float32(nAxis.y), z: Float32(nAxis.z))
                    cs.limitsMin = Float32(desc.limitMin)
                    cs.limitsMax = Float32(desc.limitMax)
                    s.write(cs)
                }
                constraint = JPH_HingeConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
            case PhysicsConstraintType.Slider =>
                let s = unsafe { LibC.malloc<JPHSliderConstraintSettings>() }
                unsafe { JPH_SliderConstraintSettings_Init_cj(s) }
                // normalAxis 必须与 sliderAxis 垂直（Jolt 用 cross(slider, normal)
                // 构造第二个局部轴，平行会使约束框架退化、电机冲量为零）。
                // joltc Init 的 normal 默认来自 Jolt 默认轴 X 的垂直向量 Y，
                // 这里覆写 sliderAxis 后必须同步重算，不能沿用默认值。
                let sa = jax1
                var sn = jpl
                if (sa.cross(sn).length() < 1e-9) {
                    sn = Vector3(1.0, 0.0, 0.0)
                    if (sa.cross(sn).length() < 1e-9) {
                        sn = Vector3(0.0, 0.0, 1.0)
                    }
                }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    cs.point1 = a1.read()
                    cs.point2 = a2.read()
                    cs.sliderAxis1 = ax1.read()
                    cs.sliderAxis2 = ax2.read()
                    cs.normalAxis1 = JPHVec3(x: Float32(sn.x), y: Float32(sn.y), z: Float32(sn.z))
                    cs.normalAxis2 = JPHVec3(x: Float32(sn.x), y: Float32(sn.y), z: Float32(sn.z))
                    cs.limitsMin = Float32(desc.limitMin)
                    cs.limitsMax = Float32(desc.limitMax)
                    s.write(cs)
                }
                constraint = JPH_SliderConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
            case PhysicsConstraintType.Distance =>
                let s = unsafe { LibC.malloc<JPHDistanceConstraintSettings>() }
                unsafe { JPH_DistanceConstraintSettings_Init_cj(s) }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    cs.point1 = a1.read()
                    cs.point2 = a2.read()
                    cs.minDistance = Float32(desc.limitMin)
                    cs.maxDistance = Float32(desc.limitMax)
                    s.write(cs)
                }
                constraint = JPH_DistanceConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
            case PhysicsConstraintType.Cone =>
                let s = unsafe { LibC.malloc<JPHConeConstraintSettings>() }
                unsafe { JPH_ConeConstraintSettings_Init_cj(s) }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    cs.point1 = a1.read()
                    cs.point2 = a2.read()
                    cs.twistAxis1 = ax1.read()
                    cs.twistAxis2 = ax2.read()
                    cs.halfConeAngle = Float32(desc.limitMin)
                    s.write(cs)
                }
                constraint = JPH_ConeConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
            case PhysicsConstraintType.SwingTwist =>
                let s = unsafe { LibC.malloc<JPHSwingTwistConstraintSettings>() }
                unsafe { JPH_SwingTwistConstraintSettings_Init_cj(s) }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    cs.position1 = a1.read()
                    cs.position2 = a2.read()
                    cs.twistAxis1 = ax1.read()
                    cs.twistAxis2 = ax2.read()
                    cs.planeAxis1 = pl.read()
                    cs.planeAxis2 = pl.read()
                    cs.twistMinAngle = Float32(desc.limitMin)
                    cs.twistMaxAngle = Float32(desc.limitMax)
                    s.write(cs)
                }
                constraint = JPH_SwingTwistConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
            case PhysicsConstraintType.SixDOF =>
                let s = unsafe { LibC.malloc<JPHSixDOFConstraintSettings>() }
                unsafe { JPH_SixDOFConstraintSettings_Init_cj(s) }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    cs.position1 = a1.read()
                    cs.position2 = a2.read()
                    cs.axisX1 = ax1.read()
                    cs.axisX2 = ax2.read()
                    s.write(cs)
                }
                constraint = JPH_SixDOFConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
            case PhysicsConstraintType.Gear =>
                let s = unsafe { LibC.malloc<JPHGearConstraintSettings>() }
                unsafe { JPH_GearConstraintSettings_Init_cj(s) }
                unsafe {
                    var cs = s.read()
                    cs.space = space
                    cs.hingeAxis1 = ax1.read()
                    cs.hingeAxis2 = ax2.read()
                    cs.ratio = Float32(if (desc.limitMin > 0.0) {
                        desc.limitMin
                    } else {
                        1.0
                    })
                    s.write(cs)
                }
                constraint = JPH_GearConstraint_Create_cj(s, bodyAID, bodyBID)
                unsafe { LibC.free(s) }
        }

        unsafe {
            LibC.free(a1);
            LibC.free(a2);
            LibC.free(ax1);
            LibC.free(ax2);
            LibC.free(pl)
        }
        return constraint
    }

    /**
     * @brief[zh-cn] 在两个刚体之间创建约束并加入世界
     * @param[zh-cn] desc 约束描述（类型、空间、锚点、轴、限制等）
     * bodyA 刚体 A 句柄
     * bodyB 刚体 B 句柄
     * @return[zh-cn] 约束句柄；创建失败返回 PhysicsConstraintHandle.INVALID
     *
     * @brief[en] Creates a constraint between two bodies and adds it to the world
     * @param[en] desc Constraint description (type, space, anchors, axes, limits, etc.)
     * bodyA Body A handle
     * bodyB Body B handle
     * @return[en] Constraint handle; PhysicsConstraintHandle.INVALID on failure
     */
    public func createConstraint(desc: PhysicsConstraintDesc, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraintHandle {
        if (!this._inited || this._system.isNull() || !bodyA.isValid() || !bodyB.isValid()) {
            return PhysicsConstraintHandle.INVALID
        }
        // Jolt 原生限制：GearConstraintPart 求解时无条件访问两体的 MotionProperties，
        // 而静态体该指针为空，会在物理步进时空指针崩溃。静态体不能转动，齿轮耦合
        // 对它也无物理意义，这里直接拒绝创建（返回 INVALID）而非让进程崩溃。
        let isGear = match (desc.constraintType) {
            case PhysicsConstraintType.Gear => true
            case _ => false
        }
        let isStatic = { h: PhysicsBodyHandle =>
            match (this.getMotionType(h)) {
                case PhysicsMotionType.Static => true
                case _ => false
            }
        }
        if (isGear && (isStatic(bodyA) || isStatic(bodyB))) {
            Logger.error(["JoltBackend", "Gear 约束不允许连接静态刚体（Jolt 原生限制），创建失败"])
            return PhysicsConstraintHandle.INVALID
        }
        // 约束对之间禁用碰撞（否则摆杆/支柱等连接体互相卡住）。
        // 用自增子组号（bodyID 含序列号位，不能直接当 subGroupID 用）
        if (!this._groupFilter.isNull()) {
            let subA = this._bodySubGroup.get(bodyA.bodyID)
            let subB = this._bodySubGroup.get(bodyB.bodyID)
            match (subA) {
                case Some(sa) => match (subB) {
                    case Some(sb) => JPH_GroupFilterTable_DisableCollision_cj(this._groupFilter, sa, sb)
                    case None => ()
                }
                case None => ()
            }
        }
        let c = this._createJoltConstraint(desc, bodyA, bodyB)
        if (c.isNull()) {
            Logger.error(["JoltBackend", "创建约束失败"])
            return PhysicsConstraintHandle.INVALID
        }
        // 加入世界并缓存
        JPH_PhysicsSystem_AddConstraint_cj(this._system, c)
        let id = this._nextConstraintID
        this._nextConstraintID++
        this._constraints[id] = c
        this._constraintTypes[id] = desc.constraintType
        this._constraintBodies[id] = (bodyA.bodyID, bodyB.bodyID)
        return PhysicsConstraintHandle(constraintID: id)
    }

    /**
     * @brief[zh-cn] 唤醒约束两端的非静态刚体
     * @explain[zh-cn] Jolt 中休眠刚体不参与约束求解；SetMotorState / SetTarget* 不会
     *                 自动唤醒刚体。切换电机模式或更新目标时必须显式激活，
     *                 否则电机看起来"静默失效"（位置/速度完全不变）。
     * @param[zh-cn] constraintID 约束 ID
     *
     * @brief[en] Wakes the non-static bodies attached to a constraint
     * @explain[en] Sleeping bodies skip constraint solving in Jolt and the motor
     *              setters do not wake them. Callers driving a motor must activate
     *              the bodies, otherwise the motor appears silently ineffective.
     * @param[en] constraintID Constraint ID
     */
    private func _wakeConstraintBodies(constraintID: UInt32): Unit {
        match (this._constraintBodies.get(constraintID)) {
            case Some(pair) =>
                this._activateIfDynamic(pair[0])
                this._activateIfDynamic(pair[1])
            case None => ()
        }
    }

    /// 唤醒单个刚体（仅动态/运动学；静态体无 MotionProperties，不可激活）
    private func _activateIfDynamic(bodyID: UInt32): Unit {
        let h = PhysicsBodyHandle(bodyID: bodyID)
        if (!h.isValid()) {
            return
        }
        match (this.getMotionType(h)) {
            case PhysicsMotionType.Static => ()
            case _ => JPH_BodyInterface_ActivateBody_cj(this._bodyIface, bodyID)
        }
    }

    /**
     * @brief[zh-cn] 从世界移除并销毁约束
     * @param[zh-cn] handle 约束句柄
     *
     * @brief[en] Removes and destroys the constraint from the world
     * @param[en] handle Constraint handle
     */
    public func destroyConstraint(handle: PhysicsConstraintHandle): Unit {
        if (!this._inited || this._system.isNull() || !handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                JPH_PhysicsSystem_RemoveConstraint_cj(this._system, c)
                JPH_Constraint_Destroy_cj(c)
                this._constraints.remove(handle.constraintID)
                this._constraintTypes.remove(handle.constraintID)
                this._constraintBodies.remove(handle.constraintID)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 查询约束是否处于启用状态
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 启用返回 true
     *
     * @brief[en] Returns whether the constraint is enabled
     * @param[en] handle Constraint handle
     * @return[en] Returns true if enabled
     */
    public func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool {
        if (!handle.isValid()) {
            return false
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) => JPH_Constraint_GetEnabled_cj(c) != 0
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 启用或禁用约束
     * @param[zh-cn] handle 约束句柄
     * enabled 是否启用
     *
     * @brief[en] Enables or disables the constraint
     * @param[en] handle Constraint handle
     * enabled Whether to enable the constraint
     */
    public func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit {
        if (!handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) => JPH_Constraint_SetEnabled_cj(c, if (enabled) {
                1u8
            } else {
                0u8
            })
            case None => ()
        }
    }

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
    public func setConstraintMotorState(handle: PhysicsConstraintHandle, state: PhysicsMotorState): Unit {
        if (!handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                // 必须按约束实际类型分发：joltc setter 内部直接
                // reinterpret_cast<Hinge/SliderConstraint>，跨类型调用会破坏内存
                match (this._constraintTypes.get(handle.constraintID)) {
                    case Some(PhysicsConstraintType.Hinge) =>
                        JPH_HingeConstraint_SetMotorState_cj(c, state.value())
                        // 切电机模式时刚体可能已休眠（如位置模式稳定后），
                        // 不唤醒则速度电机完全不产生力矩
                        this._wakeConstraintBodies(handle.constraintID)
                    case Some(PhysicsConstraintType.Slider) =>
                        JPH_SliderConstraint_SetMotorState_cj(c, state.value())
                        this._wakeConstraintBodies(handle.constraintID)
                    case _ => ()
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 设置铰链约束目标角速度（电机速度模式，弧度/秒）
     * @param[zh-cn] handle 约束句柄
     * angularVelocity 目标角速度（弧度/秒）
     *
     * @brief[en] Sets the hinge constraint target angular velocity (motor velocity mode, rad/s)
     * @param[en] handle The constraint handle
     * angularVelocity The target angular velocity (rad/s)
     */
    public func setConstraintTargetAngularVelocity(handle: PhysicsConstraintHandle, angularVelocity: Float64): Unit {
        if (!handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                JPH_HingeConstraint_SetTargetAngularVelocity_cj(c, Float32(angularVelocity))
                this._wakeConstraintBodies(handle.constraintID)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 设置铰链约束目标角度（电机位置模式，弧度）
     * @param[zh-cn] handle 约束句柄
     * angle 目标角度（弧度）
     *
     * @brief[en] Sets the hinge constraint target angle (motor position mode, radians)
     * @param[en] handle The constraint handle
     * angle The target angle (radians)
     */
    public func setConstraintTargetAngle(handle: PhysicsConstraintHandle, angle: Float64): Unit {
        if (!handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                JPH_HingeConstraint_SetTargetAngle_cj(c, Float32(angle))
                this._wakeConstraintBodies(handle.constraintID)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 获取铰链约束当前角度（弧度）
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 当前角度（弧度）；无效句柄返回 0
     *
     * @brief[en] Gets the hinge constraint current angle (radians)
     * @param[en] handle The constraint handle
     * @return[en] The current angle (radians); 0 for an invalid handle
     */
    public func getConstraintCurrentAngle(handle: PhysicsConstraintHandle): Float64 {
        if (!handle.isValid()) {
            return 0.0
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) => Float64(JPH_HingeConstraint_GetCurrentAngle_cj(c))
            case None => 0.0
        }
    }

    /**
     * @brief[zh-cn] 设置滑块约束目标速度（电机速度模式，米/秒）
     * @param[zh-cn] handle 约束句柄
     * velocity 目标速度（米/秒）
     *
     * @brief[en] Sets the slider constraint target velocity (motor velocity mode, m/s)
     * @param[en] handle The constraint handle
     * velocity The target velocity (m/s)
     */
    public func setSliderTargetVelocity(handle: PhysicsConstraintHandle, velocity: Float64): Unit {
        if (!handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                match (this._constraintTypes.get(handle.constraintID)) {
                    case Some(PhysicsConstraintType.Slider) =>
                        JPH_SliderConstraint_SetTargetVelocity_cj(c, Float32(velocity))
                        this._wakeConstraintBodies(handle.constraintID)
                    case _ => ()
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 设置滑块约束目标位置（电机位置模式，米）
     * @param[zh-cn] handle 约束句柄
     * position 目标位置（米）
     *
     * @brief[en] Sets the slider constraint target position (motor position mode, meters)
     * @param[en] handle The constraint handle
     * position The target position (meters)
     */
    public func setSliderTargetPosition(handle: PhysicsConstraintHandle, position: Float64): Unit {
        if (!handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                match (this._constraintTypes.get(handle.constraintID)) {
                    case Some(PhysicsConstraintType.Slider) =>
                        JPH_SliderConstraint_SetTargetPosition_cj(c, Float32(position))
                        this._wakeConstraintBodies(handle.constraintID)
                    case _ => ()
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 获取滑块约束当前位置（米）
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 当前位置（米）；无效句柄返回 0
     *
     * @brief[en] Gets the slider constraint current position (meters)
     * @param[en] handle The constraint handle
     * @return[en] The current position (meters); 0 for an invalid handle
     */
    public func getSliderCurrentPosition(handle: PhysicsConstraintHandle): Float64 {
        if (!handle.isValid()) {
            return 0.0
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                match (this._constraintTypes.get(handle.constraintID)) {
                    case Some(PhysicsConstraintType.Slider) =>
                        Float64(JPH_SliderConstraint_GetCurrentPosition_cj(c))
                    case _ => 0.0
                }
            case None => 0.0
        }
    }

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
    public func setConstraintLimits(handle: PhysicsConstraintHandle, limitMin: Float64, limitMax: Float64): Unit {
        if (!handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                JPH_HingeConstraint_SetLimits_cj(c, Float32(limitMin), Float32(limitMax))
                JPH_SliderConstraint_SetLimits_cj(c, Float32(limitMin), Float32(limitMax))
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 设置约束最大摩擦（Hinge 为力矩，Slider 为力）
     * @param[zh-cn] handle 约束句柄
     * friction 最大摩擦值
     *
     * @brief[en] Sets the constraint max friction (torque for Hinge, force for Slider)
     * @param[en] handle The constraint handle
     * friction The maximum friction value
     */
    public func setConstraintMaxFriction(handle: PhysicsConstraintHandle, friction: Float64): Unit {
        if (!handle.isValid()) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) =>
                JPH_HingeConstraint_SetMaxFrictionTorque_cj(c, Float32(friction))
                JPH_SliderConstraint_SetMaxFrictionForce_cj(c, Float32(friction))
            case None => ()
        }
    }

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
    public func setSixDOFMotorState(handle: PhysicsConstraintHandle, axis: Int64, state: PhysicsMotorState): Unit {
        if (!handle.isValid() || axis < 0 || axis > 5) {
            return
        }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) => JPH_SixDOFConstraint_SetMotorState_cj(c, UInt32(axis), state.value())
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 设置六自由度约束约束空间目标位置（平移电机）
     * @param[zh-cn] handle 约束句柄
     * target 约束空间目标位置
     *
     * @brief[en] Sets the SixDOF constraint-space target position (translation motors)
     * @param[en] handle The constraint handle
     * target The target position in constraint space
     */
    public func setSixDOFTargetPosition(handle: PhysicsConstraintHandle, target: Vector3): Unit {
        if (!handle.isValid()) {
            return
        }
        let jt = JoltBackend._lhToRh(target)
        let v = unsafe { LibC.malloc<JPHVec3>() }
        unsafe { v.write(JPHVec3(x: Float32(jt.x), y: Float32(jt.y), z: Float32(jt.z))) }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) => JPH_SixDOFConstraint_SetTargetPositionCS_cj(c, v)
            case None => ()
        }
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 设置六自由度约束约束空间目标速度（平移电机）
     * @param[zh-cn] handle 约束句柄
     * target 约束空间目标速度
     *
     * @brief[en] Sets the SixDOF constraint-space target velocity (translation motors)
     * @param[en] handle The constraint handle
     * target The target velocity in constraint space
     */
    public func setSixDOFTargetVelocity(handle: PhysicsConstraintHandle, target: Vector3): Unit {
        if (!handle.isValid()) {
            return
        }
        let jt = JoltBackend._lhToRh(target)
        let v = unsafe { LibC.malloc<JPHVec3>() }
        unsafe { v.write(JPHVec3(x: Float32(jt.x), y: Float32(jt.y), z: Float32(jt.z))) }
        match (this._constraints.get(handle.constraintID)) {
            case Some(c) => JPH_SixDOFConstraint_SetTargetVelocityCS_cj(c, v)
            case None => ()
        }
        unsafe { LibC.free(v) }
    }

    // =========================================================================
    // 内部
    // =========================================================================

    /// 仅销毁层过滤/作业系统句柄（initialize 失败时回滚用）
    private func _cleanupHandles(): Unit {
        if (!this._ovsFilter.isNull()) {
            JPH_ObjectVsBroadPhaseLayerFilter_Destroy_cj(this._ovsFilter)
            this._ovsFilter = CPointer<Unit>()
        }
        if (!this._bpInterface.isNull()) {
            JPH_BroadPhaseLayerInterface_Destroy_cj(this._bpInterface)
            this._bpInterface = CPointer<Unit>()
        }
        if (!this._pairFilter.isNull()) {
            JPH_ObjectLayerPairFilter_Destroy_cj(this._pairFilter)
            this._pairFilter = CPointer<Unit>()
        }
        if (!this._jobSystem.isNull()) {
            JPH_JobSystem_Destroy_cj(this._jobSystem)
            this._jobSystem = CPointer<Unit>()
        }
    }

    // =========================================================================
    // 碰撞查询回调分发（CFunc 无捕获，经静态 _activeSink 中转收集器）
    // =========================================================================

    /// 接触验证回调（返回 0 = 接受接触）
    private static func _onContactValidate(): UInt32 {
        return 0
    }

    /// 接触事件回调（Added/Persisted）→ IPhysicsSensorListener.onContact
    private static func _onContactEvent(body1: CPointer<Unit>, body2: CPointer<Unit>, event: PhysicsContactEvent): Unit {
        if (body1.isNull() || body2.isNull()) {
            return
        }
        let id1 = JPH_Body_GetID_cj(body1)
        let id2 = JPH_Body_GetID_cj(body2)
        match (JoltBackend._contactListener) {
            case Some(l) => l.onContact(id1, id2, event)
            case None => ()
        }
    }

    /// 接触移除回调 → IPhysicsSensorListener.onContact(Removed)
    private static func _onContactRemoved(pair: CPointer<JPHSubShapeIDPair>): Unit {
        if (pair.isNull()) {
            return
        }
        let p = unsafe { pair.read() }
        match (JoltBackend._contactListener) {
            case Some(l) => l.onContact(p.body1ID, p.body2ID, PhysicsContactEvent.Removed)
            case None => ()
        }
    }

    /// 刚体激活回调 → IPhysicsSensorListener.onBodyActivated
    private static func _onBodyActivated(bodyID: UInt32): Unit {
        match (JoltBackend._contactListener) {
            case Some(l) => l.onBodyActivated(bodyID)
            case None => ()
        }
    }

    /// 刚体休眠回调 → IPhysicsSensorListener.onBodyDeactivated
    private static func _onBodyDeactivated(bodyID: UInt32): Unit {
        match (JoltBackend._contactListener) {
            case Some(l) => l.onBodyDeactivated(bodyID)
            case None => ()
        }
    }

    /// 射线批量命中回调（JPH_CastRayResultCallback）
    private static func _onRayResult(ctx: CPointer<Unit>, result: CPointer<JPHRayCastResult>): Unit {
        match (JoltBackend._activeSink) {
            case Some(sink) => match (sink.rayHits) {
                case Some(hits) =>
                    let r = unsafe { result.read() }
                    let hit = PhysicsRayHit()
                    hit.bodyID = r.bodyID
                    hit.fraction = r.fraction
                    // 命中点 = origin + direction * fraction（右手系算后转左手系）
                    let f = Float64(r.fraction)
                    let pj = Vector3(sink.rayOrigin.x + sink.rayDirection.x * f,
                        sink.rayOrigin.y + sink.rayDirection.y * f, sink.rayOrigin.z + sink.rayDirection.z * f)
                    hit.point = JoltBackend._rhToLh(pj)
                    // 命中法线：GetBodyPtr → GetWorldSpaceSurfaceNormal（右手系 → 左手系）
                    hit.normal = JoltBackend._querySurfaceNormal(sink.system, r.bodyID, r.subShapeID2, pj)
                    hits.add(hit)
                case None => ()
            }
            case None => ()
        }
    }

    /// 查询刚体表面法线（右手系输入/输出，返回后转左手系）
    private static func _querySurfaceNormal(system: CPointer<Unit>, bodyID: UInt32, subShapeID: UInt32,
        worldPosJ: Vector3): Vector3 {
        if (system.isNull()) {
            return Vector3()
        }
        let body = JPH_PhysicsSystem_GetBodyPtr_cj(system, bodyID)
        if (body.isNull()) {
            return Vector3()
        }
        let posBuf = unsafe { LibC.malloc<JPHVec3>() }
        let nrmBuf = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            posBuf.write(JPHVec3(x: Float32(worldPosJ.x), y: Float32(worldPosJ.y), z: Float32(worldPosJ.z)))
            JPH_Body_GetWorldSpaceSurfaceNormal_cj(body, subShapeID, posBuf, nrmBuf)
        }
        let n = unsafe { nrmBuf.read() }
        let result = JoltBackend._rhToLh(Vector3(Float64(n.x), Float64(n.y), Float64(n.z)))
        unsafe {
            LibC.free(posBuf);
            LibC.free(nrmBuf)
        }
        return result
    }

    /// 点碰撞命中回调（JPH_CollidePointResultCallback）
    private static func _onCollidePointResult(ctx: CPointer<Unit>, result: CPointer<JPHCollidePointResult>): Unit {
        match (JoltBackend._activeSink) {
            case Some(sink) => match (sink.pointHits) {
                case Some(hits) =>
                    let r = unsafe { result.read() }
                    let hit = PhysicsPointHit()
                    hit.bodyID = r.bodyID
                    hit.subShapeID = r.subShapeID2
                    hits.add(hit)
                case None => ()
            }
            case None => ()
        }
    }

    /// 形状碰撞命中回调（JPH_CollideShapeResultCallback）
    private static func _onCollideShapeResult(ctx: CPointer<Unit>, result: CPointer<JPHCollideShapeResult>): Unit {
        match (JoltBackend._activeSink) {
            case Some(sink) => match (sink.shapeHits) {
                case Some(hits) =>
                    let r = unsafe { result.read() }
                    let hit = PhysicsShapeHit()
                    hit.bodyID = r.bodyID2
                    hit.penetrationDepth = r.penetrationDepth
                    hit.subShapeID1 = r.subShapeID1
                    hit.subShapeID2 = r.subShapeID2
                    // 接触点/穿透轴（右手系 → 左手系）
                    hit.point = JoltBackend._rhToLh(
                        Vector3(Float64(r.contactPointOn1.x), Float64(r.contactPointOn1.y), Float64(r.contactPointOn1.z)))
                    hit.normal = JoltBackend._rhToLh(
                        Vector3(Float64(r.penetrationAxis.x), Float64(r.penetrationAxis.y), Float64(r.penetrationAxis.z)))
                    hits.add(hit)
                case None => ()
            }
            case None => ()
        }
    }

    /// 形状投射命中回调（JPH_CastShapeResultCallback）
    private static func _onCastShapeResult(ctx: CPointer<Unit>, result: CPointer<JPHShapeCastResult>): Unit {
        match (JoltBackend._activeSink) {
            case Some(sink) => match (sink.shapeHits) {
                case Some(hits) =>
                    let r = unsafe { result.read() }
                    let hit = PhysicsShapeHit()
                    hit.bodyID = r.bodyID2
                    hit.fraction = r.fraction
                    hit.penetrationDepth = r.penetrationDepth
                    hit.subShapeID1 = r.subShapeID1
                    hit.subShapeID2 = r.subShapeID2
                    hit.isBackFaceHit = r.isBackFaceHit
                    hit.point = JoltBackend._rhToLh(
                        Vector3(Float64(r.contactPointOn1.x), Float64(r.contactPointOn1.y), Float64(r.contactPointOn1.z)))
                    hit.normal = JoltBackend._rhToLh(
                        Vector3(Float64(r.penetrationAxis.x), Float64(r.penetrationAxis.y), Float64(r.penetrationAxis.z)))
                    hits.add(hit)
                case None => ()
            }
            case None => ()
        }
    }
}

// =============================================================================
// JoltQuerySink：查询回调收集器（CFunc 无捕获，经 JoltBackend._activeSink 中转）
// =============================================================================

/**
 * @brief[zh-cn] 查询期间的回调收集器（CFunc 无捕获，经静态字段中转）
 * @explain[zh-cn] 由于 joltc 的回调函数签名是 CFunc（无捕获闭包），
 * 无法直接把结果列表传入回调，因此使用 JoltBackend._activeSink
 * 静态字段中转。查询开始时设置，查询结束清除。
 *
 * @brief[en] Callback sink during queries (CFunc has no capture, relayed via static field)
 * @explain[en] Since joltc callback function signatures are CFunc (no-capture closures),
 * result lists cannot be passed directly into callbacks. Instead,
 * JoltBackend._activeSink is used as a static field relay.
 * Set at query start, cleared at query end.
 */
class JoltQuerySink {
    /**
     * @brief[zh-cn] 物理系统句柄（法线查询用：GetBodyPtr + GetWorldSpaceSurfaceNormal）
     *
     * @brief[en] Physics system handle (for normal queries: GetBodyPtr + GetWorldSpaceSurfaceNormal)
     */
    public var system: CPointer<Unit> = CPointer<Unit>()
    /**
     * @brief[zh-cn] 射线起点（右手系，用于命中点计算）
     *
     * @brief[en] Ray origin (right-handed, used for hit-point calculation)
     */
    public var rayOrigin: Vector3 = Vector3()
    /**
     * @brief[zh-cn] 射线方向（右手系）
     *
     * @brief[en] Ray direction (right-handed)
     */
    public var rayDirection: Vector3 = Vector3()
    /**
     * @brief[zh-cn] 批量射线命中列表（raycastAll）
     *
     * @brief[en] Batch ray-hit list (raycastAll)
     */
    public var rayHits: Option<ArrayList<PhysicsRayHit>> = None
    /**
     * @brief[zh-cn] 点碰撞命中列表（collidePoint）
     *
     * @brief[en] Point-collision hit list (collidePoint)
     */
    public var pointHits: Option<ArrayList<PhysicsPointHit>> = None
    /**
     * @brief[zh-cn] 形状碰撞/投射命中列表（collideShape/castShape）
     *
     * @brief[en] Shape-collision/cast hit list (collideShape/castShape)
     */
    public var shapeHits: Option<ArrayList<PhysicsShapeHit>> = None

    /**
     * @brief[zh-cn] 创建空的查询收集器
     *
     * @brief[en] Creates an empty query sink
     */
    public init() {}
}
