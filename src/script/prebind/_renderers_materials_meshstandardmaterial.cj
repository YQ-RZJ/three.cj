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
 * @file[zh-cn] renderers_materials_meshstandardmaterial 标准PBR材质 MeshStandardMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.MeshStandardMaterial 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 MeshStandardMaterial 的金属度/粗糙度工作流成员：roughness/metalness、
 * 各类贴图（map/roughnessMap/metalnessMap/normalMap/aoMap/emissiveMap/lightMap/bumpMap/alphaMap）、
 * emissive/emissiveIntensity、aoMapIntensity/lightMapIntensity、normalScale（Vector2 注册对象）、
 * bumpScale/displacementScale/displacementBias，并在 b.install 之前复用
 * _prebindMatMaterialMembers 安装 Material 基类成员。
 *
 * @file[en] renderers_materials_meshstandardmaterial  Lua binding of MeshStandardMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.MeshStandardMaterial as a Lua type
 * @explain[en] Binds the metalness/roughness workflow members of MeshStandardMaterial: roughness/
 * metalness, texture maps (map/roughnessMap/metalnessMap/normalMap/aoMap/emissiveMap/lightMap/
 * bumpMap/alphaMap), emissive/emissiveIntensity, aoMapIntensity/lightMapIntensity, normalScale
 * (registered Vector2), bumpScale/displacementScale/displacementBias, and reuses
 * _prebindMatMaterialMembers to install the Material base members before b.install.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MeshStandardMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.MeshStandardMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MeshStandardMaterial
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.MeshStandardMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMeshStandardMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.MeshStandardMaterial")
    b.constructor {_ => MeshStandardMaterial()}
    b.property("roughness", getter: Some({ref => LuaValue.of(ref.cast<MeshStandardMaterial>().roughness)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().roughness = v.numberValue()}))
    b.property("metalness", getter: Some({ref => LuaValue.of(ref.cast<MeshStandardMaterial>().metalness)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().metalness = v.numberValue()}))
    b.property("map", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().map)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().map = _prebindMatTextureFromLua(v)}))
    b.property("roughnessMap",
        getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().roughnessMap)}), setter: Some({
            ref, v => ref.cast<MeshStandardMaterial>().roughnessMap = _prebindMatTextureFromLua(v)
        }))
    b.property("metalnessMap",
        getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().metalnessMap)}), setter: Some({
            ref, v => ref.cast<MeshStandardMaterial>().metalnessMap = _prebindMatTextureFromLua(v)
        }))
    b.property("normalMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().normalMap)}),
        setter: Some({
            ref, v => ref.cast<MeshStandardMaterial>().normalMap = _prebindMatTextureFromLua(v)
        }))
    b.property("aoMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().aoMap)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().aoMap = _prebindMatTextureFromLua(v)}))
    b.property("emissiveMap",
        getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().emissiveMap)}), setter: Some({
            ref, v => ref.cast<MeshStandardMaterial>().emissiveMap = _prebindMatTextureFromLua(v)
        }))
    b.property("lightMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().lightMap)}),
        setter: Some({
            ref, v => ref.cast<MeshStandardMaterial>().lightMap = _prebindMatTextureFromLua(v)
        }))
    b.property("bumpMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().bumpMap)}),
        setter: Some({
            ref, v => ref.cast<MeshStandardMaterial>().bumpMap = _prebindMatTextureFromLua(v)
        }))
    b.property("alphaMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshStandardMaterial>().alphaMap)}),
        setter: Some({
            ref, v => ref.cast<MeshStandardMaterial>().alphaMap = _prebindMatTextureFromLua(v)
        }))
    b.property("emissive", getter: Some({ref => _prebindMatColorToLua(ref.cast<MeshStandardMaterial>().emissive)}),
        setter: Some({
            ref, v => ref.cast<MeshStandardMaterial>().emissive = _prebindMatColorFromLua(v)
        }))
    b.property("emissiveIntensity",
        getter: Some({ref => LuaValue.of(ref.cast<MeshStandardMaterial>().emissiveIntensity)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().emissiveIntensity = v.numberValue()}))
    b.property("aoMapIntensity", getter: Some({ref => LuaValue.of(ref.cast<MeshStandardMaterial>().aoMapIntensity)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().aoMapIntensity = v.numberValue()}))
    b.property("lightMapIntensity",
        getter: Some({ref => LuaValue.of(ref.cast<MeshStandardMaterial>().lightMapIntensity)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().lightMapIntensity = v.numberValue()}))
    b.property("normalScale", getter: Some({
        ref => prebindRegister(ref.cast<MeshStandardMaterial>().normalScale, "three.core.math.Vector2")
    }), setter: Some({
        ref, v => ref.cast<MeshStandardMaterial>().normalScale = prebindAsValue<Vector2>(v)
    }))
    b.property("bumpScale", getter: Some({ref => LuaValue.of(ref.cast<MeshStandardMaterial>().bumpScale)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().bumpScale = v.numberValue()}))
    b.property("displacementScale",
        getter: Some({ref => LuaValue.of(ref.cast<MeshStandardMaterial>().displacementScale)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().displacementScale = v.numberValue()}))
    b.property("displacementBias", getter: Some({ref => LuaValue.of(ref.cast<MeshStandardMaterial>().displacementBias)}),
        setter: Some({ref, v => ref.cast<MeshStandardMaterial>().displacementBias = v.numberValue()}))
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
