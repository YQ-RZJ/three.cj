package pixelated

/**
 * pixelated 测试入口（v2 生命周期模式）：
 * - renderer.cj: 场景设置（彩色立方体 + 渐变球）与渲染循环
 *                EffectComposer 链：RenderPixelatedPass（pixelSize/边缘强度可调）→ OutputPass → 上屏
 *                验证 RenderPixelatedPass 像素化风格（低分辨率渲染 + 深度/法线边缘检测）
 * - 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose）。
 *
 * 按键交互（中间步骤独立呈现，详见 renderer.cj printHelp）：
 *   - 数字键 1：完整像素化流程（默认参数：pixelSize=6 normalEdge=0.3 depthEdge=0.4）
 *   - 数字键 2：大像素块模式（pixelSize=16，更粗的马赛克）
 *   - 数字键 3：精细像素模式（pixelSize=2，接近原分辨率）
 *   - 数字键 4：跳过 RenderPixelatedPass（pass.enabled=false），纯 RenderPass 直出
 *   - ↑/↓：调整 pixelSize（像素尺寸，↑ 增大马赛克更粗，↓ 减小更精细）
 *   - ←/→：调整 normalEdgeStrength（法线边缘强度，← 减弱 → 增强）
 *   - W/S：调整 depthEdgeStrength（深度边缘强度，W 增强 S 减弱）
 *   - 空格：暂停/恢复立方体旋转（静态场景下观察像素化）
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
import three.scene.entity.*
import three.rendering.cameras.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPixelatedPass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
import three.utils.log.*
import std.collection.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景与 EffectComposer 链，onFrame 读固定快照（键盘/鼠标）并渲染，onClose 清理。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _kb: Option<KeyboardProvider> = None
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var composer: EffectComposer
    var pixelatedPass: RenderPixelatedPass
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var cubes: ArrayList<Mesh> = ArrayList<Mesh>()
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 12.0
    var rotationAngle: Float64 = 0.0  // 立方体自转角度

    /// 构造：创建 EffectComposer 与默认 RenderPixelatedPass（仅占位，onInit 里用真实场景重建）
    public init() {
        this.composer = EffectComposer(this.renderer)
        this.pixelatedPass = RenderPixelatedPass(
            DEFAULT_PIXEL_SIZE,
            this.scene,
            this.camera,
            normalEdgeStrength: DEFAULT_NORMAL_EDGE,
            depthEdgeStrength: DEFAULT_DEPTH_EDGE
        )
    }

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

        // EffectComposer 链：RenderPixelatedPass → OutputPass → 上屏
        this.pixelatedPass = RenderPixelatedPass(
            DEFAULT_PIXEL_SIZE,
            this.scene,
            this.camera,
            normalEdgeStrength: DEFAULT_NORMAL_EDGE,
            depthEdgeStrength: DEFAULT_DEPTH_EDGE
        )
        this.composer.addPass(this.pixelatedPass)
        this.composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        this.composer.setSize(Int64(w), Int64(h))

        println("[4/5] 进入渲染循环（RenderPixelatedPass + OutputPass via EffectComposer，onFrame 由窗口泵线程驱动）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")
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
            println("  [key] 模式切换: 2 (大像素块)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (精细像素)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (旁路)")
        }
        // ↑ pixelSize 增大
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_pixelSize = g_pixelSize + 2
            if (g_pixelSize > 32) { g_pixelSize = 32 }
            println("  [key] pixelSize ↑ = " + g_pixelSize.toString())
        }
        // ↓ pixelSize 减小
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_pixelSize = g_pixelSize - 2
            if (g_pixelSize < 1) { g_pixelSize = 1 }
            println("  [key] pixelSize ↓ = " + g_pixelSize.toString())
        }
        // ← normalEdge 减弱
        if (_kb.getOrThrow().isKeyPressed(KeyCode.LEFT)) {
            g_normalEdge = g_normalEdge - 0.05
            if (g_normalEdge < 0.0) { g_normalEdge = 0.0 }
            println("  [key] normalEdge ← = " + g_normalEdge.toString())
        }
        // → normalEdge 增强
        if (_kb.getOrThrow().isKeyPressed(KeyCode.RIGHT)) {
            g_normalEdge = g_normalEdge + 0.05
            if (g_normalEdge > 1.0) { g_normalEdge = 1.0 }
            println("  [key] normalEdge → = " + g_normalEdge.toString())
        }
        // W depthEdge 增强
        if (_kb.getOrThrow().isKeyPressed(KeyCode.W)) {
            g_depthEdge = g_depthEdge + 0.05
            if (g_depthEdge > 1.0) { g_depthEdge = 1.0 }
            println("  [key] depthEdge W↑ = " + g_depthEdge.toString())
        }
        // S depthEdge 减弱
        if (_kb.getOrThrow().isKeyPressed(KeyCode.S)) {
            g_depthEdge = g_depthEdge - 0.05
            if (g_depthEdge < 0.0) { g_depthEdge = 0.0 }
            println("  [key] depthEdge S↓ = " + g_depthEdge.toString())
        }
        // 空格暂停/恢复旋转
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 旋转 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置参数
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetPixelated = true
            println("  [key] 重置 pixelated 参数 (R)")
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

        // 立方体自转（空格暂停）
        if (!g_pauseRotation) {
            this.rotationAngle += 0.02
        }
        for (i in 0..this.cubes.size) {
            let cube = this.cubes[i]
            cube.rotation.x = this.rotationAngle * 0.5 + Float64(i)
            cube.rotation.y = this.rotationAngle * 0.7
        }

        // 按键控制：实时同步 pixelSize/边缘强度到 pass
        if (this.pixelatedPass.pixelSize != g_pixelSize) {
            this.pixelatedPass.setPixelSize(g_pixelSize)
            Logger.debug(["pixelated", "pixelSize synced: " + g_pixelSize.toString()])
        }
        if (this.pixelatedPass.normalEdgeStrength != g_normalEdge) {
            this.pixelatedPass.normalEdgeStrength = g_normalEdge
            Logger.debug(["pixelated", "normalEdge synced: " + g_normalEdge.toString()])
        }
        if (this.pixelatedPass.depthEdgeStrength != g_depthEdge) {
            this.pixelatedPass.depthEdgeStrength = g_depthEdge
            Logger.debug(["pixelated", "depthEdge synced: " + g_depthEdge.toString()])
        }

        // R 键重置：参数回到默认值
        if (g_resetPixelated) {
            g_pixelSize = DEFAULT_PIXEL_SIZE
            g_normalEdge = DEFAULT_NORMAL_EDGE
            g_depthEdge = DEFAULT_DEPTH_EDGE
            g_debugMode = MODE_FULL
            this.pixelatedPass.setPixelSize(g_pixelSize)
            this.pixelatedPass.normalEdgeStrength = g_normalEdge
            this.pixelatedPass.depthEdgeStrength = g_depthEdge
            g_resetPixelated = false
            println("  [R] pixelated 参数已重置: pixelSize=${g_pixelSize.toString()}" +
                    " normalEdge=${g_normalEdge.toString()} depthEdge=${g_depthEdge.toString()}")
        }

        // 中间步骤模式切换（按键 1/2/3/4）
        match (g_debugMode) {
            case MODE_FULL =>
                // 完整像素化流程（默认参数：pixelSize=6 normalEdge=0.3 depthEdge=0.4）
                this.pixelatedPass.enabled = true
                g_pixelSize = DEFAULT_PIXEL_SIZE
                this.pixelatedPass.setPixelSize(g_pixelSize)
                g_normalEdge = DEFAULT_NORMAL_EDGE
                this.pixelatedPass.normalEdgeStrength = g_normalEdge
                g_depthEdge = DEFAULT_DEPTH_EDGE
                this.pixelatedPass.depthEdgeStrength = g_depthEdge
            case MODE_COARSE =>
                // 大像素块模式（pixelSize=16，更粗的马赛克）
                this.pixelatedPass.enabled = true
                g_pixelSize = 16
                this.pixelatedPass.setPixelSize(g_pixelSize)
            case MODE_FINE =>
                // 精细像素模式（pixelSize=2，接近原分辨率）
                this.pixelatedPass.enabled = true
                g_pixelSize = 2
                this.pixelatedPass.setPixelSize(g_pixelSize)
            case MODE_BYPASS =>
                // 跳过 RenderPixelatedPass：禁用 pass，纯 OutputPass 直出
                this.pixelatedPass.enabled = false
            case _ => ()
        }

        this.composer.render()

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} fps=${fps.toString()} pixelSize=${g_pixelSize.toString()}" +
                    " normalEdge=${g_normalEdge.toString()} depthEdge=${g_depthEdge.toString()}" +
                    " mode=${g_debugMode.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理合成器与渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        this.composer.dispose()
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    Logger.setLevel(LogLevel.Debug)
    println("=== pixelated：RenderPixelatedPass 像素化渲染 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，SDL3 跨平台实现） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    win.addInputProvider(KeyboardProvider())
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
