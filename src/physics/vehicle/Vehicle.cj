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
 * @file[zh-cn] Vehicle 轮式载具高层封装（three.physics.vehicle 子包）
 * @brief[zh-cn] 在 jolt4cj 的 VehicleConstraint/WheeledVehicleController FFI 之上，
 * 提供面向 three 的轮式载具物理层
 * @explain[zh-cn] 载具 = 底盘刚体 + 车辆约束（车轮悬挂/轮胎/引擎/变速箱/差速器）。
 * 车轮在 Jolt 中基于射线检测（非独立刚体），由 VehicleConstraint 作为 PhysicsStepListener
 * 在每个物理步内驱动。所有公开 API 使用 three 左手系数学类型（无指针暴露），
 * 运行时 FFI 调用经 PhysicsWorld 序列化到物理线程执行。
 *
 * @file[en] Vehicle high-level wrapper (three.physics.vehicle sub-package)
 * @brief[en] Provides a three-oriented wheeled-vehicle physics layer on top of the
 * jolt4cj VehicleConstraint/WheeledVehicleController FFI
 * @explain[en] A vehicle = chassis body + vehicle constraint (wheel suspension/tires/
 * engine/transmission/differentials). Wheels in Jolt are raycast-based (not separate
 * bodies) and driven by the VehicleConstraint acting as a PhysicsStepListener each
 * physics step. All public APIs use three left-handed math types (no pointers exposed).
 * Runtime FFI calls are serialized onto the PhysicsWorld physics thread.
 */
package three.physics.vehicle

import std.collection.ArrayList
import three.core.math.*
import three.physics.*
import three.physics.interfaces.*
import three.physics.backend.*
import three.physics.world.*
import jolt4cj.jolt.*
import three.utils.log.Logger

// =============================================================================
// PhysicsVehicleWheelDesc 车轮描述
// =============================================================================

/**
 * @brief[zh-cn] 轮式载具车轮描述
 * @explain[zh-cn] 描述一个车轮的安装位置、尺寸、悬挂弹簧与轮胎参数。
 * position 为底盘局部空间坐标（three 左手系，创建时自动转换为 Jolt 右手系）。
 *
 * @brief[en] Wheel description of a wheeled vehicle
 * @explain[en] Describes a wheel's mount position, size, suspension spring and tire
 * parameters. position is in chassis local space (three left-handed; converted to the
 * Jolt right-handed system automatically at creation).
 */
public class PhysicsVehicleWheelDesc {
    /**
     * @brief[zh-cn] 车轮安装位置（底盘局部空间）
     *
     * @brief[en] Wheel mount position (chassis local space)
     */
    public var position: Vector3 = Vector3(0.0, 0.0, 0.0)

    /**
     * @brief[zh-cn] 车轮半径（米）
     *
     * @brief[en] Wheel radius (meters)
     */
    public var radius: Float64 = 0.3

    /**
     * @brief[zh-cn] 车轮宽度（米）
     *
     * @brief[en] Wheel width (meters)
     */
    public var width: Float64 = 0.2

    /**
     * @brief[zh-cn] 悬挂最小长度（米，完全压缩）
     *
     * @brief[en] Suspension minimum length (meters, fully compressed)
     */
    public var suspensionMinLength: Float64 = 0.3

    /**
     * @brief[zh-cn] 悬挂最大长度（米，完全伸展）
     *
     * @brief[en] Suspension maximum length (meters, fully extended)
     */
    public var suspensionMaxLength: Float64 = 0.5

    /**
     * @brief[zh-cn] 悬挂自然频率（Hz，mode=Frequency）
     *
     * @brief[en] Suspension natural frequency (Hz, mode=Frequency)
     */
    public var suspensionFrequency: Float64 = 1.5

    /**
     * @brief[zh-cn] 悬挂阻尼比（0~1）
     *
     * @brief[en] Suspension damping ratio (0~1)
     */
    public var suspensionDamping: Float64 = 0.5

    /**
     * @brief[zh-cn] 最大转向角（弧度；0 表示不转向）
     *
     * @brief[en] Maximum steer angle (radians; 0 = no steering)
     */
    public var maxSteerAngle: Float64 = 0.0

