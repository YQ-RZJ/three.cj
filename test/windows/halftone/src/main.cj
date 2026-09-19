package halftone

/**
 * halftone 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧键盘/鼠标交互 + 轨道控制 + 渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（旋转立方体 + 多色球，模拟动态画面）与 createScene
 * - EffectComposer 链：RenderPass → HalftonePass（shape/radius/blending 可调）→ OutputPass → 上屏
 *   验证 HalftonePass RGB 半色调效果（旋转网点印刷风，5 种形状 × 5 种混合模式）
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.KeyCode
import three.window.KeyboardProvider
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
import three.rendering.postprocessing.HalftonePass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
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
    var _kb: Option<KeyboardProvider> = None
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var cubes: ArrayList<Mesh> = ArrayList<Mesh>()
    var composer: Option<EffectComposer> = None
    var halftonePass: Option<HalftonePass> = None
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 12.0
    var rotationAngle: Float64 = 0.0  // 立方体自转角度

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/合成器） =====
    public override func onInit(): Unit {
        this._kb = this.getProvider<KeyboardProvider>()
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
        let (scene, camera, cubes) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.cubes = cubes

        // ---- 步骤 4: 进入渲染循环（RenderPass + HalftonePass + OutputPass via EffectComposer） ----
        println("[4/5] 进入渲染循环（RenderPass + HalftonePass + OutputPass via EffectComposer）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // EffectComposer 链：RenderPass → HalftonePass → OutputPass → 上屏
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))

        let halftonePass = HalftonePass(
            shape: DEFAULT_SHAPE,
            radius: DEFAULT_RADIUS,
            rotateR: DEFAULT_ROTATE_R,
            rotateG: DEFAULT_ROTATE_G,
            rotateB: DEFAULT_ROTATE_B,
            scatter: DEFAULT_SCATTER,
            blending: DEFAULT_BLENDING,
            blendingMode: DEFAULT_BLENDING_MODE,
            greyscale: false,
            disable: false
        )
        composer.addPass(halftonePass)

        composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        composer.setSize(Int64(this.getWidth()), Int64(this.getHeight()))
        this.composer = Some(composer)
        this.halftonePass = Some(halftonePass)
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

        // ---- 键盘控制（WindowEngine 输入，替代 Win32 WM_KEYDOWN） ----
        // 数字键 1/2/3/4：切换中间步骤模式
        if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_1)) {
            g_debugMode = 1
            println("  [key] 模式切换: 1 (完整)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_2)) {
            g_debugMode = 2
            println("  [key] 模式切换: 2 (Square)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (Diamond)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (旁路)")
        }
        // ↑ radius 增大
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_radius = g_radius + 0.5
            if (g_radius > 20.0) { g_radius = 20.0 }
            println("  [key] radius ↑ = " + g_radius.toString())
        }
        // ↓ radius 减小
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_radius = g_radius - 0.5
            if (g_radius < 1.0) { g_radius = 1.0 }
            println("  [key] radius ↓ = " + g_radius.toString())
        }
        // ← blending 减弱
        if (_kb.getOrThrow().isKeyPressed(KeyCode.LEFT)) {
            g_blending = g_blending - 0.1
            if (g_blending < 0.0) { g_blending = 0.0 }
            println("  [key] blending ← = " + g_blending.toString())
        }
        // → blending 增强
        if (_kb.getOrThrow().isKeyPressed(KeyCode.RIGHT)) {
            g_blending = g_blending + 0.1
            if (g_blending > 1.0) { g_blending = 1.0 }
            println("  [key] blending → = " + g_blending.toString())
        }
        // S 切换 shape
        if (_kb.getOrThrow().isKeyPressed(KeyCode.S)) {
            g_shape = g_shape + 1
            if (g_shape > 5) { g_shape = 1 }
            println("  [key] shape = " + g_shape.toString())
        }
        // G 切换 greyscale
        if (_kb.getOrThrow().isKeyPressed(KeyCode.G)) {
            g_greyscale = !g_greyscale
            println("  [key] greyscale = " + g_greyscale.toString())
        }
        // D 切换 disable
        if (_kb.getOrThrow().isKeyPressed(KeyCode.D)) {
            g_disable = !g_disable
            println("  [key] disable = " + g_disable.toString())
        }
        // 空格暂停/恢复旋转
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 旋转 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置参数
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetHalftone = true
            println("  [key] 重置 halftone 参数 (R)")
        }
        // H 打印帮助
        if (_kb.getOrThrow().isKeyPressed(KeyCode.H)) {
            printHelp()
        }

        // 相机轨道
        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 立方体自转 + 公转（空格暂停）
        if (!g_pauseRotation) {
            this.rotationAngle += 0.02
        }
        let orbitRadius: Float64 = 3.0
        for (i in 0..this.cubes.size) {
            let cube = this.cubes[i]
            let idx = Float64(i)
            // 立方体围绕原点公转 + 自转
            let angle = this.rotationAngle + idx * 2.094395  // 2π/3 偏移
            cube.position.x = orbitRadius * cos(angle)
            cube.position.z = orbitRadius * sin(angle)
            cube.position.y = 0.5 + 0.5 * sin(this.rotationAngle * 2.0 + idx)
            cube.rotation.x = this.rotationAngle
            cube.rotation.y = this.rotationAngle * 0.7
        }

        // 按键控制：实时同步 shape/radius/blending/greyscale/disable 到 pass + 模式切换
        match (this.halftonePass) {
            case Some(halftonePass) =>
                if (halftonePass.shape != g_shape) {
                    halftonePass.shape = g_shape
                    @LogDebug(["halftone", "shape synced: " + g_shape.toString()])
                }
                if (halftonePass.radius != g_radius) {
                    halftonePass.radius = g_radius
                    @LogDebug(["halftone", "radius synced: " + g_radius.toString()])
                }
                if (halftonePass.blending != g_blending) {
                    halftonePass.blending = g_blending
                    @LogDebug(["halftone", "blending synced: " + g_blending.toString()])
                }
                if (halftonePass.greyscale != g_greyscale) {
                    halftonePass.greyscale = g_greyscale
                    @LogDebug(["halftone", "greyscale synced: " + g_greyscale.toString()])
                }
                if (halftonePass.disable != g_disable) {
                    halftonePass.disable = g_disable
                    @LogDebug(["halftone", "disable synced: " + g_disable.toString()])
                }

                // R 键重置：参数回到默认值
                if (g_resetHalftone) {
                    g_shape = DEFAULT_SHAPE
                    g_radius = DEFAULT_RADIUS
                    g_blending = DEFAULT_BLENDING
                    g_greyscale = false
                    g_disable = false
                    halftonePass.shape = g_shape
                    halftonePass.radius = g_radius
                    halftonePass.blending = g_blending
                    halftonePass.greyscale = g_greyscale
                    halftonePass.disable = g_disable
                    g_resetHalftone = false
                    println("  [R] halftone 参数已重置: shape=${g_shape.toString()} radius=${g_radius.toString()}" +
                            " blending=${g_blending.toString()} greyscale=${g_greyscale.toString()} disable=${g_disable.toString()}")
                }

                // 中间步骤模式切换（按键 1/2/3/4）
                match (g_debugMode) {
                    case MODE_FULL =>
                        // 完整 halftone 流程（默认参数：shape=1/Dot radius=4 blending=1）
                        halftonePass.enabled = true
                        halftonePass.disable = false
                        g_disable = false
                    case MODE_SQUARE =>
                        // Square 形状网点模式（shape=4，方形网点）
                        halftonePass.enabled = true
                        halftonePass.disable = false
                        g_disable = false
                        halftonePass.shape = 4
                        g_shape = 4
                    case MODE_DIAMOND =>
                        // Diamond 形状网点模式（shape=5，菱形网点）
                        halftonePass.enabled = true
                        halftonePass.disable = false
                        g_disable = false
                        halftonePass.shape = 5
                        g_shape = 5
                    case MODE_BYPASS =>
                        // 跳过 HalftonePass：禁用 pass，纯 RenderPass 直出
                        halftonePass.enabled = false
                    case _ => ()
                }
            case None => ()
        }

        match (this.composer) {
            case Some(composer) => composer.render()
            case None => ()
        }

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} fps=${fps.toString()} shape=${g_shape.toString()}" +
                    " radius=${g_radius.toString()} blending=${g_blending.toString()}" +
                    " greyscale=${g_greyscale.toString()} disable=${g_disable.toString()} mode=${g_debugMode.toString()}")
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
    println("=== halftone：HalftonePass RGB 半色调后处理 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    win.addInputProvider(KeyboardProvider())
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
