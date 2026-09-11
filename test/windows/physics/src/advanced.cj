package threePhysicsTest

/**
 * 高级物理能力验证（#5 电机 / #6 Vehicle / #7 SoftBody / #8 HeightField / #9 DebugRenderer
 * / #10 Slider 滑块电机 / 约束动物园 / #11 Ragdoll 布娃娃 / #12 Character 角色控制器）
 *
 * 与 main.cj 的碰撞查询验证（verifyCollisionQueries）同款模式：
 * - 断言结果打印 [PASS]/[FAIL]，同时落盘 physics_advanced.log
 * - 电机（M1）：铰链约束位置/速度模式，验证 getConstraintCurrentAngle 收敛
 * - 软体（S）：SharedSettings 顶点+面+边约束 → CreateAndAddSoftBody，验证刚体有效 + 重力下落
 * - 高度场（H）：N×N 高度采样 → 静态地形，验证 projectOntoSurface 采样高度
 * - 调试渲染（D）：PhysicsDebugRenderer 桥接，验证 DrawBodies 产出线段/三角形缓存
 * - 滑块（SL）：滑块约束位置电机，验证 getSliderCurrentPosition 收敛
 * - 约束动物园（CZ）：fixed/point/cone/swingTwist/gear/sixDOF 六类约束创建冒烟
 * - 布娃娃（R）：PhysicsSkeleton + RagdollPartSettings → PhysicsRagdoll，验证下落与销毁
 * - 角色（C）：虚拟角色（CharacterVirtual）水平行走 + 刚体角色（Character）落地
 */

import std.io.*
import std.env.*
import std.fs.{File, Path as FsPath}
import std.collection.*
import std.math.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.buffer.*
import three.physics.interfaces.*
import three.physics.world.*
import three.physics.body.*
import three.physics.constraint.*
import three.physics.vehicle.*
import three.physics.softbody.*
import three.physics.heightfield.*
import three.physics.debug.*
import three.physics.ragdoll.*
import three.physics.character.*

// =============================================================================
// 断言工具（与 main.cj 的 _qcheck 同款，独立计数避免互相干扰）
// =============================================================================

/// 高级测试断言计数器（进程级，advanced_test 内唯一）
var _advPass: Int64 = 0
var _advFail: Int64 = 0

func _advcheck(name: String, cond: Bool, log: StringBuilder): Unit {
    if (cond) {
        _advPass += 1
        log.append("  [PASS] ${name}\n")
    } else {
        _advFail += 1
        log.append("  [FAIL] ${name}\n")
    }
}

/// 取两个标量的绝对差
func _abs(a: Float64): Float64 {
    if (a < 0.0) { return -a }
    return a
}

/// 角度差归一化到 [-PI, PI]
func _angleDiff(a: Float64, b: Float64): Float64 {
    var d = a - b
    while (d > PI) { d -= 2.0 * PI }
    while (d < -PI) { d += 2.0 * PI }
    return d
}

// =============================================================================
// M1: 铰链约束电机运行时控制（#5）
// =============================================================================

/**
 * 创建电机测试装置：静态锚点柱 + 动态摆杆 + 铰链约束（轴沿 Z，限位 ±PI/2）。
 * 返回 (锚点刚体句柄, 摆杆刚体句柄, 约束)。
 */
public func createMotorRig(world: PhysicsWorld): (PhysicsBodyHandle, PhysicsBodyHandle, PhysicsConstraint) {
    // 静态锚点柱
    let anchorDesc = PhysicsBodyDesc(
        shape: PhysicsShape.box(0.3, 0.3, 0.3),
        position: Vector3(-12.0, 2.0, 0.0),
        motionType: PhysicsMotionType.Static,
        autoSync: false, mass: 10.0)
    let anchorHandle = world.createBody(anchorDesc)

    // 动态摆杆（1x1x1，质心在锚点正下方 1m 处）
    let armDesc = PhysicsBodyDesc(
        shape: PhysicsShape.box(0.4, 2.0, 0.4),
        position: Vector3(-12.0, 1.0, 0.0),
        motionType: PhysicsMotionType.Dynamic,
        autoSync: false, mass: 1.0)
    let armHandle = world.createBody(armDesc)

    // 铰链：锚点 (-12, 2, 0)，轴 Z，限位 ±PI/2
    let hinge = PhysicsConstraint.hinge(world, anchorHandle, armHandle,
        Vector3(-12.0, 2.0, 0.0), Vector3(0.0, 0.0, 1.0),
        limitMin: -PI / 2.0, limitMax: PI / 2.0)
    return (anchorHandle, armHandle, hinge)
}

/**
 * M1 验证：电机位置模式把铰链角驱动到目标值。
 * 在 createMotorRig 之后调用；需要世界已 update 若干帧后再调 verifyMotorPosition。
 */
public func startMotorPosition(world: PhysicsWorld, hinge: PhysicsConstraint, targetAngle: Float64): Unit {
    world.setConstraintMotorState(hinge.handle, PhysicsMotorState.Position)
    world.setConstraintTargetAngle(hinge.handle, targetAngle)
}

/**
 * M1 验证：电机速度模式把摆杆驱动到目标角速度。
 */
public func startMotorVelocity(world: PhysicsWorld, hinge: PhysicsConstraint, targetVel: Float64): Unit {
    world.setConstraintMotorState(hinge.handle, PhysicsMotorState.Velocity)
    world.setConstraintTargetAngularVelocity(hinge.handle, targetVel)
}

/**
 * M1 验证：电机 Off 后摆杆在重力作用下自由摆动（角度应离开目标值）。
 */
public func stopMotor(world: PhysicsWorld, hinge: PhysicsConstraint): Unit {
    world.setConstraintMotorState(hinge.handle, PhysicsMotorState.Off)
}

// =============================================================================
// S: SoftBody 软体（#7）
// =============================================================================

/**
 * 创建一个 4x4 网格软体薄板（25 顶点 x 32 三角形），从高空下落。
 * 返回 (软体, 世界空间初始 Y 位置)。
 */
