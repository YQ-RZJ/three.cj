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
 * @file[zh-cn] renderers_lights_pointlight 点光源 PointLight 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.PointLight 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（color / intensity / distance / decay）、属性（distance / decay /
 * shadow / power）。shadow 为 PointLightShadow；power 为可读写属性，按源码公式与 intensity
 * 换算。Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D 与 Light 的成员。
 * release 经 Light 绑定虚分派到本类覆写（同时释放 shadow）。跳过成员：copy 仅重写
 * Object3D.copy，且同名同签名，由基类绑定覆盖。
 *
 * @file[en] renderers_lights_pointlight  Lua binding of PointLight (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.PointLight as a Lua type
 * @explain[en] Binds the constructor (color / intensity / distance / decay), properties (distance /
 * decay / shadow / power). shadow is a PointLightShadow; power is read-write and converts to/from
 * intensity with the source formula. Lua class tables have no inheritance, so this binding reuses
 * the Object3D and Light members before b.install. release dispatches virtually from the Light
 * binding to this class's override (which also releases shadow). Skipped: copy, an override of
 * Object3D.copy with the same name, covered by the base binding.
 */
package three.script.prebind

import three.renderers.lights.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PointLight 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.PointLight）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PointLight
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.PointLight)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPointLight(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.PointLight")
    // ===== 构造 =====
    b.constructor {
        args => PointLight(color: _prebindLgtColorArg(args, 0), intensity: prebindNum(args, 1, default: 1.0),
            distance: prebindNum(args, 2, default: 0.0), decay: prebindNum(args, 3, default: 2.0))
    }
    // ===== 继承成员：Object3D → Light =====
    prebindInstallObject3DMembers(b, vm)
    _prebindLgtLightMembers(b, vm)
    // ===== 点光源自有成员 =====
    b.property("distance", getter: Some({ref => LuaValue.of(ref.cast<PointLight>().distance)}),
        setter: Some({ref, v => ref.cast<PointLight>().distance = v.numberValue()}))
    b.property("decay", getter: Some({ref => LuaValue.of(ref.cast<PointLight>().decay)}),
        setter: Some({ref, v => ref.cast<PointLight>().decay = v.numberValue()}))
    b.property("shadow", getter: Some({
        ref => prebindRegister(ref.cast<PointLight>().shadow, "three.renderers.lights.PointLightShadow")
    }), setter: Some({
        ref, v => ref.cast<PointLight>().shadow = prebindAsValue<PointLightShadow>(v)
    }))
    b.property("power", getter: Some({ref => LuaValue.of(ref.cast<PointLight>().power)}),
        setter: Some({ref, v => ref.cast<PointLight>().power = v.numberValue()}))
    b.install(vm)
}
