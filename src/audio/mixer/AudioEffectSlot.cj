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
 * @file[zh-cn] AudioEffectSlot EFX 辅助效果槽封装
 * @brief[zh-cn] EFX 辅助效果槽：封装 OpenAL AuxiliaryEffectSlot 句柄
 * @explain[zh-cn] 效果槽是"效果实例的容器"：将一个 AudioEffect 装入槽中，
 * 再由 Audio 源通过 connectEffectSlot 将发送路径连接到该槽，
 * 即可让源的输出经效果处理后混合到最终输出。
 * 信号流：
 * Source ──(direct)──────────────────► Listener
 * Source ──(send 0)──► EffectSlot ──► Listener
 * └─ Effect (Reverb/Chorus/...)
 * 用法：
 * let reverb = AudioEffect.createReverbEffect()
 * let slot = AudioEffectSlot()
 * slot.setEffect(reverb)
 * audio.connectEffectSlot(slot, 0)
 * 所有 OpenAL EFX 调用经 AudioContext.execAudio 序列化到音频线程。
 *
 * @file[en] AudioEffectSlot  EFX auxiliary effect slot wrapper
 * @brief[en] EFX auxiliary effect slot: wraps an OpenAL AuxiliaryEffectSlot handle
 * @explain[en] An effect slot is a "container for an effect instance": load an AudioEffect
 * into the slot, then have an Audio source connect its send path to the slot via
 * connectEffectSlot, so the source's output is processed by the effect and mixed
 * into the final output.
 * Signal flow:
 * Source ──(direct)──────────────────► Listener
 * Source ──(send 0)──► EffectSlot ──► Listener
 * └─ Effect (Reverb/Chorus/...)
 * Usage:
 * let reverb = AudioEffect.createReverbEffect()
 * let slot = AudioEffectSlot()
 * slot.setEffect(reverb)
 * audio.connectEffectSlot(slot, 0)
 * All OpenAL EFX calls are serialized onto the audio thread via AudioContext.execAudio.
 */
package three.audio.mixer

import openalsoft4cj.efx.*

import three.audio.device.*
import three.audio.interfaces.*

/**
 * @brief[zh-cn] EFX 辅助效果槽，封装 OpenAL AuxiliaryEffectSlot 句柄
 * @explain[zh-cn] 一个效果槽绑定一个 AudioEffect 实例。多个源可发送到同一效果槽
 * （共享同一效果实例），也可发送到不同效果槽（各自独立效果）。
 *
 * @brief[en] EFX auxiliary effect slot wrapping an OpenAL AuxiliaryEffectSlot handle
 * @explain[en] One effect slot is bound to one AudioEffect instance. Multiple sources can
 * send to the same slot (sharing one effect instance) or to different slots
 * (each with its own independent effect).
 */
public class AudioEffectSlot <: IAudioEffectSlot {
    /**
     * @brief[zh-cn] OpenAL 效果槽句柄
     *
     * @brief[en] The OpenAL effect slot handle
     */
    public var slotId: UInt32

    /**
     * @brief[zh-cn] 关联的音频上下文
     *
     * @brief[en] The associated audio context
     */
    public var context: AudioContext

    /**
     * @brief[zh-cn] 是否已释放
     *
     * @brief[en] Whether the object has been disposed
     */
    private var _disposed: Bool

    /**
     * @brief[zh-cn] 创建音频效果槽
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     *
     * @brief[en] Creates an audio effect slot
     * @param[en] context The audio context (defaults to the AudioContext.context singleton)
     */
    public init(context!: AudioContext = AudioContext.context) {
        this.context = context
        this.slotId = 0u32
        this._disposed = false
    }

    /**
     * @brief[zh-cn] 接口实现：获取 OpenAL 效果槽句柄
     * @return[zh-cn] OpenAL 效果槽句柄（ALuint）
     *
     * @brief[en] Interface implementation: returns the OpenAL effect slot handle
     * @return[en] The OpenAL effect slot handle (ALuint)
     */
    public func getSlotId(): UInt32 { slotId }

