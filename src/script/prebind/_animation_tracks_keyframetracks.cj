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
 * @file[zh-cn] animation_tracks 六种具体关键帧轨道的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.animation.tracks 下的 NumberKeyframeTrack / VectorKeyframeTrack /
 * ColorKeyframeTrack / QuaternionKeyframeTrack / BooleanKeyframeTrack /
 * StringKeyframeTrack 绑定为 Lua 类型
 * @explain[zh-cn] 六个子类共用 KeyframeTrack 基类的全部成员（见
 * animation_blend_keyframetrack.cj 的 _installKeyframeTrackMembers），因此每个子类绑定
 * 都重复登记「属性 + 插值器工厂 + 实例方法」以保持 Lua 侧可按实例直接调用（各绑定类
 * 拥有独立 metatable，不存在 __index 继承链）。构造参数：
 * - Number/Vector/Color/Quaternion：(name, times, values, interpolation 可选)；
 * - Boolean/String：(name, times, values)（插值恒为离散）。
 * 子类的 public override（InterpolantFactoryMethodLinear/Smooth、setInterpolation）
 * 通过虚分派生效，无需重复绑定。
 *
 * @file[en] animation_tracks  Lua bindings of the six concrete keyframe tracks
 * (three.script.prebind)
 * @brief[en] Binds NumberKeyframeTrack / VectorKeyframeTrack / ColorKeyframeTrack /
 * QuaternionKeyframeTrack / BooleanKeyframeTrack / StringKeyframeTrack under
 * three.animation.tracks as Lua types
 * @explain[en] All six subclasses share every member of the KeyframeTrack base class (see
 * _installKeyframeTrackMembers in animation_blend_keyframetrack.cj), so each subclass
 * binding registers the "properties + interpolant factories + instance methods" set again
 * so Lua can call them on the instance directly (every bound class owns an independent
 * metatable without an __index inheritance chain). Constructor arguments:
 * - Number/Vector/Color/Quaternion: (name, times, values, optional interpolation);
 * - Boolean/String: (name, times, values) (interpolation is always discrete).
 * The subclasses' public overrides (InterpolantFactoryMethodLinear/Smooth,
 * setInterpolation) take effect through virtual dispatch and need no extra binding.
 */
package three.script.prebind

import three.animation.tracks.*
import three.utils.constants.InterpolateLinear
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 NumberKeyframeTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.tracks.NumberKeyframeTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of NumberKeyframeTrack
 * @param[en] vm The target virtual machine (class table installed at three.animation.tracks.NumberKeyframeTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installNumberKeyframeTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.tracks.NumberKeyframeTrack")
    b.constructor {
        args => NumberKeyframeTrack(prebindStr(args, 0), prebindFloatArray(vm, args, 1), prebindFloatArray(vm, args, 2),
            interpolation: prebindInt(args, 3, default: InterpolateLinear))
    }
    _installKeyframeTrackMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 VectorKeyframeTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.tracks.VectorKeyframeTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of VectorKeyframeTrack
 * @param[en] vm The target virtual machine (class table installed at three.animation.tracks.VectorKeyframeTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installVectorKeyframeTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.tracks.VectorKeyframeTrack")
    b.constructor {
        args => VectorKeyframeTrack(prebindStr(args, 0), prebindFloatArray(vm, args, 1), prebindFloatArray(vm, args, 2),
            interpolation: prebindInt(args, 3, default: InterpolateLinear))
    }
    _installKeyframeTrackMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ColorKeyframeTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.tracks.ColorKeyframeTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ColorKeyframeTrack
 * @param[en] vm The target virtual machine (class table installed at three.animation.tracks.ColorKeyframeTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installColorKeyframeTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.tracks.ColorKeyframeTrack")
    b.constructor {
        args => ColorKeyframeTrack(prebindStr(args, 0), prebindFloatArray(vm, args, 1), prebindFloatArray(vm, args, 2),
            interpolation: prebindInt(args, 3, default: InterpolateLinear))
    }
    _installKeyframeTrackMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 QuaternionKeyframeTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.tracks.QuaternionKeyframeTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of QuaternionKeyframeTrack
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.tracks.QuaternionKeyframeTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installQuaternionKeyframeTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.tracks.QuaternionKeyframeTrack")
    b.constructor {
        args => QuaternionKeyframeTrack(prebindStr(args, 0), prebindFloatArray(vm, args, 1),
            prebindFloatArray(vm, args, 2), interpolation: prebindInt(args, 3, default: InterpolateLinear))
    }
    _installKeyframeTrackMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 BooleanKeyframeTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.tracks.BooleanKeyframeTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BooleanKeyframeTrack
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.tracks.BooleanKeyframeTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBooleanKeyframeTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.tracks.BooleanKeyframeTrack")
    b.constructor {
        args => BooleanKeyframeTrack(prebindStr(args, 0), prebindFloatArray(vm, args, 1), prebindFloatArray(vm, args, 2))
    }
    _installKeyframeTrackMembers(b, vm)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 StringKeyframeTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.tracks.StringKeyframeTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of StringKeyframeTrack
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.tracks.StringKeyframeTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installStringKeyframeTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.tracks.StringKeyframeTrack")
    b.constructor {
        args => StringKeyframeTrack(prebindStr(args, 0), prebindFloatArray(vm, args, 1), prebindFloatArray(vm, args, 2))
    }
    _installKeyframeTrackMembers(b, vm)
    b.install(vm)
}
