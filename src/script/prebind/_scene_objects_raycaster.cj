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
 * @file[zh-cn] scene_objects_raycaster 射线投射相关类型的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.objects.Intersection / Face / RaycasterParams / Raycaster
 * 绑定为同名 Lua 类型
 * @explain[zh-cn] Intersection 绑定构造（distance/point）与全部 public 字段（obj/uv/uv1/
 * normal/barycoord/face 为可空对象：有值注册、无值 nil）；Face 绑定构造与 a/b/c/normal/
 * materialIndex；RaycasterParams 绑定 lineThreshold/pointsThreshold；Raycaster 绑定构造
 * （origin/direction/near/far 四个具名参数，缺省取引擎默认值）、ray/near/far/camera/layers/
 * params 属性、set/setFromCamera 与 intersectObject/intersectObjects。射线求交可能因对象
 * raycast 内部类型转换/矩阵求逆抛异常，两个求交方法均 try/catch，失败返回 nil；求交结果
 * 以 Intersection 列表返回（按距离升序，排序由引擎完成）。无跳过成员。
 *
 * @file[en] scene_objects_raycaster  Lua binding of the raycasting types (three.script.prebind)
 * @brief[en] Binds three.scene.objects.Intersection / Face / RaycasterParams / Raycaster as
 * Lua types of the same names
 * @explain[en] Intersection binds its constructor (distance/point) and all public fields
 * (obj/uv/uv1/normal/barycoord/face are nullable objects: registered when present, nil
 * otherwise); Face binds its constructor and a/b/c/normal/materialIndex; RaycasterParams binds
 * lineThreshold/pointsThreshold; Raycaster binds its constructor (four named parameters
 * origin/direction/near/far, engine defaults when omitted), the ray/near/far/camera/layers/
 * params properties and set/setFromCamera plus intersectObject/intersectObjects. Ray
 * intersection can throw from an object's raycast (type conversion / matrix inversion), so both
 * intersection methods are try/catch and return nil on failure; hits come back as a list of
 * Intersection values ordered by distance (the engine sorts them). No members are skipped.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.scene.objects.*
import three.script.vm.*
import three.script.binding.*

