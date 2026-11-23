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
 * @file[zh-cn] core_math_interpolants 插值器 Interpolant 及其子包的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Interpolant 与 three.core.math.interpolants 下
 * 5 个具体插值器绑定为 Lua 类型
 * @explain[zh-cn] 覆盖构造（new，4 参：parameterPositions / sampleValues /
 * sampleSize / resultBuffer）、共有属性（parameterPositions / sampleValues /
 * resultBuffer / valueSize）、共有方法 evaluate(t)，以及各子类 public 覆写方法
 * interpolate_(i1,t0,t,t1)（CubicInterpolant 另有 intervalChanged_(i1,t0,t1)）。
 * settings / DefaultSettings_ / __cacheIndex 为 HashMap / Option 成员，当前无
 * 「Lua 表 ↔ HashMap」通道，暂不绑定；基类 interpolate_ / intervalChanged_ /
 * copySampleValue_ 为 protected，跨包不可见，故仅在子类 public 覆写处绑定。
 *
 * @file[en] core_math_interpolants Lua binding of Interpolant and its sub-package
 * (three.script.prebind)
 * @brief[en] Binds three.core.math.Interpolant and the five concrete interpolants under
 * three.core.math.interpolants as Lua types
 * @explain[en] Covers construction (new, four args: parameterPositions / sampleValues /
 * sampleSize / resultBuffer), the shared properties (parameterPositions / sampleValues /
 * resultBuffer / valueSize), the shared evaluate(t), and each subclass' public overrides
 * interpolate_(i1,t0,t,t1) (CubicInterpolant additionally intervalChanged_(i1,t0,t1)).
 * settings / DefaultSettings_ / __cacheIndex are HashMap / Option members and stay
 * unbound because there is no "Lua table ↔ HashMap" channel yet; the base-class
 * interpolate_ / intervalChanged_ / copySampleValue_ are protected and therefore
 * invisible across packages, so they are bound only at the public subclass overrides.
 */
package three.script.prebind

import three.core.math.*
import three.core.math.interpolants.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取可选浮点数组参数（缺省或 nil → None）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * args 请求参数
 * idx 参数下标（0 基）
 * @return[zh-cn] Some(浮点数组) 或 None
 *
 * @brief[en] Reads an optional float-array argument (absent or nil → None)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * args The request arguments
 * idx The 0-based argument index
 * @return[en] Some(float array) or None
 */
