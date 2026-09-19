package sp_shadowproj

/**
 * sp_shadowproj 入口（v2 生命周期模式）：
 * - renderer.cj:  场景设置（方向光 + 悬浮立方体 + 地面平面 + 阴影）与场景创建
 * - debug mode 7：shadowMatrix 投影 UV 可视化（scene.overrideMaterial = ShadowProjMaterial）
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
import three.rendering.materials.ShadowProjMaterial
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
        camera: PerspectiveCamera(fov: 45.0, aspect: 1.0, near: 0.1, far: 100.0),
        cube: Mesh(),
        dirLight: DirectionalLight())
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制状态（初始位置 = 光源默认位置 (5,10,7.5) 从 target=(0,1,0) 反算）
    //   dist = sqrt(5² + 9² + 7.5²) ≈ 12.737
    //   phi  = asin(9/12.737) ≈ 0.785 (45°)
    //   theta = atan2(5, 7.5) ≈ 0.588
    var orbitTheta: Float64 = 0.588      // 水平角
    var orbitPhi: Float64 = 0.785        // 垂直角
    var orbitDist: Float64 = 12.737      // 到场景中心距离
    let targetCenter = Vector3(0.0, 1.0, 0.0)  // 围绕地面+立方体中心

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

        // ---- 启用 debug mode 7（shadowMatrix 投影 UV 可视化） ----
        // 新架构对齐 Three.js：renderer.setDebugMode 已移除。
        // Debug 可视化用 Three.js 标准 scene.overrideMaterial：
        //   scene.overrideMaterial = Some(ShadowProjMaterial())
        // ShadowProjMaterial 是 bgfx4cj 扩展内置材质，kind 映射到 ShaderLibs 已注册的
        // "shadowproj" 程序，把 receiver 顶点经 directionalShadowMatrix 投影后的 xy 当颜色输出，
        // 顶点位置体现 UV 覆盖范围（验证阴影矩阵是否正确把世界坐标变换到 [0,1]² 阴影 UV 空间）。
        // 依赖 Renderer._render 在 beginRender 前调用 backend.prepareShadowMap 生成 shadowMap +
        // 每个 draw 前调用 backend.bindShadowUniforms 绑定 directionalShadowMatrix uniform。
        println("  设置 Debug overrideMaterial: ShadowProjMaterial (阴影投影 UV 可视化)")
        let shadowProjMat = ShadowProjMaterial()
        shadowProjMat.name = "ShadowProj"
        shadowProjMat.side = 2  // DoubleSide：平面双面可见
        this.objs.scene.overrideMaterial = Some(shadowProjMat)
        println("  scene.overrideMaterial 已设置: ${shadowProjMat.name}")

        println("[4/5] 进入渲染循环（相机轨道控制，onFrame 由窗口泵线程驱动）...")
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

        // ---- 光源跟随相机轨道（光照和相机共享同一视点方向，便于调试阴影投影） ----
        this.objs.dirLight.position.copy(this.objs.camera.position)
        this.objs.dirLight.target.position.set(0.0, 1.0, 0.0)

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
        println("  ThreeRenderer 已关闭")
        println("")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    // 调试：开启 Debug 日志
    println("=== sp_shadowproj：debug mode 7 - shadowMatrix 投影 UV 可视化 ===")
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
