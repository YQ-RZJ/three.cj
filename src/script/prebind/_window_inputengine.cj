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
 * @file[zh-cn] window_inputengine 输入引擎的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 InputEngine 绑定为 Lua 类型 three.window.InputEngine
 * @explain[zh-cn] 绑定输入轮询接口：键盘按下/刚按下/刚释放、鼠标坐标与位移、鼠标按键、滚轮、
 * 触摸点查询、手柄开关与轴/按键查询。适配约定：
 * - GamepadAxis/GamepadButton 参数接受整数值（与三个枚举的 value() 一致）；
 * - Option<TouchPoint> 返回值：Some → 注册后的对象，None → nil；
 * - getTouch / getTouchByID 的越界或缺失统一返回 nil。
 * 绑定窗口：bindWindow(win) 与 getWindow()（Option → nil）。
 *
 * @file[en] window_inputengine  Lua binding of the input engine (three.script.prebind)
 * @brief[en] Binds InputEngine as the Lua type three.window.InputEngine
 * @explain[en] Binds the input polling API: key down/pressed/released, mouse position and delta,
 * mouse buttons, wheel, touch-point queries, gamepad open/close and axis/button queries.
 * Adaptation rules:
 * - GamepadAxis/GamepadButton arguments accept integers (matching the value() of the enums);
 * - Option<TouchPoint> returns: Some → a registered object, None → nil;
 * - getTouch / getTouchByID return nil for out-of-range or missing entries.
 * Window binding: bindWindow(win) and getWindow() (Option → nil).
 */
package three.script.prebind

import three.window.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 由整数值解析 GamepadAxis（未知值回退 Invalid）
 * @param[zh-cn] v 整数值（0~5，-1/0xFFFFFFFF 为 Invalid）
 * @return[zh-cn] 对应的枚举值
 *
 * @brief[en] Resolves a GamepadAxis from an integer (unknown values fall back to Invalid)
 * @param[en] v The integer value (0~5; -1/0xFFFFFFFF is Invalid)
 * @return[en] The matching enum value
 */
private func _prebindGamepadAxisOf(v: Int64): GamepadAxis {
    match (v) {
        case 0 => GamepadAxis.LeftX
        case 1 => GamepadAxis.LeftY
        case 2 => GamepadAxis.RightX
        case 3 => GamepadAxis.RightY
        case 4 => GamepadAxis.LeftTrigger
        case 5 => GamepadAxis.RightTrigger
        case _ => GamepadAxis.Invalid
    }
}

/**
 * @brief[zh-cn] 由整数值解析 GamepadButton（未知值回退 Invalid）
 * @param[zh-cn] v 整数值（0~26，-1/0xFFFFFFFF 为 Invalid）
 * @return[zh-cn] 对应的枚举值
 *
 * @brief[en] Resolves a GamepadButton from an integer (unknown values fall back to Invalid)
 * @param[en] v The integer value (0~26; -1/0xFFFFFFFF is Invalid)
 * @return[en] The matching enum value
 */
private func _prebindGamepadButtonOf(v: Int64): GamepadButton {
    match (v) {
        case 0 => GamepadButton.South
        case 1 => GamepadButton.East
        case 2 => GamepadButton.West
        case 3 => GamepadButton.North
        case 4 => GamepadButton.Back
        case 5 => GamepadButton.Guide
        case 6 => GamepadButton.Start
        case 7 => GamepadButton.LeftStick
        case 8 => GamepadButton.RightStick
        case 9 => GamepadButton.LeftShoulder
        case 10 => GamepadButton.RightShoulder
        case 11 => GamepadButton.DPadUp
        case 12 => GamepadButton.DPadDown
        case 13 => GamepadButton.DPadLeft
        case 14 => GamepadButton.DPadRight
        case 15 => GamepadButton.Misc1
        case 16 => GamepadButton.RightPaddle1
        case 17 => GamepadButton.LeftPaddle1
        case 18 => GamepadButton.RightPaddle2
        case 19 => GamepadButton.LeftPaddle2
        case 20 => GamepadButton.Touchpad
        case 21 => GamepadButton.Misc2
        case 22 => GamepadButton.Misc3
        case 23 => GamepadButton.Misc4
        case 24 => GamepadButton.Misc5
        case 25 => GamepadButton.Misc6
        case _ => GamepadButton.Invalid
    }
}

