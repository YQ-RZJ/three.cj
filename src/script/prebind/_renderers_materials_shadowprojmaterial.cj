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
 * @file[zh-cn] renderers_materials_shadowprojmaterial 阴影投影UV可视化材质 ShadowProjMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.ShadowProjMaterial 绑定为 Lua 类型
 * @explain[zh-cn] ShadowProjMaterial 没有独有 public 字段，只声明构造并复用
 * _prebindMatMaterialMembers 安装 Material 基类成员。
 * 跳过 copy(source: ShadowProjMaterial)：与基类 copy 同名，统一由 Material 级 copy 覆盖。
 *
 * @file[en] renderers_materials_shadowprojmaterial  Lua binding of ShadowProjMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.ShadowProjMaterial as a Lua type
 * @explain[en] ShadowProjMaterial declares no own public fields; the binding only provides the
 * constructor and reuses _prebindMatMaterialMembers for the Material base members.
 * Skipped copy(source: ShadowProjMaterial): it shares the Lua name with the base copy, which the
 * Material-level copy covers.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ShadowProjMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.ShadowProjMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ShadowProjMaterial
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.ShadowProjMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installShadowProjMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.ShadowProjMaterial")
    b.constructor {_ => ShadowProjMaterial()}
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
