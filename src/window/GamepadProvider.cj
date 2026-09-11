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
 * @file[zh-cn] GamepadProvider 手柄输入提供者
 * @brief[zh-cn] 手柄输入状态管理，独立于窗口事件泵，通过 SDL API 直接轮询手柄状态
 * @explain[zh-cn] 职责：
 * - 打开/关闭手柄设备
 * - 每帧轮询手柄轴值和按键状态
 * - 提供 getGamepadAxis/getGamepadButton 查询接口
 *
 * 注意：手柄事件（如连接/断开）通过 SDL 事件泵分发，但轴值和按键状态需要主动轮询。
 *
 * @file[en] GamepadProvider Gamepad input provider
 * @brief[en] Gamepad input state management, independent of the window event pump, polls gamepad state directly via SDL API
 * @explain[en] Responsibilities:
 * - Open/close gamepad devices
 * - Poll gamepad axis values and button states every frame
 * - Provide getGamepadAxis/getGamepadButton query APIs
 *
 * Note: Gamepad events (e.g. connect/disconnect) are dispatched through the SDL event pump,
 * but axis values and button states need to be actively polled.
 */
package three.window

import std.core.*
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] 手柄输入提供者
 * @explain[zh-cn] 管理手柄设备，轮询手柄状态，提供查询接口。
 *
 * @brief[en] Gamepad input provider
 * @explain[en] Manages gamepad devices, polls gamepad state, provides query APIs.
 */
public class GamepadProvider <: InputProvider {
    /// 手柄句柄
    private var _gamepad: SDL_Gamepad = CPointer<Unit>()
    /// 手柄实例 ID（-1 表示未打开）
    private var _gamepadInstanceID: Int64 = -1

    /**
     * @brief[zh-cn] 构造手柄提供者
     *
     * @brief[en] Constructs a gamepad provider
     */
    public init() {}

    /**
     * @brief[zh-cn] 初始化（窗口绑定后调用）
     *
     * @brief[en] Initializes (called after window binding)
     */
    public override func `init`(): Unit {
        // 手柄在 init 时不自动打开，需要用户显式调用 openGamepad
    }

    /**
     * @brief[zh-cn] 每帧开始：轮询手柄状态
     * @explain[zh-cn] 手柄轴值和按键状态需要每帧轮询，不像键盘/鼠标通过事件更新。
     *
     * @brief[en] Frame begin: poll gamepad state
     * @explain[en] Gamepad axis values and button states need to be polled every frame,
     * unlike keyboard/mouse which are updated via events.
     */
    public override func beginFrame(): Unit {
        // 手柄状态通过 SDL_GetGamepadAxis/SDL_GetGamepadButton 实时查询
        // 无需在 beginFrame 中缓存，直接查询即可
    }

    /**
     * @brief[zh-cn] 清理资源
     *
     * @brief[en] Cleans up resources
     */
    public override func shutdown(): Unit {
        this.closeGamepad()
    }

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
     * @param[zh-cn] index 手柄索引（从 0 开始）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Opens the gamepad at the specified index
     * @param[en] index The gamepad index (0-based)
     * @return[en] Whether the gamepad was opened successfully
     */
    public func openGamepadAt(index: Int32): Bool {
        // 已打开则先关闭
        if (!this._gamepad.isNull()) {
            SDL_CloseGamepad_cj(this._gamepad)
            this._gamepad = CPointer<Unit>()
            this._gamepadInstanceID = -1
        }
        let countPtr = unsafe { LibC.malloc<Int32>() }
        unsafe { countPtr.write(0) }
        let ids = SDL_GetGamepads_cj(countPtr)
        let count = unsafe { countPtr.read() }
        unsafe { LibC.free(countPtr) }
        if (count <= 0 || index >= count) { return false }
        let id = unsafe { (ids + Int64(index)).read() }
        let gp = SDL_OpenGamepad_cj(id)
        if (gp.isNull()) { return false }
        this._gamepad = gp
        this._gamepadInstanceID = Int64(id)
        return true
    }

    /**
     * @brief[zh-cn] 关闭手柄
     *
     * @brief[en] Closes the gamepad
     */
    public func closeGamepad(): Unit {
        if (!this._gamepad.isNull()) {
            SDL_CloseGamepad_cj(this._gamepad)
            this._gamepad = CPointer<Unit>()
        }
        this._gamepadInstanceID = -1
    }

    /**
     * @brief[zh-cn] 查询手柄是否已连接
     * @return[zh-cn] 已连接返回 true；未打开返回 false
     *
     * @brief[en] Queries whether the gamepad is connected
     * @return[en] true if connected, or false if not opened
     */
    public func isGamepadConnected(): Bool {
        if (this._gamepad.isNull()) { return false }
        return SDL_GamepadConnected_cj(this._gamepad)
    }

    /**
     * @brief[zh-cn] 获取手柄实例 ID
     * @return[zh-cn] 手柄实例 ID；未打开返回 -1
     *
     * @brief[en] Gets the gamepad instance ID
     * @return[en] The gamepad instance ID, or -1 if not opened
     */
    public func getGamepadInstanceID(): Int64 {
        return this._gamepadInstanceID
    }

    /**
     * @brief[zh-cn] 获取手柄轴值（范围 -32768 ~ 32767）
     * @param[zh-cn] axis 轴（如 GamepadAxis.LeftX）
     * @return[zh-cn] 轴值；未连接返回 0
     *
     * @brief[en] Gets the gamepad axis value (range -32768 ~ 32767)
     * @param[en] axis The axis (e.g. GamepadAxis.LeftX)
     * @return[en] The axis value, or 0 if not connected
     */
    public func getGamepadAxis(axis: GamepadAxis): Int16 {
        if (this._gamepad.isNull()) { return 0 }
        return SDL_GetGamepadAxis_cj(this._gamepad, axis.value())
    }

    /**
     * @brief[zh-cn] 获取手柄按键状态
     * @param[zh-cn] button 按键（如 GamepadButton.South）
     * @return[zh-cn] 是否按下；未连接返回 false
     *
     * @brief[en] Gets the gamepad button state
     * @param[en] button The button (e.g. GamepadButton.South)
     * @return[en] true if pressed, or false if not connected
     */
    public func getGamepadButton(button: GamepadButton): Bool {
        if (this._gamepad.isNull()) { return false }
        return SDL_GetGamepadButton_cj(this._gamepad, button.value())
    }

    /**
     * @brief[zh-cn] 获取手柄名称
     * @return[zh-cn] 手柄名称；未连接返回空串
     *
     * @brief[en] Gets the gamepad name
     * @return[en] The gamepad name, or an empty string if not connected
     */
    public func getGamepadName(): String {
        if (this._gamepad.isNull()) { return "" }
        let cs = SDL_GetGamepadName_cj(this._gamepad)
        return unsafe { cs.toString() }
    }
}
