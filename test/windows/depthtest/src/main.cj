package depthtest

/**
 * depthtest 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/深度可视化 overrideMaterial）→
 *   onFrame（每帧球体动画 + 相机轨道 + 渲染）→ onClose（清理 + 统计输出）
 * - 基于 boxshow，剔除灯光后的深度渲染效果
 * - 使用 three.cj 的 debug 模式实现深度图可视化
 */

import std.io.*
import std.time.*
import std.collection.*
import std.math.*
import three.rendering.BgfxRenderer
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
import three.rendering.materials.ShaderMaterial
import three.utils.log.Logger
import three.utils.log.LogLevel

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: BgfxRenderer = BgfxRenderer()
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

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/深度可视化材质） =====
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
        this.renderer.setClearColor(Color(0x30, 0x30, 0x60))  // 灰蓝色背景
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        let (scene, camera, spheres, pointLights) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.spheres = spheres
        this.pointLights = pointLights

        // ---- 使用 Three.js 标准 overrideMaterial 实现深度可视化 ----
        // 对照 three.js: scene.overrideMaterial = depthVizMaterial
        // 用 ShaderMaterial 加载深度图可视化着色器，替换场景中所有物体的材质
        println("  创建深度可视化 overrideMaterial...")
        let depthVizMat = ShaderMaterial(DEPTHVIZ_VS, DEPTHVIZ_FS)
        depthVizMat.name = "DepthViz"
        depthVizMat.side = 2  // DoubleSide：盒子内壁法线向内，需双面渲染
        this.scene.overrideMaterial = Some(depthVizMat)
        println("  scene.overrideMaterial 已设置: ${depthVizMat.name} (side=DoubleSide)")

        // ---- 步骤 4: 进入渲染循环（含统计输出） ----
        println("[4/5] 进入渲染循环（相机公转 + 深度渲染）...")
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
        println("  BgfxRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    // 调试：开启 Debug 日志
    Logger.setLevel(LogLevel.Debug)
    println("=== depthtest：开放盒子 / 深度渲染可视化 ===")
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
