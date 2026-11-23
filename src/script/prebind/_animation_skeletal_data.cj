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
 * @file[zh-cn] animation_skeletal_data 骨骼动画数据（SkeletalTrackData /
 * SkeletalAnimationData / JointTrack）的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.animation.skeletal 下三个纯数据类绑定为 Lua 类型
 * @explain[zh-cn] JointTrack：通道数组属性（Float32 数组走「Lua 表 ↔ Float32 数组」通道）
 * 与三个关键帧计数方法。SkeletalAnimationData：构造（无参 / duration+numTracks+tracks）、
 * 属性 duration / numTracks、numSoaJoints 与 track(i)（返回并注册 JointTrack）。
 * SkeletalTrackData：构造、四个数组属性与三个采样方法（采样返回 Vector3F / QuaternionF
 * / 标量），以及 TrackType 枚举的数值暴露。
 * 跳过：SkeletalTrackData 的 trackType 属性（枚举类型无 Lua 通道，改用 getTrackType/
 * setTrackType 以整数值读写）。
 *
 * @file[en] animation_skeletal_data  Lua bindings of the skeletal animation data
 * (SkeletalTrackData / SkeletalAnimationData / JointTrack) (three.script.prebind)
 * @brief[en] Binds the three pure-data classes under three.animation.skeletal as Lua types
 * @explain[en] JointTrack: channel array properties (Float32 arrays through the
 * "Lua table ↔ Float32 array" channel) and the three keyframe-count methods.
 * SkeletalAnimationData: construction (parameterless / duration+numTracks+tracks), the
 * duration / numTracks properties, numSoaJoints and track(i) (returns and registers a
 * JointTrack). SkeletalTrackData: construction, four array properties, three sampling
 * methods (returning Vector3F / QuaternionF / a scalar) and the TrackType enum values.
 * Skipped: SkeletalTrackData's trackType property (an enum type has no Lua channel); instead
 * getTrackType / setTrackType read and write it as an integer.
 */
package three.script.prebind

import three.animation.skeletal.*
import three.core.math.Vector3F
import three.core.math.QuaternionF
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 读取 Lua 参数为 Float32 数组（元素经 numberValue 转换）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Float32 数组（非数组/表返回空）
 *
 * @brief[en] Reads a Lua argument as a Float32 array (elements via numberValue)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The Float32 array (empty when not an array/table)
 */
private func _prebindF32Array(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Float32> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<Float32>(n, { _ => 0.0f32 })
    for (i in 0..n) {
        out[i] = Float32(elems[i].numberValue())
    }
    return out
}

/**
 * @brief[zh-cn] 把 Float32 数组转为 Lua 数值数组（元素按 Float64 呈现）
 * @param[zh-cn] src 源数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a Float32 array into a Lua number array (elements presented as Float64)
 * @param[en] src The source array
 * @return[en] The Lua array value
 */
