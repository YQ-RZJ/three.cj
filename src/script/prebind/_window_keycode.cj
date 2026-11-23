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
 * @file[zh-cn] window_keycode 键盘/鼠标键码常量的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 KeyCode 的 SDL 扫描码常量与 MouseButton 的按钮索引常量暴露给 Lua
 * @explain[zh-cn] 常量数量较多（KeyCode 约 250 个、MouseButton 5 个），按既有 Constants 绑定惯例
 * 逐个以静态方法暴露，返回整数值。Lua 侧用法：
 *   three.window.KeyCode.A()          --> 4
 *   three.window.KeyCode.SPACE()      --> 44
 *   three.window.MouseButton.LEFT()   --> 1
 * 与 InputEngine 的 isKeyDown(scancode) / isMouseButtonDown(button) 直接配套使用。
 * 常量值即 SDL 扫描码/按钮编号，绑定层不做任何数值变换。
 *
 * @file[en] window_keycode  Lua binding of the keyboard/mouse key-code constants (three.script.prebind)
 * @brief[en] Exposes the SDL scancode constants of KeyCode and the button-index constants of MouseButton
 * @explain[en] The constant set is large (about 250 in KeyCode, 5 in MouseButton); following the
 * existing Constants binding convention, each is exposed as a static method returning an integer. Lua usage:
 *   three.window.KeyCode.A()          --> 4
 *   three.window.KeyCode.SPACE()      --> 44
 *   three.window.MouseButton.LEFT()   --> 1
 * These pair directly with InputEngine.isKeyDown(scancode) / isMouseButtonDown(button).
 * The values are the SDL scancodes/button indices; the binding layer performs no transformation.
 */
package three.script.prebind

