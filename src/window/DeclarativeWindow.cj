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
 * @file[zh-cn] DeclarativeWindow.cj — 声明式窗口 Window{}（组合 WindowEngine 的门面）
 * @brief[zh-cn] 在 WindowEngine（继承式窗口能力）之上提供能力幂等的声明式窗口
 * @explain[zh-cn] Window 不是 WindowEngine 的子类，而是组合一个内部 WindowEngine 实例：
 * 构造即声明（尾随闭包 builder），所有生命周期/输入/渲染通过链式 builder 声明；
 * show/wait/close 全部幂等（重复调用无副作用）。
 * 与继承式用法的对照：
 *   // 继承式（WindowEngine）
 *   class MyWindow <: WindowEngine { ... override func onFrame(dt) { ... } }
 *   let win = MyWindow(); win.start(title: "Hello", width: 800, height: 600); win.wait()
 *   // 声明式（Window）
 *   Window("Hello", 800, 600) { w =>
 *       w.renderWith(renderer)                       // 可选：绑定渲染器（自动 initBgfx/setSize/release）
 *       w.onFrame { dt => if (w.isCloseRequested()) { w.close() } }  // 可选：帧回调（可多次声明）
 *       w.ui { => UiText("Hello").draw() }           // 可选：UI 声明体（每帧自动执行）
 *   }.run()                                          // show + wait，一步到位
 * 能力映射（声明式 → WindowEngine）：
 *   renderWith(r)    → useGui（如声明了 ui）+ bindRenderer(r.execBgfx)
 *                      + onInit 自动 r.initBgfx(nwh, w, h)
 *                      + onResize 自动 r.setSize(w, h)
 *                      + onClose 自动 r.release()
 *   ui { ... }       → useGui + 每帧 newFrame 后、render 前执行声明体
 *                      （配合 three.window.ui 的 UiText/UiButton 等声明式控件）
 *   onInit/onFrame/onClose/onDestroy/onResize → 对应 bindXxx lambda（可多次声明，按序执行）
 *   show/wait/close/run → start/wait/requestClose（幂等包装）
 *
 * @file[en] DeclarativeWindow.cj — Declarative Window{} (facade composing WindowEngine)
 * @brief[en] A capability-idempotent declarative window on top of WindowEngine
 * @explain[en] Window is not a WindowEngine subclass; it composes an internal WindowEngine
 * instance: construction is declaration (trailing-closure builder), lifecycle/input/rendering
 * are declared via chained builders, and show/wait/close are idempotent (repeated calls are
 * no-ops). See the zh-cn doc block for the inheritance-vs-declarative usage comparison and
 * the capability mapping (renderWith/ui/onXxx/show/run).
 */
package three.window

import std.core.*
import std.collection.ArrayList
import three.rendering.ThreeRenderer
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.safe.IReleasable

/**
 * @brief[zh-cn] 声明式窗口（组合 WindowEngine 的门面）
 * @explain[zh-cn] 用法见文件头注释。构造闭包内声明配置与回调；show()/run() 启动窗口泵；
 * show/wait/close 幂等。ui{} 声明体在每帧（ImGui NewFrame 之后、Render 之前）执行，
 * 内部使用 three.window.ui 的声明式控件；需要渲染器提供 bgfx 提交通道（renderWith）。
 *
 * @brief[en] Declarative window (facade composing WindowEngine)
 * @explain[en] See the file header for usage. Declare config and callbacks inside the
 * constructor closure; show()/run() start the window pump; show/wait/close are idempotent.
 * The ui{} body runs every frame (after ImGui NewFrame, before Render) and hosts the
 * declarative widgets of three.window.ui; it needs a renderer bound via renderWith() to
 * provide the bgfx submit channel.
 */
public class Window <: IReleasable {
    /// 内部组合的窗口引擎（能力全部委托给它）
    private let _engine: WindowEngine = WindowEngine()
    /// 窗口配置（show() 时透传给 start）
    private var _config: WindowConfig = WindowConfig()

    // ===== 声明收集（builder 期间填充，show() 时组合进引擎） =====
    private var _renderer: Option<ThreeRenderer> = None
    private var _uiBody: Option<() -> Unit> = None
    private var _onInit: ArrayList<() -> Unit> = ArrayList<() -> Unit>()
    private var _onCtxtInit: ArrayList<() -> Unit> = ArrayList<() -> Unit>()
    private var _onFrame: ArrayList<(Float64) -> Unit> = ArrayList<(Float64) -> Unit>()
    private var _onResize: ArrayList<(Int32, Int32) -> Unit> = ArrayList<(Int32, Int32) -> Unit>()
    private var _onClose: ArrayList<() -> Unit> = ArrayList<() -> Unit>()
    private var _onDestroy: ArrayList<() -> Unit> = ArrayList<() -> Unit>()

