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
 * @file[zh-cn] Enums three.window 自有的窗口/输入枚举（替代直接依赖 sdl4cj 的 SDL_* 枚举）
 * @brief[zh-cn] 本文件定义窗口/输入相关的枚举类型
 * @explain[zh-cn] 设计目标：上层（WindowEngine/InputEngine 使用者）只需依赖 three，无需 import sdl4cj。
 * 数值与 SDL3 一一对应（跨平台一致），由 WindowEngine/InputEngine 内部映射。
 *
 * @file[en] Enums three.window own window/input enums (replacing direct dependencies on the SDL_* enums from sdl4cj)
 * @brief[en] This file defines window/input related enum types
 * @explain[en] Design goal: upper layers (WindowEngine/InputEngine users) only need to depend on three
 * and never need to import sdl4cj. Values map 1:1 to SDL3 (consistent across platforms)
 * and are converted internally by WindowEngine/InputEngine.
 *
 * @note[zh-cn] 用法：
 * win.setSystemCursor(SystemCursor.Hand)
 * input.getGamepadAxis(GamepadAxis.LeftX)
 * input.getGamepadButton(GamepadButton.South)
 * @note[en] Usage:
 * win.setSystemCursor(SystemCursor.Hand)
 * input.getGamepadAxis(GamepadAxis.LeftX)
 * input.getGamepadButton(GamepadButton.South)
 */
package three.window

/**
 * @brief[zh-cn] 系统光标类型
 * @explain[zh-cn] 对应 SDL_SystemCursor 数值（UInt32）。
 *
 * @brief[en] System cursor type
 * @explain[en] Corresponds to the SDL_SystemCursor values (UInt32).
 */
public enum SystemCursor {
    /**
     * @brief[zh-cn] 默认箭头光标
     *
     * @brief[en] Default arrow cursor
     */
    | Default
    /**
     * @brief[zh-cn] 文本输入 I 型光标
     *
     * @brief[en] Text entry I-beam cursor
     */
    | Text
    /**
     * @brief[zh-cn] 等待光标
     *
     * @brief[en] Wait cursor
     */
    | Wait
    /**
     * @brief[zh-cn] 十字光标
     *
     * @brief[en] Crosshair cursor
     */
    | Crosshair
    /**
     * @brief[zh-cn] 手型光标
     *
     * @brief[en] Hand cursor
     */
    | Hand
    /**
     * @brief[zh-cn] 调整大小：水平
     *
     * @brief[en] Horizontal resize cursor
     */
    | SizeHor
    /**
     * @brief[zh-cn] 调整大小：垂直
     *
     * @brief[en] Vertical resize cursor
     */
    | SizeVer
    /**
     * @brief[zh-cn] 调整大小：左上-右下
     *
     * @brief[en] Diagonal resize cursor (top-left to bottom-right)
     */
    | SizeNwse
    /**
     * @brief[zh-cn] 调整大小：右上-左下
     *
     * @brief[en] Diagonal resize cursor (top-right to bottom-left)
     */
    | SizeNesw
    /**
     * @brief[zh-cn] 调整大小：上下左右
     *
     * @brief[en] Resize all directions cursor
     */
    | SizeAll
    /**
     * @brief[zh-cn] 禁止光标
     *
     * @brief[en] No cursor
     */
    | No

    /**
     * @brief[zh-cn] 转换为 UInt32
     * @return[zh-cn] 对应的 SDL 数值
     *
     * @brief[en] Converts the enum value to UInt32
     * @return[en] The corresponding SDL value
     */
    public func value(): UInt32 {
        match (this) {
            case Default => 0
            case Text => 1
            case Wait => 2
            case Crosshair => 3
            case Hand => 4
            case SizeHor => 5
            case SizeVer => 6
            case SizeNwse => 7
            case SizeNesw => 8
            case SizeAll => 9
            case No => 10
        }
    }
}

/**
 * @brief[zh-cn] 手柄轴类型
 * @explain[zh-cn] 对应 SDL_GamepadAxis 数值（UInt32）。
 *
 * @brief[en] Gamepad axis type
 * @explain[en] Corresponds to the SDL_GamepadAxis values (UInt32).
 */
public enum GamepadAxis {
    /**
     * @brief[zh-cn] 无效轴（C 端为 -1）
     *
     * @brief[en] Invalid axis (-1 on the C side)
     */
    | Invalid
    /**
     * @brief[zh-cn] 左摇杆 X
     *
     * @brief[en] Left stick X
     */
    | LeftX
    /**
     * @brief[zh-cn] 左摇杆 Y
     *
     * @brief[en] Left stick Y
     */
    | LeftY
    /**
     * @brief[zh-cn] 右摇杆 X
     *
     * @brief[en] Right stick X
     */
    | RightX
    /**
     * @brief[zh-cn] 右摇杆 Y
     *
     * @brief[en] Right stick Y
     */
    | RightY
    /**
     * @brief[zh-cn] 左扳机
     *
     * @brief[en] Left trigger
     */
    | LeftTrigger
    /**
     * @brief[zh-cn] 右扳机
     *
     * @brief[en] Right trigger
     */
    | RightTrigger

    /**
     * @brief[zh-cn] 转换为 UInt32（Invalid 为 -1 的补码）
     * @return[zh-cn] 对应的 SDL 数值
     *
     * @brief[en] Converts the enum value to UInt32 (Invalid is the two's complement of -1)
     * @return[en] The corresponding SDL value
     */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0xFFFFFFFF
            case LeftX => 0
            case LeftY => 1
            case RightX => 2
            case RightY => 3
            case LeftTrigger => 4
            case RightTrigger => 5
        }
    }
}

