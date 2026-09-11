package xrmanager

/**
 * xrmanager 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/XR 管理器）→
 *   onFrame（每帧球体旋转 + XR 状态显示 + 渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（球体 + 灯光）与 createScene（构造并验证
 *                XRManager/XRController/XRDepthSensing 全部公开接口），
 *                SceneObjects 持有场景/相机/XR 对象引用
 * - 验证对象：xr 包（XRManager/XRController/XRDepthSensing）功能对齐，
 *            非 presenting 时回退渲染球体场景 + 画面内 dbgText 显示 XR 状态
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
import three.rendering.xr.*
import three.rendering.textures.*
import three.utils.log.Logger
import three.utils.log.LogLevel

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景/XR 管理器（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var objs: Option<SceneObjects> = None
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制状态
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.0
    var orbitDist: Float64 = 10.0
    let targetCenter = Vector3(0.0, 0.0, 0.0)

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/XR 管理器） =====
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
        this.renderer.setClearColor(Color(0x202030))
        this.renderer.setDebug(0x00000008)
        println("  ThreeRenderer 初始化成功")
        println("")

        // ---- 步骤 3: 创建场景对象（含 XR 管理器/控制器/深度感知构造与接口验证） ----
        println("[3/5] 创建场景对象...")
        this.objs = Some(createScene(w, h, this.renderer))

        // ---- 步骤 4: 进入渲染循环 ----
        println("[4/5] 进入渲染循环（XR 状态显示 + 球体渲染）...")
        println("  鼠标左键拖动：调整视角；滚轮：缩放；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++
        let t = Float64(this.frame) * 0.016

        match (this.objs) {
            case Some(objs) =>
                objs.sphere.rotation.y = t * 0.5

                // ---- XR 双眼模式：presenting 时先更新左右眼相机（IPD 偏移）----
                // 对照 JS: WebXRManager.updateCamera → 渲染前设置 cameraL/cameraR 位姿，
                // 渲染器遍历 ArrayCamera.cameras 各渲半屏。
                if (objs.xrManager.isXRPresenting()) {
                    objs.xrManager.updateCamera(objs.camera)
                }

                // ---- 鼠标拖动 ----
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

                // ---- 相机位置 ----
                let cosPhi = cos(this.orbitPhi)
                objs.camera.position.x = this.targetCenter.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
                objs.camera.position.y = this.targetCenter.y + this.orbitDist * sin(this.orbitPhi)
                objs.camera.position.z = this.targetCenter.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
                objs.camera.lookAt(this.targetCenter)

                let w = this.getWidth()
                let h = this.getHeight()
                objs.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
                objs.camera.updateProjectionMatrix()

                // ---- 画面内文本 ----
                this.renderer.dbgTextClear(0x00, false)
                this.renderer.dbgTextPrintf(0, 0, 0x0f, "XR presenting=" + objs.xrManager.isXRPresenting().toString() + " refSpace=" + refSpaceStr(objs.xrManager.getReferenceSpaceType()))
                let ctrlVisible = objs.controller.getTargetRaySpace().visible
                this.renderer.dbgTextPrintf(0, 1, 0x0e, "controller.rayVisible=" + ctrlVisible.toString() + " depthTex=" + objs.depthSensing.getTexture().idx.toString())

                // ---- 渲染：presenting 时走 ArrayCamera 双眼视口，否则单眼 ----
                // 对照 JS: WebGLRenderer 在 camera.isArrayCamera 时遍历 cameras 各渲半屏
                if (objs.xrManager.isXRPresenting()) {
                    this.renderer.render(objs.scene, objs.xrManager.getCamera())
                } else {
                    this.renderer.render(objs.scene, objs.camera)
                }
            case None => ()
        }

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()}")
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
    Logger.setLevel(LogLevel.Debug)
    println("=== xrmanager：xr 包功能验证（XRManager/XRController/XRDepthSensing） ===")
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
