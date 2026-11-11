package test_gui

/**
 * @file ImGui 集成测试入口（独立项目，纯声明式实现）
 * @brief 验证声明式 Window{}：构造即声明 + renderWith/ui/onFrame builder + 幂等 show/wait/close
 * @explain 本项目不再继承 WindowEngine，全部改用 three.window.Window 声明式窗口：
 *   1. 测试 1（无 ui）：仅 renderWith 的声明式窗口——基线验证，30 帧后自动关闭，
 *      同时验证未声明 ui 时 gui accessor 返回 None
 *   2. 测试 2（ui + renderWith）：声明 ui 体，每帧自动执行（NewFrame..Render 之间），
 *      控件经 three.window.ui 组件类声明；窗口保持打开，由用户手动关闭（点 X）
 *   3. 两个窗口均验证 renderWith 的自动化：initBgfx（含 pixelRatio 同步）、onResize 的
 *      setPixelRatio/setSize、onClose 的 release 均由 Window 自动完成，测试代码不重复声明
 * @note 仓颉 lambda 不能捕获可变局部变量，故帧计数/累计时间/滑条值/计数器等
 *       可变状态封装为测试类的成员字段（闭包捕获对象引用，字段可合法读写）。
 *
 * 运行方式：在 test_gui 目录内 cjpm run
 */

import std.io.*
import std.time.*
import std.math.*
import three.core.math.*
import three.rendering.ThreeRenderer
import three.window.Window
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.lights.*
import three.rendering.helpers.*
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.memory.PtrArray
import three.window.ui.*

// =============================================================================
// CJK 字体加载（中文显示修复）
// =============================================================================

/**
 * @brief 加载项目内置中文字体并设为默认字体（须在首个 NewFrame 前调用，即 onCtxtInit 中）
 * @explain ImGui 默认字体（ProggyClean）只有 Latin 字形，中文字符渲染为 "?"。
 *         从 res/ 相对路径加载项目内置的黑体（simhei.ttf，常用汉字全覆盖），
 *         glyph ranges 使用简体常用集（约 2500 常用字 + Latin + 假名）。
 *         相对路径基于进程工作目录：cjpm run（项目根）与直接运行 main.exe
 *         （target/release/bin）各对应一个候选位置。
 * @return 是否成功加载（失败则保持默认字体，中文仍显示 "?"）
 */
func loadCjkFont(): Bool {
    let ranges = UiFontAtlas.getGlyphRangesChineseSimplifiedCommon()
    // 关闭过采样（默认 3×3 会让 2500 个中文字形的光栅化工作量 ×9）
    // Debug 构建未优化，解析 TTF + 光栅化 2500 字形本身也可能要数十秒
    let cfg = UiFontConfig()
    cfg.setSizePixels(18.0)
    cfg.setOversampleH(1)
    cfg.setOversampleV(1)
    for (path in ["res/simhei.ttf", "../res/simhei.ttf"]) {
        println("  [font] 正在加载: ${path} ...")
        let font = UiFontAtlas.addFontFromFileTTF(path, 18.0, fontConfig: cfg, glyphRanges: ranges)
        if (font.isLoaded()) {
            println("  [font] 解析成功，正在设置默认字体...")
            UiFontAtlas.setDefaultFont(font)
            println("  [font] 正在构建图集（2500 个中文字形光栅化，Debug 构建可能需要数十秒）...")
            let ok = UiFontAtlas.build()
            println("  [font] 图集构建完成: ${ok}")
            return ok
        }
        println("  [font] 加载失败: ${path}")
    }
    println("  [font] 未找到 res/simhei.ttf，中文将显示为 ?")
    return false
}

// =============================================================================
// 测试 1：无 ui 的声明式窗口（基线验证）
// =============================================================================

/**
 * @brief 无 ui 声明式窗口——验证 renderWith 自动化与 gui accessor 返回 None
 */
class NoUiWindowTest {
    let renderer: ThreeRenderer = ThreeRenderer()
    let scene: Scene = Scene()
    let camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    let mesh: Mesh = Mesh(geometry: BoxGeometry(width: 1.0, height: 1.0, depth: 1.0),
                          material: MeshPhongMaterial())
    var frame: Int64 = 0
    var t: Float64 = 0.0

