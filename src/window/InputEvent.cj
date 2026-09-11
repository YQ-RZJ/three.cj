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
 * @file[zh-cn] InputEvent 输入事件类型定义
 * @brief[zh-cn] 本文件定义 three 侧统一的输入事件结构体与监听器接口
 * @explain[zh-cn] 由 WindowEngine 事件泵（窗口线程）解析 SDL 事件后生成，分发给 InputEngine（更新状态）
 * 与已注册的 IInputListener（回调）。键盘扫描码直接使用 sdl4cj.sdl 的 SDL_SCANCODE_* 常量
 * （UInt32），与 SDL3 物理键码一一对应，保证跨平台一致。
 *
 * @file[en] InputEvent Input event type definitions
 * @brief[en] This file defines the unified input event structures and listener interface on the three side
 * @explain[en] The WindowEngine event pump (window thread) parses SDL events and produces these events,
 * then dispatches them to the InputEngine (to update state) and to registered IInputListener
 * callbacks. Keyboard scan codes reuse the SDL_SCANCODE_* constants from sdl4cj.sdl (UInt32),
 * mapping 1:1 to SDL3 physical key codes for cross-platform consistency.
 */
package three.window

/**
 * @brief[zh-cn] 键盘事件
 * @explain[zh-cn] 携带键盘按键的物理键码、虚拟键码、修饰键掩码与按下/重复状态。
 *
 * @brief[en] Keyboard event
 * @explain[en] Carries the key's physical scan code, virtual key code, modifier mask and pressed/repeat state.
 */
public class KeyEvent {
    /**
     * @brief[zh-cn] SDL 物理键码（SDL_SCANCODE_*）
     *
     * @brief[en] SDL physical key code (SDL_SCANCODE_*)
     */
    public var scancode: UInt32 = 0
    /**
     * @brief[zh-cn] SDL 虚拟键码
     *
     * @brief[en] SDL virtual key code
     */
    public var key: UInt32 = 0
    /**
     * @brief[zh-cn] 修饰键掩码（SDL_KMOD_*）
     *
     * @brief[en] Modifier key mask (SDL_KMOD_*)
     */
    public var mod: UInt16 = 0
    /**
     * @brief[zh-cn] 是否按下
     *
     * @brief[en] Whether the key is down
     */
    public var down: Bool = false
    /**
     * @brief[zh-cn] 是否重复触发
     *
     * @brief[en] Whether the event is a repeat
     */
    public var repeat: Bool = false

    /**
     * @brief[zh-cn] 构造键盘事件
     * @param[zh-cn] scancode SDL 物理键码（SDL_SCANCODE_*）
     * key SDL 虚拟键码
     * mod 修饰键掩码（SDL_KMOD_*）
     * down 是否按下
     * repeat 是否重复触发
     *
     * @brief[en] Constructs a keyboard event
     * @param[en] scancode SDL physical key code (SDL_SCANCODE_*)
     * key SDL virtual key code
     * mod Modifier key mask (SDL_KMOD_*)
     * down Whether the key is down
     * repeat Whether the event is a repeat
     */
    public init(scancode!: UInt32, key!: UInt32, mod!: UInt16,
                down!: Bool, repeat!: Bool) {
        this.scancode = scancode
        this.key = key
        this.mod = mod
        this.down = down
        this.repeat = repeat
    }
}

/**
 * @brief[zh-cn] 鼠标移动事件
 * @explain[zh-cn] 携带鼠标相对窗口的坐标与本帧位移。
 *
 * @brief[en] Mouse motion event
 * @explain[en] Carries the mouse position relative to the window and this frame's delta.
 */
public class MouseMotionEvent {
    /**
     * @brief[zh-cn] 相对窗口的 X 坐标
     *
     * @brief[en] X position relative to the window
     */
    public var x: Float32 = 0.0
    /**
     * @brief[zh-cn] 相对窗口的 Y 坐标
     *
     * @brief[en] Y position relative to the window
     */
    public var y: Float32 = 0.0
    /**
     * @brief[zh-cn] 相对上一帧的 X 位移
     *
     * @brief[en] X delta relative to the previous frame
     */
    public var dx: Float32 = 0.0
    /**
     * @brief[zh-cn] 相对上一帧的 Y 位移
     *
     * @brief[en] Y delta relative to the previous frame
     */
    public var dy: Float32 = 0.0

