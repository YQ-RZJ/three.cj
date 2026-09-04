/**
 * @file[zh-cn] InputEngine 输入引擎（three.window 子包）
 * @brief[zh-cn] 输入引擎：键盘/鼠标/手柄/触摸状态查询的统一门面
 * @explain[zh-cn] 职责：
 * - 作为统一门面，委托给绑定的 WindowEngine 的各 InputProvider
 * - 键盘/鼠标/触摸状态：委托给对应的 Provider（KeyboardProvider/MouseProvider/TouchProvider）
 * - 手柄（Gamepad）：委托给 GamepadProvider
 * 典型用法：
 * let win = WindowEngine()
 * win.start(title: "Hello", width: 800, height: 600)
 * // 注册输入提供者
 * let keyboard = KeyboardProvider()
 * let mouse = MouseProvider()
 * let gamepad = GamepadProvider()
 * win.addInputProvider(keyboard)
 * win.addInputProvider(mouse)
 * win.addInputProvider(gamepad)
 * // 创建输入引擎并绑定窗口
 * let input = InputEngine()
 * input.bindWindow(win)
 * gamepad.openGamepad()
 * while (!win.isCloseRequested()) {
 *   win.beginFrame()
 *   if (input.isKeyDown(SDL_SCANCODE_ESCAPE)) { break }
 *   let axisX = input.getGamepadAxis(GamepadAxis.LeftX)
 *   // ...
 * }
 * gamepad.closeGamepad()
 * win.shutdown()
 *
 * @file[en] InputEngine Input engine (three.window sub-package)
 * @brief[en] Input engine: unified facade for querying keyboard/mouse/gamepad/touch state
 * @explain[en] Responsibilities:
 * - Acts as a unified facade, delegating to the WindowEngine's InputProviders
 * - Keyboard/mouse/touch state: delegated to the corresponding Provider (KeyboardProvider/MouseProvider/TouchProvider)
 * - Gamepad: delegated to GamepadProvider
 */
package three.window

import std.core.*
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] 输入引擎：键盘/鼠标/手柄/触摸状态查询的统一门面
 * @explain[zh-cn] 键盘、鼠标、触摸状态委托给绑定的 WindowEngine 的各 Provider；手柄委托给 GamepadProvider。
 *
 * @brief[en] Input engine: unified facade for keyboard/mouse/gamepad/touch state querying
 * @explain[en] Keyboard, mouse, and touch state are delegated to the bound WindowEngine's Providers;
 * gamepad is delegated to GamepadProvider.
 */
public class InputEngine {
    /// 绑定的窗口引擎（Provider 状态来源）
    private var _window: Option<WindowEngine> = None

    /// 缓存的 Provider 引用（避免每次查询都遍历）
    private var _keyboard: Option<KeyboardProvider> = None
    private var _mouse: Option<MouseProvider> = None
    private var _touch: Option<TouchProvider> = None
    private var _gamepad: Option<GamepadProvider> = None

    /**
     * @brief[zh-cn] 构造输入引擎
     *
     * @brief[en] Constructs the input engine
     */
    public init() {}

    // =========================================================================
    // 绑定
    // =========================================================================

    /**
     * @brief[zh-cn] 绑定窗口引擎（Provider 状态来源）
     * @param[zh-cn] `win` 待绑定的窗口引擎
     *
     * @brief[en] Binds the window engine (Provider state source)
     * @param[en] `win` The window engine to bind
     */
    public func bindWindow(win: WindowEngine): Unit {
        this._window = Some(win)
        // 缓存 Provider 引用
        this._keyboard = win.getProvider<KeyboardProvider>()
        this._mouse = win.getProvider<MouseProvider>()
        this._touch = win.getProvider<TouchProvider>()
        this._gamepad = win.getProvider<GamepadProvider>()
    }

    /**
     * @brief[zh-cn] 获取当前绑定的窗口引擎
     * @return[zh-cn] 绑定的窗口引擎；未绑定时返回 None
     *
     * @brief[en] Gets the currently bound window engine
     * @return[en] The bound window engine, or None if not bound
     */
    public func getWindow(): Option<WindowEngine> {
        return this._window
    }

    // =========================================================================
    // 键盘（委托 KeyboardProvider）
    // =========================================================================

