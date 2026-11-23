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
 * @file[zh-cn] renderers_materials_meshbasicmaterial 网格基础材质 MeshBasicMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.MeshBasicMaterial 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 MeshBasicMaterial 独有的贴图与反射参数（map/lightMap/lightMapIntensity/
 * aoMap/aoMapIntensity/specularMap/alphaMap/combine/reflectivity/refractionRatio/
 * wireframeLinewidth），并在 b.install 之前复用 _prebindMatMaterialMembers 安装 Material 基类成员。
 * 贴图字段用 Option 表示，nil 即 None。
 * 跳过 copy(source: MeshBasicMaterial, recursive!)：与基类 copy 同名，统一由 Material 级 copy 覆盖。
 *
 * @file[en] renderers_materials_meshbasicmaterial  Lua binding of MeshBasicMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.MeshBasicMaterial as a Lua type
 * @explain[en] Binds the texture and reflection parameters specific to MeshBasicMaterial
 * (map/lightMap/lightMapIntensity/aoMap/aoMapIntensity/specularMap/alphaMap/combine/reflectivity/
 * refractionRatio/wireframeLinewidth) and reuses _prebindMatMaterialMembers to install the Material
 * base members before b.install. Texture fields use Option, where nil means None.
 * Skipped copy(source: MeshBasicMaterial, recursive!): it shares the Lua name with the base copy,
 * which the Material-level copy covers.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MeshBasicMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.MeshBasicMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MeshBasicMaterial
 * @param[en] vm The target virtual machine (class table at three.renderers.materials.MeshBasicMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMeshBasicMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.MeshBasicMaterial")
    b.constructor {_ => MeshBasicMaterial()}
    b.property("map", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshBasicMaterial>().map)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().map = _prebindMatTextureFromLua(v)}))
    b.property("lightMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshBasicMaterial>().lightMap)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().lightMap = _prebindMatTextureFromLua(v)}))
    b.property("lightMapIntensity", getter: Some({ref => LuaValue.of(ref.cast<MeshBasicMaterial>().lightMapIntensity)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().lightMapIntensity = v.numberValue()}))
    b.property("aoMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshBasicMaterial>().aoMap)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().aoMap = _prebindMatTextureFromLua(v)}))
    b.property("aoMapIntensity", getter: Some({ref => LuaValue.of(ref.cast<MeshBasicMaterial>().aoMapIntensity)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().aoMapIntensity = v.numberValue()}))
    b.property("specularMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshBasicMaterial>().specularMap)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().specularMap = _prebindMatTextureFromLua(v)}))
    b.property("alphaMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshBasicMaterial>().alphaMap)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().alphaMap = _prebindMatTextureFromLua(v)}))
    b.property("combine", getter: Some({ref => LuaValue.of(ref.cast<MeshBasicMaterial>().combine)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().combine = v.intValue()}))
    b.property("reflectivity", getter: Some({ref => LuaValue.of(ref.cast<MeshBasicMaterial>().reflectivity)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().reflectivity = v.numberValue()}))
    b.property("refractionRatio", getter: Some({ref => LuaValue.of(ref.cast<MeshBasicMaterial>().refractionRatio)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().refractionRatio = v.numberValue()}))
    b.property("wireframeLinewidth",
        getter: Some({ref => LuaValue.of(ref.cast<MeshBasicMaterial>().wireframeLinewidth)}),
        setter: Some({ref, v => ref.cast<MeshBasicMaterial>().wireframeLinewidth = v.numberValue()}))
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
