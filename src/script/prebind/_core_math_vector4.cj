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
 * @file[zh-cn] core_math_vector4 4D 向量 Vector4 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Vector4 绑定为 Lua 类型 three.core.math.Vector4
 * @explain[zh-cn] 覆盖构造（new/无参与四参）、实例方法（set/copy/add/sub/multiply/divide/
 * normalize/lerp/clone/applyMatrix4/数组互转/轴角设置等）与属性（x/y/z/w/width/height）。
 * 互变异构方法均返回自身（Lua 链式可用）。运算符重载以 __add/__sub/__mul/__div/__unm
 * 方法形式暴露（仅程序性调用，不接 Lua 元表）。
 *
 * @file[en] core_math_vector4  Lua binding of the 4D vector Vector4 (three.script.prebind)
 * @brief[en] Binds three.core.math.Vector4 as the Lua type three.core.math.Vector4
 * @explain[en] Covers construction (new / no-arg / four-arg), instance methods
 * (set/copy/add/sub/multiply/divide/normalize/lerp/clone/applyMatrix4/array round-trip/
 * axis-angle set etc.) and properties (x/y/z/w/width/height). Mutating methods return
 * self for Lua chaining. Operator overloads are exposed as __add/__sub/__mul/__div/__unm
 * methods (callable only; Lua metamethods are not wired).
 */
package three.script.prebind