    /**
     * @brief[zh-cn] 构造鼠标移动事件
     * @param[zh-cn] x 相对窗口的 X 坐标
     * y 相对窗口的 Y 坐标
     * dx 相对上一帧的 X 位移
     * dy 相对上一帧的 Y 位移
     *
     * @brief[en] Constructs a mouse motion event
     * @param[en] x X position relative to the window
     * y Y position relative to the window
     * dx X delta relative to the previous frame
     * dy Y delta relative to the previous frame
     */
    public init(x!: Float32, y!: Float32, dx!: Float32, dy!: Float32) {
        this.x = x
        this.y = y
        this.dx = dx
        this.dy = dy
    }
}

/**
 * @brief[zh-cn] 鼠标按键事件
 * @explain[zh-cn] 携带鼠标按键索引、按下状态、点击次数与相对窗口坐标。
 *
 * @brief[en] Mouse button event
 * @explain[en] Carries the mouse button index, pressed state, click count and position relative to the window.
 */
public class MouseButtonEvent {
    /**
     * @brief[zh-cn] 鼠标按键索引（SDL_BUTTON_LEFT=1 / RIGHT=3 / MIDDLE=2）
     *
     * @brief[en] Mouse button index (SDL_BUTTON_LEFT=1 / RIGHT=3 / MIDDLE=2)
     */
    public var button: UInt8 = 0
    /**
     * @brief[zh-cn] 是否按下
     *
     * @brief[en] Whether the button is down
     */
    public var down: Bool = false
    /**
     * @brief[zh-cn] 点击次数（1 单击，2 双击）
     *
     * @brief[en] Click count (1 = single, 2 = double)
     */
    public var clicks: UInt8 = 0
    /**
     * @brief[zh-cn] 相对窗口的 X 坐标
     *
     * @brief[en] X position relative to the window
     */
    public var x: Float32 = 0.0
    /**
     * @brief[zh-cn] 相对窗口的 Y 坐标
     *
     * @brief[en] Y position relative to the window
     */
    public var y: Float32 = 0.0

    /**
     * @brief[zh-cn] 构造鼠标按键事件
     * @param[zh-cn] button 鼠标按键索引（SDL_BUTTON_LEFT=1 / RIGHT=3 / MIDDLE=2）
     * down 是否按下
     * clicks 点击次数（1 单击，2 双击）
     * x 相对窗口的 X 坐标
     * y 相对窗口的 Y 坐标
     *
     * @brief[en] Constructs a mouse button event
     * @param[en] button Mouse button index (SDL_BUTTON_LEFT=1 / RIGHT=3 / MIDDLE=2)
     * down Whether the button is down
     * clicks Click count (1 = single, 2 = double)
     * x X position relative to the window
     * y Y position relative to the window
     */
    public init(button!: UInt8, down!: Bool, clicks!: UInt8,
                x!: Float32, y!: Float32) {
        this.button = button
        this.down = down
        this.clicks = clicks
        this.x = x
        this.y = y
    }
}

/**
 * @brief[zh-cn] 鼠标滚轮事件
 * @explain[zh-cn] 携带滚轮水平与垂直滚动量。
 *
 * @brief[en] Mouse wheel event
 * @explain[en] Carries the horizontal and vertical wheel scroll amounts.
 */
public class MouseWheelEvent {
    /**
     * @brief[zh-cn] 水平滚动量（通常 -1/0/1）
     *
     * @brief[en] Horizontal scroll amount (typically -1/0/1)
     */
    public var x: Float32 = 0.0
    /**
     * @brief[zh-cn] 垂直滚动量（通常 -1/0/1，向上为正）
     *
     * @brief[en] Vertical scroll amount (typically -1/0/1, positive upward)
     */
    public var y: Float32 = 0.0

