package sp_scenes

/**
 * sp_scenes 入口（v2 生命周期模式）：
 * scenes 包功能对齐验证测试。
 * 场景：多球体 + Scene 字段验证（fog/fogExp2/background/overrideMaterial）
 *       + Scene.copy/clone/toJSON 接口验证 + 渲染展示。
 * 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose）。
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.BgfxRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.MouseProvider
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.cameras.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: BgfxRenderer = BgfxRenderer()
    var objs: SceneObjects = SceneObjects(
        scene: Scene(),
        camera: PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0),
        sphere1: Mesh(),
        sphere2: Mesh(),
        fog1: Fog(),
        fog2: FogExp2(),
        overrideMat: MeshBasicMaterial())
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.0
    var orbitDist: Float64 = 10.0
    let targetCenter = Vector3(0.0, 0.0, 0.0)

    // 状态切换周期：0=线性雾 1=指数雾 2=无雾+override 3=默认
    var mode: Int64 = 0
    var modeShown = -1

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
        this._mouse = this.getProvider<MouseProvider>()


        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[2/5] 初始化 BgfxRenderer（绑定窗口 ${hwnd}, ${w}x${h}）...")
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            println("  BgfxRenderer.initBgfx 失败!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x20, 0x20, 0x30))
        this.renderer.setDebug(0x00000008)
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        this.objs = createScene(w, h)

        println("[4/5] 进入渲染循环（Scene 状态周期切换，onFrame 由窗口泵线程驱动）...")
        println("  鼠标左键拖动：调整视角；滚轮：缩放；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++
        let t = Float64(this.frame) * 0.016

        // ---- 球自转 ----
        this.objs.sphere1.rotation.y = t * 0.5
        this.objs.sphere2.rotation.y = t * 0.3

        // ---- 每 180 帧切换一次 Scene 状态 ----
        this.mode = (this.frame / 180) % 4
        if (this.mode != this.modeShown) {
            this.modeShown = this.mode
            match (this.mode) {
                case 0 =>
                    this.objs.scene.fog = Some(this.objs.fog1)
                    this.objs.scene.fogExp2 = None
                    this.objs.scene.overrideMaterial = None
                    this.objs.scene.background = Some(Color(0x335577))
                    println("  [scene] mode=0 线性雾 near=${this.objs.fog1.near} far=${this.objs.fog1.far}")
                case 1 =>
                    this.objs.scene.fog = None
                    this.objs.scene.fogExp2 = Some(this.objs.fog2)
                    this.objs.scene.overrideMaterial = None
                    this.objs.scene.background = Some(Color(0x553333))
                    println("  [scene] mode=1 指数雾 density=${this.objs.fog2.density}")
                case 2 =>
                    this.objs.scene.fog = None
                    this.objs.scene.fogExp2 = None
                    this.objs.scene.overrideMaterial = Some(this.objs.overrideMat)
                    this.objs.scene.background = Some(Color(0x335533))
                    println("  [scene] mode=2 overrideMaterial 覆盖材质")
                case _ =>
                    this.objs.scene.fog = None
                    this.objs.scene.fogExp2 = None
                    this.objs.scene.overrideMaterial = None
                    this.objs.scene.background = None
                    println("  [scene] mode=3 默认（无雾/无覆盖）")
            }
        }

        // ---- 鼠标拖动 ----
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

        // ---- 相机位置 ----
        let cosPhi = cos(this.orbitPhi)
        this.objs.camera.position.x = this.targetCenter.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.objs.camera.position.y = this.targetCenter.y + this.orbitDist * sin(this.orbitPhi)
        this.objs.camera.position.z = this.targetCenter.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.objs.camera.lookAt(this.targetCenter)

        let w = this.getWidth()
        let h = this.getHeight()
        this.objs.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.objs.camera.updateProjectionMatrix()

        // ---- 画面内文本 ----
        this.renderer.dbgTextClear(0x00, false)
        this.renderer.dbgTextPrintf(0, 0, 0x0f, "mode=" + this.mode.toString() + " fog=" + match (this.objs.scene.fog) { case Some(f) => f.name case None => "none" } + " fogExp2=" + match (this.objs.scene.fogExp2) { case Some(f) => f.name case None => "none" })
        this.renderer.dbgTextPrintf(0, 1, 0x0e, "bg=" + match (this.objs.scene.background) { case Some(_) => "Some" case None => "None" } + " override=" + match (this.objs.scene.overrideMaterial) { case Some(_) => "Some" case None => "None" })

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
        this.renderer.shutdown()
        println("  BgfxRenderer 已关闭")
        println("")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    println("=== sp_scenes：场景功能验证（Scene/Fog/FogExp2） ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，SDL3 跨平台实现） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    win.addInputProvider(MouseProvider())
    let wok = win.start(title: "three4cj", width: 1280, height: 720)
    if (!wok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 步骤 4(续): 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
