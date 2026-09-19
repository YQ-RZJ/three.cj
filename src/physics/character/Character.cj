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
 * @file[zh-cn] Character 角色控制器高级封装（three.physics.character 子包）
 * @brief[zh-cn] 在 jolt4cj.jolt 的 Character/CharacterVirtual _cj 包装之上提供
 * 面向 three 的角色控制层
 * @explain[zh-cn] 公开类型（公共 API 不出现任何指针）：
 * - PhysicsCharacterDesc    ：角色描述（形状/位姿/层/质量/最大坡度角）
 * - PhysicsCharacterFactory ：在物理世界中创建角色的工厂
 * - PhysicsCharacter        ：基于刚体的角色（JPH_Character，受重力/碰撞驱动）
 * - PhysicsCharacterVirtual ：虚拟角色（JPH_CharacterVirtual，由用户设置速度、
 *   Jolt 处理碰撞与穿透恢复，推荐用于角色控制器）
 * 坐标系：全部使用 three 左手系（Vector3/Quaternion），底层 Jolt 右手系转换由模块
 * 内部 JoltNative 工具完成。
 * 线程模型：所有运行时 FFI 调用经 PhysicsWorld 物理线程序列化执行（execPhysics），
 * 与布娃娃/车辆/软体等高级封装一致——Jolt 的 CharacterVirtual::Update 使用
 * NarrowPhaseQuery，必须在物理步进之外、且与物理线程串行调用。
 * 典型用法（虚拟角色）：
 * let desc = PhysicsCharacterDesc(shape: PhysicsShape.capsule(0.4, 0.3),
 *     position: Vector3(0.0, 1.0, 0.0))
 * let ch = PhysicsCharacterFactory(desc).createVirtualCharacter(world)
 * // 每帧（physicsWorld.update 之后）：
 * ch.setLinearVelocity(walkDir * speed)
 * ch.update(dt)
 * let p = ch.getPosition()   // 同步给 Mesh
 * // 不用时：ch.dispose()
 *
 * @file[en] Character high-level character-controller wrappers (three.physics.character sub-package)
 * @brief[en] Provides a three-oriented character-control layer on top of the
 * Character/CharacterVirtual _cj wrappers in jolt4cj.jolt
 * @explain[en] Public types (no pointers in the public API):
 * - PhysicsCharacterDesc    : character description (shape/pose/layer/mass/max slope)
 * - PhysicsCharacterFactory : factory creating characters inside a physics world
 * - PhysicsCharacter        : rigid-body character (JPH_Character, gravity/collision driven)
 * - PhysicsCharacterVirtual : virtual character (JPH_CharacterVirtual; the user sets
 *   velocity while Jolt handles collisions and penetration recovery — recommended)
 * Coordinates: all three left-handed (Vector3/Quaternion); conversion to the Jolt
 * right-handed system is done by the internal JoltNative utilities.
 * Threading: all runtime FFI calls are serialized onto the PhysicsWorld physics thread
 * (execPhysics), matching the ragdoll/vehicle/soft-body wrappers — Jolt's
 * CharacterVirtual::Update uses a NarrowPhaseQuery and must run outside the physics
 * step but serialized with it.
 */
package three.physics.character

import three.core.math.*
import three.physics.*
import three.physics.interfaces.*
import three.physics.backend.*
import three.physics.world.*
import jolt4cj.jolt.*
import three.utils.log.*
import three.utils.log.macros.*

// =============================================================================
// 内部枚举映射辅助
// =============================================================================

/// three 激活策略 → JPH Activation 数值（Activate=0/DontActivate=1）
internal func charActivationValue(a: PhysicsActivation): UInt32 {
    match (a) {
        case PhysicsActivation.Activate => 0
        case PhysicsActivation.DontActivate => 1
    }
}

// =============================================================================
// PhysicsCharacterDesc 角色描述
// =============================================================================

/**
 * @brief[zh-cn] 角色控制器描述
 * @explain[zh-cn] shape 常用胶囊（PhysicsShape.capsule）；position/rotation 为世界
 * 空间初始位姿（three 左手系）；layer 为对象层（1 = Moving，角色默认）。
 *
 * @brief[en] Character-controller description
 * @explain[en] shape is usually a capsule (PhysicsShape.capsule); position/rotation is
 * the world-space initial pose (three left-handed); layer is the object layer
 * (1 = Moving, the character default).
 */
