/**
 * @file[zh-cn] Character 角色控制器便捷封装（three.physics.character 子包）
 * @brief[zh-cn] 提供基于刚体与虚拟两类角色控制器封装
 * @explain[zh-cn] 在 jolt4cj.jolt 的 Character/CharacterVirtual _cj 包装之上提供
 * 面向 three 的角色控制层：
 * - PhysicsCharacter        ：基于刚体的角色（Character，受重力/碰撞驱动）
 * - PhysicsCharacterVirtual ：虚拟角色（CharacterVirtual，由用户控制移动，推荐）
 * 典型用法（虚拟角色，第一人称/第三人称移动）：
 * let settings = JPHCharacterVirtualSettings()
 * settings.base.shape = capsuleShapeHandle   // 角色碰撞形状（胶囊）
 * settings.base.maxSlopeAngle = 0.785        // 45°
 * let ch = PhysicsCharacterVirtual(system, settings, Vector3(0.0, 1.0, 0.0))
 * // 主循环：
 * ch.update(dt, layer)
 * ch.setLinearVelocity(walkDir * speed)
 * 说明：
 * - 底层句柄生命周期由本类管理（dispose() 销毁）。
 * - 角色本质是"形状 + 移动规则"，不直接与 Object3D 绑定；
 * 用户可在 update 后把 position 同步到 Mesh。
 * - 与 PhysicsWorld 的物理线程模型正交：角色更新建议在主线程调用，
 * Jolt 的 CharacterVirtual 内部使用 NarrowPhaseQuery（线程安全按 Jolt 约定）。
 *
 * @file[en] Character Character-controller convenience wrappers (three.physics.character sub-package)
 * @brief[en] Provides rigid-body and virtual character-controller wrappers
 * @explain[en] Provides a three-oriented character-control layer on top of the
 * Character/CharacterVirtual _cj wrappers in jolt4cj.jolt:
 * - PhysicsCharacter       : a rigid-body character (Character, driven by
 * gravity/collisions)
 * - PhysicsCharacterVirtual: a virtual character (CharacterVirtual, moved by
 * the user, recommended)
 * Typical usage (virtual character, first/third-person movement):
 * let settings = JPHCharacterVirtualSettings()
 * settings.base.shape = capsuleShapeHandle   // character collision shape (capsule)
 * settings.base.maxSlopeAngle = 0.785        // 45°
 * let ch = PhysicsCharacterVirtual(system, settings, Vector3(0.0, 1.0, 0.0))
 * // main loop:
 * ch.update(dt, layer)
 * ch.setLinearVelocity(walkDir * speed)
 * Notes:
 * - The underlying handle lifetime is managed by this class (disposed in dispose()).
 * - A character is essentially a "shape + movement rules" and is not directly
 * bound to an Object3D; you can sync its position to a Mesh after update.
 * - Orthogonal to the PhysicsWorld physics-thread model: character updates are
 * meant to be called on the main thread; Jolt's CharacterVirtual internally uses
 * a NarrowPhaseQuery (thread-safe per Jolt conventions).
 */
package three.physics.character

import three.core.math.*
import three.physics.interfaces.*
import jolt4cj.jolt.*

/**
 * @brief[zh-cn] 基于刚体的角色（对应 JPH_Character）
 * @explain[zh-cn] 使用胶囊/盒等形状作为角色碰撞体，加入物理系统后受重力驱动，
 * 通过 SetLinearVelocity 控制移动，碰撞由物理引擎处理。
 *
 * @brief[en] Rigid-body based character (corresponds to JPH_Character)
 * @explain[en] Uses a capsule/box shape as the character's collider. Once added to the
 * physics system it is driven by gravity; movement is controlled via
 * SetLinearVelocity and collisions are handled by the physics engine.
 */
public class PhysicsCharacter {
    /// 底层 JPH_Character 句柄
    private var _handle: CPointer<Unit> = CPointer<Unit>()
    /// 是否已销毁
    private var _disposed: Bool = false

