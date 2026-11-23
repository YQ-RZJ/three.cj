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
 * @file[zh-cn] scene_entity_batchedmesh BatchedMesh 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.BatchedMesh 绑定为 Lua 类型
 * three.scene.entity.BatchedMesh
 * @explain[zh-cn] 绑定构造（无参或 maxGeometryCount/maxVertexCount/maxIndexCount/可选 material）、
 * 只读计数属性（max 系列 / active 系列）、数组属性（instanceCount/vertexCount/indexCount/matrices/
 * boundingBox/boundingSphere/geometryVisible）、addGeometry、deleteGeometry、setMatrixAt、
 * getMatrixAt、setInstanceCount、getInstanceCount、setVisibleAt、getVisibleAt、
 * computeBoundingBoxAt、computeBoundingSphereAt、optimize、copy、clone 与 release。
 * 绑定层适配：getMatrixAt(geometryId, out) 改为只收 geometryId、返回新 Matrix4；
 * boundingBox/boundingSphere 为 Array<Option<...>>，只提供读（None → nil）。
 * 跳过：无参构造之外的私有字段 _geometryId，以及渲染器注入的 _matricesTexture /
 * _indirectTexture / _colorsTexture（下划线私有纹理，属渲染器内部状态）。
 *
 * @file[en] scene_entity_batchedmesh  Lua binding of BatchedMesh (three.script.prebind)
 * @brief[en] Binds three.scene.entity.BatchedMesh as the Lua type
 * three.scene.entity.BatchedMesh
 * @explain[en] Binds construction (no-arg or maxGeometryCount/maxVertexCount/maxIndexCount/
 * optional material), read-only counters (max series / active series), array props (instanceCount/vertexCount/
 * indexCount/matrices/boundingBox/boundingSphere/geometryVisible), addGeometry, deleteGeometry,
 * setMatrixAt, getMatrixAt, setInstanceCount, getInstanceCount, setVisibleAt, getVisibleAt,
 * computeBoundingBoxAt, computeBoundingSphereAt, optimize, copy, clone and release.
 * Binding-layer adaptation: getMatrixAt(geometryId, out) takes only geometryId and returns a
 * fresh Matrix4; boundingBox/boundingSphere are Array<Option<...>> and read-only (None → nil).
 * Skipped: the private _geometryId field and the renderer-injected underscore textures
 * (_matricesTexture / _indirectTexture / _colorsTexture), which are renderer-internal state.
 */
package three.script.prebind

import three.scene.entity.BatchedMesh
import three.scene.objects.Object3D
import three.renderers.geometry.BufferGeometry
import three.renderers.materials.Material
import three.core.math.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 将 Matrix4 数组转为 Lua 对象数组
 * @param[zh-cn] items 矩阵数组
 * @return[zh-cn] Lua 数组值（元素注册为 three.core.math.Matrix4）
 *
 * @brief[en] Converts the Matrix4 array into a Lua object array
 * @param[en] items The matrix array
 * @return[en] Lua array value (elements registered as three.core.math.Matrix4)
 */
