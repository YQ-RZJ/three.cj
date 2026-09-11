package animationTest

/**
 * 骨骼动画测试项目入口
 *
 * 加载 glTF 模型，使用骨骼动画管线（SkeletonData → SamplingJob → BlendingJob → LocalToModelJob）
 * 驱动骨骼动画，验证管线端到端工作。
 *
 * 模块说明：
 * - renderer.cj: 场景创建、模型加载、骨骼动画管线集成
 */

import std.io.*
import std.time.*
import std.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.MouseButton
import three.window.MouseProvider
import three.core.math.*
import three.utils.log.Logger
import three.utils.log.LogLevel
import three.scene.scenegraph.*
import three.rendering.cameras.*

public class TestWindow <: WindowEngine {
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 5000.0)
    var modelGroup: Group = Group()
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 1.5708
    var orbitPhi: Float64 = 0.3
    var orbitDist: Float64 = 5.0
    // 相机注视点：模型包围盒中心（onInit 里计算，onFrame 里使用）
    var orbitTarget: Vector3 = Vector3(0.0, 0.0, 0.0)

    public override func onInit(): Unit {
        this._mouse = this.getProvider<MouseProvider>()

        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        println("[init] ThreeRenderer (${w}x${h})...")
        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            println("  ThreeRenderer.initBgfx failed!")
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        println("  ThreeRenderer ready")

        let (s, c, m) = createScene(w, h)
        this.scene = s
        this.camera = c
        this.modelGroup = m

        // 计算模型包围盒中心作为相机注视点；按包围球大小自适应初始距离
        m.updateMatrixWorld(true)
        let bbox = Box3().setFromObject(m)
        if (!bbox.isEmpty()) {
            this.orbitTarget = bbox.getCenter()
            let size = bbox.getSize()
            let radius = 0.5 * sqrt(size.x * size.x + size.y * size.y + size.z * size.z)
            if (radius > 0.0) {
                // fov=60°，让包围球恰好进入视锥的合适距离
                let fovRad = Float64(60.0) * 3.14159265358979 / 180.0
                this.orbitDist = clamp(radius / sin(fovRad / 2.0) * 1.1, 1.0, 200.0)
            }
            println("  model bbox center=[${this.orbitTarget.x},${this.orbitTarget.y},${this.orbitTarget.z}] dist=${this.orbitDist}")
        }

        this.startTime = MonoTime.now()
        println("[init] done, entering render loop")
    }

    public override func onFrame(dt: Float64): Unit {
        this.frame += 1

        // 驱动骨骼动画管线（mixer.update → 采样/混合 → Bone 回写 → 蒙皮）
        updateSkeletalAnimation(dt)

        // 鼠标左键拖动：手动调整公转角度
        let mouse = _mouse.getOrThrow()
        if (mouse.isMouseButtonDown(MouseButton.LEFT)) {
            let dx = Float64(mouse.getMouseDX())
            let dy = Float64(mouse.getMouseDY())
            this.orbitTheta -= dx * 0.005
            this.orbitPhi -= dy * 0.005
            this.orbitPhi = clamp(this.orbitPhi, -1.4, 1.4)
        }

        // 滚轮缩放
        if (mouse.getWheelY() != 0.0f32) {
            let zoomSpeed: Float64 = 0.05
            this.orbitDist *= (1.0 - Float64(mouse.getWheelY()) * zoomSpeed)
            this.orbitDist = clamp(this.orbitDist, 1.0, 2000.0)
        }

        // 自动缓慢旋转（可被鼠标拖动覆盖）
        // （已移除：用户要求相机绕模型旋转，模型保持静止）

        // 计算相机位置（球面坐标 → 笛卡尔坐标，绕注视点公转）
        let cosPhi = cos(this.orbitPhi)
        let camX = this.orbitTarget.x + this.orbitDist * cosPhi * sin(this.orbitTheta)
        let camY = this.orbitTarget.y + this.orbitDist * sin(this.orbitPhi)
        let camZ = this.orbitTarget.z + this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.position.set(camX, camY, camZ)
        this.camera.lookAt(this.orbitTarget)

        // 更新相机宽高比
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        this.renderer.render(this.scene, this.camera)

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = if (elapsed > 0.0) { Float64(this.frame) / elapsed } else { 0.0 }
            println("  [render] frame=${this.frame} time=${elapsed}s fps=${fps.toString()}")
        }
    }

    public override func onClose(): Unit {
        println("[close] frame=${this.frame}")
        this.renderer.shutdown()
    }
}

main(): Int64 {
    Logger.setLevel(LogLevel.Info)
    println("=== Skeletal Animation Test ===")

    let win = TestWindow()
    win.addInputProvider(MouseProvider())
    let wok = win.start(title: "Skeletal Animation Test", width: 1024, height: 768)
    if (!wok) {
        println("  WindowEngine.start failed!")
        return 1
    }
    println("  window created: ${win.getWidth()}x${win.getHeight()}")

    win.wait()
    println("=== Done ===")
    return 0
}
