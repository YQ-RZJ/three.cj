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
 * @file[zh-cn] renderers_helpers_helper 辅助对象族的共享绑定工具（three.script.prebind）
 * @brief[zh-cn] 提供 helpers 包各绑定文件共用的颜色参数转换与继承链成员安装函数
 * @explain[zh-cn] three.renderers.helpers 包没有独立的 Helper 基类（Helper.cj 只是包导出
 * 文件），因此本文件不注册类表，只提供内部辅助函数：
 * - 颜色：Color 对象往返、可选颜色参数、十六进制数值参数；
 * - _prebindHlpHelperMembers：所有辅助对象都实现 IReleasable，统一绑定 releasable / release；
 * - _prebindHlpLineMembers / _prebindHlpLineSegmentsMembers / _prebindHlpMeshMembers：
 *   LineSegments、Line、Mesh 子类的辅助对象在 b.install 前逐层复用这些成员。
 * Lua 类表没有继承，基类成员必须在子类绑定器上重新登记；回调按基类强转后经虚函数分派，
 * 子类覆写（如 LineSegments.computeLineDistances、Box3Helper.updateMatrixWorld）自动生效。
 * 跳过成员：getCullingGeometry（返回 IGeometryProvider 接口实例，Lua 侧无法表达）；
 * raycast 的仓颉签名为调用方传入可变 ArrayList<Intersection>，绑定层改为传入 raycaster 并返回数组。
 *
 * @file[en] renderers_helpers_helper  Shared binding helpers for the helper family
 * (three.script.prebind)
 * @brief[en] Shared color conversions and inherited-member installers for the helpers bindings
 * @explain[en] The three.renderers.helpers package has no standalone Helper base class (Helper.cj is
 * just the package export file), so this file registers no class table and only provides internal
 * helpers:
 * - colors: Color object round-trip, optional color arguments and hex numeric arguments;
 * - _prebindHlpHelperMembers: every helper implements IReleasable, so releasable / release are bound
 *   uniformly;
 * - _prebindHlpLineMembers / _prebindHlpLineSegmentsMembers / _prebindHlpMeshMembers: re-expose
 *   the base-class members of LineSegments, Line and Mesh before b.install.
 * Lua class tables have no inheritance, so base members must be re-registered on each subclass
 * binder; callbacks cast to the base class and rely on virtual dispatch, so overrides such as
 * LineSegments.computeLineDistances and Box3Helper.updateMatrixWorld apply automatically.
 * Skipped: getCullingGeometry (returns the interface instance IGeometryProvider, not expressible in
 * Lua); Cangjie raycast takes a caller-supplied ArrayList<Intersection>, so the binding takes only a
 * raycaster and returns an array.
 */
package three.script.prebind

import std.collection.*
import three.utils.safe.IReleasable
import three.core.math.*
import three.scene.objects.*
import three.scene.entity.*
import three.renderers.geometry.*
import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将颜色对象注册为 Lua 值
 * @param[zh-cn] color 颜色对象
 * @return[zh-cn] Lua 对象值
 *
 * @brief[en] Registers a color object as a Lua value
 * @param[en] color The color object
 * @return[en] The Lua object value
 */
internal func _prebindHlpColorToLua(color: Color): LuaValue {
    return prebindRegister(color, "three.core.math.Color")
}

/**
 * @brief[zh-cn] 将 Lua 值取回为颜色对象
 * @param[zh-cn] v Lua 对象值
 * @return[zh-cn] 颜色对象
 *
 * @brief[en] Fetches a color object from a Lua value
 * @param[en] v The Lua object value
 * @return[en] The color object
 */
internal func _prebindHlpColorFromLua(v: LuaValue): Color {
    return prebindAsValue<Color>(v)
}

/**
 * @brief[zh-cn] 读取可选颜色参数（支持 Color 对象与十六进制数值，缺省返回默认颜色）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @param[zh-cn] default 缺省颜色
 * @return[zh-cn] 颜色对象
 *
 * @brief[en] Reads an optional color argument (Color object or hex number, default when absent)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @param[en] default The default color
 * @return[en] The color object
 */