    /**
     * @brief[zh-cn] 最大刹车力矩（牛顿·米）
     *
     * @brief[en] Maximum brake torque (N·m)
     */
    public var maxBrakeTorque: Float64 = 1500.0

    /**
     * @brief[zh-cn] 最大手刹力矩（牛顿·米；0 表示不响应手刹）
     *
     * @brief[en] Maximum hand-brake torque (N·m; 0 = no hand-brake response)
     */
    public var maxHandBrakeTorque: Float64 = 0.0

    /**
     * @brief[zh-cn] 轮胎横向摩擦系数
     *
     * @brief[en] Tire lateral friction coefficient
     */
    public var lateralFriction: Float64 = 1.0

    /**
     * @brief[zh-cn] 轮胎纵向摩擦系数
     *
     * @brief[en] Tire longitudinal friction coefficient
     */
    public var longitudinalFriction: Float64 = 1.0

    /**
     * @brief[zh-cn] 车轮转动惯量
     *
     * @brief[en] Wheel rotational inertia
     */
    public var inertia: Float64 = 0.5

    /**
     * @brief[zh-cn] 车轮角阻尼
     *
     * @brief[en] Wheel angular damping
     */
    public var angularDamping: Float64 = 0.2

    /**
     * @brief[zh-cn] 构造车轮描述
     * @param[zh-cn] position 安装位置（底盘局部空间）
     *
     * @brief[en] Creates a wheel description
     * @param[en] position The mount position (chassis local space)
     */
    public init(position!: Vector3) {
        this.position = position
    }
}

// =============================================================================
// PhysicsVehicleEngineDesc 引擎/变速箱描述
// =============================================================================

/**
 * @brief[zh-cn] 轮式载具引擎与变速箱描述
 * @explain[zh-cn] 引擎提供扭矩曲线（简化为最大扭矩 + RPM 区间），变速箱为
 * 自动换挡模式（手动模式暂不暴露），档位比逐档配置。
 *
 * @brief[en] Engine and transmission description of a wheeled vehicle
 * @explain[en] The engine provides a torque curve (simplified to max torque + RPM
 * range); the transmission runs in auto-shift mode (manual mode not exposed yet) with
 * per-gear ratios.
 */
public class PhysicsVehicleEngineDesc {
    /**
     * @brief[zh-cn] 引擎最大扭矩（牛顿·米）
     *
     * @brief[en] Engine maximum torque (N·m)
     */
    public var maxTorque: Float64 = 500.0

    /**
     * @brief[zh-cn] 最小 RPM（低于此值怠速）
     *
     * @brief[en] Minimum RPM (idle below this value)
     */
    public var minRPM: Float64 = 1000.0

    /**
     * @brief[zh-cn] 最大 RPM（超过此值断油）
     *
     * @brief[en] Maximum RPM (fuel cut above this value)
     */
    public var maxRPM: Float64 = 6000.0

    /**
     * @brief[zh-cn] 前进档位比列表（索引 0 = 1 档）
     *
     * @brief[en] Forward gear ratios (index 0 = 1st gear)
     */
    public var gearRatios: ArrayList<Float64> = ArrayList<Float64>([2.66, 1.78, 1.3, 1.0])

    /**
     * @brief[zh-cn] 倒车档位比列表（正值，内部取反向）
     *
     * @brief[en] Reverse gear ratios (positive; reversed internally)
     */
    public var reverseGearRatios: ArrayList<Float64> = ArrayList<Float64>([2.9])

    /**
     * @brief[zh-cn] 升档转速（RPM）
     *
     * @brief[en] Shift-up RPM
     */
    public var shiftUpRPM: Float64 = 5000.0

    /**
     * @brief[zh-cn] 降档转速（RPM）
     *
     * @brief[en] Shift-down RPM
     */
    public var shiftDownRPM: Float64 = 2000.0

    /**
     * @brief[zh-cn] 换挡延迟（秒）
     *
     * @brief[en] Shift latency (seconds)
     */
    public var switchLatency: Float64 = 0.5

    /**
     * @brief[zh-cn] 换挡过渡时间（秒）
     *
     * @brief[en] Shift transition time (seconds)
     */
    public var switchTime: Float64 = 0.3