public class PhysicsCharacterDesc {
    /**
     * @brief[zh-cn] 角色碰撞形状（通常为胶囊）
     *
     * @brief[en] The character collision shape (usually a capsule)
     */
    public let shape: PhysicsShape

    /**
     * @brief[zh-cn] 初始位置（世界空间，three 左手系）
     *
     * @brief[en] The initial position (world space, three left-handed)
     */
    public var position: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 初始旋转
     *
     * @brief[en] The initial rotation
     */
    public var rotation: Quaternion = Quaternion()

    /**
     * @brief[zh-cn] 对象层（0 = NonMoving，1 = Moving）
     *
     * @brief[en] The object layer (0 = NonMoving, 1 = Moving)
     */
    public var layer: UInt32 = 1

    /**
     * @brief[zh-cn] 质量（千克，用于冲量计算）
     *
     * @brief[en] The mass (kilograms, used for impulse calculations)
     */
    public var mass: Float32 = 70.0f32

    /**
     * @brief[zh-cn] 最大可站立坡度角（弧度，默认 π/4 = 45°）
     *
     * @brief[en] The maximum standable slope angle (radians; default PI/4 = 45 deg)
     */
    public var maxSlopeAngle: Float32 = 0.7853982f32

    /**
     * @brief[zh-cn] 创建角色描述
     * @param[zh-cn] shape 碰撞形状
     * position 初始位置
     * rotation 初始旋转
     * layer 对象层
     * mass 质量（千克）
     * maxSlopeAngle 最大可站立坡度角（弧度）
     *
     * @brief[en] Creates a character description
     * @param[en] shape The collision shape
     * position The initial position
     * rotation The initial rotation
     * layer The object layer
     * mass The mass (kilograms)
     * maxSlopeAngle The maximum standable slope angle (radians)
     */
    public init(shape!: PhysicsShape, position!: Vector3 = Vector3(),
        rotation!: Quaternion = Quaternion(), layer!: UInt32 = 1,
        mass!: Float32 = 70.0f32, maxSlopeAngle!: Float32 = 0.7853982f32) {
        this.shape = shape
        this.position = position
        this.rotation = rotation
        this.layer = layer
        this.mass = mass
        this.maxSlopeAngle = maxSlopeAngle
    }
}

// =============================================================================
// PhysicsCharacterFactory 角色工厂
// =============================================================================

/**
 * @brief[zh-cn] 角色工厂
 * @explain[zh-cn] 在指定物理世界内创建角色（刚体角色或虚拟角色）。原生形状创建设置
 * 与坐标转换全部在物理线程内完成；失败（非 Jolt 后端等）返回 isValid=false 的对象。
 *
 * @brief[en] Character factory
 * @explain[en] Creates characters (rigid or virtual) in the given physics world. Native
 * shape creation and coordinate conversion all happen on the physics thread; on failure
 * (e.g. a non-Jolt backend) returns an object with isValid=false.
 */
public class PhysicsCharacterFactory {
    private let _desc: PhysicsCharacterDesc

    /**
     * @brief[zh-cn] 构造角色工厂
     * @param[zh-cn] desc 角色描述
     *
     * @brief[en] Creates a character factory
     * @param[en] desc The character description
     */
    public init(desc!: PhysicsCharacterDesc) {
        this._desc = desc
    }

