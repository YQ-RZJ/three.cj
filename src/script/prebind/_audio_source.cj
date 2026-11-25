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
 * @file[zh-cn] audio_source 音频源（Audio / PositionalAudio / StreamingAudio）的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.audio.source 的三个音频源类绑定为 Lua 类型
 * @explain[zh-cn] 三个类共用同一套 Audio 成员（属性 + 播放控制 + 音量/循环/速率/音调 +
 * EFX 接入），由 _installAudioMembers 统一登记到各自的 metatable（绑定层无 __index
 * 继承链，子类需重复登记基类成员）。
 * - Audio：无参构造（隐式创建监听器）或 listener 构造；
 * - PositionalAudio：可选 listener 构造，附加参考距离 / 滚降因子 / 最大距离 / 距离模型 /
 *   方向性锥体 / 速度（Vector3 对象通道）；
 * - StreamingAudio：无参或 listener 构造，附加 load(filePath) / updateStream()。
 * buffer 属性为 Option<AudioBuffer>（Lua 传对象即 Some，传 nil 即 None）；
 * getSourceState 返回 SourceState 枚举，无 Lua 通道，按 OpenAL 原始值以整数暴露
 * （0x1011=Initial 0x1012=Playing 0x1013=Paused 0x1014=Stopped）。
 * 三个类均继承 Object3D，但 Object3D 尚未绑定，故父类成员（position 等）在 Lua 侧不可用。
 *
 * @file[en] audio_source  Lua bindings of the audio sources (Audio / PositionalAudio / StreamingAudio)
 * (three.script.prebind)
 * @brief[en] Binds the three audio-source classes of three.audio.source as Lua types
 * @explain[en] The three classes share the Audio member set (properties + playback control +
 * volume/loop/rate/detune + EFX wiring), registered by _installAudioMembers on each own
 * metatable (the binding layer has no __index inheritance chain, so subclasses repeat the
 * base members).
 * - Audio: the parameterless constructor (implicitly creating a listener) or the listener one;
 * - PositionalAudio: an optional listener constructor plus refDistance / rolloffFactor /
 *   maxDistance / distanceModel / directional cone / velocity (Vector3 object channel);
 * - StreamingAudio: the parameterless or listener constructor plus load(filePath) / updateStream().
 * The buffer property is Option<AudioBuffer> (an object means Some, nil means None);
 * getSourceState returns the SourceState enum, which has no Lua channel, so the OpenAL raw
 * values are exposed as integers (0x1011=Initial 0x1012=Playing 0x1013=Paused 0x1014=Stopped).
 * All three extend Object3D, which is not bound yet, so the parent members (position, ...)
 * are unavailable from Lua.
 */
package three.script.prebind

import three._vendor.openalsoft4cj.al.SourceState
import three.audio._interfaces.IAudioEffectSlot
import three.audio._interfaces.IAudioFilter
import three.audio.listener.AudioListener
import three.audio.mixer.AudioFilter
import three.audio.source.Audio
import three.audio.source.AudioBuffer
import three.audio.source.PositionalAudio
import three.audio.source.StreamingAudio
import three.core.math.Vector3
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] SourceState → OpenAL 原始整数值
 * @param[zh-cn] s 源播放状态
 * @return[zh-cn] 0x1011=Initial / 0x1012=Playing / 0x1013=Paused / 0x1014=Stopped
 *
 * @brief[en] SourceState → OpenAL raw integer value
 * @param[en] s The source playback state
 * @return[en] 0x1011=Initial / 0x1012=Playing / 0x1013=Paused / 0x1014=Stopped
 */
private func _prebindSourceStateTo(s: SourceState): Int64 {
    match (s) {
        case SourceState.Initial => 0x1011
        case SourceState.Playing => 0x1012
        case SourceState.Paused => 0x1013
        case SourceState.Stopped => 0x1014
    }
}

/**
 * @brief[zh-cn] 读取可选监听器参数（缺省 / nil / 非对象 → None）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Some(AudioListener) 或 None
 *
 * @brief[en] Reads an optional listener argument (absent / nil / non-object → None)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] Some(AudioListener) or None
 */
private func _prebindOptListener(args: Array<LuaValue>, idx: Int64): Option<AudioListener> {
    if (args.size <= idx || args[idx].isNil || !args[idx].isObject) {
        return None
    }
    return Some(LuaObjectRegistry.getAs<AudioListener>(args[idx].objectId()))
}