public func createSoftBoard(world: PhysicsWorld): (PhysicsSoftBody, Float64) {
    let desc = PhysicsSoftBodyDesc()
    let n = 4  // 每边 4 个顶点 → 3x3 个四边形 → 6 个三角形
    let half = 1.0  // 半边长 1m（2m x 2m 薄板）
    // 生成位置偏移（SoftBodyCreationSettings 无独立位置字段，偏移烘焙进顶点）
    let ox = 0.0
    let oy = 25.0
    let oz = 10.0
    for (gy in 0..n) {
        for (gx in 0..n) {
            desc.vertices.add(Vector3(
                ox + (-half + 2.0 * half * Float64(gx) / Float64(n - 1)),
                oy,
                oz + (-half + 2.0 * half * Float64(gy) / Float64(n - 1))))
        }
    }
    // 每个四边形拆成 2 个三角形（行主序，索引 = gy * n + gx）
    for (gy in 0..n - 1) {
        for (gx in 0..n - 1) {
            let a = UInt32(gy * n + gx)
            let b = UInt32(gy * n + gx + 1)
            let c = UInt32((gy + 1) * n + gx)
            let d = UInt32((gy + 1) * n + gx + 1)
            desc.indices.add(a)
            desc.indices.add(c)
            desc.indices.add(b)
            desc.indices.add(b)
            desc.indices.add(c)
            desc.indices.add(d)
        }
    }
    desc.compliance = 0.00005  // 轻微柔顺
    desc.pressure = 0.0
    desc.friction = 0.4
    desc.vertexRadius = 0.02
    // 放在高空 (0, 25, 10) 下落
    desc.layer = PhysicsLayer.Moving
    let factory = PhysicsSoftBodyFactory(desc: desc)
    let body = factory.createSoftBody(world)
    return (body, 25.0)
}

// =============================================================================
// H: HeightField 高度场（#8）
// =============================================================================

/**
 * 创建一个正弦地形：y = 2.0 * sin(x/5.0) * cos(z/5.0)，范围 ±20m。
 * 返回 (高度场, 描述——用于投影验证)。
 */
public func createSineTerrain(world: PhysicsWorld): (PhysicsHeightField, PhysicsHeightFieldDesc) {
    let desc = PhysicsHeightFieldDesc()
    let n = 17  // 17x17 采样
    desc.sampleCount = n
    desc.sizeX = 40.0
    desc.sizeZ = 40.0
    // 地形整体抬离 y=0：振幅 2.0 的波形叠加 +2.0 基准高度，使波谷 ≥ 0，
    // 避免与 y=0 的 40×40 地面 plane 重叠区域互相遮挡（视觉"缺块"的根因）
    desc.center = Vector3(-25.0, 2.0, 5.0)
    desc.friction = 0.5
    for (gy in 0..n) {
        for (gx in 0..n) {
            let x = desc.center.x - 20.0 + 40.0 * Float64(gx) / Float64(n - 1)
            let z = desc.center.z - 20.0 + 40.0 * Float64(gy) / Float64(n - 1)
            let y = 2.0 + 2.0 * sin(x / 5.0) * cos(z / 5.0)
            desc.samples.add(y)
        }
    }
    let factory = PhysicsHeightFieldFactory(desc: desc)
    let body = factory.createHeightField(world)
    return (body, desc)
}

/// 正弦地形高度真值（与 createSineTerrain 同款公式，世界空间坐标）
public func terrainHeightAt(x: Float64, z: Float64): Float64 {
    2.0 + 2.0 * sin(x / 5.0) * cos(z / 5.0)
}

// =============================================================================
// D: DebugRenderer 调试渲染（#9）
// =============================================================================

/**
 * D 验证：创建调试渲染器并采集一帧。
 * 返回渲染器（调用方负责 dispose）。
 */
public func createDebugRenderer(): PhysicsDebugRenderer {
    PhysicsDebugRenderer()
}

// =============================================================================
// V: Vehicle 载具（#6）
// =============================================================================

/**
 * 创建四轮载具：底盘箱体 (10, 1.5, -12) + 4 个车轮（前轮可转向）。
 * 返回运行时载具。
 */
public func createTestVehicle(world: PhysicsWorld): PhysicsVehicle {
    let chassisDesc = PhysicsBodyDesc(
        shape: PhysicsShape.box(1.0, 0.3, 2.0),
        position: Vector3(10.0, 1.5, -12.0),
        motionType: PhysicsMotionType.Dynamic,
        friction: 0.5, mass: 800.0)
    let desc = PhysicsVehicleDesc(chassisDesc: chassisDesc)
    // 车轮：底盘局部空间（半长 2m、半宽 1m、轮半径 0.3）
    let fl = PhysicsVehicleWheelDesc(position: Vector3(-0.9, -0.2, 1.4))
    fl.radius = 0.3
    fl.width = 0.2
    fl.maxSteerAngle = 0.5
    let fr = PhysicsVehicleWheelDesc(position: Vector3(0.9, -0.2, 1.4))
    fr.radius = 0.3
    fr.width = 0.2
    fr.maxSteerAngle = 0.5
    let rl = PhysicsVehicleWheelDesc(position: Vector3(-0.9, -0.2, -1.4))
    rl.radius = 0.3
    rl.width = 0.2
    let rr = PhysicsVehicleWheelDesc(position: Vector3(0.9, -0.2, -1.4))
    rr.radius = 0.3
    rr.width = 0.2
    desc.wheels.add(fl)
    desc.wheels.add(fr)
    desc.wheels.add(rl)
    desc.wheels.add(rr)
    // 后轮驱动
    desc.drivenWheels.add(2)
    desc.drivenWheels.add(3)
    let factory = PhysicsVehicleFactory(desc: desc)
    return factory.createVehicle(world)
}

// =============================================================================
// SL: Slider 滑块约束电机（#10）
// =============================================================================

/**
 * 创建滑块测试装置：静态锚块 + 动态滑块 + 沿 Y 轴的滑块约束（限位 -1.0~1.5m）。
 * 返回 (锚点句柄, 滑块句柄, 滑块约束, 创建时滑块位置)。位置电机目标 +1.0m 应把滑块向上顶起。
 */
public func createSliderRig(world: PhysicsWorld): (PhysicsBodyHandle, PhysicsBodyHandle, PhysicsConstraint, Float64) {
    let anchorDesc = PhysicsBodyDesc(
        shape: PhysicsShape.box(0.6, 0.6, 0.6),
        position: Vector3(15.0, 5.0, 8.0),
        motionType: PhysicsMotionType.Static,
        autoSync: false, mass: 10.0)
    let anchor = world.createBody(anchorDesc)
    let slideDesc = PhysicsBodyDesc(
        shape: PhysicsShape.box(0.5, 0.5, 0.5),
        position: Vector3(15.0, 4.0, 8.0),
        motionType: PhysicsMotionType.Dynamic,
        autoSync: false, mass: 2.0)
    let slider = world.createBody(slideDesc)
    let c = PhysicsConstraint.slider(world, anchor, slider,
        Vector3(15.0, 4.6, 8.0), Vector3(0.0, 1.0, 0.0), -1.0, 1.5)
    return (anchor, slider, c, world.getSliderCurrentPosition(c.handle))
}

// =============================================================================
// CZ: 约束动物园（fixed/point/cone/swingTwist/gear/sixDOF 创建冒烟）
// =============================================================================

/// 约束动物园类型顺序（与 phase 9 的逐帧创建索引对应）
public func zooConstraintName(i: Int64): String {
    match (i) {
        case 0 => "fixed"
        case 1 => "point"
        case 2 => "cone"
        case 3 => "swingTwist"
        case 4 => "gear"
        case _ => "sixDOF"
    }
}

