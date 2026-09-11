package sp_materials

/**
 * sp_materials 入口（v2 生命周期模式）：
 * 材质渲染验证测试。
 * 场景：多圈材质球（每圈 6 个、共 3 圈，半径递增）围绕相机环形排列，
 * 每颗球使用不同材质/颜色便于视觉识别；
 * 相机位于圆心缓慢自转，正前方发射射线，命中材质球时打印材质名 debug 日志。
 * 窗口通过 WindowEngine v2 创建：TestWindow <: WindowEngine，
 * onInit/onFrame/onClose 生命周期由窗口泵线程驱动。
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.MouseProvider
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.*
import three.scene.objects.*
import three.utils.log.Logger
import three.utils.log.LogLevel
import std.collection.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var objs: SceneObjects = SceneObjects(
        scene: Scene(),
        camera: PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0),
        spheres: ArrayList<Object3D>(),
        extras: ArrayList<Object3D>()
    )
    var raycaster: Raycaster = Raycaster()
    // intersectObjects 需要 Array<Object3D>
    var rayObjects: Array<Object3D> = Array<Object3D>(0, { _ => Object3D() })
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制状态（对照 geometries 测试）
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.0
    var orbitDist: Float64 = 16.0
    var targetCenter = Vector3(0.0, 0.0, 0.0)

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
        this._mouse = this.getProvider<MouseProvider>()


        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[2/5] 初始化 BgfxRenderer（绑定窗口 ${hwnd}, ${w}x${h}）...")
        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            println("  ThreeRenderer.initBgfx 失败!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x20, 0x20, 0x30))  // 深蓝灰背景
        // 开启 bgfx 调试文本（DEBUG_TEXT = 0x08）——dbgTextPrintf 画面内文本渲染的前提（同 geometries）
        this.renderer.setDebug(0x00000008)
        println("  ThreeRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        // ---- 步骤 3: 创建场景对象（多圈材质球） ----
        println("[3/5] 创建场景对象...")
        this.objs = createScene(w, h)
        this.rayObjects = Array<Object3D>(this.objs.spheres.size, { i => this.objs.spheres[i] })

        // ---- 步骤 4: 进入渲染循环（含射线命中 debug） ----
        println("[4/5] 进入渲染循环（相机自由旋转 + 射线命中 debug）...")
        println("  鼠标左键拖动：调整视角；滚轮：缩放；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++
        let t = Float64(this.frame) * 0.016

        // ---- 材质球缓慢自转（便于观察表面属性） ----
        for (i in 0..this.objs.spheres.size) {
            this.objs.spheres[i].rotateY(0.3 * 0.016)
            this.objs.spheres[i].rotateX(0.15 * 0.016)
        }

        // ---- 鼠标拖动：手动调整视角（同 geometries） ----
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            let dx = Float64(_mouse.getOrThrow().getMouseDX())
            let dy = Float64(_mouse.getOrThrow().getMouseDY())
            this.orbitTheta -= dx * 0.005
            this.orbitPhi -= dy * 0.005
            this.orbitPhi = clamp(this.orbitPhi, -1.4, 1.4)
        }

        // ---- 滚轮缩放 ----
        if (_mouse.getOrThrow().getWheelY() != 0.0f32) {
            let zoomSpeed: Float64 = 0.05
            this.orbitDist *= (1.0 - Float64(_mouse.getOrThrow().getWheelY()) * zoomSpeed)
            this.orbitDist = clamp(this.orbitDist, 3.0, 40.0)
        }

        // ---- 计算相机位置（球面坐标 → 笛卡尔坐标，围绕圆心） ----
        let cosPhi = cos(this.orbitPhi)
        this.objs.camera.position.x = this.targetCenter.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.objs.camera.position.y = this.targetCenter.y + this.orbitDist * sin(this.orbitPhi)
        this.objs.camera.position.z = this.targetCenter.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.objs.camera.lookAt(this.targetCenter)

        // ---- 更新相机宽高比 ----
        let w = this.getWidth()
        let h = this.getHeight()
        this.objs.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.objs.camera.updateProjectionMatrix()

        // ---- 射线命中检测（相机正前方，同 geometries） ----
        // 先更新场景矩阵世界，确保 Mesh.raycast 中 boundingSphere 应用了最新 position
        this.objs.scene.updateMatrixWorld(true)
        let camDir = this.objs.camera.getWorldDirection(Vector3())
        this.raycaster.set(this.objs.camera.position, camDir)
        let hits = this.raycaster.intersectObjects(this.rayObjects)
        var hitName = ""
        if (hits.size > 0) {
            match (hits[0].obj) {
                case Some(obj: Object3D) => hitName = obj.name
                case _ => ()
            }
        }
        // debug 打印：每 30 帧输出射线信息；命中时即时打印材质名
        if (this.frame % 30 == 0) {
            println("raycast: theta=${this.orbitTheta} phi=${this.orbitPhi} dist=${this.orbitDist} origin=(${this.objs.camera.position.x}, ${this.objs.camera.position.y}, ${this.objs.camera.position.z}) dir=(${camDir.x}, ${camDir.y}, ${camDir.z}) objects=${this.rayObjects.size} hits=${hits.size}")
        }
        if (hitName != "") {
            println("[hit] frame=${this.frame} hit=${hitName} dist=${hits[0].distance.toString()}")
        }

        // 每帧清屏调试文本并显示当前命中材质名（bgfx dbg_text_printf 画面内文本，同 geometries）
        this.renderer.dbgTextClear(0x00, false)
        this.renderer.dbgTextPrintf(0, 0, 0x0f, "=> hit: " + hitName)
        this.renderer.dbgTextPrintf(0, 1, 0x0e, "objects=" + this.rayObjects.size.toString() + " hits=" + hits.size.toString())

        this.renderer.render(this.objs.scene, this.objs.camera)

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理渲染器 + 统计输出） =====
    public override func onClose(): Unit {
        println("")

        println("[5/5] 清理资源...")
        let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
        println("  运行时间: ${elapsed}s")
        println("  总帧数: ${this.totalFrames}")
        if (elapsed > 0.0) {
            println("  平均 FPS: ${(Float64(this.totalFrames) / elapsed).toString()}")
        }
        println("")
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    // 临时开启 Debug 日志，抓取 matcap/toon shader 编译错误详情
    Logger.setLevel(LogLevel.Debug)
    println("=== sp_materials：材质渲染验证（多圈材质球） ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    win.addInputProvider(MouseProvider())
    let wok = win.start(title: "three4cj", width: 1280, height: 720)
    if (!wok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