private func _prebindOptFloatArray(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Option<Array<Float64>> {
    if (args.size <= idx || args[idx].isNil) {
        return None
    }
    return Some(prebindFloatArray(vm, args, idx))
}

/**
 * @brief[zh-cn] 注册 Interpolant 家族共有成员（4 个属性 + evaluate）
 * @param[zh-cn] b 类绑定器（基类或子类）
 *
 * @brief[en] Registers the members shared by the whole Interpolant family
 * (four properties + evaluate)
 * @param[en] b The class binder (base class or subclass)
 */
private func _installInterpolantMembers(b: LuaClassBinder): Unit {
    // ===== 属性 =====
    b.property("parameterPositions", getter: Some({ref => LuaValue.of(ref.cast<Interpolant>().parameterPositions)}),
        setter: Some({ref, v => ref.cast<Interpolant>().parameterPositions = v.toArrayFloat()}))
    b.property("sampleValues", getter: Some({ref => LuaValue.of(ref.cast<Interpolant>().sampleValues)}),
        setter: Some({ref, v => ref.cast<Interpolant>().sampleValues = v.toArrayFloat()}))
    b.property("resultBuffer", getter: Some({ref => LuaValue.of(ref.cast<Interpolant>().resultBuffer)}),
        setter: Some({ref, v => ref.cast<Interpolant>().resultBuffer = v.toArrayFloat()}))
    b.property("valueSize", getter: Some({ref => LuaValue.of(ref.cast<Interpolant>().valueSize)}),
        setter: Some({ref, v => ref.cast<Interpolant>().valueSize = v.intValue()}))
    // ===== 求值 =====
    b.method("evaluate") {
        ref, args => [LuaValue.of(ref.cast<Interpolant>().evaluate(args[0].numberValue()))]
    }
}

/**
 * @brief[zh-cn] 安装 Interpolant 基类的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Interpolant）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the Interpolant base class
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Interpolant)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installInterpolant(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Interpolant")
    b.constructor {
        args => Interpolant(prebindFloatArray(vm, args, 0), prebindFloatArray(vm, args, 1), prebindInt(args, 2),
            _prebindOptFloatArray(vm, args, 3))
    }
    _installInterpolantMembers(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 LinearInterpolant 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.interpolants.LinearInterpolant）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LinearInterpolant
 * @param[en] vm The target virtual machine (class table installed at
 *            three.core.math.interpolants.LinearInterpolant)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLinearInterpolant(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.interpolants.LinearInterpolant")
    b.constructor {
        args => LinearInterpolant(prebindFloatArray(vm, args, 0), prebindFloatArray(vm, args, 1), prebindInt(args, 2),
            _prebindOptFloatArray(vm, args, 3))
    }
    _installInterpolantMembers(b)
    b.method("interpolate_") {
        ref, args => [LuaValue.of(
            ref
                .cast<LinearInterpolant>()
                .interpolate_(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3)))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 DiscreteInterpolant 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.interpolants.DiscreteInterpolant）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of DiscreteInterpolant
 * @param[en] vm The target virtual machine (class table installed at
 *            three.core.math.interpolants.DiscreteInterpolant)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installDiscreteInterpolant(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.interpolants.DiscreteInterpolant")
    b.constructor {
        args => DiscreteInterpolant(prebindFloatArray(vm, args, 0), prebindFloatArray(vm, args, 1), prebindInt(args, 2),
            _prebindOptFloatArray(vm, args, 3))
    }
    _installInterpolantMembers(b)
    b.method("interpolate_") {
        ref, args => [LuaValue.of(
            ref
                .cast<DiscreteInterpolant>()
                .interpolate_(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3)))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 CubicInterpolant 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.interpolants.CubicInterpolant）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CubicInterpolant
 * @param[en] vm The target virtual machine (class table installed at
 *            three.core.math.interpolants.CubicInterpolant)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCubicInterpolant(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.interpolants.CubicInterpolant")
    b.constructor {
        args => CubicInterpolant(prebindFloatArray(vm, args, 0), prebindFloatArray(vm, args, 1), prebindInt(args, 2),
            _prebindOptFloatArray(vm, args, 3))
    }
    _installInterpolantMembers(b)
    b.method("interpolate_") {
        ref, args => [LuaValue.of(
            ref
                .cast<CubicInterpolant>()
                .interpolate_(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3)))]
    }
    b.method("intervalChanged_") {
        ref, args =>
            ref.cast<CubicInterpolant>().intervalChanged_(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            []
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 QuaternionLinearInterpolant 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到
 *            three.core.math.interpolants.QuaternionLinearInterpolant）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of QuaternionLinearInterpolant
 * @param[en] vm The target virtual machine (class table installed at
 *            three.core.math.interpolants.QuaternionLinearInterpolant)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installQuaternionLinearInterpolant(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.interpolants.QuaternionLinearInterpolant")
    b.constructor {
        args => QuaternionLinearInterpolant(prebindFloatArray(vm, args, 0), prebindFloatArray(vm, args, 1),
            prebindInt(args, 2), _prebindOptFloatArray(vm, args, 3))
    }
    _installInterpolantMembers(b)
    b.method("interpolate_") {
        ref, args => [LuaValue.of(
            ref
                .cast<QuaternionLinearInterpolant>()
                .interpolate_(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3)))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 BezierInterpolant 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.interpolants.BezierInterpolant）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BezierInterpolant
 * @param[en] vm The target virtual machine (class table installed at
 *            three.core.math.interpolants.BezierInterpolant)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBezierInterpolant(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.interpolants.BezierInterpolant")
    b.constructor {
        args => BezierInterpolant(prebindFloatArray(vm, args, 0), prebindFloatArray(vm, args, 1), prebindInt(args, 2),
            _prebindOptFloatArray(vm, args, 3))
    }
    _installInterpolantMembers(b)
    b.method("interpolate_") {
        ref, args => [LuaValue.of(
            ref
                .cast<BezierInterpolant>()
                .interpolate_(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3)))]
    }
    b.install(vm)
}
