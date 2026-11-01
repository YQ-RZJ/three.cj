package cullingDemo

/**
 * 剔除效果可视化测试：视锥剔除 + 遮挡剔除 + 视锥辅助显示
 *
 * 场景说明：
 * - 120x120 地面平面 + NUM_CUBES 个随机均匀分布（环带 [4,48]）的彩色立方体
 * - 视锥相机（rotCam）位于平面中心 (0, 0.6, 0)，朝外水平观察，匀速绕 Y 轴旋转
 * - 观察相机（obsCam）位于远处高空俯瞰整个平面
 * - CameraHelper 显示旋转视锥的线框（橙色）
 *
 * 每种模式持续 MODE_SECONDS 秒，自动循环切换：
 * 1. BASELINE  无剔除基线：观察相机渲染，全部立方体提交（draw call 基准）
 * 2. FRUSTUM   视锥剔除：观察相机渲染，仅旋转视锥内的立方体可见——
 *              视锥外立方体从画面中消失，橙色线框标出视锥范围
 * 3. OCCLUSION 视锥+遮挡剔除：在视锥剔除基础上，CPU 光线-AABB（slab 法）
 *              测试剔除被其他立方体遮挡的立方体
 * 4. ENGINE    引擎管线剔除（第一人称）：直接 render(scene, rotCam)，
 *              由引擎 _collectRenderObjects 内置视锥剔除生效，
 *              draw call 数直接证明管线剔除有效
 *
 * draw call / 可见数每 30 帧打印控制台并更新窗口标题。
 * 手动剔除（模式 2/3）与引擎管线使用同一 Frustum 数学
 * （setFromProjectionMatrix + intersectsObject），结果可互相印证：
 * 模式 2 的 visible 数 ≈ 模式 4 的 draw call 数（差值为地面+helper 两次提交）。
 */

import std.math.*
import std.random.*
import std.time.*
import std.collection.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.helpers.CameraHelper

// ===== 测试参数 =====
const NUM_CUBES: Int64 = 400     // 立方体数量
const RING_MIN: Float64 = 4.0    // 分布环带内半径（避开中心相机位置）
const RING_MAX: Float64 = 48.0   // 分布环带外半径
const MODE_SECONDS: Float64 = 8.0 // 每种剔除模式持续时间（秒）
const ROT_SPEED: Float64 = 0.5   // 视锥旋转角速度（弧度/秒）
const PALETTE_SIZE: Int64 = 10   // 共享颜色数（材质数）
const PI_F: Float64 = 3.14159265358979323846

// 模式名（控制台与窗口标题共用）
let MODE_NAMES: Array<String> = [
    "1.BASELINE-无剔除",
    "2.FRUSTUM-视锥剔除",
    "3.OCCLUSION-视锥+遮挡剔除",
    "4.ENGINE-引擎管线剔除",
    "5.SPATIAL-空间剔除对照"
]

// 立方体颜色调色板（UInt32 hex）
let PALETTE: Array<UInt32> = [
    0xd9553f, 0xe8a33d, 0xe5d752, 0x7cb342, 0x2e9e6b,
    0x2f8fbf, 0x3f51b5, 0x7e57c2, 0xc2185b, 0x90a4ae
]

/**
 * 剔除可视化测试窗口
 * onInit 创建渲染器/场景，onFrame 按模式切换剔除策略并渲染，onClose 清理。
 */
public class CullingTestWindow <: WindowEngine {
    // ===== 渲染状态 =====
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()

