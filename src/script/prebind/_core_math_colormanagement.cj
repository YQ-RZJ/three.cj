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
 * @file[zh-cn] core_math_colormanagement 颜色空间管理的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math 下的 ColorManagement / ColorSpaceDefinition /
 * ColorSpaceWorkingConfig / ColorSpaceOutputConfig 绑定为 Lua 类型
 * @explain[zh-cn] ColorManagement 为纯静态类：静态属性以 get/set 静态方法暴露
 * （getEnabled/setEnabled、getWorkingColorSpace/setWorkingColorSpace），
 * 预定义矩阵常量返回 Matrix3 副本，原色/亮度/D65 常量返回 Float64 数组；
 * 颜色转换类静态方法（convert / workingToColorSpace / colorSpaceToWorking /
 * fromWorkingColorSpace / toWorkingColorSpace）就地修改并返回传入的颜色对象。
 * spaces（HashMap）与 define（HashMap 参数）缺少「Lua 表 ↔ HashMap」通道，暂不绑定。
 * ColorSpaceDefinition 的 toXYZ / fromXYZ 读取返回 Matrix3 副本（无对象→id 反查
 * 通道），写入接受 Matrix3 对象；可选配置读取返回快照副本。
 *
 * @file[en] core_math_colormanagement Lua binding of color-space management
 * (three.script.prebind)
 * @brief[en] Binds ColorManagement / ColorSpaceDefinition / ColorSpaceWorkingConfig /
 * ColorSpaceOutputConfig from three.core.math as Lua types
 * @explain[en] ColorManagement is purely static: its static properties are exposed as
 * get/set static methods (getEnabled/setEnabled, getWorkingColorSpace/
 * setWorkingColorSpace); the predefined matrix constants return Matrix3 copies while
 * the primaries/luminance/D65 constants return Float64 arrays. The conversion static
 * methods (convert / workingToColorSpace / colorSpaceToWorking / fromWorkingColorSpace /
 * toWorkingColorSpace) mutate the passed color in place and return it.
 * spaces (HashMap) and define (HashMap parameter) stay unbound because there is no
 * "Lua table ↔ HashMap" channel yet. ColorSpaceDefinition reads of toXYZ / fromXYZ
 * return Matrix3 copies (no object→id reverse lookup channel) while writes accept
 * Matrix3 objects; optional config reads return snapshot copies.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ColorManagement 的 Lua 绑定（纯静态类，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.core.math.ColorManagement）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ColorManagement (static-only class, no constructor)
 * @param[en] vm The target virtual machine (namespace table installed at
 *            three.core.math.ColorManagement)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installColorManagement(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.ColorManagement")
    // ===== 静态属性（以 get/set 静态方法暴露）=====
    b.staticMethod("getEnabled") {_ => [LuaValue.of(ColorManagement.enabled)]}
    b.staticMethod("setEnabled") {
        args =>
            ColorManagement.enabled = prebindBool(args, 0)
            []
    }
    b.staticMethod("getWorkingColorSpace") {_ => [LuaValue.of(ColorManagement.workingColorSpace)]}
    b.staticMethod("setWorkingColorSpace") {
        args =>
            ColorManagement.workingColorSpace = prebindStr(args, 0, default: ColorManagement.workingColorSpace)
            []
    }
    // ===== 注册默认颜色空间 =====
    b.staticMethod("initDefaults") {
        _ =>
            ColorManagement.initDefaults()
            []
    }
    // ===== 预定义矩阵常量（返回副本，避免 Lua 侧改动引擎常量）=====
    b.staticMethod("LINEAR_REC709_TO_XYZ") {
        _ => [prebindRegister(ColorManagement.LINEAR_REC709_TO_XYZ.clone(), "three.core.math.Matrix3")]
    }
    b.staticMethod("XYZ_TO_LINEAR_REC709") {
        _ => [prebindRegister(ColorManagement.XYZ_TO_LINEAR_REC709.clone(), "three.core.math.Matrix3")]
    }
    // ===== 原色 / 亮度 / 白点常量 =====
    b.staticMethod("REC709_PRIMARIES") {_ => [LuaValue.of(ColorManagement.REC709_PRIMARIES)]}
    b.staticMethod("REC709_LUMINANCE_COEFFICIENTS") {
        _ => [LuaValue.of(ColorManagement.REC709_LUMINANCE_COEFFICIENTS)]
    }
    b.staticMethod("D65") {_ => [LuaValue.of(ColorManagement.D65)]}
    // ===== 颜色转换（就地修改并返回传入的颜色对象）=====
    b.staticMethod("convert") {
        args =>
            ColorManagement.convert(prebindAs<Color>(args, 0), prebindStr(args, 1), prebindStr(args, 2))
            [LuaValue.Object(args[0].objectId())]
    }
    b.staticMethod("workingToColorSpace") {
        args =>
            ColorManagement.workingToColorSpace(prebindAs<Color>(args, 0), prebindStr(args, 1))
            [LuaValue.Object(args[0].objectId())]
    }
    b.staticMethod("colorSpaceToWorking") {
        args =>
            ColorManagement.colorSpaceToWorking(prebindAs<Color>(args, 0), prebindStr(args, 1))
            [LuaValue.Object(args[0].objectId())]
    }
    b.staticMethod("fromWorkingColorSpace") {
        args =>
            ColorManagement.fromWorkingColorSpace(prebindAs<Color>(args, 0), prebindStr(args, 1))
            [LuaValue.Object(args[0].objectId())]
    }
    b.staticMethod("toWorkingColorSpace") {
        args =>
            ColorManagement.toWorkingColorSpace(prebindAs<Color>(args, 0), prebindStr(args, 1))
            [LuaValue.Object(args[0].objectId())]
    }
    // ===== 颜色空间查询 =====
    b.staticMethod("getPrimaries") {
        args => [LuaValue.of(ColorManagement.getPrimaries(prebindStr(args, 0)))]
    }
    b.staticMethod("getTransfer") {
        args => [LuaValue.of(ColorManagement.getTransfer(prebindStr(args, 0)))]
    }
    b.staticMethod("getToneMappingMode") {
        args => [LuaValue.of(ColorManagement.getToneMappingMode(prebindStr(args, 0)))]
    }
    b.staticMethod("getDrawingBufferColorSpace") {
        args => [LuaValue.of(ColorManagement.getDrawingBufferColorSpace(prebindStr(args, 0)))]
    }
    b.staticMethod("getUnpackColorSpace") {
        args => [LuaValue.of(
            ColorManagement.getUnpackColorSpace(
                colorSpace: prebindStr(args, 0, default: ColorManagement.workingColorSpace)))]
    }
    b.staticMethod("getLuminanceCoefficients") {
        args =>
            ColorManagement.getLuminanceCoefficients(prebindAs<Vector3>(args, 0),
                colorSpace: prebindStr(args, 1, default: ColorManagement.workingColorSpace))
            [LuaValue.Object(args[0].objectId())]
    }
    b.staticMethod("getMatrix") {
        args =>
            ColorManagement.getMatrix(prebindAs<Matrix3>(args, 0), prebindStr(args, 1), prebindStr(args, 2))
            [LuaValue.Object(args[0].objectId())]
    }
    // ===== 传输函数 =====
    b.staticMethod("sRGBToLinear") {
        args => [LuaValue.of(ColorManagement.sRGBToLinear(args[0].numberValue()))]
    }
    b.staticMethod("linearToSRGB") {
        args => [LuaValue.of(ColorManagement.linearToSRGB(args[0].numberValue()))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ColorSpaceDefinition 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.ColorSpaceDefinition）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ColorSpaceDefinition
 * @param[en] vm The target virtual machine (class table installed at
 *            three.core.math.ColorSpaceDefinition)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installColorSpaceDefinition(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.ColorSpaceDefinition")
    // ===== 构造：primaries, whitePoint, transfer, toXYZ, fromXYZ, luminanceCoefficients,
    //              [workingColorSpaceConfig], [outputColorSpaceConfig] =====
    b.constructor {
        args =>
            let wc: ?ColorSpaceWorkingConfig = if (args.size > 6 && !args[6].isNil) {
                Some(prebindAs<ColorSpaceWorkingConfig>(args, 6))
            } else {
                None
            }
            let oc: ?ColorSpaceOutputConfig = if (args.size > 7 && !args[7].isNil) {
                Some(prebindAs<ColorSpaceOutputConfig>(args, 7))
            } else {
                None
            }
            ColorSpaceDefinition(prebindFloatArray(vm, args, 0), prebindFloatArray(vm, args, 1), prebindStr(args, 2),
                prebindAs<Matrix3>(args, 3), prebindAs<Matrix3>(args, 4), prebindFloatArray(vm, args, 5),
                workingColorSpaceConfig: wc, outputColorSpaceConfig: oc)
    }
    // ===== 属性 =====
    b.property("primaries", getter: Some({ref => LuaValue.of(ref.cast<ColorSpaceDefinition>().primaries)}),
        setter: Some({ref, v => ref.cast<ColorSpaceDefinition>().primaries = v.toArrayFloat()}))
    b.property("whitePoint", getter: Some({ref => LuaValue.of(ref.cast<ColorSpaceDefinition>().whitePoint)}),
        setter: Some({ref, v => ref.cast<ColorSpaceDefinition>().whitePoint = v.toArrayFloat()}))
    b.property("transfer", getter: Some({ref => LuaValue.of(ref.cast<ColorSpaceDefinition>().transfer)}),
        setter: Some({ref, v => ref.cast<ColorSpaceDefinition>().transfer = v.stringValue()}))
    b.property("toXYZ", getter: Some({
        ref => prebindRegister(ref.cast<ColorSpaceDefinition>().toXYZ.clone(), "three.core.math.Matrix3")
    }), setter: Some({ref, v => ref.cast<ColorSpaceDefinition>().toXYZ = prebindAsValue<Matrix3>(v)}))
    b.property("fromXYZ", getter: Some({
        ref => prebindRegister(ref.cast<ColorSpaceDefinition>().fromXYZ.clone(), "three.core.math.Matrix3")
    }), setter: Some({ref, v => ref.cast<ColorSpaceDefinition>().fromXYZ = prebindAsValue<Matrix3>(v)}))
    b.property("luminanceCoefficients",
        getter: Some({ref => LuaValue.of(ref.cast<ColorSpaceDefinition>().luminanceCoefficients)}),
        setter: Some({ref, v => ref.cast<ColorSpaceDefinition>().luminanceCoefficients = v.toArrayFloat()}))
    b.property(
        "workingColorSpaceConfig",
        getter: Some({
            ref => match (ref.cast<ColorSpaceDefinition>().workingColorSpaceConfig) {
                case Some(c) => prebindRegister(ColorSpaceWorkingConfig(c.unpackColorSpace),
                    "three.core.math.ColorSpaceWorkingConfig")
                case None => LuaValue.Nil
            }
        }),
        setter: Some(
            {
                ref, v =>
                    let value: ?ColorSpaceWorkingConfig = if (v.isNil) {
                        None
                    } else {
                        Some(prebindAsValue<ColorSpaceWorkingConfig>(v))
                    }
                    ref.cast<ColorSpaceDefinition>().workingColorSpaceConfig = value
            }
        )
    )
    b.property(
        "outputColorSpaceConfig",
        getter: Some({
            ref => match (ref.cast<ColorSpaceDefinition>().outputColorSpaceConfig) {
                case Some(c) => prebindRegister(
                    ColorSpaceOutputConfig(c.drawingBufferColorSpace, toneMappingMode: c.toneMappingMode),
                    "three.core.math.ColorSpaceOutputConfig")
                case None => LuaValue.Nil
            }
        }),
        setter: Some(
            {
                ref, v =>
                    let value: ?ColorSpaceOutputConfig = if (v.isNil) {
                        None
                    } else {
                        Some(prebindAsValue<ColorSpaceOutputConfig>(v))
                    }
                    ref.cast<ColorSpaceDefinition>().outputColorSpaceConfig = value
            }
        )
    )
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ColorSpaceWorkingConfig 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.ColorSpaceWorkingConfig）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ColorSpaceWorkingConfig
 * @param[en] vm The target virtual machine (class table installed at
 *            three.core.math.ColorSpaceWorkingConfig)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installColorSpaceWorkingConfig(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.ColorSpaceWorkingConfig")
    b.constructor {
        args => ColorSpaceWorkingConfig(prebindStr(args, 0))
    }
    b.property("unpackColorSpace",
        getter: Some({ref => LuaValue.of(ref.cast<ColorSpaceWorkingConfig>().unpackColorSpace)}),
        setter: Some({ref, v => ref.cast<ColorSpaceWorkingConfig>().unpackColorSpace = v.stringValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ColorSpaceOutputConfig 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.ColorSpaceOutputConfig）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ColorSpaceOutputConfig
 * @param[en] vm The target virtual machine (class table installed at
 *            three.core.math.ColorSpaceOutputConfig)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installColorSpaceOutputConfig(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.ColorSpaceOutputConfig")
    b.constructor {
        args => ColorSpaceOutputConfig(prebindStr(args, 0), toneMappingMode: prebindStr(args, 1, default: "standard"))
    }
    b.property("drawingBufferColorSpace",
        getter: Some({ref => LuaValue.of(ref.cast<ColorSpaceOutputConfig>().drawingBufferColorSpace)}), setter: Some({
            ref, v => ref.cast<ColorSpaceOutputConfig>().drawingBufferColorSpace = v.stringValue()
        }))
    b.property("toneMappingMode", getter: Some({ref => LuaValue.of(ref.cast<ColorSpaceOutputConfig>().toneMappingMode)}),
        setter: Some({ref, v => ref.cast<ColorSpaceOutputConfig>().toneMappingMode = v.stringValue()}))
    b.install(vm)
}
