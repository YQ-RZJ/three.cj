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
 * @file[zh-cn] animation_blend_animationaction 动画动作 AnimationAction 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.animation.blend.AnimationAction 绑定为 Lua 类型
 * three.animation.blend.AnimationAction
 * @explain[zh-cn] 覆盖构造（mixer / clip / localRoot / 可选 blendMode）、全部 public
 * 属性（blendMode/loop/time/timeScale/weight/repetitions/paused/enabled/
 * clampWhenFinished/zeroSlopeAtStart/zeroSlopeAtEnd）、播放控制（play/stop/reset/
 * startAt/setLoop/halt）、权重与时间缩放（setEffectiveWeight/getEffectiveWeight/
 * setEffectiveTimeScale/getEffectiveTimeScale/setDuration）、淡入淡出与过渡
 * （fadeIn/fadeOut/crossFadeFrom/crossFadeTo/stopFading）、时间轴（syncWith/warp/
 * stopWarping）、状态查询（isRunning/isScheduled）。
 * 跳过：getMixer/getClip/getRoot —— 返回动画内部的 mixer / clip / root 对象，
 * 当前无「对象 → 已注册 id」反查通道，无法回传同一 Lua userdata（见交接文档第 10 节）。
 *
 * @file[en] animation_blend_animationaction  Lua binding of the animation action AnimationAction
 * (three.script.prebind)
 * @brief[en] Binds three.animation.blend.AnimationAction as the Lua type
 * three.animation.blend.AnimationAction
 * @explain[en] Covers construction (mixer / clip / localRoot / optional blendMode), every
 * public property (blendMode/loop/time/timeScale/weight/repetitions/paused/enabled/
 * clampWhenFinished/zeroSlopeAtStart/zeroSlopeAtEnd), playback control (play/stop/reset/
 * startAt/setLoop/halt), weight and time scale (setEffectiveWeight/getEffectiveWeight/
 * setEffectiveTimeScale/getEffectiveTimeScale/setDuration), fading and transitions
 * (fadeIn/fadeOut/crossFadeFrom/crossFadeTo/stopFading), the timeline (syncWith/warp/
 * stopWarping) and state queries (isRunning/isScheduled).
 * Skipped: getMixer/getClip/getRoot — they return the mixer / clip / root objects held
 * inside the action, and there is no "object → registered id" reverse lookup yet, so the same
 * Lua userdata cannot be handed back (see section 10 of the handover document).
 */
package three.script.prebind

import three.animation.blend.AnimationAction
import three.animation.blend.AnimationMixer
import three.animation._interfaces.IAnimationClip
import three.scene.objects.Object3D
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AnimationAction 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.blend.AnimationAction）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimationAction
 * @param[en] vm The target virtual machine (class table installed at three.animation.blend.AnimationAction)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimationAction(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.blend.AnimationAction")
    // ===== 构造：mixer + clip + localRoot [+ blendMode] =====
    b.constructor {
        args => AnimationAction(prebindAs<AnimationMixer>(args, 0), prebindAs<IAnimationClip>(args, 1),
            prebindAs<Object3D>(args, 2), blendMode: prebindInt(args, 3, default: -1))
    }
    // ===== 属性 =====
    b.property("blendMode", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().blendMode)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().blendMode = v.intValue()}))
    b.property("loop", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().loop)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().loop = v.intValue()}))
    b.property("time", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().time)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().time = v.numberValue()}))
    b.property("timeScale", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().timeScale)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().timeScale = v.numberValue()}))
    b.property("weight", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().weight)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().weight = v.numberValue()}))
    b.property("repetitions", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().repetitions)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().repetitions = v.numberValue()}))
    b.property("paused", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().paused)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().paused = v.boolValue()}))
    b.property("enabled", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().enabled)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().enabled = v.boolValue()}))
    b.property("clampWhenFinished", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().clampWhenFinished)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().clampWhenFinished = v.boolValue()}))
    b.property("zeroSlopeAtStart", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().zeroSlopeAtStart)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().zeroSlopeAtStart = v.boolValue()}))
    b.property("zeroSlopeAtEnd", getter: Some({ref => LuaValue.of(ref.cast<AnimationAction>().zeroSlopeAtEnd)}),
        setter: Some({ref, v => ref.cast<AnimationAction>().zeroSlopeAtEnd = v.boolValue()}))
    // ===== 播放控制（链式返回自身） =====
    b.method("play") {
        ref, _ =>
            ref.cast<AnimationAction>().play()
            [LuaValue.Object(ref.id)]
    }
    b.method("stop") {
        ref, _ =>
            ref.cast<AnimationAction>().stop()
            [LuaValue.Object(ref.id)]
    }
    b.method("reset") {
        ref, _ =>
            ref.cast<AnimationAction>().reset()
            [LuaValue.Object(ref.id)]
    }
    b.method("startAt") {
        ref, args =>
            ref.cast<AnimationAction>().startAt(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setLoop") {
        ref, args =>
            ref.cast<AnimationAction>().setLoop(prebindInt(args, 0), prebindNum(args, 1, default: 1.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("halt") {
        ref, args =>
            ref.cast<AnimationAction>().halt(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 权重 =====
    b.method("setEffectiveWeight") {
        ref, args =>
            ref.cast<AnimationAction>().setEffectiveWeight(prebindNum(args, 0, default: 1.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getEffectiveWeight") {
        ref, _ => [LuaValue.of(ref.cast<AnimationAction>().getEffectiveWeight())]
    }
    b.method("fadeIn") {
        ref, args =>
            ref.cast<AnimationAction>().fadeIn(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("fadeOut") {
        ref, args =>
            ref.cast<AnimationAction>().fadeOut(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("stopFading") {
        ref, _ =>
            ref.cast<AnimationAction>().stopFading()
            [LuaValue.Object(ref.id)]
    }
    // ===== 时间缩放与时长 =====
    b.method("setEffectiveTimeScale") {
        ref, args =>
            ref.cast<AnimationAction>().setEffectiveTimeScale(prebindNum(args, 0, default: 1.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getEffectiveTimeScale") {
        ref, _ => [LuaValue.of(ref.cast<AnimationAction>().getEffectiveTimeScale())]
    }
    b.method("setDuration") {
        ref, args =>
            ref.cast<AnimationAction>().setDuration(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("syncWith") {
        ref, args =>
            ref.cast<AnimationAction>().syncWith(prebindAs<AnimationAction>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("warp") {
        ref, args =>
            ref
                .cast<AnimationAction>()
                .warp(prebindNum(args, 0, default: 1.0), prebindNum(args, 1, default: 1.0), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("stopWarping") {
        ref, _ =>
            ref.cast<AnimationAction>().stopWarping()
            [LuaValue.Object(ref.id)]
    }
    // ===== 交叉淡入淡出 =====
    b.method("crossFadeFrom") {
        ref, args =>
            ref
                .cast<AnimationAction>()
                .crossFadeFrom(prebindAs<AnimationAction>(args, 0), prebindNum(args, 1), warp: prebindBool(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("crossFadeTo") {
        ref, args =>
            ref
                .cast<AnimationAction>()
                .crossFadeTo(prebindAs<AnimationAction>(args, 0), prebindNum(args, 1), warp: prebindBool(args, 2))
            [LuaValue.Object(ref.id)]
    }
    // ===== 状态查询 =====
    b.method("isRunning") {
        ref, _ => [LuaValue.of(ref.cast<AnimationAction>().isRunning())]
    }
    b.method("isScheduled") {
        ref, _ => [LuaValue.of(ref.cast<AnimationAction>().isScheduled())]
    }
    b.install(vm)
}