import three.window.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 KeyCode 键盘扫描码常量的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.window.KeyCode）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the KeyCode keyboard scancode constants
 * @param[en] vm The target virtual machine (namespace table installed at three.window.KeyCode)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installKeyCode(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.KeyCode")
    b.staticMethod("UNKNOWN") {_ => [LuaValue.of(Int64(KeyCode.UNKNOWN))]}
    b.staticMethod("A") {_ => [LuaValue.of(Int64(KeyCode.A))]}
    b.staticMethod("B") {_ => [LuaValue.of(Int64(KeyCode.B))]}
    b.staticMethod("C") {_ => [LuaValue.of(Int64(KeyCode.C))]}
    b.staticMethod("D") {_ => [LuaValue.of(Int64(KeyCode.D))]}
    b.staticMethod("E") {_ => [LuaValue.of(Int64(KeyCode.E))]}
    b.staticMethod("F") {_ => [LuaValue.of(Int64(KeyCode.F))]}
    b.staticMethod("G") {_ => [LuaValue.of(Int64(KeyCode.G))]}
    b.staticMethod("H") {_ => [LuaValue.of(Int64(KeyCode.H))]}
    b.staticMethod("I") {_ => [LuaValue.of(Int64(KeyCode.I))]}
    b.staticMethod("J") {_ => [LuaValue.of(Int64(KeyCode.J))]}
    b.staticMethod("K") {_ => [LuaValue.of(Int64(KeyCode.K))]}
    b.staticMethod("L") {_ => [LuaValue.of(Int64(KeyCode.L))]}
    b.staticMethod("M") {_ => [LuaValue.of(Int64(KeyCode.M))]}
    b.staticMethod("N") {_ => [LuaValue.of(Int64(KeyCode.N))]}
    b.staticMethod("O") {_ => [LuaValue.of(Int64(KeyCode.O))]}
    b.staticMethod("P") {_ => [LuaValue.of(Int64(KeyCode.P))]}
    b.staticMethod("Q") {_ => [LuaValue.of(Int64(KeyCode.Q))]}
    b.staticMethod("R") {_ => [LuaValue.of(Int64(KeyCode.R))]}
    b.staticMethod("S") {_ => [LuaValue.of(Int64(KeyCode.S))]}
    b.staticMethod("T") {_ => [LuaValue.of(Int64(KeyCode.T))]}
    b.staticMethod("U") {_ => [LuaValue.of(Int64(KeyCode.U))]}
    b.staticMethod("V") {_ => [LuaValue.of(Int64(KeyCode.V))]}
    b.staticMethod("W") {_ => [LuaValue.of(Int64(KeyCode.W))]}
    b.staticMethod("X") {_ => [LuaValue.of(Int64(KeyCode.X))]}
    b.staticMethod("Y") {_ => [LuaValue.of(Int64(KeyCode.Y))]}
    b.staticMethod("Z") {_ => [LuaValue.of(Int64(KeyCode.Z))]}
    b.staticMethod("NUM_1") {_ => [LuaValue.of(Int64(KeyCode.NUM_1))]}
    b.staticMethod("NUM_2") {_ => [LuaValue.of(Int64(KeyCode.NUM_2))]}
    b.staticMethod("NUM_3") {_ => [LuaValue.of(Int64(KeyCode.NUM_3))]}
    b.staticMethod("NUM_4") {_ => [LuaValue.of(Int64(KeyCode.NUM_4))]}
    b.staticMethod("NUM_5") {_ => [LuaValue.of(Int64(KeyCode.NUM_5))]}
    b.staticMethod("NUM_6") {_ => [LuaValue.of(Int64(KeyCode.NUM_6))]}
    b.staticMethod("NUM_7") {_ => [LuaValue.of(Int64(KeyCode.NUM_7))]}
    b.staticMethod("NUM_8") {_ => [LuaValue.of(Int64(KeyCode.NUM_8))]}
    b.staticMethod("NUM_9") {_ => [LuaValue.of(Int64(KeyCode.NUM_9))]}
    b.staticMethod("NUM_0") {_ => [LuaValue.of(Int64(KeyCode.NUM_0))]}
    b.staticMethod("RETURN") {_ => [LuaValue.of(Int64(KeyCode.RETURN))]}
    b.staticMethod("ESCAPE") {_ => [LuaValue.of(Int64(KeyCode.ESCAPE))]}
    b.staticMethod("BACKSPACE") {_ => [LuaValue.of(Int64(KeyCode.BACKSPACE))]}
    b.staticMethod("TAB") {_ => [LuaValue.of(Int64(KeyCode.TAB))]}
    b.staticMethod("SPACE") {_ => [LuaValue.of(Int64(KeyCode.SPACE))]}
    b.staticMethod("MINUS") {_ => [LuaValue.of(Int64(KeyCode.MINUS))]}
    b.staticMethod("EQUALS") {_ => [LuaValue.of(Int64(KeyCode.EQUALS))]}
    b.staticMethod("LEFTBRACKET") {_ => [LuaValue.of(Int64(KeyCode.LEFTBRACKET))]}
    b.staticMethod("RIGHTBRACKET") {_ => [LuaValue.of(Int64(KeyCode.RIGHTBRACKET))]}
    b.staticMethod("BACKSLASH") {_ => [LuaValue.of(Int64(KeyCode.BACKSLASH))]}
    b.staticMethod("NONUSHASH") {_ => [LuaValue.of(Int64(KeyCode.NONUSHASH))]}
    b.staticMethod("SEMICOLON") {_ => [LuaValue.of(Int64(KeyCode.SEMICOLON))]}
    b.staticMethod("APOSTROPHE") {_ => [LuaValue.of(Int64(KeyCode.APOSTROPHE))]}
    b.staticMethod("GRAVE") {_ => [LuaValue.of(Int64(KeyCode.GRAVE))]}
    b.staticMethod("COMMA") {_ => [LuaValue.of(Int64(KeyCode.COMMA))]}
    b.staticMethod("PERIOD") {_ => [LuaValue.of(Int64(KeyCode.PERIOD))]}
    b.staticMethod("SLASH") {_ => [LuaValue.of(Int64(KeyCode.SLASH))]}
    b.staticMethod("CAPSLOCK") {_ => [LuaValue.of(Int64(KeyCode.CAPSLOCK))]}
    b.staticMethod("F1") {_ => [LuaValue.of(Int64(KeyCode.F1))]}
    b.staticMethod("F2") {_ => [LuaValue.of(Int64(KeyCode.F2))]}
    b.staticMethod("F3") {_ => [LuaValue.of(Int64(KeyCode.F3))]}
    b.staticMethod("F4") {_ => [LuaValue.of(Int64(KeyCode.F4))]}
    b.staticMethod("F5") {_ => [LuaValue.of(Int64(KeyCode.F5))]}
    b.staticMethod("F6") {_ => [LuaValue.of(Int64(KeyCode.F6))]}
    b.staticMethod("F7") {_ => [LuaValue.of(Int64(KeyCode.F7))]}
    b.staticMethod("F8") {_ => [LuaValue.of(Int64(KeyCode.F8))]}
    b.staticMethod("F9") {_ => [LuaValue.of(Int64(KeyCode.F9))]}
    b.staticMethod("F10") {_ => [LuaValue.of(Int64(KeyCode.F10))]}
    b.staticMethod("F11") {_ => [LuaValue.of(Int64(KeyCode.F11))]}
    b.staticMethod("F12") {_ => [LuaValue.of(Int64(KeyCode.F12))]}
    b.staticMethod("PRINTSCREEN") {_ => [LuaValue.of(Int64(KeyCode.PRINTSCREEN))]}
    b.staticMethod("SCROLLLOCK") {_ => [LuaValue.of(Int64(KeyCode.SCROLLLOCK))]}
    b.staticMethod("PAUSE") {_ => [LuaValue.of(Int64(KeyCode.PAUSE))]}
    b.staticMethod("INSERT") {_ => [LuaValue.of(Int64(KeyCode.INSERT))]}
    b.staticMethod("HOME") {_ => [LuaValue.of(Int64(KeyCode.HOME))]}
    b.staticMethod("PAGEUP") {_ => [LuaValue.of(Int64(KeyCode.PAGEUP))]}
    b.staticMethod("DELETE") {_ => [LuaValue.of(Int64(KeyCode.DELETE))]}
    b.staticMethod("END") {_ => [LuaValue.of(Int64(KeyCode.END))]}
    b.staticMethod("PAGEDOWN") {_ => [LuaValue.of(Int64(KeyCode.PAGEDOWN))]}
    b.staticMethod("RIGHT") {_ => [LuaValue.of(Int64(KeyCode.RIGHT))]}
    b.staticMethod("LEFT") {_ => [LuaValue.of(Int64(KeyCode.LEFT))]}
    b.staticMethod("DOWN") {_ => [LuaValue.of(Int64(KeyCode.DOWN))]}
    b.staticMethod("UP") {_ => [LuaValue.of(Int64(KeyCode.UP))]}
    b.staticMethod("NUMLOCKCLEAR") {_ => [LuaValue.of(Int64(KeyCode.NUMLOCKCLEAR))]}
    b.staticMethod("KP_DIVIDE") {_ => [LuaValue.of(Int64(KeyCode.KP_DIVIDE))]}
    b.staticMethod("KP_MULTIPLY") {_ => [LuaValue.of(Int64(KeyCode.KP_MULTIPLY))]}
    b.staticMethod("KP_MINUS") {_ => [LuaValue.of(Int64(KeyCode.KP_MINUS))]}
    b.staticMethod("KP_PLUS") {_ => [LuaValue.of(Int64(KeyCode.KP_PLUS))]}
    b.staticMethod("KP_ENTER") {_ => [LuaValue.of(Int64(KeyCode.KP_ENTER))]}
    b.staticMethod("KP_1") {_ => [LuaValue.of(Int64(KeyCode.KP_1))]}
    b.staticMethod("KP_2") {_ => [LuaValue.of(Int64(KeyCode.KP_2))]}
    b.staticMethod("KP_3") {_ => [LuaValue.of(Int64(KeyCode.KP_3))]}
    b.staticMethod("KP_4") {_ => [LuaValue.of(Int64(KeyCode.KP_4))]}
    b.staticMethod("KP_5") {_ => [LuaValue.of(Int64(KeyCode.KP_5))]}
    b.staticMethod("KP_6") {_ => [LuaValue.of(Int64(KeyCode.KP_6))]}
    b.staticMethod("KP_7") {_ => [LuaValue.of(Int64(KeyCode.KP_7))]}
    b.staticMethod("KP_8") {_ => [LuaValue.of(Int64(KeyCode.KP_8))]}
    b.staticMethod("KP_9") {_ => [LuaValue.of(Int64(KeyCode.KP_9))]}
    b.staticMethod("KP_0") {_ => [LuaValue.of(Int64(KeyCode.KP_0))]}
    b.staticMethod("KP_PERIOD") {_ => [LuaValue.of(Int64(KeyCode.KP_PERIOD))]}
    b.staticMethod("NONUSBACKSLASH") {_ => [LuaValue.of(Int64(KeyCode.NONUSBACKSLASH))]}
    b.staticMethod("APPLICATION") {_ => [LuaValue.of(Int64(KeyCode.APPLICATION))]}
    b.staticMethod("POWER") {_ => [LuaValue.of(Int64(KeyCode.POWER))]}
    b.staticMethod("KP_EQUALS") {_ => [LuaValue.of(Int64(KeyCode.KP_EQUALS))]}
    b.staticMethod("F13") {_ => [LuaValue.of(Int64(KeyCode.F13))]}
    b.staticMethod("F14") {_ => [LuaValue.of(Int64(KeyCode.F14))]}
    b.staticMethod("F15") {_ => [LuaValue.of(Int64(KeyCode.F15))]}
    b.staticMethod("F16") {_ => [LuaValue.of(Int64(KeyCode.F16))]}
    b.staticMethod("F17") {_ => [LuaValue.of(Int64(KeyCode.F17))]}
    b.staticMethod("F18") {_ => [LuaValue.of(Int64(KeyCode.F18))]}
    b.staticMethod("F19") {_ => [LuaValue.of(Int64(KeyCode.F19))]}
    b.staticMethod("F20") {_ => [LuaValue.of(Int64(KeyCode.F20))]}
    b.staticMethod("F21") {_ => [LuaValue.of(Int64(KeyCode.F21))]}
    b.staticMethod("F22") {_ => [LuaValue.of(Int64(KeyCode.F22))]}
    b.staticMethod("F23") {_ => [LuaValue.of(Int64(KeyCode.F23))]}
    b.staticMethod("F24") {_ => [LuaValue.of(Int64(KeyCode.F24))]}
    b.staticMethod("EXECUTE") {_ => [LuaValue.of(Int64(KeyCode.EXECUTE))]}
    b.staticMethod("HELP") {_ => [LuaValue.of(Int64(KeyCode.HELP))]}
    b.staticMethod("MENU") {_ => [LuaValue.of(Int64(KeyCode.MENU))]}
    b.staticMethod("SELECT") {_ => [LuaValue.of(Int64(KeyCode.SELECT))]}
    b.staticMethod("STOP") {_ => [LuaValue.of(Int64(KeyCode.STOP))]}
    b.staticMethod("AGAIN") {_ => [LuaValue.of(Int64(KeyCode.AGAIN))]}
    b.staticMethod("UNDO") {_ => [LuaValue.of(Int64(KeyCode.UNDO))]}
    b.staticMethod("CUT") {_ => [LuaValue.of(Int64(KeyCode.CUT))]}
    b.staticMethod("COPY") {_ => [LuaValue.of(Int64(KeyCode.COPY))]}
    b.staticMethod("PASTE") {_ => [LuaValue.of(Int64(KeyCode.PASTE))]}
    b.staticMethod("FIND") {_ => [LuaValue.of(Int64(KeyCode.FIND))]}
    b.staticMethod("MUTE") {_ => [LuaValue.of(Int64(KeyCode.MUTE))]}
    b.staticMethod("VOLUMEUP") {_ => [LuaValue.of(Int64(KeyCode.VOLUMEUP))]}
    b.staticMethod("VOLUMEDOWN") {_ => [LuaValue.of(Int64(KeyCode.VOLUMEDOWN))]}
    b.staticMethod("LOCKINGCAPSLOCK") {_ => [LuaValue.of(Int64(KeyCode.LOCKINGCAPSLOCK))]}
    b.staticMethod("LOCKINGNUMLOCK") {_ => [LuaValue.of(Int64(KeyCode.LOCKINGNUMLOCK))]}
    b.staticMethod("LOCKINGSCROLLLOCK") {_ => [LuaValue.of(Int64(KeyCode.LOCKINGSCROLLLOCK))]}
    b.staticMethod("KP_COMMA") {_ => [LuaValue.of(Int64(KeyCode.KP_COMMA))]}
    b.staticMethod("KP_EQUALSAS400") {_ => [LuaValue.of(Int64(KeyCode.KP_EQUALSAS400))]}
    b.staticMethod("INTERNATIONAL1") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL1))]}
    b.staticMethod("INTERNATIONAL2") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL2))]}
    b.staticMethod("INTERNATIONAL3") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL3))]}
    b.staticMethod("INTERNATIONAL4") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL4))]}
    b.staticMethod("INTERNATIONAL5") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL5))]}
    b.staticMethod("INTERNATIONAL6") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL6))]}
    b.staticMethod("INTERNATIONAL7") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL7))]}
    b.staticMethod("INTERNATIONAL8") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL8))]}
    b.staticMethod("INTERNATIONAL9") {_ => [LuaValue.of(Int64(KeyCode.INTERNATIONAL9))]}
    b.staticMethod("LANG1") {_ => [LuaValue.of(Int64(KeyCode.LANG1))]}
    b.staticMethod("LANG2") {_ => [LuaValue.of(Int64(KeyCode.LANG2))]}
    b.staticMethod("LANG3") {_ => [LuaValue.of(Int64(KeyCode.LANG3))]}
    b.staticMethod("LANG4") {_ => [LuaValue.of(Int64(KeyCode.LANG4))]}
    b.staticMethod("LANG5") {_ => [LuaValue.of(Int64(KeyCode.LANG5))]}
    b.staticMethod("LANG6") {_ => [LuaValue.of(Int64(KeyCode.LANG6))]}
    b.staticMethod("LANG7") {_ => [LuaValue.of(Int64(KeyCode.LANG7))]}
    b.staticMethod("LANG8") {_ => [LuaValue.of(Int64(KeyCode.LANG8))]}
    b.staticMethod("LANG9") {_ => [LuaValue.of(Int64(KeyCode.LANG9))]}
    b.staticMethod("ALTERASE") {_ => [LuaValue.of(Int64(KeyCode.ALTERASE))]}
    b.staticMethod("SYSREQ") {_ => [LuaValue.of(Int64(KeyCode.SYSREQ))]}
    b.staticMethod("CANCEL") {_ => [LuaValue.of(Int64(KeyCode.CANCEL))]}
    b.staticMethod("CLEAR") {_ => [LuaValue.of(Int64(KeyCode.CLEAR))]}
    b.staticMethod("PRIOR") {_ => [LuaValue.of(Int64(KeyCode.PRIOR))]}
    b.staticMethod("RETURN2") {_ => [LuaValue.of(Int64(KeyCode.RETURN2))]}
    b.staticMethod("SEPARATOR") {_ => [LuaValue.of(Int64(KeyCode.SEPARATOR))]}
    b.staticMethod("OUT") {_ => [LuaValue.of(Int64(KeyCode.OUT))]}
    b.staticMethod("OPER") {_ => [LuaValue.of(Int64(KeyCode.OPER))]}
    b.staticMethod("CLEARAGAIN") {_ => [LuaValue.of(Int64(KeyCode.CLEARAGAIN))]}
    b.staticMethod("CRSEL") {_ => [LuaValue.of(Int64(KeyCode.CRSEL))]}
    b.staticMethod("EXSEL") {_ => [LuaValue.of(Int64(KeyCode.EXSEL))]}
    b.staticMethod("KP_00") {_ => [LuaValue.of(Int64(KeyCode.KP_00))]}
    b.staticMethod("KP_000") {_ => [LuaValue.of(Int64(KeyCode.KP_000))]}
    b.staticMethod("THOUSANDSSEPARATOR") {_ => [LuaValue.of(Int64(KeyCode.THOUSANDSSEPARATOR))]}
    b.staticMethod("DECIMALSEPARATOR") {_ => [LuaValue.of(Int64(KeyCode.DECIMALSEPARATOR))]}
    b.staticMethod("CURRENCYUNIT") {_ => [LuaValue.of(Int64(KeyCode.CURRENCYUNIT))]}
    b.staticMethod("CURRENCYSUBUNIT") {_ => [LuaValue.of(Int64(KeyCode.CURRENCYSUBUNIT))]}
    b.staticMethod("KP_LEFTPAREN") {_ => [LuaValue.of(Int64(KeyCode.KP_LEFTPAREN))]}
    b.staticMethod("KP_RIGHTPAREN") {_ => [LuaValue.of(Int64(KeyCode.KP_RIGHTPAREN))]}
    b.staticMethod("KP_LEFTBRACE") {_ => [LuaValue.of(Int64(KeyCode.KP_LEFTBRACE))]}
    b.staticMethod("KP_RIGHTBRACE") {_ => [LuaValue.of(Int64(KeyCode.KP_RIGHTBRACE))]}
    b.staticMethod("KP_TAB") {_ => [LuaValue.of(Int64(KeyCode.KP_TAB))]}
    b.staticMethod("KP_BACKSPACE") {_ => [LuaValue.of(Int64(KeyCode.KP_BACKSPACE))]}
    b.staticMethod("KP_A") {_ => [LuaValue.of(Int64(KeyCode.KP_A))]}
    b.staticMethod("KP_B") {_ => [LuaValue.of(Int64(KeyCode.KP_B))]}
    b.staticMethod("KP_C") {_ => [LuaValue.of(Int64(KeyCode.KP_C))]}
    b.staticMethod("KP_D") {_ => [LuaValue.of(Int64(KeyCode.KP_D))]}
    b.staticMethod("KP_E") {_ => [LuaValue.of(Int64(KeyCode.KP_E))]}
    b.staticMethod("KP_F") {_ => [LuaValue.of(Int64(KeyCode.KP_F))]}
    b.staticMethod("KP_XOR") {_ => [LuaValue.of(Int64(KeyCode.KP_XOR))]}
    b.staticMethod("KP_POWER") {_ => [LuaValue.of(Int64(KeyCode.KP_POWER))]}
    b.staticMethod("KP_PERCENT") {_ => [LuaValue.of(Int64(KeyCode.KP_PERCENT))]}
    b.staticMethod("KP_LESS") {_ => [LuaValue.of(Int64(KeyCode.KP_LESS))]}
    b.staticMethod("KP_GREATER") {_ => [LuaValue.of(Int64(KeyCode.KP_GREATER))]}
    b.staticMethod("KP_AMPERSAND") {_ => [LuaValue.of(Int64(KeyCode.KP_AMPERSAND))]}
    b.staticMethod("KP_DBLAMPERSAND") {_ => [LuaValue.of(Int64(KeyCode.KP_DBLAMPERSAND))]}
    b.staticMethod("KP_VERTICALBAR") {_ => [LuaValue.of(Int64(KeyCode.KP_VERTICALBAR))]}
    b.staticMethod("KP_DBLVERTICALBAR") {_ => [LuaValue.of(Int64(KeyCode.KP_DBLVERTICALBAR))]}
    b.staticMethod("KP_COLON") {_ => [LuaValue.of(Int64(KeyCode.KP_COLON))]}
    b.staticMethod("KP_HASH") {_ => [LuaValue.of(Int64(KeyCode.KP_HASH))]}
    b.staticMethod("KP_SPACE") {_ => [LuaValue.of(Int64(KeyCode.KP_SPACE))]}
    b.staticMethod("KP_AT") {_ => [LuaValue.of(Int64(KeyCode.KP_AT))]}
    b.staticMethod("KP_EXCLAM") {_ => [LuaValue.of(Int64(KeyCode.KP_EXCLAM))]}
    b.staticMethod("KP_MEMSTORE") {_ => [LuaValue.of(Int64(KeyCode.KP_MEMSTORE))]}
    b.staticMethod("KP_MEMRECALL") {_ => [LuaValue.of(Int64(KeyCode.KP_MEMRECALL))]}
    b.staticMethod("KP_MEMCLEAR") {_ => [LuaValue.of(Int64(KeyCode.KP_MEMCLEAR))]}
    b.staticMethod("KP_MEMADD") {_ => [LuaValue.of(Int64(KeyCode.KP_MEMADD))]}
    b.staticMethod("KP_MEMSUBTRACT") {_ => [LuaValue.of(Int64(KeyCode.KP_MEMSUBTRACT))]}
    b.staticMethod("KP_MEMMULTIPLY") {_ => [LuaValue.of(Int64(KeyCode.KP_MEMMULTIPLY))]}
    b.staticMethod("KP_MEMDIVIDE") {_ => [LuaValue.of(Int64(KeyCode.KP_MEMDIVIDE))]}
    b.staticMethod("KP_PLUSMINUS") {_ => [LuaValue.of(Int64(KeyCode.KP_PLUSMINUS))]}
    b.staticMethod("KP_CLEAR") {_ => [LuaValue.of(Int64(KeyCode.KP_CLEAR))]}
    b.staticMethod("KP_CLEARENTRY") {_ => [LuaValue.of(Int64(KeyCode.KP_CLEARENTRY))]}
    b.staticMethod("KP_BINARY") {_ => [LuaValue.of(Int64(KeyCode.KP_BINARY))]}
    b.staticMethod("KP_OCTAL") {_ => [LuaValue.of(Int64(KeyCode.KP_OCTAL))]}
    b.staticMethod("KP_DECIMAL") {_ => [LuaValue.of(Int64(KeyCode.KP_DECIMAL))]}
    b.staticMethod("KP_HEXADECIMAL") {_ => [LuaValue.of(Int64(KeyCode.KP_HEXADECIMAL))]}
    b.staticMethod("LCTRL") {_ => [LuaValue.of(Int64(KeyCode.LCTRL))]}
    b.staticMethod("LSHIFT") {_ => [LuaValue.of(Int64(KeyCode.LSHIFT))]}
    b.staticMethod("LALT") {_ => [LuaValue.of(Int64(KeyCode.LALT))]}
    b.staticMethod("LGUI") {_ => [LuaValue.of(Int64(KeyCode.LGUI))]}
    b.staticMethod("RCTRL") {_ => [LuaValue.of(Int64(KeyCode.RCTRL))]}
    b.staticMethod("RSHIFT") {_ => [LuaValue.of(Int64(KeyCode.RSHIFT))]}
    b.staticMethod("RALT") {_ => [LuaValue.of(Int64(KeyCode.RALT))]}
    b.staticMethod("RGUI") {_ => [LuaValue.of(Int64(KeyCode.RGUI))]}
    b.staticMethod("MODE") {_ => [LuaValue.of(Int64(KeyCode.MODE))]}
    b.staticMethod("SLEEP") {_ => [LuaValue.of(Int64(KeyCode.SLEEP))]}
    b.staticMethod("WAKE") {_ => [LuaValue.of(Int64(KeyCode.WAKE))]}
    b.staticMethod("CHANNEL_INCREMENT") {_ => [LuaValue.of(Int64(KeyCode.CHANNEL_INCREMENT))]}
    b.staticMethod("CHANNEL_DECREMENT") {_ => [LuaValue.of(Int64(KeyCode.CHANNEL_DECREMENT))]}
    b.staticMethod("MEDIA_PLAY") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_PLAY))]}
    b.staticMethod("MEDIA_PAUSE") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_PAUSE))]}
    b.staticMethod("MEDIA_RECORD") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_RECORD))]}
    b.staticMethod("MEDIA_FAST_FORWARD") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_FAST_FORWARD))]}
    b.staticMethod("MEDIA_REWIND") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_REWIND))]}
    b.staticMethod("MEDIA_NEXT_TRACK") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_NEXT_TRACK))]}
    b.staticMethod("MEDIA_PREVIOUS_TRACK") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_PREVIOUS_TRACK))]}
    b.staticMethod("MEDIA_STOP") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_STOP))]}
    b.staticMethod("MEDIA_EJECT") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_EJECT))]}
    b.staticMethod("MEDIA_PLAY_PAUSE") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_PLAY_PAUSE))]}
    b.staticMethod("MEDIA_SELECT") {_ => [LuaValue.of(Int64(KeyCode.MEDIA_SELECT))]}
    b.staticMethod("AC_NEW") {_ => [LuaValue.of(Int64(KeyCode.AC_NEW))]}
    b.staticMethod("AC_OPEN") {_ => [LuaValue.of(Int64(KeyCode.AC_OPEN))]}
    b.staticMethod("AC_CLOSE") {_ => [LuaValue.of(Int64(KeyCode.AC_CLOSE))]}
    b.staticMethod("AC_EXIT") {_ => [LuaValue.of(Int64(KeyCode.AC_EXIT))]}
    b.staticMethod("AC_SAVE") {_ => [LuaValue.of(Int64(KeyCode.AC_SAVE))]}
    b.staticMethod("AC_PRINT") {_ => [LuaValue.of(Int64(KeyCode.AC_PRINT))]}
    b.staticMethod("AC_PROPERTIES") {_ => [LuaValue.of(Int64(KeyCode.AC_PROPERTIES))]}
    b.staticMethod("AC_SEARCH") {_ => [LuaValue.of(Int64(KeyCode.AC_SEARCH))]}
    b.staticMethod("AC_HOME") {_ => [LuaValue.of(Int64(KeyCode.AC_HOME))]}
    b.staticMethod("AC_BACK") {_ => [LuaValue.of(Int64(KeyCode.AC_BACK))]}
    b.staticMethod("AC_FORWARD") {_ => [LuaValue.of(Int64(KeyCode.AC_FORWARD))]}
    b.staticMethod("AC_STOP") {_ => [LuaValue.of(Int64(KeyCode.AC_STOP))]}
    b.staticMethod("AC_REFRESH") {_ => [LuaValue.of(Int64(KeyCode.AC_REFRESH))]}
    b.staticMethod("AC_BOOKMARKS") {_ => [LuaValue.of(Int64(KeyCode.AC_BOOKMARKS))]}
    b.staticMethod("SOFTLEFT") {_ => [LuaValue.of(Int64(KeyCode.SOFTLEFT))]}
    b.staticMethod("SOFTRIGHT") {_ => [LuaValue.of(Int64(KeyCode.SOFTRIGHT))]}
    b.staticMethod("CALL") {_ => [LuaValue.of(Int64(KeyCode.CALL))]}
    b.staticMethod("ENDCALL") {_ => [LuaValue.of(Int64(KeyCode.ENDCALL))]}
    b.staticMethod("RESERVED") {_ => [LuaValue.of(Int64(KeyCode.RESERVED))]}
    b.staticMethod("COUNT") {_ => [LuaValue.of(Int64(KeyCode.COUNT))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 MouseButton 鼠标按钮索引常量的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.window.MouseButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the MouseButton mouse-button index constants
 * @param[en] vm The target virtual machine (namespace table installed at three.window.MouseButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMouseButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.MouseButton")
    b.staticMethod("LEFT") {_ => [LuaValue.of(Int64(MouseButton.LEFT))]}
    b.staticMethod("MIDDLE") {_ => [LuaValue.of(Int64(MouseButton.MIDDLE))]}
    b.staticMethod("RIGHT") {_ => [LuaValue.of(Int64(MouseButton.RIGHT))]}
    b.staticMethod("X1") {_ => [LuaValue.of(Int64(MouseButton.X1))]}
    b.staticMethod("X2") {_ => [LuaValue.of(Int64(MouseButton.X2))]}
    b.install(vm)
}
