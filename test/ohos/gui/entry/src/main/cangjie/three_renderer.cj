package ohos_app_cangjie_entry

/**
 * 仓颉侧 three ImGui 集成测试与 ArkTS 侧 XComponent 的桥接（纯仓颉实现，无 C++）。
 *
 * 职责：
 *  - 通过 three.cj 的 WindowEngine 获取 native window 句柄/尺寸后，初始化
 *    three 引擎的 BgfxRenderer（bgfx + OpenGLES），创建带 GridHelper 的场景，
 *    启用 ImGui（useGui），在 onFrame 中绘制 ImGui 控件，验证引擎在 OHOS 下的
 *    UI 可用性（对齐 windows/gui test 2）。
 *
 * 测试内容：
 *  - useImGui() 启用后引擎自动创建 UiContext
 *  - onFrame 中可通过 three.window.ui API 绘制控件
 *  - ImGui 窗口保持打开，验证渲染 + UI 共存无异常
 *
 * OHOS 说明：与 base 工程一致，通过 SDL 注册 XComponent + native window 建窗。
 */

import std.sync.*
import std.time.*
import std.runtime.*
import std.math.*
import std.io.*
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
import three.rendering.lights.*
import three.rendering.helpers.*
import three.utils.log.Logger
import three.utils.log.LogLevel
import three.window.ui.*

// ===== 全局状态 =====

var g_windowEngine: Option<WindowEngine> = None

var g_renderRunning = AtomicBool(false)
var g_renderFrame: Int64 = 0
var g_resizeW = AtomicInt32(0)
var g_resizeH = AtomicInt32(0)

// ===== OHOS ImGui 测试窗口（对齐 windows/gui test 2：ImGuiWindow） =====

public class ImGuiWindow <: WindowEngine {
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var frame: Int64 = 0
    var sliderVal: Float32 = 0.5
    var counter: Int32 = 0
    var appliedW: Int32 = 0
    var appliedH: Int32 = 0
    var _mouse: Option<MouseProvider> = None

    // ===== 生命周期：窗口创建后（初始化渲染器/场景 + ImGui） =====
    public override func onInit(): Unit {
        this._mouse = this.getProvider<MouseProvider>()
        let hwnd = this.getNativeWindowHandle()
        // OHOS 窗口真实尺寸由 ArkTS XComponent 控制
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
        this.renderer.setClearColor(Color(0x1a, 0x1a, 0x2e))
        // 绑定 execBgfx 到窗口引擎（供 ImGui render hook 使用）
        this.bindRenderer(this.renderer.execBgfx)

        // 相机：绕场景旋转（对齐 windows/gui ImGuiWindow）
        this.camera.position.set(0.0, 2.0, 4.0)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
        this.scene.add(ambient)
        let grid = GridHelper(size: 10.0, divisions: 10, color1: Color(0x444444), color2: Color(0x666666))
        this.scene.add(grid)
    }

    // ===== 生命周期：每循环（渲染场景 + ImGui 控件） =====
    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // 验证 UiContext 已初始化（此时 UiContext 刚由 _windowLoop 初始化）
        if (this.frame == 1) {
            let ctx = this.gui
            match (ctx) {
                case Some(c) =>
                    if (c.initialized) {
                        println("  [PASS] Gui 启用：UiContext 已初始化")
                    } else {
                        println("  [FAIL] Gui 启用但 UiContext 未初始化!")
                        this.requestClose()
                        return
                    }
                case None =>
                    println("  [FAIL] Gui 启用但 gui accessor 返回 None!")
                    this.requestClose()
                    return
            }
        }

        // 应用 ArkTS onAreaChange 尺寸
        let rw = g_resizeW.load()
        let rh = g_resizeH.load()
        if (rw > 0i32 && rh > 0i32 && (rw != this.appliedW || rh != this.appliedH)) {
            this.appliedW = rw
            this.appliedH = rh
            this.renderer.setPixelRatio(Float64(this.getPixelRatio()))
            this.renderer.setSize(rw, rh)
        }
        let w = this.getWidth()
        let h = this.getHeight()
        this.camera.aspect = Float64(w) / Float64(if (h > 1i32) { h } else { 1i32 })
        this.camera.updateProjectionMatrix()

        // 场景渲染：相机绕原点旋转（对齐 windows/gui ImGuiWindow）
        let t = Float64(this.frame) * 0.02
        this.camera.position.set(5.0 * sin(t * 0.1), 3.0, 5.0 * cos(t * 0.1))
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        this.renderer.render(this.scene, this.camera)

