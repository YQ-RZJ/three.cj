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
 * @file[zh-cn] window_mouseprovider 鼠标输入提供者的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 MouseProvider 绑定为 Lua 类型 three.window.MouseProvider
 * @explain[zh-cn] 绑定无参构造、鼠标状态查询（坐标/位移/按键/滚轮）与基类能力
 * （getWindow/isBound/release）。按键索引用 SDL 编号（1=左 2=中 3=右，见 MouseButton）。
 *
 * @file[en] window_mouseprovider  Lua binding of the mouse input provider (three.script.prebind)
 * @brief[en] Binds MouseProvider as the Lua type three.window.MouseProvider
 * @explain[en] Binds the no-arg constructor, mouse state queries (position/delta/buttons/wheel)
 * and the base-class capabilities (getWindow/isBound/release). Button indices use SDL numbering
 * (1=left, 2=middle, 3=right; see MouseButton).
 */
package three.script.prebind

import three.window.MouseProvider
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MouseProvider 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.MouseProvider）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MouseProvider
 * @param[en] vm The target virtual machine (class table installed at three.window.MouseProvider)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMouseProvider(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.MouseProvider")
    b.constructor {_ => MouseProvider()}
    b.method("getMouseX") {
        ref, _ => [LuaValue.of(Float64(ref.cast<MouseProvider>().getMouseX()))]
    }
    b.method("getMouseY") {
        ref, _ => [LuaValue.of(Float64(ref.cast<MouseProvider>().getMouseY()))]
    }
    b.method("getMouseDX") {
        ref, _ => [LuaValue.of(Float64(ref.cast<MouseProvider>().getMouseDX()))]
    }
    b.method("getMouseDY") {
        ref, _ => [LuaValue.of(Float64(ref.cast<MouseProvider>().getMouseDY()))]
    }
    b.method("isMouseButtonDown") {
        ref, args => [LuaValue.of(ref.cast<MouseProvider>().isMouseButtonDown(UInt8(prebindInt(args, 0) & 0xFF)))]
    }
    b.method("getWheelX") {
        ref, _ => [LuaValue.of(Float64(ref.cast<MouseProvider>().getWheelX()))]
    }
    b.method("getWheelY") {
        ref, _ => [LuaValue.of(Float64(ref.cast<MouseProvider>().getWheelY()))]
    }
    b.method("getWindow") {
        ref, _ => match (ref.cast<MouseProvider>().getWindow()) {
            case Some(w) => [prebindRegister(w, "three.window.WindowEngine")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("isBound") {ref, _ => [LuaValue.of(ref.cast<MouseProvider>().isBound())]}
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<MouseProvider>().release())]}
    b.install(vm)
}
