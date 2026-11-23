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
 * @file[zh-cn] scene_entity_points Points 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.Points 绑定为 Lua 类型 three.scene.entity.Points
 * @explain[zh-cn] 覆盖构造（geometry/material 均可选）、属性 geometry/material（读写）、
 * morphTargetInfluences（Float64 数组，读写）、updateMorphTargets、intersectsFrustum、
 * raycast、copy、clone。绑定层适配：raycast 的仓颉签名为调用方传入可变
 * ArrayList<Intersection>，此处改为「传入 raycaster、返回 Intersection 数组」；copy 返回自身；
 * clone 返回新 Points。跳过 morphTargetDictionary（HashMap<String, Int64> 键值表无法在绑定层
 * 无损读写）与 getCullingGeometry（返回 IGeometryProvider 接口实例）；异常经 try/catch
 * 吞掉后返回空数组/false/nil。
 *
 * @file[en] scene_entity_points  Lua binding of Points (three.script.prebind)
 * @brief[en] Binds three.scene.entity.Points as the Lua type three.scene.entity.Points
 * @explain[en] Covers construction (optional geometry/material), props geometry/material
 * (read-write), morphTargetInfluences (Float64 array, read-write), updateMorphTargets,
 * intersectsFrustum, raycast, copy, clone. Binding adaptations: raycast takes a caller-supplied
 * mutable ArrayList<Intersection> in Cangjie, so here it takes a raycaster and returns an
 * Intersection array; copy returns self; clone returns a new Points. morphTargetDictionary is
 * skipped (a HashMap<String, Int64> key/value table cannot be read/written losslessly here) and
 * getCullingGeometry is skipped (returns an IGeometryProvider interface instance); exceptions
 * are swallowed and yield an empty array / false / nil.
 */
package three.script.prebind

import three.scene.entity.*
import three.scene.objects.*
import three.renderers.geometry.*
import three.renderers.materials.*
import three.core.math.*
import std.collection.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Points 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.Points）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Points
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.Points)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPoints(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.Points")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2 && args[1].isObject) {
            Points(geometry: prebindAs<BufferGeometry>(args, 0), material: prebindAs<Material>(args, 1))
        } else if (args.size >= 1 && args[0].isObject) {
            Points(geometry: prebindAs<BufferGeometry>(args, 0))
        } else {
            Points()
        }
    }
    // ===== 属性 =====
    b.property("geometry", getter: Some({
        ref => prebindRegister(ref.cast<Points>().geometry, "three.renderers.geometry.BufferGeometry")
    }), setter: Some({
        ref, v => ref.cast<Points>().geometry = prebindAsValue<BufferGeometry>(v)
    }))
    b.property("material", getter: Some({
        ref => prebindRegister(ref.cast<Points>().material, "three.renderers.materials.Material")
    }), setter: Some({
        ref, v => ref.cast<Points>().material = prebindAsValue<Material>(v)
    }))
    b.property(
        "morphTargetInfluences",
        getter: Some(
            {
                ref =>
                    let src = ref.cast<Points>().morphTargetInfluences
                    let out = Array<LuaValue>(src.size, {i => LuaValue.of(src[i])})
                    LuaValue.of(out)
            }
        ),
        setter: Some({
            ref, v => ref.cast<Points>().morphTargetInfluences = prebindFloatArray(vm, [v], 0)
        })
    )
    // ===== morph target 刷新 =====
    b.method("updateMorphTargets") {
        ref, _ =>
            try {
                ref.cast<Points>().updateMorphTargets()
            } catch (_) {
                ()
            }
            []
    }
    // ===== 视锥 =====
    b.method("intersectsFrustum") {
        ref, args => [LuaValue.of(ref.cast<Points>().intersectsFrustum(prebindAs<Frustum>(args, 0)))]
    }
    // ===== 射线（绑定层：返回 Intersection 数组） =====
    b.method("raycast") {
        ref, args =>
            var out = Array<LuaValue>()
            try {
                let hits = ArrayList<Intersection>()
                ref.cast<Points>().raycast(prebindAs<Raycaster>(args, 0), hits)
                out = Array<LuaValue>(hits.size, {
                    i => prebindRegister(hits[i], "three.scene.objects.Intersection")
                })
            } catch (_) {
                out = Array<LuaValue>()
            }
            [LuaValue.of(out)]
    }
    // ===== 复制 / 克隆 =====
    b.method("copy") {
        ref, args =>
            ref.cast<Points>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Points>().clone(), "three.scene.entity.Points")]
    }
    b.install(vm)
}