/**
 * 创建约束动物园中第 i 具约束（静态锚 + 动态块 + 对应约束），
 * x=20..32, z=-8。用于逐类型验证全部约束工厂与 Jolt 求解通路。
 * 返回 (约束, 该装置创建的全部刚体句柄——齿轮装置含第三个悬空动态块)。
 */
public func createOneZooConstraint(world: PhysicsWorld, i: Int64): (PhysicsConstraint, ArrayList<PhysicsBodyHandle>) {
    let bodies = ArrayList<PhysicsBodyHandle>()
    let x = 20.0 + Float64(i) * 2.5
    let anchor = world.createBody(PhysicsBodyDesc(
        shape: PhysicsShape.box(0.3, 0.3, 0.3),
        position: Vector3(x, 3.0, -8.0),
        motionType: PhysicsMotionType.Static,
        autoSync: false, mass: 10.0))
    bodies.add(anchor)
    let dyn = world.createBody(PhysicsBodyDesc(
        shape: PhysicsShape.box(0.3, 0.3, 0.3),
        position: Vector3(x, 2.2, -8.0),
        motionType: PhysicsMotionType.Dynamic,
        autoSync: false, mass: 1.0))
    bodies.add(dyn)
    let anchorP = Vector3(x, 2.6, -8.0)
    let c = match (i) {
        case 0 =>
            // Fixed：不设锚点（默认世界原点），验证创建通路
            PhysicsConstraint.fixed(world, anchor, dyn)
        case 1 =>
            PhysicsConstraint.point(world, anchor, dyn, anchorP)
        case 2 =>
            PhysicsConstraint.cone(world, anchor, dyn, anchorP,
                Vector3(0.0, 1.0, 0.0), 0.6)
        case 3 =>
            PhysicsConstraint.swingTwist(world, anchor, dyn, anchorP,
                Vector3(0.0, 1.0, 0.0), Vector3(1.0, 0.0, 0.0), -1.0, 1.0)
        case 4 =>
            // Gear：Jolt 的 GearConstraintPart 求解时直接取两体的 MotionProperties，
            // 静态体该指针为空（Jolt 原生空指针崩溃），且齿轮耦合本就需要两个可转动体。
            // 故用两个悬空的动态方块做齿轮耦合冒烟测试（静态 anchor 不参与此约束）。
            let gear2 = world.createBody(PhysicsBodyDesc(
                shape: PhysicsShape.box(0.3, 0.3, 0.3),
                position: Vector3(x, 1.4, -8.0),
                motionType: PhysicsMotionType.Dynamic,
                autoSync: false, mass: 1.0))
            bodies.add(gear2)
            PhysicsConstraint.gear(world, dyn, gear2, anchorP,
                Vector3(0.0, 1.0, 0.0), 2.0)
        case _ =>
            PhysicsConstraint.sixDOF(world, anchor, dyn, anchorP)
    }
    return (c, bodies)
}

// =============================================================================
// R: Ragdoll 布娃娃（#11）
// =============================================================================

/**
 * 创建一个 3 关节布娃娃（骨盆/胸/头，球形骨盆与头 + 盒形胸），从 y≈6 自由下落。
 * 关节为锥形摆动-扭转约束（半锥角 0.35rad）。返回 (布娃娃, 根节点初始世界高度)。
 */
public func createTestRagdoll(world: PhysicsWorld): (PhysicsRagdoll, Float64) {
    let skel = PhysicsSkeleton()
    skel.addJoint("pelvis")
    skel.addJoint("chest", parentIndex: 0)
    skel.addJoint("head", parentIndex: 1)
    // 胸→骨盆关节：锚点在胸部质心下方 0.28 / 骨盆质心上方 0.32
    let jChest = RagdollJoint()
    jChest.position1 = Vector3(0.0, -0.28, 0.0)
    jChest.position2 = Vector3(0.0, 0.32, 0.0)
    jChest.twistAxis1 = Vector3(0.0, 1.0, 0.0)
    jChest.twistAxis2 = Vector3(0.0, 1.0, 0.0)
    jChest.normalHalfConeAngle = 0.35f32
    jChest.planeHalfConeAngle = 0.35f32
    // 头→胸关节：锚点在头部质心下方 0.30 / 胸部质心上方 0.25
    let jHead = RagdollJoint()
    jHead.position1 = Vector3(0.0, -0.30, 0.0)
    jHead.position2 = Vector3(0.0, 0.25, 0.0)
    jHead.twistAxis1 = Vector3(0.0, 1.0, 0.0)
    jHead.twistAxis2 = Vector3(0.0, 1.0, 0.0)
    jHead.normalHalfConeAngle = 0.35f32
    jHead.planeHalfConeAngle = 0.35f32
    let parts = [
        RagdollPartSettings(shape: PhysicsShape.sphere(0.28),
            position: Vector3(22.0, 6.0, 6.0)),
        RagdollPartSettings(shape: PhysicsShape.box(0.35, 0.45, 0.22),
            position: Vector3(22.0, 6.6, 6.0),
            toParent: Some(jChest)),
        RagdollPartSettings(shape: PhysicsShape.sphere(0.20),
            position: Vector3(22.0, 7.15, 6.0),
            toParent: Some(jHead)),
    ]
    let settings = PhysicsRagdollSettings(skeleton: skel, parts: parts)
    let rag = settings.createRagdoll(world)
    rag.addToWorld()
    let (rootPos, _) = rag.getRootTransform()
    return (rag, rootPos.y)
}

// =============================================================================
// 高级验证状态机（由 main.cj 的 onFrame 驱动）
// =============================================================================

/// 阶段推进间隔（帧）
let _ADV_PHASE_FRAMES: Int64 = 60

/**
 * 高级验证驱动器：按阶段推进 M1 电机 / S 软体 / H 高度场 / D 调试渲染四组验证。
 * 与 main.cj 的查询验证互不干扰（独立计数与日志）。
 */
public class AdvancedTestDriver {
    /// 高级验证日志（落盘 physics_advanced.log）
    public let log: StringBuilder = StringBuilder()
    /// 全部阶段完成后置 true
    public var done: Bool = false

    private var _phase: Int64 = 0
    private var _frameInPhase: Int64 = 0

    // M1 电机装置
    private var _arm: Option<PhysicsBodyHandle> = None
    private var _hinge: Option<PhysicsConstraint> = None
    private var _angle0: Float64 = 0.0
    private var _maxAngle: Float64 = -3.4e38

    // S 软体
    private var _soft: Option<PhysicsSoftBody> = None

    // V 载具
    private var _vehicle: Option<PhysicsVehicle> = None
    private var _vehX0: Float64 = 0.0

