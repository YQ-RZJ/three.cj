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
 * @file[zh-cn] renderers_geometry_curve 曲线基类 Curve 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.Curve 绑定为 Lua 类型并导出曲线家族共用成员安装函数
 * @explain[zh-cn] 绑定 Curve 的可映射成员：kind/arcLengthDivisions/needsUpdate 属性；
 * getPoint/getPointAt/getPoints/getSpacedPoints/getLength/getLengths/getUtoTmapping/
 * getTangent/getTangentAt/computeFrenetFrames 通用算法；clone/copy。
 * 返回点的方法以 prebindRegister 注册 Vector3；点数组转为注册对象数组；
 * getLengths 转为 Lua 数值数组；computeFrenetFrames 的三元组返回转为三个数组组成的 Lua 数组。
 * 各曲线子类绑定复用 _prebindRgcCurveMembers，避免逐个复制成员。
 * 跳过成员及原因：
 * - fromJSON(HashMap<String, Any>)：任意值容器无法安全映射为 Lua 值；
 * - cacheArcLengths：私有缓存字段。
 *
 * @file[en] renderers_geometry_curve  Lua binding of the Curve base class (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.Curve and exports the shared curve member installer
 * @explain[en] Binds the mappable members of Curve: kind/arcLengthDivisions/needsUpdate properties;
 * the getPoint/getPointAt/getPoints/getSpacedPoints/getLength/getLengths/getUtoTmapping/
 * getTangent/getTangentAt/computeFrenetFrames algorithms; clone/copy. Point-returning methods
 * register a Vector3 via prebindRegister; point arrays become registered object arrays;
 * getLengths becomes a Lua numeric array; the computeFrenetFrames tuple becomes a Lua array of
 * three arrays. Curve subclass bindings reuse _prebindRgcCurveMembers instead of duplicating members.
 * Skipped members and reasons:
 * - fromJSON(HashMap<String, Any>): arbitrary value containers cannot be mapped safely;
 * - cacheArcLengths: private cache field.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将 Vector3 数组转为 Lua 对象数组
 * @param[zh-cn] points 点数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a Vector3 array into a Lua object array
 * @param[en] points The point array
 * @return[en] The Lua array value
 */
internal func _prebindRgcVec3ArrayToLua(points: Array<Vector3>): LuaValue {
    let n = points.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(points[i], "three.core.math.Vector3")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 为绑定器安装 Curve 的成员（构造除外）
 * @explain[zh-cn] 曲线子类绑定复用本函数；所有回调按 Curve 强转，经虚函数分派到具体子类实现。
 * @param[zh-cn] b 目标类绑定器
 *
 * @brief[en] Installs the Curve members (except the constructor) on a class binder
 * @explain[en] Reused by curve subclass bindings; every callback casts to Curve and relies on
 * virtual dispatch to reach the concrete subclass implementation.
 * @param[en] b The target class binder
 */
internal func _prebindRgcCurveMembers(b: LuaClassBinder): Unit {
    // ===== 属性 =====
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<Curve>().kind)}),
        setter: Some({ref, v => ref.cast<Curve>().kind = v.stringValue()}))
    b.property("arcLengthDivisions", getter: Some({ref => LuaValue.of(ref.cast<Curve>().arcLengthDivisions)}),
        setter: Some({ref, v => ref.cast<Curve>().arcLengthDivisions = v.intValue()}))
    b.property("needsUpdate", getter: Some({ref => LuaValue.of(ref.cast<Curve>().needsUpdate)}),
        setter: Some({ref, v => ref.cast<Curve>().needsUpdate = v.boolValue()}))
    // ===== 取点 =====
    b.method("getPoint") {
        ref, args => [prebindRegister(ref.cast<Curve>().getPoint(prebindNum(args, 0)), "three.core.math.Vector3")]
    }
    b.method("getPointAt") {
        ref, args => [prebindRegister(ref.cast<Curve>().getPointAt(prebindNum(args, 0)), "three.core.math.Vector3")]
    }
    b.method("getPoints") {
        ref, args => [_prebindRgcVec3ArrayToLua(ref.cast<Curve>().getPoints(prebindInt(args, 0, default: 5)))]
    }
    b.method("getSpacedPoints") {
        ref, args => [_prebindRgcVec3ArrayToLua(ref.cast<Curve>().getSpacedPoints(prebindInt(args, 0, default: 5)))]
    }
    // ===== 弧长 =====
    b.method("getLength") {
        ref, _ => [LuaValue.of(ref.cast<Curve>().getLength())]
    }
    b.method("getLengths") {
        ref, args => [LuaValue.of(ref.cast<Curve>().getLengths(prebindInt(args, 0, default: 200)))]
    }
    b.method("updateArcLengths") {
        ref, _ =>
            ref.cast<Curve>().updateArcLengths()
            []
    }
    b.method("getUtoTmapping") {
        ref, args =>
            let distance: ?Float64 = if (args.size > 1 && !args[1].isNil) {
                Some(args[1].numberValue())
            } else {
                None
            }
            [LuaValue.of(ref.cast<Curve>().getUtoTmapping(prebindNum(args, 0), distance: distance))]
    }
    // ===== 切线 / 标架 =====
    b.method("getTangent") {
        ref, args => [prebindRegister(ref.cast<Curve>().getTangent(prebindNum(args, 0)), "three.core.math.Vector3")]
    }
    b.method("getTangentAt") {
        ref, args => [prebindRegister(ref.cast<Curve>().getTangentAt(prebindNum(args, 0)), "three.core.math.Vector3")]
    }
    b.method("computeFrenetFrames") {
        ref, args =>
            let (tangents, normals, binormals) = ref
                .cast<Curve>()
                .computeFrenetFrames(prebindInt(args, 0, default: 5), closed: prebindBool(args, 1))
            [
                LuaValue.Array(
                    [
                        _prebindRgcVec3ArrayToLua(tangents),
                        _prebindRgcVec3ArrayToLua(normals),
                        _prebindRgcVec3ArrayToLua(binormals)
                    ]
                )
            ]
    }
    // ===== 克隆 / 复制 =====
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Curve>().clone(), "three.renderers.geometry.Curve")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Curve>().copy(prebindAs<Curve>(args, 0))
            [LuaValue.Object(ref.id)]
    }
}

/**
 * @brief[zh-cn] 安装 Curve 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.Curve）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Curve
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.Curve)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCurve(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.Curve")
    b.constructor {_ => Curve()}
    _prebindRgcCurveMembers(b)
    b.install(vm)
}
