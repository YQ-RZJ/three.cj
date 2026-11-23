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
 * @file[zh-cn] window_windowengine 窗口引擎的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 WindowEngine 绑定为 Lua 类型 three.window.WindowEngine
 * @explain[zh-cn] 绑定窗口生命周期（start/wait/requestClose/release）、帧时间与限帧、窗口状态查询、
 * 窗口操作（尺寸/位置/标题/显示隐藏/最大化最小化/全屏/无边框/透明度/置顶/焦点/模态/宽高比/
 * 鼠标与键盘捕获/光标）、DPI 与显示器查询、输入提供者管理与 Gui 上下文。
 * 适配约定：
 * - 元组返回值（位置/尺寸/宽高比）统一转为 Lua 数组 [a, b]；
 * - Option<SDL_Rect> 转为 [x, y, w, h] 数组，None → nil；
 * - UInt32/UIntNative 句柄值以整数返回；
 * - SystemCursor 参数接受整数（0~10），未知值回退 Default；
 * - bindOnInit/bindOnCtxtInit/bindOnFrame/bindOnClose/bindOnDestroy/bindOnResize 以
 *   函数属性暴露（只写：getter 返回 nil，与 SocketClient.listener 一致）；
 *   重新赋值会释放上一个 Lua 函数引用，release() 会释放本对象全部回调引用。
 * @attention[zh-cn] 回调在窗口泵线程执行。Lua 侧应在主线程阻塞于 wait()/Window.run()，
 * 由泵线程独占 Lua 状态；不要在另一线程并发操作同一 LuaVM。
 * 跳过成员及原因：
 * - onInit/onFrame/onClose/onDestroy/onResize（open 方法）：Lua 无法覆写绑定实例的虚方法，
 *   请改用对应的 bindOnXxx 函数属性；
 * - bindRenderer(execBgfx)：参数是高阶函数（接收仓颉闭包），无法映射为 Lua 函数；
 * - getSDLWindow/getSurface：返回 SDL 不透明句柄/结构，无 Lua 侧映射；
 * - getProvider<T>()：泛型方法无法由 Lua 指定类型参数，请用 getProviders() 后自行筛选。
 *
 * @file[en] window_windowengine  Lua binding of the window engine (three.script.prebind)
 * @brief[en] Binds WindowEngine as the Lua type three.window.WindowEngine
 * @explain[en] Binds the window lifecycle (start/wait/requestClose/release), frame timing and
 * frame cap, window state queries, window operations (size/position/title/show-hide/maximize-
 * minimize/fullscreen/borderless/opacity/always-on-top/focus/modal/aspect-ratio/mouse and
 * keyboard grab/cursor), DPI and display queries, input provider management and the Gui context.
 * Adaptation rules:
 * - tuple returns (position/size/aspect ratio) become Lua arrays [a, b];
 * - Option<SDL_Rect> becomes [x, y, w, h], None → nil;
 * - UInt32/UIntNative handle values are returned as integers;
 * - SystemCursor arguments accept integers (0~10), unknown values fall back to Default;
 * - bindOnInit/bindOnCtxtInit/bindOnFrame/bindOnClose/bindOnDestroy/bindOnResize are exposed as
 *   function properties (write-only: the getter returns nil, matching SocketClient.listener);
 *   reassignment releases the previous Lua function reference, and release() releases all
 *   callback references of this object.
 * @attention[en] Callbacks run on the window pump thread. On the Lua side, block the main thread
 * in wait()/Window.run() so the pump thread owns the Lua state; never touch the same LuaVM
 * concurrently from another thread.
 * Skipped members and reasons:
 * - onInit/onFrame/onClose/onDestroy/onResize (open methods): Lua cannot override virtual methods
 *   of a bound instance; use the matching bindOnXxx function properties instead;
 * - bindRenderer(execBgfx): the parameter is a higher-order function (takes a Cangjie closure)
 *   and cannot be mapped to a Lua function;
 * - getSDLWindow/getSurface: return SDL opaque handles/structs with no Lua-side mapping;
 * - getProvider<T>(): the generic method cannot take a Lua-supplied type parameter; use
 *   getProviders() and filter on the Lua side.
 */
package three.script.prebind

import std.collection.*
import sdl4cj.sdl.SDL_Rect
import three.window.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] WindowEngine 的 Lua 回调引用表（键 = 对象 id:回调名）
 *
 * @brief[en] Lua callback reference table for WindowEngine (key = object id:callback name)
 */
