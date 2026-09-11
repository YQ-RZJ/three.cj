package dotscreen

/**
 * dotscreen 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧键盘/鼠标交互 + 点阵渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（旋转立方体 + 多色球，模拟动态画面）与 createScene
 * - EffectComposer 链：RenderPass → DotScreenPass（angle/scale/center 可调）→ OutputPass → 上屏
 *   验证 DotScreenPass 点阵屏效果（旋转点阵网点，average*10-5+pattern 灰度化）
 *
 * 按键交互（中间步骤独立呈现，详见 renderer.cj printHelp）：
 *   - 数字键 1：完整 dot screen 流程（默认参数：center=(0.5,0.5) angle=1.57 scale=1.0）
 *   - 数字键 2：高密度点阵模式（scale=4.0，点更小更密）
 *   - 数字键 3：低密度点阵模式（scale=0.3，点更大更稀疏）
 *   - 数字键 4：跳过 DotScreenPass（pass.enabled=false），纯 RenderPass 直出
 *   - ←/→：调整 angle（点阵旋转角度，← 减小，→ 增大）
 *   - ↑/↓：调整 scale（点阵密度，↑ 增大点变小，↓ 减小点变大）
 *   - 空格：暂停/恢复立方体旋转（静态场景下观察点阵）
 *   - R：重置参数到默认值（center=0.5,0.5 angle=1.57 scale=1.0）
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
import three.rendering.postprocessing.DotScreenPass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
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
    var _kb: Option<KeyboardProvider> = None
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var cubes: ArrayList<Mesh> = ArrayList<Mesh>()
    var composer: Option<EffectComposer> = None
    var dotScreenPass: Option<DotScreenPass> = None
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 12.0
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

        // ---- 步骤 4: 进入渲染循环（RenderPass → DotScreenPass → OutputPass → 上屏） ----
        println("[4/5] 进入渲染循环（RenderPass + DotScreenPass + OutputPass via EffectComposer）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // EffectComposer 链：RenderPass → DotScreenPass → OutputPass → 上屏
        let dotScreenPass = DotScreenPass(
            center: Vector2(DEFAULT_CENTER_X, DEFAULT_CENTER_Y),
            angle: DEFAULT_ANGLE,
            scale: DEFAULT_SCALE
        )
        this.dotScreenPass = Some(dotScreenPass)
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        composer.addPass(dotScreenPass)
        composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        composer.setSize(Int64(w), Int64(h))
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

        // ---- 键盘控制（WindowEngine 输入，替代 Win32 WM_KEYDOWN） ----
        // 数字键 1/2/3/4：切换中间步骤模式
        if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_1)) {
            g_debugMode = 1
            println("  [key] 模式切换: 1 (完整)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_2)) {
            g_debugMode = 2
            println("  [key] 模式切换: 2 (高密度)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (低密度)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (旁路)")
        }
        // ↑ scale 增大（点更小更密）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_scale = g_scale + 0.1
            if (g_scale > 10.0) { g_scale = 10.0 }
            println("  [key] scale ↑ = " + g_scale.toString())
        }
        // ↓ scale 减小（点更大更稀疏）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_scale = g_scale - 0.1
            if (g_scale < 0.05) { g_scale = 0.05 }
            println("  [key] scale ↓ = " + g_scale.toString())
        }
        // ← angle 减小
        if (_kb.getOrThrow().isKeyPressed(KeyCode.LEFT)) {
            g_angle = g_angle - 0.1
            if (g_angle < 0.0) { g_angle = 0.0 }
            println("  [key] angle ← = " + g_angle.toString())
        }
        // → angle 增大
        if (_kb.getOrThrow().isKeyPressed(KeyCode.RIGHT)) {
            g_angle = g_angle + 0.1
            if (g_angle > 6.28) { g_angle = 6.28 }
            println("  [key] angle → = " + g_angle.toString())
        }
        // 空格暂停/恢复旋转
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 旋转 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置参数
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetDotScreen = true
            println("  [key] 重置 dotscreen 参数 (R)")
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

        // 按键控制：实时同步 angle/scale/center 到 pass + R 重置 + 模式切换
        match (this.dotScreenPass) {
            case Some(p) =>
                if (p.angle != g_angle) {
                    p.angle = g_angle
                    Logger.debug(["dotscreen", "angle synced: " + g_angle.toString()])
                }
                if (p.scale != g_scale) {
                    p.scale = g_scale
                    Logger.debug(["dotscreen", "scale synced: " + g_scale.toString()])
                }

                // R 键重置：参数回到默认值
                if (g_resetDotScreen) {
                    g_angle = DEFAULT_ANGLE
                    g_scale = DEFAULT_SCALE
                    g_centerX = DEFAULT_CENTER_X
                    g_centerY = DEFAULT_CENTER_Y
                    p.center.x = g_centerX
                    p.center.y = g_centerY
                    p.angle = g_angle
                    p.scale = g_scale
                    g_resetDotScreen = false
                    println("  [R] dotscreen 参数已重置: angle=${g_angle.toString()} scale=${g_scale.toString()}" +
                            " center=(${g_centerX.toString()},${g_centerY.toString()})")
                }

                // 中间步骤模式切换（按键 1/2/3/4）
                match (g_debugMode) {
                    case MODE_FULL =>
                        // 完整 dot screen 流程（默认参数）
                        p.enabled = true
                    case MODE_HIGH_DENSITY =>
                        // 高密度点阵模式（scale=4.0，点更小更密）
                        p.enabled = true
                        p.scale = 4.0
                        g_scale = 4.0
                    case MODE_LOW_DENSITY =>
                        // 低密度点阵模式（scale=0.3，点更大更稀疏）
                        p.enabled = true
                        p.scale = 0.3
                        g_scale = 0.3
                    case MODE_BYPASS =>
                        // 跳过 DotScreenPass：禁用 pass，纯 RenderPass 直出
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
            println("  [render] frame=${this.frame} fps=${fps.toString()} angle=${g_angle.toString()}" +
                    " scale=${g_scale.toString()} mode=${g_debugMode.toString()}")
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
    Logger.setLevel(LogLevel.Debug)
    println("=== dotscreen：DotScreenPass 点阵屏后处理 ===")
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
