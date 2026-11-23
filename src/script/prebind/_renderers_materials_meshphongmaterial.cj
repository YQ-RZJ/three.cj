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
 * @file[zh-cn] renderers_materials_meshphongmaterial Phong材质 MeshPhongMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.MeshPhongMaterial 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 MeshPhongMaterial 的镜面高光成员：specular（Color 注册对象）/shininess/
 * specularMap/combine/reflectivity/refractionRatio，并在 b.install 之前复用
 * _prebindMatMaterialMembers 安装 Material 基类成员。
 *
 * @file[en] renderers_materials_meshphongmaterial  Lua binding of MeshPhongMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.MeshPhongMaterial as a Lua type
 * @explain[en] Binds the specular members of MeshPhongMaterial: specular (registered Color)/
 * shininess/specularMap/combine/reflectivity/refractionRatio, and reuses
 * _prebindMatMaterialMembers to install the Material base members before b.install.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MeshPhongMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.MeshPhongMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MeshPhongMaterial
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.MeshPhongMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMeshPhongMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.MeshPhongMaterial")
    b.constructor {_ => MeshPhongMaterial()}
    b.property("specular", getter: Some({ref => _prebindMatColorToLua(ref.cast<MeshPhongMaterial>().specular)}),
        setter: Some({
            ref, v => ref.cast<MeshPhongMaterial>().specular = _prebindMatColorFromLua(v)
        }))
    b.property("shininess", getter: Some({ref => LuaValue.of(ref.cast<MeshPhongMaterial>().shininess)}),
        setter: Some({ref, v => ref.cast<MeshPhongMaterial>().shininess = v.numberValue()}))
    b.property("specularMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshPhongMaterial>().specularMap)}),
        setter: Some({
            ref, v => ref.cast<MeshPhongMaterial>().specularMap = _prebindMatTextureFromLua(v)
        }))
    b.property("combine", getter: Some({ref => LuaValue.of(ref.cast<MeshPhongMaterial>().combine)}),
        setter: Some({ref, v => ref.cast<MeshPhongMaterial>().combine = v.intValue()}))
    b.property("reflectivity", getter: Some({ref => LuaValue.of(ref.cast<MeshPhongMaterial>().reflectivity)}),
        setter: Some({ref, v => ref.cast<MeshPhongMaterial>().reflectivity = v.numberValue()}))
    b.property("refractionRatio", getter: Some({ref => LuaValue.of(ref.cast<MeshPhongMaterial>().refractionRatio)}),
        setter: Some({ref, v => ref.cast<MeshPhongMaterial>().refractionRatio = v.numberValue()}))
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
