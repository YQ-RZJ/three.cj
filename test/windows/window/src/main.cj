/**
 * @file main
 * @brief test_window：WindowEngine v2 + InputEngine + BgfxRenderer 集成测试
 *
 * 验证（v2 生命周期模式——对齐 RGF 窗口模式）：
 *  - WindowEngine v2 跨平台窗口创建（SDL3，全局事件分发器 + 每窗口独立泵）
 *  - 继承 WindowEngine 覆写生命周期回调：onInit（创建渲染器/场景）→
 *    onFrame（读固定快照：键盘/鼠标/滚轮 + 渲染）→ onClose（清理）
 *  - InputEngine 键盘/鼠标状态查询（WASD 移动、鼠标旋转、点击换色、滚轮缩放）
 *  - 按 ESC 或关闭窗口退出（requestClose / closeRequested）
 */
package test_window

import std.io.*
import std.time.*
import three.window.WindowEngine
import three.window.InputEngine
import three.window.KeyboardProvider
import three.window.MouseProvider
import three.window.KeyCode
import three.window.MouseButton
import three.rendering.BgfxRenderer
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.lights.*

/**
 * v2 窗口子类：覆写生命周期回调。
 * 渲染器/场景在 onInit 创建（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    var renderer: BgfxRenderer = BgfxRenderer()
    var input: InputEngine = InputEngine()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var material: MeshPhongMaterial = MeshPhongMaterial()
    var mesh: Mesh
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var camDistance: Float64 = 5.0
    var cubeColorIndex: Int64 = 0
    let colors = [Color(0xff, 0x60, 0x20), Color(0x20, 0xc0, 0x60),
                  Color(0x40, 0x80, 0xff), Color(0xff, 0xd0, 0x20)]

    /// 构造：创建立方体网格 + 注册输入提供者
    public init() {
        let geometry = BoxGeometry(width: 1.5, height: 1.5, depth: 1.5)
        this.material.color = Color(0xff, 0x60, 0x20)
        this.mesh = Mesh(geometry: geometry, material: this.material)
        // 注册输入提供者（可插拔架构）
        this.addInputProvider(KeyboardProvider())
        this.addInputProvider(MouseProvider())
    }

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[2/6] 初始化 BgfxRenderer（绑定窗口 ${hwnd}, ${w}x${h}）...")
        let rok = this.renderer.initBgfx(hwnd, w, h)
        if (!rok) {
            println("  BgfxRenderer.initBgfx 失败!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x30, 0x30, 0x60))
        println("  BgfxRenderer 初始化成功")
        println("")

        println("[3/6] 创建场景...")
        this.camera.position.set(0.0, 2.0, 5.0)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        this.scene.add(this.mesh)
        let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.4)
        this.scene.add(ambient)
        let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.0)
        dirLight.position.set(3.0, 5.0, 4.0)
        this.scene.add(dirLight)
        println("  场景创建成功: 立方体 + 环境光 + 平行光")
        println("")

        println("[4/6] 创建输入引擎并绑定窗口...")
        this.input.bindWindow(this)
        println("  输入引擎已绑定窗口")
        println("  操作提示: WASD/方向键移动 | 鼠标移动旋转 | 左键/空格换色 | 滚轮缩放 | ESC 退出")
        println("")
        println("[5/6] 进入渲染循环（onFrame 由窗口泵线程驱动）...")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        this.startTime = MonoTime.now()

        // ESC 退出
        if (this.input.isKeyDown(KeyCode.ESCAPE)) {
            this.requestClose()
            return
        }

        // WASD / 方向键移动立方体
        let speed = 0.06
        if (this.input.isKeyDown(KeyCode.W) || this.input.isKeyDown(KeyCode.UP)) {
            this.mesh.position.z -= speed
        }
        if (this.input.isKeyDown(KeyCode.S) || this.input.isKeyDown(KeyCode.DOWN)) {
            this.mesh.position.z += speed
        }
        if (this.input.isKeyDown(KeyCode.A) || this.input.isKeyDown(KeyCode.LEFT)) {
            this.mesh.position.x -= speed
        }
        if (this.input.isKeyDown(KeyCode.D) || this.input.isKeyDown(KeyCode.RIGHT)) {
            this.mesh.position.x += speed
        }

        // 鼠标拖动旋转立方体（按住左键拖动才生效）
        if (this.input.isMouseButtonDown(MouseButton.LEFT)) {
            this.mesh.rotation.y += Float64(this.input.getMouseDX()) * 0.01
            this.mesh.rotation.x += Float64(this.input.getMouseDY()) * 0.01
        }

        // 空格换色（边沿触发，本循环快照固定）
        if (this.input.isKeyPressed(KeyCode.SPACE)) {
            this.cubeColorIndex = (this.cubeColorIndex + 1) % 4
            this.material.color = this.colors[this.cubeColorIndex]
        }

        // 滚轮缩放相机距离
        this.camDistance -= Float64(this.input.getWheelY()) * 0.5
        if (this.camDistance < 2.0) { this.camDistance = 2.0 }
        if (this.camDistance > 20.0) { this.camDistance = 20.0 }
        this.camera.position.set(0.0, 2.0, this.camDistance)
        this.camera.lookAt(Vector3(this.mesh.position.x, this.mesh.position.y, this.mesh.position.z))

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 渲染
        this.renderer.render(this.scene, this.camera)

        // 每 60 帧打印一次统计
        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            println("  [frame=${this.frame}] fps=${fps.toString()} 立方体=(${this.mesh.position.x.toString()}, ${this.mesh.position.z.toString()}) 相机距离=${this.camDistance.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("[6/6] 清理资源...")
        let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
        println("  运行时间: ${elapsed}s, 总帧数: ${this.frame}")
        this.renderer.shutdown()
        println("  渲染引擎已关闭")
    }
}

main(): Int64 {
    println("=== test_window：窗口引擎 v2 + 输入引擎 + 渲染引擎 集成测试 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，全局分发器 + 每窗口独立泵） ----
    println("[1/6] 创建窗口（SDL3 / WindowEngine v2）...")
    let win = TestWindow()
    let ok = win.start(title: "test_window - 窗口/输入引擎", width: 960, height: 600)
    if (!ok) {
        println("  WindowEngine.start 失败!")
        return 1
    }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 步骤 5(续): 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    println("")
    println("=== test_window 完成 ===")
    return 0
}