    /**
     * @brief[zh-cn] 创建并生成 OpenAL 效果槽
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Creates and generates the OpenAL effect slot
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 在音频线程执行 alGenAuxiliaryEffectSlots；若已创建则跳过。
     * @note[en] Runs alGenAuxiliaryEffectSlots on the audio thread; skips if already created.
     */
    public func create(): AudioEffectSlot {
        if (this.slotId != 0u32) { return this }
        this.context.execAudio({ =>
            let ptr = unsafe { LibC.malloc<UInt32>() }
            alGenAuxiliaryEffectSlots_cj(1, ptr)
            this.slotId = unsafe { ptr.read() }
            unsafe { LibC.free(ptr) }
        })
        return this
    }

    /**
     * @brief[zh-cn] 绑定效果到此效果槽
     * @param[zh-cn] effect 要绑定的 AudioEffect（需已 create 并 setType）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Binds an effect to this effect slot
     * @param[en] effect The AudioEffect to bind (must have been created and set a type)
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX: alAuxiliaryEffectSloti(slot, AL_EFFECTSLOT_EFFECT, effectId)。
     * @note[en] Maps to EFX: alAuxiliaryEffectSloti(slot, AL_EFFECTSLOT_EFFECT, effectId).
     */
    public func setEffect(effect: AudioEffect): AudioEffectSlot {
        if (this.slotId == 0u32) { this.create() }
        let sid = this.slotId
        let eid = effect.effectId
        this.context.execAudio({ => alAuxiliaryEffectSloti_cj(sid, AL_EFFECTSLOT_EFFECT, Int32(eid)) })
        return this
    }

    /**
     * @brief[zh-cn] 设置效果槽增益（控制效果输出的整体音量）
     * @param[zh-cn] value 增益（0.0~1.0）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the effect slot gain (overall volume of the effect output)
     * @param[en] value The gain (0.0~1.0)
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX: alAuxiliaryEffectSlotf(slot, AL_EFFECTSLOT_GAIN, value)。
     * @note[en] Maps to EFX: alAuxiliaryEffectSlotf(slot, AL_EFFECTSLOT_GAIN, value).
     */
    public func setGain(value: Float32): AudioEffectSlot {
        if (this.slotId == 0u32) { return this }
        let sid = this.slotId
        this.context.execAudio({ => alAuxiliaryEffectSlotf_cj(sid, AL_EFFECTSLOT_GAIN, value) })
        return this
    }

    /**
     * @brief[zh-cn] 清除效果槽绑定的效果（解绑）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Clears the effect bound to this effect slot (unbind)
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX: alAuxiliaryEffectSloti(slot, AL_EFFECTSLOT_EFFECT, AL_EFFECTSLOT_NULL)。
     * @note[en] Maps to EFX: alAuxiliaryEffectSloti(slot, AL_EFFECTSLOT_EFFECT, AL_EFFECTSLOT_NULL).
     */
    public func clearEffect(): AudioEffectSlot {
        if (this.slotId == 0u32) { return this }
        let sid = this.slotId
        this.context.execAudio({ => alAuxiliaryEffectSloti_cj(sid, AL_EFFECTSLOT_EFFECT, 0) })
        return this
    }

    /**
     * @brief[zh-cn] 释放 OpenAL 效果槽
     *
     * @brief[en] Releases the OpenAL effect slot
     *
     * @note[zh-cn] 对应 EFX: alDeleteAuxiliaryEffectSlots；释放后句柄归零，重复调用安全。
     * @note[en] Maps to EFX: alDeleteAuxiliaryEffectSlots; the handle is zeroed after release and repeated calls are safe.
     */
    public func dispose(): Unit {
        if (_disposed) { return }
        if (this.slotId != 0u32) {
            let sid = this.slotId
            this.context.execAudio({ =>
                let ptr = unsafe { LibC.malloc<UInt32>() }
                unsafe { ptr.write(sid) }
                alDeleteAuxiliaryEffectSlots_cj(1, ptr)
                unsafe { LibC.free(ptr) }
            })
            this.slotId = 0u32
        }
        _disposed = true
    }
}