private func _prebindF32ArrayToLua(src: Array<Float32>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, { _ => LuaValue.Nil })
    for (i in 0..n) {
        out[i] = LuaValue.of(Float64(src[i]))
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 把 Lua 值（数组或表）转为 Float32 数组
 * @param[zh-cn] vm 目标虚拟机（Lua 表输入需经此读取）
 * @param[zh-cn] v 数值数组值或表引用
 * @return[zh-cn] Float32 数组（非数组且非表返回空）
 *
 * @brief[en] Converts a Lua value (array or table) into a Float32 array
 * @param[en] vm The target virtual machine (needed to read Lua table input)
 * @param[en] v The number-array value or table reference
 * @return[en] The Float32 array (empty when neither an array nor a table)
 */
private func _prebindF32FromValue(vm: LuaVM, v: LuaValue): Array<Float32> {
    let elems = prebindArray(vm, [v], 0)
    let n = elems.size
    var out = Array<Float32>(n, { _ => 0.0f32 })
    for (i in 0..n) {
        out[i] = Float32(elems[i].numberValue())
    }
    return out
}

/**
 * @brief[zh-cn] 由整数值取通道类型枚举（0=Float / 1=Quaternion / 2=Float3；越界回退 Float）
 * @param[zh-cn] i 整数值
 * @return[zh-cn] 对应枚举值
 *
 * @brief[en] Maps an integer to the track-type enum (0=Float / 1=Quaternion / 2=Float3; falls back to Float)
 * @param[en] i The integer value
 * @return[en] The corresponding enum value
 */
private func _prebindTrackTypeFrom(i: Int64): TrackType {
    match (i) {
        case 1 => TrackType.Quaternion
        case 2 => TrackType.Float3
        case _ => TrackType.Float
    }
}

/**
 * @brief[zh-cn] 取通道类型枚举的整数值（Float=0 / Quaternion=1 / Float3=2）
 * @param[zh-cn] t 通道类型
 * @return[zh-cn] 整数值
 *
 * @brief[en] Returns the integer value of a track-type enum (Float=0 / Quaternion=1 / Float3=2)
 * @param[en] t The track type
 * @return[en] The integer value
 */
private func _prebindTrackTypeTo(t: TrackType): Int64 {
    match (t) {
        case TrackType.Float => 0
        case TrackType.Quaternion => 1
        case TrackType.Float3 => 2
    }
}

/**
 * @brief[zh-cn] 安装 JointTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.JointTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of JointTrack
 * @param[en] vm The target virtual machine (class table installed at three.animation.skeletal.JointTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installJointTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.JointTrack")
    b.constructor { _ => JointTrack() }
    b.property("transTimes",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<JointTrack>().transTimes) }),
        setter: Some({ ref, v => ref.cast<JointTrack>().transTimes = _prebindF32FromValue(vm, v) }))
    b.property("transValues",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<JointTrack>().transValues) }),
        setter: Some({ ref, v => ref.cast<JointTrack>().transValues = _prebindF32FromValue(vm, v) }))
    b.property("rotTimes",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<JointTrack>().rotTimes) }),
        setter: Some({ ref, v => ref.cast<JointTrack>().rotTimes = _prebindF32FromValue(vm, v) }))
    b.property("rotValues",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<JointTrack>().rotValues) }),
        setter: Some({ ref, v => ref.cast<JointTrack>().rotValues = _prebindF32FromValue(vm, v) }))
    b.property("scaleTimes",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<JointTrack>().scaleTimes) }),
        setter: Some({ ref, v => ref.cast<JointTrack>().scaleTimes = _prebindF32FromValue(vm, v) }))
    b.property("scaleValues",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<JointTrack>().scaleValues) }),
        setter: Some({ ref, v => ref.cast<JointTrack>().scaleValues = _prebindF32FromValue(vm, v) }))
    b.method("numTransKeyframes") { ref, _ =>
        [LuaValue.of(Int64(ref.cast<JointTrack>().numTransKeyframes()))]
    }
    b.method("numRotKeyframes") { ref, _ =>
        [LuaValue.of(Int64(ref.cast<JointTrack>().numRotKeyframes()))]
    }
    b.method("numScaleKeyframes") { ref, _ =>
        [LuaValue.of(Int64(ref.cast<JointTrack>().numScaleKeyframes()))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 SkeletalAnimationData 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.SkeletalAnimationData）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SkeletalAnimationData
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.skeletal.SkeletalAnimationData)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSkeletalAnimationData(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.SkeletalAnimationData")
    // ===== 构造：无参 或 duration + numTracks + jointTracks 对象数组 =====
    b.constructor { args =>
        if (args.size >= 3) {
            SkeletalAnimationData(
                Float32(prebindNum(args, 0)),
                Int64(prebindInt(args, 1)),
                prebindObjList<JointTrack>(vm, args, 2).toArray())
        } else {
            SkeletalAnimationData()
        }
    }
    b.property("duration",
        getter: Some({ ref => LuaValue.of(Float64(ref.cast<SkeletalAnimationData>().duration)) }),
        setter: Some({ ref, v => ref.cast<SkeletalAnimationData>().duration = Float32(v.numberValue()) }))
    b.property("numTracks",
        getter: Some({ ref => LuaValue.of(Int64(ref.cast<SkeletalAnimationData>().numTracks)) }),
        setter: Some({ ref, v => ref.cast<SkeletalAnimationData>().numTracks = Int64(v.intValue()) }))
    b.method("numSoaJoints") { ref, _ =>
        [LuaValue.of(Int64(ref.cast<SkeletalAnimationData>().numSoaJoints()))]
    }
    b.method("track") { ref, args =>
        [prebindRegister(ref.cast<SkeletalAnimationData>().track(Int64(prebindInt(args, 0))), "three.animation.skeletal.JointTrack")]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 SkeletalTrackData 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.SkeletalTrackData）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SkeletalTrackData
 * @param[en] vm The target virtual machine (class table installed at three.animation.skeletal.SkeletalTrackData)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSkeletalTrackData(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.SkeletalTrackData")
    // ===== 构造（全部命名参数可选，按位置覆盖） =====
    b.constructor { args =>
        SkeletalTrackData(
            name: prebindStr(args, 0),
            trackType: _prebindTrackTypeFrom(prebindInt(args, 1)),
            times: _prebindF32Array(vm, args, 2),
            floatValues: _prebindF32Array(vm, args, 3),
            quatValues: _prebindF32Array(vm, args, 4),
            float3Values: _prebindF32Array(vm, args, 5),
            numKeyframes: Int64(prebindInt(args, 6)))
    }
    b.property("name",
        getter: Some({ ref => LuaValue.of(ref.cast<SkeletalTrackData>().name) }),
        setter: Some({ ref, v => ref.cast<SkeletalTrackData>().name = v.stringValue() }))
    b.property("times",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<SkeletalTrackData>().times) }),
        setter: Some({ ref, v => ref.cast<SkeletalTrackData>().times = _prebindF32FromValue(vm, v) }))
    b.property("floatValues",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<SkeletalTrackData>().floatValues) }),
        setter: Some({ ref, v => ref.cast<SkeletalTrackData>().floatValues = _prebindF32FromValue(vm, v) }))
    b.property("quatValues",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<SkeletalTrackData>().quatValues) }),
        setter: Some({ ref, v => ref.cast<SkeletalTrackData>().quatValues = _prebindF32FromValue(vm, v) }))
    b.property("float3Values",
        getter: Some({ ref => _prebindF32ArrayToLua(ref.cast<SkeletalTrackData>().float3Values) }),
        setter: Some({ ref, v => ref.cast<SkeletalTrackData>().float3Values = _prebindF32FromValue(vm, v) }))
    b.property("numKeyframes",
        getter: Some({ ref => LuaValue.of(Int64(ref.cast<SkeletalTrackData>().numKeyframes)) }),
        setter: Some({ ref, v => ref.cast<SkeletalTrackData>().numKeyframes = Int64(v.intValue()) }))
    // ===== 通道类型（枚举以整数读写） =====
    b.method("getTrackType") { ref, _ =>
        [LuaValue.of(_prebindTrackTypeTo(ref.cast<SkeletalTrackData>().trackType))]
    }
    b.method("setTrackType") { ref, args =>
        ref.cast<SkeletalTrackData>().trackType = _prebindTrackTypeFrom(prebindInt(args, 0))
        [LuaValue.Object(ref.id)]
    }
    // ===== 采样 =====
    b.method("sampleFloat") { ref, args =>
        [LuaValue.of(Float64(ref.cast<SkeletalTrackData>().sampleFloat(Float32(prebindNum(args, 0)))))]
    }
    b.method("sampleQuaternion") { ref, args =>
        [prebindRegister(
            ref.cast<SkeletalTrackData>().sampleQuaternion(Float32(prebindNum(args, 0))),
            "three.core.math.QuaternionF")]
    }
    b.method("sampleFloat3") { ref, args =>
        [prebindRegister(
            ref.cast<SkeletalTrackData>().sampleFloat3(Float32(prebindNum(args, 0))),
            "three.core.math.Vector3F")]
    }
    b.install(vm)
}

