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
 * @file[zh-cn] renderers_materials_meshlambertmaterial Lambert材质 MeshLambertMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.MeshLambertMaterial 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 MeshLambertMaterial 的成员：emissive（Color 注册对象）/
 * emissiveIntensity/map/specularMap/emissiveMap/combine/reflectivity/refractionRatio，
 * 并在 b.install 之前复用 _prebindMatMaterialMembers 安装 Material 基类成员。
 *
 * @file[en] renderers_materials_meshlambertmaterial  Lua binding of MeshLambertMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.MeshLambertMaterial as a Lua type
 * @explain[en] Binds the members of MeshLambertMaterial: emissive (registered Color)/
 * emissiveIntensity/map/specularMap/emissiveMap/combine/reflectivity/refractionRatio, and reuses
 * _prebindMatMaterialMembers to install the Material base members before b.install.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MeshLambertMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.MeshLambertMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MeshLambertMaterial
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.MeshLambertMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMeshLambertMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.MeshLambertMaterial")
    b.constructor {_ => MeshLambertMaterial()}
    b.property("emissive", getter: Some({ref => _prebindMatColorToLua(ref.cast<MeshLambertMaterial>().emissive)}),
        setter: Some({
            ref, v => ref.cast<MeshLambertMaterial>().emissive = _prebindMatColorFromLua(v)
        }))
    b.property("emissiveIntensity",
        getter: Some({ref => LuaValue.of(ref.cast<MeshLambertMaterial>().emissiveIntensity)}),
        setter: Some({ref, v => ref.cast<MeshLambertMaterial>().emissiveIntensity = v.numberValue()}))
    b.property("map", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshLambertMaterial>().map)}),
        setter: Some({ref, v => ref.cast<MeshLambertMaterial>().map = _prebindMatTextureFromLua(v)}))
    b.property("specularMap",
        getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshLambertMaterial>().specularMap)}), setter: Some({
            ref, v => ref.cast<MeshLambertMaterial>().specularMap = _prebindMatTextureFromLua(v)
        }))
    b.property("emissiveMap",
        getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshLambertMaterial>().emissiveMap)}), setter: Some({
            ref, v => ref.cast<MeshLambertMaterial>().emissiveMap = _prebindMatTextureFromLua(v)
        }))
    b.property("combine", getter: Some({ref => LuaValue.of(ref.cast<MeshLambertMaterial>().combine)}),
        setter: Some({ref, v => ref.cast<MeshLambertMaterial>().combine = v.intValue()}))
    b.property("reflectivity", getter: Some({ref => LuaValue.of(ref.cast<MeshLambertMaterial>().reflectivity)}),
        setter: Some({ref, v => ref.cast<MeshLambertMaterial>().reflectivity = v.numberValue()}))
    b.property("refractionRatio", getter: Some({ref => LuaValue.of(ref.cast<MeshLambertMaterial>().refractionRatio)}),
        setter: Some({ref, v => ref.cast<MeshLambertMaterial>().refractionRatio = v.numberValue()}))
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
