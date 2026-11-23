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
 * @file[zh-cn] animation_offline_optimizers 离线关键帧优化器（AnimationOptimizer /
 * TrackOptimizer）的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.animation.offline.AnimationOptimizer 与 TrackOptimizer 绑定为
 * Lua 类型
 * @explain[zh-cn] 两个优化器均以「误差容忍度」属性 + optimize（就地）/ optimizeCopy
 * （返回副本）成对方法构成，参数均为已绑定的离线数据类。
 *
 * @file[en] animation_offline_optimizers  Lua bindings of the offline keyframe optimizers
 * (AnimationOptimizer / TrackOptimizer) (three.script.prebind)
 * @brief[en] Binds three.animation.offline.AnimationOptimizer and TrackOptimizer as Lua types
 * @explain[en] Both optimizers consist of tolerance properties plus the paired
 * optimize (in place) / optimizeCopy (returns a copy) methods, whose parameters are the
 * already-bound offline data classes.
 */
package three.script.prebind

import three.animation.offline.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AnimationOptimizer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.AnimationOptimizer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimationOptimizer
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.offline.AnimationOptimizer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimationOptimizer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.AnimationOptimizer")
    b.constructor {
        args => AnimationOptimizer(translationTolerance: Float32(prebindNum(args, 0, default: 0.001)),
            rotationTolerance: Float32(prebindNum(args, 1, default: 0.001)),
            scaleTolerance: Float32(prebindNum(args, 2, default: 0.001)))
    }
    b.property("translationTolerance",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<AnimationOptimizer>().translationTolerance))}),
        setter: Some({ref, v => ref.cast<AnimationOptimizer>().translationTolerance = Float32(v.numberValue())}))
    b.property("rotationTolerance",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<AnimationOptimizer>().rotationTolerance))}),
        setter: Some({ref, v => ref.cast<AnimationOptimizer>().rotationTolerance = Float32(v.numberValue())}))
    b.property("scaleTolerance",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<AnimationOptimizer>().scaleTolerance))}),
        setter: Some({ref, v => ref.cast<AnimationOptimizer>().scaleTolerance = Float32(v.numberValue())}))
    b.method("optimize") {
        ref, args =>
            ref.cast<AnimationOptimizer>().optimize(prebindAs<RawAnimation>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("optimizeCopy") {
        ref, args => [prebindRegister(ref.cast<AnimationOptimizer>().optimizeCopy(prebindAs<RawAnimation>(args, 0)),
            "three.animation.offline.RawAnimation")]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 TrackOptimizer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.TrackOptimizer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TrackOptimizer
 * @param[en] vm The target virtual machine (class table installed at three.animation.offline.TrackOptimizer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTrackOptimizer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.TrackOptimizer")
    b.constructor {
        args => TrackOptimizer(floatTolerance: Float32(prebindNum(args, 0, default: 0.001)),
            float3Tolerance: Float32(prebindNum(args, 1, default: 0.001)),
            rotationTolerance: Float32(prebindNum(args, 2, default: 0.001)))
    }
    b.property("floatTolerance", getter: Some({ref => LuaValue.of(Float64(ref.cast<TrackOptimizer>().floatTolerance))}),
        setter: Some({ref, v => ref.cast<TrackOptimizer>().floatTolerance = Float32(v.numberValue())}))
    b.property("float3Tolerance",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<TrackOptimizer>().float3Tolerance))}),
        setter: Some({ref, v => ref.cast<TrackOptimizer>().float3Tolerance = Float32(v.numberValue())}))
    b.property("rotationTolerance",
        getter: Some({ref => LuaValue.of(Float64(ref.cast<TrackOptimizer>().rotationTolerance))}),
        setter: Some({ref, v => ref.cast<TrackOptimizer>().rotationTolerance = Float32(v.numberValue())}))
    // ===== 就地优化（返回被修改的轨道） =====
    b.method("optimizeFloat") {
        ref, args =>
            ref.cast<TrackOptimizer>().optimizeFloat(prebindAs<RawFloatTrack>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("optimizeQuaternion") {
        ref, args =>
            ref.cast<TrackOptimizer>().optimizeQuaternion(prebindAs<RawQuaternionTrack>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("optimizeFloat3") {
        ref, args =>
            ref.cast<TrackOptimizer>().optimizeFloat3(prebindAs<RawFloat3Track>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    // ===== 副本优化（返回新轨道） =====
    b.method("optimizeFloatCopy") {
        ref, args => [prebindRegister(ref.cast<TrackOptimizer>().optimizeFloatCopy(prebindAs<RawFloatTrack>(args, 0)),
            "three.animation.offline.RawFloatTrack")]
    }
    b.method("optimizeQuaternionCopy") {
        ref, args => [prebindRegister(
            ref.cast<TrackOptimizer>().optimizeQuaternionCopy(prebindAs<RawQuaternionTrack>(args, 0)),
            "three.animation.offline.RawQuaternionTrack")]
    }
    b.method("optimizeFloat3Copy") {
        ref, args => [prebindRegister(ref.cast<TrackOptimizer>().optimizeFloat3Copy(prebindAs<RawFloat3Track>(args, 0)),
            "three.animation.offline.RawFloat3Track")]
    }
    b.install(vm)
}