    /**
     * @brief[zh-cn] 构造鼠标滚轮事件
     * @param[zh-cn] x 水平滚动量（通常 -1/0/1）
     * y 垂直滚动量（通常 -1/0/1，向上为正）
     *
     * @brief[en] Constructs a mouse wheel event
     * @param[en] x Horizontal scroll amount (typically -1/0/1)
     * y Vertical scroll amount (typically -1/0/1, positive upward)
     */
    public init(x!: Float32, y!: Float32) {
        this.x = x
        this.y = y
    }
}

/**
 * @brief[zh-cn] 窗口事件
 * @explain[zh-cn] 携带窗口事件类型与两个可选的数据字段。
 *
 * @brief[en] Window event
 * @explain[en] Carries the window event type and two optional data fields.
 */
public class WindowEvent {
    /**
     * @brief[zh-cn] 窗口事件类型（SDL_EVENT_WINDOW_*）
     *
     * @brief[en] Window event type (SDL_EVENT_WINDOW_*)
     */
    public var `type`: UInt32 = 0
    /**
     * @brief[zh-cn] 事件相关数据 1（如 resize 的宽度）
     *
     * @brief[en] Event data 1 (e.g. width for resize)
     */
    public var data1: Int32 = 0
    /**
     * @brief[zh-cn] 事件相关数据 2（如 resize 的高度）
     *
     * @brief[en] Event data 2 (e.g. height for resize)
     */
    public var data2: Int32 = 0

    /**
     * @brief[zh-cn] 构造窗口事件
     * @param[zh-cn] `type` 窗口事件类型（SDL_EVENT_WINDOW_*）
     * data1 事件相关数据 1（如 resize 的宽度）
     * data2 事件相关数据 2（如 resize 的高度）
     *
     * @brief[en] Constructs a window event
     * @param[en] `type` Window event type (SDL_EVENT_WINDOW_*)
     * data1 Event data 1 (e.g. width for resize)
     * data2 Event data 2 (e.g. height for resize)
     */
    public init(`type`!: UInt32, data1!: Int32, data2!: Int32) {
        this.`type` = `type`
        this.data1 = data1
        this.data2 = data2
    }
}

/**
 * @brief[zh-cn] 触摸事件
 * @explain[zh-cn] 携带触摸手指实例 ID、归一化坐标/位移与压力。
 *
 * @brief[en] Touch event
 * @explain[en] Carries the finger instance ID, normalized position/delta and pressure.
 */
public class TouchEvent {
    /**
     * @brief[zh-cn] 触摸手指实例 ID
     *
     * @brief[en] Touch finger instance ID
     */
    public var fingerID: Int64 = 0
    /**
     * @brief[zh-cn] 归一化 X 坐标（0~1，相对窗口）
     *
     * @brief[en] Normalized X position (0~1, relative to the window)
     */
    public var x: Float32 = 0.0
    /**
     * @brief[zh-cn] 归一化 Y 坐标（0~1，相对窗口）
     *
     * @brief[en] Normalized Y position (0~1, relative to the window)
     */
    public var y: Float32 = 0.0
    /**
     * @brief[zh-cn] 归一化 X 位移
     *
     * @brief[en] Normalized X delta
     */
    public var dx: Float32 = 0.0
    /**
     * @brief[zh-cn] 归一化 Y 位移
     *
     * @brief[en] Normalized Y delta
     */
    public var dy: Float32 = 0.0
    /**
     * @brief[zh-cn] 压力（0~1）
     *
     * @brief[en] Pressure (0~1)
     */
    public var pressure: Float32 = 0.0

    /**
     * @brief[zh-cn] 构造触摸事件
     * @param[zh-cn] fingerID 触摸手指实例 ID
     * x 归一化 X 坐标（0~1，相对窗口）
     * y 归一化 Y 坐标（0~1，相对窗口）
     * dx 归一化 X 位移
     * dy 归一化 Y 位移
     * pressure 压力（0~1）
     *
     * @brief[en] Constructs a touch event
     * @param[en] fingerID Touch finger instance ID
     * x Normalized X position (0~1, relative to the window)
     * y Normalized Y position (0~1, relative to the window)
     * dx Normalized X delta
     * dy Normalized Y delta
     * pressure Pressure (0~1)
     */
    public init(fingerID!: Int64, x!: Float32, y!: Float32,
                dx!: Float32, dy!: Float32, pressure!: Float32) {
        this.fingerID = fingerID
        this.x = x
        this.y = y
        this.dx = dx
        this.dy = dy
        this.pressure = pressure
    }
}

