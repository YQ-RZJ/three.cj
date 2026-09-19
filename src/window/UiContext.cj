/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] UiContext ImGui 上下文管理器
 * @brief[zh-cn] 管理 ImGui 上下文的生命周期、事件桥接与渲染集成
 * @explain[zh-cn] 由 WindowEngine 在启用 ImGui 时自动创建和销毁。
 *         开发者通过 window.imgui 访问器使用 three.window.ui 的完整控件 API。
 *         **View 约定**：ImGui 固定使用 bgfx view 1（由 imgui_impl_bgfx 后端的 startingViewId=1
 *         决定）；view 0 及其他 view 由 ThreeRenderer 和后处理管线使用。不要在 view 1 上提交
 *         任何非 ImGui 的渲染命令。
 *
 * @file[en] UiContext ImGui context manager
 * @brief[en] Manages the ImGui context lifecycle, event bridging, and render integration
 * @explain[en] Created and destroyed automatically by WindowEngine when ImGui is enabled.
 *             Developers use three.window.ui widget API through the window.ui accessor.
 *             **View convention**: ImGui exclusively uses bgfx view 1 (set by imgui_impl_bgfx's
 *             startingViewId=1); view 0 and other views are used by ThreeRenderer and post-
 *             processing passes. Do not submit any non-ImGui rendering commands to view 1.
 */
package three.window

import std.core.*
import three.core.thread.{ Mutex, Condition, SThread }
import imgui4cj.imgui.*
import bgfx4cj.bgfx.*
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] UI 上下文——管理 ImGui 生命周期与渲染
 * @explain[zh-cn] 内部类，由 WindowEngine 按需实例化。
 *         持有 imgui4cj 上下文指针、帧状态与事件缓冲。
 *         NewFrame 在窗口泵线程调用，Render 在 bgfx 渲染线程调用。
 *         开发者通过 three.window.ui 的 re-export 函数使用全部 ImGui 能力。
 *
 * @brief[en] UI context — manages ImGui lifecycle and rendering
 * @explain[en] Internal class, instantiated by WindowEngine as needed.
 *             Holds the imgui4cj context pointer, frame state, and event buffer.
 *             NewFrame is called on the window pump thread; Render on the bgfx render thread.
 *             Developers use three.window.ui re-export functions for all ImGui capabilities.
 */
public class UiContext {
    // ===== 内部字段 =====
    /// imgui4cj 上下文指针
    private var _ctx: CPointer<Unit> = CPointer<Unit>()
    /// 关联的窗口引擎
    private var _engine: Option<WindowEngine> = None
    /// 是否已初始化
    private var _initialized: Bool = false
    /// 当前帧是否在 NewFrame..Render 之间
    private var _inFrame: Bool = false
    /// 当前窗口像素比（由 WindowEngine 每帧注入）
    private var _pixelRatio: Float64 = 1.0
    /// 渲染器的 execBgfx 提交方法（由 initialize 注入，供 render/shutdown 路由 bgfx 调用）
    private var _execBgfx: Option<(() -> Unit) -> Unit> = None

    // ===== 全局 DPI 访问（供 three.window.ui 控件层查询当前缩放） =====
    private static var _currentPixelRatio: Float64 = 1.0
    /// 当前活跃的 ImGui 上下文指针（供 SDL 线程事件转发时设置 TLS）
    private static var _currentCtx: CPointer<Unit> = CPointer<Unit>()

    /**
     * @brief[zh-cn] 获取当前活跃的 ImGui 上下文指针（供 SDLDispatcher 在 SDL 线程上设置 TLS）
     * @return[zh-cn] 上下文指针，未初始化时为空
     *
     * @brief[en] Gets the currently active ImGui context pointer (for SDLDispatcher to set TLS on the SDL thread)
     * @return[en] Context pointer, null if not initialized
     */
    internal static func getCurrentContext(): CPointer<Unit> {
        return _currentCtx
    }

