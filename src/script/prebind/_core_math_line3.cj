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
 * @file[zh-cn] core_math_line3 三维线段 Line3 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Line3 绑定为 Lua 类型 three.core.math.Line3
 * @explain[zh-cn] 覆盖构造（new/无参与双参）、实例方法（set/clone/copy/getCenter/delta/
 * distance/distanceSq/at/closestPointToPointParameter/closestPointToPoint/
 * distanceSqToLine3/applyMatrix4/equals/fromArray/toArray）与属性 start/end（读写）。
 * 互变异构方法均返回自身（Lua 链式可用）。getCenter/delta/at/closestPointToPoint
 * 按参数个数分派无参与 target 两版；toArray 创建长度为 6 的新数组在 Lua 侧返回。
 *
 * @file[en] core_math_line3 Lua binding of the 3D line segment Line3 (three.script.prebind)
 * @brief[en] Binds three.core.math.Line3 as the Lua type three.core.math.Line3
 * @explain[en] Covers construction (new / no-arg / two-arg), instance methods
 * (set/clone/copy/getCenter/delta/distance/distanceSq/at/
 * closestPointToPointParameter/closestPointToPoint/distanceSqToLine3/applyMatrix4/
 * equals/fromArray/toArray) and properties start/end (read-write). Mutating methods
 * return self for Lua chaining. getCenter/delta/at/closestPointToPoint dispatch
 * between no-arg and target versions by argument count; toArray creates a new 6-element
 * array returned on the Lua side.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Line3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Line3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Line3
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Line3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLine3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Line3")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2) {
            Line3(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
        } else {
            Line3()
        }
    }
    // ===== 属性 =====
    b.property("start", getter: Some({ref => prebindRegister(ref.cast<Line3>().start, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Line3>().start = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    b.property("end", getter: Some({ref => prebindRegister(ref.cast<Line3>().end, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Line3>().end = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Line3>().set(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Line3>().clone(), "three.core.math.Line3")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Line3>().copy(prebindAs<Line3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // getCenter() / getCenter(target)
    b.method("getCenter") {
        ref, args =>
            let v = ref.cast<Line3>()
            if (args.size >= 1) {
                v.getCenter(prebindAs<Vector3>(args, 0))
                [LuaValue.Object(args[0].objectId())]
            } else {
                [prebindRegister(v.getCenter(), "three.core.math.Vector3")]
            }
    }
    // delta() / delta(target)
    b.method("delta") {
        ref, args =>
            let v = ref.cast<Line3>()
            if (args.size >= 1) {
                v.delta(prebindAs<Vector3>(args, 0))
                [LuaValue.Object(args[0].objectId())]
            } else {
                [prebindRegister(v.delta(), "three.core.math.Vector3")]
            }
    }
    // ===== 长度 =====
    b.method("distance") {
        ref, _ => [LuaValue.of(ref.cast<Line3>().distance())]
    }
    b.method("distanceSq") {
        ref, _ => [LuaValue.of(ref.cast<Line3>().distanceSq())]
    }
    // at(t) / at(t, target)
    b.method("at") {
        ref, args =>
            let v = ref.cast<Line3>()
            if (args.size >= 2) {
                v.at(args[0].numberValue(), prebindAs<Vector3>(args, 1))
                [LuaValue.Object(args[1].objectId())]
            } else {
                [prebindRegister(v.at(args[0].numberValue()), "three.core.math.Vector3")]
            }
    }
    b.method("closestPointToPointParameter") {
        ref, args => [LuaValue.of(
            ref
                .cast<Line3>()
                .closestPointToPointParameter(prebindAs<Vector3>(args, 0),
                    clampToLine: prebindBool(args, 1, default: true)))]
    }
    // closestPointToPoint(point) / closestPointToPoint(point, target, clampToLine)
    b.method("closestPointToPoint") {
        ref, args =>
            let v = ref.cast<Line3>()
            if (args.size >= 2 && args[1].isObject) {
                v.closestPointToPoint(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1),
                    clampToLine: prebindBool(args, 2, default: true))
                [LuaValue.Object(args[1].objectId())]
            } else {
                [prebindRegister(
                    v.closestPointToPoint(prebindAs<Vector3>(args, 0), clampToLine: prebindBool(args, 1, default: true)),
                    "three.core.math.Vector3")]
            }
    }
    b.method("distanceSqToLine3") {
        ref, args => [LuaValue.of(
            ref
                .cast<Line3>()
                .distanceSqToLine3(prebindAs<Line3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2)))]
    }
    // ===== 变换 =====
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<Line3>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Line3>().equals(prebindAs<Line3>(args, 0)))]
    }
    // ===== 数组操作 =====
    b.method("fromArray") {
        ref, args =>
            ref.cast<Line3>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, args =>
            var arr = Array<Float64>(6, {_ => 0.0})
            ref.cast<Line3>().toArray(arr, offset: prebindInt(args, 0))
            [LuaValue.of(arr)]
    }
    b.install(vm)
}