    /**
     * @brief[zh-cn] 离合器强度
     *
     * @brief[en] Clutch strength
     */
    public var clutchStrength: Float64 = 10.0

    /**
     * @brief[zh-cn] 构造引擎/变速箱描述
     *
     * @brief[en] Creates an engine/transmission description
     */
    public init() {}
}

// =============================================================================
// PhysicsVehicleDesc 载具描述
// =============================================================================

/**
 * @brief[zh-cn] 轮式载具描述
 * @explain[zh-cn] 汇总底盘刚体描述、车轮列表、引擎与差速器配置。
 * chassisDesc 的形状建议用车轮包围盒近似（Jolt 车轮为射线检测，底盘形状即整车碰撞体）。
 *
 * @brief[en] Wheeled vehicle description
 * @explain[en] Aggregates the chassis body description, wheel list, engine and
 * differential configuration. chassisDesc shape should roughly enclose the wheels
 * (Jolt wheels are raycast-based; the chassis shape is the whole vehicle collider).
 */
public class PhysicsVehicleDesc {
    /**
     * @brief[zh-cn] 底盘刚体描述（含形状/质量/摩擦等）
     *
     * @brief[en] Chassis body description (shape/mass/friction etc.)
     */
    public var chassisDesc: PhysicsBodyDesc

    /**
     * @brief[zh-cn] 车轮列表（索引即车轮索引）
     *
     * @brief[en] Wheel list (index = wheel index)
     */
    public var wheels: ArrayList<PhysicsVehicleWheelDesc> = ArrayList<PhysicsVehicleWheelDesc>()

    /**
     * @brief[zh-cn] 引擎与变速箱配置
     *
     * @brief[en] Engine and transmission configuration
     */
    public var engine: PhysicsVehicleEngineDesc = PhysicsVehicleEngineDesc()

    /**
     * @brief[zh-cn] 驱动车轮索引列表（差速器按此成对创建；空 = 全轮驱动单差速器）
     *
     * @brief[en] Driven wheel indices (differentials are created pairwise from this;
     * empty = single differential driving all wheels)
     */
    public var drivenWheels: ArrayList<Int64> = ArrayList<Int64>()

    /**
     * @brief[zh-cn] 最大俯仰/横滚角（弧度，0 = 不限制）
     *
     * @brief[en] Maximum pitch/roll angle (radians, 0 = unlimited)
     */
    public var maxPitchRollAngle: Float64 = 0.0

    /**
     * @brief[zh-cn] 构造载具描述
     * @param[zh-cn] chassisDesc 底盘刚体描述
     *
     * @brief[en] Creates a vehicle description
     * @param[en] chassisDesc The chassis body description
     */
    public init(chassisDesc!: PhysicsBodyDesc) {
        this.chassisDesc = chassisDesc
    }
}

// =============================================================================
// PhysicsVehicle 运行时载具
// =============================================================================

/**
 * @brief[zh-cn] 轮式载具运行时对象
 * @explain[zh-cn] 持有底盘刚体句柄与车辆约束原生句柄；驱动接口（油门/转向/刹车）、
 * 车轮世界矩阵查询与销毁均经 PhysicsWorld 序列化到物理线程执行。
 *
 * @brief[en] Runtime wheeled vehicle
 * @explain[en] Holds the chassis body handle and the native vehicle constraint handle;
 * driving APIs (throttle/steer/brake), wheel world-matrix queries and disposal are all
 * serialized onto the physics thread via PhysicsWorld.
 */
public class PhysicsVehicle {
    private let _world: PhysicsWorld
    private let _chassis: PhysicsBodyHandle
    private var _constraint: CPointer<Unit> = CPointer<Unit>()
    private var _controller: CPointer<Unit> = CPointer<Unit>()
    private let _wheelCount: Int64
    private var _disposed: Bool = false

    internal init(world!: PhysicsWorld, chassis!: PhysicsBodyHandle,
        constraint!: CPointer<Unit>, controller!: CPointer<Unit>, wheelCount!: Int64) {
        this._world = world
        this._chassis = chassis
        this._constraint = constraint
        this._controller = controller
        this._wheelCount = wheelCount
    }

