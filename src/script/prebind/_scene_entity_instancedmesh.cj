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
 * @file[zh-cn] scene_entity_instancedmesh InstancedMesh 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.InstancedMesh 绑定为 Lua 类型
 * three.scene.entity.InstancedMesh
 * @explain[zh-cn] 绑定构造（可选 geometry/material/count）、属性（count/instanceMatrix/
 * instanceColor/morphTexture/boundingBox/boundingSphere）、setMatrixAt/getMatrixAt、
 * setColorAt/getColorAt、computeBoundingBox/computeBoundingSphere、setMorphAt/getMorphAt、
 * updateMorphTargets、raycast、copy、clone 与 release。
 * 绑定层适配：getMatrixAt(index, out) 改为只收 index、返回新 Matrix4；getColorAt(index, out)
 * 改为只收 index、返回新 Color；getMorphAt(index, out) 改为只收 index、按 morphTexture
 * 宽度推回读回并返回新数组；raycast 改为只收 raycaster、返回命中 Intersection 数组。
 * 跳过：无（实例数据均走公开缓冲/数组）。
 *
 * @file[en] scene_entity_instancedmesh  Lua binding of InstancedMesh (three.script.prebind)
 * @brief[en] Binds three.scene.entity.InstancedMesh as the Lua type
 * three.scene.entity.InstancedMesh
 * @explain[en] Binds construction (optional geometry/material/count), props (count/instanceMatrix/
 * instanceColor/morphTexture/boundingBox/boundingSphere), setMatrixAt/getMatrixAt,
 * setColorAt/getColorAt, computeBoundingBox/computeBoundingSphere, setMorphAt/getMorphAt,
 * updateMorphTargets, raycast, copy, clone and release.
 * Binding-layer adaptations: getMatrixAt(index, out) takes only index and returns a fresh
 * Matrix4; getColorAt(index, out) takes only index and returns a fresh Color; getMorphAt(index,
 * out) takes only index, sizes the result from the morphTexture width and returns a fresh array;
 * raycast takes only a raycaster and returns the hit Intersection array. Skipped: none.
 */
package three.script.prebind

