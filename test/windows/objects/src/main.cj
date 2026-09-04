package sp_objects

/**
 * sp_objects 入口：
 * objects 包功能对齐验证测试（v2 生命周期模式）。
 * 场景：多种对象类型（Mesh 球、Points 点云、Line 线段、LineSegments 线框、
 *       Sprite 广告牌、LOD 距离层级、Group 分组）+ 相机轨道控制；
 * 每帧验证 intersectsFrustum 视锥剔除（Mesh/Points/Line/Sprite 补齐接口）
 * 与 LOD.getCurrentLevel/removeLevel 层级切换，打印 debug 日志。
 * 窗口通过继承 WindowEngine 覆写生命周期回调（onInit/onFrame/onClose）。
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
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
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
    var objs: SceneObjects = SceneObjects(
        scene: Scene(),
        camera: PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0),
        mesh: Mesh(),
        points: Points(),
        line: Line(),
        lineSegments: LineSegments(),
        sprite: Sprite(),
        lod: LOD())
    var frame: Int64 = 0
    var totalFrames: Int64 = 0
    var startTime: MonoTime = MonoTime.now()

    // 轨道控制状态
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.4
    var orbitDist: Float64 = 18.0
    let targetCenter = Vector3(0.0, 0.0, 0.0)

    // 视锥（每帧从相机矩阵重建）
    let frustum = Frustum()

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
        this.renderer.setClearColor(Color(0x20, 0x20, 0x30))  // 深蓝灰背景
        // 开启 bgfx 调试文本（DEBUG_TEXT = 0x08）——画面内文本（同 geometries/sp_materials）
        this.renderer.setDebug(0x00000008)
        println("  BgfxRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        this.objs = createScene(w, h)

        println("[4/5] 进入渲染循环（视锥剔除 + LOD 层级验证，onFrame 由窗口泵线程驱动）...")
        println("  鼠标左键拖动：调整视角；滚轮：缩放；按窗口关闭按钮退出\n")
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.totalFrames++
        this.frame++
        let t = Float64(this.frame) * 0.016

        // ---- 对象自转 ----
        this.objs.mesh.rotation.y = t * 0.5
        this.objs.points.rotation.y = t * 0.3

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
            this.orbitDist = clamp(this.orbitDist, 4.0, 45.0)
        }

        // ---- 相机位置 ----
        let cosPhi = cos(this.orbitPhi)
        this.objs.camera.position.x = this.targetCenter.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.objs.camera.position.y = this.targetCenter.y + this.orbitDist * sin(this.orbitPhi)
        this.objs.camera.position.z = this.targetCenter.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.objs.camera.lookAt(this.targetCenter)

        let w = this.getWidth()
        let h = this.getHeight()
        this.objs.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.objs.camera.updateProjectionMatrix()

        // ---- 场景矩阵更新（视锥剔除依赖 matrixWorld） ----
        this.objs.scene.updateMatrixWorld(true)

        // ---- 视锥剔除验证：对照 JS frustum.setFromProjectionMatrix(proj * matrixWorldInverse) ----
        // 仓颉 Frustum.setFromProjectionMatrix 接受相机投影矩阵与视图逆矩阵的乘积
        let projView = Matrix4()
        projView.multiplyMatrices(this.objs.camera.projectionMatrix, this.objs.camera.matrixWorldInverse)
        this.frustum.setFromProjectionMatrix(projView)

        // intersectsFrustum（本轮补齐接口：Mesh/Points/Line/Sprite 一行委托）
        let meshIn = this.objs.mesh.intersectsFrustum(this.frustum)
        let ptsIn = this.objs.points.intersectsFrustum(this.frustum)
        let lineIn = this.objs.line.intersectsFrustum(this.frustum)
        let spriteIn = this.objs.sprite.intersectsFrustum(this.frustum)

        // ---- LOD 层级验证 ----
        this.objs.lod.update(this.objs.camera)
        let lodLevel = this.objs.lod.getCurrentLevel()   // 本轮补齐：getCurrentLevel
        var lodInFrustum = this.frustum.intersectsObject(this.objs.lod)  // Object3D 基类 IFrustumCullable 接口
        if (this.frame == 180) {
            // removeLevel 验证：移除距离阈值 3 的层级（对照 JS removeLevel(distance)）
            let removed = this.objs.lod.removeLevel(3.0)
            println("  [LOD] frame=${this.frame} removeLevel(3.0) -> ${removed}")
            // 重新 addLevel 恢复（避免后续无层级可切换）
            let rGeom = SphereGeometry(radius: 1.2, widthSegments: 12, heightSegments: 8)
            rGeom.computeBoundingSphere()
            let rMat = MeshBasicMaterial()
            rMat.color = Color(0xff4040)
            let rMesh = Mesh(geometry: rGeom, material: rMat)
            rMesh.name = "LODLevel0"
            this.objs.lod.addLevel(rMesh, distance: 3.0)
        }

        // ---- debug 打印（每 60 帧） ----
        if (this.frame % 60 == 1) {
            println("frustum: mesh=${meshIn} points=${ptsIn} line=${lineIn} sprite=${spriteIn} lod=${lodInFrustum} lodLevel=${lodLevel}")
        }

        // ---- 画面内文本（bgfx dbgText，同 geometries/sp_materials） ----
        this.renderer.dbgTextClear(0x00, false)
        this.renderer.dbgTextPrintf(0, 0, 0x0f, "frustum: mesh=" + meshIn.toString() + " pts=" + ptsIn.toString() + " line=" + lineIn.toString() + " sprite=" + spriteIn.toString())
        this.renderer.dbgTextPrintf(0, 1, 0x0e, "LOD level=" + lodLevel.toString() + " inFrustum=" + lodInFrustum.toString())

        this.renderer.render(this.objs.scene, this.objs.camera)

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
        println("  BgfxRenderer 已关闭")
        println("")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    // 临时开启 Debug 日志，确认 LOD 子球是否被收集渲染
    Logger.setLevel(LogLevel.Debug)
    println("=== sp_objects：对象功能验证（视锥剔除 + LOD + 多对象渲染） ===")
    println("")

    // ---- 步骤 1: 创建窗口（WindowEngine v2，SDL3 跨平台实现） ----
    println("[1/5] 创建窗口（WindowEngine v2）...")
    let win = TestWindow()
    win.addInputProvider(MouseProvider())
    let wok = win.start(title: "three4cj", width: 1280, height: 720)
    if (!wok) { println("  WindowEngine.start 失败!"); return 1 }
    win.setResizable(false)
    println("  窗口创建成功: ${win.getWidth()}x${win.getHeight()}, 原生句柄=${win.getNativeWindowHandle()}")
    println("")

    // ---- 步骤 4(续): 等待窗口关闭（窗口泵线程驱动 onInit/onFrame/onClose） ----
    win.wait()
    return 0
}
