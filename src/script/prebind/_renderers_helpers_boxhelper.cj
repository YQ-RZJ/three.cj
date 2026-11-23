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
 * @file[zh-cn] renderers_helpers_boxhelper BoxHelper 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.BoxHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 object 与 color：首参为 Object3D 对象时走带参构造，缺省走无参
 * 构造）、属性 object（Object3D）、方法 update / setFromObject（返回自身），以及继承自
 * LineSegments/Line/Object3D 的全部成员和 releasable / release。Lua 类表没有继承，本类绑定在
 * b.install 之前依次复用 Object3D、LineSegments（含 Line）与 IReleasable 成员。跳过成员：copy
 * 仅重写 Object3D.copy，由基类绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_helpers_boxhelper  Lua binding of BoxHelper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.BoxHelper as a Lua type
 * @explain[en] Binds the constructor (optional object and color: an Object3D first argument selects
 * the parameterized overload, otherwise the no-arg one), the object property, the update /
 * setFromObject methods (returns self), and every inherited LineSegments/Line/Object3D member plus
 * releasable / release. Lua class tables have no inheritance, so the Object3D, LineSegments
 * (including Line) and IReleasable members are reused before b.install. Skipped: copy, an override
 * of Object3D.copy covered by the base binding via virtual dispatch.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.scene.objects.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 BoxHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.BoxHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BoxHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.BoxHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBoxHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.BoxHelper")
    // ===== 构造：可选 object + color（无 object 时走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            BoxHelper(prebindAs<Object3D>(args, 0), color: _prebindHlpHexArg(args, 1, default: 0xffff00))
        } else {
            BoxHelper()
        }
    }
    // ===== 继承成员：Object3D → Line → LineSegments → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpLineSegmentsMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 包围盒自有成员 =====
    b.property("object", getter: Some({
        ref => prebindRegister(ref.cast<BoxHelper>().object, "three.scene.objects.Object3D")
    }), setter: Some({
        ref, v => ref.cast<BoxHelper>().object = prebindAsValue<Object3D>(v)
    }))
    b.method("update") {
        ref, _ =>
            ref.cast<BoxHelper>().update()
            []
    }
    b.method("setFromObject") {
        ref, args =>
            ref.cast<BoxHelper>().setFromObject(prebindAs<Object3D>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