/**
 * @brief[zh-cn] 输入监听器基类
 * @explain[zh-cn] 实现此类的回调并注册到 WindowEngine（addInputListener），即可在窗口线程收到解析后的
 * 输入事件回调。所有回调都在窗口线程执行，回调内应避免长时间阻塞；如需跨线程传递，请自行拷贝数据。
 *
 * @brief[en] Input listener base class
 * @explain[en] Implement the callbacks and register with WindowEngine (addInputListener) to receive parsed
 * input event callbacks on the window thread. All callbacks run on the window thread; avoid blocking
 * for a long time inside them. Copy data yourself if you need to pass it across threads.
 */
public open class InputListener {
    /**
     * @brief[zh-cn] 监听器唯一 ID 分配器（用于引用比较）
     *
     * @brief[en] Listener unique ID allocator (used for reference comparison)
     */
    private static var _nextId: Int64 = 0
    /**
     * @brief[zh-cn] 本实例唯一 ID
     *
     * @brief[en] Unique ID of this instance
     */
    private var _listenerId: Int64 = 0

    /**
     * @brief[zh-cn] 构造监听器（自动分配唯一 ID）
     *
     * @brief[en] Constructs a listener (automatically allocates a unique ID)
     */
    public init() {
        this._listenerId = InputListener._nextId
        InputListener._nextId += 1
    }

    /**
     * @brief[zh-cn] 引用比较（用于 removeInputListener 精确移除）
     * @param[zh-cn] other 与之比较的监听器
     * @return[zh-cn] 两个监听器是否引用同一实例
     *
     * @brief[en] Reference comparison (for precise removal via removeInputListener)
     * @param[en] other The listener to compare with
     * @return[en] Whether the two listeners refer to the same instance
     */
    public operator func ==(other: InputListener): Bool {
        return this._listenerId == other._listenerId
    }

    /**
     * @brief[zh-cn] 键盘事件回调
     * @param[zh-cn] evt 键盘事件
     *
     * @brief[en] Keyboard event callback
     * @param[en] evt The keyboard event
     */
    public open func onKeyEvent(evt: KeyEvent): Unit {}
    /**
     * @brief[zh-cn] 鼠标移动回调
     * @param[zh-cn] evt 鼠标移动事件
     *
     * @brief[en] Mouse motion callback
     * @param[en] evt The mouse motion event
     */
    public open func onMouseMotion(evt: MouseMotionEvent): Unit {}
    /**
     * @brief[zh-cn] 鼠标按键回调
     * @param[zh-cn] evt 鼠标按键事件
     *
     * @brief[en] Mouse button callback
     * @param[en] evt The mouse button event
     */
    public open func onMouseButton(evt: MouseButtonEvent): Unit {}
    /**
     * @brief[zh-cn] 鼠标滚轮回调
     * @param[zh-cn] evt 鼠标滚轮事件
     *
     * @brief[en] Mouse wheel callback
     * @param[en] evt The mouse wheel event
     */
    public open func onMouseWheel(evt: MouseWheelEvent): Unit {}
    /**
     * @brief[zh-cn] 窗口事件回调
     * @param[zh-cn] evt 窗口事件
     *
     * @brief[en] Window event callback
     * @param[en] evt The window event
     */
    public open func onWindowEvent(evt: WindowEvent): Unit {}
    /**
     * @brief[zh-cn] 触摸事件回调
     * @param[zh-cn] evt 触摸事件
     *
     * @brief[en] Touch event callback
     * @param[en] evt The touch event
     */
    public open func onTouchEvent(evt: TouchEvent): Unit {}
}
