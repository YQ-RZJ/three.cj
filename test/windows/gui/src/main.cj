package test_gui

/**
 * @file ImGui 集成测试入口（独立项目）
 * @brief 验证 three 内置 ImGui 集成：useImGui() → UiContext 生命周期 → 控件渲染 → 退出
 * @explain 测试内容：
 *   1. 无 ImGui 窗口行为不变（基线验证，30 帧后自动关闭）
 *   2. useImGui() 启用后引擎自动创建 UiContext
 *   3. onFrame 中可通过 three.window.ui API 绘制控件
 *   4. ImGui 窗口保持打开，由用户手动关闭（点 X），验证关闭流程无挂起
 *
 * 运行方式：在 test_gui 目录内 cjpm run
 */

import std.io.*
import std.time.*
import std.math.*
import three.core.math.*
import three.rendering.ThreeRenderer
import three.window.WindowEngine
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
// 测试窗口：无 ImGui（基线验证）
// =============================================================================

/**
 * @brief 无 ImGui 窗口——验证不启用 useImGui() 时行为不变
 */
public class NoImGuiWindow <: WindowEngine {
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var mesh: Mesh = Mesh(geometry: BoxGeometry(width: 1.0, height: 1.0, depth: 1.0),
                          material: MeshPhongMaterial())
    var frame: Int64 = 0

    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x20, 0x20, 0x30))

        this.camera.position.set(0.0, 2.0, 4.0)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
        this.scene.add(ambient)
        this.mesh.material.color = Color(0x4488ff)
        this.scene.add(this.mesh)
    }

    public override func onFrame(dt: Float64): Unit {
        this.frame++
        // 验证 gui accessor 返回 None
        if (this.frame == 1) {
            let hasGui = match (this.gui) {
                case Some(_) => true
                case None => false
            }
            if (hasGui) {
                println("  [FAIL] 无 Gui 窗口不应有 Gui 上下文!")
                this.requestClose()
                return
            }
            println("  [PASS] 无 Gui 窗口：gui accessor 返回 None")
        }
        // 旋转立方体
        let t = Float64(this.frame) * 0.02
        this.mesh.rotation.x = t * 0.5
        this.mesh.rotation.y = t * 0.7
        this.renderer.render(this.scene, this.camera)
        if (this.frame >= 30) {
            this.requestClose()
        }
    }

    public override func onResize(width: Int32, height: Int32): Unit {
        // 窗口尺寸变化 → 重建后备缓冲（内部触发 bgfx reset）+ 更新相机纵横比
        // 同时刷新 pixelRatio（窗口拖到不同缩放率的显示器时 DPI 会变化）
        this.renderer.setPixelRatio(Float64(this.getPixelRatio()))
        this.renderer.setSize(width, height)
        this.camera.aspect = Float64(width) / Float64(height)
        this.camera.updateProjectionMatrix()
    }

    public override func onClose(): Unit {
        this.renderer.shutdown()
    }
}

// =============================================================================
// 测试窗口：启用 ImGui（完整集成验证）
// =============================================================================

/**
 * @brief ImGui 测试窗口——启用 ImGui，绘制控件，验证集成正确性
 */
public class ImGuiWindow <: WindowEngine {
    var renderer: ThreeRenderer = ThreeRenderer()
    var scene: Scene = Scene()
    var camera: PerspectiveCamera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
    var frame: Int64 = 0
    var sliderVal: Float32 = 0.5
    var counter: Int32 = 0

    public override func onInit(): Unit {
        let hwnd = this.getNativeWindowHandle()
        let w = this.getWidth()
        let h = this.getHeight()
        let dpr = this.getPixelRatio()
        this.renderer.setPixelRatio(Float64(dpr))
        let ok = this.renderer.initBgfx(hwnd, w, h)
        if (!ok) {
            this.requestClose()
            return
        }
        this.renderer.setSize(w, h)
        this.renderer.setClearColor(Color(0x1a, 0x1a, 0x2e))
        // 绑定 execBgfx 到窗口引擎（供 ImGui render hook 使用）
        this.bindRenderer(this.renderer.execBgfx)

        this.camera.position.set(0.0, 2.0, 4.0)
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.6)
        this.scene.add(ambient)
        let grid = GridHelper(size: 10.0, divisions: 10, color1: Color(0x444444), color2: Color(0x666666))
        this.scene.add(grid)
    }

    public override func onFrame(dt: Float64): Unit {
        this.frame++

        // 验证 UiContext 已初始化
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

        // 场景渲染
        let t = Float64(this.frame) * 0.02
        this.camera.position.set(5.0 * sin(t * 0.1), 3.0, 5.0 * cos(t * 0.1))
        this.camera.lookAt(Vector3(0.0, 0.0, 0.0))
        this.renderer.render(this.scene, this.camera)

        // ImGui 控件（通过 three.window.ui 组件类）
        let sliderArr = PtrArray<Float32>(1)
        sliderArr.set(0, this.sliderVal)
        let counterPtr = unsafe { CPointer<Int32>(LibC.malloc<Int32>()) }
        unsafe { counterPtr.write(this.counter) }

        UiWindow(title: "Gui Test").draw({ =>
            UiText(text: "Frame: " + this.frame.toString()).draw()
            UiText(text: "Hello from three.window.ui!").draw()
            UiSliderFloat(label: "Value", value: sliderArr, min: 0.0f32, max: 1.0f32, format: "%.3f").draw()
            this.sliderVal = sliderArr.get(0)
            UiButton(label: "Click Me").onClick({ => this.counter++ }).draw()
            UiSameLine().draw()
            UiText(text: "Counter: " + this.counter.toString()).draw()
        })

        unsafe { LibC.free(counterPtr) }

        // 每 100 帧打印状态
        if (this.frame % 100 == 1) {
            println("  [render] frame=${this.frame} counter=${this.counter}")
        }
    }

    public override func onResize(width: Int32, height: Int32): Unit {
        // 窗口尺寸变化 → 重建后备缓冲（内部触发 bgfx reset）+ 更新相机纵横比
        // 同时刷新 pixelRatio（窗口拖到不同缩放率的显示器时 DPI 会变化）
        this.renderer.setPixelRatio(Float64(this.getPixelRatio()))
        this.renderer.setSize(width, height)
        this.camera.aspect = Float64(width) / Float64(height)
        this.camera.updateProjectionMatrix()
    }

    public override func onClose(): Unit {
        this.renderer.shutdown()
    }
}

// =============================================================================
// 主入口
// =============================================================================

main(): Int64 {
    println("=== test_gui：ImGui 集成测试 ===")
    println("")

    // ---- 测试 1：无 ImGui 窗口（基线验证）----
    println("[test 1] 无 ImGui 窗口（基线验证）...")
    let win1 = NoImGuiWindow()
    let ok1 = win1.start(title: "No ImGui", width: 640, height: 480)
    if (!ok1) {
        println("  窗口创建失败!")
        return 1
    }
    win1.wait()
    println("  通过")
    println("")

    // ---- 测试 2：ImGui 窗口（完整集成验证）----
    println("[test 2] ImGui 窗口（完整集成验证，保持打开直到手动关闭）...")
    let win2 = ImGuiWindow()
    win2.useGui()
    let ok2 = win2.start(title: "ImGui Test", width: 800, height: 600)
    if (!ok2) {
        println("  窗口创建失败!")
        return 1
    }
    win2.wait()
    println("  通过")
    println("")

    println("=== test_gui：全部通过 ===")
    return 0
}
