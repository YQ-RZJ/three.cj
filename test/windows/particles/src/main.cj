package particles

/**
 * particles 测试入口（v2 生命周期模式）：
 * - renderer.cj: 粒子场景设置（旋转 Points 星云 + Sprite 精灵 + 程序生成圆点纹理）
 *                EffectComposer 链：RenderPass → OutputPass → 上屏
 *                验证 Points（POINTS 图元 + size/sizeAttenuation/map）+ Sprite（广告牌）窗口渲染
 * - 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose）。
 *
 * 按键交互（详见 renderer.cj printHelp）：
 *   - 数字键 1：完整体现（Points + Sprite，默认参数：size=0.15）
 *   - 数字键 2：大粒子模式（size=0.5）
 *   - 数字键 3：小粒子模式（size=0.05）
 *   - 数字键 4：隐藏 Points（只显示 Sprite）
 *   - ←/→：调整粒子大小 size；↑/↓：调整旋转速度
 *   - 空格：暂停/恢复粒子旋转
 *   - R：重置参数到默认值；H：打印帮助
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
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.cameras.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
import three.utils.log.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景与 EffectComposer 链，onFrame 读固定快照（键盘/鼠标）并渲染，onClose 清理。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _kb: Option<KeyboardProvider> = None
    var _mouse: Option<MouseProvider> = None

    var renderer: BgfxRenderer = BgfxRenderer()
    var composer: EffectComposer
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 200.0)
    var points: Points = Points()
    var sprite: Sprite = Sprite()
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.3
    var orbitDist: Float64 = 12.0
    var rotAngle: Float64 = 0.0  // 粒子自转角度

    /// 构造：创建 EffectComposer（不依赖窗口，仅持有渲染器引用，onInit 里 addPass/setSize）
    public init() {
        this.composer = EffectComposer(this.renderer)
    }

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
        this.renderer.setClearColor(Color(0x0a, 0x0e, 0x1a))  // 深空蓝黑背景（粒子适合暗背景）
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        let (scene, camera, points, sprite) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.points = points
        this.sprite = sprite

        // EffectComposer 链：RenderPass → OutputPass → 上屏
        this.composer.addPass(RenderPass(this.scene, this.camera))
        this.composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        this.composer.setSize(Int64(w), Int64(h))

        println("[4/5] 进入渲染循环（RenderPass + OutputPass via EffectComposer，onFrame 由窗口泵线程驱动）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整相机轨道角度；滚轮：缩放；按窗口关闭按钮退出\n")
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
            this.orbitDist = clamp(this.orbitDist, 3.0, 60.0)
        }

        // ---- 键盘控制（WindowEngine 输入，替代 Win32 WM_KEYDOWN） ----
        // 数字键 1/2/3/4：切换中间步骤模式
        if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_1)) {
            g_debugMode = 1
            println("  [key] 模式切换: 1 (完整)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_2)) {
            g_debugMode = 2
            println("  [key] 模式切换: 2 (大粒子)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (小粒子)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (隐藏 Points)")
        }
        // ← 粒子大小减小
        if (_kb.getOrThrow().isKeyPressed(KeyCode.LEFT)) {
            g_particleSize = g_particleSize - 0.05
            if (g_particleSize < 0.01) { g_particleSize = 0.01 }
            println("  [key] size ← = " + g_particleSize.toString())
        }
        // → 粒子大小增大
        if (_kb.getOrThrow().isKeyPressed(KeyCode.RIGHT)) {
            g_particleSize = g_particleSize + 0.05
            if (g_particleSize > 2.0) { g_particleSize = 2.0 }
            println("  [key] size → = " + g_particleSize.toString())
        }
        // ↑ 旋转速度加快
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_rotSpeed = g_rotSpeed + 0.1
            if (g_rotSpeed > 5.0) { g_rotSpeed = 5.0 }
            println("  [key] rotSpeed ↑ = " + g_rotSpeed.toString())
        }
        // ↓ 旋转速度减慢
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_rotSpeed = g_rotSpeed - 0.1
            if (g_rotSpeed < 0.0) { g_rotSpeed = 0.0 }
            println("  [key] rotSpeed ↓ = " + g_rotSpeed.toString())
        }
        // 空格暂停/恢复旋转
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 旋转 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置参数
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetParams = true
            println("  [key] 重置粒子参数 (R)")
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
        this.camera.updateMatrixWorld(true)

        // 粒子自转（空格暂停）
        if (!g_pauseRotation) {
            this.rotAngle += g_rotSpeed * 0.01
        }
        this.points.rotation.y = this.rotAngle
        this.points.rotation.x = this.rotAngle * 0.3

        // 按键控制：实时同步 size / 可见性 到材质（Points.material 为 Material 基类引用，as 转型返回 Option 需 match）
        match (this.points.material as PointsMaterial) {
            case Some(pm) =>
                if (pm.size != g_particleSize) {
                    pm.size = g_particleSize
                    Logger.debug(["particles", "size synced: " + g_particleSize.toString()])
                }
                pm.transparent = true
            case None => ()
        }
        // 4 键隐藏 Points（mode=4 时在下面覆盖）
        this.points.visible = !g_hidePoints

        // R 键重置：参数回到默认值
        if (g_resetParams) {
            g_particleSize = DEFAULT_PARTICLE_SIZE
            g_rotSpeed = DEFAULT_ROT_SPEED
            g_hidePoints = false
            g_debugMode = MODE_FULL
            g_resetParams = false
            println("  [R] 粒子参数已重置: size=${g_particleSize.toString()} rotSpeed=${g_rotSpeed.toString()}")
        }

        // 中间步骤模式切换（按键 1/2/3/4）
        match (g_debugMode) {
            case MODE_FULL =>
                // 完整体现（默认参数）
                g_hidePoints = false
                g_particleSize = DEFAULT_PARTICLE_SIZE
            case MODE_BIG =>
                // 大粒子模式（size=0.5）
                g_hidePoints = false
                g_particleSize = 0.5
            case MODE_SMALL =>
                // 小粒子模式（size=0.05）
                g_hidePoints = false
                g_particleSize = 0.05
            case MODE_NO_POINTS =>
                // 隐藏 Points（只显示 Sprite）
                g_hidePoints = true
            case _ => ()
        }

        this.composer.render()

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} fps=${fps.toString()} size=${g_particleSize.toString()}" +
                    " rotSpeed=${g_rotSpeed.toString()} hidePoints=${g_hidePoints.toString()} mode=${g_debugMode.toString()}")
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
    println("=== particles：Points 点云 + Sprite 精灵窗口渲染测试 ===")
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
