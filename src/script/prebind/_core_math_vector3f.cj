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
 * @file[zh-cn] core_math_vector3f Float32 精度 3D 向量 Vector3F 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Vector3F 绑定为 Lua 类型 three.core.math.Vector3F
 * @explain[zh-cn] 覆盖构造（new/无参与三参）、实例方法（set/copy/add/sub/multiply/divide/
 * normalize/lerp/clone/cross/distance/数组互转/与 Vector3 互转等）与属性（x/y/z）。
 * 互变异构方法均返回自身（Lua 链式可用）。数值参数/返回值在 Lua number(Float64) 与
 * Float32 存储之间自动换算。
 *
 * @file[en] core_math_vector3f  Lua binding of the Float32 3D vector Vector3F (three.script.prebind)
 * @brief[en] Binds three.core.math.Vector3F as the Lua type three.core.math.Vector3F
 * @explain[en] Covers construction (new / no-arg / three-arg), instance methods
 * (set/copy/add/sub/multiply/divide/normalize/lerp/clone/cross/distance/array round-trip/
 * Vector3 conversion etc.) and properties (x/y/z). Mutating methods return self for Lua
 * chaining. Numeric arguments/returns are converted between Lua number (Float64) and
 * the internal Float32 storage.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Vector3F 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Vector3F）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Vector3F
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Vector3F)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installVector3F(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Vector3F")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            Vector3F(Float32(args[0].numberValue()), Float32(args[1].numberValue()), Float32(args[2].numberValue()))
        } else {
            Vector3F()
        }
    }
    // ===== 属性 =====
    b.property("x", getter: Some({ref => LuaValue.of(Float64(ref.cast<Vector3F>().x))}),
        setter: Some({ref, v => ref.cast<Vector3F>().x = Float32(v.numberValue())}))
    b.property("y", getter: Some({ref => LuaValue.of(Float64(ref.cast<Vector3F>().y))}),
        setter: Some({ref, v => ref.cast<Vector3F>().y = Float32(v.numberValue())}))
    b.property("z", getter: Some({ref => LuaValue.of(Float64(ref.cast<Vector3F>().z))}),
        setter: Some({ref, v => ref.cast<Vector3F>().z = Float32(v.numberValue())}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref
                .cast<Vector3F>()
                .set(Float32(args[0].numberValue()), Float32(args[1].numberValue()), Float32(args[2].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("setScalar") {
        ref, args =>
            ref.cast<Vector3F>().setScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("setX") {
        ref, args =>
            ref.cast<Vector3F>().setX(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("setY") {
        ref, args =>
            ref.cast<Vector3F>().setY(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("setZ") {
        ref, args =>
            ref.cast<Vector3F>().setZ(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Vector3F>().clone(), "three.core.math.Vector3F")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Vector3F>().copy(prebindAs<Vector3F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 加法 =====
    b.method("add") {
        ref, args =>
            ref.cast<Vector3F>().add(prebindAs<Vector3F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScalar") {
        ref, args =>
            ref.cast<Vector3F>().addScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("addVectors") {
        ref, args =>
            ref.cast<Vector3F>().addVectors(prebindAs<Vector3F>(args, 0), prebindAs<Vector3F>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScaledVector") {
        ref, args =>
            ref.cast<Vector3F>().addScaledVector(prebindAs<Vector3F>(args, 0), Float32(args[1].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 减法 =====
    b.method("sub") {
        ref, args =>
            ref.cast<Vector3F>().sub(prebindAs<Vector3F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("subScalar") {
        ref, args =>
            ref.cast<Vector3F>().subScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("subVectors") {
        ref, args =>
            ref.cast<Vector3F>().subVectors(prebindAs<Vector3F>(args, 0), prebindAs<Vector3F>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 乘法 =====
    b.method("multiply") {
        ref, args =>
            ref.cast<Vector3F>().multiply(prebindAs<Vector3F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Vector3F>().multiplyScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 除法 =====
    b.method("divide") {
        ref, args =>
            ref.cast<Vector3F>().divide(prebindAs<Vector3F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("divideScalar") {
        ref, args =>
            ref.cast<Vector3F>().divideScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 点积/叉积 =====
    b.method("dot") {
        ref, args => [LuaValue.of(Float64(ref.cast<Vector3F>().dot(prebindAs<Vector3F>(args, 0))))]
    }
    b.method("cross") {
        ref, args =>
            ref.cast<Vector3F>().cross(prebindAs<Vector3F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("crossVectors") {
        ref, args =>
            ref.cast<Vector3F>().crossVectors(prebindAs<Vector3F>(args, 0), prebindAs<Vector3F>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 长度 =====
    b.method("lengthSq") {ref, _ => [LuaValue.of(Float64(ref.cast<Vector3F>().lengthSq()))]}
    b.method("length") {ref, _ => [LuaValue.of(Float64(ref.cast<Vector3F>().length()))]}
    // ===== 归一化 =====
    b.method("normalize") {
        ref, _ =>
            ref.cast<Vector3F>().normalize()
            [LuaValue.Object(ref.id)]
    }
    b.method("setLength") {
        ref, args =>
            ref.cast<Vector3F>().setLength(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 距离 =====
    b.method("distanceTo") {
        ref, args => [LuaValue.of(Float64(ref.cast<Vector3F>().distanceTo(prebindAs<Vector3F>(args, 0))))]
    }
    b.method("distanceToSquared") {
        ref, args => [LuaValue.of(Float64(ref.cast<Vector3F>().distanceToSquared(prebindAs<Vector3F>(args, 0))))]
    }
    // ===== 线性插值 =====
    b.method("lerp") {
        ref, args =>
            ref.cast<Vector3F>().lerp(prebindAs<Vector3F>(args, 0), Float32(args[1].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("lerpVectors") {
        ref, args =>
            ref
                .cast<Vector3F>()
                .lerpVectors(prebindAs<Vector3F>(args, 0), prebindAs<Vector3F>(args, 1), Float32(args[2].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 取负 =====
    b.method("negate") {
        ref, _ =>
            ref.cast<Vector3F>().negate()
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Vector3F>().equals(prebindAs<Vector3F>(args, 0)))]
    }
    // ===== 极值 =====
    b.method("min") {
        ref, args =>
            ref.cast<Vector3F>().min(prebindAs<Vector3F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("max") {
        ref, args =>
            ref.cast<Vector3F>().max(prebindAs<Vector3F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 数组操作 =====
    b.method("toArray") {
        ref, _ =>
            let src = ref.cast<Vector3F>().toArray()
            var out = Array<Float64>(src.size, {i => Float64(src[i])})
            [LuaValue.of(out)]
    }
    // ===== 静态方法 =====
    b.staticMethod("fromVector3") {
        args => [prebindRegister(Vector3F.fromVector3(prebindAs<Vector3>(args, 0)), "three.core.math.Vector3F")]
    }
    b.staticMethod("fromArray") {
        args =>
            let fa = args[0].toArrayFloat()
            var f32 = Array<Float32>(fa.size, {i => Float32(fa[i])})
            [prebindRegister(Vector3F.fromArray(f32), "three.core.math.Vector3F")]
    }
    b.install(vm)
}
