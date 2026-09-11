package afterimage

/**
 * afterimage 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧键盘/鼠标交互 + 残影渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（旋转立方体 + 多色球，模拟运动残影）与 createScene
 * - EffectComposer 链：RenderPass → AfterimagePass（damp 可调）→ OutputPass → 上屏
 *   验证 AfterimagePass 残影拖尾效果（damp 越大拖尾越长）
 *
 * 按键交互（中间步骤独立呈现）：
 *   - 数字键 1：完整 afterimage 流程（comp + copy），残影拖尾
 *   - 数字键 2：仅 comp pass（残影融合），跳过 copy，观察融合中间结果
 *   - 数字键 3：仅 copy pass（无残影），对照无 afterimage 的原始渲染
 *   - 数字键 4：跳过 AfterimagePass（pass.enabled=false），纯 RenderPass 直出
 *   - ↑/↓：调整 damp（↑ 增大残影，↓ 减小残影）
 *   - 空格：暂停/恢复立方体旋转（静态场景下观察残影衰减）
 *   - R：重置 afterimage pass（清空 old RT）
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
import three.rendering.postprocessing.AfterimagePass
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
    var afterimagePass: Option<AfterimagePass> = None
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

        // ---- 步骤 4: 进入渲染循环（RenderPass → AfterimagePass → OutputPass → 上屏） ----
        println("[4/5] 进入渲染循环（RenderPass + AfterimagePass + OutputPass via EffectComposer）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        let afterimagePass = AfterimagePass(damp: g_damp)
        this.afterimagePass = Some(afterimagePass)
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        composer.addPass(afterimagePass)
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
            println("  [key] 模式切换: 1 (完整)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_2)) {
            g_debugMode = 2
            println("  [key] 模式切换: 2 (仅comp)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (仅copy)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (旁路)")
        }
        // ↑ 增大 damp（残影更长）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_damp = (g_damp + 0.02)
            if (g_damp > 0.999) { g_damp = 0.999 }
            println("  [key] damp ↑ = " + g_damp.toString())
        }
        // ↓ 减小 damp（残影更短）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_damp = (g_damp - 0.02)
            if (g_damp < 0.0) { g_damp = 0.0 }
            println("  [key] damp ↓ = " + g_damp.toString())
        }
        // 空格暂停/恢复旋转
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 旋转 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置 afterimage pass（清空 old RT）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetAfterimage = true
            println("  [key] 重置 afterimage pass (R)")
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

        // 按键控制：实时同步 damp 到 pass + R 重置 + 模式切换
        match (this.afterimagePass) {
            case Some(p) =>
                if (p.damp != g_damp) {
                    p.damp = g_damp
                    Logger.debug(["afterimage", "damp synced: " + g_damp.toString()])
                }
                // R 键重置：销毁并重建 afterimage pass 的 old RT
                if (g_resetAfterimage) {
                    p.dispose()
                    p.setSize(Int64(w), Int64(h))
                    g_resetAfterimage = false
                    println("  [R] afterimage pass 已重置（old RT 清空）")
                }
                // 中间步骤模式切换（按键 1/2/3/4）
                match (g_debugMode) {
                    case MODE_FULL =>
                        // 完整 afterimage 流程
                        p.enabled = true
                    case MODE_COMP_ONLY =>
                        // 仅 comp pass（残影融合），跳过 copy
                        p.enabled = true
                    case MODE_COPY_ONLY =>
                        // 仅 copy pass（无残影）：禁用 afterimage，纯 RenderPass 直出
                        p.enabled = false
                    case MODE_BYPASS =>
                        // 跳过 AfterimagePass：禁用 pass
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
            println("  [render] frame=${this.frame} fps=${fps.toString()} damp=${g_damp.toString()} mode=${g_debugMode.toString()}")
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
    println("=== afterimage：AfterimagePass 残影后处理 ===")
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
