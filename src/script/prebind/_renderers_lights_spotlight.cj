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
 * @file[zh-cn] renderers_lights_spotlight 聚光源 SpotLight 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.SpotLight 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（color / intensity / distance / angle / penumbra / decay）、属性
 * （target / angle / penumbra / decay / distance / shadow / map / power）。target 为 Object3D，
 * shadow 为 SpotLightShadow，map 为 Option<Texture>（None 用 nil 表示），power 按源码公式与
 * intensity 换算。Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D 与 Light 的
 * 成员。release 经 Light 绑定虚分派到本类覆写（同时释放 shadow）。跳过成员：copy 仅重写
 * Object3D.copy，且同名同签名，由基类绑定覆盖。
 *
 * @file[en] renderers_lights_spotlight  Lua binding of SpotLight (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.SpotLight as a Lua type
 * @explain[en] Binds the constructor (color / intensity / distance / angle / penumbra / decay),
 * properties (target / angle / penumbra / decay / distance / shadow / map / power). target is an
 * Object3D, shadow a SpotLightShadow, map an Option<Texture> (nil for None), and power converts
 * to/from intensity with the source formula. Lua class tables have no inheritance, so this binding
 * reuses the Object3D and Light members before b.install. release dispatches virtually from the
 * Light binding to this class's override (which also releases shadow). Skipped: copy, an override
 * of Object3D.copy with the same name, covered by the base binding.
 */
package three.script.prebind

import three.renderers.lights.*
import three.renderers.textures.*
import three.core.math.*
import three.scene.objects.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将可选纹理转为 Lua 值（Some 注册对象，None 返回 nil）
 * @param[zh-cn] tex 可选纹理
 * @return[zh-cn] Lua 值
 *
 * @brief[en] Converts an optional texture into a Lua value (Some registers, None is nil)
 * @param[en] tex The optional texture
 * @return[en] The Lua value
 */
internal func _prebindLgtTextureToLua(tex: Option<Texture>): LuaValue {
    match (tex) {
        case Some(t) => prebindRegister(t, "three.renderers.textures.Texture")
        case None => LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 将 Lua 值转为可选纹理（nil/非对象返回 None）
 * @param[zh-cn] v Lua 值
 * @return[zh-cn] 可选纹理
 *
 * @brief[en] Converts a Lua value into an optional texture (nil/non-object yields None)
 * @param[en] v The Lua value
 * @return[en] The optional texture
 */
internal func _prebindLgtTextureFromLua(v: LuaValue): Option<Texture> {
    if (v.isNil || !v.isObject) {
        return None
    }
    return Some(prebindAsValue<Texture>(v))
}

/**
 * @brief[zh-cn] 安装 SpotLight 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.SpotLight）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SpotLight
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.SpotLight)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSpotLight(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.SpotLight")
    // ===== 构造 =====
    b.constructor {
        args => SpotLight(color: _prebindLgtColorArg(args, 0), intensity: prebindNum(args, 1, default: 1.0),
            distance: prebindNum(args, 2, default: 0.0), angle: prebindNum(args, 3, default: PI / 3.0),
            penumbra: prebindNum(args, 4, default: 0.0), decay: prebindNum(args, 5, default: 2.0))
    }
    // ===== 继承成员：Object3D → Light =====
    prebindInstallObject3DMembers(b, vm)
    _prebindLgtLightMembers(b, vm)
    // ===== 聚光源自有成员 =====
    b.property("target", getter: Some({
        ref => prebindRegister(ref.cast<SpotLight>().target, "three.scene.objects.Object3D")
    }), setter: Some({
        ref, v => ref.cast<SpotLight>().target = prebindAsValue<Object3D>(v)
    }))
    b.property("angle", getter: Some({ref => LuaValue.of(ref.cast<SpotLight>().angle)}),
        setter: Some({ref, v => ref.cast<SpotLight>().angle = v.numberValue()}))
    b.property("penumbra", getter: Some({ref => LuaValue.of(ref.cast<SpotLight>().penumbra)}),
        setter: Some({ref, v => ref.cast<SpotLight>().penumbra = v.numberValue()}))
    b.property("decay", getter: Some({ref => LuaValue.of(ref.cast<SpotLight>().decay)}),
        setter: Some({ref, v => ref.cast<SpotLight>().decay = v.numberValue()}))
    b.property("distance", getter: Some({ref => LuaValue.of(ref.cast<SpotLight>().distance)}),
        setter: Some({ref, v => ref.cast<SpotLight>().distance = v.numberValue()}))
    b.property("shadow", getter: Some({
        ref => prebindRegister(ref.cast<SpotLight>().shadow, "three.renderers.lights.SpotLightShadow")
    }), setter: Some({
        ref, v => ref.cast<SpotLight>().shadow = prebindAsValue<SpotLightShadow>(v)
    }))
    b.property("map", getter: Some({ref => _prebindLgtTextureToLua(ref.cast<SpotLight>().map)}),
        setter: Some({ref, v => ref.cast<SpotLight>().map = _prebindLgtTextureFromLua(v)}))
    b.property("power", getter: Some({ref => LuaValue.of(ref.cast<SpotLight>().power)}),
        setter: Some({ref, v => ref.cast<SpotLight>().power = v.numberValue()}))
    b.install(vm)
}
