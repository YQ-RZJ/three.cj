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
 * @file[zh-cn] audio_mixer_effect EFX 效果对象 AudioEffect 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.audio.mixer.AudioEffect 绑定为 Lua 类型 three.audio.mixer.AudioEffect
 * @explain[zh-cn] 构造接受可选音频上下文（缺省用 AudioContext.context 单例）；
 * effectId / context（只读）属性、getEffectId、create、setType、setParamf、setParami、
 * releasable 属性与 release()，以及 13 个预设工厂静态方法。
 * EffectType 枚举无 Lua 通道，setType 以整数暴露（0=Null 1=Reverb 2=Chorus
 * 3=Distortion 4=Echo 5=Flanger 6=FrequencyShifter 7=VocalMorpher 8=PitchShifter
 * 9=RingModulator 10=Autowah 11=Compressor 12=Equalizer 32768=EaxReverb）。
 * setParamfv 接收 CPointer<Float32>，按项目约定不暴露给 Lua。
 *
 * @file[en] audio_mixer_effect  Lua binding of the EFX effect object AudioEffect
 * (three.script.prebind)
 * @brief[en] Binds three.audio.mixer.AudioEffect as the Lua type three.audio.mixer.AudioEffect
 * @explain[en] The constructor takes an optional audio context (defaults to the
 * AudioContext.context singleton); effectId / context (read-only) properties, getEffectId,
 * create, setType, setParamf, setParami, the releasable property and release(), plus the
 * 13 preset factory static methods. The EffectType enum has no Lua channel, so setType takes
 * an integer (0=Null 1=Reverb 2=Chorus 3=Distortion 4=Echo 5=Flanger 6=FrequencyShifter
 * 7=VocalMorpher 8=PitchShifter 9=RingModulator 10=Autowah 11=Compressor 12=Equalizer
 * 32768=EaxReverb). setParamfv takes a CPointer<Float32>, which the project convention
 * keeps away from Lua.
 */
package three.script.prebind

import three._vendor.openalsoft4cj.efx.EffectType
import three._vendor.openalsoft4cj.efx.{AL_VOCAL_MORPHER_PHONEME_A, AL_VOCAL_MORPHER_PHONEME_I}
import three.audio.device.AudioContext
import three.audio.mixer.AudioEffect
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 整数 → EffectType（未知值回退 Null）
 * @param[zh-cn] v 效果类型数值
 * @return[zh-cn] 对应枚举成员
 *
 * @brief[en] Integer → EffectType (unknown values fall back to Null)
 * @param[en] v The effect-type numeric value
 * @return[en] The matching enum member
 */
private func _prebindEffectTypeFrom(v: Int64): EffectType {
    match (v) {
        case 0 => EffectType.Null
        case 1 => EffectType.Reverb
        case 2 => EffectType.Chorus
        case 3 => EffectType.Distortion
        case 4 => EffectType.Echo
        case 5 => EffectType.Flanger
        case 6 => EffectType.FrequencyShifter
        case 7 => EffectType.VocalMorpher
        case 8 => EffectType.PitchShifter
        case 9 => EffectType.RingModulator
        case 10 => EffectType.Autowah
        case 11 => EffectType.Compressor
        case 12 => EffectType.Equalizer
        case 32768 => EffectType.EaxReverb
        case _ => EffectType.Null
    }
}

