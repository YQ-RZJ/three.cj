package sp_lightdir

/**
 * sp_lightdir 测试入口（v2 生命周期模式）：
 * - renderer.cj:  场景设置（方向光 + 悬浮立方体 + 地面平面 + 阴影）
 * 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose），
 * 不再使用 win.beginFrame()/while(!win.isCloseRequested()) 手动循环。
 *
 * 最简阴影投射演示：
 * 场景自上而下：光源（黄色标记球）→ 悬浮立方体（caster）→ 地面平面（receiver）
 * 目的：用最简几何体直观验证"光照遮挡→阴影投射"的核心效果
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
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.LightDirMaterial
import three.rendering.cameras.*
import three.rendering.lights.*

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
    var objs: SceneObjects = SceneObjects(scene: Scene(),
        camera: PerspectiveCamera(fov: 45.0, aspect: 1.0, near: 0.1, far: 100.0),
        cube: Mesh(), dirLight: DirectionalLight())
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制状态（runRenderLoop 局部变量提升为子类字段）
    var orbitTheta: Float64 = 0.8      // 水平角（初始从斜侧方观察）
    var orbitPhi: Float64 = 0.4        // 垂直角（略俯视）
    var orbitDist: Float64 = 14.0      // 相机到场景中心距离
    let targetCenter = Vector3(0.0, 1.0, 0.0)  // 围绕地面+立方体中心

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
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
        this.objs = createScene(w, h)

        // ---- 步骤 3.5: 启用 debug mode 4（光源方向可视化） ----
        // 新架构对齐 Three.js：renderer.setDebugMode 已移除。
        // Debug 可视化用 Three.js 标准 scene.overrideMaterial：
        //   scene.overrideMaterial = Some(LightDirMaterial())
        // LightDirMaterial 是 bgfx4cj 扩展内置材质（对照 Three.js 无），kind 映射到
        // ShaderLibs 已注册的 "lightdir" 程序，将 N·L 映射为灰度：朝光面=白、背光面=黑，
        // 用于验证方向光 u_lightDir0 是否正确传递。
        println("  设置 Debug overrideMaterial: LightDirMaterial (N·L 光源方向可视化)")
        let lightdirMat = LightDirMaterial()
        lightdirMat.name = "LightDir"
        lightdirMat.side = 2  // DoubleSide：平面/立方体双面可见
        this.objs.scene.overrideMaterial = Some(lightdirMat)
        println("  scene.overrideMaterial 已设置: ${lightdirMat.name}")

        // ---- 步骤 4: 进入渲染循环（onFrame 由窗口泵线程驱动） ----
        println("[4/5] 进入渲染循环（相机轨道控制）...")
        println("  鼠标左键拖动：调整视角；滚轮：缩放；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++
        let t = Float64(this.frame) * 0.016

        // ---- 悬浮立方体缓慢自转 ----
        this.objs.cube.rotation.y = t * 0.5

        // ---- 鼠标拖动：手动调整视角 ----
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

        // ---- 计算相机位置（球面坐标 → 笛卡尔坐标） ----
        let cosPhi = cos(this.orbitPhi)
        this.objs.camera.position.x = this.targetCenter.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.objs.camera.position.y = this.targetCenter.y + this.orbitDist * sin(this.orbitPhi)
        this.objs.camera.position.z = this.targetCenter.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.objs.camera.lookAt(this.targetCenter)

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.objs.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.objs.camera.updateProjectionMatrix()

        this.renderer.render(this.objs.scene, this.objs.camera)

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
        this.renderer.shutdown()
        println("  BgfxRenderer 已关闭")
        println("")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    println("=== sp_lightdir：debug mode 4 - 光源方向 N·L 可视化 ===")
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
