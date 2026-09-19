package boxshow

/**
 * boxshow 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景）→
 *   onFrame（每帧球体/点光源动画 + 相机轨道 + 渲染）→ onClose（清理 + 统计输出）
 * - resources.cj: 开放盒子几何体构造
 * - renderer.cj:  场景设置（开放盒子 + 多色移动球 + 多色移动点光源 + 阴影）与 createScene
 */

import std.io.*
import std.time.*
import std.collection.*
import std.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.MouseProvider
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.*
import three.scene.scenegraph.*
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
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var spheres: ArrayList<Mesh> = ArrayList<Mesh>()
    var pointLights: ArrayList<PointLight> = ArrayList<PointLight>()
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    // 轨道控制状态：相机围绕盒子公转，初始从 +Z 看开口（盒子前面板在 +Z 被去掉）
    var orbitTheta: Float64 = 0.0      // 水平角（0 = +Z 方向正对开口）
    var orbitPhi: Float64 = 0.25       // 垂直角（略俯视）
    var orbitDist: Float64 = 12.0      // 相机到盒子中心距离

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
        this.renderer.setClearColor(Color(0x00, 0x00, 0xFF))  // 【视觉二分 TEMP】纯蓝，验证 clear 色是否真正生效
        println("  ThreeRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        let (scene, camera, spheres, pointLights) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.spheres = spheres
        this.pointLights = pointLights

        // ---- 步骤 4: 进入渲染循环（含统计输出） ----
        println("[4/5] 进入渲染循环（相机公转）...")
        println("  鼠标左键拖动：手动调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        this.totalFrames++

        let t = Float64(this.frame) * 0.016

        // ---- 更新球体位置（来回移动） ----
        for (sphere in this.spheres) {
            match (sphere.userData.get("__anim")) {
                case Some(aObj) => match (aObj) {
                    case a: AnimState =>
                        let s = a.speed
                        let off = sin(t * s + a.phase) * a.amp
                        match (a.axis) {
                            case 0 => sphere.position.x = off
                            case 1 => sphere.position.y = off
                            case 2 => sphere.position.z = off
                            case _ => sphere.position.x = off
                        }
                    case _ => ()
                }
                case None => ()
            }
        }

        // ---- 更新点光源位置（来回移动） ----
        for (pl in this.pointLights) {
            match (pl.userData.get("__anim")) {
                case Some(aObj) => match (aObj) {
                    case a: AnimState =>
                        let s = a.speed
                        let off = sin(t * s + a.phase) * a.amp
                        match (a.axis) {
                            case 0 => pl.position.set(off, sin(t * 0.7) * 1.5, 0.0)
                            case 1 => pl.position.set(sin(t * 0.6) * 1.5, off, 0.0)
                            case 2 => pl.position.set(sin(t * 0.5) * 1.5, sin(t * 0.8) * 1.2, off)
                            case _ => pl.position.set(off, 0.0, 0.0)
                        }
                    case _ => ()
                }
                case None => ()
            }
        }

        // ---- 鼠标拖动：手动调整公转角度（叠加在自动公转上） ----
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            let dx = Float64(_mouse.getOrThrow().getMouseDX())
            let dy = Float64(_mouse.getOrThrow().getMouseDY())
            // 竖直方向：相机绕盒子上下公转；水平方向：相机绕盒子左右公转
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
        this.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        this.renderer.render(this.scene, this.camera)

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()} orbit=(${this.orbitTheta.toString()}, ${this.orbitPhi.toString()}) dist=${this.orbitDist.toString()}")
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
        println("")
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    println("=== boxshow：开放盒子 / 多色球 / 点光源 / 阴影 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
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