/**
 * @brief[zh-cn] 安装 AudioEffect 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.mixer.AudioEffect）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioEffect
 * @param[en] vm The target virtual machine (class table installed at three.audio.mixer.AudioEffect)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioEffect(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.mixer.AudioEffect")
    // ===== 构造（可选音频上下文） =====
    b.constructor {
        args => if (let Some(ctx) <- _prebindOptAudioContext(args, 0)) {
            AudioEffect(context: ctx)
        } else {
            AudioEffect()
        }
    }
    // ===== 属性 =====
    b.property("effectId", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioEffect>().effectId))}),
        setter: Some({ref, v => ref.cast<AudioEffect>().effectId = UInt32(v.intValue())}))
    b.property("context",
        getter: Some({ref => prebindRegister(ref.cast<AudioEffect>().context, "three.audio.device.AudioContext")}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<AudioEffect>().releasable)}))
    // ===== 创建 / 配置 =====
    b.method("getEffectId") {
        ref, _ => [LuaValue.of(Int64(ref.cast<AudioEffect>().getEffectId()))]
    }
    b.method("create") {
        ref, _ =>
            ref.cast<AudioEffect>().create()
            [LuaValue.Object(ref.id)]
    }
    b.method("setType") {
        ref, args =>
            ref.cast<AudioEffect>().setType(_prebindEffectTypeFrom(prebindInt(args, 0)))
            [LuaValue.Object(ref.id)]
    }
    b.method("setParamf") {
        ref, args =>
            ref.cast<AudioEffect>().setParamf(UInt32(prebindInt(args, 0)), Float32(prebindNum(args, 1)))
            [LuaValue.Object(ref.id)]
    }
    b.method("setParami") {
        ref, args =>
            ref.cast<AudioEffect>().setParami(UInt32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
            [LuaValue.Object(ref.id)]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<AudioEffect>().release())]
    }
    // ===== 预设工厂（首参可选音频上下文） =====
    b.staticMethod("createReverbEffect") {
        args => [prebindRegister(
            AudioEffect.createReverbEffect(context: _prebindEffectCtx(args, 0),
                density: Float32(prebindNum(args, 1, default: 1.0)), diffusion: Float32(prebindNum(args, 2, default: 1.0)),
                gain: Float32(prebindNum(args, 3, default: 0.32)), decayTime: Float32(prebindNum(args, 4, default: 1.49))),
            "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createEaxReverbEffect") {
        args => [prebindRegister(
            AudioEffect.createEaxReverbEffect(context: _prebindEffectCtx(args, 0),
                density: Float32(prebindNum(args, 1, default: 1.0)), diffusion: Float32(prebindNum(args, 2, default: 1.0)),
                gain: Float32(prebindNum(args, 3, default: 0.32)), decayTime: Float32(prebindNum(args, 4, default: 1.49))),
            "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createChorusEffect") {
        args => [prebindRegister(AudioEffect.createChorusEffect(context: _prebindEffectCtx(args, 0)),
            "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createEchoEffect") {
        args => [prebindRegister(AudioEffect.createEchoEffect(context: _prebindEffectCtx(args, 0)),
            "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createEqualizerEffect") {
        args => [prebindRegister(AudioEffect.createEqualizerEffect(context: _prebindEffectCtx(args, 0)),
            "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createDistortionEffect") {
        args => [prebindRegister(
            AudioEffect.createDistortionEffect(context: _prebindEffectCtx(args, 0),
                edge: Float32(prebindNum(args, 1, default: 0.2)), gain: Float32(prebindNum(args, 2, default: 0.05)),
                lowpassCutoff: Float32(prebindNum(args, 3, default: 8000.0)),
                eqCenter: Float32(prebindNum(args, 4, default: 3600.0)),
                eqBandwidth: Float32(prebindNum(args, 5, default: 3600.0))), "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createFlangerEffect") {
        args => [prebindRegister(
            AudioEffect.createFlangerEffect(context: _prebindEffectCtx(args, 0),
                rate: Float32(prebindNum(args, 1, default: 0.27)), depth: Float32(prebindNum(args, 2, default: 1.0)),
                delay: Float32(prebindNum(args, 3, default: 0.002)), feedback: Float32(prebindNum(args, 4, default: -0.5))),
            "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createFrequencyShifterEffect") {
        args => [prebindRegister(
            AudioEffect.createFrequencyShifterEffect(context: _prebindEffectCtx(args, 0),
                frequency: Float32(prebindNum(args, 1, default: 0.0)),
                leftDirection: Int32(prebindInt(args, 2, default: 1)),
                rightDirection: Int32(prebindInt(args, 3, default: 1))), "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createPitchShifterEffect") {
        args => [prebindRegister(
            AudioEffect.createPitchShifterEffect(context: _prebindEffectCtx(args, 0),
                coarseTune: Int32(prebindInt(args, 1)), fineTune: Int32(prebindInt(args, 2))),
            "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createRingModulatorEffect") {
        args => [prebindRegister(
            AudioEffect.createRingModulatorEffect(context: _prebindEffectCtx(args, 0),
                frequency: Float32(prebindNum(args, 1, default: 440.0)),
                highpassCutoff: Float32(prebindNum(args, 2, default: 800.0)), waveform: Int32(prebindInt(args, 3))),
            "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createAutowahEffect") {
        args => [prebindRegister(
            AudioEffect.createAutowahEffect(context: _prebindEffectCtx(args, 0),
                attackTime: Float32(prebindNum(args, 1, default: 0.06)),
                releaseTime: Float32(prebindNum(args, 2, default: 0.06)),
                resonance: Float32(prebindNum(args, 3, default: 1000.0)),
                peakGain: Float32(prebindNum(args, 4, default: 11.22))), "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createCompressorEffect") {
        args => [prebindRegister(
            AudioEffect.createCompressorEffect(context: _prebindEffectCtx(args, 0),
                onoff: Int32(prebindInt(args, 1, default: 1))), "three.audio.mixer.AudioEffect")]
    }
    b.staticMethod("createVocalMorpherEffect") {
        args => [prebindRegister(
            AudioEffect.createVocalMorpherEffect(context: _prebindEffectCtx(args, 0),
                phonemeA: Int32(prebindInt(args, 1, default: Int64(AL_VOCAL_MORPHER_PHONEME_A))),
                phonemeB: Int32(prebindInt(args, 2, default: Int64(AL_VOCAL_MORPHER_PHONEME_I))),
                rate: Float32(prebindNum(args, 3, default: 1.41))), "three.audio.mixer.AudioEffect")]
    }
    b.install(vm)
}
