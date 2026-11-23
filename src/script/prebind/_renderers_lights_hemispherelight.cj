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
 * @file[zh-cn] renderers_lights_hemispherelight 半球光 HemisphereLight 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.HemisphereLight 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（skyColor / groundColor / intensity）与属性（skyColor / groundColor）。
 * Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D 与 Light 的成员。两个颜色支持
 * Color 对象或十六进制数值，缺省分别为白色与黑色。跳过成员：copy 仅重写 Object3D.copy，
 * 由基类绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_lights_hemispherelight  Lua binding of HemisphereLight (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.HemisphereLight as a Lua type
 * @explain[en] Binds the constructor (skyColor / groundColor / intensity) and properties
 * (skyColor / groundColor). Lua class tables have no inheritance, so this binding reuses the
 * Object3D and Light members before b.install. Both colors accept a Color object or a hex number,
 * defaulting to white and black respectively. Skipped: copy, which only overrides Object3D.copy
 * and is covered by the base binding via virtual dispatch.
 */
package three.script.prebind

import three.renderers.lights.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 HemisphereLight 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.HemisphereLight）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of HemisphereLight
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.HemisphereLight)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installHemisphereLight(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.HemisphereLight")
    // ===== 构造 =====
    b.constructor {
        args => HemisphereLight(skyColor: _prebindLgtColorArg(args, 0, default: Color(0xffffff)),
            groundColor: _prebindLgtColorArg(args, 1, default: Color(0x000000)),
            intensity: prebindNum(args, 2, default: 1.0))
    }
    // ===== 继承成员：Object3D → Light =====
    prebindInstallObject3DMembers(b, vm)
    _prebindLgtLightMembers(b, vm)
    // ===== 半球光自有成员 =====
    b.property("skyColor", getter: Some({ref => _prebindLgtColorToLua(ref.cast<HemisphereLight>().skyColor)}),
        setter: Some({ref, v => ref.cast<HemisphereLight>().skyColor = _prebindLgtColorFromLua(v)}))
    b.property("groundColor", getter: Some({ref => _prebindLgtColorToLua(ref.cast<HemisphereLight>().groundColor)}),
        setter: Some({ref, v => ref.cast<HemisphereLight>().groundColor = _prebindLgtColorFromLua(v)}))
    b.install(vm)
}
