package geometries

/**
 * test_geometries 渲染测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景）→
 *   onFrame（每帧公转 + 相机旋转 + raycast 命中检测）→ onClose（清理）
 * - renderer.cj: 场景（所有 geometries 围一圈）+ 公转动画 + 相机自转 + createScene
 */

import std.io.*
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
import three.utils.log.*
import three.utils.log.macros.*
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

    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 200.0)
    var objects: ArrayList<Object3D> = ArrayList<Object3D>()
    var raycaster: Raycaster = Raycaster()
    // intersectObjects 需要 Array<Object3D>（objects 是 ArrayList<Object3D>——转换一次，对象引用不变）
    var rayObjects: Array<Object3D> = Array<Object3D>(0, { _ => Object3D() })
    var frame: Int64 = 0

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
        this._mouse = this.getProvider<MouseProvider>()


        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[2/4] 初始化 BgfxRenderer（绑定窗口 ${hwnd}, ${w}x${h}）...")
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
        // 开启 bgfx 调试文本（DEBUG_TEXT = 0x08）——dbgTextPrintf 画面内文本渲染的前提
        this.renderer.setDebug(0x00000008)
        println("  渲染器初始化成功: ${w}x${h}")
        println("")

        // ---- 步骤 3: 创建场景（所有 geometries 围一圈） ----
        println("[3/4] 创建场景...")
        let (scene, camera, objects) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.objects = objects
        this.rayObjects = Array<Object3D>(this.objects.size, { i => this.objects[i] })

        // ---- 步骤 4: 进入渲染循环（公转 + 相机自转） ----
        println("进入渲染循环（几何体公转 + 自传 + 相机鼠标旋转）...")
        println("鼠标左键拖动旋转相机；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++
        let t = Float64(this.frame) * 0.016

        // ---- 几何体公转（速度降一半）+ 每个几何体自传 ----
        let speed = 0.25
        for (i in 0..this.objects.size) {
            geomAngles[i] = PI * 2.0 * Float64(i) / Float64(GEOM_COUNT) + t * speed
            let obj = this.objects[i]
            obj.position.set(ORBIT_RADIUS * sin(geomAngles[i]), 0.0, ORBIT_RADIUS * cos(geomAngles[i]))
            // 每个几何体自传（绕自身 Y 轴）
            obj.rotateY(0.6 * 0.016)
            obj.rotateX(0.6 * 0.016)
        }

        // ---- 相机鼠标控制旋转（左键拖动——自转朝向，非绕他物） ----
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            let dx = Float64(_mouse.getOrThrow().getMouseDX())
            let dy = Float64(_mouse.getOrThrow().getMouseDY())
            orbitTheta -= dx * 0.005
            orbitPhi -= dy * 0.005
            orbitPhi = clamp(orbitPhi, -1.4, 1.4)
        }
        // 与 JS 一致：rotation(Euler) 与 quaternion 共通（Object3D 双向 onChange 同步）——直接设 rotation 即可驱动相机旋转
        this.camera.rotation.set(orbitPhi, orbitTheta, 0.0)

        // ---- 相机命中模型检测（显示名字——bgfx 画面内文本） ----
        // 相机 rotation 每帧变化（鼠标）——先更新矩阵确保 getWorldDirection 反映最新朝向
        this.camera.updateMatrixWorld(true)
        let camDir = this.camera.getWorldDirection(Vector3())
        this.raycaster.set(this.camera.position, camDir)
        let hits = this.raycaster.intersectObjects(this.rayObjects)
        // 调试日志（定位 raycast 无命中）：每 30 帧打印 orbit/射线/命中信息
        if (this.frame % 30 == 0) {
            println("raycast: theta=${orbitTheta} phi=${orbitPhi} origin=(${this.camera.position.x}, ${this.camera.position.y}, ${this.camera.position.z}) dir=(${camDir.x}, ${camDir.y}, ${camDir.z}) objects=${this.rayObjects.size} hits=${hits.size}")
        }
        var hitName = ""
        if (hits.size > 0) {
            match (hits[0].obj) {
                case Some(obj: Object3D) => hitName = obj.name
                case _ => ()
            }
        }
        // 每帧清屏调试文本并显示当前命中模型名（bgfx dbg_text_printf 画面内文本）
        this.renderer.dbgTextClear(0x00, false)
        this.renderer.dbgTextPrintf(0, 0, 0x0f, "=> " + hitName)

        // ---- 渲染 ----
        this.renderer.render(this.scene, this.camera)
    }

    // ===== 生命周期：关闭前（清理渲染器） =====
    public override func onClose(): Unit {
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
    }
}

main(): Int64 {
    println("=== test_geometries：所有几何体围一圈公转 + 相机自转 ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2） ----
    println("[1/4] 创建窗口（WindowEngine v2）...")
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
