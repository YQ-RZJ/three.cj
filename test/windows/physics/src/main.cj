package threePhysicsTest

/**
 * Three.cj 物理引擎渲染测试入口（v2 生命周期模式）
 *
 * 场景描述：
 * - 一个大平面作为静态地面（Plane + PhysicsShape.Plane，Static 刚体）
 * - 若干彩色立方体从空中下落（Box + Dynamic 刚体，受重力）
 * - 若干球体（Sphere + Dynamic，弹性更高）
 * - 一个胶囊体（Capsule + Dynamic）
 *
 * 物理引擎独立线程运行（rycj SThread），每帧步进后将刚体 transform 同步到 Mesh。
 * 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose）：
 * onInit 初始化渲染器 + PhysicsWorld + 场景，onFrame 读固定快照并步进物理 + 渲染，
 * onClose 清理约束/刚体/物理世界/渲染器。
 *
 * 可插拔后端演示：PhysicsWorld 默认使用 JoltBackend；
 * 替换底层物理库只需构造不同的 IPhysicsBackend 实现传入。
 */

import std.io.*
import std.fs.{File, Path as FsPath}
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.buffer.*
import three.rendering.cameras.*
import three.physics.interfaces.*
import three.physics.world.*
import three.physics.body.*
import three.physics.binding.*
import three.physics.constraint.*
import std.collection.*
import std.math.*
import std.time.*

/// 格式化浮点数为 3 位小数（日志可读性；截断不四舍五入）
func _fmt3(n: Float64): String {
    let v = floor(n * 1000.0) / 1000.0
    return v.toString()
}

// =============================================================================
// 碰撞事件监听器（IPhysicsSensorListener 测试）：记录接触/激活/休眠事件
// =============================================================================

/// 测试监听器：统计各类事件数量，供碰撞监听验证
public class TestSensorListener <: IPhysicsSensorListener {
    /// 接触建立计数
    public var addedCount: Int64 = 0
    /// 接触持续计数
    public var persistedCount: Int64 = 0
    /// 接触移除计数
    public var removedCount: Int64 = 0
    /// 激活计数
    public var activatedCount: Int64 = 0
    /// 休眠计数
    public var deactivatedCount: Int64 = 0
    /// 最近一次接触的刚体对
    public var lastPair: (UInt32, UInt32) = (0u32, 0u32)

    public func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit {
        match (event) {
            case PhysicsContactEvent.Added => this.addedCount += 1
            case PhysicsContactEvent.Persisted => this.persistedCount += 1
            case PhysicsContactEvent.Removed => this.removedCount += 1
        }
        this.lastPair = (bodyID1, bodyID2)
    }

    public func onBodyActivated(bodyID: UInt32): Unit {
        this.activatedCount += 1
    }

    public func onBodyDeactivated(bodyID: UInt32): Unit {
        this.deactivatedCount += 1
    }
}

// =============================================================================
// 碰撞查询验证（raycastAll / collidePoint / collideShape / castShape）
// =============================================================================

/// 断言工具：写日志并累计结果
private var _qPass: Int64 = 0
private var _qFail: Int64 = 0

private func _qcheck(name: String, cond: Bool, log: StringBuilder): Unit {
    if (cond) {
        _qPass += 1
        log.append("  [PASS] ${name}\n")
    } else {
        _qFail += 1
        log.append("  [FAIL] ${name}\n")
    }
}

