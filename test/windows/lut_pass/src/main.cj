package lut_pass

/**
 * lut_pass 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/3D LUT/EffectComposer）→
 *   onFrame（每帧键盘/鼠标交互 + 轨道控制 + 渲染）→ onClose（清理 + 释放 LUT 纹理）
 * - renderer.cj: 场景设置（彩色立方体 + 渐变球，含 HDR 高光）+ createLutTexture/createScene
 * - EffectComposer 链：RenderPass → LUTPass（lut/intensity 可调）→ OutputPass → 上屏
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
import three.rendering.postprocessing.LUTPass
import three.rendering.postprocessing.OutputPass
import three.utils.constants.*
import three.utils.log.Logger
import three.utils.log.LogLevel
import three.rendering.types.*
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
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var cubes: ArrayList<Mesh> = ArrayList<Mesh>()
    var composer: Option<EffectComposer> = None
    var lutPass: Option<LUTPass> = None
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
        let (scene, camera, cubes) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.cubes = cubes

        // ---- 步骤 4: 进入渲染循环（RenderPass + LUTPass + OutputPass via EffectComposer） ----
        println("[4/5] 进入渲染循环（RenderPass + LUTPass + OutputPass via EffectComposer）...")
        println("  按键交互：")
        printHelp()
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // 程序化生成 4 种 3D LUT 纹理（identity/warm/cool/contrast）
        g_lutTextures.add(createLutTexture(this.renderer, LUT_IDENTITY))
        g_lutTextures.add(createLutTexture(this.renderer, LUT_WARM))
        g_lutTextures.add(createLutTexture(this.renderer, LUT_COOL))
        g_lutTextures.add(createLutTexture(this.renderer, LUT_CONTRAST))
        println("  4 种 3D LUT 纹理创建完成（identity/warm/cool/contrast, ${LUT_SIZE}³ RGBA8）\n")

        // EffectComposer 链：RenderPass → LUTPass → OutputPass → 上屏
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))

        // 默认用 warm LUT（索引 lutType-1）
        let lutPass = LUTPass(
            lut: g_lutTextures[Int64(DEFAULT_LUT_TYPE) - 1],
            lutSize: LUT_SIZE,
            intensity: DEFAULT_INTENSITY
        )
        composer.addPass(lutPass)

        composer.addPass(OutputPass(toneMapping: ACESFilmicToneMapping, exposure: 1.0, sRGB: true))
        composer.setSize(Int64(this.getWidth()), Int64(this.getHeight()))
        this.composer = Some(composer)
        this.lutPass = Some(lutPass)
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
            println("  [key] 模式切换: 2 (半强度)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_debugMode = 3
            println("  [key] 模式切换: 3 (零强度)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_debugMode = 4
            println("  [key] 模式切换: 4 (旁路)")
        }
        // ↑ intensity 增大
        if (_kb.getOrThrow().isKeyPressed(KeyCode.UP)) {
            g_intensity = g_intensity + 0.1
            if (g_intensity > 1.0) { g_intensity = 1.0 }
            println("  [key] intensity ↑ = " + g_intensity.toString())
        }
        // ↓ intensity 减小
        if (_kb.getOrThrow().isKeyPressed(KeyCode.DOWN)) {
            g_intensity = g_intensity - 0.1
            if (g_intensity < 0.0) { g_intensity = 0.0 }
            println("  [key] intensity ↓ = " + g_intensity.toString())
        }
        // ← LUT 类型前一个
        if (_kb.getOrThrow().isKeyPressed(KeyCode.LEFT)) {
            g_lutType = g_lutType - 1
            if (g_lutType < LUT_IDENTITY) { g_lutType = LUT_CONTRAST }
            println("  [key] LUT ← = " + g_lutType.toString())
        }
        // → LUT 类型下一个
        if (_kb.getOrThrow().isKeyPressed(KeyCode.RIGHT)) {
            g_lutType = g_lutType + 1
            if (g_lutType > LUT_CONTRAST) { g_lutType = LUT_IDENTITY }
            println("  [key] LUT → = " + g_lutType.toString())
        }
        // 空格暂停/恢复旋转
        if (_kb.getOrThrow().isKeyPressed(KeyCode.SPACE)) {
            g_pauseRotation = !g_pauseRotation
            println("  [key] 旋转 " + (if (g_pauseRotation) { "暂停" } else { "恢复" }))
        }
        // R 重置参数
        if (_kb.getOrThrow().isKeyPressed(KeyCode.R)) {
            g_resetLut = true
            println("  [key] 重置 LUT 参数 (R)")
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

        // 按键控制：实时同步 intensity / lut（LUT 类型切换）到 pass + 模式切换
        match (this.lutPass) {
            case Some(lutPass) =>
                if (lutPass.intensity != g_intensity) {
                    lutPass.intensity = g_intensity
                    Logger.debug(["lut", "intensity synced: " + g_intensity.toString()])
                }
                // LUT 类型切换：g_lutTextures 下标 = lutType-1
                let lutIdx = g_lutType - 1
                if (lutIdx >= 0 && lutIdx < g_lutTextures.size) {
                    let curLut = g_lutTextures[Int64(lutIdx)]
                    if (handleIdx(lutPass.lut) != handleIdx(curLut)) {
                        lutPass.lut = curLut
                        Logger.debug(["lut", "lut switched: type=" + g_lutType.toString() +
                                      " tex.idx=" + handleIdx(curLut).toString()])
                    }
                }

                // R 键重置：参数回到默认值
                if (g_resetLut) {
                    g_intensity = DEFAULT_INTENSITY
                    g_lutType = DEFAULT_LUT_TYPE
                    g_debugMode = MODE_FULL
                    lutPass.intensity = g_intensity
                    lutPass.lut = g_lutTextures[Int64(g_lutType) - 1]
                    g_resetLut = false
                    println("  [R] LUT 参数已重置: intensity=${g_intensity.toString()} lutType=${g_lutType.toString()}")
                }

                // 中间步骤模式切换（按键 1/2/3/4）
                match (g_debugMode) {
                    case MODE_FULL =>
                        // 完整 LUT 流程（intensity=1.0）
                        lutPass.enabled = true
                        g_intensity = 1.0
                        lutPass.intensity = 1.0
                    case MODE_HALF =>
                        // 半强度混合（intensity=0.5，原图与 LUT 各半）
                        lutPass.enabled = true
                        g_intensity = 0.5
                        lutPass.intensity = 0.5
                    case MODE_ZERO =>
                        // 零强度（intensity=0，LUTPass 直通，等价原图）
                        lutPass.enabled = true
                        g_intensity = 0.0
                        lutPass.intensity = 0.0
                    case MODE_BYPASS =>
                        // 跳过 LUTPass：禁用 pass，纯 RenderPass 直出
                        lutPass.enabled = false
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
            let lutName = match (g_lutType) {
                case LUT_IDENTITY => "identity"
                case LUT_WARM => "warm"
                case LUT_COOL => "cool"
                case LUT_CONTRAST => "contrast"
                case _ => "Unknown"
            }
            println("  [render] frame=${this.frame} fps=${fps.toString()} intensity=${g_intensity.toString()}" +
                    " lut=${lutName} mode=${g_debugMode.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理合成器/释放 LUT 纹理/渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        match (this.composer) {
            case Some(composer) => composer.dispose()
            case None => ()
        }
        // 释放 3D LUT 纹理（本测试项目创建，负责销毁）
        for (t in g_lutTextures) {
            if (isValidHandle(t)) { this.renderer.destroyTexture(t) }
        }
        this.renderer.shutdown()
        println("  BgfxRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    Logger.setLevel(LogLevel.Debug)
    println("=== lut_pass：LUTPass 3D 查找表颜色分级 ===")
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
