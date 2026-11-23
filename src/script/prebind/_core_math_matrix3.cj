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
 * @file[zh-cn] core_math_matrix3 3x3 矩阵 Matrix3 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Matrix3 绑定为 Lua 类型 three.core.math.Matrix3
 * @explain[zh-cn] 覆盖构造（new/无参与九参）、实例方法（set/identity/clone/copy/multiply/
 * transpose/invert/determinant/fromArray/toArray/UV 变换等）与属性 elements（可读写，
 * 数组赋值写回列主序元素）。互变异构方法均返回自身（Lua 链式可用）。
 *
 * @file[en] core_math_matrix3  Lua binding of the 3x3 matrix Matrix3 (three.script.prebind)
 * @brief[en] Binds three.core.math.Matrix3 as the Lua type three.core.math.Matrix3
 * @explain[en] Covers construction (new / no-arg / nine-arg), instance methods
 * (set/identity/clone/copy/multiply/transpose/invert/determinant/fromArray/toArray/UV
 * transform etc.) and the property elements (read-write; array assignment writes back
 * the column-major elements). Mutating methods return self for Lua chaining.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Matrix3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Matrix3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Matrix3
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Matrix3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMatrix3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Matrix3")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 9) {
            Matrix3(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue(),
                args[4].numberValue(), args[5].numberValue(), args[6].numberValue(), args[7].numberValue(),
                args[8].numberValue())
        } else {
            Matrix3()
        }
    }
    // ===== 属性 =====
    b.property("elements", getter: Some({ref => LuaValue.of(ref.cast<Matrix3>().elements)}),
        setter: Some({ref, v => ref.cast<Matrix3>().elements = v.toArrayFloat()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            let v = ref.cast<Matrix3>()
            v.set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue(),
                args[4].numberValue(), args[5].numberValue(), args[6].numberValue(), args[7].numberValue(),
                args[8].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("identity") {
        ref, _ =>
            ref.cast<Matrix3>().identity()
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Matrix3>().clone(), "three.core.math.Matrix3")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Matrix3>().copy(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Matrix3>().multiplyScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 行列式/求逆/转置 =====
    b.method("determinant") {
        ref, _ => [LuaValue.of(ref.cast<Matrix3>().determinant())]
    }
    b.method("getInverse") {
        ref, args =>
            ref.cast<Matrix3>().getInverse(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("transpose") {
        ref, _ =>
            ref.cast<Matrix3>().transpose()
            [LuaValue.Object(ref.id)]
    }
    b.method("invert") {
        ref, _ =>
            ref.cast<Matrix3>().invert()
            [LuaValue.Object(ref.id)]
    }
    b.method("getNormalMatrix") {
        ref, args =>
            ref.cast<Matrix3>().getNormalMatrix(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Matrix3>().equals(prebindAs<Matrix3>(args, 0)))]
    }
    // ===== 乘法 =====
    b.method("multiply") {
        ref, args =>
            ref.cast<Matrix3>().multiply(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyMatrices") {
        ref, args =>
            ref.cast<Matrix3>().multiplyMatrices(prebindAs<Matrix3>(args, 0), prebindAs<Matrix3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("premultiply") {
        ref, args =>
            ref.cast<Matrix3>().premultiply(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("scale") {
        ref, args =>
            ref.cast<Matrix3>().scale(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 数组操作 =====
    b.method("fromArray") {
        ref, args =>
            ref.cast<Matrix3>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, args =>
            var arr = Array<Float64>(9, {_ => 0.0})
            ref.cast<Matrix3>().toArray(arr, offset: prebindInt(args, 1))
            [LuaValue.of(arr)]
    }
    b.method("transposeIntoArray") {
        ref, args =>
            ref.cast<Matrix3>().transposeIntoArray(args[0].toArrayFloat())
            [LuaValue.Object(ref.id)]
    }
    // ===== UV 变换 =====
    b.method("setUvTransform") {
        ref, args =>
            ref
                .cast<Matrix3>()
                .setUvTransform(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(),
                    args[3].numberValue(), args[4].numberValue(), args[5].numberValue(), args[6].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 矩阵提取 =====
    b.method("setFromMatrix4") {
        ref, args =>
            ref.cast<Matrix3>().setFromMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("extractBasis") {
        ref, args =>
            ref
                .cast<Matrix3>()
                .extractBasis(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2))
            [LuaValue.Object(ref.id)]
    }
    // ===== 构造矩阵 =====
    b.method("makeTranslation") {
        ref, args =>
            ref.cast<Matrix3>().makeTranslation(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("makeRotation") {
        ref, args =>
            ref.cast<Matrix3>().makeRotation(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("makeScale") {
        ref, args =>
            ref.cast<Matrix3>().makeScale(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("rotate") {
        ref, args =>
            ref.cast<Matrix3>().rotate(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("translate") {
        ref, args =>
            ref.cast<Matrix3>().translate(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
