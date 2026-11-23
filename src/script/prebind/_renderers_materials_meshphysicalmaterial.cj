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
 * @file[zh-cn] renderers_materials_meshphysicalmaterial 物理材质 MeshPhysicalMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.MeshPhysicalMaterial 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 MeshPhysicalMaterial 的高级PBR标量参数：roughness/metalness、clearcoat/
 * clearcoatRoughness、sheen、transmission、ior、thickness，并在 b.install 之前复用
 * _prebindMatMaterialMembers 安装 Material 基类成员。
 *
 * @file[en] renderers_materials_meshphysicalmaterial  Lua binding of MeshPhysicalMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.MeshPhysicalMaterial as a Lua type
 * @explain[en] Binds the advanced PBR scalar parameters of MeshPhysicalMaterial: roughness/metalness,
 * clearcoat/clearcoatRoughness, sheen, transmission, ior and thickness, and reuses
 * _prebindMatMaterialMembers to install the Material base members before b.install.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MeshPhysicalMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.MeshPhysicalMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MeshPhysicalMaterial
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.MeshPhysicalMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMeshPhysicalMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.MeshPhysicalMaterial")
    b.constructor {_ => MeshPhysicalMaterial()}
    b.property("roughness", getter: Some({ref => LuaValue.of(ref.cast<MeshPhysicalMaterial>().roughness)}),
        setter: Some({ref, v => ref.cast<MeshPhysicalMaterial>().roughness = v.numberValue()}))
    b.property("metalness", getter: Some({ref => LuaValue.of(ref.cast<MeshPhysicalMaterial>().metalness)}),
        setter: Some({ref, v => ref.cast<MeshPhysicalMaterial>().metalness = v.numberValue()}))
    b.property("clearcoat", getter: Some({ref => LuaValue.of(ref.cast<MeshPhysicalMaterial>().clearcoat)}),
        setter: Some({ref, v => ref.cast<MeshPhysicalMaterial>().clearcoat = v.numberValue()}))
    b.property("clearcoatRoughness",
        getter: Some({ref => LuaValue.of(ref.cast<MeshPhysicalMaterial>().clearcoatRoughness)}),
        setter: Some({ref, v => ref.cast<MeshPhysicalMaterial>().clearcoatRoughness = v.numberValue()}))
    b.property("sheen", getter: Some({ref => LuaValue.of(ref.cast<MeshPhysicalMaterial>().sheen)}),
        setter: Some({ref, v => ref.cast<MeshPhysicalMaterial>().sheen = v.numberValue()}))
    b.property("transmission", getter: Some({ref => LuaValue.of(ref.cast<MeshPhysicalMaterial>().transmission)}),
        setter: Some({ref, v => ref.cast<MeshPhysicalMaterial>().transmission = v.numberValue()}))
    b.property("ior", getter: Some({ref => LuaValue.of(ref.cast<MeshPhysicalMaterial>().ior)}),
        setter: Some({ref, v => ref.cast<MeshPhysicalMaterial>().ior = v.numberValue()}))
    b.property("thickness", getter: Some({ref => LuaValue.of(ref.cast<MeshPhysicalMaterial>().thickness)}),
        setter: Some({ref, v => ref.cast<MeshPhysicalMaterial>().thickness = v.numberValue()}))
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