    /**
     * @brief[zh-cn] 创建角色
     * @param[zh-cn] shape 角色碰撞形状句柄（JPH_Shape 句柄，由调用方创建并保持）
     * position 初始位置（世界坐标）
     * system 物理系统句柄（PhysicsWorld 内部 system，经 _getSystem 传入）
     * rotation 初始旋转（四元数）
     * layer 对象层（0 = NonMoving，1 = Moving）
     * mass 质量（千克）
     * maxSlopeAngle 最大可站立坡度角（弧度）
     *
     * @brief[en] Creates a character
     * @param[en] shape The character collision shape handle (a JPH_Shape handle created and kept by the caller)
     * position The initial position (world coordinates)
     * system The physics system handle (the internal PhysicsWorld system, passed via _getSystem)
     * rotation The initial rotation (quaternion)
     * layer The object layer (0 = NonMoving, 1 = Moving)
     * mass The mass (kilograms)
     * maxSlopeAngle The maximum standable slope angle (radians)
     */
    public init(shape: CPointer<Unit>, position: Vector3, system: CPointer<Unit>,
                rotation!: Quaternion = Quaternion(),
                layer!: UInt32 = 1,
                mass!: Float32 = 80.0f32,
                maxSlopeAngle!: Float32 = 0.7853982f32) {
        // 初始化角色设置
        let s = unsafe { LibC.malloc<JPHCharacterSettings>() }
        unsafe { JPH_CharacterSettings_Init_cj(s) }
        unsafe {
            var cs = s.read()
            cs.base.shape = shape
            cs.base.maxSlopeAngle = maxSlopeAngle
            cs.layer = layer
            cs.mass = mass
            s.write(cs)
        }
        let p = unsafe { LibC.malloc<JPHVec3>() }
        let q = unsafe { LibC.malloc<JPHQuat>() }
        unsafe {
            p.write(JPHVec3(
                x: Float32(position.x), y: Float32(position.y), z: Float32(position.z)))
            q.write(JPHQuat(
                x: Float32(rotation.x), y: Float32(rotation.y),
                z: Float32(rotation.z), w: Float32(rotation.w)))
        }
        this._handle = JPH_Character_Create_cj(s, p, q, 0, system)
        unsafe { LibC.free(s); LibC.free(p); LibC.free(q) }
    }

    /**
     * @brief[zh-cn] 是否创建成功（句柄有效且未销毁）
     * @return[zh-cn] 有效返回 true
     *
     * @brief[en] Whether the character was created successfully (handle valid and not disposed)
     * @return[en] true if valid
     */
    public func isValid(): Bool { return !this._disposed && !this._handle.isNull() }

    /**
     * @brief[zh-cn] 将角色添加到物理系统
     * @param[zh-cn] activation 是否激活角色（Activate/DontActivate）
     *
     * @brief[en] Adds the character to the physics system
     * @param[en] activation Whether to activate the character (Activate/DontActivate)
     */
    public func addToPhysicsSystem(activation: PhysicsActivation): Unit {
        if (!this.isValid()) { return }
        let act: UInt32 = match (activation) {
            case PhysicsActivation.Activate => 0
            case PhysicsActivation.DontActivate => 1
        }
        JPH_Character_AddToPhysicsSystem_cj(this._handle, act, 1)
    }

    /**
     * @brief[zh-cn] 从物理系统移除角色
     *
     * @brief[en] Removes the character from the physics system
     */
    public func removeFromPhysicsSystem(): Unit {
        if (!this.isValid()) { return }
        JPH_Character_RemoveFromPhysicsSystem_cj(this._handle, 1)
    }

    /**
     * @brief[zh-cn] 模拟后处理（检测地面接触，PhysicsWorld.update 后调用）
     * @param[zh-cn] maxSeparationDistance 最大分离距离（米），用于判定"是否离地"
     *
     * @brief[en] Post-simulation processing (detects ground contact; call after PhysicsWorld.update)
     * @param[en] maxSeparationDistance Maximum separation distance (meters) used to decide whether the character is on the ground
     */
    public func postSimulation(maxSeparationDistance: Float32): Unit {
        if (!this.isValid()) { return }
        JPH_Character_PostSimulation_cj(this._handle, maxSeparationDistance, 1)
    }