internal func _prebindHlpColorArg(args: Array<LuaValue>, idx: Int64, default!: Color = Color(0xffffff)): Color {
    if (args.size <= idx || args[idx].isNil) {
        return default
    }
    let v = args[idx]
    if (v.isObject) {
        return prebindAsValue<Color>(v)
    }
    if (v.isInteger || v.isNumber) {
        return Color(UInt32(v.numberValue()))
    }
    return default
}

/**
 * @brief[zh-cn] 读取可选十六进制颜色参数（Color 对象取其十六进制值，缺省返回默认值）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @param[zh-cn] default 缺省十六进制颜色
 * @return[zh-cn] 十六进制颜色值
 *
 * @brief[en] Reads an optional hex color argument (a Color object yields its hex value)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @param[en] default The default hex color
 * @return[en] The hex color value
 */
internal func _prebindHlpHexArg(args: Array<LuaValue>, idx: Int64, default!: UInt32 = 0xffff00): UInt32 {
    if (args.size <= idx || args[idx].isNil) {
        return default
    }
    let v = args[idx]
    if (v.isObject) {
        return prebindAsValue<Color>(v).getHex()
    }
    if (v.isInteger || v.isNumber) {
        return UInt32(v.numberValue())
    }
    return default
}

/**
 * @brief[zh-cn] 读取可选颜色参数为 Option<Color>（nil/缺失/非法返回 None）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @return[zh-cn] 可选颜色
 *
 * @brief[en] Reads an optional color argument as Option<Color> (nil/absent/invalid yields None)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @return[en] The optional color
 */
internal func _prebindHlpOptColorArg(args: Array<LuaValue>, idx: Int64): Option<Color> {
    if (args.size <= idx || args[idx].isNil) {
        return None
    }
    let v = args[idx]
    if (v.isObject) {
        return Some(prebindAsValue<Color>(v))
    }
    if (v.isInteger || v.isNumber) {
        return Some(Color(UInt32(v.numberValue())))
    }
    return None
}

/**
 * @brief[zh-cn] 将可选颜色转为 Lua 值（Some 注册对象，None 返回 nil）
 * @param[zh-cn] color 可选颜色
 * @return[zh-cn] Lua 值
 *
 * @brief[en] Converts an optional color into a Lua value (Some registers, None is nil)
 * @param[en] color The optional color
 * @return[en] The Lua value
 */
internal func _prebindHlpOptColorToLua(color: Option<Color>): LuaValue {
    match (color) {
        case Some(c) => _prebindHlpColorToLua(c)
        case None => LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 将 Lua 值转为可选颜色（nil/非对象返回 None，数值按十六进制颜色）
 * @param[zh-cn] v Lua 值
 * @return[zh-cn] 可选颜色
 *
 * @brief[en] Converts a Lua value into an optional color (nil/non-object yields None,
 * a number is a hex color)
 * @param[en] v The Lua value
 * @return[en] The optional color
 */
internal func _prebindHlpOptColorFromLua(v: LuaValue): Option<Color> {
    if (v.isNil) {
        return None
    }
    if (v.isObject) {
        return Some(prebindAsValue<Color>(v))
    }
    if (v.isInteger || v.isNumber) {
        return Some(Color(UInt32(v.numberValue())))
    }
    return None
}

/**
 * @brief[zh-cn] 将命中的 Intersection 列表转为 Lua 对象数组
 * @param[zh-cn] items 命中结果列表
 * @return[zh-cn] Lua 数组值（元素注册为 three.scene.objects.Intersection）
 *
 * @brief[en] Converts the hit Intersection list into a Lua object array
 * @param[en] items The hit result list
 * @return[en] Lua array value (elements registered as three.scene.objects.Intersection)
 */
internal func _prebindHlpIntersectionsToLua(items: ArrayList<Intersection>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.scene.objects.Intersection")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 为绑定器安装辅助对象共用的 IReleasable 成员
 * @explain[zh-cn] helpers 包的全部辅助对象都实现 IReleasable；按接口强转后经虚函数分派，
 * 子类各自的 release 实现自动生效。Lua 类表没有继承，必须在 b.install 之前调用。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the IReleasable members shared by every helper binding
 * @explain[en] Every helper in the helpers package implements IReleasable; callbacks cast to the
 * interface and rely on virtual dispatch so each class's own release applies. Lua class tables have
 * no inheritance, so this must be called before b.install.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine
 */
internal func _prebindHlpHelperMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<IReleasable>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<IReleasable>().release())]
    }
}

