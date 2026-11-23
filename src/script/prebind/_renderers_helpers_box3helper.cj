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
 * @file[zh-cn] renderers_helpers_box3helper Box3Helper 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.Box3Helper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 box 与 color：首参为 Box3 对象时走带参构造，缺省走无参构造）、
 * 属性 box（Box3）以及继承自 LineSegments/Line/Object3D 的全部成员和 releasable / release。
 * Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D、LineSegments（含 Line）与
 * IReleasable 成员。跳过成员：updateMatrixWorld 仅重写 Object3D 实现，由基类绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_helpers_box3helper  Lua binding of Box3Helper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.Box3Helper as a Lua type
 * @explain[en] Binds the constructor (optional box and color: a Box3 first argument selects the
 * parameterized overload, otherwise the no-arg one), the box property, and every inherited
 * LineSegments/Line/Object3D member plus releasable / release. Lua class tables have no
 * inheritance, so the Object3D, LineSegments (including Line) and IReleasable members are reused
 * before b.install. Skipped: updateMatrixWorld, an override of the Object3D implementation covered
 * by the base binding via virtual dispatch.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.scene.objects.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Box3Helper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.Box3Helper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Box3Helper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.Box3Helper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBox3Helper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.Box3Helper")
    // ===== 构造：可选 box + color（无 box 时走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            Box3Helper(prebindAs<Box3>(args, 0), color: _prebindHlpHexArg(args, 1, default: 0xffff00))
        } else {
            Box3Helper()
        }
    }
    // ===== 继承成员：Object3D → Line → LineSegments → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpLineSegmentsMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 包围盒自有成员 =====
    b.property("box", getter: Some({
        ref => prebindRegister(ref.cast<Box3Helper>().box, "three.core.math.Box3")
    }), setter: Some({
        ref, v => ref.cast<Box3Helper>().box = prebindAsValue<Box3>(v)
    }))
    b.install(vm)
}