    /**
     * @brief[zh-cn] 设置角色线速度（控制移动）
     * @param[zh-cn] velocity 目标线速度（世界坐标方向）
     *
     * @brief[en] Sets the character's linear velocity (controls movement)
     * @param[en] velocity The target linear velocity (world-space direction)
     */
    public func setLinearVelocity(velocity: Vector3): Unit {
        if (!this.isValid()) { return }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            v.write(JPHVec3(
                x: Float32(velocity.x), y: Float32(velocity.y), z: Float32(velocity.z)))
        }
        JPH_Character_SetLinearVelocity_cj(this._handle, v, 1)
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 获取角色线速度
     * @return[zh-cn] 当前线速度（世界坐标）
     *
     * @brief[en] Gets the character's linear velocity
     * @return[en] The current linear velocity (world coordinates)
     */
    public func getLinearVelocity(): Vector3 {
        if (!this.isValid()) { return Vector3() }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        JPH_Character_GetLinearVelocity_cj(this._handle, v)
        let r = unsafe { v.read() }
        unsafe { LibC.free(v) }
        return Vector3(Float64(r.x), Float64(r.y), Float64(r.z))
    }

    /**
     * @brief[zh-cn] 获取角色位置
     * @return[zh-cn] 当前位置（世界坐标）
     *
     * @brief[en] Gets the character's position
     * @return[en] The current position (world coordinates)
     */
    public func getPosition(): Vector3 {
        if (!this.isValid()) { return Vector3() }
        let p = unsafe { LibC.malloc<JPHVec3>() }
        JPH_Character_GetPosition_cj(this._handle, p, 1)
        let r = unsafe { p.read() }
        unsafe { LibC.free(p) }
        return Vector3(Float64(r.x), Float64(r.y), Float64(r.z))
    }

    /**
     * @brief[zh-cn] 设置角色位置（瞬移）
     * @param[zh-cn] position 目标位置（世界坐标）
     * activation 是否激活角色（Activate/DontActivate）
     *
     * @brief[en] Sets the character's position (teleport)
     * @param[en] position The target position (world coordinates)
     * activation Whether to activate the character (Activate/DontActivate)
     */
    public func setPosition(position: Vector3,
                            activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        if (!this.isValid()) { return }
        let p = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            p.write(JPHVec3(
                x: Float32(position.x), y: Float32(position.y), z: Float32(position.z)))
        }
        let act: UInt32 = match (activation) {
            case PhysicsActivation.Activate => 0
            case PhysicsActivation.DontActivate => 1
        }
        JPH_Character_SetPosition_cj(this._handle, p, act, 1)
        unsafe { LibC.free(p) }
    }

    /**
     * @brief[zh-cn] 角色是否在地面上（OnGround）
     * @return[zh-cn] 在地面返回 true
     *
     * @brief[en] Whether the character is on the ground (OnGround)
     * @return[en] true if on the ground
     */
    public func isOnGround(): Bool {
        if (!this.isValid()) { return false }
        return JPH_CharacterBase_GetGroundState_cj(this._handle) == 0
    }

    /**
     * @brief[zh-cn] 获取地面状态（GroundState 枚举值）
     * @return[zh-cn] GroundState 枚举值（0 = OnGround）
     *
     * @brief[en] Gets the ground state (GroundState enum value)
     * @return[en] The GroundState enum value (0 = OnGround)
     */
    public func getGroundState(): UInt32 {
        if (!this.isValid()) { return 3 }
        return JPH_CharacterBase_GetGroundState_cj(this._handle)
    }

    /**
     * @brief[zh-cn] 销毁角色并释放底层句柄
     *
     * @brief[en] Disposes the character and frees the underlying handle
     */
    public func dispose(): Unit {
        if (this._disposed) { return }
        if (!this._handle.isNull()) {
            JPH_CharacterBase_Destroy_cj(this._handle)
            this._handle = CPointer<Unit>()
        }
        this._disposed = true
    }
}

