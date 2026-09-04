package sp_gtao

/**
 * sp_gtao 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧轨道控制 + 渲染）→ onClose（清理 + 统计）
 * - resources.cj: 开放盒子几何体构造（模型加载失败时的回退场景）
 * - renderer.cj:  场景设置（LittlestTokyo 模型 + GTAO，参数对齐官方案例）与 createScene
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
import three.rendering.cameras.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.lights.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.BgfxGTAOPass
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

    var renderer: BgfxRenderer = BgfxRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 40.0, aspect: 1.0, near: 1.0, far: 100.0)
    var modelGroup: Group = Group()
    var composer: Option<EffectComposer> = None
    var gtaoPass: Option<BgfxGTAOPass> = None
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制：初始对齐官方相机位置 (5,2,8)（围绕 target (0,0.5,0)）
    // dist = |(5,2,8)-(0,0.5,0)| = sqrt(25+2.25+64) = sqrt(91.25) ≈ 9.55
    var orbitTheta: Float64 = atan2(5.0, 8.0)      // 水平角
    var orbitPhi: Float64 = asin((2.0 - 0.5) / 9.55)  // 垂直角（略俯视）
    var orbitDist: Float64 = 9.55

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/合成器） =====
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
        this.renderer.setClearColor(Color(0xbf, 0xe3, 0xdd))  // 对齐官方 scene.background = 0xbfe3dd
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        // ---- 步骤 3: 创建场景对象 ----
        println("[3/5] 创建场景对象...")
        let (scene, camera, modelGroup) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.modelGroup = modelGroup

        // ---- 步骤 4: 进入渲染循环（含统计输出） ----
        println("[4/5] 进入渲染循环（相机公转）...")
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // 对齐 Three.js EffectComposer 用法（对照官方 webgl_postprocessing_gtao.html）：
        //   const composer = new EffectComposer(renderer)
        //   composer.addPass(new RenderPass(scene, camera))
        //   const gtaoPass = new GTAOPass(scene, camera, width, height)
        //   composer.addPass(gtaoPass)
        //   composer.render()
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        let gtaoPass = BgfxGTAOPass(this.scene, this.camera)
        // 参数完全对齐官方 webgl_postprocessing_gtao.html 的 aoParameters/pdParameters：
        //   aoParameters: radius=0.25, distanceExponent=1, thickness=1, scale=1,
        //                 samples=16, distanceFallOff=1, screenSpaceRadius=false
        //   pdParameters: lumaPhi=10, depthPhi=2, normalPhi=3, radius=4,
        //                 radiusExponent=1, rings=2, samples=16
        //   blendIntensity 默认 1（GUI 可调 0~1）
        gtaoPass.radius = 0.25
        gtaoPass.distanceExponent = 1.0
        gtaoPass.thickness = 1.0
        gtaoPass.distanceFallOff = 1.0
        gtaoPass.scale = 1.0
        gtaoPass.lumaPhi = 10.0
        gtaoPass.depthPhi = 2.0
        gtaoPass.normalPhi = 3.0
        gtaoPass.pdRadius = 4.0      // 官方 pdParameters.radius=4（注意：非 GTAOPass 默认 8）
        gtaoPass.blendIntensity = 1.0
        // 输出模式：Default=0（AO 混合到场景）；调试可用 Denoise=5/AO=4/Depth=2/Normal=3
        gtaoPass.output = BgfxGTAOPass.OUTPUT_DEFAULT
        composer.addPass(gtaoPass)
        composer.setSize(Int64(this.getWidth()), Int64(this.getHeight()))
        this.composer = Some(composer)
        this.gtaoPass = Some(gtaoPass)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++

        // 鼠标拖动：调整公转角度
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            let dx = Float64(_mouse.getOrThrow().getMouseDX())
            let dy = Float64(_mouse.getOrThrow().getMouseDY())
            this.orbitTheta -= dx * 0.005
            this.orbitPhi -= dy * 0.005
            this.orbitPhi = clamp(this.orbitPhi, -1.4, 1.4)
        }

        // 滚轮缩放
        if (_mouse.getOrThrow().getWheelY() != 0.0f32) {
            let zoomSpeed: Float64 = 0.05
            this.orbitDist *= (1.0 - Float64(_mouse.getOrThrow().getWheelY()) * zoomSpeed)
            this.orbitDist = clamp(this.orbitDist, 3.0, 40.0)
        }

        // 相机球面坐标 → 笛卡尔坐标（围绕 ORBIT_TARGET）
        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = ORBIT_TARGET.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = ORBIT_TARGET.y + this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = ORBIT_TARGET.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.lookAt(ORBIT_TARGET)

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 临时诊断：按数字键 1-5 切换 OUTPUT 调试模式（1=Default 2=Depth 3=Normal 4=AO 5=Denoise）
        if (g_outputDirty.load()) {
            g_outputDirty.store(false)
            match (this.gtaoPass) {
                case Some(gtaoPass) =>
                    gtaoPass.output = g_outputMode
                    println("  [render] gtaoPass.output -> ${g_outputMode}")
                case None => ()
            }
        }

        // GTAO 后处理 pass 链（RenderPass → BgfxGTAOPass）
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
        println("  BgfxRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    Logger.setLevel(LogLevel.Debug)
    println("=== sp_gtao：地面真值环境光遮蔽（GTAO）后处理 pass ===")
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