/// 执行一轮碰撞查询验证：结果落盘 physics_query.log
public func verifyCollisionQueries(world: PhysicsWorld): Unit {
    let log = StringBuilder()
    log.append("=== 碰撞查询验证（raycastAll/collidePoint/collideShape/castShape） ===\n")
    let bodyID0: UInt32 = 0  // 地面 bodyID（第一个创建的刚体）

    // ---- [A] raycastAll：垂直向下射线，应命中地面及下落物体 ----
    log.append("[A] raycastAll 批量射线\n")
    let downHits = world.raycastAll(Vector3(0.0, 30.0, 0.0), Vector3(0.0, -60.0, 0.0))
    _qcheck("向下射线至少 1 个命中（地面）", downHits.size >= 1, log)
    var hitGround = false
    for (h in downHits) {
        if (h.bodyID == bodyID0) { hitGround = true }
        log.append("    命中 body=${h.bodyID} frac=${_fmt3(Float64(h.fraction))} " + 
            "point=(${_fmt3(h.point.x)},${_fmt3(h.point.y)},${_fmt3(h.point.z)}) " + 
            "normal=(${_fmt3(h.normal.x)},${_fmt3(h.normal.y)},${_fmt3(h.normal.z)})\n")
    }
    _qcheck("命中列表按 fraction 升序", downHits.size < 2 || downHits[0].fraction <= downHits[1].fraction, log)
    _qcheck("命中点 Y 接近 0（地面）", if (downHits.size > 0) {
        let y = downHits[0].point.y
        y > -1.0 && y < 1.0
    } else { false }, log)
    _qcheck("命中法线已填充（非零）", if (downHits.size > 0) {
        let n = downHits[0].normal
        n.x * n.x + n.y * n.y + n.z * n.z > 0.01
    } else { false }, log)

    // ---- [B] collidePoint：点碰撞 ----
    log.append("[B] collidePoint 点碰撞\n")
    let inside = world.collidePoint(Vector3(0.0, 0.2, 0.0))
    _qcheck("地面内部点命中", inside.size >= 1, log)
    let outside = world.collidePoint(Vector3(0.0, 30.0, 0.0))
    _qcheck("空中点无命中", outside.size == 0, log)

    // ---- [C] collideShape：形状 vs 世界 ----
    log.append("[C] collideShape 形状碰撞\n")
    let probe = PhysicsShape.box(1.0, 1.0, 1.0)
    let overlap = world.collideShape(probe,
        Vector3(0.0, 0.3, 0.0), Quaternion())
    _qcheck("盒子与地面重叠命中", overlap.size >= 1, log)
    if (overlap.size > 0) {
        let h0 = overlap[0]
        log.append("    命中 body=${h0.bodyID} depth=${_fmt3(Float64(h0.penetrationDepth))} " + 
            "point=(${_fmt3(h0.point.x)},${_fmt3(h0.point.y)},${_fmt3(h0.point.z)})\n")
    }
    let free = world.collideShape(probe,
        Vector3(0.0, 30.0, 0.0), Quaternion())
    _qcheck("空中盒子无命中", free.size == 0, log)

    // ---- [D] castShape：形状投射 ----
    log.append("[D] castShape 形状投射\n")
    let castHits = world.castShape(probe,
        Vector3(0.0, 10.0, 0.0), Quaternion(),
        Vector3(0.0, -20.0, 0.0))
    _qcheck("下落投射命中地面", castHits.size >= 1, log)
    if (castHits.size > 0) {
        let h0 = castHits[0]
        log.append("    命中 body=${h0.bodyID} frac=${_fmt3(Float64(h0.fraction))} " + 
            "point=(${_fmt3(h0.point.x)},${_fmt3(h0.point.y)},${_fmt3(h0.point.z)})\n")
        _qcheck("投射命中 fraction 在 (0,1]", h0.fraction > 0.0f32 && h0.fraction <= 1.0f32, log)
        _qcheck("投射命中点在地面附近", h0.point.y > -1.0 && h0.point.y < 1.5, log)
    }

    // 结果汇总
    log.append("\n=== 碰撞查询结果 ===\n")
    log.append("  PASS: ${_qPass}\n")
    log.append("  FAIL: ${_qFail}\n")
    log.append(if (_qFail == 0) { "  == 查询全部通过 ==\n" } else { "  == 存在失败 ==\n" })
    let out = log.toString()
    println(out)
    try {
        File.appendTo(FsPath("./physics_query.log"), out.toArray())
    } catch (_) {
        // 忽略落盘失败
    }
}

