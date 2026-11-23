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
 * @file[zh-cn] scene_scenegraph_clippinggroup ClippingGroup 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.scenegraph.ClippingGroup 绑定为 Lua 类型
 * three.scene.scenegraph.ClippingGroup
 * @explain[zh-cn] 绑定构造、clippingPlanes（ArrayList<Plane>：getter 返回 Plane 的 Lua 数组，
 * setter 用 Lua 数组整体替换）、enabled/clipIntersection/clipShadows，以及 addObject/
 * removeObject，并通过 prebindInstallObject3DMembers 复用 Object3D 全部成员（含 children）。
 * 无跳过成员。
 *
 * @file[en] scene_scenegraph_clippinggroup  Lua binding of ClippingGroup (three.script.prebind)
 * @brief[en] Binds three.scene.scenegraph.ClippingGroup as the Lua type
 * three.scene.scenegraph.ClippingGroup
 * @explain[en] Binds the constructor, clippingPlanes (ArrayList<Plane>: the getter returns a Lua
 * array of Plane, the setter replaces the whole list from a Lua array), enabled/
 * clipIntersection/clipShadows, and addObject/removeObject; it also reuses every Object3D member
 * (including children) through prebindInstallObject3DMembers. No members are skipped.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.scene.objects.*
import three.scene.scenegraph.*
import three.script.vm.*
import three.script.binding.*

/// 裁剪平面列表转 Lua 数组（元素以 three.core.math.Plane 注册）
private func _prebindPlaneListToLua(items: ArrayList<Plane>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.core.math.Plane")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 ClippingGroup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.scenegraph.ClippingGroup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ClippingGroup
 * @param[en] vm The target virtual machine (class table installed at three.scene.scenegraph.ClippingGroup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installClippingGroup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.scenegraph.ClippingGroup")
    // ===== 构造 =====
    b.constructor {_ => ClippingGroup()}
    // ===== Object3D 继承成员 =====
    prebindInstallObject3DMembers(b, vm)
    // ===== 裁剪平面 =====
    b.property(
        "clippingPlanes",
        getter: Some({ref => _prebindPlaneListToLua(ref.cast<ClippingGroup>().clippingPlanes)}),
        setter: Some(
            {
                ref, v =>
                    let cg = ref.cast<ClippingGroup>()
                    cg.clippingPlanes.clear()
                    for (elem in prebindArray(vm, [v], 0)) {
                        if (elem.isObject) {
                            cg.clippingPlanes.add(LuaObjectRegistry.getAs<Plane>(elem.objectId()))
                        }
                    }
            }
        )
    )
    // ===== 开关 =====
    b.property("enabled", getter: Some({ref => LuaValue.of(ref.cast<ClippingGroup>().enabled)}),
        setter: Some({ref, v => ref.cast<ClippingGroup>().enabled = v.boolValue()}))
    b.property("clipIntersection", getter: Some({ref => LuaValue.of(ref.cast<ClippingGroup>().clipIntersection)}),
        setter: Some({ref, v => ref.cast<ClippingGroup>().clipIntersection = v.boolValue()}))
    b.property("clipShadows", getter: Some({ref => LuaValue.of(ref.cast<ClippingGroup>().clipShadows)}),
        setter: Some({ref, v => ref.cast<ClippingGroup>().clipShadows = v.boolValue()}))
    // ===== 子对象（视作裁剪平面） =====
    b.method("addObject") {
        ref, args =>
            ref.cast<ClippingGroup>().addObject(prebindAs<Object3D>(args, 0))
            []
    }
    b.method("removeObject") {
        ref, args =>
            ref.cast<ClippingGroup>().removeObject(prebindAs<Object3D>(args, 0))
            []
    }
    b.install(vm)
}
