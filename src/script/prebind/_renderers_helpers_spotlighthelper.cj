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
 * @file[zh-cn] renderers_helpers_spotlighthelper SpotLightHelper 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.SpotLightHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 light / color；light 为 Light 对象时走带参构造，缺省走无参构造）、
 * 属性（light / color / cone）与方法 update，以及 Object3D 与 IReleasable 成员。color 为
 * Option<Color>：getter 在 None 时返回 nil，setter 接受 Color 对象、十六进制数值或 nil；cone 为
 * LineSegments 对象。Lua 类表没有继承，本类绑定在 b.install 之前复用 Object3D 与 IReleasable
 * 成员。跳过成员：无。
 *
 * @file[en] renderers_helpers_spotlighthelper  Lua binding of SpotLightHelper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.SpotLightHelper as a Lua type
 * @explain[en] Binds the constructor (optional light / color; a Light first argument selects the
 * parameterized overload, otherwise the no-arg one), the properties (light / color / cone) and
 * update, plus the Object3D and IReleasable members. color is Option<Color>: the getter yields nil
 * for None and the setter accepts a Color object, a hex number or nil; cone is a LineSegments
 * object. Lua class tables have no inheritance, so the Object3D and IReleasable members are reused
 * before b.install. Skipped: none.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.renderers.lights.*
import three.scene.objects.*
import three.scene.entity.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SpotLightHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.SpotLightHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SpotLightHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.SpotLightHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSpotLightHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.SpotLightHelper")
    // ===== 构造：可选 light / color（无 light 时走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            SpotLightHelper(prebindAs<Light>(args, 0), color: _prebindHlpOptColorArg(args, 1))
        } else {
            SpotLightHelper()
        }
    }
    // ===== 继承成员：Object3D → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 聚光灯辅助自有成员 =====
    b.property("light", getter: Some({
        ref => prebindRegister(ref.cast<SpotLightHelper>().light, "three.renderers.lights.Light")
    }), setter: Some({
        ref, v => ref.cast<SpotLightHelper>().light = prebindAsValue<Light>(v)
    }))
    b.property("color", getter: Some({ref => _prebindHlpOptColorToLua(ref.cast<SpotLightHelper>().color)}),
        setter: Some({
            ref, v => ref.cast<SpotLightHelper>().color = _prebindHlpOptColorFromLua(v)
        }))
    b.property("cone", getter: Some({
        ref => prebindRegister(ref.cast<SpotLightHelper>().cone, "three.scene.entity.LineSegments")
    }), setter: Some({
        ref, v => ref.cast<SpotLightHelper>().cone = prebindAsValue<LineSegments>(v)
    }))
    b.method("update") {
        ref, _ =>
            ref.cast<SpotLightHelper>().update()
            []
    }
    b.install(vm)
}
