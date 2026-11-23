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
 * @file[zh-cn] animation_blend_keyframetrack 关键帧轨道 KeyframeTrack 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.animation.blend.KeyframeTrack 绑定为 Lua 类型
 * three.animation.blend.KeyframeTrack
 * @explain[zh-cn] 覆盖两种构造（无参 / name+times+values+可选 interpolation）、
 * 全部 public 可变属性（name/times/values/ValueTypeName/ValueBufferType/
 * DefaultInterpolation）、插值器工厂（createInterpolant / InterpolantFactoryMethod*
 * 返回 Interpolant 对象，注册为 three.core.math.Interpolant）与全部实例方法
 * （setInterpolation/getInterpolation/getValueSize/shift/scale/trim/validate/
 * optimize/clone）。返回 KeyframeTrack 的方法统一回传自身对象 id 以支持链式调用；
 * clone 返回新实例并注册为新 Lua 对象。times/values 走「Lua 表 ↔ Float64 数组」通道。
 *
 * @file[en] animation_blend_keyframetrack  Lua binding of the keyframe track KeyframeTrack
 * (three.script.prebind)
 * @brief[en] Binds three.animation.blend.KeyframeTrack as the Lua type
 * three.animation.blend.KeyframeTrack
 * @explain[en] Covers the two constructors (parameterless / name+times+values with optional
 * interpolation), every public mutable property (name/times/values/ValueTypeName/
 * ValueBufferType/DefaultInterpolation), the interpolant factories (createInterpolant /
 * InterpolantFactoryMethod*, which return Interpolant objects registered as
 * three.core.math.Interpolant) and all instance methods (setInterpolation/getInterpolation/
 * getValueSize/shift/scale/trim/validate/optimize/clone). Methods returning KeyframeTrack
 * hand back the object's own id for chaining; clone registers the fresh instance as a new
 * Lua object. times/values use the "Lua table ↔ Float64 array" channel.
 */
package three.script.prebind

import three.animation.blend.KeyframeTrack
import three.core.math.Interpolant
import three.utils.constants.InterpolateLinear
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取可选浮点数组参数（缺省或 nil → None）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Some(浮点数组) 或 None
 *
 * @brief[en] Reads an optional float-array argument (absent or nil → None)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] Some(float array) or None
 */
