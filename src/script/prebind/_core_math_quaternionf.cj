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
 * @file[zh-cn] core_math_quaternionf 单精度四元数 QuaternionF 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.QuaternionF 绑定为 Lua 类型 three.core.math.QuaternionF
 * @explain[zh-cn] 覆盖两种构造（无参 = 单位四元数 / x,y,z,w）、四个分量属性、
 * 设置与运算（set/copy/clone/identity/normalize/invert/conjugate/negate/
 * multiply/premultiply/multiplyQuaternions/multiplyScalar/dot/length/lengthSq/
 * angleTo/equals/slerp/slerpQuaternions/setFromAxisAngle）、与双精度互转
 * （toQuaternion、静态 fromQuaternion）、与数组互转（toArray、静态 fromArray）。
 * 跳过 setFromRotationMatrix：参数与 Matrix4F 相关，该类型尚未绑定。
 *
 * @file[en] core_math_quaternionf  Lua binding of the single-precision quaternion QuaternionF
 * (three.script.prebind)
 * @brief[en] Binds three.core.math.QuaternionF as the Lua type three.core.math.QuaternionF
 * @explain[en] Covers the two constructors (parameterless = identity / x,y,z,w), the four
 * component properties, setters and math (set/copy/clone/identity/normalize/invert/
 * conjugate/negate/multiply/premultiply/multiplyQuaternions/multiplyScalar/dot/length/
 * lengthSq/angleTo/equals/slerp/slerpQuaternions/setFromAxisAngle), conversion to/from the
 * double-precision quaternion (toQuaternion, static fromQuaternion) and to/from arrays
 * (toArray, static fromArray).
 * setFromRotationMatrix is skipped: its parameter involves Matrix4F, which is not bound yet.
 */
package three.script.prebind

import three.core.math.QuaternionF
import three.core.math.Quaternion
import three.core.math.Vector3F
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取 Lua 参数为单精度浮点数组（元素经 numberValue 转换）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Float32 数组（非数组/表返回空）
 *
 * @brief[en] Reads a Lua argument as a single-precision float array (elements via numberValue)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The Float32 array (empty when not an array/table)
 */
private func _prebindFloat32Array(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Float32> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<Float32>(n, {_ => 0.0f32})
    for (i in 0..n) {
        out[i] = Float32(elems[i].numberValue())
    }
    return out
}

