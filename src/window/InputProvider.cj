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
 * @file[zh-cn] InputProvider 可插拔输入提供者基类
 * @brief[zh-cn] 输入提供者抽象基类，每种输入设备（键盘/鼠标/触摸/手柄等）继承此类实现独立的输入处理
 * @explain[zh-cn] 职责：
 * - 管理特定输入设备的状态
 * - 处理该设备相关的 SDL 事件
 * - 每帧开始/结束时进行状态轮询和重置
 * - 提供查询接口供 InputEngine 或 WindowEngine 调用
 *
 * 典型用法：
 * class MyCustomProvider <: InputProvider {
 *   override func onEvent(evt: DispatchEvent): Unit {
 *     if (evt.`type` == SDL_EVENT_MY_CUSTOM) {
 *       // 处理自定义事件
 *     }
 *   }
 * }
 * let win = WindowEngine()
 * win.addInputProvider(MyCustomProvider())
 *
 * @file[en] InputProvider Pluggable input provider base class
 * @brief[en] Abstract base class for input providers. Each input device (keyboard/mouse/touch/gamepad/etc.)
 * inherits this class to implement independent input handling
 * @explain[en] Responsibilities:
 * - Manage state for a specific input device
 * - Handle SDL events related to this device
 * - Poll and reset state at frame begin/end
 * - Provide query APIs for InputEngine or WindowEngine
 *
 * Typical usage:
 * class MyCustomProvider <: InputProvider {
 *   override func onEvent(evt: DispatchEvent): Unit {
 *     if (evt.`type` == SDL_EVENT_MY_CUSTOM) {
 *       // Handle custom event
 *     }
 *   }
 * }
 * let win = WindowEngine()
 * win.addInputProvider(MyCustomProvider())
 */
package three.window

import std.core.*

/**
 * @brief[zh-cn] 输入提供者抽象基类
 * @explain[zh-cn] 所有输入设备提供者（键盘/鼠标/触摸/手柄等）必须继承此类并实现相应方法。
 * WindowEngine 会在每帧的生命周期中调用这些方法：init → (beginFrame → onEvent* → endFrame)* → shutdown
 *
 * @brief[en] Abstract base class for input providers
 * @explain[en] All input device providers (keyboard/mouse/touch/gamepad/etc.) must inherit this class
 * and implement the corresponding methods. WindowEngine calls these methods in each frame's lifecycle:
 * init → (beginFrame → onEvent* → endFrame)* → shutdown
 */
public open class InputProvider {
    /// 绑定的窗口引擎
    private var _window: Option<WindowEngine> = None

    /**
     * @brief[zh-cn] 初始化提供者（绑定窗口后调用）
     *
     * @brief[en] Initializes the provider (called after binding to window)
     */
    public open func `init`(): Unit {}

    /**
     * @brief[zh-cn] 每帧开始：轮询设备状态（如手柄）+ 准备接收事件
     *
     * @brief[en] Frame begin: poll device state (e.g. gamepad) + prepare to receive events
     */
    public open func beginFrame(): Unit {}

    /**
     * @brief[zh-cn] 处理一条分发事件
     * @param[zh-cn] evt 分发器投递的轻量事件
     *
     * @brief[en] Processes a dispatched event
     * @param[en] evt The lightweight event dispatched by the dispatcher
     */
    public open func onEvent(evt: DispatchEvent): Unit {}

    /**
     * @brief[zh-cn] 每帧结束：重置边沿状态（如 pressed/released）和累积量（如位移/滚轮）
     *
     * @brief[en] Frame end: reset edge states (e.g. pressed/released) and accumulated values (e.g. motion/wheel)
     */
    public open func endFrame(): Unit {}

    /**
     * @brief[zh-cn] 清理资源（窗口关闭时调用）
     *
     * @brief[en] Cleans up resources (called when window closes)
     */
    public open func shutdown(): Unit {}

    /**
     * @brief[zh-cn] 绑定到窗口引擎
     * @param[zh-cn] win 窗口引擎实例
     *
     * @brief[en] Binds to a window engine
     * @param[en] win The window engine instance
     */
    internal func bindWindow(win: WindowEngine): Unit {
        this._window = Some(win)
    }

    /**
     * @brief[zh-cn] 获取绑定的窗口引擎
     * @return[zh-cn] 绑定的窗口引擎；未绑定时返回 None
     *
     * @brief[en] Gets the bound window engine
     * @return[en] The bound window engine, or None if not bound
     */
    public func getWindow(): Option<WindowEngine> {
        return this._window
    }

    /**
     * @brief[zh-cn] 是否已绑定窗口
     *
     * @brief[en] Whether a window is bound
     */
    public func isBound(): Bool {
        return this._window.isSome()
    }
}