    func run(): Bool {
        let win = Window(title: "No ImGui", width: 640, height: 480) { w =>
            w.renderWith(this.renderer)
            w.onInit({ =>
                this.renderer.setClearColor(Color(0x20, 0x20, 0x30))
                this.camera.position.set(0.0, 2.0, 4.0)
                this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
                let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
                this.scene.add(ambient)
                this.mesh.material.color = Color(0x4488ff)
                this.scene.add(this.mesh)
            })
            w.onFrame({ dt =>
                this.frame++
                this.t += dt
                // 验证未声明 ui 的窗口 gui accessor 返回 None
                if (this.frame == 1) {
                    let hasGui = match (w.getEngine().gui) {
                        case Some(_) => true
                        case None => false
                    }
                    if (hasGui) {
                        println("  [FAIL] 无 Gui 窗口不应有 Gui 上下文!")
                        w.close()
                        return
                    }
                    println("  [PASS] 无 Gui 窗口：gui accessor 返回 None")
                }
                // 旋转立方体
                this.mesh.rotation.x = this.t * 0.5
                this.mesh.rotation.y = this.t * 0.7
                this.renderer.render(this.scene, this.camera)
                if (this.frame >= 30) {
                    w.close()
                }
            })
            w.onResize({ width, height =>
                // 后备缓冲重建/pixelRatio 刷新由 renderWith 自动完成；此处只更新相机
                this.camera.aspect = Float64(width) / Float64(height)
                this.camera.updateProjectionMatrix()
            })
        }
        if (!win.show()) {
            println("  窗口创建失败!")
            return false
        }
        win.wait()
        return true
    }
}

// =============================================================================
// 测试 2：声明 ui 体的窗口（完整集成验证）
// =============================================================================

/**
 * @brief 声明式 ImGui 窗口——ui 体声明控件，验证声明式 UI 集成正确性
 */
class UiWindowTest {
    let renderer: ThreeRenderer = ThreeRenderer()
    let scene: Scene = Scene()
    let camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var frame: Int64 = 0
    var t: Float64 = 0.0
    var sliderVal: Float32 = 0.5
    var counter: Int32 = 0

    func run(): Bool {
        let win = Window(title: "ImGui Test", width: 800, height: 600) { w =>
            w.renderWith(this.renderer)
            // 字体加载须在 Gui 上下文初始化后、首个 NewFrame 前（onInit 时 ImGui 上下文不存在）
            w.onCtxtInit({ => loadCjkFont() })
            w.onInit({ =>
                this.renderer.setClearColor(Color(0x1a, 0x1a, 0x2e))
                this.camera.position.set(0.0, 2.0, 4.0)
                this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
                let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
                this.scene.add(ambient)
                let grid = GridHelper(size: 10.0, divisions: 10, color1: Color(0x444444), color2: Color(0x666666))
                this.scene.add(grid)
            })
            w.onFrame({ dt =>
                this.frame++
                this.t += dt
                // 验证 UiContext 已初始化
                if (this.frame == 1) {
                    match (w.getEngine().gui) {
                        case Some(c) =>
                            if (c.initialized) {
                                println("  [PASS] Gui 启用：UiContext 已初始化")
                            } else {
                                println("  [FAIL] Gui 启用但 UiContext 未初始化!")
                                w.close()
                                return
                            }
                        case None =>
                            println("  [FAIL] Gui 启用但 gui accessor 返回 None!")
                            w.close()
                            return
                    }
                }
                // 场景渲染
                this.camera.position.set(5.0 * sin(this.t * 0.1), 3.0, 5.0 * cos(this.t * 0.1))
                this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
                this.renderer.render(this.scene, this.camera)
                // 每 100 帧打印状态
                if (this.frame % 100 == 1) {
                    println("  [render] frame=${this.frame} counter=${this.counter}")
                }
            })
            // 声明式 UI 体：每帧自动执行（ImGui NewFrame 之后、Render 之前）
            w.ui({ =>
                let sliderArr = PtrArray<Float32>(1)
                sliderArr.set(0, this.sliderVal)
                UiWindow(title: "Gui Test").draw({ =>
                    UiText(text: "Frame: " + this.frame.toString()).draw()
                    UiText(text: "Hello from declarative Window!").draw()
                    UiSliderFloat(label: "Value", value: sliderArr, min: 0.0f32, max: 1.0f32, format: "%.3f").draw()
                    this.sliderVal = sliderArr.get(0)
                    UiButton(label: "Click Me").onClick({ => this.counter++ }).draw()
                    UiSameLine().draw()
                    UiText(text: "Counter: " + this.counter.toString()).draw()
                })
            })
        }
        if (!win.show()) {
            println("  窗口创建失败!")
            return false
        }
        win.wait()
        return true
    }
}

// =============================================================================
// 测试 3：自绘交互控件演示（CustomWidgets.cj v2，事件隔离版）
// =============================================================================

/**
 * @brief 自绘控件演示窗口——圆角按钮 / 拟物开关 / 环形进度 / 自绘滑条
 * @explain 展示 three.window.ui 全能力组合的自绘模式（v2）：
 *   UiDummy 布局占位 + UiMouse 矩形命中（事件独立判定，无 ImGui item 状态共享）
 *   + UiDrawList 自绘外观 + UiCursor 度量（getFrameHeight/getContentRegionAvail）。
 */
class CustomWidgetsTest {
    let renderer: ThreeRenderer = ThreeRenderer()
    let scene: Scene = Scene()
    let camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var frame: Int64 = 0
    var t: Float64 = 0.0
    var clicks: Int32 = 0
    var toggleA: Bool = false
    var toggleB: Bool = true
    var sliderVal: Float32 = 0.35
    var ringVal: Float32 = 0.0

