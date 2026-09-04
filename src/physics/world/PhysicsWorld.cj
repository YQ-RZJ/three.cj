/**
 * @file[zh-cn] PhysicsWorld 物理世界门面 + 独立物理线程
 * @brief[zh-cn] 提供后端无关的物理世界门面，持有独立物理线程序列化所有后端调用
 * @explain[zh-cn] 线程模型（对齐 AudioContext._audioLoop / BgfxRenderer._renderLoop）：
 * - 持有独立 three.core.thread.SThread，所有后端调用经 _execPhysics 序列化到物理线程执行。
 * - 同步原语使用 three.core.thread 的系统级 Mutex/Condition（基于 sdl4cj，跨用户态与系统线程同步）。
 * - 死锁约束：_execPhysics 不可重入——闭包内只能包含对 backend 的原始调用，
 * 禁止嵌套调用其它走 _execPhysics 的方法，否则自我等待死锁。
 * 可插拔后端：
 * - PhysicsWorld 仅依赖 three.physics.interfaces.IPhysicsBackend。
 * - 构造时注入具体后端实例（默认 JoltBackend）；运行时可通过 setBackend 切换。
 * - 替换底层物理库只需新写一个 IPhysicsBackend 实现，无需改 world/body/binding。
 * 步进驱动：PhysicsWorld.update(dt) 由主渲染线程每帧调用；
 * - _execPhysics({ => backend.update(dt, steps) })
 * - 同步：update 返回后，将刚体 transform 同步到绑定的 Object3D
 * （读取经 _execPhysics 序列化到物理线程，避免 Object3D 矩阵跨线程竞争）。
 *
 * @file[en] PhysicsWorld Physics-world facade + dedicated physics thread
 * @brief[en] Provides a backend-agnostic physics-world facade with a dedicated physics thread serializing all backend calls
 * @explain[en] Threading model (aligned with AudioContext._audioLoop / BgfxRenderer._renderLoop):
 * - owns a dedicated three.core.thread.SThread; every backend call is serialized
 * to the physics thread via _execPhysics.
 * - sync primitives use three.core.thread's system-level Mutex/Condition
 * (based on sdl4cj, synchronizing across user and system threads).
 * - deadlock rule: _execPhysics is not reentrant - the closure may only contain
 * raw backend calls; never nest calls to other methods that go through
 * _execPhysics, or a self-wait deadlock occurs.
 * Pluggable backend:
 * - PhysicsWorld depends only on three.physics.interfaces.IPhysicsBackend.
 * - a concrete backend instance is injected at construction (JoltBackend by
 * default); it can be swapped at runtime via setBackend.
 * - replacing the underlying engine only needs a new IPhysicsBackend
 * implementation, without touching world/body/binding.
 * Stepping: PhysicsWorld.update(dt) is called by the main render thread every frame;
 * - _execPhysics({ => backend.update(dt, steps) })
 * - after update returns, body transforms are synced to the bound Object3D
 * (reads are serialized to the physics thread via _execPhysics, avoiding
 * cross-thread races on Object3D matrices).
 */
package three.physics.world

import three.core.math.*
import three.physics.interfaces.*
import three.physics.backend.*
import three.scene.objects.*
import std.collection.*
import three.core.thread.*

/**
 * @brief[zh-cn] 绑定条目：Object3D ↔ 物理刚体句柄
 * @explain[zh-cn] 记录渲染对象与物理刚体的绑定关系，以及同步方向：
 * - syncToObj = true 时，物理→渲染（Dynamic/Kinematic 刚体由物理驱动）
 * - syncToObj = false 时，渲染→物理（Kinematic 由用户控制位置）
 * - offset 暂未使用，预留给质心校正等场景
 *
 * @brief[en] Binding entry: Object3D ↔ physics body handle
 * @explain[en] Records the binding between a render object and a physics body,
 * as well as the sync direction:
 * - syncToObj = true: physics→render (Dynamic/Kinematic bodies driven by physics)
 * - syncToObj = false: render→physics (Kinematic body position controlled by user)
 * - offset is currently unused, reserved for center-of-mass correction scenarios
 */
internal class PhysicsBinding {
    /**
     * @brief[zh-cn] 被绑定的渲染对象
     *
     * @brief[en] The bound render object
     */
    public var object3d: Object3D
    /**
     * @brief[zh-cn] 物理刚体句柄
     *
     * @brief[en] The physics body handle
     */
    public var handle: PhysicsBodyHandle
    /**
     * @brief[zh-cn] 同步方向：true=物理→渲染，false=渲染→物理
     *
     * @brief[en] Sync direction: true=physics→render, false=render→physics
     */
    public var syncToObj: Bool
    /**
     * @brief[zh-cn] 渲染对象相对物理刚体的局部偏移（暂未使用）
     *
     * @brief[en] Local offset of the render object relative to the physics body (currently unused)
     */
    public var offset: Vector3

