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
 * @file[zh-cn] core_math_quaternion 四元数 Quaternion 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Quaternion 绑定为 Lua 类型 three.core.math.Quaternion
 * @explain[zh-cn] 覆盖构造（new/无参与四参）、实例方法（set/copy/multiply/premultiply/slerp/
 * setFromRotationMatrix/setFromAxisAngle/setFromEuler/normalize/dot/rotateVector/
 * fromArray/toArray 等）与属性（x/y/z/w）。互变异构方法均返回自身（Lua 链式可用）。
 * 静态方法 slerpFlat/multiplyQuaternionsFlat 挂到类表。fromBufferAttribute 的
 * IAttributeReader 参数经接口强转传入；onChange（函数回调参数）暂不绑定。
 *
 * @file[en] core_math_quaternion  Lua binding of the quaternion Quaternion (three.script.prebind)
 * @brief[en] Binds three.core.math.Quaternion as the Lua type three.core.math.Quaternion
 * @explain[en] Covers construction (new / no-arg / four-arg), instance methods
 * (set/copy/multiply/premultiply/slerp/setFromRotationMatrix/setFromAxisAngle/
 * setFromEuler/normalize/dot/rotateVector/fromArray/toArray etc.) and properties
 * (x/y/z/w). Mutating methods return self for Lua chaining. Static methods
 * slerpFlat/multiplyQuaternionsFlat are attached to the class table. fromBufferAttribute
 * receives its IAttributeReader argument via interface cast; onChange (function-callback
 * parameter) is not bound yet.
 */
package three.script.prebind

import three.core.math.*
import three.core._interfaces.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Quaternion 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Quaternion）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Quaternion
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Quaternion)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installQuaternion(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Quaternion")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 4) {
            Quaternion(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue())
        } else {
            Quaternion()
        }
    }
    // ===== 属性 =====
    b.property("x", getter: Some({ref => LuaValue.of(ref.cast<Quaternion>().x)}),
        setter: Some({ref, v => ref.cast<Quaternion>().x = v.numberValue()}))
    b.property("y", getter: Some({ref => LuaValue.of(ref.cast<Quaternion>().y)}),
        setter: Some({ref, v => ref.cast<Quaternion>().y = v.numberValue()}))
    b.property("z", getter: Some({ref => LuaValue.of(ref.cast<Quaternion>().z)}),
        setter: Some({ref, v => ref.cast<Quaternion>().z = v.numberValue()}))
    b.property("w", getter: Some({ref => LuaValue.of(ref.cast<Quaternion>().w)}),
        setter: Some({ref, v => ref.cast<Quaternion>().w = v.numberValue()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref
                .cast<Quaternion>()
                .set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Quaternion>().clone(), "three.core.math.Quaternion")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Quaternion>().copy(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("identity") {
        ref, _ =>
            ref.cast<Quaternion>().identity()
            [LuaValue.Object(ref.id)]
    }
    // ===== 长度/归一化 =====
    b.method("lengthSq") {ref, _ => [LuaValue.of(ref.cast<Quaternion>().lengthSq())]}
    b.method("length") {ref, _ => [LuaValue.of(ref.cast<Quaternion>().length())]}
    b.method("normalize") {
        ref, _ =>
            ref.cast<Quaternion>().normalize()
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Quaternion>().multiplyScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 乘法/共轭/取反 =====
    b.method("multiply") {
        ref, args =>
            ref.cast<Quaternion>().multiply(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("premultiply") {
        ref, args =>
            ref.cast<Quaternion>().premultiply(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyQuaternions") {
        ref, args =>
            ref.cast<Quaternion>().multiplyQuaternions(prebindAs<Quaternion>(args, 0), prebindAs<Quaternion>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("conjugate") {
        ref, _ =>
            ref.cast<Quaternion>().conjugate()
            [LuaValue.Object(ref.id)]
    }
    b.method("invert") {
        ref, _ =>
            ref.cast<Quaternion>().invert()
            [LuaValue.Object(ref.id)]
    }
    b.method("negate") {
        ref, _ =>
            ref.cast<Quaternion>().negate()
            [LuaValue.Object(ref.id)]
    }
    b.method("dot") {
        ref, args => [LuaValue.of(ref.cast<Quaternion>().dot(prebindAs<Quaternion>(args, 0)))]
    }
    // ===== 旋转设置 =====
    b.method("setFromRotationMatrix") {
        ref, args =>
            ref.cast<Quaternion>().setFromRotationMatrix(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromAxisAngle") {
        ref, args =>
            ref.cast<Quaternion>().setFromAxisAngle(prebindAs<Vector3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromEuler") {
        ref, args =>
            ref.cast<Quaternion>().setFromEuler(prebindAs<Euler>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromUnitVectors") {
        ref, args =>
            ref.cast<Quaternion>().setFromUnitVectors(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 插值 =====
    b.method("slerp") {
        ref, args =>
            ref.cast<Quaternion>().slerp(prebindAs<Quaternion>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("slerpQuaternions") {
        ref, args =>
            ref
                .cast<Quaternion>()
                .slerpQuaternions(prebindAs<Quaternion>(args, 0), prebindAs<Quaternion>(args, 1), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 其他操作 =====
    b.method("angleTo") {
        ref, args => [LuaValue.of(ref.cast<Quaternion>().angleTo(prebindAs<Quaternion>(args, 0)))]
    }
    b.method("rotateVector") {
        ref, args => [prebindRegister(ref.cast<Quaternion>().rotateVector(prebindAs<Vector3>(args, 0)),
            "three.core.math.Vector3")]
    }
    b.method("rotateTowards") {
        ref, args =>
            ref.cast<Quaternion>().rotateTowards(prebindAs<Quaternion>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Quaternion>().equals(prebindAs<Quaternion>(args, 0)))]
    }
    b.method("random") {
        ref, _ =>
            ref.cast<Quaternion>().random()
            [LuaValue.Object(ref.id)]
    }
    // ===== 数组/属性读取 =====
    b.method("fromBufferAttribute") {
        ref, args =>
            ref.cast<Quaternion>().fromBufferAttribute(prebindAs<IAttributeReader>(args, 0), args[1].intValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("fromArray") {
        ref, args =>
            ref.cast<Quaternion>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, args =>
            var arr = Array<Float64>(4, {_ => 0.0})
            ref.cast<Quaternion>().toArray(arr, offset: prebindInt(args, 1))
            [LuaValue.of(arr)]
    }
    // ===== 静态方法 =====
    b.staticMethod("slerpFlat") {
        args =>
            Quaternion.slerpFlat(args[0].toArrayFloat(), args[1].intValue(), args[2].toArrayFloat(), args[3].intValue(),
                args[4].toArrayFloat(), args[5].intValue(), args[6].numberValue())
            Array<LuaValue>()
    }
    b.staticMethod("multiplyQuaternionsFlat") {
        args =>
            Quaternion.multiplyQuaternionsFlat(args[0].toArrayFloat(), args[1].intValue(), args[2].toArrayFloat(),
                args[3].intValue(), args[4].toArrayFloat(), args[5].intValue())
            Array<LuaValue>()
    }
    b.install(vm)
}
