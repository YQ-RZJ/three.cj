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
 * @file[zh-cn] core_math_color RGB 颜色 Color 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Color 绑定为 Lua 类型 three.core.math.Color
 * @explain[zh-cn] 覆盖构造（new/无参与三参/hex 单参）、实例方法（set/setHex/setRGB/setHSL/
 * setStyle/clone/copy/getHex/getHexString/getHSL/getRGB/getStyle/颜色空间换算/运算/数组互转
 * 等）与属性（r/g/b）。colorSpace 可选参数缺省时使用引擎默认常量
 * （SRGBColorSpace 或 ColorManagement.workingColorSpace）。getHSL 支持两种形态：
 * 无参与传 target（返回 (h,s,l) 三元组或目标对象）。运算符重载以 __add/__mul 方法形式暴露
 * （仅程序性调用，不接 Lua 元表）。静态 NAMES（CSS 色名表）类型为 HashMap 无法转 LuaValue，
 * 未绑定。
 *
 * @file[en] core_math_color  Lua binding of the RGB color Color (three.script.prebind)
 * @brief[en] Binds three.core.math.Color as the Lua type three.core.math.Color
 * @explain[en] Covers construction (new / no-arg / three-arg / hex one-arg), instance
 * methods (set/setHex/setRGB/setHSL/setStyle/clone/copy/getHex/getHexString/getHSL/
 * getRGB/getStyle/color-space conversion/arithmetic/array round-trip etc.) and properties
 * (r/g/b). Omitted optional colorSpace arguments fall back to the engine default
 * (SRGBColorSpace or ColorManagement.workingColorSpace). getHSL supports two forms:
 * without args and with a target (returns the (h,s,l) triple or the target object).
 * Operator overloads are exposed as __add/__mul methods (callable only; Lua metamethods
 * are not wired). The static NAMES (CSS color name table) is of type HashMap and cannot
 * be converted to a LuaValue, so it is not bound.
 */
package three.script.prebind