    /**
     * @brief[zh-cn] 获取当前 UI 上下文使用的像素比
     * @return[zh-cn] 像素比（物理像素 / 逻辑像素）
     *
     * @brief[en] Gets the pixel ratio used by the current UI context
     * @return[en] Pixel ratio (physical pixels / logical pixels)
     */
    public static prop currentPixelRatio: Float64 {
        get() { _currentPixelRatio }
    }

    // ===== 构造 =====
    public init() {}

    // ===== 帧状态查询 =====

    /**
     * @brief[zh-cn] 上下文是否已初始化
     *
     * @brief[en] Whether the context has been initialized
     */
    public prop initialized: Bool {
        get() { this._initialized }
    }

    // ===== 生命周期方法（由 WindowEngine 在合适线程调用） =====

    /**
     * @brief[zh-cn] 初始化 ImGui 上下文与后端
     * @explain[zh-cn] 必须在 bgfx 已初始化之后调用。在窗口泵线程内执行。
     *         线程路由：
     *         - ImGui 核心（CreateContext/SetCurrentContext）：泵线程
     *         - SDL3 后端（ImGui_ImplSDL3_InitForOther）：经 execSDL 路由到 SDL 系统线程
     *           （SDL 视频子系统 API 只能在初始化线程调用）
     *         - bgfx 后端（ImGui_Implbgfx_Init）：经 execBgfx 路由到 bgfx 渲染线程
     *         每次跨线程调用前都设置当前上下文（ImGui 上下文通过 TLS 存储）。
     * @param[zh-cn] engine 关联的窗口引擎
     *         execBgfx 渲染器的 execBgfx 提交方法（用于路由 bgfx 后端调用）
     *
     * @brief[en] Initialize the ImGui context and backends
     * @explain[en] Must be called after bgfx initialization. Runs on the window pump thread.
     *         Thread routing:
     *         - ImGui core (CreateContext/SetCurrentContext): pump thread
     *         - SDL3 backend (ImGui_ImplSDL3_InitForOther): routed to SDL system thread via execSDL
     *           (SDL video subsystem APIs may only be called on the initialization thread)
     *         - bgfx backend (ImGui_Implbgfx_Init): routed to bgfx render thread via execBgfx
     *         The current context is set before each cross-thread call (ImGui context is stored in TLS).
     * @param[en] engine The associated window engine
     *         execBgfx The renderer's execBgfx submit method (for routing bgfx backend calls)
     */
    internal func initialize(engine: WindowEngine, execBgfx: (() -> Unit) -> Unit) {
        if (this._initialized) { return }
        @LogInfo(["UiContext.initialize: start"])
        this._engine = Some(engine)
        this._execBgfx = Some(execBgfx)
        // 创建 ImGui 上下文（泵线程）
        @LogInfo(["UiContext.initialize: creating ImGui context"])
        this._ctx = ImGui_CreateContext_cj(CPointer<Unit>())
        if (this._ctx.isNull()) {
            @LogError(["UiContext.initialize: igCreateContext FAILED"])
            return
        }
        // 记录全局活跃上下文（供 SDL 线程事件转发）
        _currentCtx = this._ctx
        // 设置当前上下文到泵线程
        @LogInfo(["UiContext.initialize: set current context"])
        ImGui_SetCurrentContext_cj(this._ctx)
        // 暗色主题（需当前上下文）
        igStyleColorsDark_cj(CPointer<Unit>())

        let ctxPtr = this._ctx
        let win = engine.getSDLWindow()

        // SDL3 后端初始化：必须在 SDL 系统线程执行（SDL 视频子系统 API 约束）
        @LogInfo(["UiContext.initialize: init SDL3 backend (SDL thread)"])
        let sdlOkBox = Box(false)
        SDLDispatcher.execSDL({ =>
            ImGui_SetCurrentContext_cj(ctxPtr)
            sdlOkBox.value = ImGui_ImplSDL3_InitForOther_cj(win)
        })
        if (!sdlOkBox.value) {
            @LogError(["UiContext.initialize: ImGui_ImplSDL3_InitForOther FAILED"])
        }

        // bgfx 后端初始化：必须在 bgfx 渲染线程执行（startingViewId=1，view 0 保留给场景）
        @LogInfo(["UiContext.initialize: init bgfx backend (bgfx thread)"])
        let bgfxOkBox = Box(false)
        execBgfx({ =>
            ImGui_SetCurrentContext_cj(ctxPtr)
            bgfxOkBox.value = ImGui_Implbgfx_Init_cj(true, 1)
        })
        if (!bgfxOkBox.value) {
            @LogError(["UiContext.initialize: ImGui_Implbgfx_Init FAILED"])
        }

        // 恢复泵线程的当前上下文（spawn 可能在 execSDL/execBgfx 期间迁移）
        ImGui_SetCurrentContext_cj(this._ctx)
        this._initialized = true
        @LogInfo(["UiContext: initialized (ctx=ok)"])
    }