/**
 * @brief[zh-cn] 安装 InputEngine 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.InputEngine）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of InputEngine
 * @param[en] vm The target virtual machine (class table installed at three.window.InputEngine)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installInputEngine(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.InputEngine")
    b.constructor {_ => InputEngine()}
    // ===== 窗口绑定 =====
    b.method("bindWindow") {
        ref, args =>
            ref.cast<InputEngine>().bindWindow(prebindAs<WindowEngine>(args, 0))
            []
    }
    b.method("getWindow") {
        ref, _ => match (ref.cast<InputEngine>().getWindow()) {
            case Some(w) => [prebindRegister(w, "three.window.WindowEngine")]
            case None => [LuaValue.Nil]
        }
    }
    // ===== 键盘 =====
    b.method("isKeyDown") {
        ref, args => [LuaValue.of(ref.cast<InputEngine>().isKeyDown(UInt32(prebindInt(args, 0) & 0xFFFFFFFF)))]
    }
    b.method("isKeyPressed") {
        ref, args => [LuaValue.of(ref.cast<InputEngine>().isKeyPressed(UInt32(prebindInt(args, 0) & 0xFFFFFFFF)))]
    }
    b.method("isKeyReleased") {
        ref, args => [LuaValue.of(ref.cast<InputEngine>().isKeyReleased(UInt32(prebindInt(args, 0) & 0xFFFFFFFF)))]
    }
    // ===== 鼠标 =====
    b.method("getMouseX") {
        ref, _ => [LuaValue.of(Float64(ref.cast<InputEngine>().getMouseX()))]
    }
    b.method("getMouseY") {
        ref, _ => [LuaValue.of(Float64(ref.cast<InputEngine>().getMouseY()))]
    }
    b.method("getMouseDX") {
        ref, _ => [LuaValue.of(Float64(ref.cast<InputEngine>().getMouseDX()))]
    }
    b.method("getMouseDY") {
        ref, _ => [LuaValue.of(Float64(ref.cast<InputEngine>().getMouseDY()))]
    }
    b.method("isMouseButtonDown") {
        ref, args => [LuaValue.of(ref.cast<InputEngine>().isMouseButtonDown(UInt8(prebindInt(args, 0) & 0xFF)))]
    }
    b.method("getWheelX") {
        ref, _ => [LuaValue.of(Float64(ref.cast<InputEngine>().getWheelX()))]
    }
    b.method("getWheelY") {
        ref, _ => [LuaValue.of(Float64(ref.cast<InputEngine>().getWheelY()))]
    }
    // ===== 触摸 =====
    b.method("getTouchCount") {
        ref, _ => [LuaValue.of(ref.cast<InputEngine>().getTouchCount())]
    }
    b.method("getTouch") {
        ref, args => match (ref.cast<InputEngine>().getTouch(prebindInt(args, 0))) {
            case Some(t) => [prebindRegister(t, "three.window.TouchPoint")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getTouchByID") {
        ref, args => match (ref.cast<InputEngine>().getTouchByID(prebindInt(args, 0))) {
            case Some(t) => [prebindRegister(t, "three.window.TouchPoint")]
            case None => [LuaValue.Nil]
        }
    }
    // ===== 手柄 =====
    b.method("openGamepad") {
        ref, _ => [LuaValue.of(ref.cast<InputEngine>().openGamepad())]
    }
    b.method("openGamepadAt") {
        ref, args => [LuaValue.of(ref.cast<InputEngine>().openGamepadAt(Int32(prebindInt(args, 0))))]
    }
    b.method("closeGamepad") {
        ref, _ =>
            ref.cast<InputEngine>().closeGamepad()
            []
    }
    b.method("isGamepadConnected") {
        ref, _ => [LuaValue.of(ref.cast<InputEngine>().isGamepadConnected())]
    }
    b.method("getGamepadInstanceID") {
        ref, _ => [LuaValue.of(ref.cast<InputEngine>().getGamepadInstanceID())]
    }
    b.method("getGamepadAxis") {
        ref, args => [LuaValue.of(
            Int64(ref.cast<InputEngine>().getGamepadAxis(_prebindGamepadAxisOf(prebindInt(args, 0)))))]
    }
    b.method("getGamepadButton") {
        ref, args => [LuaValue.of(ref.cast<InputEngine>().getGamepadButton(_prebindGamepadButtonOf(prebindInt(args, 0))))]
    }
    b.method("getGamepadName") {
        ref, _ => [LuaValue.of(ref.cast<InputEngine>().getGamepadName())]
    }
    b.install(vm)
}
