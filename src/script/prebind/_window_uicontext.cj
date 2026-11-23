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
 * @file[zh-cn] window_uicontext UI 上下文的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 UiContext 的可观测能力绑定为 Lua 类型 three.window.UiContext
 * @explain[zh-cn] UiContext 的初始化/关闭/帧驱动/事件写入均为 internal，由 WindowEngine 管理，
 * 因此 Lua 侧只暴露：无参构造、initialized（是否已初始化）、setPixelRatio(value)、
 * 以及静态像素比 currentPixelRatio()。窗口引擎实例通过 WindowEngine.gui 获取。
 *
 * @file[en] window_uicontext  Lua binding of the UI context (three.script.prebind)
 * @brief[en] Binds the observable capabilities of UiContext as the Lua type three.window.UiContext
 * @explain[en] UiContext's initialize/shutdown/frame driving/event writing are internal and managed
 * by WindowEngine, so the Lua side exposes only: the no-arg constructor, initialized, setPixelRatio(value)
 * and the static pixel ratio currentPixelRatio(). Obtain the instance through WindowEngine.gui.
 */
package three.script.prebind

import three.window.UiContext
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 UiContext 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.UiContext）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiContext
 * @param[en] vm The target virtual machine (class table installed at three.window.UiContext)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiContext(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.UiContext")
    b.constructor {_ => UiContext()}
    b.property("initialized", getter: Some({ref => LuaValue.of(ref.cast<UiContext>().initialized)}))
    b.method("setPixelRatio") {
        ref, args =>
            ref.cast<UiContext>().setPixelRatio(prebindNum(args, 0))
            []
    }
    b.staticMethod("currentPixelRatio") {_ => [LuaValue.of(UiContext.currentPixelRatio)]}
    b.install(vm)
}
