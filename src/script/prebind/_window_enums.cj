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
 * @file[zh-cn] window_enums 窗口/输入枚举的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 SystemCursor / GamepadAxis / GamepadButton 绑定为 Lua 常量命名空间
 * @explain[zh-cn] 三个枚举都带 value(): UInt32，因此每个变体以静态方法暴露（返回 SDL 数值），
 * 与既有 LogLevel 等枚举绑定一致。Lua 侧用法：
 *   three.window.SystemCursor.Hand()      --> 4
 *   three.window.GamepadAxis.LeftX()      --> 0
 *   three.window.GamepadButton.South()    --> 0
 * 枚举本身不作为类型使用（只承载数值），因此没有 fromValue（Cangjie 侧也未提供）。
 *
 * @file[en] window_enums  Lua binding of the window/input enums (three.script.prebind)
 * @brief[en] Binds SystemCursor / GamepadAxis / GamepadButton as Lua constant namespaces
 * @explain[en] All three enums provide value(): UInt32, so every variant is exposed as a static
 * method returning the SDL value, matching existing enum bindings such as LogLevel. Lua usage:
 *   three.window.SystemCursor.Hand()      --> 4
 *   three.window.GamepadAxis.LeftX()      --> 0
 *   three.window.GamepadButton.South()    --> 0
 * The enums are not used as types (they only carry numbers), so fromValue is absent
 * (the Cangjie side does not provide it either).
 */
package three.script.prebind