/**
 * @brief[zh-cn] 读取可选滤波器参数（缺省 / nil / 非对象 → None）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Some(IAudioFilter) 或 None
 *
 * @brief[en] Reads an optional filter argument (absent / nil / non-object → None)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] Some(IAudioFilter) or None
 */
private func _prebindOptFilter(args: Array<LuaValue>, idx: Int64): Option<IAudioFilter> {
    if (args.size <= idx || args[idx].isNil || !args[idx].isObject) {
        return None
    }
    return Some(LuaObjectRegistry.getAs<AudioFilter>(args[idx].objectId()))
}

/**
 * @brief[zh-cn] 登记 Audio 家族共有成员（属性 + 播放控制 + EFX 接入 + 释放）
 * @param[zh-cn] b 类绑定器（Audio 或继承它的子类）
 *
 * @brief[en] Registers the members shared by the Audio family
 * (properties + playback control + EFX wiring + release)
 * @param[en] b The class binder (Audio or a subclass)
 */
internal func _installAudioMembers(b: LuaClassBinder): Unit {
    // ===== 属性 =====
    b.property("listener",
        getter: Some({ref => prebindRegister(ref.cast<Audio>().listener, "three.audio.listener.AudioListener")}))
    b.property("context",
        getter: Some({ref => prebindRegister(ref.cast<Audio>().context, "three.audio.device.AudioContext")}))
    b.property("sourceId", getter: Some({ref => LuaValue.of(Int64(ref.cast<Audio>().sourceId))}))
    b.property("buffer", getter: Some({
        ref => if (let Some(buf) <- ref.cast<Audio>().buffer) {
            prebindRegister(buf, "three.audio.source.AudioBuffer")
        } else {
            LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isNil) {
            ref.cast<Audio>().buffer = None
        } else {
            ref.cast<Audio>().buffer = Some(LuaObjectRegistry.getAs<AudioBuffer>(v.objectId()))
        }
    }))
    b.property("autoplay", getter: Some({ref => LuaValue.of(ref.cast<Audio>().autoplay)}),
        setter: Some({ref, v => ref.cast<Audio>().autoplay = v.boolValue()}))
    b.property("gain", getter: Some({ref => LuaValue.of(ref.cast<Audio>().gain)}),
        setter: Some({ref, v => ref.cast<Audio>().gain = v.numberValue()}))
    b.property("isPlaying", getter: Some({ref => LuaValue.of(ref.cast<Audio>().isPlaying)}),
        setter: Some({ref, v => ref.cast<Audio>().isPlaying = v.boolValue()}))
    b.property("loop", getter: Some({ref => LuaValue.of(ref.cast<Audio>().loop)}),
        setter: Some({ref, v => ref.cast<Audio>().loop = v.boolValue()}))
    b.property("offset", getter: Some({ref => LuaValue.of(ref.cast<Audio>().offset)}),
        setter: Some({ref, v => ref.cast<Audio>().offset = v.numberValue()}))
    b.property("playbackRate", getter: Some({ref => LuaValue.of(ref.cast<Audio>().playbackRate)}),
        setter: Some({ref, v => ref.cast<Audio>().playbackRate = v.numberValue()}))
    b.property("hasPlaybackControl", getter: Some({ref => LuaValue.of(ref.cast<Audio>().hasPlaybackControl)}),
        setter: Some({ref, v => ref.cast<Audio>().hasPlaybackControl = v.boolValue()}))
    b.property("detune", getter: Some({ref => LuaValue.of(ref.cast<Audio>().detune)}),
        setter: Some({ref, v => ref.cast<Audio>().detune = v.numberValue()}))
    b.property("sourceType", getter: Some({ref => LuaValue.of(ref.cast<Audio>().sourceType)}),
        setter: Some({ref, v => ref.cast<Audio>().sourceType = v.stringValue()}))
    b.property("isAudio", getter: Some({ref => LuaValue.of(ref.cast<Audio>().isAudio)}))
    // ===== 播放控制（返回 Audio 的方法回传自身 id） =====
    b.method("getOutput") {
        ref, _ => [LuaValue.of(Int64(ref.cast<Audio>().getOutput()))]
    }
    b.method("setBuffer") {
        ref, args =>
            ref.cast<Audio>().setBuffer(prebindAs<AudioBuffer>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("play") {
        ref, args =>
            if (args.size > 0 && !args[0].isNil) {
                ref.cast<Audio>().play(prebindNum(args, 0))
            } else {
                ref.cast<Audio>().play()
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("pause") {
        ref, _ =>
            ref.cast<Audio>().pause()
            [LuaValue.Object(ref.id)]
    }
    b.method("stop") {
        ref, _ =>
            ref.cast<Audio>().stop()
            [LuaValue.Object(ref.id)]
    }
    b.method("disconnect") {
        ref, _ =>
            ref.cast<Audio>().disconnect()
            [LuaValue.Object(ref.id)]
    }
    // ===== 音量 / 循环 / 速率 / 音调 =====
    b.method("setVolume") {
        ref, args =>
            ref.cast<Audio>().setVolume(prebindNum(args, 0, default: 1.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getVolume") {
        ref, _ => [LuaValue.of(ref.cast<Audio>().getVolume())]
    }
    b.method("setLoop") {
        ref, args =>
            ref.cast<Audio>().setLoop(prebindBool(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getLoop") {
        ref, _ => [LuaValue.of(ref.cast<Audio>().getLoop())]
    }
    b.method("setPlaybackRate") {
        ref, args =>
            ref.cast<Audio>().setPlaybackRate(prebindNum(args, 0, default: 1.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getPlaybackRate") {
        ref, _ => [LuaValue.of(ref.cast<Audio>().getPlaybackRate())]
    }
    b.method("setDetune") {
        ref, args =>
            ref.cast<Audio>().setDetune(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getDetune") {
        ref, _ => [LuaValue.of(ref.cast<Audio>().getDetune())]
    }
    b.method("getSourceState") {
        ref, _ => [LuaValue.of(_prebindSourceStateTo(ref.cast<Audio>().getSourceState()))]
    }
    // ===== EFX 效果接入 =====
    b.method("setDirectFilter") {
        ref, args =>
            ref.cast<Audio>().setDirectFilter(prebindAs<AudioFilter>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("removeDirectFilter") {
        ref, _ =>
            ref.cast<Audio>().removeDirectFilter()
            [LuaValue.Object(ref.id)]
    }
    b.method("connectEffectSlot") {
        ref, args =>
            ref
                .cast<Audio>()
                .connectEffectSlot(prebindAs<IAudioEffectSlot>(args, 0), Int32(prebindInt(args, 1)),
                    filter: _prebindOptFilter(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("disconnectEffectSlot") {
        ref, args =>
            ref.cast<Audio>().disconnectEffectSlot(Int32(prebindInt(args, 0)))
            [LuaValue.Object(ref.id)]
    }
    // ===== 释放 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<Audio>().release())]
    }
}

/**
 * @brief[zh-cn] 安装 Audio 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.source.Audio）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Audio
 * @param[en] vm The target virtual machine (class table installed at three.audio.source.Audio)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudio(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.source.Audio")
    // ===== 构造：无参（隐式创建监听器）或 listener =====
    b.constructor {
        args => if (let Some(listener) <- _prebindOptListener(args, 0)) {
            Audio(listener: listener)
        } else {
            Audio()
        }
    }
    _installAudioMembers(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PositionalAudio 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.source.PositionalAudio）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PositionalAudio
 * @param[en] vm The target virtual machine (class table installed at three.audio.source.PositionalAudio)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPositionalAudio(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.source.PositionalAudio")
    // ===== 构造（可选监听器，缺省由引擎创建） =====
    b.constructor {
        args => if (let Some(listener) <- _prebindOptListener(args, 0)) {
            PositionalAudio(listener: listener)
        } else {
            PositionalAudio()
        }
    }
    _installAudioMembers(b)
    // ===== 3D 空间属性 =====
    b.property("refDistance", getter: Some({ref => LuaValue.of(ref.cast<PositionalAudio>().refDistance)}),
        setter: Some({ref, v => ref.cast<PositionalAudio>().refDistance = v.numberValue()}))
    b.property("rolloffFactor", getter: Some({ref => LuaValue.of(ref.cast<PositionalAudio>().rolloffFactor)}),
        setter: Some({ref, v => ref.cast<PositionalAudio>().rolloffFactor = v.numberValue()}))
    b.property("maxDistance", getter: Some({ref => LuaValue.of(ref.cast<PositionalAudio>().maxDistance)}),
        setter: Some({ref, v => ref.cast<PositionalAudio>().maxDistance = v.numberValue()}))
    b.property("distanceModel", getter: Some({ref => LuaValue.of(ref.cast<PositionalAudio>().distanceModel)}),
        setter: Some({ref, v => ref.cast<PositionalAudio>().distanceModel = v.intValue()}))
    b.property("coneInnerAngle", getter: Some({ref => LuaValue.of(ref.cast<PositionalAudio>().coneInnerAngle)}),
        setter: Some({ref, v => ref.cast<PositionalAudio>().coneInnerAngle = v.numberValue()}))
    b.property("coneOuterAngle", getter: Some({ref => LuaValue.of(ref.cast<PositionalAudio>().coneOuterAngle)}),
        setter: Some({ref, v => ref.cast<PositionalAudio>().coneOuterAngle = v.numberValue()}))
    b.property("coneOuterGain", getter: Some({ref => LuaValue.of(ref.cast<PositionalAudio>().coneOuterGain)}),
        setter: Some({ref, v => ref.cast<PositionalAudio>().coneOuterGain = v.numberValue()}))
    b.property("velocity",
        getter: Some({ref => prebindRegister(ref.cast<PositionalAudio>().velocity, "three.core.math.Vector3")}),
        setter: Some({
            ref, v => ref.cast<PositionalAudio>().velocity = LuaObjectRegistry.getAs<Vector3>(v.objectId())
        }))
    // ===== 距离 / 锥体 / 速度（返回 PositionalAudio 的方法回传自身 id） =====
    b.method("setRefDistance") {
        ref, args =>
            ref.cast<PositionalAudio>().setRefDistance(prebindNum(args, 0, default: 1.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getRefDistance") {
        ref, _ => [LuaValue.of(ref.cast<PositionalAudio>().getRefDistance())]
    }
    b.method("setRolloffFactor") {
        ref, args =>
            ref.cast<PositionalAudio>().setRolloffFactor(prebindNum(args, 0, default: 1.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getRolloffFactor") {
        ref, _ => [LuaValue.of(ref.cast<PositionalAudio>().getRolloffFactor())]
    }
    b.method("setDistanceModel") {
        ref, args =>
            ref.cast<PositionalAudio>().setDistanceModel(prebindInt(args, 0, default: 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("getDistanceModel") {
        ref, _ => [LuaValue.of(ref.cast<PositionalAudio>().getDistanceModel())]
    }
    b.method("setMaxDistance") {
        ref, args =>
            ref.cast<PositionalAudio>().setMaxDistance(prebindNum(args, 0, default: 10000.0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getMaxDistance") {
        ref, _ => [LuaValue.of(ref.cast<PositionalAudio>().getMaxDistance())]
    }
    b.method("setDirectionalCone") {
        ref, args =>
            ref
                .cast<PositionalAudio>()
                .setDirectionalCone(coneInnerAngle: prebindNum(args, 0, default: 360.0),
                    coneOuterAngle: prebindNum(args, 1, default: 360.0), coneOuterGain: prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setVelocity") {
        ref, args =>
            ref.cast<PositionalAudio>().setVelocity(LuaObjectRegistry.getAs<Vector3>(args[0].objectId()))
            [LuaValue.Object(ref.id)]
    }
    b.method("getVelocity") {
        ref, _ => [prebindRegister(ref.cast<PositionalAudio>().getVelocity(), "three.core.math.Vector3")]
    }
    // ===== 世界变换同步 =====
    b.method("updateMatrixWorld") {
        ref, args =>
            ref.cast<PositionalAudio>().updateMatrixWorld(prebindBool(args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 StreamingAudio 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.source.StreamingAudio）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of StreamingAudio
 * @param[en] vm The target virtual machine (class table installed at three.audio.source.StreamingAudio)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installStreamingAudio(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.source.StreamingAudio")
    // ===== 构造：无参或 listener =====
    b.constructor {
        args => if (let Some(listener) <- _prebindOptListener(args, 0)) {
            StreamingAudio(listener: listener)
        } else {
            StreamingAudio()
        }
    }
    _installAudioMembers(b)
    // ===== 流式解码与刷新 =====
    b.method("load") {
        ref, args =>
            ref.cast<StreamingAudio>().load(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("updateStream") {
        ref, _ =>
            ref.cast<StreamingAudio>().updateStream()
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
