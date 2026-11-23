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
 * @file[zh-cn] scene_entity_mesh Mesh 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.Mesh 绑定为 Lua 类型 three.scene.entity.Mesh
 * @explain[zh-cn] 绑定构造（可选 geometry/material）、属性（geometry/material/
 * morphTargetInfluences/count）、updateMorphTargets、getVertexPosition、
 * intersectsFrustum、raycast、getPreciseVertexCount、getPreciseVertexPosition 与 copy。
 * 绑定层适配：getVertexPosition(index, target) 改为只收 index 并返回新 Vector3；
 * raycast(raycaster, intersects) 改为只收 raycaster 并返回命中 Intersection 数组。
 * 跳过：morphTargetDictionary（HashMap<String, Int64>，绑定层无映射通道）、
 * getCullingGeometry（返回接口实例 IGeometryProvider）。
 *
 * @file[en] scene_entity_mesh  Lua binding of Mesh (three.script.prebind)
 * @brief[en] Binds three.scene.entity.Mesh as the Lua type three.scene.entity.Mesh
 * @explain[en] Binds construction (optional geometry/material), props (geometry/material/
 * morphTargetInfluences/count), updateMorphTargets, getVertexPosition, intersectsFrustum,
 * raycast, getPreciseVertexCount, getPreciseVertexPosition and copy.
 * Binding-layer adaptations: getVertexPosition(index, target) takes only index and returns a
 * fresh Vector3; raycast(raycaster, intersects) takes only raycaster and returns an array of
 * hit Intersections. Skipped: morphTargetDictionary (HashMap<String, Int64>, no binding
 * channel) and getCullingGeometry (returns the interface instance IGeometryProvider).
 */
package three.script.prebind

import three.scene.entity.Mesh
import three.scene.objects.*
import three.renderers.geometry.BufferGeometry
import three.renderers.materials.Material
import three.core.math.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 将命中的 Intersection 列表转为 Lua 对象数组
 * @param[zh-cn] items 命中结果列表
 * @return[zh-cn] Lua 数组值（元素注册为 three.scene.objects.Intersection）
 *
 * @brief[en] Converts the hit Intersection list into a Lua object array
 * @param[en] items The hit result list
 * @return[en] Lua array value (elements registered as three.scene.objects.Intersection)
 */
private func _prebindMeshIntersectionsToLua(items: ArrayList<Intersection>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.scene.objects.Intersection")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 Mesh 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.Mesh）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Mesh
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.Mesh)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMesh(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.Mesh")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2 && args[0].isObject && args[1].isObject) {
            Mesh(geometry: prebindAs<BufferGeometry>(args, 0), material: prebindAs<Material>(args, 1))
        } else if (args.size >= 1 && args[0].isObject) {
            Mesh(geometry: prebindAs<BufferGeometry>(args, 0))
        } else {
            Mesh()
        }
    }
    // ===== 属性 =====
    b.property("geometry", getter: Some({
        ref => prebindRegister(ref.cast<Mesh>().geometry, "three.renderers.geometry.BufferGeometry")
    }), setter: Some({
        ref, v => ref.cast<Mesh>().geometry = prebindAsValue<BufferGeometry>(v)
    }))
    b.property("material", getter: Some({
        ref => prebindRegister(ref.cast<Mesh>().material, "three.renderers.materials.Material")
    }), setter: Some({
        ref, v => ref.cast<Mesh>().material = prebindAsValue<Material>(v)
    }))
    b.property("morphTargetInfluences", getter: Some({ref => LuaValue.of(ref.cast<Mesh>().morphTargetInfluences)}),
        setter: Some({
            ref, v => ref.cast<Mesh>().morphTargetInfluences = prebindFloatArray(vm, [v], 0)
        }))
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<Mesh>().count)}),
        setter: Some({ref, v => ref.cast<Mesh>().count = v.intValue()}))
    // ===== morph target =====
    b.method("updateMorphTargets") {
        ref, _ =>
            try {
                ref.cast<Mesh>().updateMorphTargets()
            } catch (_) {
                ()
            }
            []
    }
    // ===== 顶点（绑定层适配：只收 index，返回新 Vector3） =====
    b.method("getVertexPosition") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let v = ref.cast<Mesh>().getVertexPosition(prebindInt(args, 0), Vector3())
                out = prebindRegister(v, "three.core.math.Vector3")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 剔除/射线 =====
    b.method("intersectsFrustum") {
        ref, args =>
            var out = LuaValue.of(false)
            try {
                out = LuaValue.of(ref.cast<Mesh>().intersectsFrustum(prebindAs<Frustum>(args, 0)))
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // 绑定层适配：只收 raycaster，返回命中 Intersection 数组
    b.method("raycast") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let hits = ArrayList<Intersection>()
                ref.cast<Mesh>().raycast(prebindAs<Raycaster>(args, 0), hits)
                out = _prebindMeshIntersectionsToLua(hits)
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 精确模式顶点 =====
    b.method("getPreciseVertexCount") {
        ref, _ =>
            var out = LuaValue.of(Int64(0))
            try {
                out = LuaValue.of(ref.cast<Mesh>().getPreciseVertexCount())
            } catch (_) {
                out = LuaValue.of(Int64(0))
            }
            [out]
    }
    b.method("getPreciseVertexPosition") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                out = LuaValue.of(ref.cast<Mesh>().getPreciseVertexPosition(prebindInt(args, 0)))
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 复制 =====
    b.method("copy") {
        ref, args =>
            try {
                ref.cast<Mesh>().copy(prebindAs<Mesh>(args, 0), recursive: prebindBool(args, 1, default: true))
            } catch (_) {
                ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
