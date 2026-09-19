package test_helpers

/**
 * test_helpers 渲染测试入口（v2 生命周期模式）：
 * - helperChecks.cj: 计算类断言（验证各 helper 生成的数据，无需窗口）
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景）→
 *   onFrame（每帧 helpers 整体旋转展示 + 渲染）→ onClose（清理）
 * - renderer.cj: 视觉测试场景（所有 helpers 围一圈 + 轨道旋转）+ createScene
 *
 * 运行方式：在 test_helpers 目录内 cjpm run
 * 计算断言全部通过后才进入视觉渲染；断言失败以非 0 退出码结束。
 */

import std.io.*
import std.time.*
import std.math.*
import three.core.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.*
import three.scene.objects.*
import three.utils.log.*
import three.utils.log.macros.*
import three.physics.world.PhysicsWorld
import three.audio.device.AudioContext
import std.collection.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 200.0)
    var objects: ArrayList<Object3D> = ArrayList<Object3D>()
    var world: PhysicsWorld = PhysicsWorld()
    var frame: Int64 = 0

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[3/4] 初始化 BgfxRenderer（绑定窗口 ${hwnd}, ${w}x${h}）...")
        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            println("  ThreeRenderer.initBgfx 失败!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x20, 0x20, 0x30))
        this.renderer.setDebug(0x00000008)
        println("  渲染器初始化成功: ${w}x${h}")
        println("")

        // ---- 步骤 4: 创建场景（所有 helpers）并进入渲染循环 ----
        println("[4/4] 创建场景...")
        let (scene, camera, objects, world) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.objects = objects
        this.world = world
        println("进入渲染循环（helpers 围一圈旋转展示；按窗口关闭按钮退出）...\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        let t = Float64(this.frame) * 0.02

        // 整体缓慢旋转展示
        this.camera.position.set(14.0 * sin(t * 0.2), 4.0, 14.0 * cos(t * 0.2))
        this.camera.lookAt(Vector3(0.0, 0.5, 0.0))

        // 每 120 帧打印一次状态
        if (this.frame % 120 == 1) {
            println("  [render] frame=${this.frame} helpers=${this.objects.size}")
        }

        this.renderer.render(this.scene, this.camera)
    }

    // ===== 生命周期：关闭前（清理渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("=== test_helpers 视觉测试完成 ===")
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        this.world.shutdown()
        println("  PhysicsWorld 已关闭")
        AudioContext.context.shutdown()
        println("  AudioContext 已关闭")
    }
}

main(): Int64 {
    println("=== test_helpers：helpers 计算断言 + 视觉渲染 ===")
    println("")

    // ---- 步骤 1: 计算类断言（无需窗口）----
    println("[1/4] 运行 helpers 计算类断言...")
    let ok = runHelperChecks()
    if (!ok) {
        println("  计算断言存在失败项，终止运行（退出码 1）")
        return 1
    }
    println("  计算断言全部通过")
    println("")

    // ---- 步骤 2: 创建窗口（WindowEngine v2）----
    println("[2/4] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    let wok = win.start(title: "three4cj", width: 1280, height: 720)
    if (!wok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