    /**
     * @brief[zh-cn] 创建基于刚体的角色（JPH_Character）
     * @explain[zh-cn] 返回后尚未加入物理系统，需调用 addToPhysicsSystem()。
     * @param[zh-cn] world 目标物理世界
     * @return[zh-cn] 刚体角色
     *
     * @brief[en] Creates a rigid-body character (JPH_Character)
     * @explain[en] Not yet added to the physics system — call addToPhysicsSystem().
     * @param[en] world The target physics world
     * @return[en] The rigid-body character
     */
    public func createCharacter(world: PhysicsWorld): PhysicsCharacter {
        let d = this._desc
        return world.execPhysicsResult<PhysicsCharacter>({
            =>
            match (world.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (system.isNull()) {
                        PhysicsCharacter(world: world, handle: CPointer<Unit>(), layer: d.layer)
                    } else {
                        // 形状：创建原生形状 → 设置给角色 → 释放本地引用（角色内部 AddRef）
                        let shp = jb.createNativeShape(d.shape)
                        if (shp.isNull()) {
                            @LogError(["PhysicsCharacterFactory", "角色形状创建失败"])
                            PhysicsCharacter(world: world, handle: CPointer<Unit>(), layer: d.layer)
                        } else {
                            let s = unsafe { LibC.malloc<JPHCharacterSettings>() }
                            unsafe { JPH_CharacterSettings_Init_cj(s) }
                            unsafe {
                                var cs = s.read()
                                cs.base.shape = shp
                                cs.base.maxSlopeAngle = d.maxSlopeAngle
                                cs.layer = d.layer
                                cs.mass = d.mass
                                s.write(cs)
                            }
                            let p = JoltNative.allocVec3(d.position)
                            let q = JoltNative.allocQuat(d.rotation)
                            let handle = JPH_Character_Create_cj(s, p, q, 0u64, system)
                            unsafe {
                                LibC.free(s)
                                LibC.free(p)
                                LibC.free(q)
                            }
                            jb.destroyNativeShape(shp)
                            PhysicsCharacter(world: world, handle: handle, layer: d.layer)
                        }
                    }
                case _ =>
                    @LogWarn(["PhysicsCharacterFactory", "角色仅支持 Jolt 后端"])
                    PhysicsCharacter(world: world, handle: CPointer<Unit>(), layer: d.layer)
            }
        })
    }

    /**
     * @brief[zh-cn] 创建虚拟角色（JPH_CharacterVirtual）
     * @explain[zh-cn] 虚拟角色不占物理刚体，每帧调用 setLinearVelocity + update 即可
     * 行走；无需 addToPhysicsSystem。
     * @param[zh-cn] world 目标物理世界
     * @return[zh-cn] 虚拟角色
     *
     * @brief[en] Creates a virtual character (JPH_CharacterVirtual)
     * @explain[en] A virtual character owns no physics rigid body; call setLinearVelocity
     * + update every frame to walk. No addToPhysicsSystem is needed.
     * @param[en] world The target physics world
     * @return[en] The virtual character
     */
    public func createVirtualCharacter(world: PhysicsWorld): PhysicsCharacterVirtual {
        let d = this._desc
        return world.execPhysicsResult<PhysicsCharacterVirtual>({
            =>
            match (world.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (system.isNull()) {
                        PhysicsCharacterVirtual(world: world, handle: CPointer<Unit>(), layer: d.layer)
                    } else {
                        let shp = jb.createNativeShape(d.shape)
                        if (shp.isNull()) {
                            @LogError(["PhysicsCharacterFactory", "虚拟角色形状创建失败"])
                            PhysicsCharacterVirtual(world: world, handle: CPointer<Unit>(), layer: d.layer)
                        } else {
                            let s = unsafe { LibC.malloc<JPHCharacterVirtualSettings>() }
                            unsafe { JPH_CharacterVirtualSettings_Init_cj(s) }
                            unsafe {
                                var cs = s.read()
                                cs.base.shape = shp
                                cs.base.maxSlopeAngle = d.maxSlopeAngle
                                cs.mass = d.mass
                                s.write(cs)
                            }
                            let p = JoltNative.allocVec3(d.position)
                            let q = JoltNative.allocQuat(d.rotation)
                            let handle = JPH_CharacterVirtual_Create_cj(s, p, q, 0u64, system)
                            unsafe {
                                LibC.free(s)
                                LibC.free(p)
                                LibC.free(q)
                            }
                            jb.destroyNativeShape(shp)
                            PhysicsCharacterVirtual(world: world, handle: handle, layer: d.layer)
                        }
                    }
                case _ =>
                    @LogWarn(["PhysicsCharacterFactory", "角色仅支持 Jolt 后端"])
                    PhysicsCharacterVirtual(world: world, handle: CPointer<Unit>(), layer: d.layer)
            }
        })
    }
}

// =============================================================================
// PhysicsCharacter 基于刚体的角色
// =============================================================================

