package bokeh_pass

/**
 * bokeh_pass 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧键盘/鼠标交互 + 景深渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（前后错落的彩色立方体，制造景深差异）与 createScene
 * - EffectComposer 链：RenderPass → BokehPass（focus/aperture/maxblur 可调）→ OutputPass → 上屏
 *   验证 BokehPass 景深散景效果（41 抽头 lens blur）
 *
 * 按键交互（中间步骤独立呈现，详见 renderer.cj printHelp）：
 *   - 数字键 1：完整 bokeh 流程（默认参数：focus=6 aperture=0.05 maxblur=1.0）
 *   - 数字键 2：深度图可视化（debugMode=1，深度 RT 伪彩显示）
 *   - 数字键 3：原图直出（debugMode=2，跳过 41 抽头模糊，验证 tColor 绑定）
 *   - 数字键 4：跳过 BokehPass（pass.enabled=false），纯 RenderPass 直出
 *   - ↑/↓：调整 focus（焦点距离，↑ 增大）
 *   - ←/→：调整 aperture（光圈，← 减小 → 增大）
 *   - W/S：调整 maxblur（最大模糊量，W 增大 S 减小）
 *   - 空格：暂停/恢复立方体旋转（静态场景下观察景深）
 *   - R：重置参数到默认值
 *   - H：打印帮助
 */

import std.io.*
import std.time.*
import std.collection.*
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
import three.rendering.postprocessing.BokehPass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
import three.utils.log.*
import three.utils.log.macros.*

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
    var bokehPass: Option<BokehPass> = None
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 14.0
    var rotationAngle: Float64 = 0.0

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

        println("[3/5] 创建场景对象...")
        let (scene, camera, cubes) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.cubes = cubes

        // ---- 步骤 4: 进入渲染循环（RenderPass → BokehPass → OutputPass → 上屏） ----
        println("[4/5] 进入渲染循环（RenderPass + BokehPass + OutputPass via EffectComposer）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // EffectComposer 链：RenderPass → BokehPass → OutputPass → 上屏
        let bokehPass = BokehPass(
            this.scene,
            this.camera,
            focus: DEFAULT_FOCUS,
            aperture: DEFAULT_APERTURE,
            maxblur: DEFAULT_MAXBLUR
        )
        this.bokehPass = Some(bokehPass)
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        composer.addPass(bokehPass)
        composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        composer.setSize(Int64(w), Int64(h))
        this.composer = Some(composer)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // ---- 键盘控制（WindowEngine 输入，替代 Win32 WM_KEYDOWN） ----
        // 数字键 1/2/3/4：切换中间步骤模式
        if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_1)) {
            g_debugMode = 1
            println("  [key] 模式切换: 1 (完整 bokeh)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_2)) {
            g_debugMode = 2
            println("  [key] 模式切换: 2 (深度图)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (原图直出)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (旁路)")
        }
        // ↑ focus 增大（焦点拉远）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_focus = g_focus + 0.5
            if (g_focus > 30.0) { g_focus = 30.0 }
            println("  [key] focus ↑ = " + g_focus.toString())
        }
        // ↓ focus 减小（焦点拉近）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_focus = g_focus - 0.5
            if (g_focus < 0.5) { g_focus = 0.5 }
            println("  [key] focus ↓ = " + g_focus.toString())
        }
        // ← aperture 减小（景深变深）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.LEFT)) {
            g_aperture = g_aperture - 0.01
            if (g_aperture < 0.001) { g_aperture = 0.001 }
            println("  [key] aperture ← = " + g_aperture.toString())
        }
        // → aperture 增大（散景更强）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.RIGHT)) {
            g_aperture = g_aperture + 0.01
            if (g_aperture > 0.5) { g_aperture = 0.5 }
            println("  [key] aperture → = " + g_aperture.toString())
        }
        // W maxblur 增大
        if (_kb.getOrThrow().isKeyPressed(KeyCode.W)) {
            g_maxblur = g_maxblur + 0.1
            if (g_maxblur > 5.0) { g_maxblur = 5.0 }
            println("  [key] maxblur W↑ = " + g_maxblur.toString())
        }
        // S maxblur 减小
        if (_kb.getOrThrow().isKeyPressed(KeyCode.S)) {
            g_maxblur = g_maxblur - 0.1
            if (g_maxblur < 0.01) { g_maxblur = 0.01 }
            println("  [key] maxblur S↓ = " + g_maxblur.toString())
        }
        // 空格暂停/恢复旋转
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 旋转 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置参数
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetBokeh = true
            println("  [key] 重置 bokeh 参数 (R)")
        }
        // H 打印帮助
        if (_kb.getOrThrow().isKeyPressed(KeyCode.H)) {
            printHelp()
        }

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

        // 立方体自转（空格暂停）
        if (!g_pauseRotation) {
            this.rotationAngle += 0.02
        }
        for (i in 0..this.cubes.size) {
            let cube = this.cubes[i]
            cube.rotation.x = this.rotationAngle * 0.5 + Float64(i)
            cube.rotation.y = this.rotationAngle * 0.7
        }

        // 按键控制：实时同步 focus/aperture/maxblur/debugMode 到 pass + R 重置 + 模式切换
        match (this.bokehPass) {
            case Some(p) =>
                if (p.focus != g_focus) {
                    p.focus = g_focus
                    @LogDebug(["bokeh", "focus synced: " + g_focus.toString()])
                }
                if (p.aperture != g_aperture) {
                    p.aperture = g_aperture
                    @LogDebug(["bokeh", "aperture synced: " + g_aperture.toString()])
                }
                if (p.maxblur != g_maxblur) {
                    p.maxblur = g_maxblur
                    @LogDebug(["bokeh", "maxblur synced: " + g_maxblur.toString()])
                }

                // R 键重置：参数回到默认值
                if (g_resetBokeh) {
                    g_focus = DEFAULT_FOCUS
                    g_aperture = DEFAULT_APERTURE
                    g_maxblur = DEFAULT_MAXBLUR
                    g_debugMode = MODE_FULL
                    p.focus = g_focus
                    p.aperture = g_aperture
                    p.maxblur = g_maxblur
                    g_resetBokeh = false
                    println("  [R] bokeh 参数已重置: focus=${g_focus.toString()} aperture=${g_aperture.toString()}" +
                            " maxblur=${g_maxblur.toString()}")
                }

                // 中间步骤模式切换（按键 1/2/3/4）
                match (g_debugMode) {
                    case MODE_FULL =>
                        // 完整 bokeh 流程（debugMode=0，41 抽头 lens blur）
                        p.enabled = true
                        p.debugMode = 0
                    case MODE_DEPTH =>
                        // 深度图可视化（debugMode=1，深度 RT 伪彩显示）
                        p.enabled = true
                        p.debugMode = 1
                    case MODE_PASSTHROUGH =>
                        // 原图直出（debugMode=2，跳过 41 抽头模糊）
                        p.enabled = true
                        p.debugMode = 2
                    case MODE_BYPASS =>
                        // 跳过 BokehPass：禁用 pass，纯 RenderPass 直出
                        p.enabled = false
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
            println("  [render] frame=${this.frame} fps=${fps.toString()} focus=${g_focus.toString()}" +
                    " aperture=${g_aperture.toString()} maxblur=${g_maxblur.toString()}" +
                    " mode=${g_debugMode.toString()}")
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
    println("=== bokeh_pass：BokehPass 景深散景后处理 ===")
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