private func _prebindTrackOptFloatArray(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Option<Array<Float64>> {
    if (args.size <= idx || args[idx].isNil) {
        return None
    }
    return Some(prebindFloatArray(vm, args, idx))
}

/**
 * @brief[zh-cn] 把插值器注册为 Lua 对象（类型名 three.core.math.Interpolant）
 * @param[zh-cn] interp 插值器实例
 * @return[zh-cn] 承载新对象 id 的 Lua 值
 *
 * @brief[en] Registers an interpolant as a Lua object (type three.core.math.Interpolant)
 * @param[en] interp The interpolant instance
 * @return[en] The Lua value carrying the new object id
 */
private func _prebindInterpolant(interp: Interpolant): LuaValue {
    return prebindRegister(interp, "three.core.math.Interpolant")
}

/**
 * @brief[zh-cn] 把 Lua 值（数组或表）转为 Float64 数组（属性 setter 用）
 * @param[zh-cn] vm 目标虚拟机（Lua 表输入需经此读取）
 * @param[zh-cn] v 数值数组值或表引用
 * @return[zh-cn] Float64 数组（非数组且非表返回空）
 *
 * @brief[en] Converts a Lua value (array or table) into a Float64 array (for property setters)
 * @param[en] vm The target virtual machine (needed to read Lua table input)
 * @param[en] v The number-array value or table reference
 * @return[en] The Float64 array (empty when neither an array nor a table)
 */
internal func _prebindTrackFloatArray(vm: LuaVM, v: LuaValue): Array<Float64> {
    let elems = prebindArray(vm, [v], 0)
    let n = elems.size
    var out = Array<Float64>(n, {_ => 0.0})
    for (i in 0..n) {
        out[i] = elems[i].numberValue()
    }
    return out
}

/**
 * @brief[zh-cn] 注册 KeyframeTrack 家族共有成员（属性 + 插值器工厂 + 实例方法）
 * @param[zh-cn] b 类绑定器（基类或子类）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Registers the members shared by the whole KeyframeTrack family
 * (properties + interpolant factories + instance methods)
 * @param[en] b The class binder (base class or subclass)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _installKeyframeTrackMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 属性 =====
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<KeyframeTrack>().name)}),
        setter: Some({ref, v => ref.cast<KeyframeTrack>().name = v.stringValue()}))
    b.property("times", getter: Some({ref => LuaValue.of(ref.cast<KeyframeTrack>().times)}),
        setter: Some({ref, v => ref.cast<KeyframeTrack>().times = _prebindTrackFloatArray(vm, v)}))
    b.property("values", getter: Some({ref => LuaValue.of(ref.cast<KeyframeTrack>().values)}),
        setter: Some({ref, v => ref.cast<KeyframeTrack>().values = _prebindTrackFloatArray(vm, v)}))
    b.property("ValueTypeName", getter: Some({ref => LuaValue.of(ref.cast<KeyframeTrack>().ValueTypeName)}),
        setter: Some({ref, v => ref.cast<KeyframeTrack>().ValueTypeName = v.stringValue()}))
    b.property("ValueBufferType", getter: Some({ref => LuaValue.of(ref.cast<KeyframeTrack>().ValueBufferType)}),
        setter: Some({ref, v => ref.cast<KeyframeTrack>().ValueBufferType = v.stringValue()}))
    b.property("DefaultInterpolation",
        getter: Some({ref => LuaValue.of(ref.cast<KeyframeTrack>().DefaultInterpolation)}),
        setter: Some({ref, v => ref.cast<KeyframeTrack>().DefaultInterpolation = v.intValue()}))
    // ===== 插值器工厂 =====
    b.method("createInterpolant") {
        ref, args => [_prebindInterpolant(
            ref.cast<KeyframeTrack>().createInterpolant(_prebindTrackOptFloatArray(vm, args, 0)))]
    }
    b.method("InterpolantFactoryMethodDiscrete") {
        ref, args => [_prebindInterpolant(
            ref.cast<KeyframeTrack>().InterpolantFactoryMethodDiscrete(_prebindTrackOptFloatArray(vm, args, 0)))]
    }
    b.method("InterpolantFactoryMethodLinear") {
        ref, args => [_prebindInterpolant(
            ref.cast<KeyframeTrack>().InterpolantFactoryMethodLinear(_prebindTrackOptFloatArray(vm, args, 0)))]
    }
    b.method("InterpolantFactoryMethodSmooth") {
        ref, args => [_prebindInterpolant(
            ref.cast<KeyframeTrack>().InterpolantFactoryMethodSmooth(_prebindTrackOptFloatArray(vm, args, 0)))]
    }
    b.method("InterpolantFactoryMethodBezier") {
        ref, args => [_prebindInterpolant(
            ref.cast<KeyframeTrack>().InterpolantFactoryMethodBezier(_prebindTrackOptFloatArray(vm, args, 0)))]
    }
    // ===== 插值类型 =====
    b.method("setInterpolation") {
        ref, args =>
            ref.cast<KeyframeTrack>().setInterpolation(prebindInt(args, 0, default: InterpolateLinear))
            [LuaValue.Object(ref.id)]
    }
    b.method("getInterpolation") {
        ref, _ => [LuaValue.of(ref.cast<KeyframeTrack>().getInterpolation())]
    }
    b.method("getValueSize") {
        ref, _ => [LuaValue.of(ref.cast<KeyframeTrack>().getValueSize())]
    }
    // ===== 时间轴变换（链式返回自身） =====
    b.method("shift") {
        ref, args =>
            ref.cast<KeyframeTrack>().shift(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("scale") {
        ref, args =>
            ref.cast<KeyframeTrack>().scale(prebindNum(args, 0, default: 1.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("trim") {
        ref, args =>
            ref.cast<KeyframeTrack>().trim(prebindNum(args, 0), prebindNum(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 校验与优化 =====
    b.method("validate") {
        ref, _ => [LuaValue.of(ref.cast<KeyframeTrack>().validate())]
    }
    b.method("optimize") {
        ref, _ =>
            ref.cast<KeyframeTrack>().optimize()
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<KeyframeTrack>().clone(), "three.animation.blend.KeyframeTrack")]
    }
}

/**
 * @brief[zh-cn] 安装 KeyframeTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.blend.KeyframeTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of KeyframeTrack
 * @param[en] vm The target virtual machine (class table installed at three.animation.blend.KeyframeTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installKeyframeTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.blend.KeyframeTrack")
    // ===== 构造：无参（fastjson 反序列化用）或 name+times+values[+interpolation] =====
    b.constructor {
        args => if (args.size < 3) {
            KeyframeTrack()
        } else if (args.size < 4) {
            KeyframeTrack(prebindStr(args, 0), prebindFloatArray(vm, args, 1), prebindFloatArray(vm, args, 2))
        } else {
            KeyframeTrack(prebindStr(args, 0), prebindFloatArray(vm, args, 1), prebindFloatArray(vm, args, 2),
                interpolation: prebindInt(args, 3, default: InterpolateLinear))
        }
    }
    _installKeyframeTrackMembers(b, vm)
    b.install(vm)
}