    /**
     * @brief[zh-cn] 创建绑定条目
     * @param[zh-cn] object3d 被绑定的渲染对象
     * handle 物理刚体句柄
     * syncToObj 同步方向
     * offset 局部偏移（默认零向量）
     *
     * @brief[en] Creates a binding entry
     * @param[en] object3d The bound render object
     * handle The physics body handle
     * syncToObj Sync direction
     * offset Local offset (zero vector by default)
     */
    public init(object3d!: Object3D, handle!: PhysicsBodyHandle,
                syncToObj!: Bool, offset!: Vector3 = Vector3()) {
        this.object3d = object3d
        this.handle = handle
        this.syncToObj = syncToObj
        this.offset = offset
    }
}

/**
 * @brief[zh-cn] 物理世界门面
 * @explain[zh-cn] 典型用法：
 * let world = PhysicsWorld(JoltBackend())
 * world.init(1024, Vector3(0.0, -9.81, 0.0))
 * let body = world.createBody(desc)
 * world.bindObject(myMesh, body)
 * // 主循环
 * while (running) {
 * world.update(1.0f32 / 60.0f32, 1)
 * // 渲染 myMesh（transform 已被同步）
 * }
 * world.shutdown()
 *
 * @brief[en] Physics-world facade
 * @explain[en] Typical usage:
 * let world = PhysicsWorld(JoltBackend())
 * world.init(1024, Vector3(0.0, -9.81, 0.0))
 * let body = world.createBody(desc)
 * world.bindObject(myMesh, body)
 * // main loop
 * while (running) {
 * world.update(1.0f32 / 60.0f32, 1)
 * // render myMesh (transform has already been synced)
 * }
 * world.shutdown()
 */
public class PhysicsWorld {
    /// 物理后端（可插拔）
    private var _backend: IPhysicsBackend

    /// 绑定映射：Object3D.id -> PhysicsBinding
    private var _bindings: HashMap<Int64, PhysicsBinding> = HashMap<Int64, PhysicsBinding>()

    /// ===== 物理同步原语（对齐 BgfxRenderer._renderMtx/_renderCmdCnd） =====
    private var _physicsMtx = Mutex()
    private var _physicsCmdCnd = Condition()
    private var _physicsDoneCnd = Condition()
    private var _physicsCmd: Option<() -> Unit> = None
    private var _physicsDone: Bool = false
    private var _physicsExit: Bool = false
    private var _physicsSThread: Option<SThread<Unit>> = None

    /**
     * @brief[zh-cn] 构造物理世界
     * @param[zh-cn] backend 物理后端实例（默认 JoltBackend）；可替换为其他 IPhysicsBackend 实现
     *
     * @brief[en] Constructs the physics world
     * @param[en] backend The physics backend instance (JoltBackend by default); any IPhysicsBackend implementation may be used
     */
    public init(backend!: IPhysicsBackend = JoltBackend()) {
        this._backend = backend
    }

    /**
     * @brief[zh-cn] 当前后端实例
     * @explain[zh-cn] 供高级用户直接访问。
     *
     * @brief[en] The current backend instance
     * @explain[en] For direct access by advanced users.
     */
    public prop backend: IPhysicsBackend {
        get() { this._backend }
    }

    /**
     * @brief[zh-cn] 替换后端（运行时切换底层物理库）
     * @param[zh-cn] newBackend 新的后端实例
     *
     * @brief[en] Replaces the backend (swaps the underlying physics engine at runtime)
     * @param[en] newBackend The new backend instance
     *
     * @note[zh-cn] 旧后端必须先 shutdown；新后端需 init 后方可使用。
     * @note[en] The old backend must be shut down first; the new backend must be initialized before use.
     */
    public func setBackend(newBackend: IPhysicsBackend): Unit {
        this._backend = newBackend
    }

    // =========================================================================
    // 线程基础设施（对照 AudioContext._initAudioThread/_audioLoop/_execAudio）
    // =========================================================================

    private func _initPhysicsThread(): Unit {
        if (this._physicsSThread.isSome()) { return }
        // Mutex/Condition 已在字段声明处初始化
        this._physicsSThread = SThread{ this._physicsLoop(); () }
    }

    private func _physicsLoop(): Unit {
        while (!this._physicsExit) {
            this._physicsMtx.lock()
            while (this._physicsCmd.isNone() && !this._physicsExit) {
                this._physicsCmdCnd.wait(this._physicsMtx)
            }
            match (this._physicsCmd) {
                case Some(cmd) =>
                    cmd()
                    this._physicsCmd = None
                    this._physicsDone = true
                    this._physicsDoneCnd.signal()
                case None => ()
            }
            this._physicsMtx.unlock()
        }
    }

