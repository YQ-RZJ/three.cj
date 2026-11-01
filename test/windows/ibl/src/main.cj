package ibl

/**
 * ibl 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit 创建渲染器/场景/六色天空盒/PMREM 环境贴图/EffectComposer
 *   → onFrame 每帧轨道控制 + 渲染 → onClose 清理
 * - renderer.cj：buildSkyCube（程序化六色天空盒）+ createScene（PBR 金属球 + 地面 + IBL 环境）
 * - EffectComposer 链：RenderPass → CubeTexturePass（天空盒背景）→ OutputPass（上屏）
 *
 * 验证目标：IBL / PBR 材质工作流
 *   1) PMREMGenerator.fromScene 生成 CubeUV 预过滤环境贴图；
 *   2) scene.environment → 材质 u_envMap（USE_ENVMAP + ENVMAP_TYPE_CUBE_UV 变体）绑定；
 *   3) metalness/roughness 不同的金属球反射六色天空盒，粗糙度决定反射清晰度。
 *
 * 日志：统一使用 three.utils.log 的级别宏（@LogInfo/@LogDebug/@LogError）。
 * 档位由编译期环境变量 THREE_LOG_LEVEL 决定（off/error/warn/info/debug/trace，未设置按 off，
 * 此时日志调用点不生成任何代码）；改动档位后需先 cjpm clean 再重新构建。
 * 本用例启动/场景信息为 Info 级，逐帧 fps 统计为 Debug 级。
 */

import std.time.*
import std.collection.*
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
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.CubeTexturePass
import three.rendering.postprocessing.OutputPass
import three.rendering.textures.CubeTexture
import three.rendering.textures.Texture
import three.utils.log.*
import three.utils.log.macros.*

/// v2 窗口子类：覆写生命周期回调
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 45.0, aspect: 1.0, near: 0.1, far: 200.0)
    var spheres: ArrayList<Mesh> = ArrayList<Mesh>()
    var skyCube: Option<CubeTexture> = None
    var envMap: Option<Texture> = None
    var composer: Option<EffectComposer> = None
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.35
    var orbitDist: Float64 = 12.0

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/合成器） =====
    public override func onInit(): Unit {
        this._mouse = this.getProvider<MouseProvider>()

        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        @LogInfo(["ibl", "【2/5】初始化 ThreeRenderer（绑定窗口 ${hwnd}，${w}x${h}）..."])
        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            @LogError(["ibl", "ThreeRenderer.initBgfx 失败！"])
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x08, 0x08, 0x10))
        @LogInfo(["ibl", "ThreeRenderer 初始化成功"])

        @LogInfo(["ibl", "【3/5】创建 IBL/PBR 场景（六色天空盒 + PMREM 环境贴图 + 金属反射球）..."])
        let (scene, camera, spheres, skyCube, envMap) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.spheres = spheres
        this.skyCube = Some(skyCube)
        this.envMap = Some(envMap)

        @LogInfo(["ibl", "【4/5】进入渲染循环（RenderPass + CubeTexturePass via EffectComposer）..."])
        @LogInfo(["ibl", "鼠标左键拖动：旋转视角；滚轮：缩放"])

        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        composer.addPass(CubeTexturePass(this.camera, skyCube, opacity: 1.0))
        composer.addPass(OutputPass())
        composer.setSize(Int64(w), Int64(h))
        this.composer = Some(composer)
    }

    // ===== 生命周期：每循环（逻辑 + 渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // 鼠标轨道控制
        if (_mouse.getOrThrow().isMouseButtonDown(MouseButton.LEFT)) {
            this.orbitTheta -= Float64(_mouse.getOrThrow().getMouseDX()) * 0.005
            this.orbitPhi -= Float64(_mouse.getOrThrow().getMouseDY()) * 0.005
            this.orbitPhi = clamp(this.orbitPhi, -1.4, 1.4)
        }
        if (_mouse.getOrThrow().getWheelY() != 0.0f32) {
            this.orbitDist *= (1.0 - Float64(_mouse.getOrThrow().getWheelY()) * 0.05)
            this.orbitDist = clamp(this.orbitDist, 4.0, 40.0)
        }

        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = 2.0 + this.orbitDist * sin(this.orbitPhi)
        this.camera.position.z = this.orbitDist * cosPhi * cos(this.orbitTheta)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))

        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        match (this.composer) {
            case Some(composer) => composer.render()
            case None => ()
        }

        if (this.frame % 60 == 1) {
            let elapsed = Float64((MonoTime.now() - this.startTime).toMilliseconds()) / 1000.0
            let fps = Float64(this.frame) / elapsed
            @LogDebug(["ibl", "【render】frame=${this.frame} fps=${fps.toString()}"])
        }
    }

    // ===== 生命周期：关闭前（清理合成器/渲染器） =====
    public override func onClose(): Unit {
        @LogInfo(["ibl", "【5/5】清理资源..."])
        match (this.composer) {
            case Some(composer) => composer.dispose()
            case None => ()
        }
        this.renderer.shutdown()
        @LogInfo(["ibl", "ThreeRenderer 已关闭"])
        @LogInfo(["ibl", "=== 测试完成 ==="])
    }
}

main(): Int64 {
    @LogInfo(["ibl", "=== IBL/PBR 环境贴图工作流（PMREM CubeUV + 六色天空盒 + 金属反射球）==="])

    @LogInfo(["ibl", "【1/5】创建窗口（WindowEngine v2）..."])
    let win = TestWindow()
    win.addInputProvider(MouseProvider())
    let wok = win.start(title: "three4cj - IBL/PBR", width: 1280, height: 720)
    if (!wok) {
        @LogError(["ibl", "WindowEngine.start 失败！"])
        return 1
    }
    win.setResizable(false)
    @LogInfo(["ibl", "窗口创建成功: ${win.getWidth()}x${win.getHeight()}"])

    win.wait()
    return 0
}