private let _prebindWindowCallbacks: HashMap<String, LuaCallback> = HashMap<String, LuaCallback>()

/**
 * @brief[zh-cn] 释放某个 WindowEngine 的全部回调引用
 * @param[zh-cn] id 对象注册表 id
 *
 * @brief[en] Releases every callback reference of a WindowEngine
 * @param[en] id The object registry id
 */
private func _prebindWindowReleaseCallbacks(id: Int64): Unit {
    for (hook in ["bindOnInit", "bindOnCtxtInit", "bindOnFrame", "bindOnClose", "bindOnDestroy", "bindOnResize"]) {
        if (let Some(old) <- _prebindWindowCallbacks.remove("${id}:${hook}")) {
            old.release()
        }
    }
}

/**
 * @brief[zh-cn] 替换一个 WindowEngine 回调（先释放旧回调引用）
 * @param[zh-cn] id 对象注册表 id
 * @param[zh-cn] hook 回调名
 * @param[zh-cn] vm 目标虚拟机
 * @param[zh-cn] v 新的 Lua 值（非函数/nil → 清除）
 * @return[zh-cn] 新的回调（清除时为 None）
 *
 * @brief[en] Replaces one WindowEngine callback (releasing the previous reference first)
 * @param[en] id The object registry id
 * @param[en] hook The callback name
 * @param[en] vm The target virtual machine
 * @param[en] v The new Lua value (non-function/nil clears it)
 * @return[en] The new callback (None when cleared)
 */
private func _prebindWindowReplaceCallback(id: Int64, hook: String, vm: LuaVM, v: LuaValue): Option<LuaCallback> {
    let key = "${id}:${hook}"
    if (let Some(old) <- _prebindWindowCallbacks.remove(key)) {
        old.release()
    }
    let cb = prebindOptCallbackOf(vm, v)
    if (let Some(c) <- cb) {
        _prebindWindowCallbacks.add(key, c)
    }
    cb
}

/**
 * @brief[zh-cn] 把 SDL_Rect 转为 Lua 数组 [x, y, w, h]
 * @param[zh-cn] r 矩形
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts an SDL_Rect into the Lua array [x, y, w, h]
 * @param[en] r The rectangle
 * @return[en] Lua array value
 */
private func _prebindRectToLua(r: SDL_Rect): LuaValue {
    LuaValue.Array([LuaValue.of(Int64(r.x)), LuaValue.of(Int64(r.y)), LuaValue.of(Int64(r.w)), LuaValue.of(Int64(r.h))])
}

/**
 * @brief[zh-cn] 由整数值解析 SystemCursor（未知值回退 Default）
 * @param[zh-cn] v 整数值（0~10）
 * @return[zh-cn] 对应的枚举值
 *
 * @brief[en] Resolves a SystemCursor from an integer (unknown values fall back to Default)
 * @param[en] v The integer value (0~10)
 * @return[en] The matching enum value
 */
private func _prebindSystemCursorOf(v: Int64): SystemCursor {
    match (v) {
        case 0 => SystemCursor.Default
        case 1 => SystemCursor.Text
        case 2 => SystemCursor.Wait
        case 3 => SystemCursor.Crosshair
        case 4 => SystemCursor.Hand
        case 5 => SystemCursor.SizeHor
        case 6 => SystemCursor.SizeVer
        case 7 => SystemCursor.SizeNwse
        case 8 => SystemCursor.SizeNesw
        case 9 => SystemCursor.SizeAll
        case 10 => SystemCursor.No
        case _ => SystemCursor.Default
    }
}

