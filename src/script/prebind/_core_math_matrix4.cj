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
 * @file[zh-cn] core_math_matrix4 4x4 矩阵 Matrix4 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Matrix4 绑定为 Lua 类型 three.core.math.Matrix4
 * @explain[zh-cn] 覆盖构造（new/无参与十六参）、实例方法（set/identity/clone/copy/multiply/
 * invert/transpose/determinant/makeTranslation/makeRotation.../makePerspective/
 * makeOrthographic/lookAt/decompose/compose/fromArray/toArray 等）与属性 elements
 * （可读写）。makeTranslation/setPosition 按参数类型自动分派 Vector3 与 xyz 数值两版。
 * 互变异构方法均返回自身（Lua 链式可用）。
 *
 * @file[en] core_math_matrix4  Lua binding of the 4x4 matrix Matrix4 (three.script.prebind)
 * @brief[en] Binds three.core.math.Matrix4 as the Lua type three.core.math.Matrix4
 * @explain[en] Covers construction (new / no-arg / sixteen-arg), instance methods
 * (set/identity/clone/copy/multiply/invert/transpose/determinant/makeTranslation/
 * makeRotation.../makePerspective/makeOrthographic/lookAt/decompose/compose/fromArray/
 * toArray etc.) and the property elements (read-write). makeTranslation/setPosition
 * dispatch between the Vector3 variant and the xyz-number variant by argument type.
 * Mutating methods return self for Lua chaining.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Matrix4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Matrix4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Matrix4
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Matrix4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMatrix4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Matrix4")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 16) {
            Matrix4(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue(),
                args[4].numberValue(), args[5].numberValue(), args[6].numberValue(), args[7].numberValue(),
                args[8].numberValue(), args[9].numberValue(), args[10].numberValue(), args[11].numberValue(),
                args[12].numberValue(), args[13].numberValue(), args[14].numberValue(), args[15].numberValue())
        } else {
            Matrix4()
        }
    }
    // ===== 属性 =====
    b.property("elements", getter: Some({ref => LuaValue.of(ref.cast<Matrix4>().elements)}),
        setter: Some({ref, v => ref.cast<Matrix4>().elements = v.toArrayFloat()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            let v = ref.cast<Matrix4>()
            v.set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue(),
                args[4].numberValue(), args[5].numberValue(), args[6].numberValue(), args[7].numberValue(),
                args[8].numberValue(), args[9].numberValue(), args[10].numberValue(), args[11].numberValue(),
                args[12].numberValue(), args[13].numberValue(), args[14].numberValue(), args[15].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("identity") {
        ref, _ =>
            ref.cast<Matrix4>().identity()
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Matrix4>().clone(), "three.core.math.Matrix4")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Matrix4>().copy(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("copyPosition") {
        ref, args =>
            ref.cast<Matrix4>().copyPosition(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 乘法 =====
    b.method("multiply") {
        ref, args =>
            ref.cast<Matrix4>().multiply(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("premultiply") {
        ref, args =>
            ref.cast<Matrix4>().premultiply(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyMatrices") {
        ref, args =>
            ref.cast<Matrix4>().multiplyMatrices(prebindAs<Matrix4>(args, 0), prebindAs<Matrix4>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Matrix4>().multiplyScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 行列式/求逆/转置 =====
    b.method("determinant") {
        ref, _ => [LuaValue.of(ref.cast<Matrix4>().determinant())]
    }
    b.method("determinantAffine") {
        ref, _ => [LuaValue.of(ref.cast<Matrix4>().determinantAffine())]
    }
    b.method("invert") {
        ref, _ =>
            ref.cast<Matrix4>().invert()
            [LuaValue.Object(ref.id)]
    }
    b.method("transpose") {
        ref, _ =>
            ref.cast<Matrix4>().transpose()
            [LuaValue.Object(ref.id)]
    }
    b.method("getInverse") {
        ref, args =>
            ref.cast<Matrix4>().getInverse(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getMaxScaleOnAxis") {
        ref, _ => [LuaValue.of(ref.cast<Matrix4>().getMaxScaleOnAxis())]
    }
    // ===== 变换矩阵构造 =====
    b.method("makeTranslation") {
        ref, args =>
            let v = ref.cast<Matrix4>()
            if (args[0].isObject) {
                v.makeTranslation(prebindAs<Vector3>(args, 0))
            } else {
                v.makeTranslation(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("makeRotationX") {
        ref, args =>
            ref.cast<Matrix4>().makeRotationX(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("makeRotationY") {
        ref, args =>
            ref.cast<Matrix4>().makeRotationY(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("makeRotationZ") {
        ref, args =>
            ref.cast<Matrix4>().makeRotationZ(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("makeRotationAxis") {
        ref, args =>
            ref.cast<Matrix4>().makeRotationAxis(prebindAs<Vector3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("makeRotationFromEuler") {
        ref, args =>
            ref.cast<Matrix4>().makeRotationFromEuler(prebindAs<Euler>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("makeRotationFromQuaternion") {
        ref, args =>
            ref.cast<Matrix4>().makeRotationFromQuaternion(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("makeScale") {
        ref, args =>
            ref.cast<Matrix4>().makeScale(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("makeShear") {
        ref, args =>
            ref
                .cast<Matrix4>()
                .makeShear(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue(),
                    args[4].numberValue(), args[5].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("makePerspective") {
        ref, args =>
            ref
                .cast<Matrix4>()
                .makePerspective(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(),
                    args[3].numberValue(), args[4].numberValue(), args[5].numberValue(),
                    coordinateSystem: prebindInt(args, 6, default: 2001), reversedDepth: prebindBool(args, 7))
            [LuaValue.Object(ref.id)]
    }
    b.method("makeOrthographic") {
        ref, args =>
            ref
                .cast<Matrix4>()
                .makeOrthographic(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(),
                    args[3].numberValue(), args[4].numberValue(), args[5].numberValue(),
                    coordinateSystem: prebindInt(args, 6, default: 2001), reversedDepth: prebindBool(args, 7))
            [LuaValue.Object(ref.id)]
    }
    b.method("lookAt") {
        ref, args =>
            ref
                .cast<Matrix4>()
                .lookAt(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("compose") {
        ref, args =>
            ref
                .cast<Matrix4>()
                .compose(prebindAs<Vector3>(args, 0), prebindAs<Quaternion>(args, 1), prebindAs<Vector3>(args, 2))
            [LuaValue.Object(ref.id)]
    }
    // ===== 提取变换 =====
    b.method("getPosition") {
        ref, _ => [prebindRegister(ref.cast<Matrix4>().getPosition(), "three.core.math.Vector3")]
    }
    b.method("setPosition") {
        ref, args =>
            let v = ref.cast<Matrix4>()
            if (args[0].isObject) {
                v.setPosition(prebindAs<Vector3>(args, 0))
            } else {
                v.setPosition(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("decompose") {
        ref, args =>
            ref
                .cast<Matrix4>()
                .decompose(prebindAs<Vector3>(args, 0), prebindAs<Quaternion>(args, 1), prebindAs<Vector3>(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("extractRotation") {
        ref, args =>
            ref.cast<Matrix4>().extractRotation(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("extractBasis") {
        ref, args =>
            ref
                .cast<Matrix4>()
                .extractBasis(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("makeBasis") {
        ref, args =>
            ref
                .cast<Matrix4>()
                .makeBasis(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromMatrix3") {
        ref, args =>
            ref.cast<Matrix4>().setFromMatrix3(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("scale") {
        ref, args =>
            ref.cast<Matrix4>().scale(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Matrix4>().equals(prebindAs<Matrix4>(args, 0)))]
    }
    // ===== 数组操作 =====
    b.method("fromArray") {
        ref, args =>
            ref.cast<Matrix4>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, args =>
            var arr = Array<Float64>(16, {_ => 0.0})
            ref.cast<Matrix4>().toArray(arr, offset: prebindInt(args, 1))
            [LuaValue.of(arr)]
    }
    b.install(vm)
}