import three.window.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SystemCursor 枚举的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.window.SystemCursor）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the SystemCursor enum
 * @param[en] vm The target virtual machine (namespace table installed at three.window.SystemCursor)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSystemCursor(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.SystemCursor")
    b.staticMethod("Default") {_ => [LuaValue.of(Int64(SystemCursor.Default.value()))]}
    b.staticMethod("Text") {_ => [LuaValue.of(Int64(SystemCursor.Text.value()))]}
    b.staticMethod("Wait") {_ => [LuaValue.of(Int64(SystemCursor.Wait.value()))]}
    b.staticMethod("Crosshair") {_ => [LuaValue.of(Int64(SystemCursor.Crosshair.value()))]}
    b.staticMethod("Hand") {_ => [LuaValue.of(Int64(SystemCursor.Hand.value()))]}
    b.staticMethod("SizeHor") {_ => [LuaValue.of(Int64(SystemCursor.SizeHor.value()))]}
    b.staticMethod("SizeVer") {_ => [LuaValue.of(Int64(SystemCursor.SizeVer.value()))]}
    b.staticMethod("SizeNwse") {_ => [LuaValue.of(Int64(SystemCursor.SizeNwse.value()))]}
    b.staticMethod("SizeNesw") {_ => [LuaValue.of(Int64(SystemCursor.SizeNesw.value()))]}
    b.staticMethod("SizeAll") {_ => [LuaValue.of(Int64(SystemCursor.SizeAll.value()))]}
    b.staticMethod("No") {_ => [LuaValue.of(Int64(SystemCursor.No.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GamepadAxis 枚举的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.window.GamepadAxis）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the GamepadAxis enum
 * @param[en] vm The target virtual machine (namespace table installed at three.window.GamepadAxis)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGamepadAxis(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.GamepadAxis")
    b.staticMethod("Invalid") {_ => [LuaValue.of(Int64(GamepadAxis.Invalid.value()))]}
    b.staticMethod("LeftX") {_ => [LuaValue.of(Int64(GamepadAxis.LeftX.value()))]}
    b.staticMethod("LeftY") {_ => [LuaValue.of(Int64(GamepadAxis.LeftY.value()))]}
    b.staticMethod("RightX") {_ => [LuaValue.of(Int64(GamepadAxis.RightX.value()))]}
    b.staticMethod("RightY") {_ => [LuaValue.of(Int64(GamepadAxis.RightY.value()))]}
    b.staticMethod("LeftTrigger") {_ => [LuaValue.of(Int64(GamepadAxis.LeftTrigger.value()))]}
    b.staticMethod("RightTrigger") {_ => [LuaValue.of(Int64(GamepadAxis.RightTrigger.value()))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GamepadButton 枚举的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.window.GamepadButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the GamepadButton enum
 * @param[en] vm The target virtual machine (namespace table installed at three.window.GamepadButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGamepadButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.GamepadButton")
    b.staticMethod("Invalid") {_ => [LuaValue.of(Int64(GamepadButton.Invalid.value()))]}
    b.staticMethod("South") {_ => [LuaValue.of(Int64(GamepadButton.South.value()))]}
    b.staticMethod("East") {_ => [LuaValue.of(Int64(GamepadButton.East.value()))]}
    b.staticMethod("West") {_ => [LuaValue.of(Int64(GamepadButton.West.value()))]}
    b.staticMethod("North") {_ => [LuaValue.of(Int64(GamepadButton.North.value()))]}
    b.staticMethod("Back") {_ => [LuaValue.of(Int64(GamepadButton.Back.value()))]}
    b.staticMethod("Guide") {_ => [LuaValue.of(Int64(GamepadButton.Guide.value()))]}
    b.staticMethod("Start") {_ => [LuaValue.of(Int64(GamepadButton.Start.value()))]}
    b.staticMethod("LeftStick") {_ => [LuaValue.of(Int64(GamepadButton.LeftStick.value()))]}
    b.staticMethod("RightStick") {_ => [LuaValue.of(Int64(GamepadButton.RightStick.value()))]}
    b.staticMethod("LeftShoulder") {_ => [LuaValue.of(Int64(GamepadButton.LeftShoulder.value()))]}
    b.staticMethod("RightShoulder") {_ => [LuaValue.of(Int64(GamepadButton.RightShoulder.value()))]}
    b.staticMethod("DPadUp") {_ => [LuaValue.of(Int64(GamepadButton.DPadUp.value()))]}
    b.staticMethod("DPadDown") {_ => [LuaValue.of(Int64(GamepadButton.DPadDown.value()))]}
    b.staticMethod("DPadLeft") {_ => [LuaValue.of(Int64(GamepadButton.DPadLeft.value()))]}
    b.staticMethod("DPadRight") {_ => [LuaValue.of(Int64(GamepadButton.DPadRight.value()))]}
    b.staticMethod("Misc1") {_ => [LuaValue.of(Int64(GamepadButton.Misc1.value()))]}
    b.staticMethod("RightPaddle1") {_ => [LuaValue.of(Int64(GamepadButton.RightPaddle1.value()))]}
    b.staticMethod("LeftPaddle1") {_ => [LuaValue.of(Int64(GamepadButton.LeftPaddle1.value()))]}
    b.staticMethod("RightPaddle2") {_ => [LuaValue.of(Int64(GamepadButton.RightPaddle2.value()))]}
    b.staticMethod("LeftPaddle2") {_ => [LuaValue.of(Int64(GamepadButton.LeftPaddle2.value()))]}
    b.staticMethod("Touchpad") {_ => [LuaValue.of(Int64(GamepadButton.Touchpad.value()))]}
    b.staticMethod("Misc2") {_ => [LuaValue.of(Int64(GamepadButton.Misc2.value()))]}
    b.staticMethod("Misc3") {_ => [LuaValue.of(Int64(GamepadButton.Misc3.value()))]}
    b.staticMethod("Misc4") {_ => [LuaValue.of(Int64(GamepadButton.Misc4.value()))]}
    b.staticMethod("Misc5") {_ => [LuaValue.of(Int64(GamepadButton.Misc5.value()))]}
    b.staticMethod("Misc6") {_ => [LuaValue.of(Int64(GamepadButton.Misc6.value()))]}
    b.staticMethod("Count") {_ => [LuaValue.of(Int64(GamepadButton.Count.value()))]}
    b.install(vm)
}
