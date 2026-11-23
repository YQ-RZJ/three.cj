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
 * you may redistribute such product without attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] renderers_lights_spotlightshadow 聚光源阴影 SpotLightShadow 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.SpotLightShadow 绑定为 Lua 类型
 * @explain[zh-cn] 绑定无参构造与属性（focus / aspect）。Lua 类表没有继承，本类绑定在 b.install
 * 之前复用 _prebindLgtLightShadowMembers 的成员。跳过成员及原因：
 * - updateMatrices：仅重写 LightShadow.updateMatrices，同名方法经基类绑定的虚函数分派覆盖；
 * - copy：仅重写 LightShadow.copy，同上，重复登记会让分发不确定。
 *
 * @file[en] renderers_lights_spotlightshadow  Lua binding of SpotLightShadow
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.SpotLightShadow as a Lua type
 * @explain[en] Binds the no-arg constructor and properties (focus / aspect). Lua class tables have
 * no inheritance, so this binding reuses _prebindLgtLightShadowMembers before b.install. Skipped
 * members and reasons:
 * - updateMatrices: only an override of LightShadow.updateMatrices, covered by the base binding
 *   via virtual dispatch;
 * - copy: only an override of LightShadow.copy, same as above; duplicate registration would make
 *   dispatch nondeterministic.
 */
package three.script.prebind

import three.renderers.lights.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SpotLightShadow 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.SpotLightShadow）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SpotLightShadow
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.SpotLightShadow)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSpotLightShadow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.SpotLightShadow")
    // ===== 构造 =====
    b.constructor {_ => SpotLightShadow()}
    // ===== 继承成员：LightShadow =====
    _prebindLgtLightShadowMembers(b, vm)
    // ===== 聚光源阴影自有成员 =====
    b.property("focus", getter: Some({ref => LuaValue.of(ref.cast<SpotLightShadow>().focus)}),
        setter: Some({ref, v => ref.cast<SpotLightShadow>().focus = v.numberValue()}))
    b.property("aspect", getter: Some({ref => LuaValue.of(ref.cast<SpotLightShadow>().aspect)}),
        setter: Some({ref, v => ref.cast<SpotLightShadow>().aspect = v.numberValue()}))
    b.install(vm)
}
