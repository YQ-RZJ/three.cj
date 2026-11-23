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
 * @file[zh-cn] renderers_helpers_skeletonhelper SkeletonHelper 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.SkeletonHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 object：首参为 Object3D 时走带参构造，缺省走无参构造）、属性
 * （root / bones）、方法 setColors（起止颜色，返回自身），以及继承自 LineSegments/Line/Object3D
 * 的全部成员和 releasable / release。bones 为 ArrayList<Bone>：getter 返回 Bone 对象数组，
 * setter 接受 Bone 对象数组。Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D、
 * LineSegments（含 Line）与 IReleasable 成员。跳过成员：updateMatrixWorld 仅重写 Object3D
 * 实现，由基类绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_helpers_skeletonhelper  Lua binding of SkeletonHelper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.SkeletonHelper as a Lua type
 * @explain[en] Binds the constructor (optional object: an Object3D first argument selects the
 * parameterized overload, otherwise the no-arg one), the properties (root / bones), setColors
 * (start/end colors, returns self), and every inherited LineSegments/Line/Object3D member plus
 * releasable / release. bones is ArrayList<Bone>: the getter returns a Bone object array and the
 * setter accepts one. Lua class tables have no inheritance, so the Object3D, LineSegments
 * (including Line) and IReleasable members are reused before b.install. Skipped:
 * updateMatrixWorld, an override of the Object3D implementation covered by the base binding via
 * virtual dispatch.
 */
package three.script.prebind

import std.collection.*
import three.renderers.helpers.*
import three.scene.objects.*
import three.scene.entity.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将骨骼列表转为 Lua 对象数组
 * @param[zh-cn] items 骨骼列表
 * @return[zh-cn] Lua 数组值（元素注册为 three.scene.entity.Bone）
 *
 * @brief[en] Converts a bone list into a Lua object array
 * @param[en] items The bone list
 * @return[en] Lua array value (elements registered as three.scene.entity.Bone)
 */
internal func _prebindHlpBoneListToLua(items: ArrayList<Bone>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.scene.entity.Bone")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 SkeletonHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.SkeletonHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SkeletonHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.SkeletonHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSkeletonHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.SkeletonHelper")
    // ===== 构造：可选 object（缺省走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            SkeletonHelper(prebindAs<Object3D>(args, 0))
        } else {
            SkeletonHelper()
        }
    }
    // ===== 继承成员：Object3D → Line → LineSegments → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpLineSegmentsMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 骨骼辅助自有成员 =====
    b.property("root", getter: Some({
        ref => prebindRegister(ref.cast<SkeletonHelper>().root, "three.scene.objects.Object3D")
    }), setter: Some({
        ref, v => ref.cast<SkeletonHelper>().root = prebindAsValue<Object3D>(v)
    }))
    b.property("bones", getter: Some({ref => _prebindHlpBoneListToLua(ref.cast<SkeletonHelper>().bones)}),
        setter: Some({
            ref, v => ref.cast<SkeletonHelper>().bones = prebindObjList<Bone>(vm, [v], 0)
        }))
    b.method("setColors") {
        ref, args =>
            ref
                .cast<SkeletonHelper>()
                .setColors(_prebindHlpColorArg(args, 0, default: Color(0x0000ff)),
                    _prebindHlpColorArg(args, 1, default: Color(0x00ff00)))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