    /**
     * @brief[zh-cn] 载具是否有效（创建成功且未销毁）
     *
     * @brief[en] Whether the vehicle is valid (created successfully and not disposed)
     */
    public prop isValid: Bool {
        get() {
            !this._disposed && !this._constraint.isNull()
        }
    }

    /**
     * @brief[zh-cn] 底盘刚体句柄（可进一步控制底盘）
     *
     * @brief[en] The chassis body handle (for further chassis control)
     */
    public prop chassis: PhysicsBodyHandle {
        get() {
            this._chassis
        }
    }

    /**
     * @brief[zh-cn] 车轮数量
     *
     * @brief[en] The wheel count
     */
    public prop wheelCount: Int64 {
        get() {
            this._wheelCount
        }
    }

    /**
     * @brief[zh-cn] 设置驾驶员输入（油门/转向/刹车/手刹）
     * @param[zh-cn] forward 油门（-1 倒车 ~ 1 前进）
     * steer 转向（-1 左 ~ 1 右）
     * brake 刹车（0 ~ 1）
     * handBrake 手刹（0 ~ 1）
     *
     * @brief[en] Sets the driver input (throttle/steer/brake/hand-brake)
     * @param[en] forward Throttle (-1 reverse ~ 1 forward)
     * steer Steering (-1 left ~ 1 right)
     * brake Brake (0 ~ 1)
     * handBrake Hand brake (0 ~ 1)
     */
    public func setDriverInput(forward: Float64, steer: Float64,
        brake!: Float64 = 0.0, handBrake!: Float64 = 0.0): Unit {
        if (!this.isValid) {
            return
        }
        let c = this._controller
        this._world.execPhysics({
            => JPH_WheeledVehicleController_SetDriverInput_cj(c,
                Float32(forward), Float32(steer), Float32(brake), Float32(handBrake))
        })
    }

    /**
     * @brief[zh-cn] 读取指定车轮的世界变换（用于渲染车轮网格）
     * @param[zh-cn] index 车轮索引
     * @return[zh-cn] 车轮世界矩阵（three 左手系）；无效索引返回单位矩阵
     *
     * @brief[en] Reads the world transform of a wheel (for rendering the wheel mesh)
     * @param[en] index The wheel index
     * @return[en] The wheel world matrix (three left-handed); identity for an invalid index
     */
    public func getWheelWorldTransform(index: Int64): Matrix4 {
        if (!this.isValid || index < 0 || index >= this._wheelCount) {
            return Matrix4()
        }
        let c = this._constraint
        let idx = UInt32(index)
        return this._world.execPhysicsResult<Matrix4>({
            =>
            // 车轮右/上方向取 Jolt 默认约定（1,0,0)/(0,1,0)，无需额外换算
            let right = JoltNative.allocVec3Raw(Vector3(1.0, 0.0, 0.0))
            let up = JoltNative.allocVec3Raw(Vector3(0.0, 1.0, 0.0))
            let buf = unsafe { LibC.malloc<JPHMat4>() }
            JPH_VehicleConstraint_GetWheelWorldTransform_cj(c, idx, right, up, buf)
            let m = JoltNative.readMat4(buf)
            unsafe {
                LibC.free(right)
                LibC.free(up)
                LibC.free(buf)
            }
            m
        })
    }

