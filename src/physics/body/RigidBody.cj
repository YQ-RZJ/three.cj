/**
 * @file[zh-cn] RigidBody 刚体便捷封装 + PhysicsShape 工厂函数说明
 * @brief[zh-cn] 提供 RigidBody 便捷封装，并说明 PhysicsShape 工厂函数
 * @explain[zh-cn] RigidBody 是 PhysicsWorld.createBody + bindObject 的便捷封装，
 * 让用户一行代码即可"创建带物理的 Mesh"：
 * let body = RigidBody(world)
 * .setShape(PhysicsShape.box(0.5, 0.5, 0.5))
 * .setPosition(0.0, 10.0, 0.0)
 * .setDynamic()              // Dynamic/Kinematic/Static
 * .setFriction(0.3)
 * .setRestitution(0.5)
 * .attach(myMesh)            // 创建刚体 + 绑定 myMesh
 * // ... world.update(dt) 后 myMesh.position/quaternion 自动同步
 * 设计要点：
 * - RigidBody 持有 PhysicsWorld 引用 + PhysicsBodyDesc + 绑定的 Object3D。
 * - attach() 调用 world.createBody + world.bindObject，并缓存 handle。
 * - 后续 setVelocity/setPosition 等直接转发到 world（经 _execPhysics）。
 * - dispose() 调用 world.destroyBody 并解除绑定。
 *
 * @file[en] RigidBody Rigid-body convenience wrapper + PhysicsShape factory functions
 * @brief[en] Provides the RigidBody convenience wrapper and documents the PhysicsShape factory functions
 * @explain[en] RigidBody is a convenience wrapper around PhysicsWorld.createBody +
 * bindObject, letting users create a "Mesh with physics" in one line:
 * let body = RigidBody(world)
 * .setShape(PhysicsShape.box(0.5, 0.5, 0.5))
 * .setPosition(0.0, 10.0, 0.0)
 * .setDynamic()              // Dynamic/Kinematic/Static
 * .setFriction(0.3)
 * .setRestitution(0.5)
 * .attach(myMesh)            // create body + bind myMesh
 * // ... myMesh.position/quaternion sync automatically after world.update(dt)
 * Design notes:
 * - RigidBody holds a reference to PhysicsWorld, a PhysicsBodyDesc and the
 * bound Object3D.
 * - attach() calls world.createBody + world.bindObject and caches the handle.
 * - Later setVelocity/setPosition etc. are forwarded to the world (via _execPhysics).
 * - dispose() calls world.destroyBody and unbinds the object.
 *
 * @note[zh-cn] PhysicsShape 工厂（类内静态方法）：
 * - box(width, height, depth) → PhysicsShape.Box(halfExtent)
 * - sphere(radius) → PhysicsShape.Sphere
 * - capsule(halfHeight, r) → PhysicsShape.Capsule
 * - cylinder(halfHeight, r) → PhysicsShape.Cylinder
 * - plane() → PhysicsShape.Plane
 * 这些工厂与 three.rendering.geometry 的 BoxGeometry/SphereGeometry/...
 * 参数对齐，方便"几何体形状"一键生成物理碰撞体。
 * @note[en] PhysicsShape factory (static methods):
 * - box(width, height, depth) → PhysicsShape.Box(halfExtent)
 * - sphere(radius) → PhysicsShape.Sphere
 * - capsule(halfHeight, r) → PhysicsShape.Capsule
 * - cylinder(halfHeight, r) → PhysicsShape.Cylinder
 * - plane() → PhysicsShape.Plane
 * These factories align with the parameters of BoxGeometry/SphereGeometry/...
 * in three.rendering.geometry, making it easy to generate a physics collider
 * from a "geometry shape" in one step.
 */
package three.physics.body

import three.core.math.*
import three.physics.interfaces.*
import three.physics.world.*
import three.scene.objects.*
import std.collection.*