    /**
     * @brief[zh-cn] 销毁 ImGui 上下文与后端资源
     * @explain[zh-cn] 在窗口泵线程内调用。SDL3 后端关闭经 execSDL 路由到 SDL 系统线程，
     *         bgfx 后端关闭经 execBgfx 路由到 bgfx 渲染线程。
     *
     * @brief[en] Destroy the ImGui context and backend resources
     * @explain[en] Called on the window pump thread. SDL3 backend shutdown is routed to the
     *         SDL system thread via execSDL; bgfx backend shutdown is routed to the bgfx render
     *         thread via execBgfx.
     */
    internal func shutdown(): Unit {
        if (!this._initialized) { return }
        let ctxPtr = this._ctx
        // 关闭 SDL3 后端（SDL 系统线程）
        SDLDispatcher.execSDL({ =>
            ImGui_SetCurrentContext_cj(ctxPtr)
            ImGui_ImplSDL3_Shutdown_cj()
        })
        // 关闭 bgfx 后端（bgfx 渲染线程）
        match (this._execBgfx) {
            case Some(execFn) =>
                execFn({ =>
                    ImGui_SetCurrentContext_cj(ctxPtr)
                    ImGui_Implbgfx_Shutdown_cj()
                })
            case None => ()
        }
        // 销毁 ImGui 上下文（泵线程）
        ImGui_SetCurrentContext_cj(this._ctx)
        ImGui_DestroyContext_cj(this._ctx)
        this._ctx = CPointer<Unit>()
        _currentCtx = CPointer<Unit>()
        this._initialized = false
        this._engine = None
        this._execBgfx = None
        @LogInfo(["UiContext: shut down"])
    }

    /**
     * @brief[zh-cn] 设置当前窗口像素比
     * @param[zh-cn] value 像素比（物理像素 / 逻辑像素）
     *
     * @brief[en] Sets the current window pixel ratio
     * @param[en] value Pixel ratio (physical pixels / logical pixels)
     */
    public func setPixelRatio(value: Float64): Unit {
        this._pixelRatio = value
        _currentPixelRatio = value
    }

