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
 * @file[zh-cn] renderers_lights_light 光源基类 Light 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.Light 绑定为 Lua 类型并导出各光源子类共用的成员安装函数
 * @explain[zh-cn] 绑定构造（color / intensity，另含 hex 单参重载的数值颜色入口）、属性
 * （color / intensity / releasable）与方法（release）。color 以 Color 对象往返，Lua 侧首参
 * 传数值时按十六进制颜色构造，传 Color 对象时直接取值，缺省为白色。Lua 类表没有继承，
 * 所有 Light 子类的绑定都必须在 b.install 之前调用 prebindInstallObject3DMembers 与本文件的
 * _prebindLgtLightMembers。跳过成员及原因：
 * - copy：仅重写 Object3D 的 copy，未新增 Lua 名称，由 Object3D 绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_lights_light  Lua binding of the Light base class (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.Light and exports the shared subclass member installer
 * @explain[en] Binds the constructor (color / intensity, plus the numeric-color form of the hex
 * overload), properties (color / intensity / releasable) and release. color round-trips as a Color
 * object; a numeric first argument is interpreted as a hex color, a Color object is taken as-is,
 * and white is the default. Lua class tables have no inheritance, so every Light subclass binding
 * must call prebindInstallObject3DMembers and _prebindLgtLightMembers from this file before
 * b.install. Skipped members and reasons:
 * - copy: only an override of Object3D.copy with no new Lua name, covered by the Object3D binding
 *   via virtual dispatch.
 */
package three.script.prebind

import three.renderers.lights.*
import three.core.math.*
import three.scene.objects.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将颜色对象注册为 Lua 值
 * @param[zh-cn] color 颜色对象
 * @return[zh-cn] Lua 对象值
 *
 * @brief[en] Registers a color object as a Lua value
 * @param[en] color The color object
 * @return[en] The Lua object value
 */
internal func _prebindLgtColorToLua(color: Color): LuaValue {
    return prebindRegister(color, "three.core.math.Color")
}

/**
 * @brief[zh-cn] 将 Lua 值取回为颜色对象
 * @param[zh-cn] v Lua 对象值
 * @return[zh-cn] 颜色对象
 *
 * @brief[en] Fetches a color object from a Lua value
 * @param[en] v The Lua object value
 * @return[en] The color object
 */
internal func _prebindLgtColorFromLua(v: LuaValue): Color {
    return prebindAsValue<Color>(v)
}

/**
 * @brief[zh-cn] 读取可选颜色参数（支持 Color 对象与十六进制数值，缺省返回默认颜色）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @param[zh-cn] default 缺省颜色
 * @return[zh-cn] 颜色对象
 *
 * @brief[en] Reads an optional color argument (Color object or hex number, default when absent)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @param[en] default The default color
 * @return[en] The color object
 */
internal func _prebindLgtColorArg(args: Array<LuaValue>, idx: Int64, default!: Color = Color(0xffffff)): Color {
    if (args.size <= idx || args[idx].isNil) {
        return default
    }
    let v = args[idx]
    if (v.isObject) {
        return prebindAsValue<Color>(v)
    }
    if (v.isInteger || v.isNumber) {
        return Color(UInt32(v.numberValue()))
    }
    return default
}

/**
 * @brief[zh-cn] 为绑定器安装 Light 的成员（构造与 Object3D 成员除外）
 * @explain[zh-cn] Lua 类表没有继承，所有 Light 子类的绑定都必须在 b.install 之前调用本函数，
 * 否则子类实例只能看到自己新增的成员。release 按 Light 强转后经虚函数分派，子类覆写自动生效。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Light members (except the constructor and Object3D members) on a binder
 * @explain[en] Lua class tables have no inheritance, so every Light subclass binding must call this
 * before b.install; otherwise instances only expose their own extra members. release casts to Light
 * and relies on virtual dispatch, so subclass overrides apply automatically.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine
 */
internal func _prebindLgtLightMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 颜色 / 强度 =====
    b.property("color", getter: Some({ref => _prebindLgtColorToLua(ref.cast<Light>().color)}),
        setter: Some({ref, v => ref.cast<Light>().color = _prebindLgtColorFromLua(v)}))
    b.property("intensity", getter: Some({ref => LuaValue.of(ref.cast<Light>().intensity)}),
        setter: Some({ref, v => ref.cast<Light>().intensity = v.numberValue()}))
    // ===== IReleasable =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<Light>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<Light>().release())]
    }
}

/**
 * @brief[zh-cn] 安装 Light 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.Light）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Light
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.Light)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLight(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.Light")
    // ===== 构造：color（Color 或 hex 数值）+ intensity =====
    b.constructor {
        args =>
            let intensity = prebindNum(args, 1, default: 1.0)
            if (args.size > 0 && !args[0].isNil && !args[0].isObject) {
                Light(UInt32(args[0].numberValue()), intensity: intensity)
            } else {
                Light(color: _prebindLgtColorArg(args, 0), intensity: intensity)
            }
    }
    // ===== Object3D 继承成员 =====
    prebindInstallObject3DMembers(b, vm)
    // ===== Light 自有成员 =====
    _prebindLgtLightMembers(b, vm)
    b.install(vm)
}
