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
 * @file[zh-cn] core_math_vector4f Float32 精度 4D 向量 Vector4F 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Vector4F 绑定为 Lua 类型 three.core.math.Vector4F
 * @explain[zh-cn] 覆盖构造（new/无参与四参）、实例方法（set/copy/add/sub/multiply/
 * normalize/lerp/clone/数组互转等）与属性（x/y/z/w）。互变异构方法均返回自身
 * （Lua 链式可用）。数值参数/返回值在 Lua number(Float64) 与 Float32 存储之间自动换算。
 *
 * @file[en] core_math_vector4f  Lua binding of the Float32 4D vector Vector4F (three.script.prebind)
 * @brief[en] Binds three.core.math.Vector4F as the Lua type three.core.math.Vector4F
 * @explain[en] Covers construction (new / no-arg / four-arg), instance methods
 * (set/copy/add/sub/multiply/normalize/lerp/clone/array round-trip etc.) and properties
 * (x/y/z/w). Mutating methods return self for Lua chaining. Numeric arguments/returns
 * are converted between Lua number (Float64) and the internal Float32 storage.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Vector4F 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Vector4F）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Vector4F
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Vector4F)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installVector4F(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Vector4F")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 4) {
            Vector4F(Float32(args[0].numberValue()), Float32(args[1].numberValue()), Float32(args[2].numberValue()),
                Float32(args[3].numberValue()))
        } else {
            Vector4F()
        }
    }
    // ===== 属性 =====
    b.property("x", getter: Some({ref => LuaValue.of(Float64(ref.cast<Vector4F>().x))}),
        setter: Some({ref, v => ref.cast<Vector4F>().x = Float32(v.numberValue())}))
    b.property("y", getter: Some({ref => LuaValue.of(Float64(ref.cast<Vector4F>().y))}),
        setter: Some({ref, v => ref.cast<Vector4F>().y = Float32(v.numberValue())}))
    b.property("z", getter: Some({ref => LuaValue.of(Float64(ref.cast<Vector4F>().z))}),
        setter: Some({ref, v => ref.cast<Vector4F>().z = Float32(v.numberValue())}))
    b.property("w", getter: Some({ref => LuaValue.of(Float64(ref.cast<Vector4F>().w))}),
        setter: Some({ref, v => ref.cast<Vector4F>().w = Float32(v.numberValue())}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref
                .cast<Vector4F>()
                .set(Float32(args[0].numberValue()), Float32(args[1].numberValue()), Float32(args[2].numberValue()),
                    Float32(args[3].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("setScalar") {
        ref, args =>
            ref.cast<Vector4F>().setScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Vector4F>().clone(), "three.core.math.Vector4F")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Vector4F>().copy(prebindAs<Vector4F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 加法 =====
    b.method("add") {
        ref, args =>
            ref.cast<Vector4F>().add(prebindAs<Vector4F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScalar") {
        ref, args =>
            ref.cast<Vector4F>().addScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 减法 =====
    b.method("sub") {
        ref, args =>
            ref.cast<Vector4F>().sub(prebindAs<Vector4F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("subScalar") {
        ref, args =>
            ref.cast<Vector4F>().subScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 乘法 =====
    b.method("multiply") {
        ref, args =>
            ref.cast<Vector4F>().multiply(prebindAs<Vector4F>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Vector4F>().multiplyScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("divideScalar") {
        ref, args =>
            ref.cast<Vector4F>().divideScalar(Float32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 点积 =====
    b.method("dot") {
        ref, args => [LuaValue.of(Float64(ref.cast<Vector4F>().dot(prebindAs<Vector4F>(args, 0))))]
    }
    // ===== 长度 =====
    b.method("lengthSq") {ref, _ => [LuaValue.of(Float64(ref.cast<Vector4F>().lengthSq()))]}
    b.method("length") {ref, _ => [LuaValue.of(Float64(ref.cast<Vector4F>().length()))]}
    // ===== 归一化 =====
    b.method("normalize") {
        ref, _ =>
            ref.cast<Vector4F>().normalize()
            [LuaValue.Object(ref.id)]
    }
    // ===== 线性插值 =====
    b.method("lerp") {
        ref, args =>
            ref.cast<Vector4F>().lerp(prebindAs<Vector4F>(args, 0), Float32(args[1].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 取负 =====
    b.method("negate") {
        ref, _ =>
            ref.cast<Vector4F>().negate()
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Vector4F>().equals(prebindAs<Vector4F>(args, 0)))]
    }
    // ===== 数组操作 =====
    b.method("toArray") {
        ref, _ =>
            let src = ref.cast<Vector4F>().toArray()
            var out = Array<Float64>(src.size, {i => Float64(src[i])})
            [LuaValue.of(out)]
    }
    // ===== 静态方法 =====
    b.staticMethod("fromArray") {
        args =>
            let fa = args[0].toArrayFloat()
            var f32 = Array<Float32>(fa.size, {i => Float32(fa[i])})
            [prebindRegister(Vector4F.fromArray(f32), "three.core.math.Vector4F")]
    }
    b.install(vm)
}
