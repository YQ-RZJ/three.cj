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
 * @file[zh-cn] core_math_sphericalharmonics3 球面调和系数 SphericalHarmonics3 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.SphericalHarmonics3 绑定为 Lua 类型
 * three.core.math.SphericalHarmonics3
 * @explain[zh-cn] 覆盖构造（new）、实例方法（zero/getAt/getIrradianceAt/add/addScaledSH/
 * scale/lerp/equals/copy/clone/fromArray/toArray）、静态方法（getBasisAt）与属性
 * coefficients（Lua 表 ↔ Array<Vector3>，读写）。互变异构方法均返回自身（Lua 链式
 * 可用）。getAt/getIrradianceAt 按参数个数分派无参与 target 两版；toArray 创建长度
 * 27 的新数组在 Lua 侧返回；getBasisAt 的输出数组以返回值形式暴露。set（Array<Vector3>
 * 对象数组容器）暂不绑定。
 *
 * @file[en] core_math_sphericalharmonics3 Lua binding of the spherical-harmonics
 * coefficients SphericalHarmonics3 (three.script.prebind)
 * @brief[en] Binds three.core.math.SphericalHarmonics3 as the Lua type
 * three.core.math.SphericalHarmonics3
 * @explain[en] Covers construction (new), instance methods (zero/getAt/getIrradianceAt/
 * add/addScaledSH/scale/lerp/equals/copy/clone/fromArray/toArray), the static
 * getBasisAt and the property coefficients (Lua table ↔ Array<Vector3>, read-write).
 * Mutating methods return self for Lua chaining. getAt/getIrradianceAt dispatch between
 * the no-arg and target versions by argument count; toArray creates a new 27-element
 * array returned on the Lua side; set (Array<Vector3> container) is bound through the
 * object-array channel (luaVec3Array).
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SphericalHarmonics3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.SphericalHarmonics3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SphericalHarmonics3
 * @param[en] vm The target virtual machine (class table installed at three.core.math.SphericalHarmonics3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSphericalHarmonics3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.SphericalHarmonics3")
    // ===== 构造（仅无参） =====
    b.constructor {
        _ => SphericalHarmonics3()
    }
    // ===== 属性 =====
    b.property(
        "coefficients",
        getter: Some(
            {
                ref =>
                    let src = ref.cast<SphericalHarmonics3>().coefficients
                    let arr = Array<LuaValue>(src.size, {i => prebindRegister(src[i], "three.core.math.Vector3")})
                    LuaValue.of(arr)
            }
        ),
        setter: Some(
            {
                ref, v =>
                    let vals = v.arrayValues()
                    let arr = Array<Vector3>(vals.size, {i => LuaObjectRegistry.getAs<Vector3>(vals[i].objectId())})
                    ref.cast<SphericalHarmonics3>().coefficients = arr
            }
        )
    )
    // ===== 归零 =====
    b.method("zero") {
        ref, _ =>
            ref.cast<SphericalHarmonics3>().zero()
            [LuaValue.Object(ref.id)]
    }
    // getAt(normal) / getAt(normal, target)
    b.method("getAt") {
        ref, args =>
            let v = ref.cast<SphericalHarmonics3>()
            if (args.size >= 2) {
                v.getAt(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
                [LuaValue.Object(args[1].objectId())]
            } else {
                [prebindRegister(v.getAt(prebindAs<Vector3>(args, 0)), "three.core.math.Vector3")]
            }
    }
    // getIrradianceAt(normal) / getIrradianceAt(normal, target)
    b.method("getIrradianceAt") {
        ref, args =>
            let v = ref.cast<SphericalHarmonics3>()
            if (args.size >= 2) {
                v.getIrradianceAt(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
                [LuaValue.Object(args[1].objectId())]
            } else {
                [prebindRegister(v.getIrradianceAt(prebindAs<Vector3>(args, 0)), "three.core.math.Vector3")]
            }
    }
    // ===== 加法/缩放/插值 =====
    b.method("add") {
        ref, args =>
            ref.cast<SphericalHarmonics3>().add(prebindAs<SphericalHarmonics3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScaledSH") {
        ref, args =>
            ref.cast<SphericalHarmonics3>().addScaledSH(prebindAs<SphericalHarmonics3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("scale") {
        ref, args =>
            ref.cast<SphericalHarmonics3>().scale(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("lerp") {
        ref, args =>
            ref.cast<SphericalHarmonics3>().lerp(prebindAs<SphericalHarmonics3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较/复制 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<SphericalHarmonics3>().equals(prebindAs<SphericalHarmonics3>(args, 0)))]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<SphericalHarmonics3>().copy(prebindAs<SphericalHarmonics3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<SphericalHarmonics3>().clone(), "three.core.math.SphericalHarmonics3")]
    }
    // ===== 数组操作 =====
    b.method("fromArray") {
        ref, args =>
            ref.cast<SphericalHarmonics3>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, args =>
            var arr = Array<Float64>(27, {_ => 0.0})
            ref.cast<SphericalHarmonics3>().toArray(arr, offset: prebindInt(args, 0))
            [LuaValue.of(arr)]
    }
    b.method("set") {
        ref, args =>
            ref.cast<SphericalHarmonics3>().set(luaVec3Array(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 静态：基函数 =====
    b.staticMethod("getBasisAt") {
        args =>
            var arr = Array<Float64>(9, {_ => 0.0})
            SphericalHarmonics3.getBasisAt(prebindAs<Vector3>(args, 0), arr)
            [LuaValue.of(arr)]
    }
    b.install(vm)
}