    /**
     * 内部线程序列化：将 cmd 提交到物理线程同步执行并等待完成。
     * 闭包内只能包含对 backend 的原始调用，禁止嵌套调用其它走 _execPhysics 的方法。
     */
    private func _execPhysics(cmd: () -> Unit): Unit {
        if (this._physicsSThread.isNone()) {
            this._initPhysicsThread()
        }
        this._physicsMtx.lock()
        this._physicsCmd = Some(cmd)
        this._physicsDone = false
        this._physicsCmdCnd.signal()
        while (!this._physicsDone) {
            this._physicsDoneCnd.wait(this._physicsMtx)
        }
        this._physicsMtx.unlock()
    }

    // =========================================================================
    // 生命周期
    // =========================================================================

    /**
     * @brief[zh-cn] 启动物理世界（初始化后端 + 启动物理线程）
     * @param[zh-cn] maxBodies 世界最多刚体数（默认 1024）
     * gravity 全局重力（默认 (0, -9.81, 0)）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Starts the physics world (initializes the backend + starts the physics thread)
     * @param[en] maxBodies Maximum number of bodies in the world (default 1024)
     * gravity The global gravity (default (0, -9.81, 0))
     * @return[en] true on success
     */
    public func start(maxBodies!: UInt32 = 1024u32,
                      gravity!: Vector3 = Vector3(0.0, -9.81, 0.0)): Bool {
        this._initPhysicsThread()
        let okBox: Box<Bool> = Box(false)
        let be = this._backend
        _execPhysics({ =>
            okBox.value = be.initialize(maxBodies, gravity)
        })
        return okBox.value
    }

    /**
     * @brief[zh-cn] 关闭物理世界：销毁所有绑定/刚体 → backend.shutdown → 通知物理线程退出
     *
     * @brief[en] Shuts down the physics world: destroys all bindings/bodies → backend.shutdown → notifies the physics thread to exit
     */
    public func shutdown(): Unit {
        // 解除所有绑定（仅清映射，刚体由 backend.shutdown 内部清理）
        this._bindings.clear()

        let be = this._backend
        _execPhysics({ => be.shutdown() })

        // 通知物理线程退出
        this._physicsMtx.lock()
        this._physicsExit = true
        this._physicsCmdCnd.signal()
        this._physicsMtx.unlock()
    }

    /**
     * @brief[zh-cn] 后端是否已初始化
     * @return[zh-cn] 已初始化返回 true
     *
     * @brief[en] Whether the backend is initialized
     * @return[en] true if initialized
     */
    public func isInitialized(): Bool { return this._backend.isInitialized() }

    // =========================================================================
    // 世界设置
    // =========================================================================

    /**
     * @brief[zh-cn] 设置全局重力
     * @param[zh-cn] gravity 重力向量（如 (0, -9.81, 0)）
     *
     * @brief[en] Sets the global gravity
     * @param[en] gravity The gravity vector (e.g. (0, -9.81, 0))
     */
    public func setGravity(gravity: Vector3): Unit {
        let be = this._backend
        _execPhysics({ => be.setGravity(gravity) })
    }

    /**
     * @brief[zh-cn] 优化 BroadPhase 包围盒树
     *
     * @brief[en] Optimizes the BroadPhase bounding-volume tree
     *
     * @note[zh-cn] 在批量插入刚体后、正式模拟前调用一次。
     * @note[en] Call once after bulk-inserting bodies and before the main simulation.
     */
    public func optimizeBroadPhase(): Unit {
        let be = this._backend
        _execPhysics({ => be.optimizeBroadPhase() })
    }

    // =========================================================================
    // 形状/刚体（便捷构造 + 直接创建）
    // =========================================================================

    /**
     * @brief[zh-cn] 创建刚体（一步完成）
     * @param[zh-cn] desc 刚体创建描述
     * @return[zh-cn] 刚体句柄；失败返回 INVALID
     *
     * @brief[en] Creates a rigid body (single step)
     * @param[en] desc The body creation description
     * @return[en] The body handle, or INVALID on failure
     */
    public func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle {
        let handleBox: Box<PhysicsBodyHandle> = Box(PhysicsBodyHandle.INVALID)
        let be = this._backend
        _execPhysics({ => handleBox.value = be.createBody(desc) })
        return handleBox.value
    }

    /**
     * @brief[zh-cn] 销毁刚体并解除任何绑定
     * @param[zh-cn] handle 刚体句柄
     *
     * @brief[en] Destroys a body and unbinds any bindings
     * @param[en] handle The body handle
     */
    public func destroyBody(handle: PhysicsBodyHandle): Unit {
        // 先解除绑定
        var keyToRemove: Option<Int64> = None
        for ((k, b) in this._bindings) {
            if (b.handle.bodyID == handle.bodyID) {
                keyToRemove = Some(k)
                break
            }
        }
        match (keyToRemove) {
            case Some(k) => this._bindings.remove(k)
            case None => ()
        }
        let be = this._backend
        _execPhysics({ => be.destroyBody(handle) })
    }

