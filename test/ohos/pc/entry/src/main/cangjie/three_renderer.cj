package ohos_app_cangjie_entry

/**
 * 仓颉侧 three 渲染引擎与 ArkTS 侧 XComponent 的桥接（纯仓颉实现，无 C++）。
 *
 * 职责：
 *  - 通过 three.cj 的 WindowEngine 获取 native window 句柄/尺寸后，初始化
 *    three 引擎的 BgfxRenderer（bgfx + OpenGLES），创建参考 windows/base 的
 *    彩色立方体场景，并在独立线程中驱动渲染循环（每帧 render() 内部
 *    finishRender 已触发 bgfx_frame_cj 提交帧，与 windows/base 一致）。
 *
 * OHOS 说明（nm 注册模式 + XComponent 直连建窗）：
 *  - ArkTS 侧 XComponent 设 libraryname='SDL3'，mmg 加载 libSDL3.so 时 SDL 的
 *    OHOS_XcomponentExport 会把该 XComponent 注册进 SDL 注册表并挂接触摸/键鼠回调；
 *  - SDL 建窗（无 NodeController 适配层时）直接从注册表取该 XComponent 的
 *    native window 建窗，native window 经 SDL_PROP_WINDOW_OHOS_WINDOW_POINTER
 *    交给本文件 onInit 里的 ThreeRenderer.initBgfx 绑定渲染；
 *  - 输入事件按 xcompentId 路由进该 SDL 窗口，经 InputEngine 查询。
 *  base 工程保持纯仓颉，无需 C++ 工程；Three.cj 对外接口保持跨平台。
 */

import std.sync.*
import std.time.*
import std.runtime.*
import std.math.*
import ohos.app.ability.ui_ability.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.WindowConfig
import three.window.MouseProvider
import three.window.MouseButton
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.scene.entity.*
import three.rendering.cameras.*
import three.rendering.geometry.*
import three.rendering.buffer.*
import three.rendering.materials.*
import std.convert.RadixConvertible

// ===== 全局状态 =====
// WindowEngine 实例：startThreeRender 中创建并绑定 XComponent，
// resizeThreeRender 中通过 updateSize 保持窗口尺寸同步（跨平台接口）。

var g_windowEngine: Option<WindowEngine> = None

var g_renderRunning = AtomicBool(false)
var g_renderFrame: Int64 = 0
// ArkTS onAreaChange 事件驱动的待应用尺寸（0 = 无更新）。写入后渲染线程每帧
// 读原子并应用，curW/curH 更新后自然不再触发，无需清零，无竞争。
var g_resizeW = AtomicInt32(0)
var g_resizeH = AtomicInt32(0)

// ===== 着色器源码（与 windows/base 参考画面一致） =====

let CUBE_VS: String = """
$input a_position, a_normal, a_color0
$output v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);

    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_color   = a_color0;
    v_worldPos = worldPos.xyz;
}
"""

