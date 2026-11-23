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
 * @file[zh-cn] core_math_vector2 2D 向量 Vector2 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Vector2 绑定为 Lua 类型 three.core.math.Vector2
 * @explain[zh-cn] 覆盖构造（new/无参与双参）、实例方法（set/copy/add/sub/multiply/divide/
 * normalize/lerp/clone/数组互转等）与属性（x/y/width/height）。互变异构方法均返回自身
 * （Lua 链式可用）。运算符重载以 __add/__sub/__mul/__div/__unm 方法形式暴露
 * （仅程序性调用，不接 Lua 元表）。
 *
 * @file[en] core_math_vector2  Lua binding of the 2D vector Vector2 (three.script.prebind)
 * @brief[en] Binds three.core.math.Vector2 as the Lua type three.core.math.Vector2
 * @explain[en] Covers construction (new / no-arg / two-arg), instance methods
 * (set/copy/add/sub/multiply/divide/normalize/lerp/clone/array round-trip etc.) and
 * properties (x/y/width/height). Mutating methods return self for Lua chaining.
 * Operator overloads are exposed as __add/__sub/__mul/__div/__unm methods (callable
 * only; Lua metamethods are not wired).
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Vector2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Vector2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Vector2
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Vector2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
protected func installVector2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Vector2")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2) {
            Vector2(args[0].numberValue(), args[1].numberValue())
        } else {
            Vector2()
        }
    }
    // ===== 属性 =====
    b.property("x", getter: Some({ref => LuaValue.of(ref.cast<Vector2>().x)}),
        setter: Some({ref, v => ref.cast<Vector2>().x = v.numberValue()}))
    b.property("y", getter: Some({ref => LuaValue.of(ref.cast<Vector2>().y)}),
        setter: Some({ref, v => ref.cast<Vector2>().y = v.numberValue()}))
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<Vector2>().width)}),
        setter: Some({ref, v => ref.cast<Vector2>().width = v.numberValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<Vector2>().height)}),
        setter: Some({ref, v => ref.cast<Vector2>().height = v.numberValue()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            let v = ref.cast<Vector2>()
            v.set(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setScalar") {
        ref, args =>
            ref.cast<Vector2>().setScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setX") {
        ref, args =>
            ref.cast<Vector2>().setX(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setY") {
        ref, args =>
            ref.cast<Vector2>().setY(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setComponent") {
        ref, args =>
            ref.cast<Vector2>().setComponent(args[0].intValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("getComponent") {
        ref, args => [LuaValue.of(ref.cast<Vector2>().getComponent(args[0].intValue()))]
    }
    b.method("clone") {
        ref, _ => [LuaValue.Object(LuaObjectRegistry.register(ref.cast<Vector2>().clone(), "three.core.math.Vector2"))]
    }
    b.method("copy") {
        ref, args =>
            let src = LuaObjectRegistry.getAs<Vector2>(args[0].objectId())
            ref.cast<Vector2>().copy(src)
            [LuaValue.Object(ref.id)]
    }
    // ===== 加法 =====
    b.method("add") {
        ref, args =>
            ref.cast<Vector2>().add(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScalar") {
        ref, args =>
            ref.cast<Vector2>().addScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("addVectors") {
        ref, args =>
            ref
                .cast<Vector2>()
                .addVectors(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()),
                    LuaObjectRegistry.getAs<Vector2>(args[1].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScaledVector") {
        ref, args =>
            ref
                .cast<Vector2>()
                .addScaledVector(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 减法 =====
    b.method("sub") {
        ref, args =>
            ref.cast<Vector2>().sub(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("subScalar") {
        ref, args =>
            ref.cast<Vector2>().subScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("subVectors") {
        ref, args =>
            ref
                .cast<Vector2>()
                .subVectors(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()),
                    LuaObjectRegistry.getAs<Vector2>(args[1].objectId()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 乘法 =====
    b.method("multiply") {
        ref, args =>
            ref.cast<Vector2>().multiply(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Vector2>().multiplyScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 除法 =====
    b.method("divide") {
        ref, args =>
            ref.cast<Vector2>().divide(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("divideScalar") {
        ref, args =>
            ref.cast<Vector2>().divideScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 矩阵变换 =====
    b.method("applyMatrix3") {
        ref, args =>
            ref.cast<Vector2>().applyMatrix3(LuaObjectRegistry.getAs<Matrix3>(args[0].objectId()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 点积/叉积 =====
    b.method("dot") {
        ref, args => [LuaValue.of(ref.cast<Vector2>().dot(LuaObjectRegistry.getAs<Vector2>(args[0].objectId())))]
    }
    b.method("cross") {
        ref, args => [LuaValue.of(ref.cast<Vector2>().cross(LuaObjectRegistry.getAs<Vector2>(args[0].objectId())))]
    }
    // ===== 长度 =====
    b.method("lengthSq") {ref, _ => [LuaValue.of(ref.cast<Vector2>().lengthSq())]}
    b.method("length") {ref, _ => [LuaValue.of(ref.cast<Vector2>().length())]}
    b.method("manhattanLength") {ref, _ => [LuaValue.of(ref.cast<Vector2>().manhattanLength())]}
    // ===== 归一化 =====
    b.method("normalize") {
        ref, _ =>
            ref.cast<Vector2>().normalize()
            [LuaValue.Object(ref.id)]
    }
    b.method("setLength") {
        ref, args =>
            ref.cast<Vector2>().setLength(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 角度 =====
    b.method("angle") {ref, _ => [LuaValue.of(ref.cast<Vector2>().angle())]}
    b.method("angleTo") {
        ref, args => [LuaValue.of(ref.cast<Vector2>().angleTo(LuaObjectRegistry.getAs<Vector2>(args[0].objectId())))]
    }
    // ===== 距离 =====
    b.method("distanceTo") {
        ref, args => [LuaValue.of(ref.cast<Vector2>().distanceTo(LuaObjectRegistry.getAs<Vector2>(args[0].objectId())))]
    }
    b.method("distanceToSquared") {
        ref, args => [LuaValue.of(
            ref.cast<Vector2>().distanceToSquared(LuaObjectRegistry.getAs<Vector2>(args[0].objectId())))]
    }
    b.method("manhattanDistanceTo") {
        ref, args => [LuaValue.of(
            ref.cast<Vector2>().manhattanDistanceTo(LuaObjectRegistry.getAs<Vector2>(args[0].objectId())))]
    }
    // ===== 线性插值 =====
    b.method("lerp") {
        ref, args =>
            ref.cast<Vector2>().lerp(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("lerpVectors") {
        ref, args =>
            ref
                .cast<Vector2>()
                .lerpVectors(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()),
                    LuaObjectRegistry.getAs<Vector2>(args[1].objectId()), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 取负 =====
    b.method("negate") {
        ref, _ =>
            ref.cast<Vector2>().negate()
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Vector2>().equals(LuaObjectRegistry.getAs<Vector2>(args[0].objectId())))]
    }
    // ===== 极值 =====
    b.method("min") {
        ref, args =>
            ref.cast<Vector2>().min(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("max") {
        ref, args =>
            ref.cast<Vector2>().max(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("clamp") {
        ref, args =>
            ref
                .cast<Vector2>()
                .clamp(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()),
                    LuaObjectRegistry.getAs<Vector2>(args[1].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("clampScalar") {
        ref, args =>
            ref.cast<Vector2>().clampScalar(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("clampLength") {
        ref, args =>
            ref.cast<Vector2>().clampLength(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("floor") {
        ref, _ =>
            ref.cast<Vector2>().floor()
            [LuaValue.Object(ref.id)]
    }
    b.method("ceil") {
        ref, _ =>
            ref.cast<Vector2>().ceil()
            [LuaValue.Object(ref.id)]
    }
    b.method("round") {
        ref, _ =>
            ref.cast<Vector2>().round()
            [LuaValue.Object(ref.id)]
    }
    b.method("roundToZero") {
        ref, _ =>
            ref.cast<Vector2>().roundToZero()
            [LuaValue.Object(ref.id)]
    }
    // ===== 旋转 =====
    b.method("rotateAround") {
        ref, args =>
            ref
                .cast<Vector2>()
                .rotateAround(LuaObjectRegistry.getAs<Vector2>(args[0].objectId()), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 数组操作 =====
    b.method("fromArray") {
        ref, args =>
            ref.cast<Vector2>().fromArray(args[0].toArrayFloat(), offset: args[1].intValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, _ =>
            let n = 2
            var arr = Array<Float64>(n, {_ => 0.0})
            ref.cast<Vector2>().toArray(arr)
            [LuaValue.of(arr)]
    }
    // ===== 随机 =====
    b.method("random") {
        ref, _ =>
            ref.cast<Vector2>().random()
            [LuaValue.Object(ref.id)]
    }
    // ===== 运算符（程序性调用） =====
    b.method("__add") {
        ref, args =>
            let r = ref.cast<Vector2>()
            let o = r + LuaObjectRegistry.getAs<Vector2>(args[0].objectId())
            [LuaValue.Object(LuaObjectRegistry.register(o, "three.core.math.Vector2"))]
    }
    b.method("__sub") {
        ref, args =>
            let r = ref.cast<Vector2>()
            let o = r - LuaObjectRegistry.getAs<Vector2>(args[0].objectId())
            [LuaValue.Object(LuaObjectRegistry.register(o, "three.core.math.Vector2"))]
    }
    b.method("__mul") {
        ref, args =>
            let r = ref.cast<Vector2>()
            let o = r * args[0].numberValue()
            [LuaValue.Object(LuaObjectRegistry.register(o, "three.core.math.Vector2"))]
    }
    b.method("__div") {
        ref, args =>
            let r = ref.cast<Vector2>()
            let o = r / args[0].numberValue()
            [LuaValue.Object(LuaObjectRegistry.register(o, "three.core.math.Vector2"))]
    }
    b.method("__unm") {
        ref, _ =>
            let r = ref.cast<Vector2>()
            let o = -r
            [LuaValue.Object(LuaObjectRegistry.register(o, "three.core.math.Vector2"))]
    }
    b.install(vm)
}