/**
 * @brief[zh-cn] 虚拟角色（对应 JPH_CharacterVirtual）
 * @explain[zh-cn] 不直接受力，由用户控制移动（SetLinearVelocity），
 * 碰撞与穿透恢复由 Jolt 内部处理。推荐用于角色控制器。
 *
 * @brief[en] Virtual character (corresponds to JPH_CharacterVirtual)
 * @explain[en] Not directly driven by forces; movement is controlled by the user
 * (SetLinearVelocity), while collision and penetration recovery are handled
 * internally by Jolt. Recommended for character controllers.
 */
public class PhysicsCharacterVirtual {
    /// 底层 JPH_CharacterVirtual 句柄
    private var _handle: CPointer<Unit> = CPointer<Unit>()
    /// 是否已销毁
    private var _disposed: Bool = false

    /**
     * @brief[zh-cn] 创建虚拟角色
     * @param[zh-cn] shape 角色碰撞形状句柄（JPH_Shape 句柄，由调用方创建并保持）
     * position 初始位置（世界坐标）
     * system 物理系统句柄
     * rotation 初始旋转（四元数）
     * mass 质量（千克，用于冲量计算）
     * maxSlopeAngle 最大可站立坡度角（弧度）
     *
     * @brief[en] Creates a virtual character
     * @param[en] shape The character collision shape handle (a JPH_Shape handle created and kept by the caller)
     * position The initial position (world coordinates)
     * system The physics system handle
     * rotation The initial rotation (quaternion)
     * mass The mass (kilograms, used for impulse calculations)
     * maxSlopeAngle The maximum standable slope angle (radians)
     */
    public init(shape: CPointer<Unit>, position: Vector3, system: CPointer<Unit>,
                rotation!: Quaternion = Quaternion(),
                mass!: Float32 = 70.0f32,
                maxSlopeAngle!: Float32 = 0.7853982f32) {
        let s = unsafe { LibC.malloc<JPHCharacterVirtualSettings>() }
        unsafe { JPH_CharacterVirtualSettings_Init_cj(s) }
        unsafe {
            var cs = s.read()
            cs.base.shape = shape
            cs.base.maxSlopeAngle = maxSlopeAngle
            cs.mass = mass
            s.write(cs)
        }
        let p = unsafe { LibC.malloc<JPHVec3>() }
        let q = unsafe { LibC.malloc<JPHQuat>() }
        unsafe {
            p.write(JPHVec3(
                x: Float32(position.x), y: Float32(position.y), z: Float32(position.z)))
            q.write(JPHQuat(
                x: Float32(rotation.x), y: Float32(rotation.y),
                z: Float32(rotation.z), w: Float32(rotation.w)))
        }
        this._handle = JPH_CharacterVirtual_Create_cj(s, p, q, 0, system)
        unsafe { LibC.free(s); LibC.free(p); LibC.free(q) }
    }

    /**
     * @brief[zh-cn] 是否创建成功（句柄有效且未销毁）
     * @return[zh-cn] 有效返回 true
     *
     * @brief[en] Whether the virtual character was created successfully (handle valid and not disposed)
     * @return[en] true if valid
     */
    public func isValid(): Bool { return !this._disposed && !this._handle.isNull() }