    // ===== 幂等标记 =====
    /// show() 是否已执行（防重复启动）
    private var _shown: Bool = false
    /// wait() 是否已执行（防重复 join）
    private var _joined: Bool = false
    /// close() 是否已请求（防重复置位；本身亦幂等，这里仅用于返回值语义）
    private var _closeRequested: Bool = false

    /**
     * @brief[zh-cn] 声明式构造：参数 + 尾随闭包一步完成
     * @param[zh-cn] title 窗口标题
     * width 窗口宽度（逻辑像素）
     * height 窗口高度（逻辑像素）
     * config 窗口创建配置（默认 WindowConfig()）
     * build 声明闭包（在构造时立即执行，此时窗口尚未创建）
     *
     * @brief[en] Declarative construction: parameters + trailing closure in one step
     * @param[en] title Window title
     * width Window width (logical pixels)
     * height Window height (logical pixels)
     * config Window creation config (default WindowConfig())
     * build Declaration closure (executed immediately at construction, before the window exists)
     */
    public init(title!: String, width!: Int32, height!: Int32,
                config!: WindowConfig = WindowConfig(), build!: (Window) -> Unit) {
        this._config = config
        // 先声明标题/尺寸（供 build 闭包内读取），再执行声明闭包
        build(this)
        this._declaredTitle = title
        this._declaredWidth = width
        this._declaredHeight = height
    }

    /// 声明的标题/尺寸（init 中暂存，show() 时透传给 start）
    private var _declaredTitle: String = ""
    private var _declaredWidth: Int32 = 0
    private var _declaredHeight: Int32 = 0

    // =========================================================================
    // 声明式 Builder（链式，构造闭包内调用）
    // =========================================================================

    /**
     * @brief[zh-cn] 绑定渲染器（可选）
     * @explain[zh-cn] 声明后自动完成：show 时 bindRenderer(execBgfx)；onInit 时 initBgfx
     * （原生句柄 + 当前尺寸）；onResize 时 setSize；onClose 时 release。
     * 声明了 ui{} 而未绑定渲染器时，ui 声明体无法渲染（告警并跳过）。
     *
     * @brief[en] Binds the renderer (optional)
     * @explain[en] Declaring this automates: bindRenderer(execBgfx) at show; initBgfx
     * (native handle + current size) in onInit; setSize in onResize; release in onClose.
     * If ui{} is declared without a renderer, the ui body cannot render (warned and skipped).
     */
    public func renderWith(renderer: ThreeRenderer): Window {
        this._renderer = Some(renderer)
        return this
    }

    /**
     * @brief[zh-cn] 声明 UI 体（每帧自动执行）
     * @explain[zh-cn] 内部使用 three.window.ui 的声明式控件：
     *   w.ui { =>
     *       UiText("Hello").draw()
     *       if (UiButton("OK").draw()) { ... }
     *   }
     * 执行时机：每帧 ImGui NewFrame 之后、Render 之前（与 onFrame 同线程、同快照）。
     * 需要绑定渲染器（renderWith）以提供 bgfx 提交通道。可多次声明（按序执行）。
     *
     * @brief[en] Declares the UI body (executed every frame)
     * @explain[en] Hosts the declarative widgets of three.window.ui:
     *   w.ui { => UiText("Hello").draw() ... }
     * Timing: every frame after ImGui NewFrame and before Render (same thread and
     * snapshot as onFrame). Requires a renderer (renderWith) for the bgfx submit
     * channel. May be declared multiple times (executed in order).
     */
    public func ui(body: () -> Unit): Window {
        this._uiBody = Some(body)
        return this
    }

    /**
     * @brief[zh-cn] 声明窗口创建后回调（可多次声明，按序执行）
     *
     * @brief[en] Declares the post-creation callback (may be declared multiple times, run in order)
     */
    public func onInit(handler: () -> Unit): Window {
        this._onInit.add(handler)
        return this
    }

