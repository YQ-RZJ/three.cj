package outputpass

/**
 * outputpass 测试入口（v2 生命周期模式）：
 * - renderer.cj: 场景设置（盒子 + 多色球 + 点光源，部分球 emissive > 1 模拟 HDR）
 *                EffectComposer 链：RenderPass → OutputPass（ACESFilmic tone mapping + sRGB）→ 上屏
 *                验证 OutputPass 色调映射 + sRGB 色彩空间转换的效果（HDR > 1 被压缩到 [0,1] 屏幕显示）。
 * - 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose）。
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
import three.rendering.cameras.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
import three.utils.log.Logger
import three.utils.log.LogLevel
import std.collection.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景与 EffectComposer 链，onFrame 读固定快照并渲染，onClose 清理。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: BgfxRenderer = BgfxRenderer()
    var composer: EffectComposer
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var spheres: ArrayList<Mesh> = ArrayList<Mesh>()
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 12.0

    /// 构造：创建 EffectComposer（不依赖窗口，仅持有渲染器引用，onInit 里 addPass/setSize）
    public init() {
        this.composer = EffectComposer(this.renderer)
    }

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
        this.renderer.setClearColor(Color(0x10, 0x10, 0x18))  // 深灰背景
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        let (scene, camera, spheres) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.spheres = spheres

        // 对齐 Three.js EffectComposer 用法：
        //   composer.addPass(new RenderPass(scene, camera))   // 场景渲到 readBuffer（RGBA16F HDR）
        //   composer.addPass(new OutputPass())                // 色调映射 + sRGB 转换上屏
        // 视觉效果：HDR 球（color ×3/×4 > 1）经 ACESFilmic 压缩到 [0,1]，
        // 高亮区被柔和压缩（不再截断全白），整体画面经 sRGB OETF 显示更自然。
        this.composer.addPass(RenderPass(this.scene, this.camera))
        this.composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        this.composer.setSize(Int64(w), Int64(h))

        println("[4/5] 进入渲染循环（RenderPass + OutputPass via EffectComposer，onFrame 由窗口泵线程驱动）...")
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

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

        this.composer.render()

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} fps=${fps.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理合成器与渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        this.composer.dispose()
        this.renderer.shutdown()
        println("  BgfxRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    Logger.setLevel(LogLevel.Debug)
    println("=== outputpass：OutputPass 色调映射 + sRGB 后处理 ===")
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
