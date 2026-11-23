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
 * @file[zh-cn] audio_mixer_filter EFX 滤波器 AudioFilter 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.audio.mixer.AudioFilter 绑定为 Lua 类型 three.audio.mixer.AudioFilter
 * @explain[zh-cn] 构造接受可选音频上下文（缺省用 AudioContext.context 单例）；
 * filterId / context（只读）属性、getFilterId、create、setType、setParamf、releasable
 * 属性与 release()，以及 3 个预设工厂静态方法（低通 / 高通 / 带通）。
 * FilterType 枚举无 Lua 通道，setType 以整数暴露（0=Null 1=Lowpass 2=Highpass
 * 3=Bandpass）。
 *
 * @file[en] audio_mixer_filter  Lua binding of the EFX filter AudioFilter
 * (three.script.prebind)
 * @brief[en] Binds three.audio.mixer.AudioFilter as the Lua type three.audio.mixer.AudioFilter
 * @explain[en] The constructor takes an optional audio context (defaults to the
 * AudioContext.context singleton); filterId / context (read-only) properties, getFilterId,
 * create, setType, setParamf, the releasable property and release(), plus the three preset
 * factory static methods (lowpass / highpass / bandpass). The FilterType enum has no Lua
 * channel, so setType takes an integer (0=Null 1=Lowpass 2=Highpass 3=Bandpass).
 */
package three.script.prebind

import openalsoft4cj.efx.FilterType
import three.audio.mixer.AudioFilter
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 整数 → FilterType（未知值回退 Null）
 * @param[zh-cn] v 滤波器类型数值
 * @return[zh-cn] 对应枚举成员
 *
 * @brief[en] Integer → FilterType (unknown values fall back to Null)
 * @param[en] v The filter-type numeric value
 * @return[en] The matching enum member
 */
private func _prebindFilterTypeFrom(v: Int64): FilterType {
    match (v) {
        case 0 => FilterType.Null
        case 1 => FilterType.Lowpass
        case 2 => FilterType.Highpass
        case 3 => FilterType.Bandpass
        case _ => FilterType.Null
    }
}

/**
 * @brief[zh-cn] 安装 AudioFilter 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.mixer.AudioFilter）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioFilter
 * @param[en] vm The target virtual machine (class table installed at three.audio.mixer.AudioFilter)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioFilter(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.mixer.AudioFilter")
    // ===== 构造（可选音频上下文） =====
    b.constructor {
        args => if (let Some(ctx) <- _prebindOptAudioContext(args, 0)) {
            AudioFilter(context: ctx)
        } else {
            AudioFilter()
        }
    }
    // ===== 属性 =====
    b.property("filterId", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioFilter>().filterId))}),
        setter: Some({ref, v => ref.cast<AudioFilter>().filterId = UInt32(v.intValue())}))
    b.property("context",
        getter: Some({ref => prebindRegister(ref.cast<AudioFilter>().context, "three.audio.device.AudioContext")}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<AudioFilter>().releasable)}))
    // ===== 创建 / 配置 =====
    b.method("getFilterId") {
        ref, _ => [LuaValue.of(Int64(ref.cast<AudioFilter>().getFilterId()))]
    }
    b.method("create") {
        ref, _ =>
            ref.cast<AudioFilter>().create()
            [LuaValue.Object(ref.id)]
    }
    b.method("setType") {
        ref, args =>
            ref.cast<AudioFilter>().setType(_prebindFilterTypeFrom(prebindInt(args, 0)))
            [LuaValue.Object(ref.id)]
    }
    b.method("setParamf") {
        ref, args =>
            ref.cast<AudioFilter>().setParamf(UInt32(prebindInt(args, 0)), Float32(prebindNum(args, 1)))
            [LuaValue.Object(ref.id)]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<AudioFilter>().release())]
    }
    // ===== 预设工厂（首参可选音频上下文） =====
    b.staticMethod("createLowpassFilter") {
        args => [prebindRegister(
            AudioFilter.createLowpassFilter(context: _prebindEffectCtx(args, 0),
                gain: Float32(prebindNum(args, 1, default: 1.0)), gainHF: Float32(prebindNum(args, 2, default: 0.5))),
            "three.audio.mixer.AudioFilter")]
    }
    b.staticMethod("createHighpassFilter") {
        args => [prebindRegister(
            AudioFilter.createHighpassFilter(context: _prebindEffectCtx(args, 0),
                gain: Float32(prebindNum(args, 1, default: 1.0)), gainLF: Float32(prebindNum(args, 2, default: 0.5))),
            "three.audio.mixer.AudioFilter")]
    }
    b.staticMethod("createBandpassFilter") {
        args => [prebindRegister(
            AudioFilter.createBandpassFilter(context: _prebindEffectCtx(args, 0),
                gain: Float32(prebindNum(args, 1, default: 1.0)), gainLF: Float32(prebindNum(args, 2, default: 1.0)),
                gainHF: Float32(prebindNum(args, 3, default: 1.0))), "three.audio.mixer.AudioFilter")]
    }
    b.install(vm)
}