/**
 * @brief[zh-cn] 基于刚体的角色（对应 JPH_Character）
 * @explain[zh-cn] 使用胶囊/盒等形状作为角色碰撞体，加入物理系统后受重力驱动，
 * 通过 setLinearVelocity 控制移动，碰撞由物理引擎处理。流程：
 * factory.createCharacter → addToPhysicsSystem → 每帧物理步进后 postSimulation →
 * getPosition/isOnGround → dispose。
 *
 * @brief[en] Rigid-body based character (corresponds to JPH_Character)
 * @explain[en] Uses a capsule/box shape as the collider. Once added to the physics
 * system it is driven by gravity; movement is controlled via setLinearVelocity and
 * collisions are handled by the physics engine. Flow:
 * factory.createCharacter → addToPhysicsSystem → postSimulation after each physics
 * step → getPosition/isOnGround → dispose.
 */
public class PhysicsCharacter {
    private let _world: PhysicsWorld
    private var _handle: CPointer<Unit> = CPointer<Unit>()
    private let _layer: UInt32
    private var _disposed: Bool = false

    internal init(world!: PhysicsWorld, handle!: CPointer<Unit>, layer!: UInt32) {
        this._world = world
        this._handle = handle
        this._layer = layer
    }

    /**
     * @brief[zh-cn] 角色是否有效（创建成功且未销毁）
     *
     * @brief[en] Whether the character is valid (created successfully and not disposed)
     */
    public prop isValid: Bool {
        get() {
            !this._disposed && !this._handle.isNull()
        }
    }

    /**
     * @brief[zh-cn] 将角色加入物理系统
     * @param[zh-cn] activation 是否立即激活（默认 Activate）
     *
     * @brief[en] Adds the character to the physics system
     * @param[en] activation Whether to activate immediately (default Activate)
     */
    public func addToPhysicsSystem(activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        if (!this.isValid) {
            return
        }
        let w = this._world
        let h = this._handle
        let act = charActivationValue(activation)
        w.execPhysics({
            => JPH_Character_AddToPhysicsSystem_cj(h, act, 1u8)
        })
    }

    /**
     * @brief[zh-cn] 从物理系统移除角色（可再次 addToPhysicsSystem 加入）
     *
     * @brief[en] Removes the character from the physics system (can be re-added)
     */
    public func removeFromPhysicsSystem(): Unit {
        if (!this.isValid) {
            return
        }
        let w = this._world
        let h = this._handle
        w.execPhysics({
            => JPH_Character_RemoveFromPhysicsSystem_cj(h, 1u8)
        })
    }

    /**
     * @brief[zh-cn] 模拟后处理（检测地面接触）
     * @explain[zh-cn] 必须在 PhysicsWorld.update 之后调用，之后 isOnGround/getGroundState
     * 才反映本帧结果。
     * @param[zh-cn] maxSeparationDistance 最大分离距离（米），默认 0.05
     *
     * @brief[en] Post-simulation processing (ground-contact detection)
     * @explain[en] Must be called after PhysicsWorld.update; only afterwards do
     * isOnGround/getGroundState reflect this frame.
     * @param[en] maxSeparationDistance Maximum separation distance (meters; default 0.05)
     */
    public func postSimulation(maxSeparationDistance!: Float32 = 0.05f32): Unit {
        if (!this.isValid) {
            return
        }
        let w = this._world
        let h = this._handle
        let sep = maxSeparationDistance
        w.execPhysics({
            => JPH_Character_PostSimulation_cj(h, sep, 1u8)
        })
    }

    /**
     * @brief[zh-cn] 设置角色线速度（控制移动）
     * @param[zh-cn] velocity 目标线速度（世界坐标，three 左手系）
     *
     * @brief[en] Sets the character's linear velocity (controls movement)
     * @param[en] velocity The target linear velocity (world space, three left-handed)
     */
    public func setLinearVelocity(velocity: Vector3): Unit {
        if (!this.isValid) {
            return
        }
        let w = this._world
        let h = this._handle
        w.execPhysics({
            =>
            let buf = JoltNative.allocVec3(velocity)
            JPH_Character_SetLinearVelocity_cj(h, buf, 1u8)
            unsafe { LibC.free(buf) }
        })
    }