    /**
     * @brief[zh-cn] 声明 Gui 上下文初始化完成后的回调（可多次声明，按序执行）
     * @explain[zh-cn] 触发时机：ctx.initialize() 之后、首个 NewFrame 之前——字体加载、
     *             图集定制等 ImGui 初始化依赖的正确时机（onInit 阶段 ImGui 上下文尚不存在，
     *             此时调用 ImGui GetIO/字体 API 会访问无效上下文）。
     *
     * @brief[en] Declares the post-Gui-init callback (may be declared multiple times, run in order)
     * @explain[en] Fired after ctx.initialize() and before the first NewFrame — the correct
     *             timing for font loading and atlas customization (the ImGui context does
     *             not exist during onInit; ImGui GetIO/font APIs there hit an invalid context).
     */
    public func onCtxtInit(handler: () -> Unit): Window {
        this._onCtxtInit.add(handler)
        return this
    }

    /**
     * @brief[zh-cn] 声明帧回调（可多次声明，按序执行；每帧以真实 dt 调用）
     *
     * @brief[en] Declares a frame callback (may be declared multiple times, run in order; called with real dt each frame)
     */
    public func onFrame(handler: (Float64) -> Unit): Window {
        this._onFrame.add(handler)
        return this
    }

    /**
     * @brief[zh-cn] 声明尺寸变化回调（可多次声明，按序执行；拖拽缩放每帧最多一次）
     *
     * @brief[en] Declares a resize callback (may be declared multiple times, run in order; at most once per frame during interactive resizing)
     */
    public func onResize(handler: (Int32, Int32) -> Unit): Window {
        this._onResize.add(handler)
        return this
    }

    /**
     * @brief[zh-cn] 声明关闭前回调（可多次声明，按序执行；在渲染器 release 之前）
     *
     * @brief[en] Declares the pre-close callback (may be declared multiple times, run in order; before the renderer release)
     */
    public func onClose(handler: () -> Unit): Window {
        this._onClose.add(handler)
        return this
    }

    /**
     * @brief[zh-cn] 声明销毁后回调（可多次声明，按序执行）
     *
     * @brief[en] Declares the post-destroy callback (may be declared multiple times, run in order)
     */
    public func onDestroy(handler: () -> Unit): Window {
        this._onDestroy.add(handler)
        return this
    }

    // =========================================================================
    // 生命周期（幂等）
    // =========================================================================

    /**
     * @brief[zh-cn] 启动窗口（幂等：已启动时直接返回 true）
     * @explain[zh-cn] 将声明组合进内部 WindowEngine（renderer/ui/各回调 → bindXxx），
     * 然后调用 start() 创建窗口并启动泵线程。异步返回，须随后 wait() 保持主线程存活。
     *
     * @brief[en] Starts the window (idempotent: returns true immediately if already started)
     * @explain[en] Composes the declarations into the internal WindowEngine
     * (renderer/ui/callbacks → bindXxx) and calls start() to create the window and start
     * the pump thread. Returns asynchronously; call wait() afterwards to keep the main
     * thread alive.
     */
    public func show(): Bool {
        if (this._shown) { return true }
        this._shown = true
        let engine = this._engine
        // ---- 渲染器绑定（泵线程启动前完成 execBgfx 注入） ----
        if (let Some(r) <- this._renderer) {
            engine.bindRenderer({ cmd => r.execBgfx(cmd) })
        }
        // ---- 声明 ui 体：启用 Gui（需要渲染器提供 bgfx 通道） ----
        let uiBody = this._uiBody
        if (uiBody.isSome()) {
            if (this._renderer.isSome()) {
                engine.useGui()
            } else {
                @LogWarn(["Window.ui: declared ui body but no renderer bound (call renderWith); ui will not render"])
            }
        }
        // ---- 组合生命周期回调 ----
        engine.bindOnInit = Some({ =>
            if (let Some(r) <- this._renderer) {
                // pixelRatio 须在 initBgfx 之前设置（initBgfx 按它把逻辑尺寸换算为物理后备缓冲尺寸）
                r.setPixelRatio(Float64(engine.getPixelRatio()))
                if (!r.initBgfx(engine.getNativeWindowHandle(), engine.getWidth(), engine.getHeight())) {
                    @LogError(["Window: renderer.initBgfx FAILED"])
                }
                r.setSize(engine.getWidth(), engine.getHeight())
            }
            for (f in this._onInit) { f() }
        })
        engine.bindOnFrame = Some({ dt =>
            for (f in this._onFrame) { f(dt) }
            // ui 声明体：引擎已在本帧 newFrame（3a），render hook 在 onFrame 之后（3b）——
            // 此处正处 NewFrame..Render 之间，是控件声明的合法区间
            if (let Some(body) <- uiBody) {
                if (let Some(ctx) <- engine.gui) {
                    if (ctx.initialized) {
                        body()
                    }
                }
            }
        })
        engine.bindOnResize = Some({ w, h =>
            if (let Some(r) <- this._renderer) {
                // 窗口拖到不同缩放率的显示器时 DPI 会变化，先刷新 pixelRatio 再重建后备缓冲
                r.setPixelRatio(Float64(engine.getPixelRatio()))
                r.setSize(w, h)
            }
            for (f in this._onResize) { f(w, h) }
        })
        engine.bindOnClose = Some({ =>
            for (f in this._onClose) { f() }
            // 渲染器释放放在用户 onClose 之后（用户可能还要提交最后一帧清理）
            if (let Some(r) <- this._renderer) {
                r.release()
            }
        })
        engine.bindOnDestroy = Some({ =>
            for (f in this._onDestroy) { f() }
        })
        // Gui 上下文初始化完成后按序执行（引擎在 ctx.initialize 后、首个 NewFrame 前触发）
        if (!this._onCtxtInit.isEmpty()) {
            engine.bindOnCtxtInit = Some({ =>
                for (f in this._onCtxtInit) { f() }
            })
        }
        return engine.start(title: this._declaredTitle, width: this._declaredWidth,
                            height: this._declaredHeight, config: this._config)
    }