    func run(): Bool {
        let win = Window(title: "Custom Widgets Demo", width: 800, height: 600) { w =>
            w.renderWith(this.renderer)
            // 字体加载须在 Gui 上下文初始化后、首个 NewFrame 前（onInit 时 ImGui 上下文不存在）
            w.onCtxtInit({ => loadCjkFont() })
            w.onInit({ =>
                this.renderer.setClearColor(Color(0x14, 0x14, 0x20))
                this.camera.position.set(0.0, 2.0, 4.0)
                this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
                let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
                this.scene.add(ambient)
                let grid = GridHelper(size: 10.0, divisions: 10, color1: Color(0x333344), color2: Color(0x555566))
                this.scene.add(grid)
            })
            w.onFrame({ dt =>
                this.frame++
                this.t += dt
                // 环形进度随时间流动（演示每帧重绘）
                this.ringVal = Float32(0.5 + 0.5 * sin(this.t * 1.2))
                this.camera.position.set(5.0 * sin(this.t * 0.1), 3.0, 5.0 * cos(this.t * 0.1))
                this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
                this.renderer.render(this.scene, this.camera)
            })
            // 声明式 UI 体：自绘控件与内置控件混排
            w.ui({ =>
                UiWindow(title: "Custom Widgets Demo").draw({ =>
                    resetHitCounter()
                    UiText(text: "—— 圆角半透明按钮（hover/按下变色） ——").draw()
                    UiRoundedButton(label: "Button 0", w: 110.0, h: 34.0, rounding: 17.0)
                        .onClick({ => this.clicks++ }).draw()
                    UiSameLine().draw()
                    UiRoundedButton(label: "Button 1", w: 110.0, h: 34.0, rounding: 17.0)
                        .onClick({ => this.clicks += 10 }).draw()
                    UiSameLine().draw()
                    UiRoundedButton(label: "Button 2", w: 110.0, h: 34.0, rounding: 17.0)
                        .onClick({ => this.clicks += 100 }).draw()
                    UiSameLine().draw()
                    UiText(text: "Clicks: " + this.clicks.toString()).draw()

                    UiText(text: "—— 拟物开关 ——").draw()
                    UiToggleSwitch(on: this.toggleA)
                        .onChange({ v => this.toggleA = v }).draw()
                    UiSameLine().draw()
                    UiText(text: "A: " + (if (this.toggleA) { "ON" } else { "OFF" })).draw()
                    UiSameLine().draw()
                    UiToggleSwitch(on: this.toggleB)
                        .onChange({ v => this.toggleB = v }).draw()
                    UiSameLine().draw()
                    UiText(text: "B: " + (if (this.toggleB) { "ON" } else { "OFF" })).draw()

                    UiText(text: "—— 环形进度（随时间流动）+ 自绘滑条 ——").draw()
                    UiRingProgress(fraction: this.ringVal, radius: 36.0).draw()
                    UiSameLine().draw()
                    // 滑条宽度自适应内容区剩余空间（getContentRegionAvail）
                    let avail = UiCursor.getContentRegionAvail()
                    UiFancySlider(value: this.sliderVal, w: Float32(avail.x), h: 24.0, min: 0.0, max: 1.0)
                        .onChange({ v => this.sliderVal = v }).draw()
                    UiText(text: "Slider: " + this.sliderVal.toString()).draw()

                    UiText(text: "—— 与默认控件高度对齐（getFrameHeight） ——").draw()
                    // 自绘按钮高度取标准帧高度，与内置控件视觉一致
                    let frameH = UiCursor.getFrameHeight()
                    UiRoundedButton(label: "Aligned", w: 110.0, h: frameH, rounding: 6.0)
                        .onClick({ => this.clicks = 0 }).draw()
                    UiSameLine().draw()
                    UiButton(label: "Reset").onClick({ => this.clicks = 0 }).draw()
                })
            })
        }
        if (!win.show()) {
            println("  窗口创建失败!")
            return false
        }
        win.wait()
        return true
    }
}

// =============================================================================
// 主入口
// =============================================================================

main(): Int64 {
    println("=== test_gui：声明式 Window 集成测试 ===")
    println("")

    // ---- 测试 1：无 ui 的声明式窗口（基线验证）----
    println("[test 1] 无 ui 声明式窗口（基线验证）...")
    if (!NoUiWindowTest().run()) {
        println("  测试 1 失败!")
        return 1
    }
    println("  通过")
    println("")

    // ---- 测试 2：声明 ui 体窗口（完整集成验证）----
    println("[test 2] 声明式 ui 体窗口（完整集成验证，保持打开直到手动关闭）...")
    if (!UiWindowTest().run()) {
        println("  测试 2 失败!")
        return 1
    }
    println("  通过")
    println("")

    // ---- 测试 3：自绘交互控件演示----
    println("[test 3] 自绘交互控件演示（事件隔离版：圆角按钮/开关/环形进度/自绘滑条，手动关闭）...")
    if (!CustomWidgetsTest().run()) {
        println("  测试 3 失败!")
        return 1
    }
    println("  通过")
    println("")

    println("=== test_gui：全部通过 ===")
    return 0
}