/**
 * @brief[zh-cn] 为绑定器安装 Line 的成员（构造与 Object3D 成员除外）
 * @explain[zh-cn] LineSegments 与 Line 的辅助对象绑定复用本函数；回调按 Line 强转，
 * LineSegments 覆写的 computeLineDistances 经虚函数分派自动生效。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Line members (except the constructor and Object3D members) on a binder
 * @explain[en] LineSegments and Line helper bindings reuse this function; callbacks cast to Line and
 * the LineSegments computeLineDistances override applies through virtual dispatch.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine
 */
internal func _prebindHlpLineMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    b.property("geometry", getter: Some({
        ref => prebindRegister(ref.cast<Line>().geometry, "three.renderers.geometry.BufferGeometry")
    }), setter: Some({
        ref, v => ref.cast<Line>().geometry = prebindAsValue<BufferGeometry>(v)
    }))
    b.property("material", getter: Some({
        ref => prebindRegister(ref.cast<Line>().material, "three.renderers.materials.Material")
    }), setter: Some({
        ref, v => ref.cast<Line>().material = prebindAsValue<Material>(v)
    }))
    b.method("computeLineDistances") {
        ref, _ =>
            ref.cast<Line>().computeLineDistances()
            [LuaValue.Object(ref.id)]
    }
    b.method("intersectsFrustum") {
        ref, args => [LuaValue.of(ref.cast<Line>().intersectsFrustum(prebindAs<Frustum>(args, 0)))]
    }
    b.method("raycast") {
        ref, args =>
            var out = Array<LuaValue>()
            try {
                let hits = ArrayList<Intersection>()
                ref.cast<Line>().raycast(prebindAs<Raycaster>(args, 0), hits)
                out = Array<LuaValue>(hits.size, {
                    i => prebindRegister(hits[i], "three.scene.objects.Intersection")
                })
            } catch (_) {
                out = Array<LuaValue>()
            }
            [LuaValue.of(out)]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Line>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Line>().clone(), "three.scene.entity.Line")]
    }
}

/**
 * @brief[zh-cn] 为绑定器安装 LineSegments 的成员（构造与 Object3D 成员除外）
 * @explain[zh-cn] LineSegments 仅重写 computeLineDistances（按线段逐段距离），其余成员与 Line 相同；
 * 因此复用 _prebindHlpLineMembers，虚函数分派保证重写生效。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the LineSegments members (except the constructor and Object3D members)
 * @explain[en] LineSegments only overrides computeLineDistances; the other members match Line, so
 * _prebindHlpLineMembers is reused and virtual dispatch applies the override.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine
 */
internal func _prebindHlpLineSegmentsMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    _prebindHlpLineMembers(b, vm)
}

/**
 * @brief[zh-cn] 为绑定器安装 Mesh 的成员（构造与 Object3D 成员除外）
 * @explain[zh-cn] PointLightHelper 继承 Mesh，绑定在 b.install 之前复用本函数。
 * 跳过 morphTargetDictionary（HashMap<String, Int64>，绑定层无映射通道）与
 * getCullingGeometry（返回接口实例 IGeometryProvider）。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Mesh members (except the constructor and Object3D members)
 * @explain[en] PointLightHelper extends Mesh and reuses this function before b.install.
 * Skipped: morphTargetDictionary (HashMap<String, Int64>, no binding channel) and
 * getCullingGeometry (returns the interface instance IGeometryProvider).
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine
 */
internal func _prebindHlpMeshMembers(b: LuaClassBinder, vm: LuaVM): Unit {
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
    b.method("updateMorphTargets") {
        ref, _ =>
            try {
                ref.cast<Mesh>().updateMorphTargets()
            } catch (_) {
                ()
            }
            []
    }
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
    b.method("raycast") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                let hits = ArrayList<Intersection>()
                ref.cast<Mesh>().raycast(prebindAs<Raycaster>(args, 0), hits)
                out = _prebindHlpIntersectionsToLua(hits)
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
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
    b.method("copy") {
        ref, args =>
            try {
                ref.cast<Mesh>().copy(prebindAs<Mesh>(args, 0), recursive: prebindBool(args, 1, default: true))
            } catch (_) {
                ()
            }
            [LuaValue.Object(ref.id)]
    }
}
