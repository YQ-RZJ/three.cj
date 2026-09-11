package threeTest

/**
 * 测试入口：Three.js + bgfx 着色器材质测试（v2 生命周期模式）
 *
 * 模块说明：
 * - renderer.cj:  Three.js 场景设置、渲染循环（onFrame 由窗口泵线程驱动）
 * - resources.cj: 自定义着色器源码与几何体辅助函数
 * 窗口通过 three 引擎自带的 src/window 子包（WindowEngine v2，SDL3 跨平台实现）创建，
 * 不再依赖 Win32 FFI。
 */

import std.io.*
import std.time.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var mesh: Mesh = Mesh(geometry: createColoredBoxGeometry(1.5, 1.5, 1.5),
                          material: ShaderMaterial(CUBE_VS, CUBE_FS))
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        let dpr = this.getPixelRatio()
        println("[2/5] 初始化 BgfxRenderer（绑定窗口 ${hwnd}, ${w}x${h}, DPR=${dpr}）...")
        this.renderer.setPixelRatio(Float64(dpr))
        let rok = this.renderer.initBgfx(hwnd, w, h)
        if (!rok) {
            println("  ThreeRenderer.initBgfx 失败!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x30, 0x30, 0x60))  // 灰蓝色背景
        println("  ThreeRenderer 初始化成功")
        println("")

        println("[3/5] 创建场景...")
        this.camera.position.set(0.0, 2.0, 5.0)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        this.mesh.position.set(0.0, 0.0, 0.0)
        this.scene.add(this.mesh)
        println("  场景创建成功: 彩色立方体 + ShaderMaterial")
        println("")
        println("[4/5] 进入渲染循环（onFrame 由窗口泵线程驱动，按窗口关闭按钮退出）...")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // 更新旋转
        let angle = Float64(this.frame) * 0.02
        this.mesh.rotation.x = angle * 0.5
        this.mesh.rotation.y = angle * 0.7

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
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()} rot=(${this.mesh.rotation.x}, ${this.mesh.rotation.y})")
        }
    }

    // ===== 生命周期：关闭前（清理渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
        println("  运行时间: ${elapsed}s")
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    println("=== three4cj ShaderMaterial 测试 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，SDL3 跨平台实现） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    let wok = win.start(title: "three4cj ShaderMaterial", width: 1280, height: 720)
    if (!wok) {
        println("  WindowEngine.start 失败!")
        return 1
    }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 步骤 4(续): 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
