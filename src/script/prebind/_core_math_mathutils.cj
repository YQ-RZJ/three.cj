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
 * @file[zh-cn] core_math_mathutils 数学工具 MathUtils 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.MathUtils 绑定为 Lua 命名空间 three.core.math.MathUtils
 * @explain[zh-cn] MathUtils 是纯静态工具类（无构造器），本绑定只注册 staticMethod、
 * 不定义 constructor 也不安装 new。公共常量 PI/LN2/DEG2RAD/RAD2DEG 以 getter 式
 * 静态方法暴露；euclideanModulo 的 Int64/Int64 与 Float64/Float64 重载经 Lua 数值
 * 统一走 Float64 语义（整数输入两者结果一致）。
 *
 * @file[en] core_math_mathutils  Lua binding of the math utilities MathUtils (three.script.prebind)
 * @brief[en] Binds three.core.math.MathUtils as the Lua namespace three.core.math.MathUtils
 * @explain[en] MathUtils is a pure static utility class (no constructor); this binding
 * registers staticMethod only, without a constructor (no `new`). The public constants
 * PI/LN2/DEG2RAD/RAD2DEG are exposed as getter-style static methods; the Int64/Int64
 * and Float64/Float64 overloads of euclideanModulo collapse to the Float64 semantics
 * under Lua numbers (identical results for integer inputs).
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MathUtils 的 Lua 绑定（纯静态类，无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.core.math.MathUtils）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MathUtils (a pure static class; no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.core.math.MathUtils)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMathUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.MathUtils")
    // ===== 常量（getter 式静态方法） =====
    b.staticMethod("PI") {_ => [LuaValue.of(PI)]}
    b.staticMethod("LN2") {_ => [LuaValue.of(LN2)]}
    b.staticMethod("DEG2RAD") {_ => [LuaValue.of(DEG2RAD)]}
    b.staticMethod("RAD2DEG") {_ => [LuaValue.of(RAD2DEG)]}
    // ===== 基础数值工具 =====
    b.staticMethod("clamp") {
        args => [LuaValue.of(MathUtils.clamp(args[0].numberValue(), args[1].numberValue(), args[2].numberValue()))]
    }
    b.staticMethod("euclideanModulo") {
        args =>
        // Int64/Float64 重载统一走 Float64 版本（Lua 数值为 double；整数输入结果一致）
        [LuaValue.of(MathUtils.euclideanModulo(args[0].numberValue(), args[1].numberValue()))]
    }
    b.staticMethod("mapLinear") {
        args => [LuaValue.of(
            MathUtils.mapLinear(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(),
                args[3].numberValue(), args[4].numberValue()))]
    }
    b.staticMethod("inverseLerp") {
        args => [LuaValue.of(MathUtils.inverseLerp(args[0].numberValue(), args[1].numberValue(), args[2].numberValue()))]
    }
    b.staticMethod("lerp") {
        args => [LuaValue.of(MathUtils.lerp(args[0].numberValue(), args[1].numberValue(), args[2].numberValue()))]
    }
    b.staticMethod("damp") {
        args => [LuaValue.of(
            MathUtils.damp(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue()))]
    }
    b.staticMethod("pingpong") {
        args => [LuaValue.of(MathUtils.pingpong(args[0].numberValue(), length: prebindNum(args, 1, default: 1.0)))]
    }
    // ===== 平滑插值 =====
    b.staticMethod("smoothstep") {
        args => [LuaValue.of(MathUtils.smoothstep(args[0].numberValue(), args[1].numberValue(), args[2].numberValue()))]
    }
    b.staticMethod("smootherstep") {
        args => [LuaValue.of(MathUtils.smootherstep(args[0].numberValue(), args[1].numberValue(), args[2].numberValue()))]
    }
    // ===== 随机数 =====
    b.staticMethod("randInt") {
        args => [LuaValue.of(MathUtils.randInt(args[0].intValue(), args[1].intValue()))]
    }
    b.staticMethod("randFloat") {
        args => [LuaValue.of(MathUtils.randFloat(args[0].numberValue(), args[1].numberValue()))]
    }
    b.staticMethod("randFloatSpread") {
        args => [LuaValue.of(MathUtils.randFloatSpread(args[0].numberValue()))]
    }
    b.staticMethod("seededRandom") {
        args => if (args.size > 0) {
            [LuaValue.of(MathUtils.seededRandom(s: Some(args[0].intValue())))]
        } else {
            [LuaValue.of(MathUtils.seededRandom())]
        }
    }
    // ===== 角度换算 =====
    b.staticMethod("degToRad") {
        args => [LuaValue.of(MathUtils.degToRad(args[0].numberValue()))]
    }
    b.staticMethod("radToDeg") {
        args => [LuaValue.of(MathUtils.radToDeg(args[0].numberValue()))]
    }
    // ===== 2 的幂 =====
    b.staticMethod("isPowerOfTwo") {
        args => [LuaValue.of(MathUtils.isPowerOfTwo(args[0].intValue()))]
    }
    b.staticMethod("ceilPowerOfTwo") {
        args => [LuaValue.of(MathUtils.ceilPowerOfTwo(args[0].intValue()))]
    }
    b.staticMethod("floorPowerOfTwo") {
        args => [LuaValue.of(MathUtils.floorPowerOfTwo(args[0].intValue()))]
    }
    // ===== UUID =====
    b.staticMethod("generateUUID") {
        _ => [LuaValue.of(MathUtils.generateUUID())]
    }
    // ===== 从欧拉角设置四元数 =====
    b.staticMethod("setQuaternionFromProperEuler") {
        args =>
            MathUtils.setQuaternionFromProperEuler(prebindAs<Quaternion>(args, 0), args[1].numberValue(),
                args[2].numberValue(), args[3].numberValue(), args[4].stringValue())
            Array<LuaValue>()
    }
    // ===== 归一化/反归一化 =====
    b.staticMethod("denormalize") {
        args => [LuaValue.of(MathUtils.denormalize(args[0].numberValue(), args[1].intValue()))]
    }
    b.staticMethod("normalize") {
        args => [LuaValue.of(MathUtils.normalize(args[0].numberValue(), args[1].intValue()))]
    }
    b.install(vm)
}