/**
 * @brief[zh-cn] 安装 WindowEngine 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.WindowEngine）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of WindowEngine
 * @param[en] vm The target virtual machine (class table installed at three.window.WindowEngine)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installWindowEngine(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.WindowEngine")
    b.constructor {_ => WindowEngine()}
    // ===== 帧时间 / 限帧 =====
    b.property("frameDeltaTime", getter: Some({ref => LuaValue.of(ref.cast<WindowEngine>().frameDeltaTime)}))
    b.property("elapsedTime", getter: Some({ref => LuaValue.of(ref.cast<WindowEngine>().elapsedTime)}))
    b.property("targetFrameRate", getter: Some({ref => LuaValue.of(ref.cast<WindowEngine>().targetFrameRate)}),
        setter: Some({ref, v => ref.cast<WindowEngine>().targetFrameRate = v.numberValue()}))
    // ===== 回调绑定（只写） =====
    b.property(
        "bindOnInit",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let engine = ref.cast<WindowEngine>()
                    match (_prebindWindowReplaceCallback(ref.id, "bindOnInit", vm, v)) {
                        case Some(cb) => engine.bindOnInit = Some({
                            => try {
                                let _ = cb.call()
                            } catch (_) {}
                        })
                        case None => engine.bindOnInit = None
                    }
            }
        )
    )
    b.property(
        "bindOnCtxtInit",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let engine = ref.cast<WindowEngine>()
                    match (_prebindWindowReplaceCallback(ref.id, "bindOnCtxtInit", vm, v)) {
                        case Some(cb) => engine.bindOnCtxtInit = Some({
                            => try {
                                let _ = cb.call()
                            } catch (_) {}
                        })
                        case None => engine.bindOnCtxtInit = None
                    }
            }
        )
    )
    b.property(
        "bindOnFrame",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let engine = ref.cast<WindowEngine>()
                    match (_prebindWindowReplaceCallback(ref.id, "bindOnFrame", vm, v)) {
                        case Some(cb) => engine.bindOnFrame = Some({
                            dt: Float64 => try {
                                let _ = cb.call(args: [LuaValue.of(dt)])
                            } catch (_) {}
                        })
                        case None => engine.bindOnFrame = None
                    }
            }
        )
    )
    b.property(
        "bindOnClose",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let engine = ref.cast<WindowEngine>()
                    match (_prebindWindowReplaceCallback(ref.id, "bindOnClose", vm, v)) {
                        case Some(cb) => engine.bindOnClose = Some({
                            => try {
                                let _ = cb.call()
                            } catch (_) {}
                        })
                        case None => engine.bindOnClose = None
                    }
            }
        )
    )
    b.property(
        "bindOnDestroy",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let engine = ref.cast<WindowEngine>()
                    match (_prebindWindowReplaceCallback(ref.id, "bindOnDestroy", vm, v)) {
                        case Some(cb) => engine.bindOnDestroy = Some({
                            => try {
                                let _ = cb.call()
                            } catch (_) {}
                        })
                        case None => engine.bindOnDestroy = None
                    }
            }
        )
    )
    b.property(
        "bindOnResize",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let engine = ref.cast<WindowEngine>()
                    match (_prebindWindowReplaceCallback(ref.id, "bindOnResize", vm, v)) {
                        case Some(cb) => engine.bindOnResize = Some({
                            w: Int32, h: Int32 => try {
                                let _ = cb.call(args: [LuaValue.of(Int64(w)), LuaValue.of(Int64(h))])
                            } catch (_) {}
                        })
                        case None => engine.bindOnResize = None
                    }
            }
        )
    )
    // ===== Gui =====
    b.method("useGui") {
        ref, _ =>
            ref.cast<WindowEngine>().useGui()
            []
    }
    b.property("gui", getter: Some({
        ref => match (ref.cast<WindowEngine>().gui) {
            case Some(ctx) => prebindRegister(ctx, "three.window.UiContext")
            case None => LuaValue.Nil
        }
    }))
    // ===== 输入提供者 =====
    b.method("addInputProvider") {
        ref, args =>
            ref.cast<WindowEngine>().addInputProvider(prebindAs<InputProvider>(args, 0))
            []
    }
    b.method("removeInputProvider") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().removeInputProvider(prebindAs<InputProvider>(args, 0)))]
    }
    b.method("getProviders") {
        ref, _ =>
            let items = ref.cast<WindowEngine>().getProviders()
            let n = items.size
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                let p = items[i]
                if (let Some(kp) <- (p as KeyboardProvider)) {
                    out[i] = prebindRegister(kp, "three.window.KeyboardProvider")
                } else if (let Some(mp) <- (p as MouseProvider)) {
                    out[i] = prebindRegister(mp, "three.window.MouseProvider")
                } else if (let Some(tp) <- (p as TouchProvider)) {
                    out[i] = prebindRegister(tp, "three.window.TouchProvider")
                } else if (let Some(gp) <- (p as GamepadProvider)) {
                    out[i] = prebindRegister(gp, "three.window.GamepadProvider")
                } else {
                    out[i] = prebindRegister(p, "three.window.InputProvider")
                }
            }
            [LuaValue.Array(out)]
    }
    // ===== 生命周期 =====
    b.method("start") {
        ref, args =>
            let engine = ref.cast<WindowEngine>()
            let title = prebindStr(args, 0)
            let w = Int32(prebindInt(args, 1))
            let h = Int32(prebindInt(args, 2))
            let cfg = if (args.size >= 4 && args[3].isObject) {
                prebindAsValue<WindowConfig>(args[3])
            } else {
                WindowConfig()
            }
            [LuaValue.of(engine.start(title: title, width: w, height: h, config: cfg))]
    }
    b.method("wait") {
        ref, _ =>
            ref.cast<WindowEngine>().wait()
            []
    }
    b.method("requestClose") {
        ref, _ =>
            ref.cast<WindowEngine>().requestClose()
            []
    }
    b.method("release") {
        ref, _ =>
            _prebindWindowReleaseCallbacks(ref.id)
            [LuaValue.of(ref.cast<WindowEngine>().release())]
    }
    b.property("initialized", getter: Some({ref => LuaValue.of(ref.cast<WindowEngine>().initialized)}))
    b.property("closeRequested", getter: Some({ref => LuaValue.of(ref.cast<WindowEngine>().closeRequested)}))
    b.method("isCloseRequested") {
        ref, _ => [LuaValue.of(ref.cast<WindowEngine>().isCloseRequested())]
    }
    // ===== 状态查询 =====
    b.method("getWidth") {ref, _ => [LuaValue.of(Int64(ref.cast<WindowEngine>().getWidth()))]}
    b.method("getHeight") {ref, _ => [LuaValue.of(Int64(ref.cast<WindowEngine>().getHeight()))]}
    b.method("getTitle") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().getTitle())]}
    b.method("getNativeWindowHandle") {
        ref, _ => [LuaValue.of(Int64(ref.cast<WindowEngine>().getNativeWindowHandle()))]
    }
    // ===== 窗口操作 =====
    b.method("updateSize") {
        ref, args =>
            ref.cast<WindowEngine>().updateSize(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
            []
    }
    b.method("setSize") {
        ref, args =>
            ref.cast<WindowEngine>().setSize(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
            []
    }
    b.method("setResizable") {
        ref, args =>
            ref.cast<WindowEngine>().setResizable(prebindBool(args, 0))
            []
    }
    b.method("setTitle") {
        ref, args =>
            ref.cast<WindowEngine>().setTitle(prebindStr(args, 0))
            []
    }
    b.method("show") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().show())]}
    b.method("hide") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().hide())]}
    b.method("raise") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().raise())]}
    b.method("maximize") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().maximize())]}
    b.method("minimize") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().minimize())]}
    b.method("restore") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().restore())]}
    b.method("setPosition") {
        ref, args => [LuaValue.of(
            ref.cast<WindowEngine>().setPosition(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1))))]
    }
    b.method("getPosition") {
        ref, _ =>
            let (x, y) = ref.cast<WindowEngine>().getPosition()
            [LuaValue.Array([LuaValue.of(Int64(x)), LuaValue.of(Int64(y))])]
    }
    b.method("getDrawableSize") {
        ref, _ =>
            let (w, h) = ref.cast<WindowEngine>().getDrawableSize()
            [LuaValue.Array([LuaValue.of(Int64(w)), LuaValue.of(Int64(h))])]
    }
    b.method("setMinimumSize") {
        ref, args => [LuaValue.of(
            ref.cast<WindowEngine>().setMinimumSize(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1))))]
    }
    b.method("getMinimumSize") {
        ref, _ =>
            let (w, h) = ref.cast<WindowEngine>().getMinimumSize()
            [LuaValue.Array([LuaValue.of(Int64(w)), LuaValue.of(Int64(h))])]
    }
    b.method("setMaximumSize") {
        ref, args => [LuaValue.of(
            ref.cast<WindowEngine>().setMaximumSize(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1))))]
    }
    b.method("getMaximumSize") {
        ref, _ =>
            let (w, h) = ref.cast<WindowEngine>().getMaximumSize()
            [LuaValue.Array([LuaValue.of(Int64(w)), LuaValue.of(Int64(h))])]
    }
    b.method("setFullscreen") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setFullscreen(prebindBool(args, 0)))]
    }
    b.method("setBordered") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setBordered(prebindBool(args, 0)))]
    }
    b.method("setOpacity") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setOpacity(Float32(prebindNum(args, 0))))]
    }
    b.method("getOpacity") {
        ref, _ => [LuaValue.of(Float64(ref.cast<WindowEngine>().getOpacity()))]
    }
    b.method("setAlwaysOnTop") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setAlwaysOnTop(prebindBool(args, 0)))]
    }
    b.method("setFocusable") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setFocusable(prebindBool(args, 0)))]
    }
    b.method("setModal") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setModal(prebindBool(args, 0)))]
    }
    b.method("setAspectRatio") {
        ref, args => [LuaValue.of(
            ref.cast<WindowEngine>().setAspectRatio(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1))))]
    }
    b.method("getAspectRatio") {
        ref, _ =>
            let (mn, mx) = ref.cast<WindowEngine>().getAspectRatio()
            [LuaValue.Array([LuaValue.of(Float64(mn)), LuaValue.of(Float64(mx))])]
    }
    b.method("setMouseGrab") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setMouseGrab(prebindBool(args, 0)))]
    }
    b.method("getMouseGrab") {
        ref, _ => [LuaValue.of(ref.cast<WindowEngine>().getMouseGrab())]
    }
    b.method("setKeyboardGrab") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setKeyboardGrab(prebindBool(args, 0)))]
    }
    b.method("getKeyboardGrab") {
        ref, _ => [LuaValue.of(ref.cast<WindowEngine>().getKeyboardGrab())]
    }
    // ===== DPI / 显示器 =====
    b.method("getPixelDensity") {
        ref, _ => [LuaValue.of(Float64(ref.cast<WindowEngine>().getPixelDensity()))]
    }
    b.method("getDisplayScale") {
        ref, _ => [LuaValue.of(Float64(ref.cast<WindowEngine>().getDisplayScale()))]
    }
    b.method("getPixelRatio") {
        ref, _ => [LuaValue.of(Float64(ref.cast<WindowEngine>().getPixelRatio()))]
    }
    b.method("setDpiAutoDetect") {
        ref, args =>
            ref.cast<WindowEngine>().setDpiAutoDetect(prebindBool(args, 0))
            []
    }
    b.method("setDpiScale") {
        ref, args =>
            ref.cast<WindowEngine>().setDpiScale(prebindNum(args, 0))
            []
    }
    b.method("getDpiScale") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().getDpiScale())]}
    b.method("getPixelFormat") {
        ref, _ => [LuaValue.of(Int64(ref.cast<WindowEngine>().getPixelFormat()))]
    }
    b.method("getSafeArea") {
        ref, _ => match (ref.cast<WindowEngine>().getSafeArea()) {
            case Some(r) => [_prebindRectToLua(r)]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getDisplays") {
        ref, _ => [prebindU32ListToLua(ref.cast<WindowEngine>().getDisplays())]
    }
    b.method("getPrimaryDisplay") {
        ref, _ => [LuaValue.of(Int64(ref.cast<WindowEngine>().getPrimaryDisplay()))]
    }
    b.method("getDisplayBounds") {
        ref, args => match (ref.cast<WindowEngine>().getDisplayBounds(UInt32(prebindInt(args, 0) & 0xFFFFFFFF))) {
            case Some(r) => [_prebindRectToLua(r)]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getDisplayName") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().getDisplayName(UInt32(prebindInt(args, 0) & 0xFFFFFFFF)))]
    }
    // ===== 光标 / 鼠标 =====
    b.method("setSystemCursor") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setSystemCursor(_prebindSystemCursorOf(prebindInt(args, 0))))]
    }
    b.method("showCursor") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().showCursor())]}
    b.method("hideCursor") {ref, _ => [LuaValue.of(ref.cast<WindowEngine>().hideCursor())]}
    b.method("isCursorVisible") {
        ref, _ => [LuaValue.of(ref.cast<WindowEngine>().isCursorVisible())]
    }
    b.method("warpMouseInWindow") {
        ref, args =>
            ref.cast<WindowEngine>().warpMouseInWindow(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)))
            []
    }
    b.method("setRelativeMouseMode") {
        ref, args => [LuaValue.of(ref.cast<WindowEngine>().setRelativeMouseMode(prebindBool(args, 0)))]
    }
    b.method("getRelativeMouseMode") {
        ref, _ => [LuaValue.of(ref.cast<WindowEngine>().getRelativeMouseMode())]
    }
    b.install(vm)
}
