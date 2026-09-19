package transition

/**
 * transition 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/过渡纹理/EffectComposer）→
 *   onFrame（每帧键盘/鼠标交互 + 轨道控制 + 渲染）→ onClose（清理）
 * - renderer.cj: 双场景设置（场景A：红色系立方体；场景B：蓝色系立方体）与 createScenes
 *                EffectComposer 链：RenderTransitionPass（mixRatio/threshold 可调）→ OutputPass → 上屏
 *                验证 RenderTransitionPass 场景过渡效果（纹理过渡 + 纯比例混合）
 *
 * 按键交互（中间步骤独立呈现，详见 renderer.cj printHelp）：
 *   - 数字键 1：自动过渡循环（mixRatio 0→1→0 自动往复）
 *   - 数字键 2：静态场景A（mixRatio=0，全场景A）
 *   - 数字键 3：半过渡（mixRatio=0.5，A/B 各半）
 *   - 数字键 4：静态场景B（mixRatio=1，全场景B）
 *   - ↑/↓：手动调整 mixRatio（过渡比例，↑ 增大偏向场景B，↓ 减小偏向场景A）
 *   - ←/→：调整 threshold（过渡纹理阈值，← 减小效果更强，→ 增大效果更弱）
 *   - T：切换 useTexture（纹理过渡 / 纯比例混合）
 *   - 空格：暂停/恢复自动过渡循环
 *   - R：重置参数到默认值
 *   - H：打印帮助
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
import three.rendering.postprocessing.RenderTransitionPass
import three.rendering.postprocessing.OutputPass
import three.rendering.types.*
import three.utils.constants.*
import three.utils.log.*
import three.utils.log.macros.*
import std.collection.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景/过渡纹理/合成器（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _kb: Option<KeyboardProvider> = None
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var sceneA: Scene = Scene()
    var sceneB: Scene = Scene()
    var cameraA: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var cameraB: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var cubes: ArrayList<Mesh> = ArrayList<Mesh>()
    var composer: Option<EffectComposer> = None
    var transitionPass: Option<RenderTransitionPass> = None
    var mixTex: TextureHandle = INVALID_TEXTURE_HANDLE
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制状态
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 12.0
    var rotationAngle: Float64 = 0.0  // 立方体自转角度

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/过渡纹理/合成器） =====
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
        let (sceneA, sceneB, cameraA, cameraB, cubes) = createScenes(w, h)
        this.sceneA = sceneA
        this.sceneB = sceneB
        this.cameraA = cameraA
        this.cameraB = cameraB
        this.cubes = cubes

        // ---- 步骤 4: 进入渲染循环（RenderTransitionPass + OutputPass via EffectComposer） ----
        println("[4/5] 进入渲染循环（RenderTransitionPass + OutputPass via EffectComposer）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // 生成过渡纹理
        this.mixTex = createMixTexture(this.renderer)

        // EffectComposer 链：RenderTransitionPass → OutputPass → 上屏
        let composer = EffectComposer(this.renderer)
        let transitionPass = RenderTransitionPass(this.sceneA, this.cameraA, this.sceneB, this.cameraB)
        transitionPass.setTransition(DEFAULT_MIX_RATIO)
        transitionPass.setTextureThreshold(DEFAULT_THRESHOLD)
        transitionPass.useTexture(DEFAULT_USE_TEXTURE)
        transitionPass.setTexture(this.mixTex)
        composer.addPass(transitionPass)
        composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        composer.setSize(Int64(this.getWidth()), Int64(this.getHeight()))
        this.composer = Some(composer)
        this.transitionPass = Some(transitionPass)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // 鼠标轨道控制（两相机同步）
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
            println("  [key] 模式切换: 1 (自动过渡)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_2)) {
            g_debugMode = 2
            println("  [key] 模式切换: 2 (静态场景A)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (半过渡)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (静态场景B)")
        }
        // ↑ mixRatio 增大（偏向场景B）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_mixRatio = g_mixRatio + 0.05
            if (g_mixRatio > 1.0) { g_mixRatio = 1.0 }
            println("  [key] mixRatio ↑ = " + g_mixRatio.toString())
        }
        // ↓ mixRatio 减小（偏向场景A）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_mixRatio = g_mixRatio - 0.05
            if (g_mixRatio < 0.0) { g_mixRatio = 0.0 }
            println("  [key] mixRatio ↓ = " + g_mixRatio.toString())
        }
        // ← threshold 减小（效果更强）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.LEFT)) {
            g_threshold = g_threshold - 0.01
            if (g_threshold < 0.01) { g_threshold = 0.01 }
            println("  [key] threshold ← = " + g_threshold.toString())
        }
        // → threshold 增大（效果更弱）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.RIGHT)) {
            g_threshold = g_threshold + 0.01
            if (g_threshold > 1.0) { g_threshold = 1.0 }
            println("  [key] threshold → = " + g_threshold.toString())
        }
        // T 切换 useTexture
        if (_kb.getOrThrow().isKeyPressed(KeyCode.T)) {
            g_useTexture = !g_useTexture
            println("  [key] useTexture = " + g_useTexture.toString())
        }
        // 空格暂停/恢复自动循环
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 自动循环 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置参数
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetTransition = true
            println("  [key] 重置 transition 参数 (R)")
        }
        // H 打印帮助
        if (_kb.getOrThrow().isKeyPressed(KeyCode.H)) {
            printHelp()
        }

        // 相机轨道（两相机同步）
        let cosPhi = cos(this.orbitPhi)
        let camX = this.orbitDist * cosPhi * sin(this.orbitTheta)
        let camY = this.orbitDist * sin(this.orbitPhi)
        let camZ = this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.cameraA.position.set(camX, camY, camZ)
        this.cameraA.lookAt(Vector3(0.0, 0.0, 0.0))
        this.cameraB.position.set(camX, camY, camZ)
        this.cameraB.lookAt(Vector3(0.0, 0.0, 0.0))
        let w = this.getWidth()
        let h = this.getHeight()
        let asp = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.cameraA.aspect = asp
        this.cameraA.updateProjectionMatrix()
        this.cameraB.aspect = asp
        this.cameraB.updateProjectionMatrix()

        // 立方体自转（两场景同步）
        if (!g_pauseRotation) {
            this.rotationAngle += 0.02
        }
        for (i in 0..this.cubes.size) {
            let cube = this.cubes[i]
            cube.rotation.x = this.rotationAngle * 0.5 + Float64(i)
            cube.rotation.y = this.rotationAngle * 0.7
        }

        match (this.transitionPass) {
            case Some(transitionPass) =>
                // 按键控制：实时同步 mixRatio/threshold/useTexture 到 pass
                if (transitionPass.mixRatio != g_mixRatio) {
                    transitionPass.setTransition(g_mixRatio)
                    @LogDebug(["transition", "mixRatio synced: " + g_mixRatio.toString()])
                }
                if (transitionPass.threshold != g_threshold) {
                    transitionPass.setTextureThreshold(g_threshold)
                    @LogDebug(["transition", "threshold synced: " + g_threshold.toString()])
                }
                if (transitionPass.useMixTexture != g_useTexture) {
                    transitionPass.useTexture(g_useTexture)
                    @LogDebug(["transition", "useTexture synced: " + g_useTexture.toString()])
                }

                // R 键重置：参数回到默认值
                if (g_resetTransition) {
                    g_mixRatio = DEFAULT_MIX_RATIO
                    g_threshold = DEFAULT_THRESHOLD
                    g_useTexture = DEFAULT_USE_TEXTURE
                    g_debugMode = MODE_AUTO
                    g_autoDirection = 1
                    transitionPass.setTransition(g_mixRatio)
                    transitionPass.setTextureThreshold(g_threshold)
                    transitionPass.useTexture(g_useTexture)
                    g_resetTransition = false
                    println("  [R] transition 参数已重置: mixRatio=${g_mixRatio.toString()}" +
                            " threshold=${g_threshold.toString()} useTexture=${g_useTexture.toString()}")
                }

                // 中间步骤模式切换（按键 1/2/3/4）
                match (g_debugMode) {
                    case MODE_AUTO =>
                        // 自动过渡循环：mixRatio 0→1→0 往复
                        transitionPass.enabled = true
                        if (!g_pauseRotation) {
                            g_mixRatio = g_mixRatio + 0.01 * Float64(g_autoDirection)
                            if (g_mixRatio >= 1.0) {
                                g_mixRatio = 1.0
                                g_autoDirection = -1
                            } else if (g_mixRatio <= 0.0) {
                                g_mixRatio = 0.0
                                g_autoDirection = 1
                            }
                            transitionPass.setTransition(g_mixRatio)
                        }
                    case MODE_SCENE_A =>
                        // 静态场景A（mixRatio=0，全场景A）
                        transitionPass.enabled = true
                        g_mixRatio = 0.0
                        transitionPass.setTransition(0.0)
                    case MODE_HALF =>
                        // 半过渡（mixRatio=0.5，A/B 各半）
                        transitionPass.enabled = true
                        g_mixRatio = 0.5
                        transitionPass.setTransition(0.5)
                    case MODE_SCENE_B =>
                        // 静态场景B（mixRatio=1，全场景B）
                        transitionPass.enabled = true
                        g_mixRatio = 1.0
                        transitionPass.setTransition(1.0)
                    case _ => ()
                }

                match (this.composer) {
                    case Some(composer) => composer.render()
                    case None => ()
                }

                if (this.frame % 60 == 1) {
                    let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
                    let fps = Float64(this.frame) / elapsed
                    println("  [render] frame=${this.frame} fps=${fps.toString()} mixRatio=${g_mixRatio.toString()}" +
                            " threshold=${g_threshold.toString()} useTexture=${g_useTexture.toString()}" +
                            " mode=${g_debugMode.toString()}")
                }
            case None => ()
        }
    }

    // ===== 生命周期：关闭前（清理合成器/过渡纹理/渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        match (this.composer) {
            case Some(composer) => composer.dispose()
            case None => ()
        }
        if (Handle.isValid(this.mixTex)) { this.renderer.destroyTexture(this.mixTex) }
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    println("=== transition：RenderTransitionPass 场景过渡渲染 ===")
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