let CUBE_FS: String = """
$input v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(1.0, 1.0, -0.5));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.3;

    float rim = 1.0 - max(dot(normal, vec3(0.0, 0.0, 1.0)), 0.0);
    rim = pow(rim, 3.0) * 0.4;

    vec3 litColor = v_color.xyz * (ambient + diff * 0.7) + vec3_splat(rim);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ===== 几何体辅助：带逐面顶点颜色的立方体（与 windows/base 一致） =====

func createColoredBoxGeometry(width: Float64, height: Float64, depth: Float64): BufferGeometry {
    let w2 = width / 2.0
    let h2 = height / 2.0
    let d2 = depth / 2.0

    let posData = [
        -w2, -h2,  d2,   w2, -h2,  d2,   w2,  h2,  d2,  -w2,  h2,  d2,
         w2, -h2, -d2,  -w2, -h2, -d2,  -w2,  h2, -d2,   w2,  h2, -d2,
        -w2,  h2,  d2,   w2,  h2,  d2,   w2,  h2, -d2,  -w2,  h2, -d2,
        -w2, -h2, -d2,   w2, -h2, -d2,   w2, -h2,  d2,  -w2, -h2,  d2,
         w2, -h2,  d2,   w2, -h2, -d2,   w2,  h2, -d2,   w2,  h2,  d2,
        -w2, -h2, -d2,  -w2, -h2,  d2,  -w2,  h2,  d2,  -w2,  h2, -d2,
    ]
    let normData = [
        0.0, 0.0, 1.0,  0.0, 0.0, 1.0,  0.0, 0.0, 1.0,  0.0, 0.0, 1.0,
        0.0, 0.0,-1.0,  0.0, 0.0,-1.0,  0.0, 0.0,-1.0,  0.0, 0.0,-1.0,
        0.0, 1.0, 0.0,  0.0, 1.0, 0.0,  0.0, 1.0, 0.0,  0.0, 1.0, 0.0,
        0.0,-1.0, 0.0,  0.0,-1.0, 0.0,  0.0,-1.0, 0.0,  0.0,-1.0, 0.0,
        1.0, 0.0, 0.0,  1.0, 0.0, 0.0,  1.0, 0.0, 0.0,  1.0, 0.0, 0.0,
       -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0,
    ]
    let colData = [
        1.0, 0.2, 0.2,   1.0, 0.2, 0.2,   1.0, 0.2, 0.2,   1.0, 0.2, 0.2,
        0.2, 1.0, 1.0,   0.2, 1.0, 1.0,   0.2, 1.0, 1.0,   0.2, 1.0, 1.0,
        0.2, 1.0, 0.2,   0.2, 1.0, 0.2,   0.2, 1.0, 0.2,   0.2, 1.0, 0.2,
        1.0, 1.0, 0.2,   1.0, 1.0, 0.2,   1.0, 1.0, 0.2,   1.0, 1.0, 0.2,
        1.0, 0.2, 1.0,   1.0, 0.2, 1.0,   1.0, 0.2, 1.0,   1.0, 0.2, 1.0,
        0.2, 0.2, 1.0,   0.2, 0.2, 1.0,   0.2, 0.2, 1.0,   0.2, 0.2, 1.0,
    ]
    let idxData = [
        0, 1, 2,  0, 2, 3,
        4, 5, 6,  4, 6, 7,
        8, 9, 10, 8, 10, 11,
        12, 13, 14, 12, 14, 15,
        16, 17, 18, 16, 18, 19,
        20, 21, 22, 20, 22, 23,
    ]

    let positions = Array<Float64>(posData.size, { i => posData[i] })
    let normals = Array<Float64>(normData.size, { i => normData[i] })
    let colors = Array<Float64>(colData.size, { i => colData[i] })
    let indices = Array<Float64>(idxData.size, { i => Float64(idxData[i]) })

    let geom = BufferGeometry()
    geom.setIndex(BufferAttribute(indices, 1))
    geom.setAttribute("position", BufferAttribute(positions, 3))
    geom.setAttribute("normal", BufferAttribute(normals, 3))
    geom.setAttribute("color", BufferAttribute(colors, 3))
    return geom
}

// ===== OHOS 渲染窗口：复用跨平台 WindowEngine 生命周期（参考 windows/base） =====
// onInit 用 SDL 窗口的 native window 句柄初始化 BgfxRenderer（OpenGLES），
// onFrame 驱动每帧渲染，onClose 关闭渲染器。

public class ThreeWindow <: WindowEngine {
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var material: ShaderMaterial = ShaderMaterial()
    var mesh: Mesh
    var frame: Int64 = 0
    var appliedW: Int32 = 0
    var appliedH: Int32 = 0
    // 输入提供者（可插拔架构）
    var _mouse: Option<MouseProvider> = None

    /// 构造：创建立方体网格（不依赖窗口，可在字段初始化阶段完成）
    public init() {
        // 恢复迁移前的逐面彩色立方体：createColoredBoxGeometry + 自定义光照 shader（CUBE_VS/CUBE_FS）
        let geometry = createColoredBoxGeometry(1.5, 1.5, 1.5)
        this.material = ShaderMaterial(CUBE_VS, CUBE_FS)
        this.mesh = Mesh(geometry: geometry, material: this.material)
    }

    // ===== 生命周期：窗口创建后（初始化渲染器/场景） =====
    public override func onInit(): Unit {
        this._mouse = this.getProvider<MouseProvider>()
        let hwnd = this.getNativeWindowHandle()
        // OHOS 窗口真实尺寸由 ArkTS XComponent 控制（onAreaChange 写入 g_resizeW/H）；
        // start() 时传的是占位尺寸，优先使用 ArkTS 已同步的真实尺寸。
        let rw = g_resizeW.load()
        let rh = g_resizeH.load()
        let w = if (rw > 0i32) { rw } else { this.getWidth() }
        let h = if (rh > 0i32) { rh } else { this.getHeight() }
        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let rok = this.renderer.initBgfx(hwnd, w, h)
        if (!rok) {
            this.requestClose()
            return
        }
        this.appliedW = w
        this.appliedH = h
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x30, 0x30, 0x60))

        // 相机固定（对齐 windows/base）：位置固定，朝向原点；拖动只旋转模型本身
        this.camera.position.set(0.0, 2.0, 5.0)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))

        // 模型位于原点，相机朝向固定
        this.scene.add(this.mesh)
    }

    // ===== 生命周期：每循环（读固定快照——逻辑+渲染） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // 鼠标/触摸拖动：旋转模型自身（相机固定，对齐 windows/base 的固定相机）。
        // OHOS 触摸已由 SDL C++ 层归一化并合成为标准鼠标事件（SDL_HINT_TOUCH_MOUSE_EVENTS 默认开启），
        // 因此上层直接走与其它平台一致的鼠标 API 即可。
        match (this._mouse) {
            case Some(m) =>
                if (m.isMouseButtonDown(MouseButton.LEFT)) {
                    let dx = Float64(m.getMouseDX())
                    let dy = Float64(m.getMouseDY())
                    // 水平拖动绕 Y 轴旋转，垂直拖动绕 X 轴旋转（手感：往右拖→模型右转）
                    this.mesh.rotation.y -= dx * 0.01
                    this.mesh.rotation.x -= dy * 0.01
                }
                // 滚轮缩放（模型缩放；相机固定不移动。OHOS 触摸无滚轮）
                if (m.getWheelY() != 0.0f32) {
                    let zoomSpeed: Float64 = 0.05
                    let factor = 1.0 + Float64(m.getWheelY()) * zoomSpeed / 120.0
                    this.mesh.scale.x *= factor
                    this.mesh.scale.y *= factor
                    this.mesh.scale.z *= factor
                }
            case None => ()
        }

        // 应用 ArkTS onAreaChange 尺寸（XComponent 尺寸由 ArkTS 控制）
        let rw = g_resizeW.load()
        let rh = g_resizeH.load()
        if (rw > 0i32 && rh > 0i32 && (rw != this.appliedW || rh != this.appliedH)) {
            this.appliedW = rw
            this.appliedH = rh
            // 真实逻辑尺寸变化后重取窗口像素比（getPixelRatio 内部会用新的
            // _width/_height 重算缓存；updateSize 不在主线程重算以免阻塞），
            // 再应用到渲染器，避免沿用 onInit 占位尺寸算出的异常 pixelRatio。
            this.renderer.setPixelRatio(Float64(this.getPixelRatio()))
            this.renderer.setSize(rw, rh)
        }
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        this.renderer.render(this.scene, this.camera)
    }

    // ===== 生命周期：关闭前（清理渲染器） =====
    public override func onClose(): Unit {
        this.renderer.shutdown()
    }
}

// ===== 启动 three 渲染（WindowEngine + 独立泵线程驱动） =====
// context：ArkTS 传入的 UIAbilityContext（base 无音频，仅保留统一接口，未使用）

public func startThreeRender(context: Option<UIAbilityContext>): Bool {
    if (g_renderRunning.load()) {
        return true
    }
    let win = ThreeWindow()
    // 注册输入提供者（可插拔架构）
    win.addInputProvider(MouseProvider())
    let cfg = WindowConfig()
    cfg.resizable = false
    // width/height 传占位值：OHOS 建窗回退路径会从注册的 XComponent 取真实
    // native window 并回填真实尺寸；真实尺寸随后由 ArkTS onAreaChange 同步。
    let ok = win.start(title: "ThreeRender", width: 1, height: 1, config: cfg)
    if (ok) {
        g_windowEngine = Some(win)
        g_renderRunning.store(true)
    }
    return ok
}

// ===== 事件驱动 resize：由 ArkTS 侧 XComponent onAreaChange 触发（旋转/窗口尺寸变化） =====
// 写入原子变量，渲染线程每帧只读内存原子（非 FFI、无锁、开销≈0），
// 与参考项目 xcomponent-vsync-master 的 OnSurfaceChanged 事件驱动等价。

public func resizeThreeRender(w: Int32, h: Int32): Unit {
    if (w > 0 && h > 0) {
        g_resizeW.store(w)
        g_resizeH.store(h)
        // 同步 three.cj WindowEngine 的窗口尺寸（跨平台接口；
        // OHOS 上 XComponent 由 ArkTS 控制，仅更新内部尺寸供渲染查询）
        match (g_windowEngine) {
            case Some(engine) => engine.updateSize(w, h)
            case None => ()
        }
    }
}

// ===== 停止 three 渲染 =====

public func stopThreeRender(): Unit {
    g_renderRunning.store(false)
    match (g_windowEngine) {
        case Some(engine) => engine.shutdown()
        case None => ()
    }
    g_windowEngine = None
}

// ===== 查询渲染状态 =====

public func isThreeRendering(): Bool {
    return g_renderRunning.load()
}