/// 相交结果列表转 Lua 数组（元素以 three.scene.objects.Intersection 注册）
private func _prebindIntersectionsToLua(hits: ArrayList<Intersection>): LuaValue {
    let n = hits.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(hits[i], "three.scene.objects.Intersection")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 Intersection 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.objects.Intersection）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Intersection
 * @param[en] vm The target virtual machine (class table installed at three.scene.objects.Intersection)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installIntersection(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.objects.Intersection")
    // ===== 构造 =====
    b.constructor {
        args => Intersection(distance: prebindNum(args, 0), point: prebindVec3(args, 1))
    }
    // ===== 基本字段 =====
    b.property("distance", getter: Some({ref => LuaValue.of(ref.cast<Intersection>().distance)}),
        setter: Some({ref, v => ref.cast<Intersection>().distance = v.numberValue()}))
    b.property("point", getter: Some({ref => prebindRegister(ref.cast<Intersection>().point, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Intersection>().point = prebindAsValue<Vector3>(v)}))
    b.property("faceIndex", getter: Some({ref => LuaValue.of(ref.cast<Intersection>().faceIndex)}),
        setter: Some({ref, v => ref.cast<Intersection>().faceIndex = v.intValue()}))
    b.property("instanceId", getter: Some({ref => LuaValue.of(ref.cast<Intersection>().instanceId)}),
        setter: Some({ref, v => ref.cast<Intersection>().instanceId = v.intValue()}))
    b.property("index", getter: Some({ref => LuaValue.of(ref.cast<Intersection>().index)}),
        setter: Some({ref, v => ref.cast<Intersection>().index = v.intValue()}))
    b.property("distanceToRay", getter: Some({ref => LuaValue.of(ref.cast<Intersection>().distanceToRay)}),
        setter: Some({ref, v => ref.cast<Intersection>().distanceToRay = v.numberValue()}))
    // ===== 可空对象字段 =====
    b.property("obj", getter: Some({
        ref => match (ref.cast<Intersection>().obj) {
            case Some(o) => prebindRegister(o, "three.scene.objects.Object3D")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Intersection>().obj = Some(LuaObjectRegistry.getAs<Object3D>(v.objectId()))
        } else {
            ref.cast<Intersection>().obj = None
        }
    }))
    b.property("uv", getter: Some({
        ref => match (ref.cast<Intersection>().uv) {
            case Some(o) => prebindRegister(o, "three.core.math.Vector2")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Intersection>().uv = Some(LuaObjectRegistry.getAs<Vector2>(v.objectId()))
        } else {
            ref.cast<Intersection>().uv = None
        }
    }))
    b.property("uv1", getter: Some({
        ref => match (ref.cast<Intersection>().uv1) {
            case Some(o) => prebindRegister(o, "three.core.math.Vector2")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Intersection>().uv1 = Some(LuaObjectRegistry.getAs<Vector2>(v.objectId()))
        } else {
            ref.cast<Intersection>().uv1 = None
        }
    }))
    b.property("normal", getter: Some({
        ref => match (ref.cast<Intersection>().normal) {
            case Some(o) => prebindRegister(o, "three.core.math.Vector3")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Intersection>().normal = Some(LuaObjectRegistry.getAs<Vector3>(v.objectId()))
        } else {
            ref.cast<Intersection>().normal = None
        }
    }))
    b.property("barycoord", getter: Some({
        ref => match (ref.cast<Intersection>().barycoord) {
            case Some(o) => prebindRegister(o, "three.core.math.Vector3")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Intersection>().barycoord = Some(LuaObjectRegistry.getAs<Vector3>(v.objectId()))
        } else {
            ref.cast<Intersection>().barycoord = None
        }
    }))
    b.property("face", getter: Some({
        ref => match (ref.cast<Intersection>().face) {
            case Some(o) => prebindRegister(o, "three.scene.objects.Face")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Intersection>().face = Some(LuaObjectRegistry.getAs<Face>(v.objectId()))
        } else {
            ref.cast<Intersection>().face = None
        }
    }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Face 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.objects.Face）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Face
 * @param[en] vm The target virtual machine (class table installed at three.scene.objects.Face)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFace(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.objects.Face")
    // ===== 构造 =====
    b.constructor {
        args => Face(a: prebindInt(args, 0, default: -1), b: prebindInt(args, 1, default: -1),
            c: prebindInt(args, 2, default: -1), normal: prebindVec3(args, 3), materialIndex: prebindInt(args, 4))
    }
    // ===== 顶点索引 =====
    b.property("a", getter: Some({ref => LuaValue.of(ref.cast<Face>().a)}),
        setter: Some({ref, v => ref.cast<Face>().a = v.intValue()}))
    b.property("b", getter: Some({ref => LuaValue.of(ref.cast<Face>().b)}),
        setter: Some({ref, v => ref.cast<Face>().b = v.intValue()}))
    b.property("c", getter: Some({ref => LuaValue.of(ref.cast<Face>().c)}),
        setter: Some({ref, v => ref.cast<Face>().c = v.intValue()}))
    b.property("normal", getter: Some({ref => prebindRegister(ref.cast<Face>().normal, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Face>().normal = prebindAsValue<Vector3>(v)}))
    b.property("materialIndex", getter: Some({ref => LuaValue.of(ref.cast<Face>().materialIndex)}),
        setter: Some({ref, v => ref.cast<Face>().materialIndex = v.intValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RaycasterParams 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.objects.RaycasterParams）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RaycasterParams
 * @param[en] vm The target virtual machine (class table installed at three.scene.objects.RaycasterParams)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRaycasterParams(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.objects.RaycasterParams")
    b.constructor {_ => RaycasterParams()}
    b.property("lineThreshold", getter: Some({ref => LuaValue.of(ref.cast<RaycasterParams>().lineThreshold)}),
        setter: Some({ref, v => ref.cast<RaycasterParams>().lineThreshold = v.numberValue()}))
    b.property("pointsThreshold", getter: Some({ref => LuaValue.of(ref.cast<RaycasterParams>().pointsThreshold)}),
        setter: Some({ref, v => ref.cast<RaycasterParams>().pointsThreshold = v.numberValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Raycaster 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.objects.Raycaster）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Raycaster
 * @param[en] vm The target virtual machine (class table installed at three.scene.objects.Raycaster)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRaycaster(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.objects.Raycaster")
    // ===== 构造（origin/direction/near/far，缺省取引擎默认值） =====
    b.constructor {
        args => Raycaster(origin: prebindVec3(args, 0), direction: prebindVec3(args, 1, default: Vector3(0.0, 0.0, 1.0)),
            near: prebindNum(args, 2), far: prebindNum(args, 3, default: Float64.Inf))
    }
    // ===== 属性 =====
    b.property("ray", getter: Some({ref => prebindRegister(ref.cast<Raycaster>().ray, "three.core.math.Ray")}),
        setter: Some({ref, v => ref.cast<Raycaster>().ray = prebindAsValue<Ray>(v)}))
    b.property("near", getter: Some({ref => LuaValue.of(ref.cast<Raycaster>().near)}),
        setter: Some({ref, v => ref.cast<Raycaster>().near = v.numberValue()}))
    b.property("far", getter: Some({ref => LuaValue.of(ref.cast<Raycaster>().far)}),
        setter: Some({ref, v => ref.cast<Raycaster>().far = v.numberValue()}))
    b.property("camera", getter: Some({
        ref => match (ref.cast<Raycaster>().camera) {
            case Some(c) => prebindRegister(c, "three.scene.objects.Object3D")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Raycaster>().camera = Some(LuaObjectRegistry.getAs<Object3D>(v.objectId()))
        } else {
            ref.cast<Raycaster>().camera = None
        }
    }))
    b.property("layers",
        getter: Some({ref => prebindRegister(ref.cast<Raycaster>().layers, "three.scene.objects.Layers")}),
        setter: Some({ref, v => ref.cast<Raycaster>().layers = prebindAsValue<Layers>(v)}))
    b.property("params",
        getter: Some({ref => prebindRegister(ref.cast<Raycaster>().params, "three.scene.objects.RaycasterParams")}),
        setter: Some({ref, v => ref.cast<Raycaster>().params = prebindAsValue<RaycasterParams>(v)}))
    // ===== 射线设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Raycaster>().set(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            []
    }
    b.method("setFromCamera") {
        ref, args =>
            try {
                ref.cast<Raycaster>().setFromCamera(prebindAs<Vector2>(args, 0), prebindAs<Object3D>(args, 1))
            } catch (_: Exception) {
                ()
            }
            []
    }
    // ===== 求交 =====
    b.method("intersectObject") {
        ref, args => try {
            let hits = ref
                .cast<Raycaster>()
                .intersectObject(prebindAs<Object3D>(args, 0), recursive: prebindBool(args, 1, default: true))
            [_prebindIntersectionsToLua(hits)]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.method("intersectObjects") {
        ref, args => try {
            let list = prebindObjList<Object3D>(vm, args, 0)
            let objs = Array<Object3D>(list.size, {i => list[i]})
            let hits = ref.cast<Raycaster>().intersectObjects(objs, recursive: prebindBool(args, 1, default: true))
            [_prebindIntersectionsToLua(hits)]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.install(vm)
}
