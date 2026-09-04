package volumecloud

/**
 * volumecloud 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧键盘/鼠标交互 + 轨道控制 + 渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（地面 + 多色方块，体积云参照物）与 createScene
 *                EffectComposer 链：RenderPass → VolumeCloudPass（全屏 ray marching 体积云）→ OutputPass → 上屏
 *                验证 VolumeCloudPass 体积云效果（3D Simplex 噪声 + wang_hash 抖动 + smoothstep 密度 + 差分着色）
 *
 * 按键交互（详见 renderer.cj printHelp）：
 *   - 数字键 1：完整体积云流程（默认参数：threshold=0.25 opacity=0.25 range=0.1 steps=100）
 *   - 数字键 2：更浓密的云（opacity=0.5）
 *   - 数字键 3：更高步数精细云（steps=200）
 *   - 数字键 4：跳过 VolumeCloudPass（pass.enabled=false），纯 RenderPass 直出
 *   - ←/→：调整 threshold（密度阈值，← 减小更密，→ 增大更疏）
 *   - ↑/↓：调整 opacity（不透明度）
 *   - 空格：暂停/恢复相机轨道旋转
 *   - R：重置参数到默认值
 *   - H：打印帮助
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.BgfxRenderer
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
import three.rendering.postprocessing.VolumeCloudPass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
import three.utils.log.Logger
import three.utils.log.LogLevel
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

    var renderer: BgfxRenderer = BgfxRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var meshes: ArrayList<Mesh> = ArrayList<Mesh>()
    var composer: Option<EffectComposer> = None
    var cloudPass: Option<VolumeCloudPass> = None
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制状态
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.3
    var orbitDist: Float64 = 8.0

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/合成器） =====
    public override func onInit(): Unit {
        this._kb = this.getProvider<KeyboardProvider>()
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

        // ---- 步骤 3: 创建场景对象 ----
        println("[3/5] 创建场景对象...")
        let (scene, camera, meshes) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.meshes = meshes

        // ---- 步骤 4: 进入渲染循环（RenderPass + VolumeCloudPass + OutputPass via EffectComposer） ----
        println("[4/5] 进入渲染循环（RenderPass + VolumeCloudPass + OutputPass via EffectComposer）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整相机轨道角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // EffectComposer 链：RenderPass → VolumeCloudPass → OutputPass → 上屏
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))

        // 体积云 pass：云盒中心在原点（地面 -2 之上），半尺寸 (4,2,4)（对照 JS 示例 scale）
        // camera 为位置参数（对齐 SSRPass 构造范式），其余为命名参数
        let cloudPass = VolumeCloudPass(
            this.camera,
            cloudCenter: Vector3(0.0, 0.0, 0.0),
            cloudHalfSize: Vector3(4.0, 2.0, 4.0),
            threshold: DEFAULT_THRESHOLD,
            range: DEFAULT_RANGE,
            opacity: DEFAULT_OPACITY,
            steps: DEFAULT_STEPS,
            texSize: 64
        )
        composer.addPass(cloudPass)

        composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        composer.setSize(Int64(this.getWidth()), Int64(this.getHeight()))
        this.composer = Some(composer)
        this.cloudPass = Some(cloudPass)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
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
            println("  [key] 模式切换: 2 (浓密)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (精细)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (旁路)")
        }
        // ↑ opacity 增大
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_opacity = g_opacity + 0.05
            if (g_opacity > 1.0) { g_opacity = 1.0 }
            println("  [key] opacity ↑ = " + g_opacity.toString())
        }
        // ↓ opacity 减小
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_opacity = g_opacity - 0.05
            if (g_opacity < 0.0) { g_opacity = 0.0 }
            println("  [key] opacity ↓ = " + g_opacity.toString())
        }
        // ← threshold 减小
        if (_kb.getOrThrow().isKeyPressed(KeyCode.LEFT)) {
            g_threshold = g_threshold - 0.05
            if (g_threshold < 0.0) { g_threshold = 0.0 }
            println("  [key] threshold ← = " + g_threshold.toString())
        }
        // → threshold 增大
        if (_kb.getOrThrow().isKeyPressed(KeyCode.RIGHT)) {
            g_threshold = g_threshold + 0.05
            if (g_threshold > 1.0) { g_threshold = 1.0 }
            println("  [key] threshold → = " + g_threshold.toString())
        }
        // 空格暂停/恢复相机轨道旋转
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 轨道旋转 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置参数
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetParams = true
            println("  [key] 重置体积云参数 (R)")
        }
        // H 打印帮助
        if (_kb.getOrThrow().isKeyPressed(KeyCode.H)) {
            printHelp()
        }

        // 相机轨道（空格暂停，静态观察云）
        if (!g_pauseRotation) {
            this.orbitTheta += 0.004
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
        this.camera.updateMatrixWorld(true)

        match (this.cloudPass) {
            case Some(cloudPass) =>
                // 按键控制：实时同步 threshold/opacity 到 pass
                if (cloudPass.threshold != g_threshold) {
                    cloudPass.threshold = g_threshold
                    Logger.debug(["volumecloud", "threshold synced: " + g_threshold.toString()])
                }
                if (cloudPass.opacity != g_opacity) {
                    cloudPass.opacity = g_opacity
                    Logger.debug(["volumecloud", "opacity synced: " + g_opacity.toString()])
                }
                if (cloudPass.steps != g_steps) {
                    cloudPass.steps = g_steps
                    Logger.debug(["volumecloud", "steps synced: " + g_steps.toString()])
                }

                // R 键重置：参数回到默认值
                if (g_resetParams) {
                    g_threshold = DEFAULT_THRESHOLD
                    g_opacity = DEFAULT_OPACITY
                    g_steps = DEFAULT_STEPS
                    cloudPass.threshold = g_threshold
                    cloudPass.opacity = g_opacity
                    cloudPass.steps = g_steps
                    g_resetParams = false
                    println("  [R] 体积云参数已重置: threshold=${g_threshold.toString()} opacity=${g_opacity.toString()}" +
                            " steps=${g_steps.toString()}")
                }

                // 中间步骤模式切换（按键 1/2/3/4）
                match (g_debugMode) {
                    case MODE_FULL =>
                        // 完整体积云流程（默认参数）
                        cloudPass.enabled = true
                    case MODE_DENSE =>
                        // 更浓密的云（opacity=0.5）
                        cloudPass.enabled = true
                        cloudPass.opacity = 0.5
                        g_opacity = 0.5
                    case MODE_FINE =>
                        // 更高步数精细云（steps=200）
                        cloudPass.enabled = true
                        cloudPass.steps = 200.0
                        g_steps = 200.0
                    case MODE_BYPASS =>
                        // 跳过 VolumeCloudPass：禁用 pass，纯 RenderPass 直出
                        cloudPass.enabled = false
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
            println("  [render] frame=${this.frame} fps=${fps.toString()} threshold=${g_threshold.toString()}" +
                    " opacity=${g_opacity.toString()} steps=${g_steps.toString()} mode=${g_debugMode.toString()}")
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
        this.renderer.shutdown()
        println("  BgfxRenderer 已关闭")
        println("")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    Logger.setLevel(LogLevel.Debug)
    println("=== volumecloud：VolumeCloudPass 体积云后处理 ===")
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
