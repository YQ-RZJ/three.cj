package cubetexture

/**
 * cubetexture 测试入口（v2 生命周期模式）：
 * - TestWindow <: WindowEngine：onInit（创建渲染器/场景/CubeTexture/EffectComposer）→
 *   onFrame（每帧轨道控制 + 渲染）→ onClose（清理）
 * - renderer.cj: 场景设置（盒子 + 多色球 + 环境光 + 方向光）与 createScene
 * - EffectComposer 链：RenderPass → CubeTexturePass（立方体贴图背景）→ 上屏
 *   验证 CubeTexturePass 把 CubeTexture 当作天空盒/背景渲染的效果。
 */

import std.io.*
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
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.lights.*
import three.rendering.postprocessing.EffectComposer
import three.rendering.postprocessing.RenderPass
import three.rendering.postprocessing.CubeTexturePass
import three.rendering.postprocessing.OutputPass
import three.rendering.textures.CubeTexture
import three.utils.log.Logger
import three.utils.log.LogLevel

/**
 * v2 窗口子类：覆写生命周期回调。
 * onInit 创建渲染器/场景/合成器（窗口泵线程，可读 getNativeWindowHandle/getWidth/getHeight），
 * 每帧逻辑与渲染在 onFrame 执行（读固定快照），清理在 onClose。
 */
public class TestWindow <: WindowEngine {
    // ===== 渲染状态（onInit 创建 / onFrame 使用 / onClose 清理） =====
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 50.0, aspect: 1.0, near: 0.1, far: 100.0)
    var spheres: ArrayList<Mesh> = ArrayList<Mesh>()
    var composer: Option<EffectComposer> = None
    var frame: Int64 = 0
    var startTime: MonoTime = MonoTime.now()
    var orbitTheta: Float64 = 0.0
    var orbitPhi: Float64 = 0.2
    var orbitDist: Float64 = 12.0

    // ===== 生命周期：窗口创建后（初始化渲染器/场景/合成器） =====
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
        this.renderer.setClearColor(Color(0x10, 0x10, 0x18))  // 深灰背景
        println("  ThreeRenderer 初始化成功")
        println("  渲染器尺寸: ${w}x${h}")
        println("")

        println("[3/5] 创建场景对象...")
        let (scene, camera, spheres) = createScene(w, h)
        this.scene = scene
        this.camera = camera
        this.spheres = spheres

        // ---- 步骤 4: 进入渲染循环（RenderPass → CubeTexturePass → 上屏） ----
        println("[4/5] 进入渲染循环（RenderPass + CubeTexturePass via EffectComposer）...")
        println("  鼠标左键拖动：调整公转角度；滚轮：缩放；按窗口关闭按钮退出\n")

        // 对齐 Three.js EffectComposer 用法：
        //   composer.addPass(new RenderPass(scene, camera))                       // 场景渲到 readBuffer
        //   composer.addPass(new CubeTexturePass(camera, cubeTex, 1))            // 立方体贴图背景
        //   最后一个 enabled pass 自动 renderToScreen=true 上屏
        // CubeTexturePass：立方体贴图背景（天空盒），opacity=1.0
        // 程序化生成 6 面渐变 RGBA 数据构造 CubeTexture（64x64/面），
        // CubeTexturePass 经 bgfx_create_texture_cube_cj 上传为真 cube 纹理并渲染背景。
        let cubeSide: Int64 = 64
        let faceBytes: Int64 = cubeSide * cubeSide * 4
        let faceColors: Array<(UInt8, UInt8, UInt8)> = [
            (0xffu8, 0x40u8, 0x40u8),  // +X 红
            (0x40u8, 0xffu8, 0x40u8),  // -X 绿
            (0x40u8, 0x40u8, 0xffu8),  // +Y 蓝
            (0xffu8, 0xffu8, 0x40u8),  // -Y 黄
            (0xffu8, 0x40u8, 0xffu8),  // +Z 品红
            (0x40u8, 0xffu8, 0xffu8),  // -Z 青
        ]
        let cubeImages = Array<Array<UInt8>>(6, { f => Array<UInt8>(faceBytes, { i => 0u8 }) })
        for (f in 0..6) {
            let face = cubeImages[f]
            let (cr, cg, cb) = faceColors[f]
            // 渐变：从左上到右下混合底色与白色（可见梯度纹理）
            for (y in 0..cubeSide) {
                for (x in 0..cubeSide) {
                    let idx = (y * cubeSide + x) * 4
                    let t = Float64(x + y) / Float64(cubeSide * 2)
                    face[idx] = UInt8(Float64(cr) * (1.0 - t) + 255.0 * t)
                    face[idx + 1] = UInt8(Float64(cg) * (1.0 - t) + 255.0 * t)
                    face[idx + 2] = UInt8(Float64(cb) * (1.0 - t) + 255.0 * t)
                    face[idx + 3] = 0xffu8
                }
            }
        }
        let cubeTex = CubeTexture(images: cubeImages)
        let composer = EffectComposer(this.renderer)
        composer.addPass(RenderPass(this.scene, this.camera))
        composer.addPass(CubeTexturePass(this.camera, cubeTex, opacity: 1.0))
        // OutputPass：链尾上屏（把 readBuffer 场景输出到屏幕）。
        // 说明：CubeTexturePass 是"背景覆盖"pass；空 cubeTex 时无内容可渲，
        // 若链尾缺上屏 pass，屏幕将无内容（全白），故加 OutputPass 显示场景。
        composer.addPass(OutputPass())
        composer.setSize(Int64(w), Int64(h))
        this.composer = Some(composer)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
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
            this.orbitDist = clamp(this.orbitDist, 3.0, 40.0)
        }

        let cosPhi = cos(this.orbitPhi)
        this.camera.position.x = this.orbitDist * cosPhi * sin(this.orbitTheta)
        this.camera.position.y = this.orbitDist * sin(this.orbitPhi)
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
            println("  [render] frame=${this.frame} fps=${fps.toString()}")
        }
    }

    // ===== 生命周期：关闭前（清理合成器/渲染器） =====
    public override func onClose(): Unit {
        println("")
        println("[5/5] 清理资源...")
        match (this.composer) {
            case Some(composer) => composer.dispose()
            case None => ()
        }
        this.renderer.shutdown()
        println("  ThreeRenderer 已关闭")
        println("=== 测试完成 ===")
    }
}

main(): Int64 {
    Logger.setLevel(LogLevel.Debug)
    println("=== cubetexture：CubeTexturePass 立方体贴图背景 ===")
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
