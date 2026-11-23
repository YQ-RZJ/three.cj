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
 * @file[zh-cn] window_gamepadprovider 手柄输入提供者的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 GamepadProvider 绑定为 Lua 类型 three.window.GamepadProvider
 * @explain[zh-cn] 绑定无参构造、手柄开关（openGamepad/openGamepadAt/closeGamepad）、
 * 连接状态与实例 ID、轴/按键查询（整数值对应 GamepadAxis/GamepadButton 的 value()）、
 * 手柄名称与基类能力。轴/按键整数值未知时回退 Invalid。
 *
 * @file[en] window_gamepadprovider  Lua binding of the gamepad input provider (three.script.prebind)
 * @brief[en] Binds GamepadProvider as the Lua type three.window.GamepadProvider
 * @explain[en] Binds the no-arg constructor, gamepad open/close (openGamepad/openGamepadAt/
 * closeGamepad), connection state and instance id, axis/button queries (integer values matching
 * GamepadAxis/GamepadButton's value()), the gamepad name and the base-class capabilities.
 * Unknown axis/button integers fall back to Invalid.
 */
package three.script.prebind

import three.window.{GamepadAxis, GamepadButton, GamepadProvider}
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 由整数值解析 GamepadAxis（未知值回退 Invalid）
 * @param[zh-cn] v 整数值
 * @return[zh-cn] 对应的枚举值
 *
 * @brief[en] Resolves a GamepadAxis from an integer (unknown values fall back to Invalid)
 * @param[en] v The integer value
 * @return[en] The matching enum value
 */
private func _prebindGamepadAxis(v: Int64): GamepadAxis {
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
 * @param[zh-cn] v 整数值
 * @return[zh-cn] 对应的枚举值
 *
 * @brief[en] Resolves a GamepadButton from an integer (unknown values fall back to Invalid)
 * @param[en] v The integer value
 * @return[en] The matching enum value
 */
private func _prebindGamepadButton(v: Int64): GamepadButton {
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
 * @brief[zh-cn] 安装 GamepadProvider 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.GamepadProvider）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GamepadProvider
 * @param[en] vm The target virtual machine (class table installed at three.window.GamepadProvider)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGamepadProvider(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.GamepadProvider")
    b.constructor {_ => GamepadProvider()}
    b.method("openGamepad") {
        ref, _ => [LuaValue.of(ref.cast<GamepadProvider>().openGamepad())]
    }
    b.method("openGamepadAt") {
        ref, args => [LuaValue.of(ref.cast<GamepadProvider>().openGamepadAt(Int32(prebindInt(args, 0))))]
    }
    b.method("closeGamepad") {
        ref, _ =>
            ref.cast<GamepadProvider>().closeGamepad()
            []
    }
    b.method("isGamepadConnected") {
        ref, _ => [LuaValue.of(ref.cast<GamepadProvider>().isGamepadConnected())]
    }
    b.method("getGamepadInstanceID") {
        ref, _ => [LuaValue.of(ref.cast<GamepadProvider>().getGamepadInstanceID())]
    }
    b.method("getGamepadAxis") {
        ref, args => [LuaValue.of(
            Int64(ref.cast<GamepadProvider>().getGamepadAxis(_prebindGamepadAxis(prebindInt(args, 0)))))]
    }
    b.method("getGamepadButton") {
        ref, args => [LuaValue.of(
            ref.cast<GamepadProvider>().getGamepadButton(_prebindGamepadButton(prebindInt(args, 0))))]
    }
    b.method("getGamepadName") {
        ref, _ => [LuaValue.of(ref.cast<GamepadProvider>().getGamepadName())]
    }
    b.method("getWindow") {
        ref, _ => match (ref.cast<GamepadProvider>().getWindow()) {
            case Some(w) => [prebindRegister(w, "three.window.WindowEngine")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("isBound") {ref, _ => [LuaValue.of(ref.cast<GamepadProvider>().isBound())]}
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<GamepadProvider>().release())]}
    b.install(vm)
}
