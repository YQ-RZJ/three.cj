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
 * @file[zh-cn] window_inputprovider 输入提供者基类的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 InputProvider 基类绑定为 Lua 类型 three.window.InputProvider
 * @explain[zh-cn] InputProvider 是 Cangjie 侧供子类扩展的抽象基类，Lua 无法继承它，
 * 因此本绑定不提供 constructor（Lua 侧无 new），只暴露基类可观测能力：
 * getWindow（已绑定窗口，None → nil）、isBound、release。
 * Lua 侧实际拿到的提供者实例来自具体子类（KeyboardProvider/MouseProvider/
 * TouchProvider/GamepadProvider，以及 WindowEngine.getProviders 的返回）。
 * 跳过成员及原因：
 * - init/beginFrame/onEvent/endFrame（open 方法）：面向 Cangjie 子类覆写；
 *   且 onEvent 的参数 DispatchEvent 字段非 public，Lua 无法读取事件内容，绑定时回调没有意义。
 *
 * @file[en] window_inputprovider  Lua binding of the input provider base class (three.script.prebind)
 * @brief[en] Binds the InputProvider base class as the Lua type three.window.InputProvider
 * @explain[en] InputProvider is an abstract base meant for Cangjie subclassing, and Lua cannot
 * inherit it, so this binding exposes no constructor (no new on the Lua side) and provides only
 * the base-class observable capabilities: getWindow (bound window, None → nil), isBound and release.
 * Lua obtains provider instances from the concrete subclasses (KeyboardProvider/MouseProvider/
 * TouchProvider/GamepadProvider) and from WindowEngine.getProviders.
 * Skipped members and reasons:
 * - init/beginFrame/onEvent/endFrame (open methods): meant for Cangjie subclass overrides;
 *   moreover DispatchEvent's fields are non-public, so Lua cannot inspect event content and a
 *   bound callback would be useless.
 */
package three.script.prebind

import three.window.InputProvider
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 InputProvider 的 Lua 绑定（无构造，仅基类能力）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.InputProvider）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of InputProvider (no constructor; base capabilities only)
 * @param[en] vm The target virtual machine (class table installed at three.window.InputProvider)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installInputProvider(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.InputProvider")
    b.method("getWindow") {
        ref, _ => match (ref.cast<InputProvider>().getWindow()) {
            case Some(w) => [prebindRegister(w, "three.window.WindowEngine")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("isBound") {ref, _ => [LuaValue.of(ref.cast<InputProvider>().isBound())]}
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<InputProvider>().release())]}
    b.install(vm)
}
