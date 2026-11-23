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
 * @file[zh-cn] scene_entity_skinnedmesh SkinnedMesh 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.SkinnedMesh 绑定为 Lua 类型
 * three.scene.entity.SkinnedMesh
 * @explain[zh-cn] 绑定构造（可选 geometry/material）、属性（skeleton/bindMode/bindMatrix/
 * bindMatrixInverse）、bind（可选 bindMatrix）、pose、normalizeSkinWeights、
 * updateMatrixWorld、computeBoundingBox、computeBoundingSphere、applyBoneTransform、
 * getVertexPosition、raycast、applySkinningJob、copy 与 clone。
 * 绑定层适配：applyBoneTransform / getVertexPosition 的 out 参数改为只收 index、
 * 返回新 Vector3；raycast 改为只收 raycaster、返回命中 Intersection 数组。
 * 跳过：无（私有蒙皮缓存字段不对外）。
 *
 * @file[en] scene_entity_skinnedmesh  Lua binding of SkinnedMesh (three.script.prebind)
 * @brief[en] Binds three.scene.entity.SkinnedMesh as the Lua type
 * three.scene.entity.SkinnedMesh
 * @explain[en] Binds construction (optional geometry/material), props (skeleton/bindMode/
 * bindMatrix/bindMatrixInverse), bind (optional bindMatrix), pose, normalizeSkinWeights,
 * updateMatrixWorld, computeBoundingBox, computeBoundingSphere, applyBoneTransform,
 * getVertexPosition, raycast, applySkinningJob, copy and clone.
 * Binding-layer adaptations: the out parameters of applyBoneTransform / getVertexPosition
 * become index-only methods returning a fresh Vector3; raycast takes only a raycaster and
 * returns the hit Intersection array. Skipped: none (private skinning caches stay internal).
 */
package three.script.prebind

import three.scene.entity.SkinnedMesh
import three.scene.entity.Skeleton
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
private func _prebindSkinnedIntersectionsToLua(items: ArrayList<Intersection>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.scene.objects.Intersection")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 SkinnedMesh 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.SkinnedMesh）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SkinnedMesh
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.SkinnedMesh)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSkinnedMesh(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.SkinnedMesh")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2 && args[0].isObject && args[1].isObject) {
            SkinnedMesh(geometry: prebindAs<BufferGeometry>(args, 0), material: prebindAs<Material>(args, 1))
        } else if (args.size >= 1 && args[0].isObject) {
            SkinnedMesh(geometry: prebindAs<BufferGeometry>(args, 0))
        } else {
            SkinnedMesh()
        }
    }
    // ===== 属性 =====
    b.property("skeleton", getter: Some({
        ref => prebindRegister(ref.cast<SkinnedMesh>().skeleton, "three.scene.entity.Skeleton")
    }), setter: Some({
        ref, v => ref.cast<SkinnedMesh>().skeleton = prebindAsValue<Skeleton>(v)
    }))
    b.property("bindMode", getter: Some({ref => LuaValue.of(ref.cast<SkinnedMesh>().bindMode)}),
        setter: Some({ref, v => ref.cast<SkinnedMesh>().bindMode = v.stringValue()}))
    b.property("bindMatrix", getter: Some({
        ref => prebindRegister(ref.cast<SkinnedMesh>().bindMatrix, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<SkinnedMesh>().bindMatrix = prebindAsValue<Matrix4>(v)
    }))
    b.property("bindMatrixInverse", getter: Some({
        ref => prebindRegister(ref.cast<SkinnedMesh>().bindMatrixInverse, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<SkinnedMesh>().bindMatrixInverse = prebindAsValue<Matrix4>(v)
    }))
    // ===== 绑定骨骼 =====
    b.method("bind") {
        ref, args =>
            try {
                let skel = prebindAs<Skeleton>(args, 0)
                if (args.size >= 2 && args[1].isObject) {
                    ref.cast<SkinnedMesh>().bind(skel, bindMatrix: Some(prebindAs<Matrix4>(args, 1)))
                } else {
                    ref.cast<SkinnedMesh>().bind(skel)
                }
            } catch (_) {
                ()
            }
            []
    }
    b.method("pose") {
        ref, _ =>
            try {
                ref.cast<SkinnedMesh>().pose()
            } catch (_) {
                ()
            }
            []
    }
    b.method("normalizeSkinWeights") {
        ref, _ =>
            try {
                ref.cast<SkinnedMesh>().normalizeSkinWeights()
            } catch (_) {
                ()
            }
            []
    }
    b.method("updateMatrixWorld") {
        ref, args =>
            try {
                ref.cast<SkinnedMesh>().updateMatrixWorld(prebindBool(args, 0))
            } catch (_) {
                ()
            }
            []
    }
    b.method("computeBoundingBox") {
        ref, _ =>
            try {
                ref.cast<SkinnedMesh>().computeBoundingBox()
            } catch (_) {
                ()
            }
            []
    }
    b.method("computeBoundingSphere") {
        ref, _ =>
            try {
                ref.cast<SkinnedMesh>().computeBoundingSphere()
            } catch (_) {
                ()
            }
            []
    }
    // ===== 顶点（绑定层适配：out 参数改为返回新 Vector3） =====
    b.method("applyBoneTransform") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let v = ref.cast<SkinnedMesh>().applyBoneTransform(prebindInt(args, 0), Vector3())
                out = prebindRegister(v, "three.core.math.Vector3")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.method("getVertexPosition") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let v = ref.cast<SkinnedMesh>().getVertexPosition(prebindInt(args, 0), Vector3())
                out = prebindRegister(v, "three.core.math.Vector3")
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
                ref.cast<SkinnedMesh>().raycast(prebindAs<Raycaster>(args, 0), hits)
                out = _prebindSkinnedIntersectionsToLua(hits)
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 批量蒙皮 =====
    b.method("applySkinningJob") {
        ref, _ =>
            try {
                ref.cast<SkinnedMesh>().applySkinningJob()
            } catch (_) {
                ()
            }
            []
    }
    // ===== 复制/克隆 =====
    b.method("copy") {
        ref, args =>
            try {
                ref.cast<SkinnedMesh>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            } catch (_) {
                ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<SkinnedMesh>().clone(), "three.scene.entity.SkinnedMesh")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.install(vm)
}