    /**
     * @brief[zh-cn] 销毁载具（移除并释放车辆约束；底盘刚体由调用方管理）
     * @note[zh-cn] 底盘刚体不在此销毁——载具常复用底盘，请按需调用
     * world.destroyBody(chassis)
     *
     * @brief[en] Disposes the vehicle (removes and releases the vehicle constraint;
     * the chassis body is managed by the caller)
     * @note[en] The chassis body is NOT destroyed here — vehicles often reuse the
     * chassis; call world.destroyBody(chassis) as needed
     */
    public func dispose(): Unit {
        if (this._disposed) {
            return
        }
        this._disposed = true
        let c = this._constraint
        if (!c.isNull()) {
            this._world.execPhysics({
                =>
                // 闭包在物理线程执行，用表达式风格获取系统句柄（与 Ragdoll 同款模式）
                match (this._world.backend) {
                    case jb: JoltBackend =>
                        let system = jb.nativeSystemHandle()
                        if (!system.isNull()) {
                            // 必须先摘除步进监听器再移除/销毁约束（与创建时 AddStepListener 配对），
                            // 否则 PhysicsSystem 的 mStepListeners 残留悬垂指针，
                            // 下一物理步 JobStepListeners 解引用已释放对象而崩溃。
                            let listener = JPH_VehicleConstraint_AsPhysicsStepListener_cj(c)
                            if (!listener.isNull()) {
                                JPH_PhysicsSystem_RemoveStepListener_cj(system, listener)
                            }
                            JPH_PhysicsSystem_RemoveConstraint_cj(system, c)
                        }
                    case _ => ()  // 非 Jolt 后端：无系统句柄可移除，仅释放约束内存
                }
                JPH_Constraint_Destroy_cj(c)
            })
            this._constraint = CPointer<Unit>()
            this._controller = CPointer<Unit>()
        }
    }
}

// =============================================================================
// PhysicsVehicleFactory 载具工厂
// =============================================================================

/**
 * @brief[zh-cn] 轮式载具工厂
 * @explain[zh-cn] 在指定物理世界内创建载具：底盘刚体 + 车辆约束（车轮/引擎/变速箱/
 * 差速器）+ 射线碰撞测试器，并把车辆约束注册为 PhysicsStepListener 以驱动每个物理步。
 * 失败（非 Jolt 后端、创建失败）时返回 isValid=false 的对象。
 *
 * @brief[en] Wheeled vehicle factory
 * @explain[en] Creates a vehicle in the given physics world: chassis body + vehicle
 * constraint (wheels/engine/transmission/differentials) + ray collision tester, and
 * registers the constraint as a PhysicsStepListener driving every physics step. On
 * failure (non-Jolt backend or creation failure) returns an object with isValid=false.
 */
public class PhysicsVehicleFactory {
    private let _desc: PhysicsVehicleDesc

    /**
     * @brief[zh-cn] 构造载具工厂
     * @param[zh-cn] desc 载具描述
     *
     * @brief[en] Creates a vehicle factory
     * @param[en] desc The vehicle description
     */
    public init(desc!: PhysicsVehicleDesc) {
        this._desc = desc
    }