/**
 * @brief[zh-cn] 安装 QuaternionF 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.QuaternionF）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of QuaternionF
 * @param[en] vm The target virtual machine (class table installed at three.core.math.QuaternionF)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installQuaternionF(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.QuaternionF")
    // ===== 构造：无参（单位四元数）或 x,y,z,w =====
    b.constructor {
        args => if (args.size >= 4) {
            QuaternionF(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)), Float32(prebindNum(args, 2)),
                Float32(prebindNum(args, 3)))
        } else {
            QuaternionF()
        }
    }
    // ===== 属性 =====
    b.property("x", getter: Some({ref => LuaValue.of(Float64(ref.cast<QuaternionF>().x))}),
        setter: Some({ref, v => ref.cast<QuaternionF>().x = Float32(v.numberValue())}))
    b.property("y", getter: Some({ref => LuaValue.of(Float64(ref.cast<QuaternionF>().y))}),
        setter: Some({ref, v => ref.cast<QuaternionF>().y = Float32(v.numberValue())}))
    b.property("z", getter: Some({ref => LuaValue.of(Float64(ref.cast<QuaternionF>().z))}),
        setter: Some({ref, v => ref.cast<QuaternionF>().z = Float32(v.numberValue())}))
    b.property("w", getter: Some({ref => LuaValue.of(Float64(ref.cast<QuaternionF>().w))}),
        setter: Some({ref, v => ref.cast<QuaternionF>().w = Float32(v.numberValue())}))
    // ===== 设置 / 拷贝 =====
    b.method("set") {
        ref, args =>
            ref
                .cast<QuaternionF>()
                .set(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)), Float32(prebindNum(args, 2)),
                    Float32(prebindNum(args, 3)))
            [LuaValue.Object(ref.id)]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<QuaternionF>().copy(prebindAs<QuaternionF>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<QuaternionF>().clone(), "three.core.math.QuaternionF")]
    }
    b.method("identity") {
        ref, _ =>
            ref.cast<QuaternionF>().identity()
            [LuaValue.Object(ref.id)]
    }
    // ===== 度量与归一 =====
    b.method("lengthSq") {
        ref, _ => [LuaValue.of(Float64(ref.cast<QuaternionF>().lengthSq()))]
    }
    b.method("length") {
        ref, _ => [LuaValue.of(Float64(ref.cast<QuaternionF>().length()))]
    }
    b.method("normalize") {
        ref, _ =>
            ref.cast<QuaternionF>().normalize()
            [LuaValue.Object(ref.id)]
    }
    b.method("dot") {
        ref, args => [LuaValue.of(Float64(ref.cast<QuaternionF>().dot(prebindAs<QuaternionF>(args, 0))))]
    }
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<QuaternionF>().equals(prebindAs<QuaternionF>(args, 0)))]
    }
    b.method("angleTo") {
        ref, args => [LuaValue.of(Float64(ref.cast<QuaternionF>().angleTo(prebindAs<QuaternionF>(args, 0))))]
    }
    // ===== 四元数运算 =====
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<QuaternionF>().multiplyScalar(Float32(prebindNum(args, 0, default: 1.0)))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiply") {
        ref, args =>
            ref.cast<QuaternionF>().multiply(prebindAs<QuaternionF>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("premultiply") {
        ref, args =>
            ref.cast<QuaternionF>().premultiply(prebindAs<QuaternionF>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyQuaternions") {
        ref, args =>
            ref.cast<QuaternionF>().multiplyQuaternions(prebindAs<QuaternionF>(args, 0), prebindAs<QuaternionF>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("conjugate") {
        ref, _ =>
            ref.cast<QuaternionF>().conjugate()
            [LuaValue.Object(ref.id)]
    }
    b.method("invert") {
        ref, _ =>
            ref.cast<QuaternionF>().invert()
            [LuaValue.Object(ref.id)]
    }
    b.method("negate") {
        ref, _ =>
            ref.cast<QuaternionF>().negate()
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromAxisAngle") {
        ref, args =>
            ref.cast<QuaternionF>().setFromAxisAngle(prebindAs<Vector3F>(args, 0), Float32(prebindNum(args, 1)))
            [LuaValue.Object(ref.id)]
    }
    b.method("slerp") {
        ref, args =>
            ref.cast<QuaternionF>().slerp(prebindAs<QuaternionF>(args, 0), Float32(prebindNum(args, 1)))
            [LuaValue.Object(ref.id)]
    }
    b.method("slerpQuaternions") {
        ref, args =>
            ref
                .cast<QuaternionF>()
                .slerpQuaternions(prebindAs<QuaternionF>(args, 0), prebindAs<QuaternionF>(args, 1),
                    Float32(prebindNum(args, 2)))
            [LuaValue.Object(ref.id)]
    }
    // ===== 与双精度 / 数组互转 =====
    b.staticMethod("fromQuaternion") {
        args => [prebindRegister(QuaternionF.fromQuaternion(prebindAs<Quaternion>(args, 0)),
            "three.core.math.QuaternionF")]
    }
    b.method("toQuaternion") {
        ref, _ => [prebindRegister(ref.cast<QuaternionF>().toQuaternion(), "three.core.math.Quaternion")]
    }
    b.method("toArray") {
        ref, _ =>
            let src = ref.cast<QuaternionF>().toArray()
            let n = src.size
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = LuaValue.of(Float64(src[i]))
            }
            [LuaValue.Array(out)]
    }
    b.staticMethod("fromArray") {
        args => [prebindRegister(QuaternionF.fromArray(_prebindFloat32Array(vm, args, 0)), "three.core.math.QuaternionF")]
    }
    b.install(vm)
}