import three.core.math.*
import three.core._interfaces.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Vector4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Vector4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Vector4
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Vector4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installVector4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Vector4")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 4) {
            Vector4(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue())
        } else {
            Vector4()
        }
    }
    // ===== 属性 =====
    b.property("x", getter: Some({ref => LuaValue.of(ref.cast<Vector4>().x)}),
        setter: Some({ref, v => ref.cast<Vector4>().x = v.numberValue()}))
    b.property("y", getter: Some({ref => LuaValue.of(ref.cast<Vector4>().y)}),
        setter: Some({ref, v => ref.cast<Vector4>().y = v.numberValue()}))
    b.property("z", getter: Some({ref => LuaValue.of(ref.cast<Vector4>().z)}),
        setter: Some({ref, v => ref.cast<Vector4>().z = v.numberValue()}))
    b.property("w", getter: Some({ref => LuaValue.of(ref.cast<Vector4>().w)}),
        setter: Some({ref, v => ref.cast<Vector4>().w = v.numberValue()}))
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<Vector4>().width)}),
        setter: Some({ref, v => ref.cast<Vector4>().width = v.numberValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<Vector4>().height)}),
        setter: Some({ref, v => ref.cast<Vector4>().height = v.numberValue()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref
                .cast<Vector4>()
                .set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setScalar") {
        ref, args =>
            ref.cast<Vector4>().setScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setX") {
        ref, args =>
            ref.cast<Vector4>().setX(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setY") {
        ref, args =>
            ref.cast<Vector4>().setY(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setZ") {
        ref, args =>
            ref.cast<Vector4>().setZ(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setW") {
        ref, args =>
            ref.cast<Vector4>().setW(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setComponent") {
        ref, args =>
            ref.cast<Vector4>().setComponent(args[0].intValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("getComponent") {
        ref, args => [LuaValue.of(ref.cast<Vector4>().getComponent(args[0].intValue()))]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Vector4>().clone(), "three.core.math.Vector4")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Vector4>().copy(prebindAs<Vector4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 加法 =====
    b.method("add") {
        ref, args =>
            ref.cast<Vector4>().add(prebindAs<Vector4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScalar") {
        ref, args =>
            ref.cast<Vector4>().addScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("addVectors") {
        ref, args =>
            ref.cast<Vector4>().addVectors(prebindAs<Vector4>(args, 0), prebindAs<Vector4>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScaledVector") {
        ref, args =>
            ref.cast<Vector4>().addScaledVector(prebindAs<Vector4>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 减法 =====
    b.method("sub") {
        ref, args =>
            ref.cast<Vector4>().sub(prebindAs<Vector4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("subScalar") {
        ref, args =>
            ref.cast<Vector4>().subScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("subVectors") {
        ref, args =>
            ref.cast<Vector4>().subVectors(prebindAs<Vector4>(args, 0), prebindAs<Vector4>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 乘法 =====
    b.method("multiply") {
        ref, args =>
            ref.cast<Vector4>().multiply(prebindAs<Vector4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Vector4>().multiplyScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 除法 =====
    b.method("divide") {
        ref, args =>
            ref.cast<Vector4>().divide(prebindAs<Vector4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("divideScalar") {
        ref, args =>
            ref.cast<Vector4>().divideScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 矩阵变换 =====
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<Vector4>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 点积 =====
    b.method("dot") {
        ref, args => [LuaValue.of(ref.cast<Vector4>().dot(prebindAs<Vector4>(args, 0)))]
    }
    // ===== 长度 =====
    b.method("lengthSq") {ref, _ => [LuaValue.of(ref.cast<Vector4>().lengthSq())]}
    b.method("length") {ref, _ => [LuaValue.of(ref.cast<Vector4>().length())]}
    b.method("manhattanLength") {ref, _ => [LuaValue.of(ref.cast<Vector4>().manhattanLength())]}
    // ===== 归一化 =====
    b.method("normalize") {
        ref, _ =>
            ref.cast<Vector4>().normalize()
            [LuaValue.Object(ref.id)]
    }
    b.method("setLength") {
        ref, args =>
            ref.cast<Vector4>().setLength(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 线性插值 =====
    b.method("lerp") {
        ref, args =>
            ref.cast<Vector4>().lerp(prebindAs<Vector4>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("lerpVectors") {
        ref, args =>
            ref
                .cast<Vector4>()
                .lerpVectors(prebindAs<Vector4>(args, 0), prebindAs<Vector4>(args, 1), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 取负 =====
    b.method("negate") {
        ref, _ =>
            ref.cast<Vector4>().negate()
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Vector4>().equals(prebindAs<Vector4>(args, 0)))]
    }
    // ===== 极值 =====
    b.method("min") {
        ref, args =>
            ref.cast<Vector4>().min(prebindAs<Vector4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("max") {
        ref, args =>
            ref.cast<Vector4>().max(prebindAs<Vector4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("clamp") {
        ref, args =>
            ref.cast<Vector4>().clamp(prebindAs<Vector4>(args, 0), prebindAs<Vector4>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("clampScalar") {
        ref, args =>
            ref.cast<Vector4>().clampScalar(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("clampLength") {
        ref, args =>
            ref.cast<Vector4>().clampLength(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("floor") {
        ref, _ =>
            ref.cast<Vector4>().floor()
            [LuaValue.Object(ref.id)]
    }
    b.method("ceil") {
        ref, _ =>
            ref.cast<Vector4>().ceil()
            [LuaValue.Object(ref.id)]
    }
    b.method("round") {
        ref, _ =>
            ref.cast<Vector4>().round()
            [LuaValue.Object(ref.id)]
    }
    b.method("roundToZero") {
        ref, _ =>
            ref.cast<Vector4>().roundToZero()
            [LuaValue.Object(ref.id)]
    }
    // ===== 顶点属性 =====
    b.method("fromBufferAttribute") {
        ref, args =>
            ref.cast<Vector4>().fromBufferAttribute(prebindAs<IAttributeReader>(args, 0), args[1].intValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 数组操作 =====
    b.method("fromArray") {
        ref, args =>
            ref.cast<Vector4>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, _ =>
            var arr = Array<Float64>(4, {_ => 0.0})
            ref.cast<Vector4>().toArray(arr)
            [LuaValue.of(arr)]
    }
    // ===== 随机 =====
    b.method("random") {
        ref, _ =>
            ref.cast<Vector4>().random()
            [LuaValue.Object(ref.id)]
    }
    // ===== 轴角 =====
    b.method("setAxisAngleFromQuaternion") {
        ref, args =>
            ref.cast<Vector4>().setAxisAngleFromQuaternion(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setAxisAngleFromRotationMatrix") {
        ref, args =>
            ref.cast<Vector4>().setAxisAngleFromRotationMatrix(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromMatrixPosition") {
        ref, args =>
            ref.cast<Vector4>().setFromMatrixPosition(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 运算符（程序性调用） =====
    b.method("__add") {
        ref, args => [prebindRegister(ref.cast<Vector4>() + prebindAs<Vector4>(args, 0), "three.core.math.Vector4")]
    }
    b.method("__sub") {
        ref, args => [prebindRegister(ref.cast<Vector4>() - prebindAs<Vector4>(args, 0), "three.core.math.Vector4")]
    }
    b.method("__mul") {
        ref, args => [prebindRegister(ref.cast<Vector4>() * args[0].numberValue(), "three.core.math.Vector4")]
    }
    b.method("__div") {
        ref, args => [prebindRegister(ref.cast<Vector4>() / args[0].numberValue(), "three.core.math.Vector4")]
    }
    b.method("__unm") {
        ref, _ => [prebindRegister(-ref.cast<Vector4>(), "three.core.math.Vector4")]
    }
    b.install(vm)
}
