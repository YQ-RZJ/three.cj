package mask

/**
 * mask 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧轨道控制 + 渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（盒子 + 多色球 + 环境光/方向光）与 createScene
 * - EffectComposer 链：RenderPass → MaskPass → ClearMaskPass
 *   验证 MaskPass 用 stencil buffer 标记遮罩区域、
 *   ClearMaskPass 清除遮罩状态的后处理控制流程。
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
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.lights.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.MaskPass
import three.rendering.postprocessing.ClearMaskPass
import three.rendering.postprocessing.ShaderPass
import three.rendering.postprocessing.OutputPass
import three.utils.log.*
import three.utils.log.macros.*
import std.collection.*

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
        this.renderer.setClearColor(Color(0x10, 0x10, 0x18))  // 深灰背景
        println("  ThreeRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        // ---- 步骤 3: 创建场景对象 ----
        println("[3/5] 创建场景对象...")
        let (scene, camera, spheres) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.spheres = spheres

        // ---- 步骤 4: 进入渲染循环（RenderPass + MaskPass + ClearMaskPass via EffectComposer） ----
        println("[4/5] 进入渲染循环（RenderPass + MaskPass + ClearMaskPass via EffectComposer）...")
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // 对齐 Three.js EffectComposer 用法：
        //   composer.addPass(new RenderPass(scene, camera))       // 场景渲到 readBuffer
        //   composer.addPass(new MaskPass(scene, camera))         // 用 stencil buffer 标记遮罩区域
        //   composer.addPass(new ShaderPass(copy))                // 只在遮罩区域透传场景（主体可见、背景被遮盖）
        //   composer.addPass(new ClearMaskPass())                 // 清除遮罩状态
        //   最后一个 enabled pass 自动 renderToScreen=true 上屏
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        // MaskPass：把场景几何体写入 stencil buffer（writeValue=1），
        // 后续 pass 仅在 stencil==1 区域渲染（遮罩控制）。
        composer.addPass(MaskPass(this.scene, this.camera))
        // 受 mask 影响的 pass：只在遮罩区域（stencil==1）透传 readBuffer 场景，
        // 非遮罩区域保留 writeBuffer 清黑内容 → 呈现"场景主体内容可见、背景被遮盖"的效果。
        let maskedPass = ShaderPass("copy")
        maskedPass.stencilTestRef = Some(1u32)
        composer.addPass(maskedPass)
        // ClearMaskPass：重置 stencil 状态到 disabled，后续 pass 不再受遮罩约束。
        composer.addPass(ClearMaskPass())
        // OutputPass：链尾上屏（把 readBuffer 场景输出到屏幕）。
        // 说明：MaskPass/ClearMaskPass 是"基础设施"pass，不绘制画面；
        // 若链尾缺上屏 pass，屏幕将无内容（全白/黑），故加 OutputPass 显示场景。
        composer.addPass(OutputPass())
        composer.setSize(Int64(this.getWidth()), Int64(this.getHeight()))
        this.composer = Some(composer)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // 鼠标轨道控制
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            this.orbitTheta -= Float64(_mouse.getOrThrow().getMouseDX()) * 0.005
            this.orbitPhi -= Float64(_mouse.getOrThrow().getMouseDY()) * 0.005
            this.orbitPhi = clamp(this.orbitPhi, -1.4, 1.4)
        }
        if (_mouse.getOrThrow().getWheelY() != 0.0f32) {
            this.orbitDist *= (1.0 - Float64(_mouse.getOrThrow().getWheelY()) * 0.05)
            this.orbitDist = clamp(this.orbitDist, 3.0, 40.0)
        }

        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        match (this.composer) {
            case Some(composer) => composer.render()
            case None => ()
        }

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} fps=${fps.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理合成器/渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        match (this.composer) {
            case Some(composer) => composer.dispose()
            case None => ()
        }
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    println("=== mask：MaskPass+ClearMaskPass 遮罩控制 ===")
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
