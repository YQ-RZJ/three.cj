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
 * @file[zh-cn] renderers_lights_rectarealight 矩形面光源 RectAreaLight 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.RectAreaLight 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（color / intensity / width / height）、属性（width / height / power）
 * 与 release（继承自 Light）。power 为可读写属性，读写时按源码公式在 intensity 之间换算。
 * Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D 与 Light 的成员。
 * 跳过成员：copy 仅重写 Object3D.copy，由基类绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_lights_rectarealight  Lua binding of RectAreaLight (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.RectAreaLight as a Lua type
 * @explain[en] Binds the constructor (color / intensity / width / height), properties
 * (width / height / power) and release (inherited from Light). power is read-write and converts
 * to/from intensity with the formula from the source. Lua class tables have no inheritance, so this
 * binding reuses the Object3D and Light members before b.install. Skipped: copy, which only
 * overrides Object3D.copy and is covered by the base binding via virtual dispatch.
 */
package three.script.prebind

import three.renderers.lights.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RectAreaLight 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.RectAreaLight）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RectAreaLight
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.RectAreaLight)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRectAreaLight(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.RectAreaLight")
    // ===== 构造 =====
    b.constructor {
        args => RectAreaLight(color: _prebindLgtColorArg(args, 0), intensity: prebindNum(args, 1, default: 1.0),
            width: prebindNum(args, 2, default: 10.0), height: prebindNum(args, 3, default: 10.0))
    }
    // ===== 继承成员：Object3D → Light =====
    prebindInstallObject3DMembers(b, vm)
    _prebindLgtLightMembers(b, vm)
    // ===== 矩形面光源自有成员 =====
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<RectAreaLight>().width)}),
        setter: Some({ref, v => ref.cast<RectAreaLight>().width = v.numberValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<RectAreaLight>().height)}),
        setter: Some({ref, v => ref.cast<RectAreaLight>().height = v.numberValue()}))
    b.property("power", getter: Some({ref => LuaValue.of(ref.cast<RectAreaLight>().power)}),
        setter: Some({ref, v => ref.cast<RectAreaLight>().power = v.numberValue()}))
    b.install(vm)
}