    /**
     * @brief[zh-cn] 阻塞等待窗口关闭（幂等：重复调用直接返回）
     * @note[zh-cn] 主线程必须调用（否则 main 退出会杀死 spawn 泵线程）。
     *
     * @brief[en] Blocks until the window closes (idempotent: repeated calls return immediately)
     * @note[en] Must be called on the main thread (otherwise main exiting kills the spawn pump thread).
     */
    public func wait(): Unit {
        if (this._joined) { return }
        this._joined = true
        this._engine.wait()
    }

    /**
     * @brief[zh-cn] 请求关闭窗口（幂等；异步，等价于用户点关闭按钮）
     *
     * @brief[en] Requests the window to close (idempotent; async; equivalent to the user clicking close)
     */
    public func close(): Unit {
        if (this._closeRequested) { return }
        this._closeRequested = true
        this._engine.requestClose()
    }

    /**
     * @brief[zh-cn] 便捷一步启动：show() + wait()（幂等）
     *
     * @brief[en] One-step convenience: show() + wait() (idempotent)
     */
    public func run(): Unit {
        if (!this.show()) { return }
        this.wait()
    }

    /**
     * @brief[zh-cn] IReleasable：请求关闭并等待泵线程结束（幂等）
     *
     * @brief[en] IReleasable: request close and join the pump thread (idempotent)
     */
    public func release(): Bool {
        this.close()
        this.wait()
        return true
    }

    // =========================================================================
    // 状态查询 / 引擎透传
    // =========================================================================

    /**
     * @brief[zh-cn] 窗口是否已启动（show 成功后为 true）
     *
     * @brief[en] Whether the window has been started (true after a successful show)
     */
    public prop started: Bool {
        get() { this._shown && this._engine.initialized }
    }

    /**
     * @brief[zh-cn] 是否已请求关闭（读固定快照）
     *
     * @brief[en] Whether a close has been requested (reads the fixed snapshot)
     */
    public prop isCloseRequested: Bool {
        get() { this._engine.closeRequested }
    }

    /**
     * @brief[zh-cn] 窗口宽度（逻辑像素）
     *
     * @brief[en] Window width (logical pixels)
     */
    public prop width: Int32 {
        get() { this._engine.getWidth() }
    }

    /**
     * @brief[zh-cn] 窗口高度（逻辑像素）
     *
     * @brief[en] Window height (logical pixels)
     */
    public prop height: Int32 {
        get() { this._engine.getHeight() }
    }

    /**
     * @brief[zh-cn] 获取内部 WindowEngine（高级用法：输入 Provider、窗口操作 API、
     * targetFrameRate 等完整能力；声明式未覆盖的能力经此透传）
     *
     * @brief[en] Gets the internal WindowEngine (advanced use: input providers, window
     * operation APIs, targetFrameRate, etc.; capabilities not covered by the declarative
     * API pass through here)
     */
    public func getEngine(): WindowEngine {
        return this._engine
    }
}
