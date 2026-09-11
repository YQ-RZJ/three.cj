package bloom_basic

/**
 * bloom_basic 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧轨道控制 + 球体动画 + 渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（多个不同颜色的高强度发光球 + 方向光 + 环境光）与 createScene
 * - EffectComposer 链：RenderPass → BgfxBloomPass（strength/kernelSize/sigma）→ 上屏
 *
 * 验证对象：three.js BloomPass（简单版）迁移 —— BloomPass
 *   （1 遍水平卷积 + 1 遍垂直卷积 + scene+strength×blur 合成回 readBuffer）
 * 与 unreal_bloom 测试（UnrealBloomPass 5 级金字塔）形成对照。
 */

import std.io.*
import std.time.*
import std.collection.*
import std.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.MouseProvider
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.lights.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.BloomPass
import three.utils.log.Logger
import three.utils.log.LogLevel

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景/合成器（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var spheres: ArrayList<Mesh> = ArrayList<Mesh>()
    var composer: Option<EffectComposer> = None
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 12.0

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/合成器） =====
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
        // 深蓝黑背景，突出 bloom 光晕（与 unreal_bloom 一致）
        this.renderer.setClearColor(Color(0x10, 0x12, 0x18))
        println("  ThreeRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        let (scene, camera, spheres) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.spheres = spheres

        // ---- 步骤 4: 进入渲染循环（RenderPass → BloomPass → 上屏） ----
        println("[4/5] 进入渲染循环（启用简单版 Bloom via EffectComposer）...")
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // 对齐 Three.js EffectComposer 用法：
        //   const composer = new EffectComposer(renderer)
        //   composer.addPass(new RenderPass(scene, camera))
        //   composer.addPass(new BloomPass(strength, kernelSize, sigma))
        //   composer.render()
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        // 简单版 BloomPass：默认 kernelSize=25 / sigma=4（与 three.js 默认一致）。
        // strength=1.0 保持模糊合成强度；对比 unreal_bloom（threshold 提取 + 5 级金字塔）。
        composer.addPass(BloomPass(strength: 1.0, kernelSize: 25, sigma: 4.0))
        composer.setSize(Int64(w), Int64(h))
        this.composer = Some(composer)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        this.totalFrames++

        let t = Float64(this.frame) * 0.016

        // ---- 更新球体位置（来回移动） ----
        for (sphere in this.spheres) {
            match (sphere.userData.get("__anim")) {
                case Some(aObj) => match (aObj) {
                    case a: AnimState =>
                        let s = a.speed
                        let off = sin(t * s + a.phase) * a.amp
                        match (a.axis) {
                            case 0 => sphere.position.x = off
                            case 1 => sphere.position.y = off
                            case 2 => sphere.position.z = off
                            case _ => sphere.position.x = off
                        }
                    case _ => ()
                }
                case None => ()
            }
        }

        // ---- 鼠标拖动：调整公转角度 ----
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

        // ---- 计算相机位置（球面坐标 → 笛卡尔坐标） ----
        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // EffectComposer pass 链：RenderPass（渲场景到 readBuffer）→ BgfxBloomPass（bloom 写屏幕）
        match (this.composer) {
            case Some(composer) => composer.render()
            case None => ()
        }

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()} orbit=(${this.orbitTheta.toString()}, ${this.orbitPhi.toString()}) dist=${this.orbitDist.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理合成器/渲染器 + 统计输出） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        match (this.composer) {
            case Some(composer) => composer.dispose()
            case None => ()
        }
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
    Logger.setLevel(LogLevel.Debug)
    println("=== bloom_basic：发亮球 / 简单版 Bloom 后处理（BgfxBloomPass）===")
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