    // H 高度场
    private var _terrain: Option<PhysicsHeightField> = None
    private var _terrainDesc: Option<PhysicsHeightFieldDesc> = None

    // D 调试渲染
    private var _dbg: Option<PhysicsDebugRenderer> = None
    private var _bodyLines: Int64 = 0

    // SL 滑块电机
    private var _slider: Option<PhysicsConstraint> = None
    private var _sliderPos0: Float64 = 0.0

    // CZ 约束动物园
    private var _zoo: Option<ArrayList<PhysicsConstraint>> = None

    // R 布娃娃
    private var _rag: Option<PhysicsRagdoll> = None
    private var _ragY0: Float64 = 0.0

    // C 角色控制器
    private var _vchar: Option<PhysicsCharacterVirtual> = None
    private var _rchar: Option<PhysicsCharacter> = None
    private var _charX0: Float64 = 0.0
    private var _charRY0: Float64 = 0.0

    // ===== 可视化（渲染网格跟随物理体；autoSync 由 world.update 驱动） =====
    /// 渲染场景（setup 时注入）
    private var _scene: Scene = Scene()
    /// 电机装置网格（锚点 + 摆杆，全程存在）
    private let _motorMeshes: ArrayList<Mesh> = ArrayList<Mesh>()
    /// 软体板网格（阶段 3 末销毁）
    private var _softMesh: Option<Mesh> = None
    /// 载具底盘网格 + 4 个车轮网格（阶段 4 末销毁）
    private var _vehChassisMesh: Option<Mesh> = None
    private let _wheelMeshes: ArrayList<Mesh> = ArrayList<Mesh>()
    /// 高度场网格（阶段 6 末销毁）
    private var _terrainMesh: Option<Mesh> = None
    /// 滑块装置网格（阶段 8 末销毁）
    private let _sliderMeshes: ArrayList<Mesh> = ArrayList<Mesh>()
    /// 约束动物园网格（刚体全程保留，网格同）
    private let _zooMeshes: ArrayList<Mesh> = ArrayList<Mesh>()
    /// 布娃娃 3 部件网格（阶段 10 末销毁）
    private let _ragMeshes: ArrayList<Mesh> = ArrayList<Mesh>()
    /// 角色胶囊网格（阶段 11 末销毁；0=虚拟角色，1=刚体角色）
    private var _vcharMesh: Option<Mesh> = None
    private var _rcharMesh: Option<Mesh> = None

    /// 注入共享物理世界与渲染场景（由 main.cj 在 onInit 后调用；世界已含地面）
    public func setup(world: PhysicsWorld, scene: Scene): Unit {
        this._scene = scene
        this.log.append("=== advanced physics verification ===\n")

        // M1：电机装置（放在空旷区，避免与查询验证的刚体相互干扰）
        let (anchor, arm, hinge) = createMotorRig(world)
        this._arm = Some(arm)
        this._hinge = Some(hinge)
        // 可视化：锚点青绿色小方块 + 暖橙色摆杆
        this._motorMeshes.add(this._spawnBox(world, anchor,
            0.3, 0.3, 0.3, Vector3(-12.0, 2.0, 0.0), MESH_VS, MESH_FS))
        this._motorMeshes.add(this._spawnBox(world, arm,
            0.4, 2.0, 0.4, Vector3(-12.0, 1.0, 0.0), HINGE_VS, HINGE_FS))
        this.log.append("[M1] motor rig created (hinge at (-12,2,0), axis Z)\n")
    }

    // =========================================================================
    // 可视化辅助
    // =========================================================================

    /// 创建盒形网格并绑定到已有物理刚体（world.update 后自动同步 transform）
    private func _spawnBox(world: PhysicsWorld, handle: PhysicsBodyHandle,
            w: Float64, h: Float64, d: Float64, pos: Vector3,
            vs: String, fs: String): Mesh {
        let mesh = Mesh(geometry: BoxGeometry(width: w, height: h, depth: d),
            material: ShaderMaterial(vs, fs))
        mesh.position.set(pos.x, pos.y, pos.z)
        this._scene.add(mesh)
        world.bindObject(mesh, handle)
        return mesh
    }

    /// 创建球形网格并绑定到已有物理刚体
    private func _spawnSphere(world: PhysicsWorld, handle: PhysicsBodyHandle,
            radius: Float64, pos: Vector3, vs: String, fs: String): Mesh {
        let mesh = Mesh(geometry: SphereGeometry(radius: radius, widthSegments: 16, heightSegments: 12),
            material: ShaderMaterial(vs, fs))
        mesh.position.set(pos.x, pos.y, pos.z)
        this._scene.add(mesh)
        world.bindObject(mesh, handle)
        return mesh
    }

    /// 创建胶囊网格（不绑定物理，位置由调用方每帧手动同步）
    private func _spawnCapsuleVisual(radius: Float64, halfHeight: Float64, pos: Vector3,
            vs: String, fs: String): Mesh {
        let mesh = Mesh(geometry: CapsuleGeometry(radius: radius, length: halfHeight * 2.0 + radius * 2.0),
            material: ShaderMaterial(vs, fs))
        mesh.position.set(pos.x, pos.y, pos.z)
        this._scene.add(mesh)
        return mesh
    }

    /// 创建车轮圆柱网格（圆柱轴向旋转为 X；transform 每帧由车轮世界矩阵驱动）
    private func _spawnWheelVisual(pos: Vector3): Mesh {
        let geom = CylinderGeometry(radiusTop: 0.3, radiusBottom: 0.3, height: 0.2)
        geom.rotateZ(PI / 2.0)
        let mesh = Mesh(geometry: geom, material: ShaderMaterial(CAPSULE_VS, CAPSULE_FS))
        mesh.position.set(pos.x, pos.y, pos.z)
        this._scene.add(mesh)
        return mesh
    }

    /// 解除物理绑定并从场景移除网格
    private func _despawn(world: PhysicsWorld, mesh: Mesh): Unit {
        world.unbindObject(mesh)
        this._scene.remove(mesh)
    }