    /**
     * @brief[zh-cn] 获取角色线速度
     * @return[zh-cn] 当前线速度（世界坐标，three 左手系）
     *
     * @brief[en] Gets the character's linear velocity
     * @return[en] The current linear velocity (world space, three left-handed)
     */
    public func getLinearVelocity(): Vector3 {
        if (!this.isValid) {
            return Vector3()
        }
        let w = this._world
        let h = this._handle
        return w.execPhysicsResult<Vector3>({
            =>
            let buf = unsafe { LibC.malloc<JPHVec3>() }
            JPH_Character_GetLinearVelocity_cj(h, buf)
            let v = JoltNative.readVec3(buf)
            unsafe { LibC.free(buf) }
            v
        })
    }

    /**
     * @brief[zh-cn] 获取角色位置
     * @return[zh-cn] 当前位置（世界坐标，three 左手系）
     *
     * @brief[en] Gets the character's position
     * @return[en] The current position (world space, three left-handed)
     */
    public func getPosition(): Vector3 {
        if (!this.isValid) {
            return Vector3()
        }
        let w = this._world
        let h = this._handle
        return w.execPhysicsResult<Vector3>({
            =>
            let buf = unsafe { LibC.malloc<JPHVec3>() }
            JPH_Character_GetPosition_cj(h, buf, 1u8)
            let v = JoltNative.readVec3(buf)
            unsafe { LibC.free(buf) }
            v
        })
    }

    /**
     * @brief[zh-cn] 设置角色位置（瞬移）
     * @param[zh-cn] position 目标位置（世界坐标，three 左手系）
     * activation 是否立即激活（默认 Activate）
     *
     * @brief[en] Sets the character's position (teleport)
     * @param[en] position The target position (world space, three left-handed)
     * activation Whether to activate immediately (default Activate)
     */
    public func setPosition(position: Vector3,
        activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        if (!this.isValid) {
            return
        }
        let w = this._world
        let h = this._handle
        let act = charActivationValue(activation)
        w.execPhysics({
            =>
            let buf = JoltNative.allocVec3(position)
            JPH_Character_SetPosition_cj(h, buf, act, 1u8)
            unsafe { LibC.free(buf) }
        })
    }

    /**
     * @brief[zh-cn] 角色是否在地面上（GroundState == OnGround）
     * @note[zh-cn] 需先调用 postSimulation 刷新地面状态
     *
     * @brief[en] Whether the character is on the ground (GroundState == OnGround)
     * @note[en] Call postSimulation first to refresh the ground state
     */
    public func isOnGround(): Bool {
        if (!this.isValid) {
            return false
        }
        return this.getGroundState() == 0
    }

    /**
     * @brief[zh-cn] 获取地面状态（0 = OnGround，1 = OnSteepGround，2 = NotSupported，3 = InAir）
     *
     * @brief[en] Gets the ground state (0 = OnGround, 1 = OnSteepGround, 2 = NotSupported, 3 = InAir)
     */
    public func getGroundState(): UInt32 {
        if (!this.isValid) {
            return 3
        }
        let w = this._world
        let h = this._handle
        return w.execPhysicsResult<UInt32>({
            => JPH_CharacterBase_GetGroundState_cj(h)
        })
    }

    /**
     * @brief[zh-cn] 销毁角色（自动从物理系统移除并释放底层句柄）
     *
     * @brief[en] Disposes the character (auto-removes it from the physics system and frees the handle)
     */
    public func dispose(): Unit {
        if (this._disposed) {
            return
        }
        this._disposed = true
        if (!this._handle.isNull()) {
            let w = this._world
            let h = this._handle
            this._handle = CPointer<Unit>()
            w.execPhysics({
                =>
                JPH_Character_RemoveFromPhysicsSystem_cj(h, 1u8)
                JPH_CharacterBase_Destroy_cj(h)
            })
        }
    }
}

// =============================================================================
// PhysicsCharacterVirtual 虚拟角色
// =============================================================================

