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
 * @file[zh-cn] renderers_geometry_instancedbuffergeometry 实例化缓冲几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.InstancedBufferGeometry 绑定为 Lua 类型
 * three.renderers.geometry.InstancedBufferGeometry
 * @explain[zh-cn] 覆盖无参构造、属性 instanceCount（Float64，读写）与方法 copy(source)
 * （返回自身，支持链式）。继承自 BufferGeometry 的成员由 BufferGeometry 绑定提供，
 * 本文件不重复绑定。
 *
 * @file[en] renderers_geometry_instancedbuffergeometry  Lua binding of
 * InstancedBufferGeometry (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.InstancedBufferGeometry as the Lua type
 * three.renderers.geometry.InstancedBufferGeometry
 * @explain[en] Covers the no-arg constructor, the instanceCount property (Float64,
 * read-write) and the copy(source) method (returns self for chaining). Members inherited
 * from BufferGeometry are provided by the BufferGeometry binding and are not duplicated
 * here.
 */
package three.script.prebind

import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 InstancedBufferGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到
 * three.renderers.geometry.InstancedBufferGeometry）
 *
 * @brief[en] Installs the Lua binding of InstancedBufferGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.InstancedBufferGeometry)
 */
public func installInstancedBufferGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.InstancedBufferGeometry")
    // ===== 构造 =====
    b.constructor { _ => InstancedBufferGeometry() }
    // ===== 属性 =====
    b.property("instanceCount",
        getter: Some({ ref => LuaValue.of(ref.cast<InstancedBufferGeometry>().instanceCount) }),
        setter: Some({ ref, v =>
            ref.cast<InstancedBufferGeometry>().instanceCount = v.numberValue()
        }))
    // ===== 拷贝（返回自身） =====
    b.method("copy") { ref, args =>
        try {
            ref.cast<InstancedBufferGeometry>().copy(prebindAs<InstancedBufferGeometry>(args, 0))
            [LuaValue.Object(ref.id)]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
