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
 * @file[zh-cn] WindowEngine 窗口引擎 v2：全局事件分发器 + 每窗口独立事件队列 + 生命周期回调
 * @brief[zh-cn] 窗口引擎 v2：全局事件分发器 + 每窗口独立事件队列 + 生命周期回调（对齐 RGF 窗口模式）
 * @explain[zh-cn] 线程模型（v2，重写自 v1 的"单 SThread + _execWindow 序列化 + 互斥锁输入状态"）：
 * - SDL3 线程安全结论（逐函数标注）：SDL_PollEvent/窗口创建/销毁/窗口操作只能在
 * "初始化 video 子系统的线程"（主线程语义）调用；且仓颉主线程本身也是用户态线程
 * （M:N 模型，可能在系统线程间迁移），不能承载这些 API。
 * - 因此 v2 采用混合线程架构："SDL 主线程 API 全程固定一个 SThread；纯逻辑用 spawn"：
 * * SDLDispatcher（全局单例）：持有一个固定 SThread（系统线程）承载全部 SDL 调用——
 * SDL_Init / SDL_PollEvent 事件泵（本线程即"初始化线程"）、窗口创建/销毁/窗口操作
 * 命令（外部经 execSDL() 同步提交，对齐 ThreeRenderer._execBgfx 模式）；
 * 事件按 windowID 推入各窗口独立事件队列，多窗口互不抢占；
 * * 每个 WindowEngine 实例（窗口类）启动一个 spawn 用户态线程泵：从自己的队列取事件 →
 * 构建本循环固定快照（InputSnapshot）→ 调用生命周期回调（onFrame 读快照）→ 循环末重置；
 * 泵线程只读队列/构建快照/调用户回调，不直接调用任何 SDL 窗口 API（需要时经 execSDL 转发）；
 * * 注意：主线程退出会杀死未完成的 spawn 线程，故主线程须 wait() 保持存活。
 * * 锁几乎不需要：每窗口队列独立，仅分发器写入 vs 窗口泵读取需一个并发队列同步。
 * - 生命周期回调（窗口泵线程主循环调用，open 可覆写 / bindXxx lambda 绑定优先于覆写）：
 * onInit() → 循环 { onFrame(dt) } → onClose() → onDestroy()
 * 典型用法（继承覆写，RGF 模式）：
 * class MyWindow <: WindowEngine {
 * var renderer: ThreeRenderer
 * override func onInit() {
 * renderer = ThreeRenderer()
 * renderer.initBgfx(this.getNativeWindowHandle(), this.getWidth(), this.getHeight())
 * }
 * override func onFrame(dt: Float64) {
 * if (this.isKeyDown(KeyCode.ESCAPE)) { this.requestClose() }
 * renderer.render(scene, camera)
 * }
 * override func onClose() { renderer.shutdown() }
 * }
 * let win = MyWindow()
 * if (win.start(title: "Hello", width: 800, height: 600)) { win.wait() }
 * 或 lambda 绑定（bindOnFrame 优先于覆写 onFrame）：
 * let win = WindowEngine()
 * win.bindOnFrame = Some({ dt => ... })
 * win.start(title: "Hello", width: 800, height: 600)
 * win.wait()
 * 每循环固定事件快照（解决 v1 的"中途清理"问题）：
 * - 本循环内任何时刻读取一致（读快照，不再有读后清 / beginFrame 清 / 互斥锁）；
 * - 边沿状态（pressed/released）与位移/滚轮累积在循环末自动重置。
 * 跨平台原生窗口句柄：通过 SDL 窗口属性（SDL_PROP_WINDOW_*）获取，
 * 供渲染引擎（ThreeRenderer.initBgfx(hwnd, w, h)）绑定窗口。
 * . Each loop uses a fixed event snapshot: reads are consistent at any
 * moment within a frame (no read-then-clear / beginFrame-clear / mutex), and edge
 * states (pressed/released) plus motion/wheel deltas reset automatically at loop end.
 * The cross-platform native window handle is obtained via SDL window properties
 * (SDL_PROP_WINDOW_*), for binding the window to a renderer
 * (ThreeRenderer.initBgfx(hwnd, w, h)).
 *
 * @file[en] WindowEngine  Window engine v2: global event dispatcher + per-window independent event queues + lifecycle callbacks
 * @brief[en] Window engine v2: a global event dispatcher, per-window event queues and
 * lifecycle callbacks (aligned with the RGF window model)
 * @explain[en] Threading model (v2, rewritten from v1's "single SThread + _execWindow
 * serialization + mutex-protected input state"):
 * - SDL3 thread-safety: SDL_PollEvent / window create, destroy and window operations
 * may only run on the thread that initialized the video subsystem; the Cangjie main
 * thread is itself a user-space thread (M:N model) that may migrate across system
 * threads, so it cannot host these APIs.
 * - v2 uses a hybrid architecture: "all SDL main-thread APIs run on a single fixed
 * SThread; pure logic uses spawn".
 * * SDLDispatcher (global singleton) hosts all SDL calls on one fixed SThread
 * (system thread): SDL_Init, the SDL_PollEvent pump (this thread is the
 * "initialization thread"), and window create/destroy/operation commands
 * submitted synchronously via execSDL() (mirroring ThreeRenderer._execBgfx);
 * events are pushed into each window's own queue by windowID.
 * * Each WindowEngine (window class) starts a spawned user-space pump thread that
 * drains its own queue, builds a fixed per-frame InputSnapshot, invokes lifecycle
 * callbacks (onFrame reads the snapshot) and resets at the end of the loop; it
 * never calls SDL window APIs directly (it forwards through execSDL).
 * * Note: exiting the main thread kills unfinished spawn threads, so the main
 * thread must call wait() to stay alive.
 * * Locks are barely needed: each window queue is independent; only the
 * dispatcher-writes vs window-pump-reads boundary needs one concurrent queue.
 * - Lifecycle callbacks (called by the window pump loop; open overridable, and a
 * bindXxx lambda binding takes precedence over the override):
 * onInit() -> loop { onFrame(dt) } -> onClose() -> onDestroy()
 * Typical usage (inherit & override) and alternative lambda binding are described in
 */
package three.window

import std.core.*
import std.collection.*
import std.collection.concurrent.{ ConcurrentHashMap, ConcurrentLinkedQueue }
import std.sync.{ AtomicBool, AtomicInt64 }
import std.time.*
import sdl4cj.sdl.*
import three.core.thread.{ Mutex, Condition, SThread }
import three.utils.log.*
import three.utils.log.macros.*

// =============================================================================
// 轻量分发事件（分发器 → 窗口队列）
// =============================================================================

/**
 * @brief[zh-cn] 分发器投递给窗口队列的轻量事件
 * @explain[zh-cn] 避免拷贝 128 字节的 SDL_Event union，仅携带窗口泵构建快照所需的字段；
 * 字段按事件类型复用。
 *
 * @brief[en] Lightweight event dispatched to window queues
 * @explain[en] Avoids copying the 128-byte SDL_Event union; carries only the fields
 * needed by the window pump to build a snapshot. Fields are reused by event type.
 */
public struct DispatchEvent {
    /// 事件类型（SDL_EVENT_*）
    var `type`: UInt32 = 0
    /// 关联窗口 ID
    var windowID: UInt32 = 0
    /// 通用字段 1（键盘=scancode / 鼠标=x / 窗口=data1 / 滚轮=x）
    var f1: Float32 = 0.0
    /// 通用字段 2（键盘=key / 鼠标=y / 窗口=data2 / 滚轮=y）
    var f2: Float32 = 0.0
    /// 通用字段 3（鼠标=xrel / 滚轮=preciseX）
    var f3: Float32 = 0.0
    /// 通用字段 4（鼠标=yrel / 滚轮=preciseY）
    var f4: Float32 = 0.0
    /// 通用字段 5（键盘=mod 修饰键）
    var f5: Float32 = 0.0
    /// 通用布尔 1（键盘=down / 鼠标按钮=down）
    var b1: Bool = false
    /// 通用布尔 2（键盘=repeat）
    var b2: Bool = false
    /// 文本输入内容（SDL_EVENT_TEXT_INPUT，UTF-8）
    var text: String = ""

    /// 构造分发事件（各字段按事件类型复用，未用字段保持默认值）。
    internal init(`type`!: UInt32, windowID!: UInt32,
                  f1!: Float32 = 0.0, f2!: Float32 = 0.0,
                  f3!: Float32 = 0.0, f4!: Float32 = 0.0, f5!: Float32 = 0.0,
                  b1!: Bool = false, b2!: Bool = false,
                  text!: String = "") {
        this.`type` = `type`
        this.windowID = windowID
        this.f1 = f1
        this.f2 = f2
        this.f3 = f3
        this.f4 = f4
        this.f5 = f5
        this.b1 = b1
        this.b2 = b2
        this.text = text
    }
}

// =============================================================================
// 全局事件分发器（固定 SThread：SDL_Init/PollEvent/窗口命令 → 按 windowID 推入各窗口队列）
// =============================================================================

/**
 * @brief[zh-cn] 全局事件分发器
 * @explain[zh-cn] 职责：持有全局唯一的 SDL 事件泵（SDL_PollEvent），将每个事件按 windowID
 * 推入对应 WindowEngine 的独立事件队列。多窗口共享此分发器，事件互不抢占
 * （各窗口泵只读自己的队列）。
 * 线程模型（对齐 ThreeRenderer._execBgfx）：
 * - SDL3 要求 SDL_PollEvent/窗口创建/销毁/窗口操作只能在"初始化 video 子系统
 * 的线程"调用；而仓颉用户态线程（spawn，M:N）可能在系统线程间迁移，不能承载
 * 这些 API。故本类持有一个固定 SThread（系统线程）承载全部 SDL 调用：
 * * SDL_Init / SDL_PollEvent 事件泵（本线程即"初始化线程"）；
 * * 窗口创建/销毁/窗口操作命令——外部经 execSDL() 提交，在本线程同步执行；
 * - 每窗口泵线程（spawn 用户态线程）只读自己的事件队列、构建快照、调 onFrame，
 * 不直接调用任何 SDL 窗口 API（需要时经 execSDL 转发）。
 * 生命周期：首个窗口启动时 ensureStarted()（内部 SDL_Init），末个窗口注销时停止
 * （内部 SDL_Quit）。引用计数保护。
 *
 * @brief[en] Global event dispatcher
 * @explain[en] Responsibility: owns the single global SDL event pump (SDL_PollEvent) and pushes
 * each event, by windowID, into the corresponding WindowEngine's independent event queue.
 * Multiple windows share this dispatcher and events never preempt each other
 * (each window pump only reads its own queue).
 * Threading model (aligned with ThreeRenderer._execBgfx):
 * - SDL3 requires SDL_PollEvent / window create, destroy and window operations to be called
 * on the thread that initialized the video subsystem, while Cangjie user-space threads
 * (spawn, M:N) may migrate across system threads and cannot host these APIs. Therefore this
 * class holds one fixed SThread (system thread) that carries all SDL calls:
 * * the SDL_Init / SDL_PollEvent event pump (this thread is the "initialization thread");
 * * window create/destroy/operation commands, submitted externally via execSDL() and
 * executed synchronously on this thread;
 * - Each per-window pump thread (spawn user-space thread) only reads its own event queue,
 * builds a snapshot and calls onFrame; it never calls SDL window APIs directly
 * (forwarded through execSDL when needed).
 * Lifecycle: ensureStarted() on the first window (internally SDL_Init), stopped when the
 * last window unregisters (internally SDL_Quit). Protected by reference counting.
 */
internal class SDLDispatcher {
    /// 窗口注册表：windowID → 事件队列
    private static let _registry = ConcurrentHashMap<UInt32, ConcurrentLinkedQueue<DispatchEvent>>()
    /// 引用计数（已注册窗口数）
    private static let _refCount = AtomicInt64(0)
    /// 缓存：SDL 线程分发事件时直接用此引用，避免在 SDL 外来线程上
    /// 调 ConcurrentHashMap.get（该调用会触发 GetOrCreateTypeInfo，
    /// 在外来线程上与 GC/主线程竞争导致 GenericTiDesc 崩溃）。
    private static var _cachedQueue: Option<ConcurrentLinkedQueue<DispatchEvent>> = None
    private static var _cachedWindowID: UInt32 = 0

    // ===== SDL 系统线程同步原语（对齐 ThreeRenderer._execBgfx） =====
    // 使用 three.core.thread 的系统级 Mutex/Condition（基于 sdl4cj，而非 std.sync），
    // 因为需要跨用户态（spawn 泵）与系统线程（SDL SThread）同步。
    private static let _sdlMtx = Mutex()
    private static let _sdlCmdCnd = Condition()
    private static let _sdlDoneCnd = Condition()
    private static let _sdlReadyCnd = Condition()
    private static var _sdlCmd: Option<() -> Unit> = None
    private static var _sdlDone: Bool = false
    private static var _sdlExit: Bool = false
    private static var _sdlReady: Bool = false
    private static var _sdlSThread: Option<SThread<Unit>> = None

    /**
     * 确保 SDL 系统线程已启动并完成 SDL_Init。幂等。
     *
     * @note[zh-cn] SDL3 要求 SDL_PollEvent/窗口创建/销毁/窗口操作只能在"初始化 video 子系统
     *       的线程"调用；而仓颉用户态线程（spawn，M:N）可能在系统线程间迁移，不能
     *       承载这些 API。故 SDL_Init/PollEvent/窗口命令全部固定在本 SThread（系统线程）
     *       内执行——本线程即"初始化线程"。
     * @note[en] SDL3 requires that SDL_PollEvent / window create/destroy/operations only be
     *       called on the thread that initialized the video subsystem; the Cangjie
     *       user-space thread (spawn, M:N) may migrate across system threads and cannot
     *       host these APIs. Therefore all SDL_Init/PollEvent/window commands are
     *       fixed on this SThread (system thread) — this thread is the "initialization thread".
     */
    internal static func ensureStarted(): Unit {
        if (_sdlSThread.isNone()) {
            _sdlExit = false
            _sdlReady = false
            _sdlSThread = Some(SThread{ SDLDispatcher._sdlLoop(); () })
        }
        // 等待 SDL_Init 完成（首次启动时；之后立即返回）
        _sdlMtx.lock()
        while (!_sdlReady) {
            _sdlReadyCnd.wait(_sdlMtx)
        }
        _sdlMtx.unlock()
    }

    /**
     * 提交命令到 SDL 系统线程同步执行（对齐 ThreeRenderer._execBgfx）。
     * 闭包内只能包含对 SDL 的原始调用，禁止嵌套调用其它走 execSDL 的方法（会自我等待死锁）。
     */
    internal static func execSDL(cmd: () -> Unit): Unit {
        if (_sdlSThread.isNone()) {
            ensureStarted()
        }
        _sdlMtx.lock()
        _sdlCmd = Some(cmd)
        _sdlDone = false
        _sdlCmdCnd.signal()
        // 使用 1s 超时循环等待（不做无限等待）：避免条件变量唤醒丢失时永久阻塞
        while (!_sdlDone) {
            _sdlDoneCnd.wait(_sdlMtx, 1000)
        }
        _sdlMtx.unlock()
    }

    /**
     * @param[zh-cn] windowID SDL 窗口 ID
     * @param[zh-cn] queue    该窗口的独立事件队列
     *
     * @param[en] windowID SDL window ID
     * @param[en] queue    The independent event queue for this window
     *
     * 注册窗口：建立 windowID → 队列映射（并发安全，可跨线程调用）。
     */
    internal static func register(windowID: UInt32, queue: ConcurrentLinkedQueue<DispatchEvent>): Unit {
        _refCount.fetchAdd(1)
        _registry.add(windowID, queue)
        _cachedWindowID = windowID
        _cachedQueue = Some(queue)
    }

    /**
     * @param[zh-cn] windowID SDL 窗口 ID
     *
     * @param[en] windowID SDL window ID
     *
     * 注销窗口：移除映射；末个窗口注销时停止分发器并 SDL_Quit。
     */
    internal static func unregister(windowID: UInt32): Unit {
        _registry.remove(windowID)
        let left = _refCount.fetchSub(1)
        if (left <= 1) {
            _stop()
        }
    }

    /// 停止分发线程并 SDL_Quit
    private static func _stop(): Unit {
        _sdlMtx.lock()
        _sdlExit = true
        _sdlCmdCnd.signal()
        _sdlMtx.unlock()
        match (_sdlSThread) {
            case Some(t) => t.join()
            case None => ()
        }
        _sdlSThread = None
    }

    /// SDL 系统线程主循环：SDL_Init → 命令执行 + 事件泵 → SDL_Quit
    private static func _sdlLoop(): Unit {
        // 本线程即"初始化 video 子系统的线程"（SDL3 约束：PollEvent 只能在此线程调用）
        let initOk = SDL_Init_cj(SDL_INIT_VIDEO | SDL_INIT_EVENTS | SDL_INIT_GAMEPAD)
        if (!initOk) {
            // SDL3 错误为线程局部：必须在本线程（SThread）内读取才有效
            let err = unsafe { if (SDL_GetError_cj().isNull()) { "?" } else { SDL_GetError_cj().toString() } }
            @LogError(["SDL_Init_cj FAILED (VIDEO|EVENTS|GAMEPAD): " + err])
        }
        // 标记就绪（ensureStarted 等待此信号）
        _sdlMtx.lock()
        _sdlReady = true
        _sdlReadyCnd.signal()
        _sdlMtx.unlock()
        let evPtr = unsafe { LibC.malloc<SDL_Event>() }
        unsafe { evPtr.write(SDL_Event()) }
        while (true) {
            // 1. 执行待处理命令（非阻塞检查）
            _drainCommands()
            // 2. 事件泵：阻塞等待事件（10ms 超时用于响应退出请求，避免忙等）
            if (SDL_WaitEventTimeout_cj(evPtr, 10)) {
                _dispatch(evPtr)
                // 排空剩余堆积事件（WaitEventTimeout 取出一个后，其余用 PollEvent 取）
                while (SDL_PollEvent_cj(evPtr)) {
                    _dispatch(evPtr)
                }
                unsafe { evPtr.write(SDL_Event()) }
            }
            // 3. 退出检查
            _sdlMtx.lock()
            let exit = _sdlExit
            _sdlMtx.unlock()
            if (exit) { break }
        }
        unsafe { LibC.free(evPtr) }
        SDL_Quit_cj()
    }

    /// 非阻塞检查并执行一条待执行命令（SDL 系统线程内调用）
    private static func _drainCommands(): Unit {
        _sdlMtx.lock()
        match (_sdlCmd) {
            case Some(cmd) =>
                cmd()
                _sdlCmd = None
                _sdlDone = true
                _sdlDoneCnd.signal()
            case None => ()
        }
        _sdlMtx.unlock()
    }

    /// 单事件分发：解析 windowID → 投递到对应窗口队列
    private static func _dispatch(evPtr: CPointer<SDL_Event>): Unit {
        let common = unsafe { CPointer<SDL_CommonEvent>(evPtr).read() }
        let t = common.`type`
        if (t == SDL_EVENT_QUIT) {
            // QUIT 无 windowID：广播到所有窗口
            for ((_, q) in _registry) {
                q.add(DispatchEvent(`type`: t, windowID: 0))
            }
            return
        }
        let windowID = _eventWindowID(evPtr, t)
        if (windowID == 0) { return }
        /* 使用缓存引用而非 _registry.get——避免在 SDL 外来线程上
         * 调 ConcurrentHashMap.get 触发 GetOrCreateTypeInfo 与 GC 竞争。 */
        if (windowID == _cachedWindowID) {
            match (_cachedQueue) {
                case Some(q) => q.add(_toDispatchEvent(evPtr, t, windowID))
                case None => ()
            }
        } else {
            if (let Some(q) <- _registry.get(windowID)) {
                q.add(_toDispatchEvent(evPtr, t, windowID))
            }
        }
    }

    /// 从事件结构读取关联窗口 ID（各具体事件结构体的 windowID 字段）
    private static func _eventWindowID(evPtr: CPointer<SDL_Event>, t: UInt32): UInt32 {
        if (t == SDL_EVENT_KEY_DOWN || t == SDL_EVENT_KEY_UP) {
            return unsafe { CPointer<SDL_KeyboardEvent>(evPtr).read().windowID }
        } else if (t == SDL_EVENT_TEXT_INPUT) {
            return unsafe { CPointer<SDL_TextInputEvent>(evPtr).read().windowID }
        } else if (t == SDL_EVENT_MOUSE_MOTION) {
            return unsafe { CPointer<SDL_MouseMotionEvent>(evPtr).read().windowID }
        } else if (t == SDL_EVENT_MOUSE_BUTTON_DOWN || t == SDL_EVENT_MOUSE_BUTTON_UP) {
            return unsafe { CPointer<SDL_MouseButtonEvent>(evPtr).read().windowID }
        } else if (t == SDL_EVENT_MOUSE_WHEEL) {
            return unsafe { CPointer<SDL_MouseWheelEvent>(evPtr).read().windowID }
        } else if (t >= 0x200u32 && t < 0x300u32) {
            // 窗口事件区间（SHOWN/HIDDEN/RESIZED/CLOSE_REQUESTED 等）
            return unsafe { CPointer<SDL_WindowEvent>(evPtr).read().windowID }
        } else if (t >= SDL_EVENT_FINGER_DOWN && t <= SDL_EVENT_FINGER_MOTION) {
            return unsafe { CPointer<SDL_TouchFingerEvent>(evPtr).read().windowID }
        }
        return 0
    }

    /// 将 SDL 事件结构转换为轻量 DispatchEvent（仅取快照所需字段）
    private static func _toDispatchEvent(evPtr: CPointer<SDL_Event>, t: UInt32, windowID: UInt32): DispatchEvent {
        if (t == SDL_EVENT_KEY_DOWN || t == SDL_EVENT_KEY_UP) {
            let evt = unsafe { CPointer<SDL_KeyboardEvent>(evPtr).read() }
            return DispatchEvent(`type`: t, windowID: windowID,
                                 f1: Float32(evt.scancode), f2: Float32(evt.key), f5: Float32(evt.mod),
                                 b1: evt.down, b2: evt.repeat)
        } else if (t == SDL_EVENT_TEXT_INPUT) {
            let evt = unsafe { CPointer<SDL_TextInputEvent>(evPtr).read() }
            let txt = if (evt.text.isNull()) { "" } else { unsafe { (evt.text as CString).toString() } }
            return DispatchEvent(`type`: t, windowID: windowID, text: txt)
        } else if (t == SDL_EVENT_MOUSE_MOTION) {
            let evt = unsafe { CPointer<SDL_MouseMotionEvent>(evPtr).read() }
            return DispatchEvent(`type`: t, windowID: windowID,
                                 f1: evt.x, f2: evt.y, f3: evt.xrel, f4: evt.yrel,
                                 b1: (evt.state & 0x1u32) != 0u32)
        } else if (t == SDL_EVENT_MOUSE_BUTTON_DOWN || t == SDL_EVENT_MOUSE_BUTTON_UP) {
            let evt = unsafe { CPointer<SDL_MouseButtonEvent>(evPtr).read() }
            return DispatchEvent(`type`: t, windowID: windowID,
                                 f1: Float32(evt.button), f2: evt.x, f3: evt.y,
                                 b1: evt.down)
        } else if (t == SDL_EVENT_MOUSE_WHEEL) {
            let evt = unsafe { CPointer<SDL_MouseWheelEvent>(evPtr).read() }
            return DispatchEvent(`type`: t, windowID: windowID, f1: evt.x, f2: evt.y)
        } else if (t >= 0x200u32 && t < 0x300u32) {
            let evt = unsafe { CPointer<SDL_WindowEvent>(evPtr).read() }
            return DispatchEvent(`type`: t, windowID: windowID,
                                 f1: Float32(evt.data1), f2: Float32(evt.data2))
        } else if (t >= SDL_EVENT_FINGER_DOWN && t <= SDL_EVENT_FINGER_MOTION) {
            let evt = unsafe { CPointer<SDL_TouchFingerEvent>(evPtr).read() }
            return DispatchEvent(`type`: t, windowID: windowID,
                                 f1: evt.x, f2: evt.y, f3: evt.dx, f4: evt.dy,
                                 f5: evt.pressure)
        }
        return DispatchEvent(`type`: t, windowID: windowID)
    }
}

// =============================================================================
// InputSnapshot：每循环固定事件快照
// =============================================================================

/**
 * @brief[zh-cn] 每循环固定窗口快照
 * @explain[zh-cn] 语义：窗口泵线程在每循环开头从本窗口队列取出全部事件 → 更新快照，
 * 之后整个 onFrame 期间快照值固定不变（任何时刻读取一致）。
 * 输入状态由各 InputProvider 自管理，不再包含在此快照中。
 *
 * @brief[en] Per-frame fixed window snapshot
 * @explain[en] Semantics: at the start of every loop the window pump thread drains all
 * events from this window's queue into the snapshot; the snapshot then stays
 * fixed for the whole onFrame period (reads are consistent at any moment).
 * Input state is managed by each InputProvider, no longer included in this snapshot.
 *
 * @note[zh-cn] 仅窗口泵线程读写（分发器只写事件队列），无需锁。
 * @note[en] Only the window pump thread reads and writes it (the dispatcher only writes
 * the event queue), so no lock is needed.
 */
public class InputSnapshot {
    /// 窗口宽度（resize 事件更新，持续状态）
    internal var width: Int32 = 0
    /// 窗口高度（resize 事件更新，持续状态）
    internal var height: Int32 = 0
    /// 用户是否请求关闭窗口（置位后不再清空）
    internal var closeRequested: Bool = false

    /**
     * @brief[zh-cn] 构造空快照
     *
     * @brief[en] Constructs an empty snapshot
     */
    public init() {}

    /**
     * @brief[zh-cn] 循环末重置（当前无输入状态需要重置）
     *
     * @brief[en] Reset at end of loop (no input state to reset currently)
     */
    internal func resetForNextFrame(): Unit {
        // 输入状态由各 Provider 在 endFrame() 中自行重置
    }
}

// =============================================================================
// WindowEngine：窗口类（生命周期回调 + 每窗口独立事件泵）
// =============================================================================

/**
 * @brief[zh-cn] 窗口引擎 v2（对齐 RGF 窗口模式）
 * @explain[zh-cn] 用法：继承本类并覆写生命周期回调（onInit/onFrame/onClose/onDestroy），
 * 或直接绑定 lambda（bindOnFrame 等，绑定优先于覆写）；start() 创建窗口并
 * 启动窗口泵线程，wait() 阻塞至窗口关闭。
 *
 * @brief[en] Window engine v2 (aligned with the RGF window model)
 * @explain[en] Usage: subclass this class and override the lifecycle callbacks
 * (onInit/onFrame/onClose/onDestroy), or bind lambdas directly (e.g. bindOnFrame,
 * binding takes precedence over overriding); start() creates the window and starts
 * the window pump thread, and wait() blocks until the window is closed.
 *
 * @note[zh-cn] 窗口泵线程主循环（每个窗口实例一条用户态线程，读自己的事件队列）：
 * onInit()                          // 窗口创建后（初始化渲染器/场景）
 * while (!closeRequested):
 * drainQueue → 构建固定快照      // 本循环全部事件 → InputSnapshot
 * bindOnFrame?(dt) / onFrame(dt) // 用户逻辑/渲染——读快照（值固定）
 * snapshot.resetForNextFrame()   // 循环末重置（下一循环重新收集）
 * onClose(); onDestroy()
 * @note[en] Window pump thread main loop (one user-space thread per window instance,
 * reading its own event queue):
 * onInit()                          // after window creation (init renderer/scene)
 * while (!closeRequested):
 * drainQueue -> build fixed snapshot  // all events this loop -> InputSnapshot
 * bindOnFrame?(dt) / onFrame(dt)     // user logic/rendering - reads snapshot
 * snapshot.resetForNextFrame()       // reset at loop end (re-collect next loop)
 * onClose(); onDestroy()
 */
public open class WindowEngine {
    // ===== 窗口状态 =====
    private var _window: SDL_Window = CPointer<Unit>()
    private var _initialized: Bool = false
    private var _width: Int32 = 0
    private var _height: Int32 = 0
    private var _title: String = ""
    private var _nativeHandle: UIntNative = 0
    private var _windowID: UInt32 = 0
    private var _exitRequested: Bool = false

    // ===== 事件队列 + 快照（仅窗口泵线程读写，无锁） =====
    private var _eventQueue: ConcurrentLinkedQueue<DispatchEvent> = ConcurrentLinkedQueue()
    private var _snapshot: InputSnapshot = InputSnapshot()

    // ===== 输入提供者（可插拔） =====
    private var _providers: ArrayList<InputProvider> = ArrayList<InputProvider>()

    // ===== 窗口泵线程（仓颉用户态线程，M:N 调度） =====
    private var _pumpThread: Option<Future<Unit>> = None

    // ===== Gui（ImGui）集成 =====
    /// 是否启用 Gui（由 useGui() 标记；start() 内创建；_windowLoop 内初始化/销毁）
    private var _enableGui: Bool = false
    /// Gui 上下文（启用后由 _windowLoop 创建）
    private var _gui: Option<UiContext> = None
    /// 渲染器的 execBgfx 提交方法（由 bindRenderer 注入，供 Gui render/shutdown 路由 bgfx 调用）
    internal var _execBgfx: Option<(() -> Unit) -> Unit> = None

    // ===== DPI（像素比） =====
    /// 当前窗口像素比（物理像素 / 逻辑像素），由 _updatePixelRatio 计算并缓存
    private var _pixelRatio: Float64 = 1.0
    /// 是否自动检测 DPI（默认 true）
    private var _dpiAutoDetect: Bool = true
    /// 手动 DPI 缩放值（_dpiAutoDetect=false 时生效）
    private var _manualDpiScale: Float64 = 0.0

    // ===== 生命周期回调（窗口线程主循环调用——open 可覆写，RGF 模式） =====
    /**
     * @brief[zh-cn] 窗口创建后调用（初始化渲染器/场景；可读 getNativeWindowHandle/getWidth/getHeight）
     *
     * @brief[en] Called after the window is created (init renderer/scene; can read
     * getNativeWindowHandle/getWidth/getHeight)
     */
    public open func onInit(): Unit {}
    /**
     * @brief[zh-cn] 每循环调用（读固定快照——逻辑+渲染）
     * @param[zh-cn] dt 距上循环的秒数
     *
     * @brief[en] Called every loop (reads the fixed snapshot - logic + rendering)
     * @param[en] dt Seconds elapsed since the previous loop
     */
    public open func onFrame(dt: Float64): Unit {}
    /**
     * @brief[zh-cn] 关闭前调用（清理逻辑/渲染器）
     *
     * @brief[en] Called before the window closes (clean up logic/renderer)
     */
    public open func onClose(): Unit {}
    /**
     * @brief[zh-cn] 销毁后调用
     *
     * @brief[en] Called after the window is destroyed
     */
    public open func onDestroy(): Unit {}
    /**
     * @brief[zh-cn] 窗口尺寸变化后调用（泵线程；getWidth/getHeight 已更新为新值）
     * @explain[zh-cn] 渲染器由用户持有，引擎只负责通知：用户应在此调用 renderer.setSize(w, h)
     *         触发后备缓冲重建（bgfx reset），并更新相机 aspect + updateProjectionMatrix()。
     *         拖拽缩放期间每帧最多回调一次（多事件自动合并）。
     *
     * @brief[en] Called after the window size changed (pump thread; getWidth/getHeight already updated)
     * @explain[en] The renderer is user-owned, so the engine only notifies: call renderer.setSize(w, h)
     *         here to rebuild the backbuffer (bgfx reset), and update camera aspect + updateProjectionMatrix().
     *         At most one callback per frame during interactive resizing (events are coalesced).
     */
    public open func onResize(width: Int32, height: Int32): Unit {}

    // ===== lambda 绑定（绑定优先于覆写，RGF 模式） =====
    private var _bindOnInit: Option<() -> Unit> = None
    /**
     * @brief[zh-cn] 绑定式事件 - 窗口创建后
     *
     * @brief[en] Bound event - after window creation
     */
    public mut prop bindOnInit: Option<() -> Unit> {
        get() { this._bindOnInit }
        set(v) { this._bindOnInit = v }
    }
    private var _bindOnFrame: Option<(Float64) -> Unit> = None
    /**
     * @brief[zh-cn] 绑定式事件 - 每循环（优先于覆写 onFrame）
     *
     * @brief[en] Bound event - every loop (takes precedence over the onFrame override)
     */
    public mut prop bindOnFrame: Option<(Float64) -> Unit> {
        get() { this._bindOnFrame }
        set(v) { this._bindOnFrame = v }
    }
    private var _bindOnClose: Option<() -> Unit> = None
    /**
     * @brief[zh-cn] 绑定式事件 - 关闭前
     *
     * @brief[en] Bound event - before closing
     */
    public mut prop bindOnClose: Option<() -> Unit> {
        get() { this._bindOnClose }
        set(v) { this._bindOnClose = v }
    }
    private var _bindOnDestroy: Option<() -> Unit> = None
    /**
     * @brief[zh-cn] 绑定式事件 - 销毁后
     *
     * @brief[en] Bound event - after destruction
     */
    public mut prop bindOnDestroy: Option<() -> Unit> {
        get() { this._bindOnDestroy }
        set(v) { this._bindOnDestroy = v }
    }
    private var _bindOnResize: Option<(Int32, Int32) -> Unit> = None
    /**
     * @brief[zh-cn] 绑定式事件 - 窗口尺寸变化后（优先于覆写 onResize）
     *
     * @brief[en] Bound event - after window size changed (takes precedence over the onResize override)
     */
    public mut prop bindOnResize: Option<(Int32, Int32) -> Unit> {
        get() { this._bindOnResize }
        set(v) { this._bindOnResize = v }
    }

    /**
     * @brief[zh-cn] 构造窗口引擎（尚未创建窗口，需调用 start）
     *
     * @brief[en] Constructs a window engine (no window created yet; call start first)
     */
    public init() {}

    // =========================================================================
    // Gui（ImGui）集成
    // =========================================================================

    /**
     * @brief[zh-cn] 启用 Gui（ImGui）。须在 start() 之前调用。
     * @explain[zh-cn] 启用后引擎会在 onInit 之后自动创建 UiContext，在 onFrame 前后自动
     *         执行 NewFrame/Render。须通过 bindRenderer() 绑定渲染器的 execBgfx。
     *
     * @brief[en] Enables the GUI (ImGui). Must be called before start().
     * @explain[en] Once enabled, the engine automatically creates a UiContext after onInit
     *         and runs NewFrame/Render around onFrame. Must call bindRenderer() to bind
     *         the renderer's execBgfx.
     */
    public func useGui(): Unit {
        this._enableGui = true
    }

    /**
     * @brief[zh-cn] 获取 Gui 上下文（启用后由 _windowLoop 创建）
     * @return[zh-cn] Gui 上下文；未启用或未初始化时返回 None
     *
     * @brief[en] Gets the GUI context (created by _windowLoop after enabling)
     * @return[en] The GUI context, or None if not enabled or not initialized
     */
    public prop gui: Option<UiContext> {
        get() { this._gui }
    }

    /**
     * @brief[zh-cn] 绑定渲染器的 execBgfx 提交方法（供 Gui 路由 bgfx 后端调用）
     * @param[zh-cn] execBgfx 渲染器的 execBgfx 方法引用
     *
     * @brief[en] Binds the renderer's execBgfx submit method (for the GUI to route bgfx backend calls)
     * @param[en] execBgfx The renderer's execBgfx method reference
     */
    public func bindRenderer(execBgfx: (() -> Unit) -> Unit): Unit {
        this._execBgfx = Some(execBgfx)
    }

    /**
     * @brief[zh-cn] 获取 SDL 窗口指针（供 ImGui SDL3 后端初始化使用）
     * @return[zh-cn] SDL 窗口指针
     *
     * @brief[en] Gets the SDL window pointer (for ImGui SDL3 backend initialization)
     * @return[en] The SDL window pointer
     */
    public func getSDLWindow(): SDL_Window {
        return this._window
    }

    // =========================================================================
    // 输入提供者管理（可插拔）
    // =========================================================================

    /**
     * @brief[zh-cn] 添加输入提供者
     * @param[zh-cn] provider 输入提供者实例
     *
     * @brief[en] Adds an input provider
     * @param[en] provider The input provider instance
     */
    public func addInputProvider(provider: InputProvider): Unit {
        provider.bindWindow(this)
        this._providers.add(provider)
    }

    /**
     * @brief[zh-cn] 移除输入提供者
     * @param[zh-cn] provider 输入提供者实例
     * @return[zh-cn] 是否成功移除
     *
     * @brief[en] Removes an input provider
     * @param[en] provider The input provider instance
     * @return[en] Whether the provider was successfully removed
     */
    public func removeInputProvider(provider: InputProvider): Bool {
        for (i in 0..this._providers.size) {
            if (refEq(this._providers[i], provider)) {
                this._providers.remove(i..i + 1)
                return true
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 获取所有输入提供者
     * @return[zh-cn] 输入提供者列表
     *
     * @brief[en] Gets all input providers
     * @return[en] The list of input providers
     */
    public func getProviders(): ArrayList<InputProvider> {
        return this._providers
    }

    /**
     * @brief[zh-cn] 获取指定类型的输入提供者
     * @return[zh-cn] 第一个匹配的提供者；未找到返回 None
     *
     * @brief[en] Gets the first input provider of the specified type
     * @return[en] The first matching provider, or None if not found
     */
    public func getProvider<T>(): Option<T> where T <: InputProvider {
        for (p in this._providers) {
            let tmp = p as T
            if (tmp.isSome()) {
                return tmp
            }
        }
        return None
    }

    // =========================================================================
    // 生命周期启动
    // =========================================================================

    /**
     * @brief[zh-cn] 启动窗口引擎：SDL 初始化 + 创建窗口 + 启动窗口泵线程（异步返回）
     * @param[zh-cn] title 窗口标题
     * width 窗口宽度（像素）
     * height 窗口高度（像素）
     * config 窗口创建配置（是否可 resize、是否全屏等），默认 WindowConfig()（resizable 开启）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Starts the window engine: SDL init + window creation + starts the window
     * pump thread (returns asynchronously)
     * @param[en] title Window title
     * width Window width in pixels
     * height Window height in pixels
     * config Window creation config (resizable, fullscreen, etc.); defaults to
     * WindowConfig() (resizable enabled)
     * @return[en] Whether the startup succeeded
     */
    public func start(title!: String, width!: Int32, height!: Int32, config!: WindowConfig = WindowConfig()): Bool {
        if (this._initialized) { return true }
        // 1. 确保全局分发器已启动（SDL_Init + 事件泵 SThread）
        SDLDispatcher.ensureStarted()
        // 2. 在 SDL 系统线程内创建窗口（SDL_CreateWindow 只能在初始化线程调用；
        //    仓颉用户态线程可能在系统线程间迁移，不能直接创建）
        let okBox = Box(false)
        let t = title
        let w = width
        let h = height
        let c = config
        SDLDispatcher.execSDL({ =>
            var flags: UInt64 = 0
            if (c.highPixelDensity) { flags |= SDL_WINDOW_HIGH_PIXEL_DENSITY }
            if (c.resizable) { flags |= SDL_WINDOW_RESIZABLE }
            if (c.fullscreen) { flags |= SDL_WINDOW_FULLSCREEN }
            if (c.borderless) { flags |= SDL_WINDOW_BORDERLESS }
            if (c.alwaysOnTop) { flags |= SDL_WINDOW_ALWAYS_ON_TOP }
            let titleCs = unsafe { LibC.mallocCString(t) }
            let win = SDL_CreateWindow_cj(titleCs, w, h, flags)
            unsafe { LibC.free(titleCs) }
            if (win.isNull()) {
                // SDL3 错误为线程局部：必须在本线程（SDL SThread）内读取才有效
                let err = unsafe { if (SDL_GetError_cj().isNull()) { "?" } else { SDL_GetError_cj().toString() } }
                @LogError(["SDL_CreateWindow_cj FAILED (" + w.toString() + "x" + h.toString() + "): " + err])
            }
            if (!win.isNull()) {
                // 应用非 flags 属性（透明度 / 最小最大尺寸）
                if (c.opacity < 1.0) { SDL_SetWindowOpacity_cj(win, c.opacity) }
                if (c.minWidth > 0 && c.minHeight > 0) {
                    SDL_SetWindowMinimumSize_cj(win, c.minWidth, c.minHeight)
                }
                if (c.maxWidth > 0 && c.maxHeight > 0) {
                    SDL_SetWindowMaximumSize_cj(win, c.maxWidth, c.maxHeight)
                }
                // 记录状态 + 注册分发器
                this._window = win
                // 回填 SDL 实际窗口尺寸（OHOS 等平台建窗时可能忽略传入的 w/h，
                // 直接取 XComponent/native window 的真实尺寸；若不回填，_width
                // 停留在占位值，后续 getPixelRatio() 会用 drawable/占位 算出
                // 异常大的 pixelRatio，导致物理尺寸溢出 UInt16 而崩溃）。
                let rwBox = Box(0i32)
                let rhBox = Box(0i32)
                unsafe {
                    let wp = LibC.malloc<Int32>()
                    let hp = LibC.malloc<Int32>()
                    wp.write(0); hp.write(0)
                    if (SDL_GetWindowSize_cj(win, wp, hp)) {
                        rwBox.value = wp.read()
                        rhBox.value = hp.read()
                    }
                    LibC.free(wp); LibC.free(hp)
                }
                let rw = if (rwBox.value > 0) { rwBox.value } else { w }
                let rh = if (rhBox.value > 0) { rhBox.value } else { h }
                this._width = rw
                this._height = rh
                this._title = t
                this._nativeHandle = this._getNativeHandle(win)
                this._windowID = SDL_GetWindowID_cj(win)
                this._snapshot = InputSnapshot()
                this._snapshot.width = rw
                this._snapshot.height = rh
                SDLDispatcher.register(this._windowID, this._eventQueue)
                SDL_ShowWindow_cj(win)
                okBox.value = true
            }
        })
        if (!okBox.value) { return false }
        // 3. 若启用 Gui，创建 UiContext 实例（在 _windowLoop 中 onInit 后初始化）
        if (this._enableGui) {
            this._gui = Some(UiContext())
        }
        // 4. 启动窗口泵线程（spawn 用户态线程；主线程须 wait() 保持存活，
        //    否则 main 退出会杀死未完成的 spawn 线程）
        this._exitRequested = false
        this._pumpThread = Some(spawn { => this._windowLoop() })
        this._initialized = true
        return true
    }

    /**
     * @brief[zh-cn] 阻塞等待窗口关闭（窗口泵线程结束后返回）
     *
     * @brief[en] Blocks until the window is closed (returns after the window pump
     * thread ends)
     *
     * @note[zh-cn] 窗口关闭途径：用户点标题栏 X / Alt+F4、onFrame 内调 requestClose()、
     * 外部调 shutdown()。
     * @note[en] Ways to close: user clicks the title bar X / Alt+F4, calling
     * requestClose() inside onFrame, or an external shutdown() call.
     */
    public func wait(): Unit {
        match (this._pumpThread) {
            case Some(t) => t.get()
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 请求关闭窗口
     * @explain[zh-cn] 等价于用户点击关闭按钮：泵循环检测到后退出，依次执行
     * onClose()/onDestroy() 并销毁窗口。可跨线程调用。
     *
     * @brief[en] Requests the window to close
     * @explain[en] Equivalent to the user clicking the close button: the pump loop exits
     * once it detects this, running onClose()/onDestroy() and destroying the
     * window. Can be called from any thread.
     */
    public func requestClose(): Unit {
        this._snapshot.closeRequested = true
    }

    /**
     * @brief[zh-cn] 关闭窗口引擎
     * @explain[zh-cn] 请求退出 + 等待窗口泵线程结束（含 onClose/onDestroy）。
     *
     * @brief[en] Shuts down the window engine
     * @explain[en] Requests exit and waits for the window pump thread to finish
     * (including onClose/onDestroy).
     */
    public func shutdown(): Unit {
        if (!this._initialized && this._pumpThread.isNone()) { return }
        this._exitRequested = true
        this._snapshot.closeRequested = true
        this.wait()
        this._initialized = false
    }

    /**
     * @brief[zh-cn] 窗口是否已初始化
     *
     * @brief[en] Whether the window has been initialized
     */
    public prop initialized: Bool {
        get() { this._initialized }
    }

    /**
     * @brief[zh-cn] 用户是否请求关闭窗口（读快照——固定）
     *
     * @brief[en] Whether the user requested to close the window (reads the snapshot - fixed)
     */
    public prop closeRequested: Bool {
        get() { this._snapshot.closeRequested }
    }

    /**
     * @brief[zh-cn] 用户是否请求关闭窗口（方法形式，等价于 closeRequested）
     * @return[zh-cn] 是否已请求关闭
     *
     * @brief[en] Whether the user requested to close the window (method form, equivalent
     * to closeRequested)
     * @return[en] Whether a close has been requested
     */
    public func isCloseRequested(): Bool {
        return this._snapshot.closeRequested
    }

    // =========================================================================
    // 窗口泵线程（每窗口独立循环）
    // =========================================================================

    private func _windowLoop(): Unit {
        // 初始化所有输入提供者
        for (p in this._providers) {
            p.`init`()
        }
        // 生命周期：窗口创建后
        if (let Some(f) <- this._bindOnInit) { f() } else { this.onInit() }
        // onInit 中应已完成 bgfx 初始化；此时初始化 Gui 上下文（依赖 bgfx）
        match (this._gui) {
            case Some(ctx) =>
                if (!ctx.initialized) {
                    match (this._execBgfx) {
                        case Some(execFn) =>
                            @LogInfo(["WindowEngine._windowLoop: initializing Gui context"])
                            ctx.initialize(this, execFn)
                            @LogInfo(["WindowEngine._windowLoop: Gui context initialized"])
                        case None => @LogWarn(["Gui enabled but no renderer bound (call bindRenderer in onInit)"])
                    }
                }
            case None => ()
        }
        var lastTime = MonoTime.now()
        var lastWidth = this._width
        var lastHeight = this._height
        while (!this._snapshot.closeRequested && !this._exitRequested) {
            // ① 各 Provider 帧开始（轮询设备状态）
            for (p in this._providers) {
                p.beginFrame()
            }
            // ② 收集本循环全部事件 → 分发给各 Provider
            this._drainQueue()
            // ②a 尺寸变化 → 触发 onResize（泵线程；拖拽缩放的多事件在此合并为每帧一次）
            if (this._width != lastWidth || this._height != lastHeight) {
                lastWidth = this._width
                lastHeight = this._height
                if (let Some(f) <- this._bindOnResize) { f(this._width, this._height) } else { this.onResize(this._width, this._height) }
            }
            // ③ 用户逻辑/渲染——读快照（值固定）
            let now = MonoTime.now()
            let dt = Float64((now - lastTime).toMilliseconds()) / 1000.0
            lastTime = now
            // ③a 开始 Gui 新帧（在 onFrame 之前，确保控件 API 可用）
            match (this._gui) {
                case Some(ctx) =>
                    if (ctx.initialized) {
                        this._updatePixelRatio()
                        ctx.setPixelRatio(this._pixelRatio)
                        ctx.newFrame(dt, this._width, this._height)
                    }
                case None => ()
            }
            // ③ 用户帧回调：异常时绝不能让泵线程静默死亡——否则主协程 win.wait()
            // 会永久挂起、进程卡死。记录异常并请求关闭，使 onClose 清理流程正常走完。
            var frameFailed = false
            try {
                if (let Some(f) <- this._bindOnFrame) { f(dt) } else { this.onFrame(dt) }
            } catch (e: Exception) {
                frameFailed = true
                @LogError(["WindowEngine._windowLoop: onFrame 抛出异常: ${e.message}; 请求关闭窗口"])
            }
            if (frameFailed) {
                this.requestClose()
                break
            }
            // ③b Gui render hook：onFrame 结束后将 Gui 绘制提交到渲染线程
            match (this._gui) {
                case Some(ctx) =>
                    if (ctx.initialized) {
                        match (this._execBgfx) {
                            case Some(execFn) =>
                                let vw = this._width
                                let vh = this._height
                                execFn({ =>
                                    ctx.render(vw, vh)
                                })
                            case None =>
                                @LogWarn(["Gui enabled but no renderer bound (call bindRenderer in onInit)"])
                        }
                    }
                case None => ()
            }
            // ④ 循环末尾重置（下一循环重新收集）
            this._snapshot.resetForNextFrame()
            for (p in this._providers) {
                p.endFrame()
            }
        }
        // 清理所有输入提供者
        for (p in this._providers) {
            p.shutdown()
        }
        // 销毁 Gui 上下文：必须在 onClose()（renderer.shutdown() 停掉 bgfx 线程）
        // 与 SDL 窗口销毁之前——其 SDL3/bgfx 后端关闭依赖这两个线程仍存活
        match (this._gui) {
            case Some(ctx) =>
                ctx.shutdown()
                this._gui = None
            case None => ()
        }
        // 生命周期：关闭前 + 销毁
        if (let Some(f) <- this._bindOnClose) { f() } else { this.onClose() }
        // 销毁窗口必须在 SDL SThread（初始化线程）内执行
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                SDL_DestroyWindow_cj(this._window)
                this._window = CPointer<Unit>()
            }
        })
        SDLDispatcher.unregister(this._windowID)
        if (let Some(f) <- this._bindOnDestroy) { f() } else { this.onDestroy() }
    }

    /// 取出本窗口队列中全部事件 → 更新快照
    private func _drainQueue(): Unit {
        while (let Some(evt) <- this._eventQueue.remove()) {
            this._applyEvent(evt)
        }
    }

    /// 单事件应用：更新快照 + 分发给各 Provider（仅泵线程调用）
    private func _applyEvent(evt: DispatchEvent): Unit {
        let t = evt.`type`
        // 窗口相关事件直接处理（不属于任何 Provider）
        if (t == SDL_EVENT_WINDOW_RESIZED) {
            this._width = Int32(evt.f1)
            this._height = Int32(evt.f2)
            this._snapshot.width = this._width
            this._snapshot.height = this._height
        } else if (t == SDL_EVENT_WINDOW_CLOSE_REQUESTED) {
            this._snapshot.closeRequested = true
        } else if (t == SDL_EVENT_QUIT) {
            this._snapshot.closeRequested = true
        } else {
            // 输入事件分发给各 Provider
            for (p in this._providers) {
                p.onEvent(evt)
            }
        }
        // 将输入事件转发给 Gui（ImGui）上下文
        match (this._gui) {
            case Some(ctx) =>
                if (ctx.initialized) {
                    if (t == SDL_EVENT_KEY_DOWN || t == SDL_EVENT_KEY_UP) {
                        ctx.addKeyEvent(UInt32(evt.f1), UInt32(evt.f2), UInt32(evt.f5), evt.b1, evt.b2)
                    } else if (t == SDL_EVENT_TEXT_INPUT) {
                        ctx.addTextInput(evt.text)
                    } else if (t == SDL_EVENT_MOUSE_MOTION) {
                        ctx.addMousePosEvent(evt.f1, evt.f2)
                    } else if (t == SDL_EVENT_MOUSE_BUTTON_DOWN || t == SDL_EVENT_MOUSE_BUTTON_UP) {
                        // SDL 按钮：1=左 2=中 3=右；ImGui：0=左 1=右 2=中
                        let sdlBtn = Int32(evt.f1)
                        let imBtn: Int32 = if (sdlBtn == 1i32) { 0i32 } else if (sdlBtn == 3i32) { 1i32 } else if (sdlBtn == 2i32) { 2i32 } else { sdlBtn - 1i32 }
                        ctx.addMouseButtonEvent(imBtn, evt.b1)
                    } else if (t == SDL_EVENT_MOUSE_WHEEL) {
                        ctx.addMouseWheelEvent(evt.f1, evt.f2)
                    }
                }
            case None => ()
        }
    }

    // =========================================================================
    // 快照查询 API（读固定快照；在 onFrame 内调用）
    // 注意：输入查询方法已移至各 InputProvider，请通过 getProvider<T>() 获取
    // =========================================================================

    /**
     * @brief[zh-cn] 窗口宽度（像素）
     *
     * @brief[en] Window width in pixels
     */
    public func getWidth(): Int32 { return this._width }

    /**
     * @brief[zh-cn] 窗口高度（像素）
     *
     * @brief[en] Window height in pixels
     */
    public func getHeight(): Int32 { return this._height }

    /**
     * @brief[zh-cn] 窗口标题
     *
     * @brief[en] Window title
     */
    public func getTitle(): String { return this._title }

    /**
     * @brief[zh-cn] 获取跨平台原生窗口句柄（nwh），供渲染引擎绑定窗口
     * @explain[zh-cn] Windows 返回 HWND、X11 返回 Window、Wayland 返回 surface 指针等。
     * @return[zh-cn] 原生窗口句柄
     *
     * @brief[en] Gets the cross-platform native window handle (nwh) for binding the
     * window to a renderer
     * @explain[en] Returns HWND on Windows, Window on X11, the surface pointer on
     * Wayland, etc.
     * @return[en] The native window handle
     */
    public func getNativeWindowHandle(): UIntNative { return this._nativeHandle }

    // =========================================================================
    // 窗口操作 API（全部经 SDLDispatcher.execSDL 转发到 SDL SThread 执行——
    // SDL3 窗口操作只能在初始化线程调用，仓颉用户态线程不可直接调用）
    // =========================================================================

    /**
     * @brief[zh-cn] 更新窗口逻辑尺寸（跨平台接口）
     * @explain[zh-cn] 桌面：同步调整 SDL 窗口大小（SDL SThread 内执行）。
     * OHOS：窗口由 ArkTS 侧 XComponent 控制（ArkTS 负责真实 resize），
     * 本方法仅更新内部尺寸供渲染查询。
     * @param[zh-cn] width 新宽度（像素）
     * height 新高度（像素）
     *
     * @brief[en] Updates the window logical size (cross-platform interface)
     * @explain[en] Desktop: synchronously resizes the SDL window (executed on the SDL
     * SThread). OHOS: the window is controlled by the ArkTS-side XComponent
     * (ArkTS performs the real resize); this method only updates the internal
     * size for render queries.
     * @param[en] width New width in pixels
     * height New height in pixels
     */
    public func updateSize(width: Int32, height: Int32): Unit {
        let w = width
        let h = height
        this._width = w
        this._height = h
        this._snapshot.width = w
        this._snapshot.height = h
        // 注意：
        // 1. 此处不调用 _updatePixelRatio()——该函数经 execSDL 走 SDL 线程查询
        //    drawable size，会阻塞调用方线程。updateSize 可能被 ArkTS 主线程
        //    （onAreaChange 回调）调用，阻塞主线程会触发 THREAD_BLOCK_6S。
        //    pixelRatio 延迟到 SDL 泵线程（onFrame 中 getPixelRatio）重算。
        // 2. 此处不调用 SDL_SetWindowSize_cj——OHOS 上窗口尺寸由 XComponent 驱动，
        //    且 OHOS_SetWindowSize 内部经 NAPI 操作 ArkUI 节点，从 SDL 线程调用
        //    可能等待主线程，与主线程的 execSDL 等待形成死锁。引擎只需同步内部
        //    逻辑尺寸，实际窗口 resize 由平台事件（XComponent surface change /
        //    WM SIZE 消息）驱动。
    }

    /**
     * @brief[zh-cn] 调整窗口尺寸
     * @param[zh-cn] width 新宽度
     * height 新高度
     *
     * @brief[en] Resizes the window
     * @param[en] width New width
     * height New height
     */
    public func setSize(width: Int32, height: Int32): Unit {
        this.updateSize(width, height)
    }

    /**
     * @brief[zh-cn] 设置窗口是否可由用户调整大小
     * @param[zh-cn] resizable true=可调节尺寸，false=锁定尺寸（不可调节）
     *
     * @brief[en] Sets whether the user can resize the window
     * @param[en] resizable true = resizable, false = locked (not resizable)
     *
     * @note[zh-cn] 创建后也可用。
     * @note[en] Also usable after creation.
     */
    public func setResizable(resizable: Bool): Unit {
        let r = resizable
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                SDL_SetWindowResizable_cj(this._window, r)
            }
        })
    }

    /**
     * @brief[zh-cn] 设置窗口标题
     * @param[zh-cn] title 新标题
     *
     * @brief[en] Sets the window title
     * @param[en] title New title
     */
    public func setTitle(title: String): Unit {
        let t = title
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                let cs = unsafe { LibC.mallocCString(t) }
                SDL_SetWindowTitle_cj(this._window, cs)
                unsafe { LibC.free(cs) }
            }
            this._title = t
        })
    }

    /**
     * @brief[zh-cn] 显示窗口
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Shows the window
     * @return[en] Whether the operation succeeded
     */
    public func show(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_ShowWindow_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 隐藏窗口
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Hides the window
     * @return[en] Whether the operation succeeded
     */
    public func hide(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_HideWindow_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 将窗口置顶
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Raises the window to the top
     * @return[en] Whether the operation succeeded
     */
    public func raise(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_RaiseWindow_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 最大化窗口
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Maximizes the window
     * @return[en] Whether the operation succeeded
     */
    public func maximize(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_MaximizeWindow_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 最小化窗口
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Minimizes the window
     * @return[en] Whether the operation succeeded
     */
    public func minimize(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_MinimizeWindow_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 恢复窗口（从最大化/最小化恢复）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Restores the window (from maximized/minimized)
     * @return[en] Whether the operation succeeded
     */
    public func restore(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_RestoreWindow_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 设置窗口位置（屏幕坐标）
     * @param[zh-cn] x 屏幕 X 坐标
     * y 屏幕 Y 坐标
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets the window position (screen coordinates)
     * @param[en] x Screen X coordinate
     * y Screen Y coordinate
     * @return[en] Whether the operation succeeded
     */
    public func setPosition(x: Int32, y: Int32): Bool {
        let resultBox = Box(false)
        let px = x
        let py = y
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowPosition_cj(this._window, px, py) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口位置（屏幕坐标）
     * @return[zh-cn] (x, y) 屏幕坐标
     *
     * @brief[en] Gets the window position (screen coordinates)
     * @return[en] (x, y) screen coordinates
     */
    public func getPosition(): (Int32, Int32) {
        let xBox = Box(0i32)
        let yBox = Box(0i32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                let xp = unsafe { LibC.malloc<Int32>() }
                let yp = unsafe { LibC.malloc<Int32>() }
                unsafe { xp.write(0); yp.write(0) }
                if (SDL_GetWindowPosition_cj(this._window, xp, yp)) {
                    xBox.value = unsafe { xp.read() }
                    yBox.value = unsafe { yp.read() }
                }
                unsafe { LibC.free(xp); LibC.free(yp) }
            }
        })
        return (xBox.value, yBox.value)
    }

    /**
     * @brief[zh-cn] 获取窗口像素密度（HiDPI 缩放因子）
     * @return[zh-cn] 像素密度
     *
     * @brief[en] Gets the window pixel density (HiDPI scale factor)
     * @return[en] The pixel density
     */
    public func getPixelDensity(): Float32 {
        let resultBox = Box(1.0f32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_GetWindowPixelDensity_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口显示缩放比例（HiDPI）
     * @return[zh-cn] 显示缩放比例
     *
     * @brief[en] Gets the window display scale (HiDPI)
     * @return[en] The display scale
     */
    public func getDisplayScale(): Float32 {
        let resultBox = Box(1.0f32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_GetWindowDisplayScale_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口像素尺寸（物理后备缓冲尺寸）
     * @return[zh-cn] (物理宽度, 物理高度)
     * @explain[zh-cn] 在 HiDPI 显示器上通常大于逻辑尺寸（getWidth/getHeight）。bgfx 等渲染器应使用此尺寸作为后备缓冲大小。
     *
     * @brief[en] Gets the window pixel dimensions (physical backbuffer size)
     * @return[en] (physical width, physical height)
     * @explain[en] On HiDPI displays this is usually larger than the logical size (getWidth/getHeight). Renderers like bgfx should use this as the backbuffer size.
     */
    public func getDrawableSize(): (Int32, Int32) {
        let wBox = Box(0i32)
        let hBox = Box(0i32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                let wp = unsafe { LibC.malloc<Int32>() }
                let hp = unsafe { LibC.malloc<Int32>() }
                unsafe { wp.write(0); hp.write(0) }
                if (SDL_GetWindowSizeInPixels_cj(this._window, wp, hp)) {
                    wBox.value = unsafe { wp.read() }
                    hBox.value = unsafe { hp.read() }
                }
                unsafe { LibC.free(wp); LibC.free(hp) }
            }
        })
        return (wBox.value, hBox.value)
    }

    /**
     * @brief[zh-cn] 获取窗口像素比（物理像素 / 逻辑像素）
     * @return[zh-cn] 像素比；查询失败或无窗口时返回 1.0
     * @explain[zh-cn] 基于 getDrawableSize() 与逻辑尺寸计算，可直接传给 renderer.setPixelRatio()。
     *         若已通过 setDpiScale 设置手动值，则返回手动值。
     *
     * @brief[en] Gets the window pixel ratio (physical pixels / logical pixels)
     * @return[en] Pixel ratio; returns 1.0 if query fails or no window exists
     * @explain[en] Computed from getDrawableSize() and logical dimensions; can be passed directly
     *         to renderer.setPixelRatio(). Returns the manual value if set via setDpiScale.
     */
    public func getPixelRatio(): Float32 {
        this._updatePixelRatio()
        return Float32(this._pixelRatio)
    }

    /**
     * @brief[zh-cn] 重新计算并缓存当前窗口像素比
     * @return[zh-cn] 缓存后的像素比
     *
     * @brief[en] Recalculates and caches the current window pixel ratio
     * @return[en] The cached pixel ratio
     */
    private func _updatePixelRatio(): Float64 {
        if (!this._dpiAutoDetect && this._manualDpiScale > 0.0) {
            this._pixelRatio = this._manualDpiScale
            return this._pixelRatio
        }
        let (dw, dh) = this.getDrawableSize()
        if (this._width <= 0 || this._height <= 0) {
            this._pixelRatio = 1.0
            return this._pixelRatio
        }
        let ratioX = Float32(dw) / Float32(this._width)
        let ratioY = Float32(dh) / Float32(this._height)
        this._pixelRatio = Float64((ratioX + ratioY) * 0.5f32)
        return this._pixelRatio
    }

    /**
     * @brief[zh-cn] 设置是否自动检测 DPI
     * @param[zh-cn] autoDetect true 时通过 SDL 自动检测；false 时强制使用 setDpiScale 指定的值
     *
     * @brief[en] Sets whether to auto-detect DPI
     * @param[en] autoDetect true to auto-detect via SDL; false to enforce the value set by setDpiScale
     */
    public func setDpiAutoDetect(autoDetect: Bool): Unit {
        this._dpiAutoDetect = autoDetect
        this._updatePixelRatio()
    }

    /**
     * @brief[zh-cn] 设置手动 DPI 缩放值
     * @param[zh-cn] scale 像素比（必须 > 0）；设置后会自动关闭自动检测
     *
     * @brief[en] Sets the manual DPI scale value
     * @param[en] scale Pixel ratio (must be > 0); auto-detection is automatically disabled after setting
     */
    public func setDpiScale(scale: Float64): Unit {
        if (scale > 0.0) {
            this._manualDpiScale = scale
            this._dpiAutoDetect = false
            this._updatePixelRatio()
        }
    }

    /**
     * @brief[zh-cn] 获取当前 DPI 缩放值
     * @return[zh-cn] 当前像素比
     *
     * @brief[en] Gets the current DPI scale value
     * @return[en] Current pixel ratio
     */
    public func getDpiScale(): Float64 {
        return this._pixelRatio
    }

    /**
     * @brief[zh-cn] 获取窗口像素格式
     * @return[zh-cn] 像素格式（SDL_PixelFormat 枚举值）
     *
     * @brief[en] Gets the window pixel format
     * @return[en] The pixel format (SDL_PixelFormat enum value)
     */
    public func getPixelFormat(): UInt32 {
        let resultBox = Box(0u32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_GetWindowPixelFormat_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 设置窗口最小尺寸（resize 下限）
     * @param[zh-cn] minW 最小宽度（像素）
     * minH 最小高度（像素）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets the window minimum size (resize lower bound)
     * @param[en] minW Minimum width in pixels
     * minH Minimum height in pixels
     * @return[en] Whether the operation succeeded
     */
    public func setMinimumSize(minW: Int32, minH: Int32): Bool {
        let resultBox = Box(false)
        let w = minW
        let h = minH
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowMinimumSize_cj(this._window, w, h) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口最小尺寸
     * @return[zh-cn] (最小宽度, 最小高度)
     *
     * @brief[en] Gets the window minimum size
     * @return[en] (minimum width, minimum height)
     */
    public func getMinimumSize(): (Int32, Int32) {
        let wBox = Box(0i32)
        let hBox = Box(0i32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                let wp = unsafe { LibC.malloc<Int32>() }
                let hp = unsafe { LibC.malloc<Int32>() }
                unsafe { wp.write(0); hp.write(0) }
                if (SDL_GetWindowMinimumSize_cj(this._window, wp, hp)) {
                    wBox.value = unsafe { wp.read() }
                    hBox.value = unsafe { hp.read() }
                }
                unsafe { LibC.free(wp); LibC.free(hp) }
            }
        })
        return (wBox.value, hBox.value)
    }

    /**
     * @brief[zh-cn] 设置窗口最大尺寸（resize 上限）
     * @param[zh-cn] maxW 最大宽度（像素）
     * maxH 最大高度（像素）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets the window maximum size (resize upper bound)
     * @param[en] maxW Maximum width in pixels
     * maxH Maximum height in pixels
     * @return[en] Whether the operation succeeded
     */
    public func setMaximumSize(maxW: Int32, maxH: Int32): Bool {
        let resultBox = Box(false)
        let w = maxW
        let h = maxH
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowMaximumSize_cj(this._window, w, h) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口最大尺寸
     * @return[zh-cn] (最大宽度, 最大高度)
     *
     * @brief[en] Gets the window maximum size
     * @return[en] (maximum width, maximum height)
     */
    public func getMaximumSize(): (Int32, Int32) {
        let wBox = Box(0i32)
        let hBox = Box(0i32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                let wp = unsafe { LibC.malloc<Int32>() }
                let hp = unsafe { LibC.malloc<Int32>() }
                unsafe { wp.write(0); hp.write(0) }
                if (SDL_GetWindowMaximumSize_cj(this._window, wp, hp)) {
                    wBox.value = unsafe { wp.read() }
                    hBox.value = unsafe { hp.read() }
                }
                unsafe { LibC.free(wp); LibC.free(hp) }
            }
        })
        return (wBox.value, hBox.value)
    }

    /**
     * @brief[zh-cn] 设置窗口是否全屏（运行时切换）
     * @param[zh-cn] fullscreen true=进入全屏，false=退出全屏
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets whether the window is fullscreen (runtime toggle)
     * @param[en] fullscreen true = enter fullscreen, false = exit fullscreen
     * @return[en] Whether the operation succeeded
     */
    public func setFullscreen(fullscreen: Bool): Bool {
        let resultBox = Box(false)
        let f = fullscreen
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowFullscreen_cj(this._window, f) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 设置窗口是否有边框
     * @param[zh-cn] bordered true=有边框，false=无边框
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets whether the window has a border
     * @param[en] bordered true = bordered, false = borderless
     * @return[en] Whether the operation succeeded
     */
    public func setBordered(bordered: Bool): Bool {
        let resultBox = Box(false)
        let b = bordered
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowBordered_cj(this._window, b) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 设置窗口透明度
     * @param[zh-cn] opacity 透明度（0.0=完全透明，1.0=不透明）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets the window opacity
     * @param[en] opacity Opacity (0.0 = fully transparent, 1.0 = opaque)
     * @return[en] Whether the operation succeeded
     */
    public func setOpacity(opacity: Float32): Bool {
        let resultBox = Box(false)
        let o = opacity
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowOpacity_cj(this._window, o) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口透明度
     * @return[zh-cn] 透明度（0.0-1.0）
     *
     * @brief[en] Gets the window opacity
     * @return[en] Opacity (0.0-1.0)
     */
    public func getOpacity(): Float32 {
        let oBox = Box(1.0f32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                let op = unsafe { LibC.malloc<Float32>() }
                unsafe { op.write(1.0f32) }
                if (SDL_GetWindowOpacity_cj(this._window, op)) {
                    oBox.value = unsafe { op.read() }
                }
                unsafe { LibC.free(op) }
            }
        })
        return oBox.value
    }

    /**
     * @brief[zh-cn] 设置窗口是否置顶
     * @param[zh-cn] onTop true=置顶，false=取消置顶
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets whether the window stays on top
     * @param[en] onTop true = always on top, false = cancel
     * @return[en] Whether the operation succeeded
     */
    public func setAlwaysOnTop(onTop: Bool): Bool {
        let resultBox = Box(false)
        let t = onTop
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowAlwaysOnTop_cj(this._window, t) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 设置窗口是否可聚焦
     * @param[zh-cn] focusable true=可聚焦，false=不可聚焦
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets whether the window is focusable
     * @param[en] focusable true = focusable, false = not focusable
     * @return[en] Whether the operation succeeded
     */
    public func setFocusable(focusable: Bool): Bool {
        let resultBox = Box(false)
        let f = focusable
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowFocusable_cj(this._window, f) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 设置窗口是否模态
     * @param[zh-cn] modal true=模态，false=非模态
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets whether the window is modal
     * @param[en] modal true = modal, false = non-modal
     * @return[en] Whether the operation succeeded
     */
    public func setModal(modal: Bool): Bool {
        let resultBox = Box(false)
        let m = modal
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowModal_cj(this._window, m) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 设置窗口宽高比约束
     * @param[zh-cn] minAspect 最小宽高比
     * maxAspect 最大宽高比
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets the window aspect-ratio constraint
     * @param[en] minAspect Minimum aspect ratio
     * maxAspect Maximum aspect ratio
     * @return[en] Whether the operation succeeded
     */
    public func setAspectRatio(minAspect: Float32, maxAspect: Float32): Bool {
        let resultBox = Box(false)
        let a = minAspect
        let b = maxAspect
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowAspectRatio_cj(this._window, a, b) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口宽高比约束
     * @return[zh-cn] (最小宽高比, 最大宽高比)
     *
     * @brief[en] Gets the window aspect-ratio constraint
     * @return[en] (minimum aspect ratio, maximum aspect ratio)
     */
    public func getAspectRatio(): (Float32, Float32) {
        let aBox = Box(0.0f32)
        let bBox = Box(0.0f32)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                let ap = unsafe { LibC.malloc<Float32>() }
                let bp = unsafe { LibC.malloc<Float32>() }
                unsafe { ap.write(0.0f32); bp.write(0.0f32) }
                if (SDL_GetWindowAspectRatio_cj(this._window, ap, bp)) {
                    aBox.value = unsafe { ap.read() }
                    bBox.value = unsafe { bp.read() }
                }
                unsafe { LibC.free(ap); LibC.free(bp) }
            }
        })
        return (aBox.value, bBox.value)
    }

    /**
     * @brief[zh-cn] 设置鼠标是否捕获到窗口（隐藏并锁定鼠标）
     * @param[zh-cn] grabbed true=捕获，false=释放
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets whether the mouse is grabbed by the window (hides and locks the mouse)
     * @param[en] grabbed true = grab, false = release
     * @return[en] Whether the operation succeeded
     */
    public func setMouseGrab(grabbed: Bool): Bool {
        let resultBox = Box(false)
        let g = grabbed
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowMouseGrab_cj(this._window, g) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口鼠标捕获状态
     * @return[zh-cn] 是否处于鼠标捕获状态
     *
     * @brief[en] Gets the window mouse-grab state
     * @return[en] Whether the mouse is currently grabbed
     */
    public func getMouseGrab(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_GetWindowMouseGrab_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 设置键盘是否捕获到窗口
     * @param[zh-cn] grabbed true=捕获，false=释放
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets whether the keyboard is grabbed by the window
     * @param[en] grabbed true = grab, false = release
     * @return[en] Whether the operation succeeded
     */
    public func setKeyboardGrab(grabbed: Bool): Bool {
        let resultBox = Box(false)
        let g = grabbed
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowKeyboardGrab_cj(this._window, g) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口键盘捕获状态
     * @return[zh-cn] 是否处于键盘捕获状态
     *
     * @brief[en] Gets the window keyboard-grab state
     * @return[en] Whether the keyboard is currently grabbed
     */
    public func getKeyboardGrab(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_GetWindowKeyboardGrab_cj(this._window) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口安全区域
     * @return[zh-cn] 安全区域矩形；查询失败返回 None
     *
     * @brief[en] Gets the window safe area
     * @return[en] The safe-area rectangle, or None if the query failed
     */
    public func getSafeArea(): Option<SDL_Rect> {
        let noneRect: Option<SDL_Rect> = None
        let rectBox = Box<Option<SDL_Rect>>(noneRect)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) {
                let rp = unsafe { LibC.malloc<SDL_Rect>() }
                unsafe { rp.write(SDL_Rect()) }
                let ok = SDL_GetWindowSafeArea_cj(this._window, rp)
                rectBox.value = if (ok) { Some(unsafe { rp.read() }) } else { noneRect }
                unsafe { LibC.free(rp) }
            }
        })
        return rectBox.value
    }

    /**
     * @brief[zh-cn] 获取窗口表面（用于软件渲染）
     * @return[zh-cn] 窗口表面
     *
     * @brief[en] Gets the window surface (for software rendering)
     * @return[en] The window surface
     */
    public func getSurface(): SDL_Surface {
        let resultBox = Box(CPointer<Unit>())
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_GetWindowSurface_cj(this._window) }
        })
        return resultBox.value
    }

    // =========================================================================
    // 显示器查询（视频子系统，经 SDL SThread 执行）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取所有显示器 ID 列表
     * @return[zh-cn] 显示器 ID 列表
     *
     * @brief[en] Gets the list of all display IDs
     * @return[en] The list of display IDs
     */
    public func getDisplays(): ArrayList<UInt32> {
        let resultBox = Box(ArrayList<UInt32>())
        SDLDispatcher.execSDL({ =>
            let result = ArrayList<UInt32>()
            let countPtr = unsafe { LibC.malloc<Int32>() }
            unsafe { countPtr.write(0) }
            let ids = SDL_GetDisplays_cj(countPtr)
            let count = unsafe { countPtr.read() }
            unsafe { LibC.free(countPtr) }
            if (!ids.isNull()) {
                for (i in 0..count) {
                    result.add(unsafe { (ids + Int64(i)).read() })
                }
                unsafe { LibC.free(ids) }
            }
            resultBox.value = result
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取主显示器 ID
     * @return[zh-cn] 主显示器 ID
     *
     * @brief[en] Gets the primary display ID
     * @return[en] The primary display ID
     */
    public func getPrimaryDisplay(): UInt32 {
        let resultBox = Box(0u32)
        SDLDispatcher.execSDL({ => resultBox.value = SDL_GetPrimaryDisplay_cj() })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 获取显示器边界矩形
     * @param[zh-cn] displayID 显示器 ID
     * @return[zh-cn] 边界矩形；查询失败返回 None
     *
     * @brief[en] Gets the display bounds rectangle
     * @param[en] displayID Display ID
     * @return[en] The bounds rectangle, or None if the query failed
     */
    public func getDisplayBounds(displayID: UInt32): Option<SDL_Rect> {
        let noneRect: Option<SDL_Rect> = None
        let rectBox = Box<Option<SDL_Rect>>(noneRect)
        let id = displayID
        SDLDispatcher.execSDL({ =>
            let rectPtr = unsafe { LibC.malloc<SDL_Rect>() }
            unsafe { rectPtr.write(SDL_Rect()) }
            let ok = SDL_GetDisplayBounds_cj(id, rectPtr)
            rectBox.value = if (ok) { Some(unsafe { rectPtr.read() }) } else { noneRect }
            unsafe { LibC.free(rectPtr) }
        })
        return rectBox.value
    }

    /**
     * @brief[zh-cn] 获取显示器名称
     * @param[zh-cn] displayID 显示器 ID
     * @return[zh-cn] 显示器名称；查询失败返回空字符串
     *
     * @brief[en] Gets the display name
     * @param[en] displayID Display ID
     * @return[en] The display name, or an empty string if the query failed
     */
    public func getDisplayName(displayID: UInt32): String {
        let nameBox = Box("")
        let id = displayID
        SDLDispatcher.execSDL({ =>
            let cs = SDL_GetDisplayName_cj(id)
            nameBox.value = if (cs.isNull()) { "" } else { unsafe { cs.toString() } }
        })
        return nameBox.value
    }

    // =========================================================================
    // 光标控制（经 SDL SThread 执行）
    // =========================================================================

    /**
     * @brief[zh-cn] 设置系统光标
     * @param[zh-cn] cursor 光标类型（SystemCursor）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Sets the system cursor
     * @param[en] cursor Cursor type (SystemCursor)
     * @return[en] Whether the operation succeeded
     */
    public func setSystemCursor(cursor: SystemCursor): Bool {
        let resultBox = Box(false)
        let c = cursor
        SDLDispatcher.execSDL({ =>
            let c2 = SDL_CreateSystemCursor_cj(c.value())
            if (!c2.isNull()) {
                resultBox.value = SDL_SetCursor_cj(c2)
                SDL_DestroyCursor_cj(c2)
            }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 显示光标
     * @return[zh-cn] 是否显示成功
     *
     * @brief[en] Shows the cursor
     * @return[en] Whether the cursor was shown successfully
     */
    public func showCursor(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ => resultBox.value = SDL_ShowCursor_cj() })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 隐藏光标
     * @return[zh-cn] 是否隐藏成功
     *
     * @brief[en] Hides the cursor
     * @return[en] Whether the cursor was hidden successfully
     */
    public func hideCursor(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ => resultBox.value = SDL_HideCursor_cj() })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 查询光标当前是否可见
     * @return[zh-cn] 光标是否可见
     *
     * @brief[en] Checks whether the cursor is currently visible
     * @return[en] Whether the cursor is visible
     */
    public func isCursorVisible(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ => resultBox.value = SDL_CursorVisible_cj() })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 将鼠标移动到窗口内指定位置（窗口坐标）
     * @param[zh-cn] x 窗口内 X 坐标
     * y 窗口内 Y 坐标
     *
     * @brief[en] Moves the mouse to the specified position within the window (window coordinates)
     * @param[en] x The X coordinate inside the window
     * y The Y coordinate inside the window
     */
    public func warpMouseInWindow(x: Float32, y: Float32): Unit {
        let mx = x
        let my = y
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { SDL_WarpMouseInWindow_cj(this._window, mx, my) }
        })
    }

    /**
     * @brief[zh-cn] 设置相对鼠标模式（捕获鼠标，用于 FPS 视角）
     * @param[zh-cn] enabled 是否启用
     * @return[zh-cn] 是否设置成功
     *
     * @brief[en] Sets the relative mouse mode (captures the mouse, used for FPS-style views)
     * @param[en] enabled Whether to enable it
     * @return[en] Whether the operation succeeded
     */
    public func setRelativeMouseMode(enabled: Bool): Bool {
        let resultBox = Box(false)
        let e = enabled
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_SetWindowRelativeMouseMode_cj(this._window, e) }
        })
        return resultBox.value
    }

    /**
     * @brief[zh-cn] 查询当前是否处于相对鼠标模式
     * @return[zh-cn] 是否处于相对鼠标模式
     *
     * @brief[en] Checks whether the window is currently in relative mouse mode
     * @return[en] Whether the window is in relative mouse mode
     */
    public func getRelativeMouseMode(): Bool {
        let resultBox = Box(false)
        SDLDispatcher.execSDL({ =>
            if (!this._window.isNull()) { resultBox.value = SDL_GetWindowRelativeMouseMode_cj(this._window) }
        })
        return resultBox.value
    }

    // =========================================================================
    // 原生句柄获取（平台分支）
    // =========================================================================

    @When[os == "Windows"]
    private func _getNativeHandle(win: SDL_Window): UIntNative {
        let props = SDL_GetWindowProperties_cj(win)
        return this._propPointer(props, SDL_PROP_WINDOW_WIN32_HWND_POINTER)
    }
    // Linux (android)
    @When[os == "Linux" && env == "android"]
    private func _getNativeHandle(win: SDL_Window): UIntNative {
        let props = SDL_GetWindowProperties_cj(win)
        return this._propPointer(props, SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER)
    }
    // Linux (ohos)
    @When[os == "Linux" && env == "ohos"]
    private func _getNativeHandle(win: SDL_Window): UIntNative {
        let props = SDL_GetWindowProperties_cj(win)
        return this._propPointer(props, SDL_PROP_WINDOW_OHOS_WINDOW_POINTER)
    }
    // macOS
    @When[os == "macOS"]
    private func _getNativeHandle(win: SDL_Window): UIntNative {
        let props = SDL_GetWindowProperties_cj(win)
        return this._propPointer(props, SDL_PROP_WINDOW_COCOA_WINDOW_POINTER)
    }
    // iOS
    @When[os == "iOS"]
    private func _getNativeHandle(win: SDL_Window): UIntNative {
        let props = SDL_GetWindowProperties_cj(win)
        return this._propPointer(props, SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER)
    }
    // 兜底：跨平台获取原生窗口句柄（通过 SDL 窗口属性）
    @When[
        os != "Windows" &&
        (os != "Linux" || (env != "android" && env != "ohos")) &&
        os != "macOS" &&
        os != "iOS"
    ]
    private func _getNativeHandle(win: SDL_Window): UIntNative {
        let props = SDL_GetWindowProperties_cj(win)
        let hwnd = this._propPointer(props, SDL_PROP_WINDOW_WIN32_HWND_POINTER)
        if (hwnd != 0) { return hwnd }
        let x11 = this._propNumber(props, SDL_PROP_WINDOW_X11_WINDOW_NUMBER, 0)
        if (x11 != 0) { return UIntNative(x11) }
        let wayland = this._propPointer(props, SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER)
        if (wayland != 0) { return wayland }
        let cocoa = this._propPointer(props, SDL_PROP_WINDOW_COCOA_WINDOW_POINTER)
        if (cocoa != 0) { return cocoa }
        let android = this._propPointer(props, SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER)
        if (android != 0) { return android }
        let uikit = this._propPointer(props, SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER)
        if (uikit != 0) { return uikit }
        let ohos = this._propPointer(props, SDL_PROP_WINDOW_OHOS_WINDOW_POINTER)
        if (ohos != 0) { return ohos }
        return 0
    }

    private func _propNumber(props: UInt32, name: String, def: Int64): Int64 {
        let cs = unsafe { LibC.mallocCString(name) }
        let v = SDL_GetNumberProperty_cj(props, cs, def)
        unsafe { LibC.free(cs) }
        return v
    }

    private func _propPointer(props: UInt32, name: String): UIntNative {
        let cs = unsafe { LibC.mallocCString(name) }
        let p = SDL_GetPointerProperty_cj(props, cs, CPointer<Unit>())
        unsafe { LibC.free(cs) }
        return p.toUIntNative()
    }
}
