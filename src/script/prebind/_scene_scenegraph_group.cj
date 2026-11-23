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
 * @file[zh-cn] scene_scenegraph_group Group 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.scenegraph.Group 绑定为 Lua 类型 three.scene.scenegraph.Group
 * @explain[zh-cn] 绑定构造、materialLibraries（Array<String>：getter 返回 Lua 字符串数组，
 * setter 接受 Lua 数组/表），并通过 prebindInstallObject3DMembers 复用 Object3D 全部成员。
 * 无跳过成员；IGroup 为标记接口，按约定不绑定。
 *
 * @file[en] scene_scenegraph_group  Lua binding of Group (three.script.prebind)
 * @brief[en] Binds three.scene.scenegraph.Group as the Lua type three.scene.scenegraph.Group
 * @explain[en] Binds the constructor and materialLibraries (Array<String>: the getter returns a
 * Lua string array, the setter accepts a Lua array/table), and reuses every Object3D member
 * through prebindInstallObject3DMembers. No members are skipped; IGroup is a marker interface
 * and is intentionally not bound.
 */
package three.script.prebind

import three.scene.objects.*
import three.scene.scenegraph.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Group 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.scenegraph.Group）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Group
 * @param[en] vm The target virtual machine (class table installed at three.scene.scenegraph.Group)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGroup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.scenegraph.Group")
    // ===== 构造 =====
    b.constructor {_ => Group()}
    // ===== Object3D 继承成员 =====
    prebindInstallObject3DMembers(b, vm)
    // ===== 材质库路径 =====
    b.property(
        "materialLibraries",
        getter: Some({ref => LuaValue.of(ref.cast<Group>().materialLibraries)}),
        setter: Some(
            {
                ref, v =>
                    let elems = prebindArray(vm, [v], 0)
                    let n = elems.size
                    var out = Array<String>(n, {_ => ""})
                    for (i in 0..n) {
                        out[i] = elems[i].stringValue()
                    }
                    ref.cast<Group>().materialLibraries = out
            }
        )
    )
    b.install(vm)
}
