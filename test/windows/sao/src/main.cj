package sp_sao

/**
 * sp_sao 测试入口（v2 生命周期模式）：
 * - resources.cj: 开放盒子几何体构造（备用，未在官方案例场景中使用）
 * - renderer.cj:  场景设置（120 随机球体 + SAO，参数对齐官方案例）
 * - 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose）。
 *
 * 调试：数字键 1-3 切换 SAO 输出模式（1=Default 2=纯AO图 3=法线图）。
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.BgfxRenderer
import three.window.WindowEngine
import three.window.KeyCode
import three.window.KeyboardProvider
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.utils.log.Logger
import three.utils.log.LogLevel
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.BgfxSAOPass

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景与 EffectComposer 链，onFrame 读固定快照并渲染，onClose 清理。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _kb: Option<KeyboardProvider> = None

    var renderer: BgfxRenderer = BgfxRenderer()
    var composer: EffectComposer
    var saoPass: BgfxSAOPass
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 65.0, aspect: 1.0, near: 3.0, far: 10.0)
    var group: Group = Group()
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    /// 构造：创建 EffectComposer 与默认 BgfxSAOPass（仅占位，onInit 里用真实场景重建）
    public init() {
        this.composer = EffectComposer(this.renderer)
        this.saoPass = BgfxSAOPass(this.scene, this.camera)
    }

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/合成器） =====
    public override func onInit(): Unit {
        this._kb = this.getProvider<KeyboardProvider>()


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
        this.renderer.setClearColor(Color(0x30, 0x30, 0x60))  // 灰蓝色背景
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        let (scene, camera, group) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.group = group

        // 对齐 Three.js EffectComposer 用法（对照官方 webgl_postprocessing_sao.html）：
        //   const composer = new EffectComposer(renderer)
        //   composer.addPass(new RenderPass(scene, camera))
        //   const saoPass = new SAOPass(scene, camera)
        //   composer.addPass(saoPass)
        //   composer.render()
        this.composer.addPass(RenderPass(this.scene, this.camera))
        this.saoPass = BgfxSAOPass(this.scene, this.camera)
        // 参数：官方未显式修改 params（构造函数默认值）→ BgfxSAOPass 默认值即官方默认
        //   output=Default(0)：AO 混合到场景；调试可用 SAO=1/Normal=2
        this.saoPass.output = BgfxSAOPass.OUTPUT_DEFAULT
        this.composer.addPass(this.saoPass)
        this.composer.setSize(Int64(w), Int64(h))

        println("[4/5] 进入渲染循环（球体群缓慢旋转，onFrame 由窗口泵线程驱动）...")
        println("  按窗口关闭按钮退出；数字键 1-3 切换 SAO 输出模式（1=Default 2=纯AO图 3=法线图）\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++
        let timerMs = Float64((MonoTime.now() - this.startTime).toMilliseconds())

        // group 缓慢旋转（对齐官方 timer*0.0002 / timer*0.0001）
        this.group.rotation.x = timerMs * 0.0002
        this.group.rotation.y = timerMs * 0.0001

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // ★调试：按数字键 1-3 切换 SAO 输出模式（1=Default 2=纯AO图 3=法线图）
        if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_1)) {
            g_outputMode = 0
            g_outputDirty.store(true)
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_2)) {
            g_outputMode = 1
            g_outputDirty.store(true)
        } else if (_kb.getOrThrow().isKeyPressed(KeyCode.NUM_3)) {
            g_outputMode = 2
            g_outputDirty.store(true)
        }
        if (g_outputDirty.load()) {
            g_outputDirty.store(false)
            this.saoPass.output = g_outputMode
            println("  [render] saoPass.output -> ${g_outputMode}")
        }

        // SAO 后处理 pass 链（RenderPass → BgfxSAOPass）
        this.composer.render()

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理合成器与渲染器 + 统计输出） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        this.composer.dispose()
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
    println("=== sp_sao：尺度敏感环境光遮蔽（SAO）后处理 pass ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，SDL3 跨平台实现） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    win.addInputProvider(KeyboardProvider())
    let wok = win.start(title: "three4cj", width: 1280, height: 720)
    if (!wok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 步骤 4(续): 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