import three.scene.entity.InstancedMesh
import three.scene.objects.*
import three.renderers.buffer.InstancedBufferAttribute
import three.renderers.geometry.BufferGeometry
import three.renderers.materials.Material
import three.renderers.textures.DataTexture
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
private func _prebindInstancedIntersectionsToLua(items: ArrayList<Intersection>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.scene.objects.Intersection")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 InstancedMesh 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.InstancedMesh）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of InstancedMesh
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.InstancedMesh)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installInstancedMesh(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.InstancedMesh")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3 && args[0].isObject && args[1].isObject) {
            InstancedMesh(geometry: prebindAs<BufferGeometry>(args, 0), material: prebindAs<Material>(args, 1),
                count: prebindInt(args, 2))
        } else if (args.size >= 2 && args[0].isObject && args[1].isObject) {
            InstancedMesh(geometry: prebindAs<BufferGeometry>(args, 0), material: prebindAs<Material>(args, 1))
        } else if (args.size >= 1 && args[0].isObject) {
            InstancedMesh(geometry: prebindAs<BufferGeometry>(args, 0))
        } else {
            InstancedMesh()
        }
    }
    // ===== 属性 =====
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<InstancedMesh>().count)}),
        setter: Some({ref, v => ref.cast<InstancedMesh>().count = v.intValue()}))
    b.property("instanceMatrix", getter: Some({
        ref => prebindRegister(ref.cast<InstancedMesh>().instanceMatrix,
            "three.renderers.buffer.InstancedBufferAttribute")
    }), setter: Some({
        ref, v => ref.cast<InstancedMesh>().instanceMatrix = prebindAsValue<InstancedBufferAttribute>(v)
    }))
    b.property("instanceColor", getter: Some({
        ref => match (ref.cast<InstancedMesh>().instanceColor) {
            case Some(attr) => prebindRegister(attr, "three.renderers.buffer.InstancedBufferAttribute")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<InstancedMesh>().instanceColor = Some(prebindAsValue<InstancedBufferAttribute>(v))
        } else {
            ref.cast<InstancedMesh>().instanceColor = None
        }
    }))
    b.property("morphTexture", getter: Some({
        ref => match (ref.cast<InstancedMesh>().morphTexture) {
            case Some(tex) => prebindRegister(tex, "three.renderers.textures.DataTexture")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<InstancedMesh>().morphTexture = Some(prebindAsValue<DataTexture>(v))
        } else {
            ref.cast<InstancedMesh>().morphTexture = None
        }
    }))
    b.property("boundingBox", getter: Some({
        ref => match (ref.cast<InstancedMesh>().boundingBox) {
            case Some(box) => prebindRegister(box, "three.core.math.Box3")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<InstancedMesh>().boundingBox = Some(prebindAsValue<Box3>(v))
        } else {
            ref.cast<InstancedMesh>().boundingBox = None
        }
    }))
    b.property("boundingSphere", getter: Some({
        ref => match (ref.cast<InstancedMesh>().boundingSphere) {
            case Some(sphere) => prebindRegister(sphere, "three.core.math.Sphere")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<InstancedMesh>().boundingSphere = Some(prebindAsValue<Sphere>(v))
        } else {
            ref.cast<InstancedMesh>().boundingSphere = None
        }
    }))
    // ===== 实例矩阵 =====
    b.method("setMatrixAt") {
        ref, args =>
            try {
                ref.cast<InstancedMesh>().setMatrixAt(prebindInt(args, 0), prebindAs<Matrix4>(args, 1))
            } catch (_) {
                ()
            }
            []
    }
    // 绑定层适配：out 参数改为返回新 Matrix4
    b.method("getMatrixAt") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let m = ref.cast<InstancedMesh>().getMatrixAt(prebindInt(args, 0), Matrix4())
                out = prebindRegister(m, "three.core.math.Matrix4")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 实例颜色 =====
    b.method("setColorAt") {
        ref, args =>
            try {
                ref.cast<InstancedMesh>().setColorAt(prebindInt(args, 0), prebindAs<Color>(args, 1))
            } catch (_) {
                ()
            }
            []
    }
    // 绑定层适配：out 参数改为返回新 Color
    b.method("getColorAt") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let c = ref.cast<InstancedMesh>().getColorAt(prebindInt(args, 0), Color())
                out = prebindRegister(c, "three.core.math.Color")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 包围体 =====
    b.method("computeBoundingBox") {
        ref, _ =>
            try {
                ref.cast<InstancedMesh>().computeBoundingBox()
            } catch (_) {
                ()
            }
            []
    }
    b.method("computeBoundingSphere") {
        ref, _ =>
            try {
                ref.cast<InstancedMesh>().computeBoundingSphere()
            } catch (_) {
                ()
            }
            []
    }
    // ===== morph target =====
    b.method("setMorphAt") {
        ref, args =>
            try {
                ref.cast<InstancedMesh>().setMorphAt(prebindInt(args, 0), prebindFloatArray(vm, args, 1))
            } catch (_) {
                ()
            }
            []
    }
    // 绑定层适配：out 参数改为按 morphTexture 宽度推回读回并返回新数组
    b.method("getMorphAt") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let im = ref.cast<InstancedMesh>()
                match (im.morphTexture) {
                    case Some(tex) =>
                        let len = tex.width - 1
                        if (len > 0) {
                            let influences = Array<Float64>(len, {_ => 0.0})
                            out = LuaValue.of(im.getMorphAt(prebindInt(args, 0), influences))
                        } else {
                            out = LuaValue.Array(Array<LuaValue>())
                        }
                    case None => out = LuaValue.Array(Array<LuaValue>())
                }
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.method("updateMorphTargets") {
        ref, _ =>
            try {
                ref.cast<InstancedMesh>().updateMorphTargets()
            } catch (_) {
                ()
            }
            []
    }
    // 绑定层适配：只收 raycaster，返回命中 Intersection 数组
    b.method("raycast") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let hits = ArrayList<Intersection>()
                ref.cast<InstancedMesh>().raycast(prebindAs<Raycaster>(args, 0), hits)
                out = _prebindInstancedIntersectionsToLua(hits)
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 复制/克隆/释放 =====
    b.method("copy") {
        ref, args =>
            try {
                ref.cast<InstancedMesh>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            } catch (_) {
                ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<InstancedMesh>().clone(), "three.scene.entity.InstancedMesh")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.method("release") {
        ref, _ =>
            var out = LuaValue.of(false)
            try {
                out = LuaValue.of(ref.cast<InstancedMesh>().release())
            } catch (_) {
                out = LuaValue.of(false)
            }
            [out]
    }
    b.install(vm)
}