    /**
     * @brief[zh-cn] 更新虚拟角色（每帧调用）
     * @param[zh-cn] deltaTime 时间步长（秒）
     * layer 对象层（角色移动时的碰撞层）
     * system 物理系统句柄
     *
     * @brief[en] Updates the virtual character (call every frame)
     * @param[en] deltaTime The time step (seconds)
     * layer The object layer (collision layer used while the character moves)
     * system The physics system handle
     */
    public func update(deltaTime: Float32, layer: UInt32, system: CPointer<Unit>): Unit {
        if (!this.isValid()) { return }
        JPH_CharacterVirtual_Update_cj(
            this._handle, deltaTime, layer, system,
            CPointer<Unit>(), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 设置虚拟角色线速度（控制移动）
     * @param[zh-cn] velocity 目标线速度（世界坐标方向）
     *
     * @brief[en] Sets the virtual character's linear velocity (controls movement)
     * @param[en] velocity The target linear velocity (world-space direction)
     */
    public func setLinearVelocity(velocity: Vector3): Unit {
        if (!this.isValid()) { return }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            v.write(JPHVec3(
                x: Float32(velocity.x), y: Float32(velocity.y), z: Float32(velocity.z)))
        }
        JPH_CharacterVirtual_SetLinearVelocity_cj(this._handle, v)
        unsafe { LibC.free(v) }
    }

    /**
     * @brief[zh-cn] 获取虚拟角色线速度
     * @return[zh-cn] 当前线速度（世界坐标）
     *
     * @brief[en] Gets the virtual character's linear velocity
     * @return[en] The current linear velocity (world coordinates)
     */
    public func getLinearVelocity(): Vector3 {
        if (!this.isValid()) { return Vector3() }
        let v = unsafe { LibC.malloc<JPHVec3>() }
        JPH_CharacterVirtual_GetLinearVelocity_cj(this._handle, v)
        let r = unsafe { v.read() }
        unsafe { LibC.free(v) }
        return Vector3(Float64(r.x), Float64(r.y), Float64(r.z))
    }

    /**
     * @brief[zh-cn] 获取虚拟角色位置
     * @return[zh-cn] 当前位置（世界坐标）
     *
     * @brief[en] Gets the virtual character's position
     * @return[en] The current position (world coordinates)
     */
    public func getPosition(): Vector3 {
        if (!this.isValid()) { return Vector3() }
        let p = unsafe { LibC.malloc<JPHVec3>() }
        JPH_CharacterVirtual_GetPosition_cj(this._handle, p)
        let r = unsafe { p.read() }
        unsafe { LibC.free(p) }
        return Vector3(Float64(r.x), Float64(r.y), Float64(r.z))
    }

    /**
     * @brief[zh-cn] 设置虚拟角色位置（瞬移）
     * @param[zh-cn] position 目标位置（世界坐标）
     *
     * @brief[en] Sets the virtual character's position (teleport)
     * @param[en] position The target position (world coordinates)
     */
    public func setPosition(position: Vector3): Unit {
        if (!this.isValid()) { return }
        let p = unsafe { LibC.malloc<JPHVec3>() }
        unsafe {
            p.write(JPHVec3(
                x: Float32(position.x), y: Float32(position.y), z: Float32(position.z)))
        }
        JPH_CharacterVirtual_SetPosition_cj(this._handle, p)
        unsafe { LibC.free(p) }
    }

    /**
     * @brief[zh-cn] 角色是否在地面上（OnGround）
     * @return[zh-cn] 在地面返回 true
     *
     * @brief[en] Whether the virtual character is on the ground (OnGround)
     * @return[en] true if on the ground
     */
    public func isOnGround(): Bool {
        if (!this.isValid()) { return false }
        return JPH_CharacterBase_GetGroundState_cj(this._handle) == 0
    }

    /**
     * @brief[zh-cn] 获取地面状态（GroundState 枚举值）
     * @return[zh-cn] GroundState 枚举值（0 = OnGround）
     *
     * @brief[en] Gets the ground state (GroundState enum value)
     * @return[en] The GroundState enum value (0 = OnGround)
     */
    public func getGroundState(): UInt32 {
        if (!this.isValid()) { return 3 }
        return JPH_CharacterBase_GetGroundState_cj(this._handle)
    }

    /**
     * @brief[zh-cn] 销毁虚拟角色并释放底层句柄
     *
     * @brief[en] Disposes the virtual character and frees the underlying handle
     */
    public func dispose(): Unit {
        if (this._disposed) { return }
        if (!this._handle.isNull()) {
            JPH_CharacterBase_Destroy_cj(this._handle)
            this._handle = CPointer<Unit>()
        }
        this._disposed = true
    }
}
