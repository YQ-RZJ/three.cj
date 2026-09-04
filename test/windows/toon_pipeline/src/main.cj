package toon_pipeline

/**
 * toon_pipeline 测试入口（v2 生命周期模式）：
 *
 * 完整实现自定义卡通渲染管线测试项目：
 *   1. onInit：创建窗口渲染器 → createScene（多几何体 + 自定义 ToonShader + 多方向光）
 *   2. onFrame：相机轨道控制 + 几何体自旋 + 自定义渲染管线帧提交
 *   3. onClose：释放 ToonOutlinePass 资源 + 统计输出 + 关闭渲染器
 *
 * 对照 three.js 官方案例 webgl_materials_toon.html：
 *   - 卡通量化光照（gradientMap 或硬编码 3 级量化）
 *   - 多方向光累加
 *   - ToonOutlinePass 后处理描边（基于深度的 Sobel 边缘检测）
 *
 * 文件结构：
 *   - main.cj:     入口，组装流程（v2 生命周期）
 *   - win32.cj:    Win32 API 声明、窗口创建、消息循环
 *   - toon_shaders.cj:        自定义卡通着色器（ToonShader + ToonEdge）
 *   - toon_outline_pass.cj:   ToonOutlinePass 后处理描边
 *   - renderer.cj: 场景设置 + createScene
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
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.lights.*
import three.utils.log.Logger
import three.utils.log.LogLevel
import std.collection.*

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
    var sceneObj: ToonScene = ToonScene(scene: Scene(), camera: PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0), meshes: ArrayList<Mesh>(), dirLights: ArrayList<DirectionalLight>())
    var outlinePass: Option<ToonOutlinePass> = None
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制：初始对齐官方相机位置 (0,1.5,5)
    // dist = |(0,1.5,5)-(0,0,0)| = sqrt(0+2.25+25) = sqrt(27.25) ≈ 5.22
    var orbitTheta: Float64 = atan2(0.0, 5.0)      // 水平角（0，正对 +Z）
    var orbitPhi: Float64 = asin(1.5 / 5.22)  // 垂直角（略俯视）
    var orbitDist: Float64 = 5.22

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
        this.renderer.setClearColor(Color(0.15, 0.15, 0.2))  // 深蓝灰背景
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        this.sceneObj = createScene(w, h)
        println("")

        // 创建 ToonOutlinePass
        let outlinePass = ToonOutlinePass(this.sceneObj.scene, this.sceneObj.camera)
        outlinePass.outlineColor = Color(0.05, 0.05, 0.08)  // 深色描边
        outlinePass.outlineStrength = 0.9
        outlinePass.edgeThreshold = 0.002
        outlinePass.setSize(Int64(w), Int64(h))
        this.outlinePass = Some(outlinePass)

        println("[4/5] 进入渲染循环（自定义卡通渲染管线，onFrame 由窗口泵线程驱动）...")
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")
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

        // 相机球面坐标 → 笛卡尔坐标（围绕 ORBIT_TARGET）
        let camera = this.sceneObj.camera
        let cosPhi = cos(this.orbitPhi)
        camera.position.x = ORBIT_TARGET.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
        camera.position.y = ORBIT_TARGET.y + this.orbitDist * sin(this.orbitPhi)
        camera.position.z = ORBIT_TARGET.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
        camera.lookAt(ORBIT_TARGET)

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        camera.updateProjectionMatrix()

        // 动画：几何体自旋（凸显卡通量化光照动态变化）
        let t = Float64(this.frame) * 0.016
        for (i in 0..this.sceneObj.meshes.size) {
            let mesh = this.sceneObj.meshes[i]
            mesh.rotation.y = t * 0.3 + Float64(i) * 0.5
            mesh.rotation.x = t * 0.15
        }

        // 自定义渲染管线帧提交：
        // 1. renderer.render(scene, camera) - 场景渲染（含自定义 ToonShader）
        // 2. ToonOutlinePass 作为可选后处理（实际效果需 EffectComposer 双 RT 支持，
        //    本测试采用简化管线，直接 renderer.render 上屏）
        this.renderer.render(this.sceneObj.scene, camera)

        // 每 60 帧打印一次状态
        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()} orbit=(${this.orbitTheta.toString()}, ${this.orbitPhi.toString()}) dist=${this.orbitDist.toString()}")
        }
    }

    // ===== 生命周期：关闭前（释放资源 + 统计输出） =====
    public override func onClose(): Unit {
        println("")

        // 释放 ToonOutlinePass 资源
        match (this.outlinePass) {
            case Some(outlinePass) => outlinePass.dispose()
            case None => ()
        }

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

main(args: Array<String>): Int64 {
    Logger.setLevel(LogLevel.Debug)
    println("=== toon_pipeline：自定义卡通渲染管线测试 ===")
    println("")
    println("功能说明：")
    println("  1. 自定义 ToonShader：量化光照 + gradientMap 控制明暗分界")
    println("  2. ToonOutlinePass：基于深度的 Sobel 边缘检测描边")
    println("  3. 多几何体测试：球/立方体/圆环/甜甜圈")
    println("  4. 多方向光：暖白主光 + 冷蓝补光")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    win.addInputProvider(MouseProvider())
    let wok = win.start(title: "toon_pipeline", width: 1280, height: 720)
    if (!wok) {
        println("  WindowEngine.start 失败!")
        return 1
    }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