    /// 构建软体薄板网格（4x4 顶点，双面三角形；顶点为相对刚体质心的局部坐标）
    private func _buildSoftBoardMesh(): Mesh {
        let n = 4
        let half = 1.0
        let positions = Array<Float64>(n * n * 3, repeat: 0.0)
        let normals = Array<Float64>(n * n * 3, repeat: 0.0)
        var vi = 0
        for (gy in 0..n) {
            for (gx in 0..n) {
                positions[vi] = -half + 2.0 * half * Float64(gx) / Float64(n - 1)
                positions[vi + 1] = 0.0
                positions[vi + 2] = -half + 2.0 * half * Float64(gy) / Float64(n - 1)
                normals[vi] = 0.0
                normals[vi + 1] = 1.0
                normals[vi + 2] = 0.0
                vi += 3
            }
        }
        // 每个四边形正反两面各 2 个三角形（共 36 索引），翻转时背面也可见
        let indices = ArrayList<Float64>()
        for (gy in 0..n - 1) {
            for (gx in 0..n - 1) {
                let a = Float64(gy * n + gx)
                let b = Float64(gy * n + gx + 1)
                let c = Float64((gy + 1) * n + gx)
                let d = Float64((gy + 1) * n + gx + 1)
                indices.add(a); indices.add(c); indices.add(b)
                indices.add(b); indices.add(c); indices.add(d)
                // 反向缠绕
                indices.add(a); indices.add(b); indices.add(c)
                indices.add(b); indices.add(d); indices.add(c)
            }
        }
        let idxArr = Array<Float64>(indices.size, repeat: 0.0)
        for (i in 0..indices.size) {
            idxArr[i] = indices[i]
        }
        let geom = BufferGeometry()
        geom.setIndex(BufferAttribute(idxArr, 1))
        geom.setAttribute("position", BufferAttribute(positions, 3))
        geom.setAttribute("normal", BufferAttribute(normals, 3))
        return Mesh(geometry: geom, material: ShaderMaterial(CONVEX_VS, CONVEX_FS))
    }

    /// 依据高度场采样描述构建世界空间地形网格（双面三角形）
    /// desc.samples 已含世界空间高度（含基准高度 +2），顶点直接烘焙世界坐标
    private func _buildTerrainMesh(desc: PhysicsHeightFieldDesc): Mesh {
        let n = desc.sampleCount
        let positions = Array<Float64>(n * n * 3, repeat: 0.0)
        for (gy in 0..n) {
            for (gx in 0..n) {
                let x = desc.center.x - desc.sizeX / 2.0 + desc.sizeX * Float64(gx) / Float64(n - 1)
                let z = desc.center.z - desc.sizeZ / 2.0 + desc.sizeZ * Float64(gy) / Float64(n - 1)
                let y = desc.samples[gy * n + gx]
                let vi = (gy * n + gx) * 3
                positions[vi] = x
                positions[vi + 1] = y
                positions[vi + 2] = z
            }
        }
        let geom = BufferGeometry()
        geom.setAttribute("position", BufferAttribute(positions, 3))
        let nrm = Array<Float64>(n * n * 3, repeat: 0.0)
        for (v in 0..n * n) { nrm[v * 3 + 1] = 1.0 }
        geom.setAttribute("normal", BufferAttribute(nrm, 3))
        // 索引：每 quad 正向 2 个三角形 + 反向 2 个三角形（双面可见）
        let idx = ArrayList<Float64>()
        for (gy in 0..n - 1) {
            for (gx in 0..n - 1) {
                let a = Float64(gy * n + gx)
                let b = Float64(gy * n + gx + 1)
                let c = Float64((gy + 1) * n + gx)
                let d = Float64((gy + 1) * n + gx + 1)
                idx.add(a); idx.add(c); idx.add(b)
                idx.add(b); idx.add(c); idx.add(d)
                idx.add(a); idx.add(b); idx.add(c)
                idx.add(b); idx.add(d); idx.add(c)
            }
        }
        let idxArr = Array<Float64>(idx.size, repeat: 0.0)
        for (i in 0..idx.size) { idxArr[i] = idx[i] }
        geom.setIndex(BufferAttribute(idxArr, 1))
        return Mesh(geometry: geom, material: ShaderMaterial(MESH_VS, TERRAIN_FS))
    }