    // =========================================================================
    // Object3D 绑定
    // =========================================================================

    /**
     * @brief[zh-cn] 绑定 Object3D 与已有刚体：步进后自动将刚体 transform 同步到 object3d
     * @param[zh-cn] object3d 被绑定的渲染对象
     * handle 物理刚体句柄
     * syncToObj true=物理→渲染（Dynamic/Kinematic 刚体）；
     * false=渲染→物理（Kinematic 由用户驱动时可选）
     *
     * @brief[en] Binds an Object3D to an existing body: the body transform is auto-synced to the object after each step
     * @param[en] object3d The rendering object to bind
     * handle The physics body handle
     * syncToObj true = physics→render (Dynamic/Kinematic bodies);
     * false = render→physics (optional when a Kinematic body is user-driven)
     */
    public func bindObject(object3d: Object3D, handle: PhysicsBodyHandle,
                           syncToObj!: Bool = true): Unit {
        if (!handle.isValid()) { return }
        this._bindings[object3d.id] = PhysicsBinding(
            object3d: object3d, handle: handle, syncToObj: syncToObj)
    }

    /**
     * @brief[zh-cn] 解除 Object3D 的物理绑定（不销毁刚体）
     * @param[zh-cn] object3d 要解除绑定的渲染对象
     *
     * @brief[en] Unbinds an Object3D from physics (does not destroy the body)
     * @param[en] object3d The rendering object to unbind
     */
    public func unbindObject(object3d: Object3D): Unit {
        this._bindings.remove(object3d.id)
    }

    /**
     * @brief[zh-cn] 获取某 Object3D 绑定的刚体句柄
     * @param[zh-cn] object3d 渲染对象
     * @return[zh-cn] 刚体句柄；无绑定返回 INVALID
     *
     * @brief[en] Gets the body handle bound to an Object3D
     * @param[en] object3d The rendering object
     * @return[en] The body handle, or INVALID if not bound
     */
    public func getBoundHandle(object3d: Object3D): PhysicsBodyHandle {
        match (this._bindings.get(object3d.id)) {
            case Some(b) => b.handle
            case None => PhysicsBodyHandle.INVALID
        }
    }

    // =========================================================================
    // 步进 + Transform 同步
    // =========================================================================

    /**
     * @brief[zh-cn] 步进物理世界一帧 + 同步刚体 transform 到绑定的 Object3D
     * @explain[zh-cn] 线程约定：update 由主渲染线程每帧调用；内部 _execPhysics 将
     * backend.update + transform 读取 + Object3D 写入一起序列化到物理线程。
     * 这样 Object3D 的 position/quaternion 只在物理线程写入，避免与渲染线程的
     * updateMatrixWorld 竞争（渲染线程在 renderer.render 之前 updateMatrixWorld，
     * 此时物理线程已结束本帧同步——_execPhysics 是同步等待语义）。
     * @param[zh-cn] deltaTime 时间步长（秒），典型 1/60
     * collisionSteps 每步内的碰撞细分次数（1/60s 一步取 1）
     * @return[zh-cn] 更新错误标志（0 = 完整完成）
     *
     * @brief[en] Steps the physics world by one frame + syncs body transforms to the bound Object3D
     * @explain[en] Threading contract: update is called by the main render thread every frame;
     * internally _execPhysics serializes backend.update + transform reads + Object3D
     * writes onto the physics thread. This way an Object3D's position/quaternion are
     * only written on the physics thread, avoiding races with the render thread's
     * updateMatrixWorld (the render thread calls updateMatrixWorld before
     * renderer.render, by which time the physics thread has finished this frame's
     * sync — _execPhysics is synchronous-wait semantics).
     * @param[en] deltaTime The time step (seconds), typically 1/60
     * collisionSteps The number of collision substeps per step (1 for a 1/60s step)
     * @return[en] The update error flags (0 = completed fully)
     */
    public func update(deltaTime: Float32, collisionSteps!: Int32 = 1): UInt32 {
        let errBox: Box<UInt32> = Box(0u32)
        let be = this._backend
        let bindings = this._bindings
        _execPhysics({ =>
            errBox.value = be.update(deltaTime, collisionSteps)
            // 同步 transform 到绑定的 Object3D
            for ((_, b) in bindings) {
                if (!b.syncToObj) { continue }
                if (!b.handle.isValid()) { continue }
                let pos = be.getPosition(b.handle)
                let rot = be.getRotation(b.handle)
                b.object3d.position.set(pos.x, pos.y, pos.z)
                b.object3d.quaternion.set(rot.x, rot.y, rot.z, rot.w)
                // 触发矩阵更新（matrixAutoUpdate=true 时 renderer.render 会重算）
                b.object3d.matrixWorldNeedsUpdate = true
            }
        })
        return errBox.value
    }