    /**
     * @brief[zh-cn] 开始新帧：设置 IO 参数并调用 ImGui::NewFrame
     * @explain[zh-cn] 在窗口泵线程调用，事件已在之前写入 IO。
     *         ImGui_ImplSDL3_NewFrame 会根据 SDL 窗口逻辑尺寸与物理尺寸自动设置
     *         DisplaySize 和 DisplayFramebufferScale，因此 UI 控件层只需按逻辑像素传参。
     * @param[zh-cn] dt 帧间隔秒数
     * width 窗口逻辑宽度
     * height 窗口逻辑高度
     *
     * @brief[en] Begin a new frame: set IO parameters and call ImGui::NewFrame
     * @explain[en] Called on the window pump thread; events must have been written to IO beforehand.
     *         ImGui_ImplSDL3_NewFrame automatically sets DisplaySize and DisplayFramebufferScale
     *         from SDL window logical/physical dimensions, so UI widget APIs only need logical pixels.
     * @param[en] dt Frame delta in seconds
     * width Window logical width
     * height Window logical height
     */
    internal func newFrame(dt: Float64, width: Int32, height: Int32): Unit {
        if (!this._initialized) { return }
        if (this._inFrame) {
            @LogError(["UiContext.newFrame: already in NewFrame"])
            return
        }
        this._inFrame = true
        let ctxPtr = this._ctx
        // SDL3 后端 NewFrame：经 execSDL 路由到 SDL 系统线程
        // （内部调用 SDL_GetWindowSize / SDL_GetPerformanceCounter 等）
        SDLDispatcher.execSDL({ =>
            ImGui_SetCurrentContext_cj(ctxPtr)
            ImGui_ImplSDL3_NewFrame_cj()
        })
        // ImGui 核心 NewFrame：泵线程（spawn 可能迁移，需重设上下文）
        ImGui_SetCurrentContext_cj(this._ctx)
        ImGui_NewFrame_cj()
    }

    /**
     * @brief[zh-cn] 结束帧：调用 ImGui::Render，设置 view 1，执行 RenderDrawData
     * @explain[zh-cn] 在 bgfx 渲染线程内调用（通过 ThreeRenderer.execBgfx 提交）。
     * @param[zh-cn] viewW 视口宽度
     * viewH 视口高度
     *
     * @brief[en] End frame: call ImGui::Render, set up view 1, execute RenderDrawData
     * @explain[en] Called on the bgfx render thread (via ThreeRenderer.execBgfx).
     * @param[en] viewW Viewport width
     * viewH Viewport height
     */
    internal func render(viewW: Int32, viewH: Int32): Unit {
        if (!this._initialized) { return }
        if (!this._inFrame) {
            @LogError(["UiContext.render: called outside NewFrame/Render cycle"])
            return
        }
        // 在 bgfx 渲染线程上设置当前上下文（ImGui 上下文通过 TLS 存储）
        ImGui_SetCurrentContext_cj(this._ctx)
        // igRender 生成绘制数据
        ImGui_Render_cj()
        this._inFrame = false
        let viewId: UInt16 = 1u16 // ImGui 固定使用 view 1
        // 设置 view 1 视口
        bgfx_set_view_rect_cj(viewId, 0u16, 0u16, UInt16(viewW), UInt16(viewH))
        // 设置 view 1 clear（无清除，避免覆盖场景）
        bgfx_set_view_clear_cj(viewId, 0u16, 0x00000000u32, 1.0f32, 0u8)
        // touch view 1
        bgfx_touch_cj(viewId)
        // 执行 ImGui 绘制
        ImGui_Implbgfx_RenderDrawData_cj()
    }

    // ===== 事件输入方法（由 WindowEngine._applyEvent 调用） =====

    /**
     * @brief[zh-cn] 写入键盘事件
     * @param[zh-cn] scancode SDL 扫描码
     * key SDL 虚拟键码
     * mod 修饰键
     * down 按下/释放
     * repeat 是否重复
     *
     * @brief[en] Write a keyboard event
     * @param[en] scancode SDL scancode
     * key SDL keycode
     * mod modifier mask
     * down press/release
     * repeat whether repeat
     */
    internal func addKeyEvent(scancode: UInt32, key: UInt32, mod: UInt32, down: Bool, repeat: Bool): Unit {
        if (!this._initialized) { return }
        ImGui_SetCurrentContext_cj(this._ctx)
        let io = ImGui_GetIO_cj()
        if (io.isNull()) { return }
        // ImGui Key 映射：SDL scancode → ImGuiKey
        let imguiKey = this._mapSDLScancodeToImGuiKey(scancode)
        if (imguiKey >= 0) {
            unsafe { ImGuiIO_AddKeyEvent_cj(io, imguiKey, if (down) { 1 } else { 0 }) }
        }
    }