    /**
     * @brief[zh-cn] 查询键盘某键当前是否按下（scancode 为 SDL_SCANCODE_*）
     * @param[zh-cn] `scancode` SDL 扫描码（SDL_SCANCODE_*）
     * @return[zh-cn] 按下返回 true；未绑定窗口或未注册 KeyboardProvider 返回 false
     *
     * @brief[en] Returns whether a keyboard key is currently held down (scancode is SDL_SCANCODE_*)
     * @param[en] `scancode` The SDL scancode (SDL_SCANCODE_*)
     * @return[en] true if held down, or false if no window is bound or no KeyboardProvider registered
     */
    public func isKeyDown(scancode: UInt32): Bool {
        match (this._keyboard) {
            case Some(kb) => kb.isKeyDown(scancode)
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 查询键盘某键本帧是否刚按下（边沿触发）
     * @param[zh-cn] `scancode` SDL 扫描码（SDL_SCANCODE_*）
     * @return[zh-cn] 刚按下返回 true；未绑定窗口返回 false
     *
     * @brief[en] Returns whether a keyboard key was just pressed this frame (edge-triggered)
     * @param[en] `scancode` The SDL scancode (SDL_SCANCODE_*)
     * @return[en] true if just pressed, or false if no window is bound
     */
    public func isKeyPressed(scancode: UInt32): Bool {
        match (this._keyboard) {
            case Some(kb) => kb.isKeyPressed(scancode)
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 查询键盘某键本帧是否刚释放（边沿触发）
     * @param[zh-cn] `scancode` SDL 扫描码（SDL_SCANCODE_*）
     * @return[zh-cn] 刚释放返回 true；未绑定窗口返回 false
     *
     * @brief[en] Returns whether a keyboard key was just released this frame (edge-triggered)
     * @param[en] `scancode` The SDL scancode (SDL_SCANCODE_*)
     * @return[en] true if just released, or false if no window is bound
     */
    public func isKeyReleased(scancode: UInt32): Bool {
        match (this._keyboard) {
            case Some(kb) => kb.isKeyReleased(scancode)
            case None => false
        }
    }

    // =========================================================================
    // 鼠标（委托 MouseProvider）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取鼠标 X 坐标（相对窗口）
     * @return[zh-cn] 鼠标 X 坐标；未绑定窗口返回 0.0
     *
     * @brief[en] Gets the mouse X coordinate relative to the window
     * @return[en] The mouse X coordinate, or 0.0 if no window is bound
     */
    public func getMouseX(): Float32 {
        match (this._mouse) {
            case Some(m) => m.getMouseX()
            case None => 0.0
        }
    }

    /**
     * @brief[zh-cn] 获取鼠标 Y 坐标（相对窗口）
     * @return[zh-cn] 鼠标 Y 坐标；未绑定窗口返回 0.0
     *
     * @brief[en] Gets the mouse Y coordinate relative to the window
     * @return[en] The mouse Y coordinate, or 0.0 if no window is bound
     */
    public func getMouseY(): Float32 {
        match (this._mouse) {
            case Some(m) => m.getMouseY()
            case None => 0.0
        }
    }

    /**
     * @brief[zh-cn] 获取鼠标本帧 X 位移
     * @return[zh-cn] 鼠标 X 位移；未绑定窗口返回 0.0
     *
     * @brief[en] Gets the mouse X movement delta this frame
     * @return[en] The mouse X delta, or 0.0 if no window is bound
     */
    public func getMouseDX(): Float32 {
        match (this._mouse) {
            case Some(m) => m.getMouseDX()
            case None => 0.0
        }
    }

    /**
     * @brief[zh-cn] 获取鼠标本帧 Y 位移
     * @return[zh-cn] 鼠标 Y 位移；未绑定窗口返回 0.0
     *
     * @brief[en] Gets the mouse Y movement delta this frame
     * @return[en] The mouse Y delta, or 0.0 if no window is bound
     */
    public func getMouseDY(): Float32 {
        match (this._mouse) {
            case Some(m) => m.getMouseDY()
            case None => 0.0
        }
    }

    /**
     * @brief[zh-cn] 查询鼠标按键是否按下（button 为 SDL_BUTTON_*）
     * @param[zh-cn] `button` SDL 鼠标按键（SDL_BUTTON_*）
     * @return[zh-cn] 按下返回 true；未绑定窗口返回 false
     *
     * @brief[en] Returns whether a mouse button is held down (button is SDL_BUTTON_*)
     * @param[en] `button` The SDL mouse button (SDL_BUTTON_*)
     * @return[en] true if held down, or false if no window is bound
     */
    public func isMouseButtonDown(button: UInt8): Bool {
        match (this._mouse) {
            case Some(m) => m.isMouseButtonDown(button)
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 获取滚轮水平滚动量（本帧累积）
     * @return[zh-cn] 水平滚动量；未绑定窗口返回 0.0
     *
     * @brief[en] Gets the horizontal wheel scroll amount (accumulated this frame)
     * @return[en] The horizontal scroll amount, or 0.0 if no window is bound
     */
    public func getWheelX(): Float32 {
        match (this._mouse) {
            case Some(m) => m.getWheelX()
            case None => 0.0
        }
    }

    /**
     * @brief[zh-cn] 获取滚轮垂直滚动量（本帧累积）
     * @return[zh-cn] 垂直滚动量；未绑定窗口返回 0.0
     *
     * @brief[en] Gets the vertical wheel scroll amount (accumulated this frame)
     * @return[en] The vertical scroll amount, or 0.0 if no window is bound
     */
    public func getWheelY(): Float32 {
        match (this._mouse) {
            case Some(m) => m.getWheelY()
            case None => 0.0
        }
    }

    // =========================================================================
    // 触摸（委托 TouchProvider）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取当前活跃触摸点数量
     * @return[zh-cn] 触摸点数量；未绑定窗口返回 0
     *
     * @brief[en] Gets the number of active touch points
     * @return[en] The number of touch points, or 0 if no window is bound
     */
    public func getTouchCount(): Int64 {
        match (this._touch) {
            case Some(t) => t.getTouchCount()
            case None => 0i64
        }
    }

    /**
     * @brief[zh-cn] 获取指定索引的触摸点
     * @param[zh-cn] index 触摸点索引（0-based）
     * @return[zh-cn] 触摸点数据；索引越界或未绑定窗口返回 None
     *
     * @brief[en] Gets the touch point at the specified index
     * @param[en] index Touch point index (0-based)
     * @return[en] The touch point data, or None if index is out of bounds or no window is bound
     */
    public func getTouch(index: Int64): Option<TouchPoint> {
        match (this._touch) {
            case Some(t) => t.getTouch(index)
            case None => None
        }
    }

    /**
     * @brief[zh-cn] 获取指定 fingerID 的触摸点
     * @param[zh-cn] fingerID 手指实例 ID
     * @return[zh-cn] 触摸点数据；未找到或未绑定窗口返回 None
     *
     * @brief[en] Gets the touch point with the specified finger ID
     * @param[en] fingerID Finger instance ID
     * @return[en] The touch point data, or None if not found or no window is bound
     */
    public func getTouchByID(fingerID: Int64): Option<TouchPoint> {
        match (this._touch) {
            case Some(t) => t.getTouchByID(fingerID)
            case None => None
        }
    }

    // =========================================================================
    // 手柄（委托 GamepadProvider）
    // =========================================================================

    /**
     * @brief[zh-cn] 打开第一个已连接的手柄
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Opens the first connected gamepad
     * @return[en] Whether the gamepad was opened successfully
     */
    public func openGamepad(): Bool {
        return this.openGamepadAt(0)
    }

    /**
     * @brief[zh-cn] 打开指定索引的手柄
     * @param[zh-cn] `index` 手柄索引（从 0 开始）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Opens the gamepad at the specified index
     * @param[en] `index` The gamepad index (0-based)
     * @return[en] Whether the gamepad was opened successfully
     */
    public func openGamepadAt(index: Int32): Bool {
        match (this._gamepad) {
            case Some(gp) => gp.openGamepadAt(index)
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 关闭手柄
     *
     * @brief[en] Closes the gamepad
     */
    public func closeGamepad(): Unit {
        match (this._gamepad) {
            case Some(gp) => gp.closeGamepad()
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 查询手柄是否已连接
     * @return[zh-cn] 已连接返回 true；未打开返回 false
     *
     * @brief[en] Returns whether the gamepad is connected
     * @return[en] true if connected, or false if not opened
     */
    public func isGamepadConnected(): Bool {
        match (this._gamepad) {
            case Some(gp) => gp.isGamepadConnected()
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 获取手柄实例 ID
     * @return[zh-cn] 手柄实例 ID；未打开返回 -1
     *
     * @brief[en] Gets the gamepad instance ID
     * @return[en] The gamepad instance ID, or -1 if not opened
     */
    public func getGamepadInstanceID(): Int64 {
        match (this._gamepad) {
            case Some(gp) => gp.getGamepadInstanceID()
            case None => -1i64
        }
    }

    /**
     * @brief[zh-cn] 获取手柄轴值（范围 -32768 ~ 32767）
     * @param[zh-cn] `axis` 轴（如 GamepadAxis.LeftX）
     * @return[zh-cn] 轴值；未连接返回 0
     *
     * @brief[en] Gets the gamepad axis value (range -32768 ~ 32767)
     * @param[en] `axis` The axis (e.g. GamepadAxis.LeftX)
     * @return[en] The axis value, or 0 if not connected
     */
    public func getGamepadAxis(axis: GamepadAxis): Int16 {
        match (this._gamepad) {
            case Some(gp) => gp.getGamepadAxis(axis)
            case None => 0i16
        }
    }

    /**
     * @brief[zh-cn] 获取手柄按键状态
     * @param[zh-cn] `button` 按键（如 GamepadButton.South）
     * @return[zh-cn] 是否按下；未连接返回 false
     *
     * @brief[en] Gets the gamepad button state
     * @param[en] `button` The button (e.g. GamepadButton.South)
     * @return[en] true if pressed, or false if not connected
     */
    public func getGamepadButton(button: GamepadButton): Bool {
        match (this._gamepad) {
            case Some(gp) => gp.getGamepadButton(button)
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 获取手柄名称
     * @return[zh-cn] 手柄名称；未连接返回空串
     *
     * @brief[en] Gets the gamepad name
     * @return[en] The gamepad name, or an empty string if not connected
     */
    public func getGamepadName(): String {
        match (this._gamepad) {
            case Some(gp) => gp.getGamepadName()
            case None => ""
        }
    }
}