/**
 * @brief[zh-cn] 虚拟角色（对应 JPH_CharacterVirtual）
 * @explain[zh-cn] 不直接受力，由用户通过 setLinearVelocity 控制移动，重力积分、
 * 碰撞与穿透恢复由 Jolt 在 update 内处理。推荐用于角色控制器。每帧流程
 * （在 PhysicsWorld.update 之后）：setLinearVelocity → update(dt) →
 * getPosition/isOnGround。
 *
 * @brief[en] Virtual character (corresponds to JPH_CharacterVirtual)
 * @explain[en] Not directly driven by forces; the user controls movement via
 * setLinearVelocity, while gravity integration, collisions and penetration recovery
 * are handled inside update by Jolt. Recommended for character controllers. Per-frame
 * flow (after PhysicsWorld.update): setLinearVelocity → update(dt) →
 * getPosition/isOnGround.
 */
public class PhysicsCharacterVirtual {
    private let _world: PhysicsWorld
    private var _handle: CPointer<Unit> = CPointer<Unit>()
    private let _layer: UInt32
    private var _disposed: Bool = false

    internal init(world!: PhysicsWorld, handle!: CPointer<Unit>, layer!: UInt32) {
        this._world = world
        this._handle = handle
        this._layer = layer
    }

    /**
     * @brief[zh-cn] 虚拟角色是否有效（创建成功且未销毁）
     *
     * @brief[en] Whether the virtual character is valid (created successfully and not disposed)
     */
    public prop isValid: Bool {
        get() {
            !this._disposed && !this._handle.isNull()
        }
    }

    /**
     * @brief[zh-cn] 更新虚拟角色（每帧在 PhysicsWorld.update 之后调用）
     * @explain[zh-cn] Jolt 的 CharacterVirtual::Update 只做形状扫掠移动，自身不积分
     * 重力（重力仅用于给地面刚体施冲量），因此本方法在同一物理线程闭包内先对竖直
     * 速度做 v += gravity * dt 再调用 Update。碰撞层取创建时的 layer。
     * @param[zh-cn] deltaTime 时间步长（秒）
     * gravity 重力向量（默认 (0,-9.81,0)，与物理世界一致；水平移动请在调用前
     * 用 setLinearVelocity 设置，竖直分量会被本方法保留并叠加重力）
     *
     * @brief[en] Updates the virtual character (call every frame after PhysicsWorld.update)
     * @explain[en] Jolt's CharacterVirtual::Update only sweeps the shape and does not
     * integrate gravity itself (gravity is only used to apply an impulse to the ground
     * body), so this method first applies v += gravity * dt to the vertical velocity in
     * the same physics-thread closure and then calls Update. The collision layer is the
     * one given at creation.
     * @param[en] deltaTime The time step (seconds)
     * gravity The gravity vector (default (0,-9.81,0), matching the physics world; set
     * horizontal movement with setLinearVelocity beforehand — the vertical component is
     * preserved and gravity is added on top)
     */
    public func update(deltaTime: Float32, gravity!: Vector3 = Vector3(0.0, -9.81, 0.0)): Unit {
        if (!this.isValid) {
            return
        }
        let w = this._world
        let h = this._handle
        let layer = this._layer
        let dt = deltaTime
        let g = gravity
        w.execPhysics({
            =>
            match (w.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (!system.isNull()) {
                        // 重力积分：v.y += g.y * dt（水平分量保持用户设置的速度）
                        let vbuf = unsafe { LibC.malloc<JPHVec3>() }
                        JPH_CharacterVirtual_GetLinearVelocity_cj(h, vbuf)
                        let v = JoltNative.readVec3(vbuf)
                        let nv = Vector3(v.x, v.y + g.y * Float64(dt), v.z)
                        let nbuf = JoltNative.allocVec3(nv)
                        JPH_CharacterVirtual_SetLinearVelocity_cj(h, nbuf)
                        unsafe {
                            LibC.free(vbuf)
                            LibC.free(nbuf)
                        }
                        JPH_CharacterVirtual_Update_cj(h, dt, layer, system,
                            CPointer<Unit>(), CPointer<Unit>())
                    }
                case _ => ()
            }
        })
    }