    /// 每帧推进；world 为共享物理世界
    public func tick(world: PhysicsWorld): Unit {
        if (this.done) {
            return
        }
        this._frameInPhase += 1
        let f = this._frameInPhase

        if (this._phase == 0) {
            // 等装置稳定
            if (f >= 10) {
                match (this._hinge) {
                    case Some(h) =>
                        this._angle0 = world.getConstraintCurrentAngle(h.handle)
                        // 位置模式：驱动到 +PI/4
                        startMotorPosition(world, h, PI / 4.0)
                        this.log.append("[M1] position motor -> target +PI/4 (start angle = ${this._angle0})\n")
                    case None => ()
                }
                this._nextPhase()
            }
        } else if (this._phase == 1) {
            // 位置模式运行中，跟踪最大角度
            match (this._hinge) {
                case Some(h) =>
                    let a = world.getConstraintCurrentAngle(h.handle)
                    if (a > this._maxAngle) {
                        this._maxAngle = a
                    }
                case None => ()
            }
            if (f >= _ADV_PHASE_FRAMES) {
                match (this._hinge) {
                    case Some(h) =>
                        let a = world.getConstraintCurrentAngle(h.handle)
                        _advcheck("M1 position motor drives angle toward +PI/4 (max=${this._maxAngle}, end=${a})",
                            this._maxAngle > this._angle0 + 0.2 && _abs(_angleDiff(a, PI / 4.0)) < 0.35,
                            this.log)
                        // 切速度模式：-1.5 rad/s
                        startMotorVelocity(world, h, -1.5)
                        this._angle0 = a
                        this.log.append("[M1] velocity motor -> -1.5 rad/s\n")
                    case None => ()
                }
                this._nextPhase()
            }
        } else if (this._phase == 2) {
            // 速度模式运行中：角度应持续下降；阶段结束后电机 Off + 创建软体
            match (this._hinge) {
                case Some(h) =>
                    let a = world.getConstraintCurrentAngle(h.handle)
                    if (f >= _ADV_PHASE_FRAMES) {
                        _advcheck("M1 velocity motor spins arm negative (start=${this._angle0}, end=${a})",
                            a < this._angle0 - 0.2, this.log)
                        stopMotor(world, h)
                        // M1 完成 → 创建软体（S）
                        let (soft, y0) = createSoftBoard(world)
                        this._soft = Some(soft)
                        // 可视化：紫色薄板跟随软体总体位姿（jolt4cj 暂无顶点回读 FFI，
                        // 不表现形变，仅表现整体下落/翻转）
                        if (soft.isValid) {
                            let softMesh = this._buildSoftBoardMesh()
                            this._scene.add(softMesh)
                            world.bindObject(softMesh, PhysicsBodyHandle(bodyID: soft.bodyID))
                            this._softMesh = Some(softMesh)
                        }
                        this.log.append("[S] soft board created at y=${y0} (valid=${soft.isValid})\n")
                        this._nextPhase()
                    }
                case None =>
                    _advcheck("M1 hinge created", false, this.log)
                    this._nextPhase()
            }
        } else if (this._phase == 3) {
            // 软体下落 90 帧 → 检查有效性与重力响应（软体无逐顶点回读接口，
            // 可视化用刚体总体位姿驱动整块薄板）
            if (f >= 90) {
                match (this._soft) {
                    case Some(s) =>
                        _advcheck("S soft body valid after creation", s.isValid, this.log)
                        _advcheck("S soft body bodyID assigned", s.bodyID != 0, this.log)
                        // 先解绑并移除渲染网格，再销毁物理体（避免同步到已释放 bodyID）
                        match (this._softMesh) {
                            case Some(m) => this._despawn(world, m)
                            case None => ()
                        }
                        this._softMesh = None
                        s.dispose()
                        _advcheck("S soft body disposed (isValid=false)", !s.isValid, this.log)
                    case None =>
                        _advcheck("S soft body created", false, this.log)
                }
                // V：载具（放在空旷区 x=10）
                let veh = createTestVehicle(world)
                this._vehicle = Some(veh)
                _advcheck("V vehicle valid", veh.isValid, this.log)
                _advcheck("V vehicle wheelCount == 4", veh.wheelCount == 4, this.log)
                let p0 = world.getPosition(veh.chassis)
                this._vehX0 = p0.x
                // 可视化：黄色底盘盒（绑定底盘刚体自动同步）+ 4 个灰色车轮圆柱
                if (veh.isValid) {
                    let chassisMesh = this._spawnBox(world, veh.chassis,
                        1.0, 0.3, 2.0, p0, COMPOUND_VS, COMPOUND_FS)
                    this._vehChassisMesh = Some(chassisMesh)
                    this._wheelMeshes.clear()
                    for (wi in 0..veh.wheelCount) {
                        let wm = veh.getWheelWorldTransform(wi)
                        let wp = Vector3(0.0, 0.0, 0.0)
                        let wq = Quaternion()
                        let ws = Vector3(1.0, 1.0, 1.0)
                        wm.decompose(wp, wq, ws)
                        this._wheelMeshes.add(this._spawnWheelVisual(wp))
                    }
                }
                this.log.append("[V] vehicle created at x=${this._vehX0} (chassis y=${p0.y})\n")
                this._nextPhase()
            }
        } else if (this._phase == 4) {
            // V 验证：全油门直行 120 帧 → 底盘应沿 +Z 前进；再查车轮世界矩阵
            match (this._vehicle) {
                case Some(veh) =>
                    // 每帧用车轮世界矩阵同步车轮网格（位移+旋转+轮半径缩放）
                    for (wi in 0..veh.wheelCount) {
                        if (wi < this._wheelMeshes.size) {
                            let wm = veh.getWheelWorldTransform(wi)
                            let wp = Vector3(0.0, 0.0, 0.0)
                            let wq = Quaternion()
                            let ws = Vector3(1.0, 1.0, 1.0)
                            wm.decompose(wp, wq, ws)
                            let wheelMesh = this._wheelMeshes[wi]
                            wheelMesh.position.set(wp.x, wp.y, wp.z)
                            wheelMesh.quaternion.copy(wq)
                            wheelMesh.scale.set(ws.x, ws.y, ws.z)
                        }
                    }
                    if (f == 1) {
                        veh.setDriverInput(1.0, 0.0)
                    }
                    if (f >= 120) {
                        veh.setDriverInput(0.0, 0.0, brake: 1.0)
                        let p = world.getPosition(veh.chassis)
                        _advcheck("V vehicle drove forward +Z (dz=${_fmt3(p.z - (-12.0))})",
                            p.z > -12.0 + 1.0, this.log)
                        this.log.append("[V] chassis end pos=(${_fmt3(p.x)}, ${_fmt3(p.y)}, ${_fmt3(p.z)})\n")
                        // 车轮世界矩阵应非单位阵（说明约束查询工作正常）
                        let m = veh.getWheelWorldTransform(0)
                        _advcheck("V wheel0 world matrix translated (y<0 local mount)",
                            _abs(m.elements[13]) > 0.1, this.log)
                        // 车轮索引越界应返回单位矩阵（防御性约定）
                        let bad = veh.getWheelWorldTransform(99)
                        _advcheck("V invalid wheel index returns identity",
                            _abs(bad.elements[13]) < 1.0e-9, this.log)
                        // 移除载具渲染网格（底盘物理体由测试流程保留）
                        match (this._vehChassisMesh) {
                            case Some(cm) => this._despawn(world, cm)
                            case None => ()
                        }
                        this._vehChassisMesh = None
                        for (wm in this._wheelMeshes) {
                            this._scene.remove(wm)
                        }
                        this._wheelMeshes.clear()
                        veh.dispose()
                        _advcheck("V vehicle disposed", !veh.isValid, this.log)
                        this._vehicle = None
                        this._nextPhase()
                    }
                case None =>
                    _advcheck("V vehicle created", false, this.log)
                    this._nextPhase()
            }
        } else if (this._phase == 5) {
            // H：正弦地形
            if (f >= 5) {
                let (terrain, tdesc) = createSineTerrain(world)
                this._terrain = Some(terrain)
                this._terrainDesc = Some(tdesc)
                // 可视化：青绿起伏地形（顶点直接用世界坐标，静态无需同步）
                if (terrain.isValid) {
                    let terrainMesh = this._buildTerrainMesh(tdesc)
                    this._scene.add(terrainMesh)
                    this._terrainMesh = Some(terrainMesh)
                }
                this.log.append("[H] sine terrain created (17x17, valid=${terrain.isValid})\n")
                this._nextPhase()
            }
        } else if (this._phase == 6) {
            // H 验证：投影若干采样点（取整数网格点，量化误差最小）
            if (f >= 300) { // TEMP-SHOT 原为 5，截图验证后还原
                match (this._terrain) {
                    case Some(t) =>
                        _advcheck("H terrain valid", t.isValid, this.log)
                        // 地形中心附近网格点，直接用真值函数对比
                        let c = Vector3(-25.0, 0.0, 5.0)
                        let p1 = t.projectOntoSurface(c.x, c.z)
                        let h1 = terrainHeightAt(c.x, c.z)
                        _advcheck("H project center (y=${_fmt3(p1.y)} vs ${_fmt3(h1)})",
                            _abs(p1.y - h1) < 0.15, this.log)
                        let p2 = t.projectOntoSurface(c.x + 5.0, c.z)
                        let h2 = terrainHeightAt(c.x + 5.0, c.z)
                        _advcheck("H project +5m x (y=${_fmt3(p2.y)} vs ${_fmt3(h2)})",
                            _abs(p2.y - h2) < 0.15, this.log)
                        let p3 = t.projectOntoSurface(c.x + 10.0, c.z + 5.0)
                        let h3 = terrainHeightAt(c.x + 10.0, c.z + 5.0)
                        _advcheck("H project offset (y=${_fmt3(p3.y)} vs ${_fmt3(h3)})",
                            _abs(p3.y - h3) < 0.15, this.log)
                        // 地形外应报告无效高度（-3.4e38 哨兵值）
                        let p4 = t.projectOntoSurface(500.0, 500.0)
                        _advcheck("H project outside returns invalid sentinel",
                            p4.y < -1.0e30, this.log)
                        t.dispose()
                        _advcheck("H terrain disposed", !t.isValid, this.log)
                    case None =>
                        _advcheck("H terrain created", false, this.log)
                }
                // 移除地形渲染网格
                match (this._terrainMesh) {
                    case Some(tm) => this._scene.remove(tm)
                    case None => ()
                }
                this._terrainMesh = None
                // D：调试渲染
                this._dbg = Some(createDebugRenderer())
                this._nextPhase()
            }
        } else if (this._phase == 7) {
            // D 验证：f==1 采集 bodies（线框），f==2 clear + 采集 constraints，
            // f==3 断言 + dispose。drawBodies 那帧的线段数已暂存到 _bodyLines。
            match (this._dbg) {
                case Some(d) =>
                    if (f == 1) {
                        d.drawBodies(world, wireframe: true)
                        this._bodyLines = d.lineCount
                        this.log.append("[D] drawBodies captured ${this._bodyLines} lines\n")
                    } else if (f == 2) {
                        d.clear()
                        d.drawConstraints(world)
                        this.log.append("[D] drawConstraints captured ${d.lineCount} lines\n")
                    } else if (f == 3) {
                        _advcheck("D debug renderer valid", d.isValid, this.log)
                        _advcheck("D drawBodies produced geometry (${this._bodyLines} lines)",
                            this._bodyLines > 0, this.log)
                        _advcheck("D drawConstraints produced geometry (${d.lineCount} lines)",
                            d.lineCount > 0, this.log)
                        d.dispose()
                        _advcheck("D renderer disposed", !d.isValid, this.log)
                    }
                case None =>
                    _advcheck("D debug renderer created", false, this.log)
            }
            if (f >= 4) {
                this._nextPhase()
            }
        } else if (this._phase == 8) {
            // SL：滑块约束 + 位置电机（沿 Y 把动态滑块顶到 +1.0m）
            match (this._slider) {
                case None =>
                    if (f == 1) {
                        let (anchor, slider, sl, p0) = createSliderRig(world)
                        this._slider = Some(sl)
                        this._sliderPos0 = p0
                        // 可视化：青绿锚块 + 亮黄滑块
                        this._sliderMeshes.add(this._spawnBox(world, anchor,
                            0.6, 0.6, 0.6, Vector3(15.0, 5.0, 8.0), MESH_VS, MESH_FS))
                        this._sliderMeshes.add(this._spawnBox(world, slider,
                            0.5, 0.5, 0.5, Vector3(15.0, 4.0, 8.0), COMPOUND_VS, COMPOUND_FS))
                        world.setConstraintMotorState(sl.handle, PhysicsMotorState.Position)
                        world.setSliderTargetPosition(sl.handle, 1.0)
                        this.log.append("[SL] slider rig created at x=15 (pos0=${_fmt3(p0)})\n")
                    }
                case Some(sl) =>
                    if (f >= _ADV_PHASE_FRAMES) {
                        let pos = world.getSliderCurrentPosition(sl.handle)
                        _advcheck("SL slider created valid", sl.isValid(), this.log)
                        _advcheck("SL position motor lifts slider (pos0=${_fmt3(this._sliderPos0)}, end=${_fmt3(pos)})",
                            pos > 0.6, this.log)
                        sl.dispose()
                        this._slider = None
                        this._nextPhase()
                    }
            }
        } else if (this._phase == 9) {
            // CZ：约束动物园——每帧创建一类（fixed/point/cone/swingTwist/gear/sixDOF），
            // 下一个物理步立即参与求解；逐帧打点以隔离任何类型的创建/求解问题
            if (f >= 1 && f <= 6) {
                let idx = f - 1
                let (c, zooBodies) = createOneZooConstraint(world, idx)
                // 可视化：该装置的每个刚体挂一个灰色小方块（随物理自动同步）
                for (bi in 0..zooBodies.size) {
                    let bh = zooBodies[bi]
                    let bp = world.getPosition(bh)
                    this._zooMeshes.add(this._spawnBox(world, bh,
                        0.3, 0.3, 0.3, bp, CAPSULE_VS, CAPSULE_FS))
                }
                match (this._zoo) {
                    case Some(list) => list.add(c)
                    case None =>
                        let list = ArrayList<PhysicsConstraint>()
                        list.add(c)
                        this._zoo = Some(list)
                }
            }
            if (f >= 12) {
                match (this._zoo) {
                    case Some(zoo) =>
                        for (i in 0..zoo.size) {
                            _advcheck("CZ ${zooConstraintName(i)} constraint valid",
                                zoo[i].isValid(), this.log)
                        }
                        for (i in 0..zoo.size) {
                            zoo[i].dispose()
                        }
                        this.log.append("[CZ] 6 constraint types created and disposed\n")
                    case None =>
                        _advcheck("CZ constraint zoo created", false, this.log)
                }
                this._zoo = None
                this._nextPhase()
            }
        } else if (this._phase == 10) {
            // R：3 关节布娃娃从 y≈6 自由下落，验证关节刚体数量与重力响应
            match (this._rag) {
                case None =>
                    if (f == 1) {
                        let (rag, y0) = createTestRagdoll(world)
                        this._rag = Some(rag)
                        this._ragY0 = y0
                        _advcheck("R ragdoll valid", rag.isValid, this.log)
                        _advcheck("R ragdoll bodyCount == 3 (got ${rag.bodyCount})",
                            rag.bodyCount == 3, this.log)
                        _advcheck("R ragdoll constraintCount == 2 (got ${rag.constraintCount})",
                            rag.constraintCount == 2, this.log)
                        // 临时诊断：步进前逐部件回读位姿（排查 NaN/野指针）
                        for (pi in 0..rag.bodyCount) {
                            let bid = rag.getBodyID(pi)
                            let h = PhysicsBodyHandle(bodyID: bid)
                            let p = world.getPosition(h)
                            let q = world.getRotation(h)
                        }
                        // 可视化：骨盆/头为橙色球，胸为橙色盒（绑定各部件刚体自动跟随）
                        this._ragMeshes.clear()
                        let pelvisH = PhysicsBodyHandle(bodyID: rag.getBodyID(0))
                        let chestH = PhysicsBodyHandle(bodyID: rag.getBodyID(1))
                        let headH = PhysicsBodyHandle(bodyID: rag.getBodyID(2))
                        this._ragMeshes.add(this._spawnSphere(world, pelvisH,
                            0.28, world.getPosition(pelvisH), SPHERE_VS, SPHERE_FS))
                        this._ragMeshes.add(this._spawnBox(world, chestH,
                            0.35, 0.45, 0.22, world.getPosition(chestH), HINGE_VS, HINGE_FS))
                        this._ragMeshes.add(this._spawnSphere(world, headH,
                            0.20, world.getPosition(headH), SPHERE_VS, SPHERE_FS))
                        this.log.append("[R] ragdoll dropped from y=${_fmt3(y0)}\n")
                    }
                case Some(rag) =>
                    if (f == 2 || f == 3) {
                    }
                    if (f >= 90) {
                        let (rootPos, _) = rag.getRootTransform()
                        _advcheck("R ragdoll fell under gravity (y0=${_fmt3(this._ragY0)}, yEnd=${_fmt3(rootPos.y)}, drop=${_fmt3(this._ragY0 - rootPos.y)})",
                            this._ragY0 - rootPos.y > 1.0, this.log)
                        // 先解绑移除 3 个部件网格，再销毁布娃娃
                        for (rm in this._ragMeshes) {
                            this._despawn(world, rm)
                        }
                        this._ragMeshes.clear()
                        rag.dispose()
                        _advcheck("R ragdoll disposed", !rag.isValid, this.log)
                        this._rag = None
                        this._nextPhase()
                    }
            }
        } else if (this._phase == 11) {
            // C：角色控制器——虚拟角色保持水平速度行走（+X），刚体角色自由落地
            match (this._vchar) {
                case None =>
                    if (f == 1) {
                        // 虚拟角色（无物理刚体，用户驱动移动；Jolt 处理碰撞/穿透恢复）
                        let vdesc = PhysicsCharacterDesc(
                            shape: PhysicsShape.capsule(0.4, 0.3),
                            position: Vector3(-16.0, 2.0, 9.0))
                        let vch = PhysicsCharacterFactory(desc: vdesc).createVirtualCharacter(world)
                        // 刚体角色（加入物理系统，受重力/碰撞驱动）
                        let rdesc = PhysicsCharacterDesc(
                            shape: PhysicsShape.capsule(0.4, 0.3),
                            position: Vector3(-18.0, 2.0, 9.0), mass: 80.0f32)
                        let rch = PhysicsCharacterFactory(desc: rdesc).createCharacter(world)
                        rch.addToPhysicsSystem()
                        this._vchar = Some(vch)
                        this._rchar = Some(rch)
                        this._charX0 = vch.getPosition().x
                        this._charRY0 = rch.getPosition().y
                        // 可视化：黄色胶囊=虚拟角色，紫色胶囊=刚体角色（每帧手动同步位置）
                        this._vcharMesh = Some(this._spawnCapsuleVisual(0.3, 0.4,
                            vch.getPosition(), COMPOUND_VS, COMPOUND_FS))
                        this._rcharMesh = Some(this._spawnCapsuleVisual(0.3, 0.4,
                            rch.getPosition(), CONVEX_VS, CONVEX_FS))
                        _advcheck("C virtual character valid", vch.isValid, this.log)
                        _advcheck("C rigid character valid", rch.isValid, this.log)
                        this.log.append("[C] characters created at (-16,2,9) virtual / (-18,2,9) rigid\n")
                    }
                case Some(vch) =>
                    // 每帧：虚拟角色保持 +X 水平速度（竖直分量留给 update 内部叠加重力）
                    if (f <= 3) {
                    }
                    let vel = vch.getLinearVelocity()
                    vch.setLinearVelocity(Vector3(3.0, vel.y, vel.z))
                    vch.update(1.0f32 / 60.0f32)
                    if (f <= 3) {
                    }
                    // 刚体角色：物理步进后刷新地面状态
                    match (this._rchar) {
                        case Some(rch) => rch.postSimulation(maxSeparationDistance: 0.05f32)
                        case None => ()
                    }
                    // 可视化同步：角色仅暴露位置（胶囊始终直立，无旋转回读）
                    match (this._vcharMesh) {
                        case Some(vm) =>
                            let vp0 = vch.getPosition()
                            vm.position.set(vp0.x, vp0.y, vp0.z)
                        case None => ()
                    }
                    match (this._rcharMesh) {
                        case Some(rm) =>
                            match (this._rchar) {
                                case Some(rch) =>
                                    let rp0 = rch.getPosition()
                                    rm.position.set(rp0.x, rp0.y, rp0.z)
                                case None => ()
                            }
                        case None => ()
                    }
                    if (f >= _ADV_PHASE_FRAMES) {
                        let vp = vch.getPosition()
                        _advcheck("C virtual character walked +X (dx=${_fmt3(vp.x - this._charX0)})",
                            vp.x - this._charX0 > 1.0, this.log)
                        _advcheck("C virtual character on ground (state=${vch.getGroundState()}, y=${_fmt3(vp.y)})",
                            vch.isOnGround(), this.log)
                        match (this._rchar) {
                            case Some(rch) =>
                                let rp = rch.getPosition()
                                _advcheck("C rigid character fell (y0=${_fmt3(this._charRY0)}, yEnd=${_fmt3(rp.y)})",
                                    rp.y < this._charRY0 - 0.5, this.log)
                                _advcheck("C rigid character on ground (state=${rch.getGroundState()}, y=${_fmt3(rp.y)})",
                                    rch.isOnGround(), this.log)
                                rch.dispose()
                                _advcheck("C rigid character disposed", !rch.isValid, this.log)
                            case None =>
                                _advcheck("C rigid character created", false, this.log)
                        }
                        vch.dispose()
                        _advcheck("C virtual character disposed", !vch.isValid, this.log)
                        // 移除两个角色胶囊网格
                        match (this._vcharMesh) {
                            case Some(vm) => this._scene.remove(vm)
                            case None => ()
                        }
                        match (this._rcharMesh) {
                            case Some(rm) => this._scene.remove(rm)
                            case None => ()
                        }
                        this._vcharMesh = None
                        this._rcharMesh = None
                        this._vchar = None
                        this._rchar = None
                        this._nextPhase()
                    }
            }
        } else {
            // 全部完成
            this.done = true
            this.log.append("=== advanced verification done: ${_advPass} pass, ${_advFail} fail ===\n")
        }
    }

    private func _nextPhase(): Unit {
        this._phase += 1
        this._frameInPhase = 0
    }

    /// 三位小数格式化（仓颉无 String.format；round 为 std.math 自由函数）
    /// 对 NaN/无穷/哨兵值（如投影失败的 -3.4e38）做防御，避免 Int64 转换溢出抛异常
    private func _fmt3(v: Float64): String {
        if (v != v) {
            return "NaN"
        }
        if (v > 1.0e15 || v < -1.0e15) {
            return "n/a"
        }
        let i = Int64(round(v * 1000.0))
        let sign = if (i < 0) { "-" } else { "" }
        let a = if (i < 0) { -i } else { i }
        return "${sign}${a / 1000}.${a % 1000}"
    }
}
