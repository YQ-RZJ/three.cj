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
 * @file[zh-cn] renderers_materials_meshdepthmaterial 网格深度材质 MeshDepthMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.MeshDepthMaterial 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 MeshDepthMaterial 的成员：depthPacking/map/alphaMap/displacementMap/
 * displacementScale/displacementBias/wireframeLinewidth，并在 b.install 之前复用
 * _prebindMatMaterialMembers 安装 Material 基类成员。
 * 跳过 copy(source: MeshDepthMaterial)：与基类 copy 同名，统一由 Material 级 copy 覆盖。
 *
 * @file[en] renderers_materials_meshdepthmaterial  Lua binding of MeshDepthMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.MeshDepthMaterial as a Lua type
 * @explain[en] Binds the members of MeshDepthMaterial: depthPacking/map/alphaMap/displacementMap/
 * displacementScale/displacementBias/wireframeLinewidth, and reuses _prebindMatMaterialMembers to
 * install the Material base members before b.install.
 * Skipped copy(source: MeshDepthMaterial): it shares the Lua name with the base copy, which the
 * Material-level copy covers.
 */
package three.script.prebind

import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MeshDepthMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.MeshDepthMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MeshDepthMaterial
 * @param[en] vm The target virtual machine (class table at three.renderers.materials.MeshDepthMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMeshDepthMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.MeshDepthMaterial")
    b.constructor {_ => MeshDepthMaterial()}
    b.property("depthPacking", getter: Some({ref => LuaValue.of(ref.cast<MeshDepthMaterial>().depthPacking)}),
        setter: Some({ref, v => ref.cast<MeshDepthMaterial>().depthPacking = v.intValue()}))
    b.property("map", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshDepthMaterial>().map)}),
        setter: Some({ref, v => ref.cast<MeshDepthMaterial>().map = _prebindMatTextureFromLua(v)}))
    b.property("alphaMap", getter: Some({ref => _prebindMatTextureToLua(ref.cast<MeshDepthMaterial>().alphaMap)}),
        setter: Some({
            ref, v => ref.cast<MeshDepthMaterial>().alphaMap = _prebindMatTextureFromLua(v)
        }))
    b.property("displacementMap", getter: Some({
        ref => _prebindMatTextureToLua(ref.cast<MeshDepthMaterial>().displacementMap)
    }), setter: Some({
        ref, v => ref.cast<MeshDepthMaterial>().displacementMap = _prebindMatTextureFromLua(v)
    }))
    b.property("displacementScale", getter: Some({ref => LuaValue.of(ref.cast<MeshDepthMaterial>().displacementScale)}),
        setter: Some({ref, v => ref.cast<MeshDepthMaterial>().displacementScale = v.numberValue()}))
    b.property("displacementBias", getter: Some({ref => LuaValue.of(ref.cast<MeshDepthMaterial>().displacementBias)}),
        setter: Some({ref, v => ref.cast<MeshDepthMaterial>().displacementBias = v.numberValue()}))
    b.property("wireframeLinewidth",
        getter: Some({ref => LuaValue.of(ref.cast<MeshDepthMaterial>().wireframeLinewidth)}),
        setter: Some({ref, v => ref.cast<MeshDepthMaterial>().wireframeLinewidth = v.numberValue()}))
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