        // ImGui 自定义样式演示
        let (dw, dh) = UiStyle.getDisplaySize()
        UiWindow.setNextWindowPos(dw * 0.5f32, dh * 0.5f32, pivotX: 0.5f32, pivotY: 0.5f32)
        UiWindow.setNextWindowSize(dw * 0.85f32, dh * 0.85f32)

        let sliderPtr = unsafe { CPointer<Float32>(LibC.malloc<Float32>()) }
        unsafe { sliderPtr.write(this.sliderVal) }
        let counterPtr = unsafe { CPointer<Int32>(LibC.malloc<Int32>()) }
        unsafe { counterPtr.write(this.counter) }

        UiWindow(title: "three.window.ui Demo").draw({ =>
            // --- 标题区 ---
            UiTextColored(text: "OHOS ImGui Test", color: Color(0.4, 0.8, 1.0)).draw()
            UiTextDisabled(text: "Powered by three.cj + imgui4cj").draw()
            UiSeparatorText(label: "Info")
            UiText(text: "Frame: " + this.frame.toString()).draw()
            let (tw, th) = UiStyle.calcTextSize("Hello")
            UiText(text: "calcTextSize(\"Hello\") = " + tw.toString() + " x " + th.toString()).draw()
            UiText(text: "DisplaySize: " + dw.toString() + " x " + dh.toString()).draw()
            UiText(text: "Time: " + UiStyle.getTime().toString() + "s").draw()

            // --- 交互控件 ---
            UiSeparatorText(label: "Controls")
            UiSliderFloat(label: "Slider", value: sliderPtr, min: 0.0f32, max: 1.0f32, format: "%.3f").draw()
            this.sliderVal = unsafe { sliderPtr.read() }
            UiProgressBar(fraction: this.sliderVal).draw()

            if (UiButton(label: "Click Me").draw()) { this.counter++ }
            UiSameLine().draw()
            UiText(text: "Counter: " + this.counter.toString()).draw()

            UiSameLine().draw()
            UiBullet().withContent({ =>
                UiText(text: "Bullet item").draw()
            }).draw()

            // --- Tree / Collapsing ---
            UiSeparatorText(label: "Tree")
            UiTreeNode(label: "Details").withContent({ =>
                UiText(text: "Expanded content").draw()
                UiText(text: "Label: Value").draw()
            }).draw()
            UiCollapsingHeader(label: "More Info").draw()
            UiTextWrapped(text: "This is a very long text that should wrap automatically within the window boundaries to demonstrate the text wrapping capability.").draw()

            // --- Tab Bar ---
            UiSeparatorText(label: "Tabs")
            UiTabBar(id: "demo_tabs", content: { =>
                UiTabItem(label: "Tab A", content: { =>
                    UiText(text: "Content of Tab A").draw()
                    UiTextColored(text: "Colored text here", color: Color(1.0, 0.5, 0.2)).draw()
                }).draw()
                UiTabItem(label: "Tab B", content: { =>
                    UiText(text: "Content of Tab B").draw()
                    UiText(text: "(link placeholder)").draw()
                }).draw()
            }).draw()

            // --- 状态 ---
            UiSeparatorText(label: "Status")
            UiText(text: "Frames rendered: " + UiStyle.getFrameCount().toString()).draw()
        })

        unsafe { LibC.free(sliderPtr) }
        unsafe { LibC.free(counterPtr) }

        // 每 100 帧打印状态
        if (this.frame % 100 == 1) {
            println("  [render] frame=${this.frame} counter=${this.counter}")
        }
    }

    // ===== 生命周期：关闭前（清理渲染器） =====
    public override func onClose(): Unit {
        this.renderer.shutdown()
    }
}

// ===== 启动 three ImGui 渲染（WindowEngine + 独立泵线程驱动） =====

public func startThreeRender(context: Option<UIAbilityContext>): Bool {
    if (g_renderRunning.load()) {
        return true
    }
    Logger.setLevel(LogLevel.Trace)
    let win = ImGuiWindow()
    // 注册输入提供者
    win.addInputProvider(MouseProvider())
    // 启用 ImGui（引擎自动创建 UiContext）
    win.useGui()
    let cfg = WindowConfig()
    cfg.resizable = false
    let ok = win.start(title: "ImGui OHOS Test", width: 1, height: 1, config: cfg)
    if (ok) {
        g_windowEngine = Some(win)
        g_renderRunning.store(true)
    }
    return ok
}

// ===== 事件驱动 resize =====

public func resizeThreeRender(w: Int32, h: Int32): Unit {
    if (w > 0 && h > 0) {
        g_resizeW.store(w)
        g_resizeH.store(h)
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