    // 观察相机：远处高空俯瞰
    var obsCam: PerspectiveCamera = PerspectiveCamera(fov: 55.0, aspect: 1.0, near: 1.0, far: 300.0)
    // 视锥相机：平面中心朝外，匀速旋转
    var rotCam: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.2, far: 50.0)

    // 视锥线框辅助（构造时替换为绑定 rotCam 的实例）
    var camHelper: CameraHelper = CameraHelper()

    // ===== 立方体与遮挡体数据 =====
    var cubes: ArrayList<Mesh> = ArrayList<Mesh>()
    // 遮挡体静态 AABB：中心与半宽（yaw 旋转后的 x/z 半宽 = 0.5*scale*(|cos|+|sin|)）
    var centers: ArrayList<Vector3> = ArrayList<Vector3>()
    var halfXZ: ArrayList<Float64> = ArrayList<Float64>()
    var halfY: ArrayList<Float64> = ArrayList<Float64>()

    // ===== 剔除与统计状态 =====
    // 手动剔除用视锥（与引擎管线同一数学）
    var frustum: Frustum = Frustum()
    var pm: Matrix4 = Matrix4()
    var frame: Int64 = 0
    var elapsed: Float64 = 0.0
    var lastMode: Int64 = -1
    var lastVisible: Int64 = 0
    // 空间剔除对照数据（模式 5）
    var spatialTrisLinear: Int64 = 0
    var spatialTrisBvh: Int64 = 0
    var spatialCallsLinear: Int64 = 0
    var spatialCallsBvh: Int64 = 0
    var spatialMismatch: Bool = false
    var startTime: MonoTime = MonoTime.now()

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[1/3] 初始化 ThreeRenderer（绑定窗口 ${hwnd}, ${w}x${h}）...")
        this.renderer.setPixelRatio(Float64(this.getPixelRatio()))
        let rok = this.renderer.initBgfx(hwnd, w, h)
        if (!rok) {
            println("  ThreeRenderer.initBgfx 失败!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x1a1a24))
        println("  ThreeRenderer 初始化成功")

        println("[2/3] 创建场景...")
        // 地面：120x120 平面，绕 X 轴 -90° 平铺
        let groundMat = MeshBasicMaterial()
        groundMat.color = Color(0x33333c)
        let ground = Mesh(geometry: PlaneGeometry(width: 120.0, height: 120.0), material: groundMat)
        ground.rotation.x = -PI_F / 2.0
        this.scene.add(ground)

        // 立方体：共享几何体 + PALETTE_SIZE 个共享材质（同色复用，控制材质数）
        let boxGeom = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
        let mats = ArrayList<MeshBasicMaterial>()
        for (hex in PALETTE) {
            let m = MeshBasicMaterial()
            m.color = Color(hex)
            mats.add(m)
        }
        // 均匀环带分布：r = sqrt(rand([r0^2, r1^2])) 保证面积均匀
        let rng = Random()
        for (i in 0..NUM_CUBES) {
            let ang = rng.nextFloat64() * 2.0 * PI_F
            let r = sqrt(MathUtils.randFloat(RING_MIN * RING_MIN, RING_MAX * RING_MAX))
            let scale = MathUtils.randFloat(0.7, 1.6)
            let yaw = rng.nextFloat64() * 2.0 * PI_F
            let mesh = Mesh(geometry: boxGeom, material: mats[i % PALETTE_SIZE])
            mesh.position.set(r * cos(ang), 0.5 * scale, r * sin(ang))
            mesh.rotation.y = yaw
            mesh.scale.set(scale, scale, scale)
            mesh.frustumCulled = true
            this.scene.add(mesh)
            this.cubes.add(mesh)
            // 预计算遮挡体 AABB 半宽（yaw 旋转后的保守轴对齐半宽）
            this.centers.add(Vector3(mesh.position.x, mesh.position.y, mesh.position.z))
            this.halfXZ.add(0.5 * scale * (abs(cos(yaw)) + abs(sin(yaw))))
            this.halfY.add(0.5 * scale)
        }

        // 视锥相机初始朝向 + 视锥线框辅助
        this.rotCam.position.set(0.0, 0.6, 0.0)
        this.rotCam.lookAt(Vector3(0.0, 0.6, 10.0))
        this.camHelper = CameraHelper(this.rotCam)
        this.scene.add(this.camHelper)

        // 观察相机初始位姿
        this.obsCam.position.set(0.0, 70.0, 85.0)
        this.obsCam.lookAt(Vector3(0.0, 0.0, 0.0))

        // 预更新一次全场景矩阵（立方体为静态，之后 matrixWorld 不再变化，
        // 包围球缓存首次 intersectsObject 时按需计算）
        this.scene.updateMatrixWorld(true)
        this.rotCam.updateMatrixWorld(true)
        this.camHelper.updateMatrixWorld(true)

        println("  场景创建成功: 地面 + ${NUM_CUBES} 立方体（环带 [${RING_MIN},${RING_MAX}] 均匀分布）")
        println("  视锥相机: 中心 (0,0.6,0) 朝外匀速旋转（${ROT_SPEED} rad/s）")
        println("  CameraHelper: 橙色视锥线框随 rotCam 旋转")
        println("[3/3] 进入渲染循环（每 ${MODE_SECONDS}s 自动切换剔除模式）...")
        println("  模式: ${MODE_NAMES[0]} -> ${MODE_NAMES[1]} -> ${MODE_NAMES[2]} -> ${MODE_NAMES[3]} -> 循环")
        println("")
    }

    // ===== 生命周期：每帧（模式切换 -> 剔除 -> 渲染 -> 统计） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        this.elapsed += dt

        // 模式轮换
        let mode = Int64(this.elapsed / MODE_SECONDS) % 5
        if (mode != this.lastMode) {
            this.lastMode = mode
            println("[mode] ${MODE_NAMES[mode]}")
        }

        // 视锥相机：平面中心朝外匀速旋转
        let yaw = this.elapsed * ROT_SPEED
        this.rotCam.position.set(0.0, 0.6, 0.0)
        this.rotCam.lookAt(Vector3(sin(yaw) * 10.0, 0.6, cos(yaw) * 10.0))
        this.rotCam.updateMatrixWorld(true)

        // 手动剔除用视锥（与引擎管线同一 Frustum 数学）
        this.pm.multiplyMatrices(this.rotCam.projectionMatrix, this.rotCam.matrixWorldInverse)
        this.frustum.setFromProjectionMatrix(this.pm)

        // helper 跟随（matrix 与相机 matrixWorld 共享引用，强制同步 matrixWorld）
        this.camHelper.updateMatrixWorld(true)
        this.camHelper.visible = mode != 3  // 第一人称模式下隐藏自身视锥线框

        // 相机宽高比跟随窗口（两种相机共用窗口比例）
        let w = this.getWidth()
        let h = this.getHeight()
        let aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.obsCam.aspect = aspect
        this.obsCam.updateProjectionMatrix()
        this.rotCam.aspect = aspect
        this.rotCam.updateProjectionMatrix()
        this.camHelper.update()  // 投影变化后重建视锥线框顶点

        // ===== 按模式设置可见性并渲染 =====
        match (mode) {
            case 0 =>
                // 基线：全部提交
                for (m in this.cubes) { m.visible = true }
                this.renderer.render(this.scene, this.obsCam)
            case 1 =>
                // 视锥剔除：仅旋转视锥内的立方体可见
                var vis: Int64 = 0
                for (m in this.cubes) {
                    m.visible = this.frustum.intersectsObject(m)
                    if (m.visible) { vis++ }
                }
                this.lastVisible = vis
                this.renderer.render(this.scene, this.obsCam)
            case 2 =>
                // 视锥 + 遮挡剔除：再剔除被其他立方体挡住的
                var vis: Int64 = 0
                for (i in 0..NUM_CUBES) {
                    let m = this.cubes[i]
                    m.visible = this.frustum.intersectsObject(m) && !this.isOccluded(i)
                    if (m.visible) { vis++ }
                }
                this.lastVisible = vis
                this.renderer.render(this.scene, this.obsCam)
            case 3 =>
                // 引擎管线剔除（第一人称）：全部 visible，剔除由引擎收集阶段完成
                for (m in this.cubes) { m.visible = true }
                this.renderer.render(this.scene, this.rotCam)
            case 4 =>
                // 空间剔除对照（第一人称）：同一相机下分别走"逐对象视锥测试"与
                // "BVH 空间剔除"两条路径，比较渲染出的三角形数。
                // 空间剔除使用包围盒判定（比包围球宽松），因此可见对象数应 >= 逐对象
                // 路径；若小于则说明空间剔除发生了误剔除（漏渲染）。
                for (m in this.cubes) { m.visible = true }
                this.renderer.enableSpatialCulling = false
                this.renderer.render(this.scene, this.rotCam)
                let trisLinear = this.renderer.info.render.triangles
                let callsLinear = this.renderer.info.render.calls
                this.renderer.enableSpatialCulling = true
                this.renderer.render(this.scene, this.rotCam)
                let trisSpatial = this.renderer.info.render.triangles
                let callsSpatial = this.renderer.info.render.calls
                this.lastVisible = trisLinear / 12
                this.spatialTrisLinear = trisLinear
                this.spatialTrisBvh = trisSpatial
                this.spatialCallsLinear = callsLinear
                this.spatialCallsBvh = callsSpatial
                this.spatialMismatch = (trisSpatial < trisLinear)
                this.renderer.render(this.scene, this.rotCam)
            case _ => ()
        }

        // ===== 统计显示：每 30 帧打印 + 更新窗口标题 =====
        if (this.frame % 30 == 1) {
            let calls = this.renderer.info.render.calls
            let tris = this.renderer.info.render.triangles
            let total = this.cubes.size
            // 基线/引擎模式全量提交，显示 total 而非残留的手动剔除计数
            let visTxt = if (mode == 0) { "${total}/400(all)" } else if (mode == 3) { "pipeline" } else if (mode == 4) { "A/B对照" } else { "${this.lastVisible}/${total}" }
            println("[stats] ${MODE_NAMES[mode]}  drawCalls=${calls}  visibleCubes=${visTxt}  tris=${tris}")
            if (mode == 4) {
                // 空间剔除对照：逐对象视锥测试 vs BVH 空间剔除
                println("[spatial] linearTris=${this.spatialTrisLinear} bvhTris=${this.spatialTrisBvh} " +
                        "linearCalls=${this.spatialCallsLinear} bvhCalls=${this.spatialCallsBvh} " +
                        "mismatch=${this.spatialMismatch} (bvhTris 应 >= linearTris)")
            }
            this.setTitle("CullingDemo | ${MODE_NAMES[mode]} | drawCalls=${calls} | visible=${visTxt}")
        }
    }

    // ===== 生命周期：关闭前清理 =====
    public override func onClose(): Unit {
        println("")
        println("[cleanup] 关闭渲染器...")
        let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
        println("  运行时间: ${elapsed}s")
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("=== 剔除可视化测试完成 ===")
    }

    // ===== CPU 遮挡测试 =====

    /**
     * 判断第 idx 个立方体是否被其他立方体遮挡
     * 思路：从视锥相机位置向目标立方体中心投射线段，
     * 遍历其余立方体的静态 AABB 做 slab 相交测试，
     * 命中点位于目标近侧面之前（t ∈ [0, tMax]）即判定遮挡。
     */
    func isOccluded(idx: Int64): Bool {
        // 视线起点 = 视锥相机位置（平面中心上方）
        let ox = this.rotCam.position.x
        let oy = this.rotCam.position.y
        let oz = this.rotCam.position.z
        let target = this.centers[idx]
        let dx = target.x - ox
        let dy = target.y - oy
        let dz = target.z - oz
        let dist = sqrt(dx * dx + dy * dy + dz * dz)
        if (dist < 1e-6) { return false }
        let ix = dx / dist
        let iy = dy / dist
        let iz = dz / dist
        // 遮挡判定终点：目标立方体近侧面（留 0.7 倍半宽 bias 防止相邻立方体互挡闪烁）
        let tMax = (dist - 0.7 * this.halfY[idx]) / dist
        let cnt = this.cubes.size
        var j: Int64 = 0
        while (j < cnt) {
            if (j != idx) {
                let c = this.centers[j]
                let wx = c.x - ox
                let wy = c.y - oy
                let wz = c.z - oz
                // 快速剔除：遮挡体在视线反方向或明显越过目标
                let along = wx * ix + wy * iy + wz * iz
                if (along > 0.0 && along < dist + 2.0) {
                    let hx = this.halfXZ[j]
                    let hy = this.halfY[j]
                    if (this.raySlab(ox, oy, oz, ix, iy, iz, tMax,
                            c.x - hx, c.y - hy, c.z - hx,
                            c.x + hx, c.y + hy, c.z + hx)) {
                        return true
                    }
                }
            }
            j++
        }
        return false
    }

    /**
     * 线段-AABB slab 相交测试
     * 线段: origin + t * dir, t ∈ [0, tMax]；dir 为单位向量
     * 逐轴求参数区间并求交，区间非空即命中
     */
    func raySlab(ox: Float64, oy: Float64, oz: Float64,
                 ix: Float64, iy: Float64, iz: Float64, tMax: Float64,
                 minX: Float64, minY: Float64, minZ: Float64,
                 maxX: Float64, maxY: Float64, maxZ: Float64): Bool {
        var t0: Float64 = 0.0
        var t1: Float64 = tMax
        // X 轴
        if (abs(ix) < 1e-9) {
            if (ox < minX || ox > maxX) { return false }
        } else {
            var ta = (minX - ox) / ix
            var tb = (maxX - ox) / ix
            if (ta > tb) { let t = ta; ta = tb; tb = t }
            if (ta > t0) { t0 = ta }
            if (tb < t1) { t1 = tb }
            if (t0 > t1) { return false }
        }
        // Y 轴
        if (abs(iy) < 1e-9) {
            if (oy < minY || oy > maxY) { return false }
        } else {
            var ta = (minY - oy) / iy
            var tb = (maxY - oy) / iy
            if (ta > tb) { let t = ta; ta = tb; tb = t }
            if (ta > t0) { t0 = ta }
            if (tb < t1) { t1 = tb }
            if (t0 > t1) { return false }
        }
        // Z 轴
        if (abs(iz) < 1e-9) {
            if (oz < minZ || oz > maxZ) { return false }
        } else {
            var ta = (minZ - oz) / iz
            var tb = (maxZ - oz) / iz
            if (ta > tb) { let t = ta; ta = tb; tb = t }
            if (ta > t0) { t0 = ta }
            if (tb < t1) { t1 = tb }
            if (t0 > t1) { return false }
        }
        return true
    }
}

main(): Int64 {
    println("=== three4cj 剔除可视化测试（视锥剔除/遮挡剔除/CameraHelper） ===")
    println("")

    // ---- 步骤 1: 创建窗口 ----
    println("[1/3] 创建窗口（WindowEngine v2）...")
    let win = CullingTestWindow()
    let wok = win.start(title: "three4cj CullingDemo", width: 1280, height: 720)
    if (!wok) {
        println("  WindowEngine.start 失败!")
        return 1
    }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}")
    println("")

    // ---- 步骤 2: 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
