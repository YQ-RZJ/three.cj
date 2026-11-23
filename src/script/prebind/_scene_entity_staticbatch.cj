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
 * @file[zh-cn] scene_entity_staticbatch StaticBatcher 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.StaticBatcher 绑定为 Lua 类型
 * three.scene.entity.StaticBatch
 * @explain[zh-cn] StaticBatcher 为纯静态工具类（私有构造，Lua 侧不提供 .new；Lua 类型名
 * 沿用 resources/lua 约定的 StaticBatch）：
 * 绑定 process(root)（按材质与属性签名自动分组并合并，返回新 Mesh 数组）与
 * mergeMeshes(meshes)（合并给定网格列表，返回新 Mesh）。参数/返回值中的
 * Object3D / Mesh 走对象通道，数组走 Lua 数组。跳过：无（私有辅助方法 _collectCandidates /
 * _signature / _vertexCount 不对外）。
 *
 * @file[en] scene_entity_staticbatch  Lua binding of StaticBatcher (three.script.prebind)
 * @brief[en] Binds three.scene.entity.StaticBatcher as the Lua type
 * three.scene.entity.StaticBatch
 * @explain[en] StaticBatcher is a pure static utility (private constructor, no .new on the Lua
 * side; the Lua type name follows the resources/lua convention StaticBatch): binds process(root)
 * (auto-group/merge by material and attribute signature, returning
 * the new Mesh array) and mergeMeshes(meshes) (merge the given mesh list, returning a new Mesh).
 * Object3D / Mesh parameters and results go through the object channel; arrays use Lua arrays.
 * Skipped: none (private helpers _collectCandidates / _signature / _vertexCount stay internal).
 */
package three.script.prebind

import three.scene.entity.StaticBatcher
import three.scene.entity.Mesh
import three.scene.objects.Object3D
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 将 Mesh 列表转为 Lua 对象数组
 * @param[zh-cn] items 合并生成的新网格列表
 * @return[zh-cn] Lua 数组值（元素注册为 three.scene.entity.Mesh）
 *
 * @brief[en] Converts the Mesh list into a Lua object array
 * @param[en] items The newly merged mesh list
 * @return[en] Lua array value (elements registered as three.scene.entity.Mesh)
 */
private func _prebindStaticBatchMeshesToLua(items: ArrayList<Mesh>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.scene.entity.Mesh")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 StaticBatch 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.StaticBatch）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of StaticBatch
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.StaticBatch)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installStaticBatch(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.StaticBatch")
    // ===== 遍历合并 =====
    b.staticMethod("process") {
        args =>
            var out = LuaValue.Nil
            try {
                out = _prebindStaticBatchMeshesToLua(StaticBatcher.process(prebindAs<Object3D>(args, 0)))
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 指定网格合并 =====
    b.staticMethod("mergeMeshes") {
        args =>
            var out = LuaValue.Nil
            try {
                let meshes = prebindObjList<Mesh>(vm, args, 0)
                out = prebindRegister(StaticBatcher.mergeMeshes(meshes), "three.scene.entity.Mesh")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.install(vm)
}
