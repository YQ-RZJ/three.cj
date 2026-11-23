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
 * @file[zh-cn] window_keyboardprovider 键盘输入提供者的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 KeyboardProvider 绑定为 Lua 类型 three.window.KeyboardProvider
 * @explain[zh-cn] 绑定无参构造、键盘轮询（isKeyDown/isKeyPressed/isKeyReleased）与基类能力
 * （getWindow/isBound/release）。键码参数为 SDL 扫描码（配合 three.window.KeyCode 常量）。
 *
 * @file[en] window_keyboardprovider  Lua binding of the keyboard input provider (three.script.prebind)
 * @brief[en] Binds KeyboardProvider as the Lua type three.window.KeyboardProvider
 * @explain[en] Binds the no-arg constructor, keyboard polling (isKeyDown/isKeyPressed/isKeyReleased)
 * and the base-class capabilities (getWindow/isBound/release). Key arguments are SDL scancodes
 * (pair with the three.window.KeyCode constants).
 */
package three.script.prebind

import three.window.KeyboardProvider
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 KeyboardProvider 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.KeyboardProvider）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of KeyboardProvider
 * @param[en] vm The target virtual machine (class table installed at three.window.KeyboardProvider)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installKeyboardProvider(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.KeyboardProvider")
    b.constructor {_ => KeyboardProvider()}
    b.method("isKeyDown") {
        ref, args => [LuaValue.of(ref.cast<KeyboardProvider>().isKeyDown(UInt32(prebindInt(args, 0) & 0xFFFFFFFF)))]
    }
    b.method("isKeyPressed") {
        ref, args => [LuaValue.of(ref.cast<KeyboardProvider>().isKeyPressed(UInt32(prebindInt(args, 0) & 0xFFFFFFFF)))]
    }
    b.method("isKeyReleased") {
        ref, args => [LuaValue.of(ref.cast<KeyboardProvider>().isKeyReleased(UInt32(prebindInt(args, 0) & 0xFFFFFFFF)))]
    }
    b.method("getWindow") {
        ref, _ => match (ref.cast<KeyboardProvider>().getWindow()) {
            case Some(w) => [prebindRegister(w, "three.window.WindowEngine")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("isBound") {ref, _ => [LuaValue.of(ref.cast<KeyboardProvider>().isBound())]}
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<KeyboardProvider>().release())]}
    b.install(vm)
}
