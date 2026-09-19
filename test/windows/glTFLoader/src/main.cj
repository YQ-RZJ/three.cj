package threeTest

/**
 * 测试入口：Three.js + bgfx GLTF 模型加载测试（v2 生命周期模式）
 *
 * 模块说明：
 * - renderer.cj:   Three.js 场景设置、GLB 模型加载、createScene
 * - resources.cj:  模块占位（无自定义着色器）
 * 窗口通过 three 引擎自带的 WindowEngine v2 创建：TestWindow <: WindowEngine，
 * onInit/onFrame/onClose 生命周期由窗口泵线程驱动。
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.MouseProvider
import three.core.math.*
import three.utils.log.*
import three.utils.log.macros.*
import three.scene.scenegraph.*
import three.rendering.cameras.*

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
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var modelGroup: Group = Group()
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.0
    var orbitDist: Float64 = 10.0

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

        // ---- 步骤 3: 创建场景对象 ----
        println("[3/5] 创建场景对象...")
        let (scene, camera, modelGroup) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.modelGroup = modelGroup

        // ---- 步骤 4: 进入渲染循环 ----
        println("[4/5] 进入渲染循环...")
        println("  按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++

        // 鼠标拖动旋转模型视角（围绕目标点旋转 Orbit）
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            let dx = Float64(_mouse.getOrThrow().getMouseDX())
            let dy = Float64(_mouse.getOrThrow().getMouseDY())
            // 竖直方向：相机绕模型上下公转；水平方向：相机绕模型左右公转
            this.orbitTheta -= dx * 0.005
            this.orbitPhi -= dy * 0.005
            // 限制垂直角度，防止翻转
            this.orbitPhi = clamp(this.orbitPhi, -1.5, 1.5)
        }

        // 滚轮缩放
        if (_mouse.getOrThrow().getWheelY() != 0.0f32) {
            let zoomSpeed: Float64 = 0.05
            this.orbitDist *= (1.0 - Float64(_mouse.getOrThrow().getWheelY()) * zoomSpeed)
            this.orbitDist = clamp(this.orbitDist, 1.0, 50.0)
        }

        // 计算相机位置（球面坐标 → 笛卡尔坐标）
        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = this.orbitDist * cosPhi * cos(this.orbitTheta)

        // Three.cj 的 lookAt 已修复：set() 以列优先存储视图矩阵
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))

        // [DEBUG] 查看四元数、视图矩阵与位置
        if (this.frame % 60 == 1) {
            println("  [dbg] q=(${this.camera.quaternion.x.toString()}, ${this.camera.quaternion.y.toString()}, ${this.camera.quaternion.z.toString()}, ${this.camera.quaternion.w.toString()})")
            println("  [dbg] pos=(${this.camera.position.x.toString()}, ${this.camera.position.y.toString()}, ${this.camera.position.z.toString()})")
            let mwi = this.camera.matrixWorldInverse
            println("  [dbg] mwi[0]=(${mwi.elements[0].toString()}, ${mwi.elements[1].toString()}, ${mwi.elements[2].toString()}, ${mwi.elements[3].toString()})")
            println("  [dbg] mwi[1]=(${mwi.elements[4].toString()}, ${mwi.elements[5].toString()}, ${mwi.elements[6].toString()}, ${mwi.elements[7].toString()})")
            println("  [dbg] mwi[2]=(${mwi.elements[8].toString()}, ${mwi.elements[9].toString()}, ${mwi.elements[10].toString()}, ${mwi.elements[11].toString()})")
            // 检查模型世界位置、clip 平面
            let mPos = Vector3(this.modelGroup.matrixWorld.elements[12], this.modelGroup.matrixWorld.elements[13], this.modelGroup.matrixWorld.elements[14])
            println("  [dbg] modelGroup.worldPos=(${mPos.x.toString()}, ${mPos.y.toString()}, ${mPos.z.toString()})")
            println("  [dbg] cam near=${this.camera.near.toString()} far=${this.camera.far.toString()}")
            // 相机在世界空间的前方向量（matrixWorldInverse 第 3 行取反 = 相机 -Z 方向）
            let fwd = Vector3(-mwi.elements[8], -mwi.elements[9], -mwi.elements[10])
            println("  [dbg] camFwd=(${fwd.x.toString()}, ${fwd.y.toString()}, ${fwd.z.toString()})")
        }

        // 更新相机宽高比（窗口可能已调整大小）
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 渲染场景
        this.renderer.render(this.scene, this.camera)

        // 每 60 帧打印一次日志
        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理渲染器 + 统计输出） =====
    public override func onClose(): Unit {
        println("")

        // 打印最终统计信息
        println("[5/5] 清理资源...")
        let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
        println("  运行时间: ${elapsed}s")
        println("  总帧数: ${this.totalFrames}")
        println("  平均 FPS: ${(Float64(this.totalFrames) / elapsed).toString()}")
        println("")
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    println("=== three4cj glTF Loader 测试 ===")
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
