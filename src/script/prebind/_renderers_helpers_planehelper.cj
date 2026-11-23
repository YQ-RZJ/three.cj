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
 * @file[zh-cn] renderers_helpers_planehelper PlaneHelper 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.PlaneHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 plane / size / hex：plane 为 Plane 对象时走带参构造，缺省走无参
 * 构造；hex 支持 Color 对象或十六进制数值）、属性（plane / size），以及继承自 Line/Object3D 的
 * 全部成员和 releasable / release。Lua 类表没有继承，本类绑定在 b.install 之前依次复用
 * Object3D、Line（含 LineSegments 语义）与 IReleasable 成员。跳过成员：updateMatrixWorld 仅重写
 * Object3D 实现，由基类绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_helpers_planehelper  Lua binding of PlaneHelper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.PlaneHelper as a Lua type
 * @explain[en] Binds the constructor (optional plane / size / hex: a Plane first argument selects
 * the parameterized overload, otherwise the no-arg one; hex accepts a Color object or a hex
 * number), the properties (plane / size), and every inherited Line/Object3D member plus releasable /
 * release. Lua class tables have no inheritance, so the Object3D, Line and IReleasable members are
 * reused before b.install. Skipped: updateMatrixWorld, an override of the Object3D implementation
 * covered by the base binding via virtual dispatch.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.scene.objects.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PlaneHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.PlaneHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PlaneHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.PlaneHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPlaneHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.PlaneHelper")
    // ===== 构造：可选 plane / size / hex（无 plane 时走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            PlaneHelper(prebindAs<Plane>(args, 0), size: prebindNum(args, 1, default: 1.0),
                hex: _prebindHlpHexArg(args, 2, default: 0xffff00))
        } else {
            PlaneHelper()
        }
    }
    // ===== 继承成员：Object3D → Line → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpLineMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 平面辅助自有成员 =====
    b.property("plane", getter: Some({
        ref => prebindRegister(ref.cast<PlaneHelper>().plane, "three.core.math.Plane")
    }), setter: Some({
        ref, v => ref.cast<PlaneHelper>().plane = prebindAsValue<Plane>(v)
    }))
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<PlaneHelper>().size)}),
        setter: Some({ref, v => ref.cast<PlaneHelper>().size = v.numberValue()}))
    b.install(vm)
}
