package sp_ssr

/**
 * sp_ssr 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧相机轨道 + SSR 按键调试 + 渲染 + capture 状态机）→ onClose（清理）
 * - resources.cj: 开放盒子几何体构造（反射房间）
 * - renderer.cj:  场景设置（房间 + 球 + 立方体 + 圆环 + SSR）与 createScene
 *
 * 对照 three.js 官方案例 webgl_postprocessing_ssr.html。
 */

import std.io.*
import std.time.*
import std.math.*
import std.collection.*
import three.rendering.BgfxRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.KeyCode
import three.window.KeyboardProvider
import three.window.MouseProvider
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.BgfxSSRPass
import three.utils.log.Logger
import three.utils.log.LogLevel
import three.scene.objects.*

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
    var modelGroup: Group = Group()
    var composer: Option<EffectComposer> = None
    var ssrPass: Option<BgfxSSRPass> = None
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制：初始对齐官方相机位置 (0,1.5,5)（围绕 target (0,1,0)）
    // dist = |(0,1.5,5)-(0,1,0)| = sqrt(0+0.25+25) = sqrt(25.25) ≈ 5.025
    var orbitTheta: Float64 = atan2(0.0, 5.0)      // 水平角（0，正对 +Z）
    var orbitPhi: Float64 = asin((1.5 - 1.0) / 5.025)  // 垂直角（略俯视）
    var orbitDist: Float64 = 5.025

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
        this.renderer.setClearColor(Color(0x22, 0x22, 0x22))  // 深灰背景，凸显反射
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        // ---- 步骤 3: 创建场景对象 ----
        println("[3/5] 创建场景对象...")
        let (scene, camera, modelGroup, groundReflector) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.modelGroup = modelGroup

        // ---- 步骤 4: 进入渲染循环（相机公转 + SSR 调试） ----
        println("[4/5] 进入渲染循环（相机公转 + SSR 调试）...")
        println("  按键：1=Default 2=SSR 3=Beauty 4=Depth 5=Normal")
        println("        B=blur F=fresnel D=distanceAttenuation I=infiniteThick")
        println("        O/P=opacity-/+ T/Y=thickness-/+ M/N=maxDistance-/+ H=help")
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // 对齐 Three.js EffectComposer 用法（对照官方 webgl_postprocessing_ssr.html）：
        //   const composer = new EffectComposer(renderer)
        //   composer.addPass(new RenderPass(scene, camera))
        //   const ssrPass = new SSRPass({ scene, camera, width, height })
        //   composer.addPass(ssrPass)
        //   composer.render()
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        let ssrPass = BgfxSSRPass(this.scene, this.camera)
        // 参数对齐官方 webgl_postprocessing_ssr.html（SSRPass 默认值）：
        //   opacity=0.5, maxDistance=180, thickness=0.018, blur=true,
        //   distanceAttenuation=true, fresnel=true, infiniteThick=false
        // output=Default（0）：场景色 + SSR 混合
        ssrPass.output = BgfxSSRPass.OUTPUT_DEFAULT
        // selective 模式——只有模型执行 SSR（球/立方体/甜甜圈），地面不执行：
        //   Three.js 官方范式：groundReflector（地板 portal 反射）+ selects=[金属物体]，
        //   SSR 只处理 selects 中的物体表面反射。
        //   地面用 GroundReflector（平面反射：镜像相机渲场景到反射 RT，
        //   ReflectorShader 经 textureMatrix 投影到地面），地面自身不执行 SSR——
        //   SSR 在平面掠射的固有自相交（水平条纹斑马纹）不作用于地面，selects 不含地面。
        //   group.add 顺序：groundReflector=0/sphere=1/box=2/torus=3
        let selects = ArrayList<Object3D>()
        let groupChildren = modelGroup.children
        if (groupChildren.size >= 4) {
            selects.add(groupChildren[1])  // sphere（球）
            selects.add(groupChildren[2])  // box（立方体）
            selects.add(groupChildren[3])  // torus（甜甜圈）
        }
        ssrPass.selective = true
        ssrPass.selects = Some(selects)
        // 挂载地面反射器（对照 JS: new SSRPass({ ..., groundReflector })）
        ssrPass.groundReflector = Some(groundReflector)
        composer.addPass(ssrPass)
        composer.setSize(Int64(this.getWidth()), Int64(this.getHeight()))
        this.composer = Some(composer)
        this.ssrPass = Some(ssrPass)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++

        // 鼠标拖动：调整公转角度
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            let dx = Float64(_mouse.getOrThrow().getMouseDX())
            let dy = Float64(_mouse.getOrThrow().getMouseDY())
            this.orbitTheta -= dx * 0.005
            this.orbitPhi -= dy * 0.005
            this.orbitPhi = clamp(this.orbitPhi, -1.4, 1.4)
        }

        // 滚轮缩放
        if (_mouse.getOrThrow().getWheelY() != 0.0f32) {
            let zoomSpeed: Float64 = 0.05
            this.orbitDist *= (1.0 - Float64(_mouse.getOrThrow().getWheelY()) * zoomSpeed)
            this.orbitDist = clamp(this.orbitDist, 2.0, 30.0)
        }

        // ---- 键盘控制（WindowEngine 输入，替代 Win32 WM_KEYDOWN） ----
        // 数字键 1..6：切换 OUTPUT 模式（1=Default 2=SSR 3=Beauty 4=Depth 5=Normal 6=HitNormals）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_1)) {
            g_outputMode = 0  // Default
            g_outputDirty.store(true)
            println("  [key] OUTPUT -> Default (1)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_2)) {
            g_outputMode = 1  // SSR
            g_outputDirty.store(true)
            println("  [key] OUTPUT -> SSR (2)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_outputMode = 3  // Beauty
            g_outputDirty.store(true)
            println("  [key] OUTPUT -> Beauty (3)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_4)) {
            g_outputMode = 4  // Depth
            g_outputDirty.store(true)
            println("  [key] OUTPUT -> Depth (4)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_5)) {
            g_outputMode = 5  // Normal
            g_outputDirty.store(true)
            println("  [key] OUTPUT -> Normal (5)")
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_6)) {
            g_outputMode = 6  // HitNormals
            g_outputDirty.store(true)
            println("  [key] OUTPUT -> HitNormals (6)")
        }
        // B：blur 开关
        if (_kb.getOrThrow().isKeyPressed(KeyCode.B)) {
            g_blur = !g_blur
            g_blurDirty.store(true)
            println("  [key] blur -> ${g_blur}")
        }
        // F：fresnel 开关
        if (_kb.getOrThrow().isKeyPressed(KeyCode.F)) {
            g_fresnel = !g_fresnel
            g_fresnelDirty.store(true)
            println("  [key] fresnel -> ${g_fresnel}")
        }
        // G：debug 诊断着色开关
        if (_kb.getOrThrow().isKeyPressed(KeyCode.G)) {
            g_debug = !g_debug
            g_debugDirty.store(true)
            println("  [key] debug(诊断着色) -> ${g_debug}")
        }
        // D：distanceAttenuation 开关
        if (_kb.getOrThrow().isKeyPressed(KeyCode.D)) {
            g_distanceAttenuation = !g_distanceAttenuation
            g_distanceAttenuationDirty.store(true)
            println("  [key] distanceAttenuation -> ${g_distanceAttenuation}")
        }
        // I：infiniteThick 开关
        if (_kb.getOrThrow().isKeyPressed(KeyCode.I)) {
            g_infiniteThick = !g_infiniteThick
            g_infiniteThickDirty.store(true)
            println("  [key] infiniteThick -> ${g_infiniteThick}")
        }
        // O / P：减小 / 增大 opacity
        if (_kb.getOrThrow().isKeyPressed(KeyCode.O)) {
            g_opacity = max(g_opacity - 0.05, 0.0)
            g_opacityDirty.store(true)
            println("  [key] opacity -> ${g_opacity}")
        }
        if (_kb.getOrThrow().isKeyPressed(KeyCode.P)) {
            g_opacity = min(g_opacity + 0.05, 1.0)
            g_opacityDirty.store(true)
            println("  [key] opacity -> ${g_opacity}")
        }
        // T / Y：减小 / 增大 thickness
        if (_kb.getOrThrow().isKeyPressed(KeyCode.T)) {
            g_thickness = max(g_thickness - 0.002, 0.001)
            g_thicknessDirty.store(true)
            println("  [key] thickness -> ${g_thickness}")
        }
        if (_kb.getOrThrow().isKeyPressed(KeyCode.Y)) {
            g_thickness = min(g_thickness + 0.002, 0.1)
            g_thicknessDirty.store(true)
            println("  [key] thickness -> ${g_thickness}")
        }
        // M / N：减小 / 增大 maxDistance
        if (_kb.getOrThrow().isKeyPressed(KeyCode.M)) {
            g_maxDistance = max(g_maxDistance - 10.0, 10.0)
            g_maxDistanceDirty.store(true)
            println("  [key] maxDistance -> ${g_maxDistance}")
        }
        if (_kb.getOrThrow().isKeyPressed(KeyCode.N)) {
            g_maxDistance = min(g_maxDistance + 10.0, 500.0)
            g_maxDistanceDirty.store(true)
            println("  [key] maxDistance -> ${g_maxDistance}")
        }
        // H：打印帮助
        if (_kb.getOrThrow().isKeyPressed(KeyCode.H)) {
            println("  [help] SSR 测试按键：")
            println("    1=Default 2=SSR 3=Beauty 4=Depth 5=Normal")
            println("    B=blur F=fresnel D=distanceAttenuation I=infiniteThick")
            println("    O/P=opacity-/+ T/Y=thickness-/+ M/N=maxDistance-/+")
            println("    鼠标左键拖动=公转 滚轮=缩放")
        }

        // 相机球面坐标 → 笛卡尔坐标（围绕 ORBIT_TARGET）
        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = ORBIT_TARGET.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = ORBIT_TARGET.y + this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = ORBIT_TARGET.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.lookAt(ORBIT_TARGET)

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 同步 SSR 调试参数到 ssrPass（仅 dirty 时）
        // 注：define 类参数（fresnel/distanceAttenuation/infiniteThick）改动需重新编译 shader，
        //     BgfxSSRPass._compileSSRShader 在 programHandle==invalid 时才编译，
        //     故 dirty 时主动重置 programHandle 强制下帧重编译。
        match (this.ssrPass) {
            case Some(ssrPass) =>
                if (g_outputDirty.load()) {
                    g_outputDirty.store(false)
                    ssrPass.output = g_outputMode
                }
                if (g_blurDirty.load()) {
                    g_blurDirty.store(false)
                    ssrPass.blur = g_blur
                }
                if (g_opacityDirty.load()) {
                    g_opacityDirty.store(false)
                    ssrPass.opacity = g_opacity
                }
                if (g_maxDistanceDirty.load()) {
                    g_maxDistanceDirty.store(false)
                    ssrPass.maxDistance = g_maxDistance
                }
                if (g_thicknessDirty.load()) {
                    g_thicknessDirty.store(false)
                    ssrPass.thickness = g_thickness
                }
                // define 类参数：改动后需重编译 SSR shader
                var needRecompile = false
                if (g_fresnelDirty.load()) {
                    g_fresnelDirty.store(false)
                    ssrPass.fresnel = g_fresnel
                    needRecompile = true
                }
                if (g_distanceAttenuationDirty.load()) {
                    g_distanceAttenuationDirty.store(false)
                    ssrPass.distanceAttenuation = g_distanceAttenuation
                    needRecompile = true
                }
                if (g_infiniteThickDirty.load()) {
                    g_infiniteThickDirty.store(false)
                    ssrPass.infiniteThick = g_infiniteThick
                    needRecompile = true
                }
                // debug 诊断着色：uniform 开关（u_debug.x），无需重编译 shader
                if (g_debugDirty.load()) {
                    g_debugDirty.store(false)
                    ssrPass.debug = g_debug
                }
                if (needRecompile) {
                    // 通过反射重置 programHandle 触发下帧重编译（_compileSSRShader 检测 invalid 时编译）
                    // 此处 ssrPass 暴露 recompile() 方法更优雅，但避免改动 pass 接口，依赖其内部懒编译机制
                    // 注：BgfxSSRPass 首帧已编译，define 改动需销毁旧 program 重编译。
                    // 当前实现：pass 内部 programHandle 不会自动重置，故 define 改动需重启程序生效。
                    // 这是已知限制，记录在日志中。
                    println("  [render] define 参数已改动（fresnel/distanceAttenuation/infiniteThick），需重启程序以重新编译 shader")
                }
            case None => ()
        }

        // SSR 后处理 pass 链（RenderPass → BgfxSSRPass）
        match (this.composer) {
            case Some(composer) => composer.render()
            case None => ()
        }

        // 每帧推进 capture 状态机（'C' 键 / --capture 自动模式；诊断地面反射 RT 内容）
        match (this.ssrPass) {
            case Some(ssrPass) =>
                match (this.composer) {
                    case Some(composer) => tickCapture(this.renderer, ssrPass, composer, this.frame, this.camera.near, this.camera.far)
                    case None => ()
                }
            case None => ()
        }

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            match (this.ssrPass) {
                case Some(ssrPass) =>
                    println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()} orbit=(${this.orbitTheta.toString()}, ${this.orbitPhi.toString()}) dist=${this.orbitDist.toString()} output=${ssrPass.output} blur=${ssrPass.blur} opacity=${ssrPass.opacity} thickness=${ssrPass.thickness} maxDist=${ssrPass.maxDistance}")
                case None => ()
            }
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

main(args: Array<String>): Int64 {
    Logger.setLevel(LogLevel.Debug)
    // --capture：自动模式第 45 帧抓取 SSR 全部中间 RT（含反射 RT/反射深度 RT）并退出
    for (a in args) {
        if (a == "--capture") {
            g_capAuto = true
            println("=== 诊断模式：--capture 自动抓取 SSR 中间 RT（含反射 RT）===")
        }
    }
    println("=== sp_ssr：屏幕空间反射（SSR）后处理 pass 测试 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2） ----
    println("[1/5] 创建窗口（WindowEngine）...")
    let win = TestWindow()
    win.addInputProvider(KeyboardProvider())
    win.addInputProvider(MouseProvider())
    let wok = win.start(title: "sp_ssr", width: 1280, height: 720)
    if (!wok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
