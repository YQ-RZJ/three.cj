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
 * @file[zh-cn] renderers_helpers_pointlighthelper PointLightHelper 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.PointLightHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 light / sphereSize / color；light 为 Light 对象时走带参构造，
 * 缺省走无参构造）、属性（light / color）与方法 update，以及继承自 Mesh/Object3D 的全部成员和
 * releasable / release。color 为 Option<Color>：getter 在 None 时返回 nil，setter 接受 Color 对象、
 * 十六进制数值或 nil。Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D、Mesh 与
 * IReleasable 成员。跳过成员：无（morphTargetDictionary/getCullingGeometry 由 Mesh 绑定统一跳过）。
 *
 * @file[en] renderers_helpers_pointlighthelper  Lua binding of PointLightHelper
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.PointLightHelper as a Lua type
 * @explain[en] Binds the constructor (optional light / sphereSize / color; a Light first argument
 * selects the parameterized overload, otherwise the no-arg one), the properties (light / color) and
 * update, plus every inherited Mesh/Object3D member and releasable / release. color is
 * Option<Color>: the getter yields nil for None and the setter accepts a Color object, a hex number
 * or nil. Lua class tables have no inheritance, so the Object3D, Mesh and IReleasable members are
 * reused before b.install. Skipped: none (morphTargetDictionary/getCullingGeometry are skipped by
 * the Mesh binding).
 */
package three.script.prebind

import three.renderers.helpers.*
import three.renderers.lights.*
import three.scene.objects.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PointLightHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.PointLightHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PointLightHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.PointLightHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPointLightHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.PointLightHelper")
    // ===== 构造：可选 light / sphereSize / color（无 light 时走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            PointLightHelper(prebindAs<Light>(args, 0), sphereSize: prebindNum(args, 1, default: 1.0),
                color: _prebindHlpOptColorArg(args, 2))
        } else {
            PointLightHelper()
        }
    }
    // ===== 继承成员：Object3D → Mesh → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpMeshMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 点光源辅助自有成员 =====
    b.property("light", getter: Some({
        ref => prebindRegister(ref.cast<PointLightHelper>().light, "three.renderers.lights.Light")
    }), setter: Some({
        ref, v => ref.cast<PointLightHelper>().light = prebindAsValue<Light>(v)
    }))
    b.property("color", getter: Some({ref => _prebindHlpOptColorToLua(ref.cast<PointLightHelper>().color)}),
        setter: Some({
            ref, v => ref.cast<PointLightHelper>().color = _prebindHlpOptColorFromLua(v)
        }))
    b.method("update") {
        ref, _ =>
            ref.cast<PointLightHelper>().update()
            []
    }
    b.install(vm)
}
