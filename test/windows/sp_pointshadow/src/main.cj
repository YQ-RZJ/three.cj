package sp_pointshadow

/**
 * sp_pointshadow 入口（v2 生命周期模式）：
 * 验证 PointLight 立方体阴影投射能力。
 * 场景：点光源位于悬浮立方体上方，向四面八方照射，立方体投影到地面六个方向之一。
 * 阴影贴图为立方体贴图（6 个面），主 pass 采样 cube shadow map。
 * 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose）。
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.MouseProvider
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.lights.*
import three.utils.log.*
import three.utils.log.macros.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var objs: SceneObjects = SceneObjects(
        scene: Scene(),
        camera: PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0),
        box: Mesh(),
        pointLight: PointLight(),
        sphere: Mesh())
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制状态（相机围绕盒子公转，初始从 +Z 看开口）
    var orbitTheta: Float64 = 0.0      // 水平角（0 = +Z 方向正对开口）
    var orbitPhi: Float64 = 0.25       // 垂直角（略俯视）
    var orbitDist: Float64 = 12.0      // 相机到盒子中心距离
    // 球体绕行半径（盒子半宽 4 内，留出球体半径余量）
    let orbitR: Float64 = 2.5

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
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
        this.renderer.setClearColor(Color(0x30, 0x30, 0x60))  // 灰蓝色背景
        println("  ThreeRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        this.objs = createScene(w, h)

        println("[4/5] 进入渲染循环（球体绕光源运动 + 相机轨道控制，onFrame 由窗口泵线程驱动）...")
        println("  鼠标左键拖动：调整视角；滚轮：缩放；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++
        let t = Float64(this.frame) * 0.016

        // ---- 球体连续螺旋绕光源运动（覆盖 cube 全部 6 个面）----
        // polar 在 [0, π] 连续摆动：polar=0 → +Y 顶，polar=π → -Y 底
        let polar = PI * (0.5 - 0.5 * cos(t * 0.35))
        // azimuth 连续旋转：覆盖 ±X/±Z 所有经度方向
        let azim = t * 0.9
        let px = this.orbitR * sin(polar) * cos(azim)
        let py = this.orbitR * cos(polar)
        let pz = this.orbitR * sin(polar) * sin(azim)
        this.objs.sphere.position.set(px, py, pz)
        // 球体自转（可选，不影响阴影形状验证）
        this.objs.sphere.rotation.y = t * 0.5

        // ---- 鼠标拖动：手动调整公转角度 ----
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            let dx = Float64(_mouse.getOrThrow().getMouseDX())
            let dy = Float64(_mouse.getOrThrow().getMouseDY())
            this.orbitTheta -= dx * 0.005
            this.orbitPhi -= dy * 0.005
            this.orbitPhi = clamp(this.orbitPhi, -1.4, 1.4)
        }

        // ---- 滚轮缩放 ----
        if (_mouse.getOrThrow().getWheelY() != 0.0f32) {
            let zoomSpeed: Float64 = 0.05
            this.orbitDist *= (1.0 - Float64(_mouse.getOrThrow().getWheelY()) * zoomSpeed)
            this.orbitDist = clamp(this.orbitDist, 3.0, 40.0)
        }

        // ---- 计算相机位置（球面坐标 → 笛卡尔坐标，围绕盒子中心原点） ----
        let cosPhi = cos(this.orbitPhi)
        this.objs.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.objs.camera.position.y = this.orbitDist * sin(this.orbitPhi)
        this.objs.camera.position.z = this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.objs.camera.lookAt(Vector3(0.0, 0.0, 0.0))

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.objs.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.objs.camera.updateProjectionMatrix()

        this.renderer.render(this.objs.scene, this.objs.camera)

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()} sphere=(${px.toString()}, ${py.toString()}, ${pz.toString()})")
        }
    }

    // ===== 生命周期：关闭前（清理渲染器 + 统计输出） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
        println("  运行时间: ${elapsed}s")
        println("  总帧数: ${this.totalFrames}")
        if (elapsed > 0.0) {
            println("  平均 FPS: ${(Float64(this.totalFrames) / elapsed).toString()}")
        }
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    // 调试：开启 Debug 日志
    println("=== sp_pointshadow：PointLight 立方体阴影验证 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，SDL3 跨平台实现） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    win.addInputProvider(MouseProvider())
    let ok = win.start(title: "three4cj", width: 1280, height: 720)
    if (!ok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 步骤 4(续): 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
