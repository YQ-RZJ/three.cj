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
 * @file[zh-cn] animation_offline_rawtracks 离线单通道轨道（RawFloatTrack /
 * RawQuaternionTrack / RawFloat3Track）的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.animation.offline 下三种离线通道轨道绑定为 Lua 类型
 * @explain[zh-cn] 每个轨道覆盖构造（name）、属性 name、以及 addKeyframe /
 * numKeyframes / sortKeyframes / validate。关键帧入参统一为标量（时间 + 值），
 * 不使用 keyframes 属性——其类型为 ArrayList<Raw*Keyframe>，当前无「Lua 表 ↔ 嵌套容器」
 * 通道，故 keyframes 不绑定。
 *
 * @file[en] animation_offline_rawtracks  Lua bindings of the offline single-channel tracks
 * (RawFloatTrack / RawQuaternionTrack / RawFloat3Track) (three.script.prebind)
 * @brief[en] Binds the three offline channel tracks under three.animation.offline as Lua types
 * @explain[en] Every track covers construction (name), the name property and
 * addKeyframe / numKeyframes / sortKeyframes / validate. Keyframe arguments are scalars
 * (time + value); the keyframes property is not bound because its type is
 * ArrayList<Raw*Keyframe> and there is no "Lua table ↔ nested container" channel yet.
 */
package three.script.prebind

import three.animation.offline.*
import three.core.math.Vector3F
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RawFloatTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.RawFloatTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RawFloatTrack
 * @param[en] vm The target virtual machine (class table installed at three.animation.offline.RawFloatTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRawFloatTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.RawFloatTrack")
    b.constructor { args => RawFloatTrack(prebindStr(args, 0)) }
    b.property("name",
        getter: Some({ ref => LuaValue.of(ref.cast<RawFloatTrack>().name) }),
        setter: Some({ ref, v => ref.cast<RawFloatTrack>().name = v.stringValue() }))
    b.method("addKeyframe") { ref, args =>
        ref.cast<RawFloatTrack>().addKeyframe(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)))
        [LuaValue.Object(ref.id)]
    }
    b.method("numKeyframes") { ref, _ =>
        [LuaValue.of(Int64(ref.cast<RawFloatTrack>().numKeyframes()))]
    }
    b.method("sortKeyframes") { ref, _ =>
        ref.cast<RawFloatTrack>().sortKeyframes()
        [LuaValue.Object(ref.id)]
    }
    b.method("validate") { ref, _ =>
        [LuaValue.of(ref.cast<RawFloatTrack>().validate())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RawQuaternionTrack 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.RawQuaternionTrack）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RawQuaternionTrack
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.offline.RawQuaternionTrack)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRawQuaternionTrack(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.RawQuaternionTrack")
    b.constructor { args => RawQuaternionTrack(prebindStr(args, 0)) }
    b.property("name",
        getter: Some({ ref => LuaValue.of(ref.cast<RawQuaternionTrack>().name) }),
        setter: Some({ ref, v => ref.cast<RawQuaternionTrack>().name = v.stringValue() }))
    b.method("addKeyframe") { ref, args =>
        ref.cast<RawQuaternionTrack>().addKeyframe(
            Float32(prebindNum(args, 0)),
            Float32(prebindNum(args, 1)),
            Float32(prebindNum(args, 2)),
            Float32(prebindNum(args, 3)),
            Float32(prebindNum(args, 4)))
        [LuaValue.Object(ref.id)]
    }
    b.method("numKeyframes") { ref, _ =>
        [LuaValue.of(Int64(ref.cast<RawQuaternionTrack>().numKeyframes()))]
    }
    b.method("sortKeyframes") { ref, _ =>
        ref.cast<RawQuaternionTrack>().sortKeyframes()
        [LuaValue.Object(ref.id)]
    }
    b.method("validate") { ref, _ =>
        [LuaValue.of(ref.cast<RawQuaternionTrack>().validate())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RawFloat3Track 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.RawFloat3Track）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RawFloat3Track
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.offline.RawFloat3Track)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRawFloat3Track(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.RawFloat3Track")
    b.constructor { args => RawFloat3Track(prebindStr(args, 0)) }
    b.property("name",
        getter: Some({ ref => LuaValue.of(ref.cast<RawFloat3Track>().name) }),
        setter: Some({ ref, v => ref.cast<RawFloat3Track>().name = v.stringValue() }))
    b.method("addKeyframe") { ref, args =>
        ref.cast<RawFloat3Track>().addKeyframe(Float32(prebindNum(args, 0)), prebindAs<Vector3F>(args, 1))
        [LuaValue.Object(ref.id)]
    }
    b.method("numKeyframes") { ref, _ =>
        [LuaValue.of(Int64(ref.cast<RawFloat3Track>().numKeyframes()))]
    }
    b.method("sortKeyframes") { ref, _ =>
        ref.cast<RawFloat3Track>().sortKeyframes()
        [LuaValue.Object(ref.id)]
    }
    b.method("validate") { ref, _ =>
        [LuaValue.of(ref.cast<RawFloat3Track>().validate())]
    }
    b.install(vm)
}