private func _prebindBatchedMatricesToLua(items: Array<Matrix4>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.core.math.Matrix4")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 将布尔数组转为 Lua 布尔数组
 * @param[zh-cn] items 布尔数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts the Bool array into a Lua boolean array
 * @param[en] items The boolean array
 * @return[en] Lua array value
 */
private func _prebindBatchedBoolsToLua(items: Array<Bool>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(items[i])
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 读取 Lua 数组参数为 Bool 数组
 * @param[zh-cn] vm 目标虚拟机
 * @param[zh-cn] v 待读取的 Lua 值
 * @return[zh-cn] Bool 数组（非数组/表返回空）
 *
 * @brief[en] Reads a Lua array argument as a Bool array
 * @param[en] vm The target virtual machine
 * @param[en] v The Lua value to read
 * @return[en] Bool array (empty when not an array/table)
 */
private func _prebindBatchedBoolsFromLua(vm: LuaVM, v: LuaValue): Array<Bool> {
    let elems = prebindArray(vm, [v], 0)
    let n = elems.size
    var out = Array<Bool>(n, {_ => false})
    for (i in 0..n) {
        out[i] = elems[i].boolValue(default: false)
    }
    return out
}

/**
 * @brief[zh-cn] 将可选 Box3 数组转为 Lua 数组（None → nil）
 * @param[zh-cn] items 包围盒数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts the optional Box3 array into a Lua array (None → nil)
 * @param[en] items The bounding box array
 * @return[en] Lua array value
 */
private func _prebindBatchedBoxesToLua(items: Array<Option<Box3>>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = match (items[i]) {
            case Some(box) => prebindRegister(box, "three.core.math.Box3")
            case None => LuaValue.Nil
        }
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 将可选 Sphere 数组转为 Lua 数组（None → nil）
 * @param[zh-cn] items 包围球数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts the optional Sphere array into a Lua array (None → nil)
 * @param[en] items The bounding sphere array
 * @return[en] Lua array value
 */
private func _prebindBatchedSpheresToLua(items: Array<Option<Sphere>>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = match (items[i]) {
            case Some(sphere) => prebindRegister(sphere, "three.core.math.Sphere")
            case None => LuaValue.Nil
        }
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 BatchedMesh 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.BatchedMesh）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BatchedMesh
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.BatchedMesh)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBatchedMesh(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.BatchedMesh")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            if (args.size >= 4 && args[3].isObject) {
                BatchedMesh(prebindInt(args, 0), prebindInt(args, 1), prebindInt(args, 2),
                    material: prebindAs<Material>(args, 3))
            } else {
                BatchedMesh(prebindInt(args, 0), prebindInt(args, 1), prebindInt(args, 2))
            }
        } else {
            BatchedMesh()
        }
    }
    // ===== 只读计数 =====
    b.property("maxGeometryCount", getter: Some({ref => LuaValue.of(ref.cast<BatchedMesh>().maxGeometryCount)}))
    b.property("maxVertexCount", getter: Some({ref => LuaValue.of(ref.cast<BatchedMesh>().maxVertexCount)}))
    b.property("maxIndexCount", getter: Some({ref => LuaValue.of(ref.cast<BatchedMesh>().maxIndexCount)}))
    b.property("activeGeometryCount", getter: Some({ref => LuaValue.of(ref.cast<BatchedMesh>().activeGeometryCount)}))
    b.property("activeInstanceCount", getter: Some({ref => LuaValue.of(ref.cast<BatchedMesh>().activeInstanceCount)}))
    // ===== 数组属性 =====
    b.property("instanceCount", getter: Some({ref => LuaValue.of(ref.cast<BatchedMesh>().instanceCount)}),
        setter: Some({
            ref, v => ref.cast<BatchedMesh>().instanceCount = prebindI64List(vm, [v], 0).toArray()
        }))
    b.property("vertexCount", getter: Some({ref => LuaValue.of(ref.cast<BatchedMesh>().vertexCount)}), setter: Some({
        ref, v => ref.cast<BatchedMesh>().vertexCount = prebindI64List(vm, [v], 0).toArray()
    }))
    b.property("indexCount", getter: Some({ref => LuaValue.of(ref.cast<BatchedMesh>().indexCount)}), setter: Some({
        ref, v => ref.cast<BatchedMesh>().indexCount = prebindI64List(vm, [v], 0).toArray()
    }))
    b.property("matrices", getter: Some({ref => _prebindBatchedMatricesToLua(ref.cast<BatchedMesh>().matrices)}),
        setter: Some({
            ref, v => ref.cast<BatchedMesh>().matrices = prebindObjList<Matrix4>(vm, [v], 0).toArray()
        }))
    b.property("boundingBox", getter: Some({ref => _prebindBatchedBoxesToLua(ref.cast<BatchedMesh>().boundingBox)}))
    b.property("boundingSphere", getter: Some({
        ref => _prebindBatchedSpheresToLua(ref.cast<BatchedMesh>().boundingSphere)
    }))
    b.property("geometryVisible",
        getter: Some({ref => _prebindBatchedBoolsToLua(ref.cast<BatchedMesh>().geometryVisible)}), setter: Some({
            ref, v => ref.cast<BatchedMesh>().geometryVisible = _prebindBatchedBoolsFromLua(vm, v)
        }))
    // ===== 几何增删 =====
    b.method("addGeometry") {
        ref, args =>
            var out = LuaValue.of(Int64(-1))
            try {
                out = LuaValue.of(ref.cast<BatchedMesh>().addGeometry(prebindAs<BufferGeometry>(args, 0)))
            } catch (_) {
                out = LuaValue.of(Int64(-1))
            }
            [out]
    }
    b.method("deleteGeometry") {
        ref, args =>
            try {
                ref.cast<BatchedMesh>().deleteGeometry(prebindInt(args, 0))
            } catch (_) {
                ()
            }
            []
    }
    // ===== 矩阵 =====
    b.method("setMatrixAt") {
        ref, args =>
            try {
                ref.cast<BatchedMesh>().setMatrixAt(prebindInt(args, 0), prebindAs<Matrix4>(args, 1))
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
                let m = ref.cast<BatchedMesh>().getMatrixAt(prebindInt(args, 0), Matrix4())
                out = prebindRegister(m, "three.core.math.Matrix4")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 实例数量 =====
    b.method("setInstanceCount") {
        ref, args =>
            try {
                ref.cast<BatchedMesh>().setInstanceCount(prebindInt(args, 0), prebindInt(args, 1))
            } catch (_) {
                ()
            }
            []
    }
    b.method("getInstanceCount") {
        ref, args =>
            var out = LuaValue.of(Int64(0))
            try {
                out = LuaValue.of(ref.cast<BatchedMesh>().getInstanceCount(prebindInt(args, 0)))
            } catch (_) {
                out = LuaValue.of(Int64(0))
            }
            [out]
    }
    // ===== 可见性 =====
    b.method("setVisibleAt") {
        ref, args =>
            try {
                ref.cast<BatchedMesh>().setVisibleAt(prebindInt(args, 0), prebindBool(args, 1))
            } catch (_) {
                ()
            }
            []
    }
    b.method("getVisibleAt") {
        ref, args =>
            var out = LuaValue.of(false)
            try {
                out = LuaValue.of(ref.cast<BatchedMesh>().getVisibleAt(prebindInt(args, 0)))
            } catch (_) {
                out = LuaValue.of(false)
            }
            [out]
    }
    // ===== 包围体 =====
    b.method("computeBoundingBoxAt") {
        ref, args =>
            try {
                ref.cast<BatchedMesh>().computeBoundingBoxAt(prebindInt(args, 0))
            } catch (_) {
                ()
            }
            []
    }
    b.method("computeBoundingSphereAt") {
        ref, args =>
            try {
                ref.cast<BatchedMesh>().computeBoundingSphereAt(prebindInt(args, 0))
            } catch (_) {
                ()
            }
            []
    }
    b.method("optimize") {
        ref, _ =>
            try {
                ref.cast<BatchedMesh>().optimize()
            } catch (_) {
                ()
            }
            []
    }
    // ===== 复制/克隆/释放 =====
    b.method("copy") {
        ref, args =>
            try {
                ref.cast<BatchedMesh>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            } catch (_) {
                ()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<BatchedMesh>().clone(), "three.scene.entity.BatchedMesh")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.method("release") {
        ref, _ =>
            var out = LuaValue.of(false)
            try {
                out = LuaValue.of(ref.cast<BatchedMesh>().release())
            } catch (_) {
                out = LuaValue.of(false)
            }
            [out]
    }
    b.install(vm)
}