    /**
     * @brief[zh-cn] 设置虚拟角色线速度（控制移动）
     * @param[zh-cn] velocity 目标线速度（世界坐标，three 左手系）
     *
     * @brief[en] Sets the virtual character's linear velocity (controls movement)
     * @param[en] velocity The target linear velocity (world space, three left-handed)
     */
    public func setLinearVelocity(velocity: Vector3): Unit {
        if (!this.isValid) {
            return
        }
        let w = this._world
        let h = this._handle
        w.execPhysics({
            =>
            let buf = JoltNative.allocVec3(velocity)
            JPH_CharacterVirtual_SetLinearVelocity_cj(h, buf)
            unsafe { LibC.free(buf) }
        })
    }

    /**
     * @brief[zh-cn] 获取虚拟角色线速度
     * @return[zh-cn] 当前线速度（世界坐标，three 左手系）
     *
     * @brief[en] Gets the virtual character's linear velocity
     * @return[en] The current linear velocity (world space, three left-handed)
     */
    public func getLinearVelocity(): Vector3 {
        if (!this.isValid) {
            return Vector3()
        }
        let w = this._world
        let h = this._handle
        return w.execPhysicsResult<Vector3>({
            =>
            let buf = unsafe { LibC.malloc<JPHVec3>() }
            JPH_CharacterVirtual_GetLinearVelocity_cj(h, buf)
            let v = JoltNative.readVec3(buf)
            unsafe { LibC.free(buf) }
            v
        })
    }

    /**
     * @brief[zh-cn] 获取虚拟角色位置
     * @return[zh-cn] 当前位置（世界坐标，three 左手系）
     *
     * @brief[en] Gets the virtual character's position
     * @return[en] The current position (world space, three left-handed)
     */
    public func getPosition(): Vector3 {
        if (!this.isValid) {
            return Vector3()
        }
        let w = this._world
        let h = this._handle
        return w.execPhysicsResult<Vector3>({
            =>
            let buf = unsafe { LibC.malloc<JPHVec3>() }
            JPH_CharacterVirtual_GetPosition_cj(h, buf)
            let v = JoltNative.readVec3(buf)
            unsafe { LibC.free(buf) }
            v
        })
    }

    /**
     * @brief[zh-cn] 设置虚拟角色位置（瞬移）
     * @param[zh-cn] position 目标位置（世界坐标，three 左手系）
     *
     * @brief[en] Sets the virtual character's position (teleport)
     * @param[en] position The target position (world space, three left-handed)
     */
    public func setPosition(position: Vector3): Unit {
        if (!this.isValid) {
            return
        }
        let w = this._world
        let h = this._handle
        w.execPhysics({
            =>
            let buf = JoltNative.allocVec3(position)
            JPH_CharacterVirtual_SetPosition_cj(h, buf)
            unsafe { LibC.free(buf) }
        })
    }

    /**
     * @brief[zh-cn] 虚拟角色是否在地面上（GroundState == OnGround）
     * @note[zh-cn] update 之后本帧地面状态即有效
     *
     * @brief[en] Whether the virtual character is on the ground (GroundState == OnGround)
     * @note[en] The ground state is valid for this frame after update
     */
    public func isOnGround(): Bool {
        if (!this.isValid) {
            return false
        }
        return this.getGroundState() == 0
    }

    /**
     * @brief[zh-cn] 获取地面状态（0 = OnGround，1 = OnSteepGround，2 = NotSupported，3 = InAir）
     *
     * @brief[en] Gets the ground state (0 = OnGround, 1 = OnSteepGround, 2 = NotSupported, 3 = InAir)
     */
    public func getGroundState(): UInt32 {
        if (!this.isValid) {
            return 3
        }
        let w = this._world
        let h = this._handle
        return w.execPhysicsResult<UInt32>({
            => JPH_CharacterBase_GetGroundState_cj(h)
        })
    }

    /**
     * @brief[zh-cn] 销毁虚拟角色并释放底层句柄
     *
     * @brief[en] Disposes the virtual character and frees the underlying handle
     */
    public func dispose(): Unit {
        if (this._disposed) {
            return
        }
        this._disposed = true
        if (!this._handle.isNull()) {
            let w = this._world
            let h = this._handle
            this._handle = CPointer<Unit>()
            w.execPhysics({
                => JPH_CharacterBase_Destroy_cj(h)
            })
        }
    }
}
