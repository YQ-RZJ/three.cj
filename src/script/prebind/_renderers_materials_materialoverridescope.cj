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
 * @file[zh-cn] renderers_materials_materialoverridescope 材质替换器栈 MaterialOverrideScope 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.MaterialOverrideScope 绑定为 Lua 类型
 * @explain[zh-cn] 该类以回调注入方式工作，只绑定可映射的构造与 restoreAll()。
 * 跳过成员及原因：
 * - pushOverride(mesh: IMesh, getter: () -> IMaterial, setter: (IMaterial) -> Unit)：
 *   形参包含接口类型与函数类型，Lua 侧无法构造 IMesh 与 IMaterial 回调，无可用通道。
 *
 * @file[en] renderers_materials_materialoverridescope  Lua binding of MaterialOverrideScope
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.MaterialOverrideScope as a Lua type
 * @explain[en] The class works by callback injection, so only the mappable constructor and
 * restoreAll() are bound.
 * Skipped members and reasons:
 * - pushOverride(mesh: IMesh, getter: () -> IMaterial, setter: (IMaterial) -> Unit): its parameters
 *   include an interface type and function types; Lua cannot construct IMesh or IMaterial callbacks,
 *   so no usable channel exists.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MaterialOverrideScope 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.MaterialOverrideScope）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MaterialOverrideScope
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.MaterialOverrideScope)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMaterialOverrideScope(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.MaterialOverrideScope")
    b.constructor {_ => MaterialOverrideScope()}
    b.method("restoreAll") {
        ref, _ =>
            ref.cast<MaterialOverrideScope>().restoreAll()
            []
    }
    b.install(vm)
}