/**
 * v2 窗口子类：覆写生命周期回调。
 * 渲染器/PhysicsWorld/场景在 onInit 创建（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧物理步进 + 渲染在 onFrame 执行（读固定快照），清理（约束/刚体/物理世界/渲染器）在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染/物理状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    var renderer: ThreeRenderer = ThreeRenderer()
    var physicsWorld: PhysicsWorld = PhysicsWorld()
    var sensorListener: TestSensorListener = TestSensorListener()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var bodies: ArrayList<RigidBody> = ArrayList<RigidBody>()
    var constraints: ArrayList<PhysicsConstraint> = ArrayList<PhysicsConstraint>()

    var startTime: MonoTime = MonoTime.now()
    var frame: Int64 = 0
    let dt: Float32 = 1.0f32 / 60.0f32

    // 力演示目标：圆柱体（每 60 帧施加一次侧向冲量，让其持续滚动）
    var forceTarget: Option<RigidBody> = None
    // 运动学演示：第 6 个立方体改为运动学刚体做往返平移（用于展示 moveKinematic）
    var kinematicTarget: Option<RigidBody> = None
    var kinematicDir: Float64 = 1.0

    // 高级验证驱动器（电机/软体/载具/高度场/调试渲染，advanced_test.cj）
    let advDriver: AdvancedTestDriver = AdvancedTestDriver()

    // ===== 生命周期：窗口创建后（初始化渲染器 + 物理世界 + 场景） =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[2/6] 初始化 BgfxRenderer（绑定窗口 ${hwnd}, ${w}x${h}）...")
        println("[ADV] onInit: before getPixelRatio")
        let dpr = this.getPixelRatio()
        println("[ADV] onInit: after getPixelRatio dpr=${dpr}")
        this.renderer.setPixelRatio(Float64(dpr))
        println("[ADV] onInit: before initBgfx")
        let ok = this.renderer.initBgfx(hwnd, w, h)
        println("[ADV] onInit: after initBgfx ok=${ok}")
        if (!ok) {
            println("  ThreeRenderer.initBgfx 失败!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x1a, 0x1a, 0x2e))
        println("  ThreeRenderer 初始化成功")
        println("")

        // ---- 步骤 3: 创建场景 + 物理世界 ----
        println("[3/6] 创建场景和物理世界...")
        let (scene, camera, bodies, constraints) = createPhysicsScene(w, h, this.physicsWorld, this.sensorListener)
        this.scene = scene
        this.camera = camera
        this.bodies = bodies
        this.constraints = constraints
        println("")

        // ---- 力演示目标初始化（原 runPhysicsRenderLoop 前置逻辑） ----
        this.forceTarget = None
        if (this.bodies.size > 8) {
            // bodies[7] = 圆柱体（0-5 立方体，6-8 球体，9 胶囊，10 圆柱）
            this.forceTarget = Some(this.bodies[10])
        }

        // ---- 运动学演示初始化：第 6 个立方体改为运动学刚体做往返平移 ----
        this.kinematicTarget = None
        if (this.bodies.size > 5) {
            let kb = this.bodies[5]
            // 运行时切换为运动学并赋予初始速度
            kb.setMotionTypeRuntime(PhysicsMotionType.Kinematic, activation: PhysicsActivation.Activate)
            this.kinematicTarget = Some(kb)
        }
        this.kinematicDir = 1.0

        // ---- 高级验证：装置创建（共享同一物理世界 + 渲染场景） ----
        this.advDriver.setup(this.physicsWorld, this.scene)

        println("[4/6] 进入渲染+物理循环（onFrame 由窗口泵线程驱动）...")
        println("  按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——物理步进 + 渲染） =====
    public override func onFrame(dt: Float64): Unit {
        // [DBG] 自动退出：1200 帧（≈20s）后自动关闭，便于无人值守验证
        // （高级验证阶段 0-11：电机/软体/载具/高度场/调试渲染/滑块/约束动物园/布娃娃/角色）
        if (this.frame >= 1200) {
            println("[DBG] auto-close at frame=${this.frame}")
            this.requestClose()
            return
        }
        // 力演示：每 120 帧给圆柱体一次侧向冲量（推动滚动）
        if (this.frame % 120 == 0) {
            match (this.forceTarget) {
                case Some(fb) =>
                    fb.addImpulse(0.0, 0.0, 2.0)
                case None => ()
            }
        }

        // 运动学演示：控制第 6 个立方体沿 X 轴往返平移
        match (this.kinematicTarget) {
            case Some(kb) =>
                let pos = kb.getPosition()
                let nx = pos.x + this.kinematicDir * 0.08
                let limit = 4.0
                if (nx > limit) { this.kinematicDir = -1.0 }
                if (nx < -limit) { this.kinematicDir = 1.0 }
                let targetPos = Vector3(nx, pos.y, pos.z)
                kb.moveKinematic(targetPos, kb.getRotation(), this.dt)
            case None => ()
        }

        // 步进物理世界（独立物理线程执行，主线程等待完成）
        this.physicsWorld.update(this.dt, collisionSteps: 1)

        // 高级验证状态机推进（物理步进之后，读到的 transform 是最新值）
        this.advDriver.tick(this.physicsWorld)

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 渲染场景（物理刚体的 transform 已同步到 Mesh）
        this.renderer.render(this.scene, this.camera)

        this.frame++
        // 每 120 帧打印一次日志（stdout 可能被缓冲，同时落盘到文件便于验证）
        if (this.frame % 15 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            // 打印第一个立方体的状态 + 约束状态
            var info: String = "N/A"
            if (this.bodies.size > 0) {
                let b0 = this.bodies[0]
                let pos = b0.getPosition()
                info = "Box0 pos=(${pos.x}, ${pos.y}, ${pos.z}) active=${b0.isActive()}"
            }
            var cInfo: String = "约束: ${this.constraints.size} 个"
            if (this.constraints.size > 0) {
                cInfo += " hinge=${this.constraints[0].isEnabled()}"
            }
            println("  [render] frame=${this.frame} fps=${fps} ${info} ${cInfo}")
            // 位置落盘（物理验证用，绕开 stdout 缓冲）
            // bodies 顺序（创建顺序，索引与下方 names 对齐）:
            //   0-5  下落立方体 Box0..Box5（Box5 运行时切 Kinematic 往返）
            //   6-8  弹跳球体 Sphere0..Sphere2
            //   9    胶囊 Capsule,  10 圆柱 Cylinder（力演示）
            //   11   铰链支柱 Post（Static）, 12 铰链摆杆 Arm
            //   13/14 距离约束双球 BallA/BallB
            //   15   Mesh 三角网格坡道 Ramp（Static）
            //   16   ConvexHull 凸包 Hull, 17 Compound 复合哑铃
            let names = [
                "Box0", "Box1", "Box2", "Box3", "Box4", "Box5",
                "Sphere0", "Sphere1", "Sphere2", "Capsule", "Cylinder",
                "Post", "Arm", "BallA", "BallB",
                "Ramp", "Hull", "Compound",
            ]
            var detail: String = ""
            for (i in 0..this.bodies.size) {
                if (i >= names.size) { break }
                let b = this.bodies[i]
                let p = b.getPosition()
                let v = b.getLinearVelocity()
                detail += " ${names[i]}=(${_fmt3(p.x)},${_fmt3(p.y)},${_fmt3(p.z)})v=(${_fmt3(v.x)},${_fmt3(v.y)},${_fmt3(v.z)})"
            }
            // 摆杆角速度（验证往复摆动）
            if (this.bodies.size > 12) {
                let armV = this.bodies[12].getAngularVelocity()
                detail += " armW=(${_fmt3(armV.x)},${_fmt3(armV.y)},${_fmt3(armV.z)})"
            }
            // 双球间距（验证距离约束 0.5~1.2 区间）
            if (this.bodies.size > 14) {
                let pa = this.bodies[13].getPosition()
                let pb = this.bodies[14].getPosition()
                let dx = pa.x - pb.x
                let dy = pa.y - pb.y
                let dz = pa.z - pb.z
                detail += " ballDist=${_fmt3(sqrt(dx * dx + dy * dy + dz * dz))}"
            }
            let logLine = "frame=${this.frame} ${detail} ${cInfo}\n"
            try {
                File.appendTo(FsPath("./physics_pos.log"), logLine.toArray())
            } catch (_) {
                // 忽略落盘失败（不影响主循环）
            }
        }
    }

    // ===== 生命周期：关闭前（清理物理世界 + 渲染器 + 统计输出） =====
    public override func onClose(): Unit {
        println("")
        let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
        println("  运行时间: ${elapsed}s")
        println("  总帧数: ${this.frame}")
        if (elapsed > 0.0) {
            println("  平均 FPS: ${(Float64(this.frame) / elapsed).toString()}")
        }

        // ===== 碰撞事件监听器统计输出（接触/激活/休眠） =====
        println("")
        println("=== 碰撞事件监听器统计（TestSensorListener） ===")
        println("  接触建立 Added:     ${this.sensorListener.addedCount}")
        println("  接触持续 Persisted: ${this.sensorListener.persistedCount}")
        println("  接触移除 Removed:   ${this.sensorListener.removedCount}")
        println("  刚体激活 Activated: ${this.sensorListener.activatedCount}")
        println("  刚体休眠 Deactivated: ${this.sensorListener.deactivatedCount}")
        let listenerOk = this.sensorListener.addedCount > 0 || this.sensorListener.persistedCount > 0
        println(if (listenerOk) { "  监听器验证: [PASS] 收到接触事件" } else { "  监听器验证: [FAIL] 无接触事件" })
        let stats = "added=${this.sensorListener.addedCount} persisted=${this.sensorListener.persistedCount} " + 
            "removed=${this.sensorListener.removedCount} activated=${this.sensorListener.activatedCount} " + 
            "deactivated=${this.sensorListener.deactivatedCount}\n"
        try {
            File.appendTo(FsPath("./physics_listener.log"), stats.toArray())
        } catch (_) {
            // 忽略落盘失败
        }

        // ===== 高级验证日志落盘（physics_advanced.log） =====
        try {
            File.appendTo(FsPath("./physics_advanced.log"), this.advDriver.log.toString().toArray())
            println("高级验证日志已落盘 physics_advanced.log")
        } catch (_) {
            println("高级验证日志落盘失败")
        }

        // ---- 步骤 5: 清理物理世界 ----
        println("")
        println("[5/6] 清理物理世界...")
        // 先销毁约束（须在刚体销毁之前，避免悬空引用）
        for (c in this.constraints) {
            c.dispose()
        }
        for (b in this.bodies) {
            b.dispose()
        }
        this.physicsWorld.shutdown()
        println("  物理世界已关闭")

        // ---- 步骤 6: 关闭渲染器 ----
        println("")
        this.renderer.shutdown()
        println("[6/6] ThreeRenderer + WindowEngine 已关闭")
    }
}

main(): Int64 {
    println("=== Three.cj Physics + Rendering 测试 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，SDL3 跨平台实现） ----
    println("[1/6] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    let wok = win.start(title: "three4cj Physics + Rendering", width: 1280, height: 720)
    if (!wok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 步骤 4(续): 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}

// =============================================================================
// 场景创建：地面 + 下落立方体 + 球体 + 胶囊 + 圆柱 + 约束钟摆 + 力/运动学演示
// =============================================================================

/// 创建物理场景：返回 (Scene, Camera, RigidBody列表, Constraint列表)
/// @param world 物理世界（子类字段，onClose 中 shutdown）
/// @param listener 碰撞事件监听器（子类字段，用于 setContactListener 注册与统计输出）
public func createPhysicsScene(width: Int32, height: Int32, world: PhysicsWorld, listener: TestSensorListener): (Scene, PerspectiveCamera, ArrayList<RigidBody>, ArrayList<PhysicsConstraint>) {
    // 创建场景
    let scene = Scene()
    scene.name = "PhysicsTestScene"

    // 创建相机
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    // 取景需覆盖高级验证装置的分布：动物园 x∈[20,32.5]、地形中心(-25,0,5)、
    // 角色 x=-18、滑块 (15,*,8)，故相机拉高后退并略俯视场景中心
    camera.position.set(0.0, 14.0, 32.0)
    camera.lookAt(Vector3(0.0, 3.0, -2.0))
    camera.name = "MainCamera"
    println("  相机创建成功: 位置=(${camera.position.x}, ${camera.position.y}, ${camera.position.z})")

    // ===== 初始化物理世界（默认 JoltBackend，可插拔） =====
    let ok = world.start(maxBodies: 1024u32,
                               gravity: Vector3(0.0, -9.81, 0.0))
    if (!ok) {
        println("  [警告] 物理世界初始化失败！将无物理模拟")
    } else {
        println("  物理世界初始化成功: 后端=${world.backend.backendName()} 重力=(0,-9.81,0)")
    }

    // ===== 创建地面（静态刚体） =====
    let groundGeom = PlaneGeometry(width: 40.0, height: 40.0)
    // 旋转地面让它平铺（PlaneGeometry 默认在 XY 平面，法线 +Z）
    groundGeom.rotateX(-PI / 2.0)
    let groundMat = ShaderMaterial(GROUND_VS, GROUND_FS)
    let ground = Mesh(geometry: groundGeom, material: groundMat)
    ground.name = "Ground"
    ground.position.set(0.0, 0.0, 0.0)
    scene.add(ground)

    // 地面物理：Static 刚体 + Plane 形状
    let groundBody = PhysicsBinding.ground(world, ground, yPosition: 0.0)
    println("  地面创建成功: Static 刚体")

    // ===== 注册碰撞事件监听器（接触回调 + 激活/休眠回调） =====
    world.setContactListener(Some(listener))
    println("  碰撞事件监听器已注册（TestSensorListener）")

    // ===== 碰撞查询验证（此时世界仅有地面，断言确定性强） =====
    verifyCollisionQueries(world)

    // ===== 创建下落立方体（Dynamic 刚体） =====
    let bodies = ArrayList<RigidBody>()
    let boxColors = [
        Color(1.0, 0.2, 0.2),   // 红
        Color(0.2, 1.0, 0.3),   // 绿
        Color(0.3, 0.5, 1.0),   // 蓝
        Color(1.0, 0.9, 0.2),   // 黄
        Color(1.0, 0.5, 0.1),   // 橙
        Color(0.8, 0.2, 1.0),   // 紫
    ]
    let boxSize = 1.0
    for (i in 0..6) {
        let boxGeom = BoxGeometry(width: boxSize, height: boxSize, depth: boxSize)
        let boxMat = ShaderMaterial(BOX_VS, BOX_FS)
        // 给每个立方体设置颜色（通过 uniform 或顶点色——这里简化用顶点色）
        let box = Mesh(geometry: boxGeom, material: boxMat)
        box.name = "FallingBox_${i}"
        // 初始位置：空中，错开排列
        let x = (Float64(i) - 2.5) * 2.0
        let y = 8.0 + Float64(i) * 1.5
        let z = 0.0
        box.position.set(x, y, z)
        scene.add(box)

        // 物理绑定：Box 形状 + Dynamic 刚体
        let body = PhysicsBinding.meshBox(world, box,
            motionType: PhysicsMotionType.Dynamic,
            friction: 0.3, restitution: 0.4)
        bodies.add(body)
    }
    println("  创建 ${6} 个下落立方体（Dynamic）")

    // ===== 创建球体（Dynamic，高弹性） =====
    for (i in 0..3) {
        let sphereGeom = SphereGeometry(radius: 0.5, widthSegments: 16, heightSegments: 12)
        let sphereMat = ShaderMaterial(SPHERE_VS, SPHERE_FS)
        let sphere = Mesh(geometry: sphereGeom, material: sphereMat)
        sphere.name = "BouncingSphere_${i}"
        let x = (Float64(i) - 1.0) * 3.0
        let y = 6.0 + Float64(i) * 2.0
        let z = -2.0
        sphere.position.set(x, y, z)
        scene.add(sphere)

        // 物理绑定：Sphere 形状 + Dynamic，高弹性
        let body = PhysicsBinding.meshSphere(world, sphere,
            motionType: PhysicsMotionType.Dynamic,
            friction: 0.2, restitution: 0.8)
        bodies.add(body)
    }
    println("  创建 ${3} 个弹跳球体（Dynamic，restitution=0.8）")

    // ===== 创建胶囊体（Dynamic） =====
    let capGeom = CapsuleGeometry(radius: 0.4, length: 1.2)
    let capMat = ShaderMaterial(CAPSULE_VS, CAPSULE_FS)
    let capsule = Mesh(geometry: capGeom, material: capMat)
    capsule.name = "FallingCapsule"
    capsule.position.set(0.0, 10.0, 3.0)
    scene.add(capsule)

    let capBody = PhysicsBinding.meshCapsule(world, capsule,
        motionType: PhysicsMotionType.Dynamic,
        friction: 0.4, restitution: 0.3)
    bodies.add(capBody)
    println("  创建 1 个下落胶囊体（Dynamic）")

    // ===== 创建圆柱体（Dynamic，滚动演示） =====
    let cylGeom = CylinderGeometry(radiusTop: 0.5, radiusBottom: 0.5, height: 1.0)
    let cylMat = ShaderMaterial(CYLINDER_VS, CYLINDER_FS)
    let cylinder = Mesh(geometry: cylGeom, material: cylMat)
    cylinder.name = "RollingCylinder"
    cylinder.position.set(-4.0, 9.0, 2.0)
    scene.add(cylinder)

    let cylBody = PhysicsBinding.meshCylinder(world, cylinder,
        motionType: PhysicsMotionType.Dynamic,
        friction: 0.5, restitution: 0.2)
    bodies.add(cylBody)
    println("  创建 1 个圆柱体（Dynamic，滚动）")

    // ===== 创建约束钟摆（铰链约束演示：静态支柱 + 动态摆杆） =====
    let constraints = ArrayList<PhysicsConstraint>()

    // 静态支柱（顶部锚点）
    let postGeom = BoxGeometry(width: 0.3, height: 4.0, depth: 0.3)
    let postMat = ShaderMaterial(BOX_VS, BOX_FS)
    let post = Mesh(geometry: postGeom, material: postMat)
    post.name = "HingePost"
    post.position.set(3.0, 2.0, -4.0)
    scene.add(post)
    let postBody = PhysicsBinding.meshBox(world, post,
        motionType: PhysicsMotionType.Static, friction: 0.4, restitution: 0.2)
    bodies.add(postBody)

    // 动态摆杆（绕支柱顶端铰链旋转）
    // 视觉上摆杆保持竖直（质心在锚点正下方），靠创建后施加的质心水平线速度
    // 驱动往复摆动——竖直悬挂是稳定平衡，水平初速让摆杆绕锚点做单摆运动。
    // 注意：不能用 setAngularVelocity（绕质心自转会被铰链约束吸收），
    // 必须给质心水平线速度（等价于绕锚点的初始角速度 ω = v/L）。
    let armGeom = BoxGeometry(width: 0.4, height: 2.0, depth: 0.4)
    let armMat = ShaderMaterial(HINGE_VS, HINGE_FS)
    let arm = Mesh(geometry: armGeom, material: armMat)
    arm.name = "HingeArm"
    arm.position.set(3.0, 3.0, -4.0)
    scene.add(arm)
    let armBody = PhysicsBinding.meshBox(world, arm,
        motionType: PhysicsMotionType.Dynamic, friction: 0.3, restitution: 0.1)
    // 初始水平线速度：质心沿 +X 1.5 m/s（摆长 1.0 → 初始角速度 1.5 rad/s），驱动单摆
    armBody.setLinearVelocity(1.5, 0.0, 0.0)
    bodies.add(armBody)

    // 铰链连接：锚点在支柱顶端，轴沿 Z（让摆杆在 XZ 平面摆动）
    let hinge = PhysicsConstraint.hinge(world, postBody.handle, armBody.handle,
        Vector3(3.0, 4.0, -4.0), Vector3(0.0, 0.0, 1.0),
        limitMin: -1.2, limitMax: 1.2)
    constraints.add(hinge)
    println("  创建铰链约束（钟摆）: ${if (hinge.isValid()) { "成功" } else { "失败" }}")

    // ===== 距离约束演示（两个小球用距离约束连接） =====
    let ballAGeom = SphereGeometry(radius: 0.35, widthSegments: 12, heightSegments: 10)
    let ballAMat = ShaderMaterial(SPHERE_VS, SPHERE_FS)
    let ballA = Mesh(geometry: ballAGeom, material: ballAMat)
    ballA.name = "ChainBallA"
    ballA.position.set(5.0, 5.0, -2.0)
    scene.add(ballA)
    let ballABody = PhysicsBinding.meshSphere(world, ballA,
        motionType: PhysicsMotionType.Dynamic, friction: 0.3, restitution: 0.3)
    bodies.add(ballABody)

    let ballBGeom = SphereGeometry(radius: 0.35, widthSegments: 12, heightSegments: 10)
    let ballBMat = ShaderMaterial(SPHERE_VS, SPHERE_FS)
    let ballB = Mesh(geometry: ballBGeom, material: ballBMat)
    ballB.name = "ChainBallB"
    ballB.position.set(5.0, 4.0, -2.0)
    scene.add(ballB)
    let ballBBody = PhysicsBinding.meshSphere(world, ballB,
        motionType: PhysicsMotionType.Dynamic, friction: 0.3, restitution: 0.3)
    bodies.add(ballBBody)

    // 距离约束：两球锚点距离保持 1.2 米（像弹簧链）
    let chain = PhysicsConstraint.distance(world, ballABody.handle, ballBBody.handle,
        Vector3(5.0, 5.0, -2.0), Vector3(5.0, 4.0, -2.0),
        0.5, 1.2)
    constraints.add(chain)
    println("  创建距离约束（双球链）: ${if (chain.isValid()) { "成功" } else { "失败" }}")

    // ===== 扩展形状演示 1：Mesh 三角网格坡道（Static，青绿色） =====
    // 用顶点 + 索引三角形构造一个楔形三棱柱（坡道），Static 刚体；
    // 视觉用 BoxGeometry 近似渲染（物理形状为三角网格）。
    let meshGeom = BoxGeometry(width: 4.0, height: 1.0, depth: 2.0)
    let meshMat = ShaderMaterial(MESH_VS, MESH_FS)
    let meshRamp = Mesh(geometry: meshGeom, material: meshMat)
    meshRamp.name = "MeshRamp"
    meshRamp.position.set(7.0, 0.5, -1.0)
    meshRamp.quaternion.setFromEuler(Euler(0.0, 0.0, 0.0))
    scene.add(meshRamp)
    // 楔形三棱柱：6 顶点（底面矩形 + 顶边），8 三角形（2 端面 + 4 侧面 + 2 底面）
    let rampVerts = [
        Vector3(-2.0, 0.0, -1.0), Vector3(2.0, 0.0, -1.0),
        Vector3(2.0, 1.0, -1.0),  Vector3(-2.0, 1.0, -1.0),
        Vector3(-2.0, 0.0, 1.0),  Vector3(2.0, 0.0, 1.0),
        Vector3(2.0, 1.0, 1.0),   Vector3(-2.0, 1.0, 1.0),
    ]
    // 完整封闭盒的 12 三角形（两倍楔形 = 直接用完整盒子网格更稳）
    let rampTris = [
        0u32, 2u32, 1u32, 0u32, 3u32, 2u32,
        4u32, 5u32, 6u32, 4u32, 6u32, 7u32,
        0u32, 1u32, 5u32, 0u32, 5u32, 4u32,
        1u32, 2u32, 6u32, 1u32, 6u32, 5u32,
        2u32, 3u32, 7u32, 2u32, 7u32, 6u32,
        3u32, 0u32, 4u32, 3u32, 4u32, 7u32,
    ]
    let rampShape = PhysicsShape.mesh(rampVerts, rampTris)
    let rampBody = PhysicsBinding.bind(world, meshRamp, rampShape,
        motionType: PhysicsMotionType.Static, friction: 0.6, restitution: 0.1)
    bodies.add(rampBody)
    println("  创建 Mesh 三角网格坡道（Static, 12 三角形）: ${if (rampBody.handle.isValid()) { "成功" } else { "失败" }}")

    // ===== 扩展形状演示 2：ConvexHull 凸包（Dynamic，亮紫色，下落翻滚） =====
    let hullGeom = BoxGeometry(width: 1.2, height: 1.2, depth: 1.2)
    let hullMat = ShaderMaterial(CONVEX_VS, CONVEX_FS)
    let hull = Mesh(geometry: hullGeom, material: hullMat)
    hull.name = "ConvexHull"
    hull.position.set(-7.0, 8.0, 1.0)
    scene.add(hull)
    // 不规则八面体顶点（凸包自动贴合）
    let hullPts = [
        Vector3(-0.6, -0.6, -0.6), Vector3(0.6, -0.6, -0.6),
        Vector3(0.6, 0.6, -0.6),   Vector3(-0.6, 0.6, -0.6),
        Vector3(-0.6, -0.6, 0.6),  Vector3(0.6, -0.6, 0.6),
        Vector3(0.6, 0.6, 0.6),    Vector3(-0.6, 0.6, 0.6),
        Vector3(0.0, 1.1, 0.0),
    ]
    let hullShape = PhysicsShape.convexHull(hullPts)
    let hullBody = PhysicsBinding.bind(world, hull, hullShape,
        motionType: PhysicsMotionType.Dynamic, friction: 0.4, restitution: 0.3)
    bodies.add(hullBody)
    println("  创建 ConvexHull 凸包（Dynamic, 9 顶点）: ${if (hullBody.handle.isValid()) { "成功" } else { "失败" }}")

    // ===== 扩展形状演示 3：Compound 复合形状（Dynamic，亮黄色，锤子形） =====
    let compGeom = BoxGeometry(width: 1.4, height: 1.4, depth: 1.4)
    let compMat = ShaderMaterial(COMPOUND_VS, COMPOUND_FS)
    let comp = Mesh(geometry: compGeom, material: compMat)
    comp.name = "Compound"
    comp.position.set(-3.0, 9.0, 4.0)
    scene.add(comp)
    // 复合形状：杆（Box）+ 两端锤头（Sphere）组成"哑铃"碰撞体
    let compShape = PhysicsShape.compound([
        PhysicsCompoundPart(shape: PhysicsShape.box(0.25, 1.2, 0.25), position: Vector3(0.0, 0.0, 0.0)),
        PhysicsCompoundPart(shape: PhysicsShape.sphere(0.45), position: Vector3(0.0, 1.0, 0.0)),
        PhysicsCompoundPart(shape: PhysicsShape.sphere(0.45), position: Vector3(0.0, -1.0, 0.0)),
    ])
    let compBody = PhysicsBinding.bind(world, comp, compShape,
        motionType: PhysicsMotionType.Dynamic, friction: 0.4, restitution: 0.3)
    bodies.add(compBody)
    println("  创建 Compound 复合形状（Dynamic, 3 子形状）: ${if (compBody.handle.isValid()) { "成功" } else { "失败" }}")

    // ===== 优化 BroadPhase（批量插入后） =====
    world.optimizeBroadPhase()
    println("  BroadPhase 已优化")

    return (scene, camera, bodies, constraints)
}
