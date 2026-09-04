package taa

/**
 * taa 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/EffectComposer）→
 *   onFrame（每帧轨道控制 + TAA 跨帧累加渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（盒子 + 多色球 + 地面，边缘清晰的几何体，静止场景）与 createScene
 *                 pass 链：TAARenderPass（跨帧累加 jitter 样本，accumulate=true）
 *
 * TAA 正确使用姿势（对照 three.js 官方 webgl_postprocessing_taa 示例）：
 *   - 场景静止（不旋转几何体）时，TAA 跨帧累积约 32 帧后达到完整 32 样本 AA 结果，
 *     边缘最平滑、画面稳定。
 *   - 相机轨道旋转会产生残影（TAA 无重投影，非 TRAA）——这是预期行为，旋转停止后
 *     画面重新累积收敛。
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.BgfxRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.MouseProvider
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.TAARenderPass
import three.utils.log.Logger
import three.utils.log.LogLevel
import std.collection.*
import three.scene.objects.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景/合成器（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: BgfxRenderer = BgfxRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var meshes: ArrayList<Object3D> = ArrayList<Object3D>()
    var composer: Option<EffectComposer> = None
    var taaPass: Option<TAARenderPass> = None
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 11.0

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/合成器） =====
    public override func onInit(): Unit {
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
        this.renderer.setClearColor(Color(0x10, 0x12, 0x18))  // 深蓝黑背景
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        // ---- 步骤 3: 创建场景对象 ----
        println("[3/5] 创建场景对象...")
        let (scene, camera, meshes) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.meshes = meshes

        // ---- 步骤 4: 进入渲染循环（TAARenderPass via EffectComposer） ----
        println("[4/5] 进入渲染循环（TAARenderPass via EffectComposer）...")
        println("  场景静止：约 32 帧累积后边缘最平滑（TAA 收敛）")
        println("  鼠标左键拖动：调整公转角度（会产生残影，停止后重新收敛）；滚轮：缩放\n")

        // 对齐 Three.js EffectComposer 用法：
        //   const taaRenderPass = new TAARenderPass(scene, camera)
        //   taaRenderPass.accumulate = true
        //   composer.addPass(taaRenderPass)
        let composer = EffectComposer(this.renderer)
        let taaPass = TAARenderPass(this.scene, this.camera)
        taaPass.accumulate = true   // 启用跨帧累加（TAA）
        composer.addPass(taaPass)
        composer.setSize(Int64(this.getWidth()), Int64(this.getHeight()))
        this.composer = Some(composer)
        this.taaPass = Some(taaPass)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        let t = Float64(this.frame) * 0.016

        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            this.orbitTheta -= Float64(_mouse.getOrThrow().getMouseDX()) * 0.005
            this.orbitPhi -= Float64(_mouse.getOrThrow().getMouseDY()) * 0.005
            this.orbitPhi = clamp(this.orbitPhi, -1.4, 1.4)
        }
        if (_mouse.getOrThrow().getWheelY() != 0.0f32) {
            this.orbitDist *= (1.0 - Float64(_mouse.getOrThrow().getWheelY()) * 0.05)
            this.orbitDist = clamp(this.orbitDist, 3.0, 40.0)
        }

        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.lookAt(Vector3(0.0, 0.5, 0.0))
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 场景静止：不旋转几何体（TAA 时间累加，运动产生残影）
        // （若想观察残影，可取消注释下方旋转）

        match (this.composer) {
            case Some(composer) => composer.render()
            case None => ()
        }

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            match (this.taaPass) {
                case Some(taaPass) =>
                    println("  [render] frame=${this.frame} fps=${fps.toString()} accumulateIndex=${taaPass.accumulateIndex}")
                case None => ()
            }
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
        println("  BgfxRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    Logger.setLevel(LogLevel.Debug)
    println("=== taa：时间抗锯齿（TAA，跨帧累加）===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2） ----
    println("[1/5] 创建窗口（WindowEngine）...")
    let win = TestWindow()
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