/**
 * @brief[zh-cn] 手柄按键类型
 * @explain[zh-cn] 对应 SDL_GamepadButton 数值（UInt32）。
 *
 * @brief[en] Gamepad button type
 * @explain[en] Corresponds to the SDL_GamepadButton values (UInt32).
 */
public enum GamepadButton {
    /**
     * @brief[zh-cn] 无效按键（C 端为 -1）
     *
     * @brief[en] Invalid button (-1 on the C side)
     */
    | Invalid
    /**
     * @brief[zh-cn] 底部按键（如 Xbox A）
     *
     * @brief[en] Bottom button (e.g. Xbox A)
     */
    | South
    /**
     * @brief[zh-cn] 右侧按键（如 Xbox B）
     *
     * @brief[en] Right button (e.g. Xbox B)
     */
    | East
    /**
     * @brief[zh-cn] 左侧按键（如 Xbox X）
     *
     * @brief[en] Left button (e.g. Xbox X)
     */
    | West
    /**
     * @brief[zh-cn] 顶部按键（如 Xbox Y）
     *
     * @brief[en] Top button (e.g. Xbox Y)
     */
    | North
    /**
     * @brief[zh-cn] 返回键
     *
     * @brief[en] Back button
     */
    | Back
    /**
     * @brief[zh-cn] 主页键
     *
     * @brief[en] Guide button
     */
    | Guide
    /**
     * @brief[zh-cn] 开始键
     *
     * @brief[en] Start button
     */
    | Start
    /**
     * @brief[zh-cn] 左摇杆按下
     *
     * @brief[en] Left stick pressed
     */
    | LeftStick
    /**
     * @brief[zh-cn] 右摇杆按下
     *
     * @brief[en] Right stick pressed
     */
    | RightStick
    /**
     * @brief[zh-cn] 左肩键
     *
     * @brief[en] Left shoulder button
     */
    | LeftShoulder
    /**
     * @brief[zh-cn] 右肩键
     *
     * @brief[en] Right shoulder button
     */
    | RightShoulder
    /**
     * @brief[zh-cn] 十字键上
     *
     * @brief[en] D-pad up
     */
    | DPadUp
    /**
     * @brief[zh-cn] 十字键下
     *
     * @brief[en] D-pad down
     */
    | DPadDown
    /**
     * @brief[zh-cn] 十字键左
     *
     * @brief[en] D-pad left
     */
    | DPadLeft
    /**
     * @brief[zh-cn] 十字键右
     *
     * @brief[en] D-pad right
     */
    | DPadRight
    /**
     * @brief[zh-cn] 杂项键 1
     *
     * @brief[en] Misc button 1
     */
    | Misc1
    /**
     * @brief[zh-cn] 右侧拨片 1
     *
     * @brief[en] Right paddle 1
     */
    | RightPaddle1
    /**
     * @brief[zh-cn] 左侧拨片 1
     *
     * @brief[en] Left paddle 1
     */
    | LeftPaddle1
    /**
     * @brief[zh-cn] 右侧拨片 2
     *
     * @brief[en] Right paddle 2
     */
    | RightPaddle2
    /**
     * @brief[zh-cn] 左侧拨片 2
     *
     * @brief[en] Left paddle 2
     */
    | LeftPaddle2
    /**
     * @brief[zh-cn] 触摸板
     *
     * @brief[en] Touchpad
     */
    | Touchpad
    /**
     * @brief[zh-cn] 杂项键 2
     *
     * @brief[en] Misc button 2
     */
    | Misc2
    /**
     * @brief[zh-cn] 杂项键 3
     *
     * @brief[en] Misc button 3
     */
    | Misc3
    /**
     * @brief[zh-cn] 杂项键 4
     *
     * @brief[en] Misc button 4
     */
    | Misc4
    /**
     * @brief[zh-cn] 杂项键 5
     *
     * @brief[en] Misc button 5
     */
    | Misc5
    /**
     * @brief[zh-cn] 杂项键 6
     *
     * @brief[en] Misc button 6
     */
    | Misc6
    /**
     * @brief[zh-cn] 按键总数（非真实按键，标记枚举末尾）
     *
     * @brief[en] Total number of buttons (not a real button; marks the end of the enum)
     */
    | Count

    /**
     * @brief[zh-cn] 转换为 UInt32（Invalid 为 -1 的补码）
     * @return[zh-cn] 对应的 SDL 数值
     *
     * @brief[en] Converts the enum value to UInt32 (Invalid is the two's complement of -1)
     * @return[en] The corresponding SDL value
     */
    public func value(): UInt32 {
        match (this) {
            case Invalid => 0xFFFFFFFF
            case South => 0
            case East => 1
            case West => 2
            case North => 3
            case Back => 4
            case Guide => 5
            case Start => 6
            case LeftStick => 7
            case RightStick => 8
            case LeftShoulder => 9
            case RightShoulder => 10
            case DPadUp => 11
            case DPadDown => 12
            case DPadLeft => 13
            case DPadRight => 14
            case Misc1 => 15
            case RightPaddle1 => 16
            case LeftPaddle1 => 17
            case RightPaddle2 => 18
            case LeftPaddle2 => 19
            case Touchpad => 20
            case Misc2 => 21
            case Misc3 => 22
            case Misc4 => 23
            case Misc5 => 24
            case Misc6 => 25
            case Count => 26
        }
    }
}