    // =========================================================================
    // 刚体属性读写（经 _execPhysics 序列化）
    // =========================================================================

    /**
     * @brief[zh-cn] 设置刚体位置（世界坐标）
     * @param[zh-cn] handle 刚体句柄
     * position 新位置
     * activation 激活策略（默认 Activate）
     *
     * @brief[en] Sets the body position (world coordinates)
     * @param[en] handle The body handle
     * position The new position
     * activation The activation strategy (default Activate)
     */
    public func setPosition(handle: PhysicsBodyHandle, position: Vector3,
                            activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        let be = this._backend
        _execPhysics({ => be.setPosition(handle, position, activation) })
    }

    /**
     * @brief[zh-cn] 获取刚体位置（世界坐标）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前位置
     *
     * @brief[en] Gets the body position (world coordinates)
     * @param[en] handle The body handle
     * @return[en] The body's current position
     */
    public func getPosition(handle: PhysicsBodyHandle): Vector3 {
        let posBox: Box<Vector3> = Box(Vector3())
        let be = this._backend
        _execPhysics({ => posBox.value = be.getPosition(handle) })
        return posBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体旋转（四元数）
     * @param[zh-cn] handle 刚体句柄
     * rotation 新旋转
     * activation 激活策略（默认 Activate）
     *
     * @brief[en] Sets the body rotation (quaternion)
     * @param[en] handle The body handle
     * rotation The new rotation
     * activation The activation strategy (default Activate)
     */
    public func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion,
                            activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        let be = this._backend
        _execPhysics({ => be.setRotation(handle, rotation, activation) })
    }

