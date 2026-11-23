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
 * @file[zh-cn] window_ui_uiviewport UiViewport.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiViewport 绑定为 Lua 类型 three.window.ui.UiViewport
 * @explain[zh-cn] 覆盖：静态工厂 getMain()/getWindowViewport()，以及全部只读实例方法
 * （getPos/getSize/getWorkPos/getWorkSize、getDpiScale、getCenter/getWorkCenter）。
 * 适配约定：
 * - 该类只有 internal 构造（接收 CPointer），脚本侧不提供 constructor，实例只能经静态工厂获取；
 * - getPos/getSize/getWorkPos/getWorkSize 的 (Float32, Float32) 元组返回值转为 Lua 数组
 *   [x, y] / [w, h]（元素按 Float64 呈现）；
 * - getCenter/getWorkCenter 的 Vector2 返回值经 prebindRegister 注册为 three.core.math.Vector2；
 * - getDpiScale 以 Float64(...) 返回；静态工厂返回值经 prebindRegister 注册为
 *   three.window.ui.UiViewport。
 * 跳过成员及原因：
 * - getHandle() 返回 VoidPtr（底层 ImGuiViewport 裸指针），不属于脚本接口，跳过；
 * - private 字段 _vp 不暴露。
 *
 * @file[en] window_ui_uiviewport  Lua binding of UiViewport.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiViewport as the Lua type three.window.ui.UiViewport
 * @explain[en] Coverage: static factories getMain()/getWindowViewport() and all read-only instance
 * methods (getPos/getSize/getWorkPos/getWorkSize, getDpiScale, getCenter/getWorkCenter).
 * Conventions:
 * - The class only has an internal constructor (taking a CPointer), so no constructor is exposed and
 *   instances are obtained through the static factories only;
 * - The (Float32, Float32) tuples returned by getPos/getSize/getWorkPos/getWorkSize become Lua arrays
 *   [x, y] / [w, h] (elements rendered as Float64);
 * - The Vector2 results of getCenter/getWorkCenter are registered as three.core.math.Vector2 via
 *   prebindRegister;
 * - getDpiScale is returned as Float64(...), and static-factory results are registered as
 *   three.window.ui.UiViewport.
 * Skipped members and reasons:
 * - getHandle() returns VoidPtr (the raw ImGuiViewport pointer) and is not a script API — skipped;
 * - The private field _vp is not exposed.
 */
package three.script.prebind

import three.core.math.*
import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将 (Float32, Float32) 元组转为 Lua 数值数组
 * @param[zh-cn] pair 二维元组
 * @return[zh-cn] 单元素 Lua 返回值（数组 [a, b]）
 *
 * @brief[en] Converts a (Float32, Float32) tuple into a Lua number array
 * @param[en] pair The two-element tuple
 * @return[en] A single-element Lua return value (array [a, b])
 */
private func _prebindUivPair(pair: (Float32, Float32)): Array<LuaValue> {
    let (a, b) = pair
    return [LuaValue.Array([LuaValue.of(Float64(a)), LuaValue.of(Float64(b))])]
}

/**
 * @brief[zh-cn] 安装 UiViewport 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiViewport）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiViewport
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiViewport)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiViewport(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiViewport")
    b.staticMethod("getMain") {
        _ => [prebindRegister(UiViewport.getMain(), "three.window.ui.UiViewport")]
    }
    b.staticMethod("getWindowViewport") {
        _ => [prebindRegister(UiViewport.getWindowViewport(), "three.window.ui.UiViewport")]
    }
    b.method("getPos") {ref, _ => _prebindUivPair(ref.cast<UiViewport>().getPos())}
    b.method("getSize") {ref, _ => _prebindUivPair(ref.cast<UiViewport>().getSize())}
    b.method("getWorkPos") {ref, _ => _prebindUivPair(ref.cast<UiViewport>().getWorkPos())}
    b.method("getWorkSize") {ref, _ => _prebindUivPair(ref.cast<UiViewport>().getWorkSize())}
    b.method("getDpiScale") {
        ref, _ => [LuaValue.of(Float64(ref.cast<UiViewport>().getDpiScale()))]
    }
    b.method("getCenter") {
        ref, _ => [prebindRegister(ref.cast<UiViewport>().getCenter(), "three.core.math.Vector2")]
    }
    b.method("getWorkCenter") {
        ref, _ => [prebindRegister(ref.cast<UiViewport>().getWorkCenter(), "three.core.math.Vector2")]
    }
    b.install(vm)
}
