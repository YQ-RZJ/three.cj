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
 * @file[zh-cn] renderers_geometry_buffergeometry 缓冲几何体的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.BufferGeometry 与 BufferGeometryGroup 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 BufferGeometry 的可映射成员：标识（id/uuid/name/kind）、索引与间接绘制
 * （getIndex/setIndex/getIndirect/setIndirect）、属性字典的方法接口（getAttribute/setAttribute/
 * hasAttribute/deleteAttribute）、绘制组（groups 只读对象数组 + addGroup/clearGroups）、绘制范围
 * （drawRange 以 [start, count] 数组读写）、包围盒/球（getter 返回注册对象，未计算时为 nil）、
 * 变换（applyMatrix4/applyQuaternion/rotateX/Y/Z/translate/scale/lookAt/center）与计算
 * （computeBoundingBox/computeBoundingSphere/computeTangents/computeVertexNormals/normalizeNormals）、
 * 克隆/复制/释放。返回自身的方法统一回传 self 句柄以支持链式调用。
 * 跳过成员及原因：
 * - attributes / morphAttributes / userData：HashMap 字段不直接暴露，属性访问走方法接口；
 * - getParameters()：返回 HashMap<String, Any>，任意值无法安全映射；
 * - getAttributeReader()：返回 IAttributeReader 接口，脚本侧统一改用 getAttribute；
 * - 各内置图元子类（BoxGeometry 等）由独立绑定文件负责。
 *
 * @file[en] renderers_geometry_buffergeometry  Lua binding of BufferGeometry (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.BufferGeometry and BufferGeometryGroup as Lua types
 * @explain[en] Binds the mappable members of BufferGeometry: identity (id/uuid/name/kind), index and
 * indirect draw (getIndex/setIndex/getIndirect/setIndirect), the method-based attribute dictionary
 * (getAttribute/setAttribute/hasAttribute/deleteAttribute), draw groups (read-only object array
 * groups plus addGroup/clearGroups), draw range (drawRange read/written as a [start, count] array),
 * bounding box/sphere (getters return registered objects, nil when not computed), transforms
 * (applyMatrix4/applyQuaternion/rotateX/Y/Z/translate/scale/lookAt/center) and computations
 * (computeBoundingBox/computeBoundingSphere/computeTangents/computeVertexNormals/normalizeNormals),
 * clone/copy/dispose. Methods returning the current instance return the self handle for chaining.
 * Skipped members and reasons:
 * - attributes / morphAttributes / userData: HashMap fields are not exposed directly; use the
 *   method-based attribute interface;
 * - getParameters(): returns HashMap<String, Any>, arbitrary values cannot be mapped safely;
 * - getAttributeReader(): returns the IAttributeReader interface, scripts use getAttribute instead;
 * - built-in primitive subclasses (BoxGeometry etc.) live in their own binding files.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.renderers.buffer.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将绘制组列表转为 Lua 数组（元素注册为 BufferGeometryGroup）
 * @param[zh-cn] items 绘制组列表
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a draw-group list into a Lua array (elements registered as BufferGeometryGroup)
 * @param[en] items The draw-group list
 * @return[en] The Lua array value
 */
internal func _prebindRgcGroupListToLua(items: ArrayList<BufferGeometryGroup>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.renderers.geometry.BufferGeometryGroup")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 将可选缓冲属性转为 Lua 值（Some 注册对象，None 返回 nil）
 *
 * @brief[en] Converts an optional buffer attribute into a Lua value (Some registers, None is nil)
 */
internal func _prebindRgcAttrToLua(attr: Option<BufferAttribute>): LuaValue {
    match (attr) {
        case Some(a) => prebindRegister(a, "three.renderers.buffer.BufferAttribute")
        case None => LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 安装 BufferGeometryGroup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.BufferGeometryGroup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BufferGeometryGroup
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.BufferGeometryGroup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBufferGeometryGroup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.BufferGeometryGroup")
    b.constructor {
        args => BufferGeometryGroup(prebindInt(args, 0), prebindInt(args, 1), materialIndex: prebindInt(args, 2))
    }
    b.property("start", getter: Some({ref => LuaValue.of(ref.cast<BufferGeometryGroup>().start)}),
        setter: Some({ref, v => ref.cast<BufferGeometryGroup>().start = v.intValue()}))
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<BufferGeometryGroup>().count)}),
        setter: Some({ref, v => ref.cast<BufferGeometryGroup>().count = v.intValue()}))
    b.property("materialIndex", getter: Some({ref => LuaValue.of(ref.cast<BufferGeometryGroup>().materialIndex)}),
        setter: Some({ref, v => ref.cast<BufferGeometryGroup>().materialIndex = v.intValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 BufferGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.BufferGeometry）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BufferGeometry
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.BufferGeometry)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBufferGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.BufferGeometry")
    // ===== 构造 =====
    b.constructor {_ => BufferGeometry()}
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 为绑定器安装 BufferGeometry 的成员（构造除外）
 * @explain[zh-cn] Lua 类表没有继承，所有 BufferGeometry 子类的绑定都必须在 b.install 之前调用本函数，
 * 否则子类实例只能看到自己新增的成员。所有回调按 BufferGeometry 强转后经虚函数分派。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Installs the BufferGeometry members (except the constructor) on a class binder
 * @explain[en] Lua class tables have no inheritance, so every BufferGeometry subclass binding must call
 * this before b.install; otherwise instances only expose their own extra members. Callbacks cast to
 * BufferGeometry and rely on virtual dispatch.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _prebindRgcBufferGeometryMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 标识 =====
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<BufferGeometry>().kind)}),
        setter: Some({ref, v => ref.cast<BufferGeometry>().kind = v.stringValue()}))
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<BufferGeometry>().uuid)}),
        setter: Some({ref, v => ref.cast<BufferGeometry>().uuid = v.stringValue()}))
    b.property("id", getter: Some({ref => LuaValue.of(ref.cast<BufferGeometry>().id)}))
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<BufferGeometry>().name)}),
        setter: Some({ref, v => ref.cast<BufferGeometry>().name = v.stringValue()}))
    // ===== 绘制范围 / 标志 =====
    b.property("indirectOffset", getter: Some({ref => LuaValue.of(ref.cast<BufferGeometry>().indirectOffset)}),
        setter: Some({ref, v => ref.cast<BufferGeometry>().indirectOffset = v.intValue()}))
    b.property("morphTargetsRelative",
        getter: Some({ref => LuaValue.of(ref.cast<BufferGeometry>().morphTargetsRelative)}),
        setter: Some({ref, v => ref.cast<BufferGeometry>().morphTargetsRelative = v.boolValue()}))
    b.property(
        "drawRange",
        getter: Some(
            {
                ref =>
                    let (start, count) = ref.cast<BufferGeometry>().drawRange
                    LuaValue.Array([LuaValue.of(start), LuaValue.of(count)])
            }
        ),
        setter: Some(
            {
                ref, v =>
                    let arr = prebindArray(vm, [v], 0)
                    if (arr.size >= 2) {
                        ref.cast<BufferGeometry>().drawRange = (arr[0].intValue(), arr[1].intValue())
                    }
            }
        )
    )
    // ===== 包围体 =====
    b.property("boundingBox", getter: Some({
        ref => match (ref.cast<BufferGeometry>().boundingBox) {
            case Some(box) => prebindRegister(box, "three.core.math.Box3")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isNil || !v.isObject) {
            ref.cast<BufferGeometry>().boundingBox = None
        } else {
            ref.cast<BufferGeometry>().boundingBox = Some(prebindAsValue<Box3>(v))
        }
    }))
    b.property("boundingSphere", getter: Some({
        ref => match (ref.cast<BufferGeometry>().boundingSphere) {
            case Some(sphere) => prebindRegister(sphere, "three.core.math.Sphere")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isNil || !v.isObject) {
            ref.cast<BufferGeometry>().boundingSphere = None
        } else {
            ref.cast<BufferGeometry>().boundingSphere = Some(prebindAsValue<Sphere>(v))
        }
    }))
    // ===== 绘制组（只读对象数组） =====
    b.property("groups", getter: Some({ref => _prebindRgcGroupListToLua(ref.cast<BufferGeometry>().groups)}))
    // ===== 索引 / 间接绘制 =====
    b.method("getIndex") {
        ref, _ => [_prebindRgcAttrToLua(ref.cast<BufferGeometry>().getIndex())]
    }
    b.method("setIndex") {
        ref, args =>
            ref.cast<BufferGeometry>().setIndex(prebindAs<BufferAttribute>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getIndirect") {
        ref, _ => [_prebindRgcAttrToLua(ref.cast<BufferGeometry>().getIndirect())]
    }
    b.method("setIndirect") {
        ref, args =>
            ref
                .cast<BufferGeometry>()
                .setIndirect(prebindAs<BufferAttribute>(args, 0), indirectOffset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 属性字典方法 =====
    b.method("getAttribute") {
        ref, args => [_prebindRgcAttrToLua(ref.cast<BufferGeometry>().getAttribute(prebindStr(args, 0)))]
    }
    b.method("setAttribute") {
        ref, args =>
            ref.cast<BufferGeometry>().setAttribute(prebindStr(args, 0), prebindAs<BufferAttribute>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("hasAttribute") {
        ref, args => [LuaValue.of(ref.cast<BufferGeometry>().hasAttribute(prebindStr(args, 0)))]
    }
    b.method("deleteAttribute") {
        ref, args =>
            ref.cast<BufferGeometry>().deleteAttribute(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 绘制组 / 范围 =====
    b.method("addGroup") {
        ref, args =>
            ref
                .cast<BufferGeometry>()
                .addGroup(prebindInt(args, 0), prebindInt(args, 1), materialIndex: prebindInt(args, 2))
            []
    }
    b.method("clearGroups") {
        ref, _ =>
            ref.cast<BufferGeometry>().clearGroups()
            []
    }
    b.method("setDrawRange") {
        ref, args =>
            ref.cast<BufferGeometry>().setDrawRange(prebindInt(args, 0), prebindInt(args, 1))
            []
    }
    // ===== 变换（返回自身） =====
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<BufferGeometry>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyQuaternion") {
        ref, args =>
            ref.cast<BufferGeometry>().applyQuaternion(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("rotateX") {
        ref, args =>
            ref.cast<BufferGeometry>().rotateX(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("rotateY") {
        ref, args =>
            ref.cast<BufferGeometry>().rotateY(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("rotateZ") {
        ref, args =>
            ref.cast<BufferGeometry>().rotateZ(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("translate") {
        ref, args =>
            ref.cast<BufferGeometry>().translate(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("scale") {
        ref, args =>
            ref.cast<BufferGeometry>().scale(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("lookAt") {
        ref, args =>
            ref.cast<BufferGeometry>().lookAt(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("center") {
        ref, _ =>
            ref.cast<BufferGeometry>().center()
            [LuaValue.Object(ref.id)]
    }
    // ===== 点集 / 计算 =====
    b.method("setFromPoints") {
        ref, args =>
            ref.cast<BufferGeometry>().setFromPoints(prebindObjList<Vector3>(vm, args, 0).toArray())
            [LuaValue.Object(ref.id)]
    }
    b.method("computeBoundingBox") {
        ref, _ =>
            ref.cast<BufferGeometry>().computeBoundingBox()
            []
    }
    b.method("computeBoundingSphere") {
        ref, _ =>
            ref.cast<BufferGeometry>().computeBoundingSphere()
            []
    }
    b.method("invalidateBounds") {
        ref, _ =>
            ref.cast<BufferGeometry>().invalidateBounds()
            []
    }
    b.method("computeTangents") {
        ref, _ =>
            ref.cast<BufferGeometry>().computeTangents()
            []
    }
    b.method("computeVertexNormals") {
        ref, _ =>
            ref.cast<BufferGeometry>().computeVertexNormals()
            []
    }
    b.method("normalizeNormals") {
        ref, _ =>
            ref.cast<BufferGeometry>().normalizeNormals()
            []
    }
    // ===== 包围体接口 =====
    b.method("getBoundingSphere") {
        ref, _ => match (ref.cast<BufferGeometry>().getBoundingSphere()) {
            case Some(sphere) => [prebindRegister(sphere, "three.core.math.Sphere")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getBoundingBox") {
        ref, _ => match (ref.cast<BufferGeometry>().getBoundingBox()) {
            case Some(box) => [prebindRegister(box, "three.core.math.Box3")]
            case None => [LuaValue.Nil]
        }
    }
    // ===== 克隆 / 复制 / 释放 =====
    b.method("toNonIndexed") {
        ref, _ => [prebindRegister(ref.cast<BufferGeometry>().toNonIndexed(), "three.renderers.geometry.BufferGeometry")]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<BufferGeometry>().clone(), "three.renderers.geometry.BufferGeometry")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<BufferGeometry>().copy(prebindAs<BufferGeometry>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<BufferGeometry>().dispose()
            []
    }
}