    /**
     * @brief[zh-cn] 写入鼠标移动事件
     * @param[zh-cn] x 窗口坐标 X
     * y 窗口坐标 Y
     *
     * @brief[en] Write a mouse motion event
     * @param[en] x Window X coordinate
     * y Window Y coordinate
     */
    internal func addMousePosEvent(x: Float32, y: Float32): Unit {
        if (!this._initialized) { return }
        ImGui_SetCurrentContext_cj(this._ctx)
        let io = ImGui_GetIO_cj()
        if (!io.isNull()) {
            unsafe { ImGuiIO_AddMousePosEvent_cj(io, x, y) }
        }
    }

    /**
     * @brief[zh-cn] 写入鼠标按钮事件
     * @param[zh-cn] button 按钮索引（0=左 1=右 2=中）
     * down 按下/释放
     *
     * @brief[en] Write a mouse button event
     * @param[en] button Button index (0=left, 1=right, 2=middle)
     * down press/release
     */
    internal func addMouseButtonEvent(button: Int32, down: Bool): Unit {
        if (!this._initialized) { return }
        ImGui_SetCurrentContext_cj(this._ctx)
        let io = ImGui_GetIO_cj()
        if (!io.isNull()) {
            unsafe { ImGuiIO_AddMouseButtonEvent_cj(io, button, if (down) { 1 } else { 0 }) }
        }
    }

    /**
     * @brief[zh-cn] 写入鼠标滚轮事件
     * @param[zh-cn] wheelX 水平滚动
     * wheelY 垂直滚动
     *
     * @brief[en] Write a mouse wheel event
     * @param[en] wheelX Horizontal scroll
     * wheelY Vertical scroll
     */
    internal func addMouseWheelEvent(wheelX: Float32, wheelY: Float32): Unit {
        if (!this._initialized) { return }
        ImGui_SetCurrentContext_cj(this._ctx)
        let io = ImGui_GetIO_cj()
        if (!io.isNull()) {
            unsafe { ImGuiIO_AddMouseWheelEvent_cj(io, wheelX, wheelY) }
        }
    }

    /**
     * @brief[zh-cn] 写入文本输入（SDL_EVENT_TEXT_INPUT）
     * @param[zh-cn] text UTF-8 文本
     *
     * @brief[en] Write text input (SDL_EVENT_TEXT_INPUT)
     * @param[en] text UTF-8 text
     */
    internal func addTextInput(text: String): Unit {
        if (!this._initialized) { return }
        if (text.isEmpty()) { return }
        ImGui_SetCurrentContext_cj(this._ctx)
        let io = ImGui_GetIO_cj()
        if (!io.isNull()) {
            unsafe {
                let cs = LibC.mallocCString(text)
                ImGuiIO_AddInputCharactersUTF8_cj(io, cs)
                LibC.free(cs)
            }
        }
    }

    // ===== SDL Scancode → ImGuiKey 映射 =====

    private func _mapSDLScancodeToImGuiKey(scancode: UInt32): Int32 {
        if (scancode == 0x2Au32 || scancode == 0x2Bu32) { return 0 } // A-Z
        if (scancode >= 0x04u32 && scancode <= 0x1du32) {
            return Int32(scancode - 0x04u32) + 27 // ImGuiKey_A = 27+
        }
        if (scancode == 0x2Cu32) { return 51 } // Space
        if (scancode == 0x28u32) { return 52 } // Enter
        if (scancode == 0x2Au32) { return 53 } // Backspace
        if (scancode == 0x2Bu32) { return 54 } // Tab
        return -1 // 未知键
    }
}