    /**
     * @brief[zh-cn] 在指定物理世界创建运行时载具
     * @param[zh-cn] world 目标物理世界
     * @return[zh-cn] 运行时载具
     *
     * @brief[en] Creates a runtime vehicle in the given physics world
     * @param[en] world The target physics world
     * @return[en] The runtime vehicle
     */
    public func createVehicle(world: PhysicsWorld): PhysicsVehicle {
        let desc = this._desc
        let chassisDesc = desc.chassisDesc
        return world.execPhysicsResult<PhysicsVehicle>({
            =>
            match (world.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (system.isNull() || desc.wheels.size == 0) {
                        PhysicsVehicle(world: world, chassis: PhysicsBodyHandle.INVALID,
                            constraint: CPointer<Unit>(), controller: CPointer<Unit>(), wheelCount: 0)
                    } else {
                        // 底盘刚体（动态）
                        let chassis = jb.createBody(chassisDesc)
                        if (!chassis.isValid()) {
                            PhysicsVehicle(world: world, chassis: PhysicsBodyHandle.INVALID,
                                constraint: CPointer<Unit>(), controller: CPointer<Unit>(), wheelCount: 0)
                        } else {
                            let bodyPtr = JPH_PhysicsSystem_GetBodyPtr_cj(system, chassis.bodyID)
                            if (bodyPtr.isNull()) {
                                PhysicsVehicle(world: world, chassis: chassis,
                                    constraint: CPointer<Unit>(), controller: CPointer<Unit>(), wheelCount: 0)
                            } else {
                                // 车辆约束设置
                                let vs = unsafe { LibC.malloc<JPHVehicleConstraintSettings>() }
                                unsafe { JPH_VehicleConstraintSettings_Init_cj(vs) }
                                unsafe {
                                    // @C 结构体 read() 返回不可变值：读出 → 修改 → 写回
                                    var v = vs.read()
                                    v.up = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
                                    // three API 约定车头朝局部 +Z（左手系），镜像到 Jolt
                                    // 右手系后为 -Z；若填 +Z 会导致"前进"输入实际把车
                                    // 开向 three 的 -Z（底盘 z 不增反减）。
                                    v.forward = JPHVec3(x: 0.0f32, y: 0.0f32, z: -1.0f32)
                                    v.maxPitchRollAngle = Float32(desc.maxPitchRollAngle)
                                    v.wheelsCount = UInt32(desc.wheels.size)
                                    vs.write(v)
                                }
                                // 车轮设置指针数组（JPH_WheelSettings*）
                                let wheelArr = unsafe {
                                    LibC.malloc<CPointer<Unit>>(count: desc.wheels.size)
                                }
                                for (i in 0..desc.wheels.size) {
                                    let w = desc.wheels[i]
                                    let ws = JPH_WheelSettingsWV_Create_cj()
                                    // 车轮安装点是底盘局部坐标（three 左手系），
                                    // 必须与底盘世界坐标一样做 LH→RH 镜像，否则
                                    // 前/后轮（±Z）在 Jolt 空间颠倒：转向轮跑到车尾，
                                    // 行驶方向也与 three 预期相反。
                                    let pos = JoltNative.allocVec3(w.position)
                                    JPH_WheelSettings_SetPosition_cj(ws, pos)
                                    unsafe { LibC.free(pos) }
                                    // 车轮自身的滚动前向轴（WheelSettings::mWheelForward，
                                    // Jolt 默认 (0,0,+1)）。它独立于约束的 mForward：
                                    // 引擎驱动车轮转动时按该轴决定车辆行进方向，不覆写则
                                    // 全油门仍朝 Jolt +Z（即 three 的 -Z）倒车。
                                    // 注意这里要用 Raw（不做 LH→RH 镜像）：值本身已经是
                                    // Jolt 空间的 (0,0,-1)，再镜像会翻回 +1。
                                    let fwd = JoltNative.allocVec3Raw(Vector3(0.0, 0.0, -1.0))
                                    JPH_WheelSettings_SetWheelForward_cj(ws, fwd)
                                    unsafe { LibC.free(fwd) }
                                    JPH_WheelSettings_SetRadius_cj(ws, Float32(w.radius))
                                    JPH_WheelSettings_SetWidth_cj(ws, Float32(w.width))
                                    JPH_WheelSettings_SetSuspensionMinLength_cj(ws, Float32(w.suspensionMinLength))
                                    JPH_WheelSettings_SetSuspensionMaxLength_cj(ws, Float32(w.suspensionMaxLength))
                                    let spring = unsafe { LibC.malloc<JPHSpringSettings>() }
                                    unsafe {
                                        // @C 结构体合成 init 无参：先构造再逐字段赋值
                                        var s = JPHSpringSettings()
                                        s.mode = 0  // SpringMode_Frequency
                                        s.frequencyOrStiffness = Float32(w.suspensionFrequency)
                                        s.damping = Float32(w.suspensionDamping)
                                        spring.write(s)
                                    }
                                    JPH_WheelSettings_SetSuspensionSpring_cj(ws, spring)
                                    unsafe { LibC.free(spring) }
                                    JPH_WheelSettingsWV_SetMaxSteerAngle_cj(ws, Float32(w.maxSteerAngle))
                                    JPH_WheelSettingsWV_SetMaxBrakeTorque_cj(ws, Float32(w.maxBrakeTorque))
                                    JPH_WheelSettingsWV_SetMaxHandBrakeTorque_cj(ws, Float32(w.maxHandBrakeTorque))
                                    // 摩擦系数：C 端形参是 const JPH_LinearCurve*（轮胎摩擦是
                                    // 滑移率→摩擦系数曲线），按曲线语义构造 (0,1)→(1,coeff) 折线：
                                    // 零滑移全摩擦、饱和滑移后恒定。此前错误地把单个 Float32
                                    // 指针当作曲线传入，C 端按 sizeof(JPH_LinearCurve) 解引用
                                    // 拷贝 → 堆越界写 → 物理线程崩溃（窗口冻结根因）。
                                    let lat = JPH_LinearCurve_Create_cj()
                                    let lon = JPH_LinearCurve_Create_cj()
                                    JPH_LinearCurve_AddPoint_cj(lat, 0.0f32, 1.0f32)
                                    JPH_LinearCurve_AddPoint_cj(lat, 1.0f32, Float32(w.lateralFriction))
                                    JPH_LinearCurve_Sort_cj(lat)
                                    JPH_LinearCurve_AddPoint_cj(lon, 0.0f32, 1.0f32)
                                    JPH_LinearCurve_AddPoint_cj(lon, 1.0f32, Float32(w.longitudinalFriction))
                                    JPH_LinearCurve_Sort_cj(lon)
                                    JPH_WheelSettingsWV_SetLateralFriction_cj(ws, lat)
                                    JPH_WheelSettingsWV_SetLongitudinalFriction_cj(ws, lon)
                                    JPH_LinearCurve_Destroy_cj(lat)
                                    JPH_LinearCurve_Destroy_cj(lon)
                                    JPH_WheelSettingsWV_SetInertia_cj(ws, Float32(w.inertia))
                                    JPH_WheelSettingsWV_SetAngularDamping_cj(ws, Float32(w.angularDamping))
                                    unsafe { (wheelArr + i).write(ws) }
                                }
                                unsafe {
                                    var v = vs.read()
                                    // wheels 字段是 JPH_WheelSettings**（数组基址），
                                    // wheelArr 本身就是数组首地址（JPH_WheelSettings* 数组），
                                    // reinterpret 成 CPointer<Unit> 直接传入；
                                    // 不能用 wheelArr.read()（那只是第一个元素 wheel0 的指针，
                                    // C 端按 wheels[i] 遍历时会越界读 → 崩溃）
                                    v.wheels = CPointer<Unit>(wheelArr)
                                    vs.write(v)
                                }
                                // 控制器设置（WheeledVehicleController：引擎/变速箱/差速器）
                                // 必须在 Create 之前挂到 vs.controller，创建约束时一并安装
                                let wcs = JPH_WheeledVehicleControllerSettings_Create_cj()
                                let eng = unsafe { LibC.malloc<JPHVehicleEngineSettings>() }
                                unsafe { JPH_VehicleEngineSettings_Init_cj(eng) }
                                unsafe {
                                    var e = eng.read()
                                    e.maxTorque = Float32(desc.engine.maxTorque)
                                    e.minRPM = Float32(desc.engine.minRPM)
                                    e.maxRPM = Float32(desc.engine.maxRPM)
                                    eng.write(e)
                                }
                                JPH_WheeledVehicleControllerSettings_SetEngine_cj(wcs, eng)
                                unsafe { LibC.free(eng) }
                                let trans = JPH_VehicleTransmissionSettings_Create_cj()
                                // 变速箱模式：0 = 自动（JPH ETransmissionMode_Auto）
                                JPH_VehicleTransmissionSettings_SetMode_cj(trans, 0u32)
                                let gears = unsafe { LibC.malloc<Float32>(count: desc.engine.gearRatios.size) }
                                for (i in 0..desc.engine.gearRatios.size) {
                                    unsafe { (gears + i).write(Float32(desc.engine.gearRatios[i])) }
                                }
                                JPH_VehicleTransmissionSettings_SetGearRatios_cj(trans, gears,
                                    UInt32(desc.engine.gearRatios.size))
                                unsafe { LibC.free(gears) }
                                let revs = unsafe { LibC.malloc<Float32>(count: desc.engine.reverseGearRatios.size) }
                                for (i in 0..desc.engine.reverseGearRatios.size) {
                                    unsafe { (revs + i).write(Float32(desc.engine.reverseGearRatios[i])) }
                                }
                                JPH_VehicleTransmissionSettings_SetReverseGearRatios_cj(trans, revs,
                                    UInt32(desc.engine.reverseGearRatios.size))
                                unsafe { LibC.free(revs) }
                                JPH_VehicleTransmissionSettings_SetShiftUpRPM_cj(trans, Float32(desc.engine.shiftUpRPM))
                                JPH_VehicleTransmissionSettings_SetShiftDownRPM_cj(trans, Float32(desc.engine.shiftDownRPM))
                                JPH_VehicleTransmissionSettings_SetSwitchLatency_cj(trans, Float32(desc.engine.switchLatency))
                                JPH_VehicleTransmissionSettings_SetSwitchTime_cj(trans, Float32(desc.engine.switchTime))
                                JPH_VehicleTransmissionSettings_SetClutchStrength_cj(trans, Float32(desc.engine.clutchStrength))
                                JPH_WheeledVehicleControllerSettings_SetTransmission_cj(wcs, trans)
                                JPH_VehicleTransmissionSettings_Destroy_cj(trans)
                                // 差速器：成对驱动轮（左/右），未配置时用首末车轮。
                                // C 端 AddDifferential(settings, leftWheel, rightWheel) 会用
                                // 默认差速比 3.5 / 限滑比 1.4 构造差速器并加入控制器。
                                let dw = desc.drivenWheels
                                let leftIdx: Int32 = if (dw.size >= 2) { Int32(dw[0]) } else { 0i32 }
                                let rightIdx: Int32 = if (dw.size >= 2) { Int32(dw[1]) } else { Int32(desc.wheels.size - 1) }
                                JPH_WheeledVehicleControllerSettings_AddDifferential_cj(wcs, leftIdx, rightIdx)
                                unsafe {
                                    var v = vs.read()
                                    v.controller = wcs
                                    vs.write(v)
                                }
                                // 创建约束（此时安装控制器）
                                let constraint = JPH_VehicleConstraint_Create_cj(bodyPtr, vs)
                                unsafe { LibC.free(wheelArr) }
                                unsafe { LibC.free(vs) }
                                if (constraint.isNull()) {
                                    PhysicsVehicle(world: world, chassis: chassis,
                                        constraint: CPointer<Unit>(), controller: CPointer<Unit>(), wheelCount: 0)
                                } else {
                                    let controller = JPH_VehicleConstraint_GetController_cj(constraint)
                                    // 射线碰撞测试器（车轮接地检测）
                                    let upVec = JoltNative.allocVec3Raw(Vector3(0.0, 1.0, 0.0))
                                    let tester = JPH_VehicleCollisionTesterRay_Create_cj(
                                        _vehicleLayerValue(chassisDesc.layer), upVec, 1.5707963f32)
                                    unsafe { LibC.free(upVec) }
                                    if (!tester.isNull()) {
                                        JPH_VehicleConstraint_SetVehicleCollisionTester_cj(constraint, tester)
                                        JPH_VehicleCollisionTester_Destroy_cj(tester)
                                    }
                                    // 加入世界并注册步进监听器
                                    JPH_PhysicsSystem_AddConstraint_cj(system, constraint)
                                    let listener = JPH_VehicleConstraint_AsPhysicsStepListener_cj(constraint)
                                    if (!listener.isNull()) {
                                        // 必须注册为 PhysicsStepListener：Jolt 载具的悬挂压缩、
                                        // 轮胎抓地、引擎/差速器扭矩全部在 OnStep 中驱动。
                                        // 不注册则驾驶输入完全无效（车辆不动、车轮变换不更新）。
                                        // 配对：dispose() 中必须先 RemoveStepListener 再销毁约束，
                                        // 否则监听器数组残留悬垂指针，下一物理步 worker 解引用崩溃。
                                        JPH_PhysicsSystem_AddStepListener_cj(system, listener)
                                    }
                                    PhysicsVehicle(world: world, chassis: chassis,
                                        constraint: constraint, controller: controller,
                                        wheelCount: Int64(desc.wheels.size))
                                }
                            }
                        }
                    }
                case _ =>
                    // 非 Jolt 后端：无载具能力
                    PhysicsVehicle(world: world, chassis: PhysicsBodyHandle.INVALID,
                        constraint: CPointer<Unit>(), controller: CPointer<Unit>(), wheelCount: 0)
            }
        })
    }
}

/// three 物理层 → Jolt 对象层值（与 JoltBackend 层映射一致：Moving=1，NonMoving/Static=0）
internal func _vehicleLayerValue(layer: PhysicsLayer): UInt32 {
    match (layer) {
        case PhysicsLayer.Moving => 1
        case _ => 0
    }
}