    /**
     * @brief[zh-cn] 获取刚体旋转（四元数）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前旋转
     *
     * @brief[en] Gets the body rotation (quaternion)
     * @param[en] handle The body handle
     * @return[en] The body's current rotation
     */
    public func getRotation(handle: PhysicsBodyHandle): Quaternion {
        let rotBox: Box<Quaternion> = Box(Quaternion())
        let be = this._backend
        _execPhysics({ => rotBox.value = be.getRotation(handle) })
        return rotBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体线速度（世界空间，米/秒）
     * @param[zh-cn] handle 刚体句柄
     * velocity 线速度
     *
     * @brief[en] Sets the body linear velocity (world space, m/s)
     * @param[en] handle The body handle
     * velocity The linear velocity
     */
    public func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit {
        let be = this._backend
        _execPhysics({ => be.setLinearVelocity(handle, velocity) })
    }

    /**
     * @brief[zh-cn] 获取刚体线速度（世界空间，米/秒）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前线速度
     *
     * @brief[en] Gets the body linear velocity (world space, m/s)
     * @param[en] handle The body handle
     * @return[en] The body's current linear velocity
     */
    public func getLinearVelocity(handle: PhysicsBodyHandle): Vector3 {
        let vBox: Box<Vector3> = Box(Vector3())
        let be = this._backend
        _execPhysics({ => vBox.value = be.getLinearVelocity(handle) })
        return vBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体角速度（世界空间，弧度/秒）
     * @param[zh-cn] handle 刚体句柄
     * angularVelocity 角速度
     *
     * @brief[en] Sets the body angular velocity (world space, rad/s)
     * @param[en] handle The body handle
     * angularVelocity The angular velocity
     */
    public func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit {
        let be = this._backend
        _execPhysics({ => be.setAngularVelocity(handle, angularVelocity) })
    }

    /**
     * @brief[zh-cn] 获取刚体角速度（世界空间，弧度/秒）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前角速度
     *
     * @brief[en] Gets the body angular velocity (world space, rad/s)
     * @param[en] handle The body handle
     * @return[en] The body's current angular velocity
     */
    public func getAngularVelocity(handle: PhysicsBodyHandle): Vector3 {
        let vBox: Box<Vector3> = Box(Vector3())
        let be = this._backend
        _execPhysics({ => vBox.value = be.getAngularVelocity(handle) })
        return vBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体摩擦系数（0~1）
     * @param[zh-cn] handle 刚体句柄
     * friction 摩擦系数
     *
     * @brief[en] Sets the body friction coefficient (0~1)
     * @param[en] handle The body handle
     * friction The friction coefficient
     */
    public func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit {
        let be = this._backend
        _execPhysics({ => be.setFriction(handle, friction) })
    }

    /**
     * @brief[zh-cn] 获取刚体摩擦系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前摩擦系数
     *
     * @brief[en] Gets the body friction coefficient
     * @param[en] handle The body handle
     * @return[en] The body's current friction coefficient
     */
    public func getFriction(handle: PhysicsBodyHandle): Float64 {
        let fBox: Box<Float64> = Box(0.0)
        let be = this._backend
        _execPhysics({ => fBox.value = be.getFriction(handle) })
        return fBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体弹性系数（0~1）
     * @param[zh-cn] handle 刚体句柄
     * restitution 弹性系数
     *
     * @brief[en] Sets the body restitution coefficient (0~1)
     * @param[en] handle The body handle
     * restitution The restitution coefficient
     */
    public func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit {
        let be = this._backend
        _execPhysics({ => be.setRestitution(handle, restitution) })
    }

    /**
     * @brief[zh-cn] 获取刚体弹性系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前弹性系数
     *
     * @brief[en] Gets the body restitution coefficient
     * @param[en] handle The body handle
     * @return[en] The body's current restitution coefficient
     */
    public func getRestitution(handle: PhysicsBodyHandle): Float64 {
        let rBox: Box<Float64> = Box(0.0)
        let be = this._backend
        _execPhysics({ => rBox.value = be.getRestitution(handle) })
        return rBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体运动类型（运行时切换 Static/Kinematic/Dynamic）
     * @param[zh-cn] handle 刚体句柄
     * motionType 目标运动类型
     * activation 激活策略（默认 Activate）
     *
     * @brief[en] Sets the body motion type (switch Static/Kinematic/Dynamic at runtime)
     * @param[en] handle The body handle
     * motionType The target motion type
     * activation The activation strategy (default Activate)
     */
    public func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType,
                              activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        let be = this._backend
        _execPhysics({ => be.setMotionType(handle, motionType, activation) })
    }

    /**
     * @brief[zh-cn] 获取刚体运动类型
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前运动类型
     *
     * @brief[en] Gets the body motion type
     * @param[en] handle The body handle
     * @return[en] The body's current motion type
     */
    public func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType {
        let mtBox: Box<PhysicsMotionType> = Box(PhysicsMotionType.Static)
        let be = this._backend
        _execPhysics({ => mtBox.value = be.getMotionType(handle) })
        return mtBox.value
    }

    /**
     * @brief[zh-cn] 查询刚体是否处于活动（模拟）状态
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 活动返回 true
     *
     * @brief[en] Queries whether a body is in the active (simulating) state
     * @param[en] handle The body handle
     * @return[en] true if active
     */
    public func isBodyActive(handle: PhysicsBodyHandle): Bool {
        let aBox: Box<Bool> = Box(false)
        let be = this._backend
        _execPhysics({ => aBox.value = be.isBodyActive(handle) })
        return aBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体是否为传感器
     * @param[zh-cn] handle 刚体句柄
     * isSensor 是否传感器（只检测碰撞、不产生物理响应）
     *
     * @brief[en] Sets whether a body is a sensor
     * @param[en] handle The body handle
     * isSensor Whether the body is a sensor (collision-only, no physical response)
     */
    public func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit {
        let be = this._backend
        _execPhysics({ => be.setIsSensor(handle, isSensor) })
    }

    // =========================================================================
    // 射线查询
    // =========================================================================

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
    public func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool {
        let okBox: Box<Bool> = Box(false)
        let be = this._backend
        _execPhysics({ => okBox.value = be.raycast(origin, direction, hit) })
        return okBox.value
    }

    // =========================================================================
    // 碰撞查询（完整能力：批量射线 / 点碰撞 / 形状碰撞 / 形状投射）
    // =========================================================================

    /**
     * @brief[zh-cn] 世界射线批量检测（收集所有命中，按距离升序）
     * @param[zh-cn] origin 射线起点（世界坐标）
     * direction 射线方向（长度即最大检测距离）
     * @return[zh-cn] 命中列表（按 fraction 升序）
     *
     * @brief[en] World ray batch cast (collects all hits, sorted by distance ascending)
     * @param[en] origin The ray origin (world coordinates)
     * direction The ray direction (its length is the max cast distance)
     * @return[en] The hit list (sorted by fraction ascending)
     */
    public func raycastAll(origin: Vector3, direction: Vector3): ArrayList<PhysicsRayHit> {
        let hits = ArrayList<PhysicsRayHit>()
        let be = this._backend
        _execPhysics({ => be.raycastAll(origin, direction, hits) })
        return hits
    }

    /**
     * @brief[zh-cn] 世界点碰撞检测（检测点位于哪些形状内部/表面）
     * @param[zh-cn] point 世界坐标检测点
     * @return[zh-cn] 命中列表
     *
     * @brief[en] World point collision test (which shapes contain or touch the point)
     * @param[en] point The test point in world coordinates
     * @return[en] The hit list
     */
    public func collidePoint(point: Vector3): ArrayList<PhysicsPointHit> {
        let hits = ArrayList<PhysicsPointHit>()
        let be = this._backend
        _execPhysics({ => be.collidePoint(point, hits) })
        return hits
    }

    /**
     * @brief[zh-cn] 形状 vs 世界碰撞检测（查询形状摆到 pose 后与场景求交）
     * @param[zh-cn] shape 查询形状描述
     * position 查询形状位置（世界坐标）
     * rotation 查询形状旋转
     * @return[zh-cn] 命中列表
     *
     * @brief[en] Shape-vs-world collision test (intersects the scene with the query shape placed at the pose)
     * @param[en] shape The query shape description
     * position The query shape position (world coordinates)
     * rotation The query shape rotation
     * @return[en] The hit list
     */
    public func collideShape(shape: PhysicsShape,
                             position: Vector3, rotation: Quaternion): ArrayList<PhysicsShapeHit> {
        let hits = ArrayList<PhysicsShapeHit>()
        let be = this._backend
        _execPhysics({ => be.collideShape(shape, position, rotation, hits) })
        return hits
    }

    /**
     * @brief[zh-cn] 形状投射（shape 沿 direction 扫掠，检测首个/全部阻挡）
     * @param[zh-cn] shape 投射形状描述
     * position 投射起点位置（世界坐标）
     * rotation 投射形状旋转
     * direction 投射方向（长度即最大扫掠距离）
     * @return[zh-cn] 命中列表（按 fraction 升序；空 = 无阻挡）
     *
     * @brief[en] Shape cast (sweeps shape along direction, detecting the first/all blockers)
     * @param[en] shape The cast shape description
     * position The cast start position (world coordinates)
     * rotation The cast shape rotation
     * direction The cast direction (its length is the max sweep distance)
     * @return[en] The hit list (sorted by fraction ascending; empty = no blocker)
     */
    public func castShape(shape: PhysicsShape,
                          position: Vector3, rotation: Quaternion,
                          direction: Vector3): ArrayList<PhysicsShapeHit> {
        let hits = ArrayList<PhysicsShapeHit>()
        let be = this._backend
        _execPhysics({ => be.castShape(shape, position, rotation, direction, hits) })
        return hits
    }

    /**
     * @brief[zh-cn] 注册碰撞事件监听器（接触回调 + 激活/休眠回调）
     * @param[zh-cn] listener 监听器；None 注销
     *
     * @brief[en] Registers a collision event listener (contact + activation/sleep callbacks)
     * @param[en] listener The listener, or None to unregister
     */
    public func setContactListener(listener: Option<IPhysicsSensorListener>): Unit {
        let be = this._backend
        _execPhysics({ => be.setContactListener(listener) })
    }

    // =========================================================================
    // 力 / 力矩 / 冲量（经物理线程转发）
    // =========================================================================

    /**
     * @brief[zh-cn] 在刚体质心施加力（牛顿）
     * @param[zh-cn] handle 刚体句柄
     * force 力向量
     *
     * @brief[en] Applies a force at the body's center of mass (newtons)
     * @param[en] handle The body handle
     * force The force vector
     */
    public func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit {
        let be = this._backend
        _execPhysics({ => be.addForce(handle, force) })
    }

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
    public func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit {
        let be = this._backend
        _execPhysics({ => be.addForceAtPosition(handle, force, point) })
    }

    /**
     * @brief[zh-cn] 施加力矩（牛顿·米）
     * @param[zh-cn] handle 刚体句柄
     * torque 力矩向量
     *
     * @brief[en] Applies a torque (newton-meters)
     * @param[en] handle The body handle
     * torque The torque vector
     */
    public func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit {
        let be = this._backend
        _execPhysics({ => be.addTorque(handle, torque) })
    }

    /**
     * @brief[zh-cn] 在刚体质心施加冲量（冲量 = 力 × 时间）
     * @param[zh-cn] handle 刚体句柄
     * impulse 冲量向量
     *
     * @brief[en] Applies an impulse at the body's center of mass (impulse = force × time)
     * @param[en] handle The body handle
     * impulse The impulse vector
     */
    public func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit {
        let be = this._backend
        _execPhysics({ => be.addImpulse(handle, impulse) })
    }

    /**
     * @brief[zh-cn] 施加角冲量
     * @param[zh-cn] handle 刚体句柄
     * angularImpulse 角冲量向量
     *
     * @brief[en] Applies an angular impulse
     * @param[en] handle The body handle
     * angularImpulse The angular impulse vector
     */
    public func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit {
        let be = this._backend
        _execPhysics({ => be.addAngularImpulse(handle, angularImpulse) })
    }

    // =========================================================================
    // 质量 / 惯量（经物理线程转发）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取刚体质量（千克）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前质量
     *
     * @brief[en] Gets the body mass (kilograms)
     * @param[en] handle The body handle
     * @return[en] The body's current mass
     */
    public func getMass(handle: PhysicsBodyHandle): Float64 {
        let mBox: Box<Float64> = Box(0.0)
        let be = this._backend
        _execPhysics({ => mBox.value = be.getMass(handle) })
        return mBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体质量（千克）
     * @param[zh-cn] handle 刚体句柄
     * mass 目标质量
     *
     * @brief[en] Sets the body mass (kilograms)
     * @param[en] handle The body handle
     * mass The target mass
     */
    public func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit {
        let be = this._backend
        _execPhysics({ => be.setMass(handle, mass) })
    }

    /**
     * @brief[zh-cn] 获取刚体逆惯量（3x3，输出 4x4 矩阵左上角）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前逆惯量矩阵
     *
     * @brief[en] Gets the body inverse inertia (3x3, in the top-left of the returned 4x4)
     * @param[en] handle The body handle
     * @return[en] The body's current inverse-inertia matrix
     */
    public func getInverseInertia(handle: PhysicsBodyHandle): Matrix4 {
        let mBox: Box<Matrix4> = Box(Matrix4())
        let be = this._backend
        _execPhysics({ => mBox.value = be.getInverseInertia(handle) })
        return mBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体重力因子（1 = 正常重力，0 = 无重力）
     * @param[zh-cn] handle 刚体句柄
     * gravityFactor 重力因子
     *
     * @brief[en] Sets the body gravity factor (1 = normal gravity, 0 = no gravity)
     * @param[en] handle The body handle
     * gravityFactor The gravity factor
     */
    public func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit {
        let be = this._backend
        _execPhysics({ => be.setGravityFactor(handle, gravityFactor) })
    }

    /**
     * @brief[zh-cn] 获取刚体重力因子
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前重力因子
     *
     * @brief[en] Gets the body gravity factor
     * @param[en] handle The body handle
     * @return[en] The body's current gravity factor
     */
    public func getGravityFactor(handle: PhysicsBodyHandle): Float64 {
        let gBox: Box<Float64> = Box(1.0)
        let be = this._backend
        _execPhysics({ => gBox.value = be.getGravityFactor(handle) })
        return gBox.value
    }

    // =========================================================================
    // 运动学（经物理线程转发）
    // =========================================================================

    /**
     * @brief[zh-cn] 运动学刚体移动到指定位置/旋转
     * @param[zh-cn] handle 刚体句柄
     * position 目标位置（世界坐标）
     * rotation 目标旋转
     * deltaTime 时间步长（秒）
     *
     * @brief[en] Moves a kinematic body to the given position/rotation
     * @param[en] handle The body handle
     * position The target position (world coordinates)
     * rotation The target rotation
     * deltaTime The time step (seconds)
     *
     * @note[zh-cn] 每帧调用，由 deltaTime 步长驱动。
     * @note[en] Call every frame; driven by the deltaTime step.
     */
    public func moveKinematic(handle: PhysicsBodyHandle, position: Vector3,
                              rotation: Quaternion, deltaTime: Float32): Unit {
        let be = this._backend
        _execPhysics({ => be.moveKinematic(handle, position, rotation, deltaTime) })
    }

    // =========================================================================
    // 约束（经物理线程转发）
    // =========================================================================

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
    public func createConstraint(desc: PhysicsConstraintDesc,
                                 bodyA: PhysicsBodyHandle,
                                 bodyB: PhysicsBodyHandle): PhysicsConstraintHandle {
        let cBox: Box<PhysicsConstraintHandle> = Box(PhysicsConstraintHandle.INVALID)
        let be = this._backend
        _execPhysics({ => cBox.value = be.createConstraint(desc, bodyA, bodyB) })
        return cBox.value
    }

    /**
     * @brief[zh-cn] 销毁约束并从世界移除（句柄立即失效）
     * @param[zh-cn] handle 约束句柄
     *
     * @brief[en] Destroys a constraint and removes it from the world (the handle becomes invalid immediately)
     * @param[en] handle The constraint handle
     */
    public func destroyConstraint(handle: PhysicsConstraintHandle): Unit {
        let be = this._backend
        _execPhysics({ => be.destroyConstraint(handle) })
    }

    /**
     * @brief[zh-cn] 约束是否启用
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 启用返回 true
     *
     * @brief[en] Whether the constraint is enabled
     * @param[en] handle The constraint handle
     * @return[en] true if enabled
     */
    public func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool {
        let eBox: Box<Bool> = Box(false)
        let be = this._backend
        _execPhysics({ => eBox.value = be.isConstraintEnabled(handle) })
        return eBox.value
    }

    /**
     * @brief[zh-cn] 设置约束是否启用
     * @param[zh-cn] handle 约束句柄
     * enabled 是否启用
     *
     * @brief[en] Sets whether the constraint is enabled
     * @param[en] handle The constraint handle
     * enabled Whether the constraint is enabled
     */
    public func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit {
        let be = this._backend
        _execPhysics({ => be.setConstraintEnabled(handle, enabled) })
    }
}