import three.core.math.*
import three.core._interfaces.*
import three.utils.constants.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Color 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Color）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Color
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Color)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installColor(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Color")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            Color(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
        } else if (args.size == 1) {
            Color(UInt32(args[0].numberValue()))
        } else {
            Color()
        }
    }
    // ===== 属性 =====
    b.property("r", getter: Some({ref => LuaValue.of(ref.cast<Color>().r)}),
        setter: Some({ref, v => ref.cast<Color>().r = v.numberValue()}))
    b.property("g", getter: Some({ref => LuaValue.of(ref.cast<Color>().g)}),
        setter: Some({ref, v => ref.cast<Color>().g = v.numberValue()}))
    b.property("b", getter: Some({ref => LuaValue.of(ref.cast<Color>().b)}),
        setter: Some({ref, v => ref.cast<Color>().b = v.numberValue()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Color>().set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setScalar") {
        ref, args =>
            ref.cast<Color>().setScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setHex") {
        ref, args =>
            let cs = if (args.size > 1) {
                args[1].stringValue()
            } else {
                SRGBColorSpace
            }
            ref.cast<Color>().setHex(UInt32(args[0].numberValue()), colorSpace: cs)
            [LuaValue.Object(ref.id)]
    }
    b.method("setRGB") {
        ref, args =>
            let cs = if (args.size > 3) {
                args[3].stringValue()
            } else {
                ColorManagement.workingColorSpace
            }
            ref.cast<Color>().setRGB(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), colorSpace: cs)
            [LuaValue.Object(ref.id)]
    }
    b.method("setHSL") {
        ref, args =>
            let cs = if (args.size > 3) {
                args[3].stringValue()
            } else {
                ColorManagement.workingColorSpace
            }
            ref.cast<Color>().setHSL(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), colorSpace: cs)
            [LuaValue.Object(ref.id)]
    }
    b.method("setStyle") {
        ref, args =>
            let cs = if (args.size > 1) {
                args[1].stringValue()
            } else {
                SRGBColorSpace
            }
            ref.cast<Color>().setStyle(args[0].stringValue(), colorSpace: cs)
            [LuaValue.Object(ref.id)]
    }
    b.method("setColorName") {
        ref, args =>
            let cs = if (args.size > 1) {
                args[1].stringValue()
            } else {
                SRGBColorSpace
            }
            ref.cast<Color>().setColorName(args[0].stringValue(), colorSpace: cs)
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Color>().clone(), "three.core.math.Color")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Color>().copy(prebindAs<Color>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 颜色空间 =====
    b.method("copySRGBToLinear") {
        ref, args =>
            ref.cast<Color>().copySRGBToLinear(prebindAs<Color>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("copyLinearToSRGB") {
        ref, args =>
            ref.cast<Color>().copyLinearToSRGB(prebindAs<Color>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("convertSRGBToLinear") {
        ref, _ =>
            ref.cast<Color>().convertSRGBToLinear()
            [LuaValue.Object(ref.id)]
    }
    b.method("convertLinearToSRGB") {
        ref, _ =>
            ref.cast<Color>().convertLinearToSRGB()
            [LuaValue.Object(ref.id)]
    }
    // ===== 查询 =====
    b.method("getHex") {
        ref, args =>
            let cs = if (args.size > 0) {
                args[0].stringValue()
            } else {
                SRGBColorSpace
            }
            [LuaValue.of(Int64(ref.cast<Color>().getHex(colorSpace: cs)))]
    }
    b.method("getHexString") {
        ref, args =>
            let cs = if (args.size > 0) {
                args[0].stringValue()
            } else {
                SRGBColorSpace
            }
            [LuaValue.of(ref.cast<Color>().getHexString(colorSpace: cs))]
    }
    b.method("getHSL") {
        ref, args => if (args.size > 0 && args[0].isObject) {
            // 有 target：写入目标 HSL 对象并返回它
            let target = prebindAs<HSL>(args, 0)
            let cs = if (args.size > 1) {
                args[1].stringValue()
            } else {
                ColorManagement.workingColorSpace
            }
            ref.cast<Color>().getHSL(target, colorSpace: cs)
            [LuaValue.Object(args[0].objectId())]
        } else {
            // 无参与：返回 (h, s, l) 三元组（Lua 多返回值）
            let (h, s, l) = ref.cast<Color>().getHSL()
            [LuaValue.of(h), LuaValue.of(s), LuaValue.of(l)]
        }
    }
    b.method("getRGB") {
        ref, args =>
            let target = prebindAs<Color>(args, 0)
            let cs = if (args.size > 1) {
                args[1].stringValue()
            } else {
                ColorManagement.workingColorSpace
            }
            ref.cast<Color>().getRGB(target, colorSpace: cs)
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("getStyle") {
        ref, args =>
            let cs = if (args.size > 0) {
                args[0].stringValue()
            } else {
                SRGBColorSpace
            }
            [LuaValue.of(ref.cast<Color>().getStyle(colorSpace: cs))]
    }
    // ===== HSL 偏移 =====
    b.method("offsetHSL") {
        ref, args =>
            ref.cast<Color>().offsetHSL(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 运算 =====
    b.method("add") {
        ref, args =>
            ref.cast<Color>().add(prebindAs<Color>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addColors") {
        ref, args =>
            ref.cast<Color>().addColors(prebindAs<Color>(args, 0), prebindAs<Color>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScalar") {
        ref, args =>
            ref.cast<Color>().addScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("sub") {
        ref, args =>
            ref.cast<Color>().sub(prebindAs<Color>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiply") {
        ref, args =>
            ref.cast<Color>().multiply(prebindAs<Color>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Color>().multiplyScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("lerp") {
        ref, args =>
            ref.cast<Color>().lerp(prebindAs<Color>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("lerpColors") {
        ref, args =>
            ref.cast<Color>().lerpColors(prebindAs<Color>(args, 0), prebindAs<Color>(args, 1), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("lerpHSL") {
        ref, args =>
            ref.cast<Color>().lerpHSL(prebindAs<Color>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 向量/矩阵 =====
    b.method("setFromVector3") {
        ref, args =>
            ref.cast<Color>().setFromVector3(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyMatrix3") {
        ref, args =>
            ref.cast<Color>().applyMatrix3(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Color>().equals(prebindAs<Color>(args, 0)))]
    }
    // ===== 顶点属性/数组 =====
    b.method("fromBufferAttribute") {
        ref, args =>
            ref.cast<Color>().fromBufferAttribute(prebindAs<IAttributeReader>(args, 0), args[1].intValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("fromArray") {
        ref, args =>
            ref.cast<Color>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, _ =>
            var arr = Array<Float64>(3, {_ => 0.0})
            ref.cast<Color>().toArray(arr)
            [LuaValue.of(arr)]
    }
    b.method("copyHex") {
        ref, args =>
            ref.cast<Color>().copyHex(UInt32(args[0].numberValue()))
            [LuaValue.Object(ref.id)]
    }
    b.method("copyColorSpace") {
        ref, args =>
            ref.cast<Color>().copyColorSpace(prebindAs<Color>(args, 0), args[1].stringValue(), args[2].stringValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 运算符（程序性调用） =====
    b.method("__add") {
        ref, args => [prebindRegister(ref.cast<Color>() + prebindAs<Color>(args, 0), "three.core.math.Color")]
    }
    b.method("__mul") {
        ref, args => [prebindRegister(ref.cast<Color>() * args[0].numberValue(), "three.core.math.Color")]
    }
    b.install(vm)
}