/**
 * @brief[zh-cn] 物理刚体便捷封装
 * @explain[zh-cn] 采用链式构建模式：先在未 attach 时累积 PhysicsBodyDesc，
 * 再通过 attach() 一次性创建刚体并绑定渲染对象；attach 后各 setter
 * 直接转发到 PhysicsWorld（经 _execPhysics）。
 * 典型流程：
 * let body = RigidBody(world).setShape(...).setDynamic().attach(mesh)
 * world.update(dt)  // mesh 自动跟随物理
 * body.dispose()    // 销毁刚体并解除绑定
 *
 * @brief[en] Convenience wrapper for a physics rigid body
 * @explain[en] Uses a fluent builder pattern: while not attached, setters accumulate
 * into a PhysicsBodyDesc; attach() then creates the body and binds the render
 * object in one shot. After attaching, each setter forwards to PhysicsWorld
 * (via _execPhysics).
 * Typical flow:
 * let body = RigidBody(world).setShape(...).setDynamic().attach(mesh)
 * world.update(dt)  // mesh follows physics automatically
 * body.dispose()    // destroy body and unbind
 */
public class RigidBody {
    /// 所属物理世界
    private var _world: PhysicsWorld

    /// 刚体描述（构建期累积，attach 时使用）
    private var _desc: PhysicsBodyDesc

    /// 绑定的渲染对象（attach 后有效）
    private var _boundObj: Option<Object3D> = None

    /// 创建后的刚体句柄（attach 后有效）
    private var _handle: PhysicsBodyHandle = PhysicsBodyHandle.INVALID

    /// 是否已 attach
    private var _attached: Bool = false

    /**
     * @brief[zh-cn] 构造刚体构建器
     * @param[zh-cn] world 所属物理世界
     * shape 初始形状（默认 Box(0.5,0.5,0.5)）
     * layer 物理层（默认 Moving）
     *
     * @brief[en] Constructs a rigid-body builder
     * @param[en] world The owning physics world
     * shape The initial shape (defaults to Box(0.5,0.5,0.5))
     * layer The physics layer (defaults to Moving)
     */
    public init(world!: PhysicsWorld,
                shape!: PhysicsShape = PhysicsShape(
                    shapeType: PhysicsShapeType.Box,
                    halfExtent: Vector3(0.5, 0.5, 0.5)),
                layer!: PhysicsLayer = PhysicsLayer.Moving) {
        this._world = world
        this._desc = PhysicsBodyDesc(
            shape: shape, layer: layer,
            motionType: PhysicsMotionType.Dynamic,
            activation: PhysicsActivation.Activate,
            friction: 0.2, restitution: 0.0)
    }

    // =========================================================================
    // 链式构建 API
    // =========================================================================

    /**
     * @brief[zh-cn] 设置碰撞形状
     * @param[zh-cn] shape 新的碰撞形状
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the collision shape
     * @param[en] shape The new collision shape
     * @return[en] Returns itself (chainable)
     */
    public func setShape(shape: PhysicsShape): RigidBody {
        if (!this._attached) { this._desc.shape = shape }
        return this
    }

