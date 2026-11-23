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
 * @file[zh-cn] renderers_materials_meshmatcapmaterial Matcap材质 MeshMatcapMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.MeshMatcapMaterial 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 MeshMatcapMaterial 的成员：matcap/map/bumpMap/bumpScale/normalMap/
 * normalScale（Vector2 注册对象），并在 b.install 之前复用 _prebindMatMaterialMembers
 * 安装 Material 基类成员。
 *
 * @file[en] renderers_materials_meshmatcapmaterial  Lua binding of MeshMatcapMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.MeshMatcapMaterial as a Lua type
 * @explain[en] Binds the members of MeshMatcapMaterial: matcap/map/bumpMap/bumpScale/normalMap/
 * normalScale (registered Vector2), and reuses _prebindMatMaterialMembers to install the Material
 * base members before b.install.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MeshMatcapMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.MeshMatcapMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MeshMatcapMaterial
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.MeshMatcapMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMeshMatcapMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.MeshMatcapMaterial")
    b.constructor {_ => MeshMatcapMaterial()}
    b.property("matcap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshMatcapMaterial>().matcap)}),
        setter: Some({
            ref, v => ref.cast<MeshMatcapMaterial>().matcap = _prebindMatTextureFromLua(v)
        }))
    b.property("map", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshMatcapMaterial>().map)}),
        setter: Some({ref, v => ref.cast<MeshMatcapMaterial>().map = _prebindMatTextureFromLua(v)}))
    b.property("bumpMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshMatcapMaterial>().bumpMap)}),
        setter: Some({
            ref, v => ref.cast<MeshMatcapMaterial>().bumpMap = _prebindMatTextureFromLua(v)
        }))
    b.property("bumpScale", getter: Some({ref => LuaValue.of(ref.cast<MeshMatcapMaterial>().bumpScale)}),
        setter: Some({ref, v => ref.cast<MeshMatcapMaterial>().bumpScale = v.numberValue()}))
    b.property("normalMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshMatcapMaterial>().normalMap)}),
        setter: Some({
            ref, v => ref.cast<MeshMatcapMaterial>().normalMap = _prebindMatTextureFromLua(v)
        }))
    b.property("normalScale", getter: Some({
        ref => prebindRegister(ref.cast<MeshMatcapMaterial>().normalScale, "three.core.math.Vector2")
    }), setter: Some({
        ref, v => ref.cast<MeshMatcapMaterial>().normalScale = prebindAsValue<Vector2>(v)
    }))
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