    /**
     * @brief[zh-cn] 设置初始位置（世界坐标）
     * @param[zh-cn] x 世界 X 坐标
     * y 世界 Y 坐标
     * z 世界 Z 坐标
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the initial position (world coordinates)
     * @param[en] x World X coordinate
     * y World Y coordinate
     * z World Z coordinate
     * @return[en] Returns itself (chainable)
     */
    public func setPosition(x: Float64, y: Float64, z: Float64): RigidBody {
        if (!this._attached) {
            this._desc.position = Vector3(x, y, z)
        } else if (this._handle.isValid()) {
            this._world.setPosition(this._handle, Vector3(x, y, z))
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置初始旋转（四元数）
     * @param[zh-cn] quat 初始四元数
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the initial rotation (quaternion)
     * @param[en] quat The initial quaternion
     * @return[en] Returns itself (chainable)
     */
    public func setRotation(quat: Quaternion): RigidBody {
        if (!this._attached) {
            this._desc.rotation = quat
        } else if (this._handle.isValid()) {
            this._world.setRotation(this._handle, quat)
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置初始旋转（欧拉角，单位弧度）
     * @param[zh-cn] x X 轴旋转角（弧度）
     * y Y 轴旋转角（弧度）
     * z Z 轴旋转角（弧度）
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the initial rotation (Euler angles, in radians)
     * @param[en] x Rotation about the X axis (radians)
     * y Rotation about the Y axis (radians)
     * z Rotation about the Z axis (radians)
     * @return[en] Returns itself (chainable)
     */
    public func setRotationEuler(x: Float64, y: Float64, z: Float64): RigidBody {
        let q = Quaternion().setFromEuler(Euler(x, y, z, EulerOrder.XYZ))
        return this.setRotation(q)
    }

    /**
     * @brief[zh-cn] 标记为 Dynamic 刚体（受重力/碰撞驱动）
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Marks the body as Dynamic (driven by gravity/collisions)
     * @return[en] Returns itself (chainable)
     */
    public func setDynamic(): RigidBody {
        if (!this._attached) {
            this._desc.motionType = PhysicsMotionType.Dynamic
            this._desc.layer = PhysicsLayer.Moving
        }
        return this
    }

    /**
     * @brief[zh-cn] 标记为 Kinematic 刚体（由用户控制，不受力）
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Marks the body as Kinematic (user-controlled, unaffected by forces)
     * @return[en] Returns itself (chainable)
     */
    public func setKinematic(): RigidBody {
        if (!this._attached) {
            this._desc.motionType = PhysicsMotionType.Kinematic
            this._desc.layer = PhysicsLayer.Moving
        }
        return this
    }

    /**
     * @brief[zh-cn] 标记为 Static 刚体（完全不动，如地面）
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Marks the body as Static (completely immobile, e.g. the ground)
     * @return[en] Returns itself (chainable)
     */
    public func setStatic(): RigidBody {
        if (!this._attached) {
            this._desc.motionType = PhysicsMotionType.Static
            this._desc.layer = PhysicsLayer.NonMoving
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置摩擦系数（0~1）
     * @param[zh-cn] friction 摩擦系数
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the friction coefficient (0~1)
     * @param[en] friction The friction coefficient
     * @return[en] Returns itself (chainable)
     */
    public func setFriction(friction: Float64): RigidBody {
        if (!this._attached) {
            this._desc.friction = friction
        } else if (this._handle.isValid()) {
            this._world.setFriction(this._handle, friction)
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置弹性系数（0~1）
     * @param[zh-cn] restitution 弹性系数
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the restitution coefficient (0~1)
     * @param[en] restitution The restitution coefficient
     * @return[en] Returns itself (chainable)
     */
    public func setRestitution(restitution: Float64): RigidBody {
        if (!this._attached) {
            this._desc.restitution = restitution
        } else if (this._handle.isValid()) {
            this._world.setRestitution(this._handle, restitution)
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置激活策略
     * @param[zh-cn] activation 激活策略
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the activation policy
     * @param[en] activation The activation policy
     * @return[en] Returns itself (chainable)
     */
    public func setActivation(activation: PhysicsActivation): RigidBody {
        if (!this._attached) { this._desc.activation = activation }
        return this
    }

    /**
     * @brief[zh-cn] 设置物理层
     * @param[zh-cn] layer 物理层
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the physics layer
     * @param[en] layer The physics layer
     * @return[en] Returns itself (chainable)
     */
    public func setLayer(layer: PhysicsLayer): RigidBody {
        if (!this._attached) { this._desc.layer = layer }
        return this
    }

    /**
     * @brief[zh-cn] 设置是否为传感器刚体（只检测碰撞、不产生物理响应）
     * @param[zh-cn] sensor 是否为传感器
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets whether the body is a sensor (detects collisions only, no physical response)
     * @param[en] sensor Whether it is a sensor
     * @return[en] Returns itself (chainable)
     */
    public func setSensor(sensor: Bool): RigidBody {
        if (!this._attached) {
            this._desc.isSensor = sensor
        } else if (this._handle.isValid()) {
            this._world.setIsSensor(this._handle, sensor)
        }
        return this
    }

    /**
     * @brief[zh-cn] 查询是否为传感器刚体
     * @return[zh-cn] 是否为传感器
     *
     * @brief[en] Queries whether the body is a sensor
     * @return[en] Whether it is a sensor
     */
    public prop isSensor: Bool {
        get() { this._desc.isSensor }
    }

    // =========================================================================
    // 创建/绑定/销毁
    // =========================================================================

    /**
     * @brief[zh-cn] 创建刚体并绑定到渲染对象
     * @explain[zh-cn] 若 object3d 已有位置/旋转，且 _desc.position 仍为默认 (0,0,0)，
     * 自动采用 object3d.position 作为初始位置（便于"先摆 mesh，再加物理"）。
     * @param[zh-cn] object3d 被绑定的渲染对象
     * syncToObj true=物理→渲染（Dynamic/Kinematic）
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Creates the body and binds it to a render object
     * @explain[en] If object3d already has a position/rotation and _desc.position is still
     * the default (0,0,0), the object3d.position is used automatically as the
     * initial position (for a "place the mesh first, then add physics" workflow).
     * @param[en] object3d The render object to bind
     * syncToObj true = physics→render (Dynamic/Kinematic)
     * @return[en] Returns itself (chainable)
     */
    public func attach(object3d: Object3D,
                       syncToObj!: Bool = true): RigidBody {
        if (this._attached) { return this }

        // 自动采用 object3d 的位置作为初始位置（若 desc.position 仍为原点）
        if (this._desc.position.x == 0.0 &&
            this._desc.position.y == 0.0 &&
            this._desc.position.z == 0.0) {
            this._desc.position = object3d.position.clone()
        }
        // 旋转同理（单位四元数时采用 object3d.quaternion）
        let q = this._desc.rotation
        if (q.x == 0.0 && q.y == 0.0 && q.z == 0.0 && q.w == 1.0) {
            this._desc.rotation = object3d.quaternion.clone()
        }

        // 创建刚体
        this._handle = this._world.createBody(this._desc)
        if (!this._handle.isValid()) {
            println("[RigidBody] attach 失败：createBody 返回 INVALID")
            return this
        }

        // 绑定
        this._world.bindObject(object3d, this._handle, syncToObj: syncToObj)
        this._boundObj = Some(object3d)
        this._attached = true
        return this
    }

    /**
     * @brief[zh-cn] 销毁刚体并解除绑定
     *
     * @brief[en] Destroys the body and unbinds it
     */
    public func dispose(): Unit {
        if (!this._attached) { return }
        // 解除绑定（destroyBody 内部也会清映射，但显式清更安全）
        match (this._boundObj) {
            case Some(obj) => this._world.unbindObject(obj)
            case None => ()
        }
        this._world.destroyBody(this._handle)
        this._handle = PhysicsBodyHandle.INVALID
        this._boundObj = None
        this._attached = false
    }

    // =========================================================================
    // 运行时访问
    // =========================================================================

    /**
     * @brief[zh-cn] 获取刚体句柄（attach 后有效）
     * @return[zh-cn] 刚体句柄
     *
     * @brief[en] Gets the body handle (valid after attach)
     * @return[en] The body handle
     */
    public prop handle: PhysicsBodyHandle {
        get() { this._handle }
    }

    /**
     * @brief[zh-cn] 是否已 attach
     * @return[zh-cn] 是否已 attach
     *
     * @brief[en] Whether it has been attached
     * @return[en] Whether it has been attached
     */
    public prop attached: Bool {
        get() { this._attached }
    }

    /**
     * @brief[zh-cn] 获取绑定的渲染对象
     * @return[zh-cn] 绑定的渲染对象（None 表示未绑定）
     *
     * @brief[en] Gets the bound render object
     * @return[en] The bound render object (None if not bound)
     */
    public prop boundObject: Option<Object3D> {
        get() { this._boundObj }
    }

    /**
     * @brief[zh-cn] 获取所属物理世界
     * @return[zh-cn] 所属物理世界
     *
     * @brief[en] Gets the owning physics world
     * @return[en] The owning physics world
     */
    public prop world: PhysicsWorld {
        get() { this._world }
    }

    // =========================================================================
    // 运行时控制（转发到 PhysicsWorld）
    // =========================================================================

    /**
     * @brief[zh-cn] 设置线速度（世界空间，米/秒）
     * @param[zh-cn] x X 方向线速度
     * y Y 方向线速度
     * z Z 方向线速度
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the linear velocity (world space, m/s)
     * @param[en] x Linear velocity along X
     * y Linear velocity along Y
     * z Linear velocity along Z
     * @return[en] Returns itself (chainable)
     */
    public func setLinearVelocity(x: Float64, y: Float64, z: Float64): RigidBody {
        if (this._handle.isValid()) {
            this._world.setLinearVelocity(this._handle, Vector3(x, y, z))
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置角速度（世界空间，弧度/秒）
     * @param[zh-cn] x X 轴角速度
     * y Y 轴角速度
     * z Z 轴角速度
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the angular velocity (world space, radians/s)
     * @param[en] x Angular velocity about X
     * y Angular velocity about Y
     * z Angular velocity about Z
     * @return[en] Returns itself (chainable)
     */
    public func setAngularVelocity(x: Float64, y: Float64, z: Float64): RigidBody {
        if (this._handle.isValid()) {
            this._world.setAngularVelocity(this._handle, Vector3(x, y, z))
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取线速度
     * @return[zh-cn] 线速度（未 attach 时返回零向量）
     *
     * @brief[en] Gets the linear velocity
     * @return[en] The linear velocity (zero vector if not attached)
     */
    public func getLinearVelocity(): Vector3 {
        if (!this._handle.isValid()) { return Vector3() }
        return this._world.getLinearVelocity(this._handle)
    }

    /**
     * @brief[zh-cn] 获取角速度
     * @return[zh-cn] 角速度（未 attach 时返回零向量）
     *
     * @brief[en] Gets the angular velocity
     * @return[en] The angular velocity (zero vector if not attached)
     */
    public func getAngularVelocity(): Vector3 {
        if (!this._handle.isValid()) { return Vector3() }
        return this._world.getAngularVelocity(this._handle)
    }

    /**
     * @brief[zh-cn] 设置位置（运行时）
     * @param[zh-cn] x 世界 X 坐标
     * y 世界 Y 坐标
     * z 世界 Z 坐标
     * activation 激活策略，默认 Activate
     *
     * @brief[en] Sets the position (at runtime)
     * @param[en] x World X coordinate
     * y World Y coordinate
     * z World Z coordinate
     * activation Activation policy, defaults to Activate
     */
    public func setPositionRuntime(x: Float64, y: Float64, z: Float64,
                                   activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        if (this._handle.isValid()) {
            this._world.setPosition(this._handle, Vector3(x, y, z), activation: activation)
        }
    }

    /**
     * @brief[zh-cn] 设置旋转（运行时）
     * @param[zh-cn] quat 目标四元数
     * activation 激活策略，默认 Activate
     *
     * @brief[en] Sets the rotation (at runtime)
     * @param[en] quat The target quaternion
     * activation Activation policy, defaults to Activate
     */
    public func setRotationRuntime(quat: Quaternion,
                                   activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        if (this._handle.isValid()) {
            this._world.setRotation(this._handle, quat, activation: activation)
        }
    }

    /**
     * @brief[zh-cn] 切换运动类型（运行时）
     * @param[zh-cn] motionType 新的运动类型
     * activation 激活策略，默认 Activate
     *
     * @brief[en] Switches the motion type (at runtime)
     * @param[en] motionType The new motion type
     * activation Activation policy, defaults to Activate
     */
    public func setMotionTypeRuntime(motionType: PhysicsMotionType,
                                     activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        if (this._handle.isValid()) {
            this._world.setMotionType(this._handle, motionType, activation: activation)
        }
    }

    /**
     * @brief[zh-cn] 刚体是否处于活动（模拟）状态
     * @return[zh-cn] 是否处于活动状态
     *
     * @brief[en] Whether the body is active (being simulated)
     * @return[en] Whether the body is active
     */
    public func isActive(): Bool {
        if (!this._handle.isValid()) { return false }
        return this._world.isBodyActive(this._handle)
    }

    /**
     * @brief[zh-cn] 获取当前位置
     * @return[zh-cn] 当前位置
     *
     * @brief[en] Gets the current position
     * @return[en] The current position
     */
    public func getPosition(): Vector3 {
        if (!this._handle.isValid()) { return Vector3() }
        return this._world.getPosition(this._handle)
    }

    /**
     * @brief[zh-cn] 获取当前旋转
     * @return[zh-cn] 当前旋转四元数
     *
     * @brief[en] Gets the current rotation
     * @return[en] The current rotation quaternion
     */
    public func getRotation(): Quaternion {
        if (!this._handle.isValid()) { return Quaternion() }
        return this._world.getRotation(this._handle)
    }

    // =========================================================================
    // 运行时控制：力 / 力矩 / 冲量（转发到 PhysicsWorld）
    // =========================================================================

    /**
     * @brief[zh-cn] 在质心施加力（牛顿）
     * @param[zh-cn] x 力在 X 方向的分量
     * y 力在 Y 方向的分量
     * z 力在 Z 方向的分量
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Applies a force at the center of mass (Newtons)
     * @param[en] x Force component along X
     * y Force component along Y
     * z Force component along Z
     * @return[en] Returns itself (chainable)
     */
    public func addForce(x: Float64, y: Float64, z: Float64): RigidBody {
        if (this._handle.isValid()) {
            this._world.addForce(this._handle, Vector3(x, y, z))
        }
        return this
    }

    /**
     * @brief[zh-cn] 在质心施加力（Vector3）
     * @param[zh-cn] force 力向量
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Applies a force at the center of mass (Vector3)
     * @param[en] force The force vector
     * @return[en] Returns itself (chainable)
     */
    public func addForceV(force: Vector3): RigidBody {
        if (this._handle.isValid()) {
            this._world.addForce(this._handle, force)
        }
        return this
    }

    /**
     * @brief[zh-cn] 在指定世界位置施加力
     * @param[zh-cn] force 力向量
     * point 力的作用点（世界坐标）
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Applies a force at a specified world position
     * @param[en] force The force vector
     * point The point of application (world coordinates)
     * @return[en] Returns itself (chainable)
     */
    public func addForceAtPosition(force: Vector3, point: Vector3): RigidBody {
        if (this._handle.isValid()) {
            this._world.addForceAtPosition(this._handle, force, point)
        }
        return this
    }

    /**
     * @brief[zh-cn] 施加力矩（牛顿·米）
     * @param[zh-cn] x 绕 X 轴的力矩
     * y 绕 Y 轴的力矩
     * z 绕 Z 轴的力矩
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Applies a torque (Newton·meters)
     * @param[en] x Torque about the X axis
     * y Torque about the Y axis
     * z Torque about the Z axis
     * @return[en] Returns itself (chainable)
     */
    public func addTorque(x: Float64, y: Float64, z: Float64): RigidBody {
        if (this._handle.isValid()) {
            this._world.addTorque(this._handle, Vector3(x, y, z))
        }
        return this
    }

    /**
     * @brief[zh-cn] 在质心施加冲量
     * @param[zh-cn] x 冲量在 X 方向的分量
     * y 冲量在 Y 方向的分量
     * z 冲量在 Z 方向的分量
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Applies an impulse at the center of mass
     * @param[en] x Impulse component along X
     * y Impulse component along Y
     * z Impulse component along Z
     * @return[en] Returns itself (chainable)
     */
    public func addImpulse(x: Float64, y: Float64, z: Float64): RigidBody {
        if (this._handle.isValid()) {
            this._world.addImpulse(this._handle, Vector3(x, y, z))
        }
        return this
    }

    /**
     * @brief[zh-cn] 施加角冲量
     * @param[zh-cn] x 绕 X 轴的角冲量
     * y 绕 Y 轴的角冲量
     * z 绕 Z 轴的角冲量
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Applies an angular impulse
     * @param[en] x Angular impulse about the X axis
     * y Angular impulse about the Y axis
     * z Angular impulse about the Z axis
     * @return[en] Returns itself (chainable)
     */
    public func addAngularImpulse(x: Float64, y: Float64, z: Float64): RigidBody {
        if (this._handle.isValid()) {
            this._world.addAngularImpulse(this._handle, Vector3(x, y, z))
        }
        return this
    }

    // =========================================================================
    // 运行时控制：质量 / 重力因子（转发到 PhysicsWorld）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取刚体质量（千克）
     * @return[zh-cn] 刚体质量（未 attach 时返回 0.0）
     *
     * @brief[en] Gets the body mass (kilograms)
     * @return[en] The body mass (0.0 if not attached)
     */
    public func getMass(): Float64 {
        if (!this._handle.isValid()) { return 0.0 }
        return this._world.getMass(this._handle)
    }

    /**
     * @brief[zh-cn] 设置刚体质量（千克）
     * @param[zh-cn] mass 新的质量
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the body mass (kilograms)
     * @param[en] mass The new mass
     * @return[en] Returns itself (chainable)
     */
    public func setMass(mass: Float64): RigidBody {
        if (this._handle.isValid()) {
            this._world.setMass(this._handle, mass)
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置重力因子（1 = 正常重力，0 = 无重力）
     * @param[zh-cn] gravityFactor 重力因子
     * @return[zh-cn] 返回自身（可链式）
     *
     * @brief[en] Sets the gravity factor (1 = normal gravity, 0 = no gravity)
     * @param[en] gravityFactor The gravity factor
     * @return[en] Returns itself (chainable)
     */
    public func setGravityFactor(gravityFactor: Float64): RigidBody {
        if (this._handle.isValid()) {
            this._world.setGravityFactor(this._handle, gravityFactor)
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取重力因子
     * @return[zh-cn] 重力因子（未 attach 时返回 1.0）
     *
     * @brief[en] Gets the gravity factor
     * @return[en] The gravity factor (1.0 if not attached)
     */
    public func getGravityFactor(): Float64 {
        if (!this._handle.isValid()) { return 1.0 }
        return this._world.getGravityFactor(this._handle)
    }

    // =========================================================================
    // 运行时控制：运动学（转发到 PhysicsWorld）
    // =========================================================================

    /**
     * @brief[zh-cn] 运动学刚体移动到指定位置/旋转（每帧调用）
     * @param[zh-cn] position 目标位置
     * rotation 目标旋转
     * deltaTime 距上一帧的时间差（秒）
     *
     * @brief[en] Moves a kinematic body to the given position/rotation (call every frame)
     * @param[en] position The target position
     * rotation The target rotation
     * deltaTime Time since the previous frame (seconds)
     */
    public func moveKinematic(position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit {
        if (this._handle.isValid()) {
            this._world.moveKinematic(this._handle, position, rotation, deltaTime)
        }
    }
}

// =============================================================================
// PhysicsShape 工厂已收拢为 PhysicsShape 类内静态方法：
//   PhysicsShape.box(width, height, depth) / sphere(radius) / capsule(halfHeight, r)
//   / cylinder(halfHeight, r) / plane() / mesh(vertices, triangles)
//   / convexHull(points) / compound(parts)
// 定义见 three.physics.interfaces.IPhysicsBackend.PhysicsShape。
// =============================================================================
