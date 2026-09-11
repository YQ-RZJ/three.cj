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
 * @file[zh-cn] Audio 非位置音频源
 * @brief[zh-cn] 非位置音频基类：封装 OpenAL Source + Buffer，继承 Object3D
 * @explain[zh-cn] Audio 播放的声音没有 3D 空间效果，始终以相同音量播放。
 * 若需 3D 空间音频，请使用 PositionalAudio。
 * 内部映射：
 * - Web Audio BufferSourceNode → OpenAL Source + Buffer
 * - Web Audio GainNode → OpenAL AL_GAIN 属性
 * - Web Audio AudioBuffer → three.audio.source.AudioBuffer（封装 OpenAL Buffer）
 *
 * @file[en] Audio non-positional audio source
 * @brief[en] Non-positional audio base class: wraps OpenAL Source + Buffer, extends Object3D
 * @explain[en] Audio plays sound without 3D spatial effects; it always plays at the same volume.
 * Use PositionalAudio for 3D spatial audio.
 * Internal mapping:
 * - Web Audio BufferSourceNode → OpenAL Source + Buffer
 * - Web Audio GainNode → OpenAL AL_GAIN attribute
 * - Web Audio AudioBuffer → three.audio.source.AudioBuffer (wraps an OpenAL Buffer)
 */
package three.audio.source

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import openalsoft4cj.al.*
import openalsoft4cj.alc.*
import openalsoft4cj.efx.*
import std.math.*

import three.audio.device.*
import three.audio.listener.*
import three.audio.mixer.*
import three.audio.interfaces.*

/**
 * @brief[zh-cn] 非位置音频基类，继承 Object3D
 * @explain[zh-cn] Audio 播放的声音没有 3D 空间效果，始终以相同音量播放；
 * 若需 3D 空间音频，请使用 PositionalAudio。
 *
 * @brief[en] Non-positional audio base class extending Object3D
 * @explain[en] Audio plays sound without 3D spatial effects, always at the same volume;
 * use PositionalAudio for 3D spatial audio.
 */
@JsonAdapter[polymorphic = true ; withSuperClass = Object3D]
public open class Audio <: Object3D {
    /**
     * @brief[zh-cn] 关联的监听器
     *
     * @brief[en] The associated audio listener
     */
    @JsonIgnore
    public var listener: AudioListener

    /**
     * @brief[zh-cn] 音频上下文
     *
     * @brief[en] The audio context
     */
    @JsonIgnore
    public var context: AudioContext

    /**
     * @brief[zh-cn] OpenAL 源 ID
     *
     * @brief[en] The OpenAL source ID
     */
    @JsonIgnore
    public var sourceId: UInt32

    /**
     * @brief[zh-cn] 音频缓冲区
     *
     * @brief[en] The audio buffer
     */
    @JsonIgnore
    public var buffer: Option<AudioBuffer>

    /**
     * @brief[zh-cn] 是否自动播放
     *
     * @brief[en] Whether to autoplay
     */
    public var autoplay: Bool

    /**
     * @brief[zh-cn] 音量增益（0.0 及以上）
     *
     * @brief[en] Volume gain (0.0 and above)
     */
    public var gain: Float64

    /**
     * @brief[zh-cn] 是否正在播放
     *
     * @brief[en] Whether currently playing
     */
    public var isPlaying: Bool

    /**
     * @brief[zh-cn] 是否循环播放
     *
     * @brief[en] Whether to loop playback
     */
    public var loop: Bool

    /**
     * @brief[zh-cn] 播放偏移（秒）
     *
     * @brief[en] Playback offset (seconds)
     */
    public var offset: Float64

    /**
     * @brief[zh-cn] 播放速率
     *
     * @brief[en] Playback rate
     */
    public var playbackRate: Float64

    /**
     * @brief[zh-cn] 是否可控制播放
     *
     * @brief[en] Whether playback control is available
     */
    public var hasPlaybackControl: Bool

    /**
     * @brief[zh-cn] 音调偏移（cent，±100 为半音）
     *
     * @brief[en] Detune in cents (100 cents = one semitone)
     */
    public var detune: Float64

    /**
     * @brief[zh-cn] 源类型："empty" | "buffer"
     *
     * @brief[en] Source type: "empty" | "buffer"
     */
    public var sourceType: String

    /**
     * @brief[zh-cn] 是否为 Audio 对象
     *
     * @brief[en] Whether this is an Audio object
     */
    public var isAudio: Bool

    /**
     * @brief[zh-cn] 创建非位置音频源
     * @param[zh-cn] listener 关联的音频监听器
     *
     * @brief[en] Creates a non-positional audio source
     * @param[en] listener The associated audio listener
     */
    public init() {
        this(listener: AudioListener())
    }
    public init(listener!: AudioListener) {
        // 仓颉：super 必须为构造器首条语句
        super()
        this.listener = listener
        this.context = listener.context
        this.sourceId = 0u32
        this.buffer = None
        this.autoplay = false
        this.gain = 1.0
        this.isPlaying = false
        this.loop = false
        this.offset = 0.0
        this.playbackRate = 1.0
        this.hasPlaybackControl = true
        this.detune = 0.0
        this.sourceType = "empty"
        this.isAudio = true
    }
    /**
     * @brief[zh-cn] 获取输出节点（OpenAL 中为源本身）
     * @return[zh-cn] OpenAL 源 ID
     *
     * @brief[en] Returns the output node (in OpenAL the source itself)
     * @return[en] The OpenAL source ID
     */
    public func getOutput(): UInt32 {
        return this.sourceId
    }

    /**
     * @brief[zh-cn] 设置音频缓冲区
     * @param[zh-cn] audioBuffer 要绑定的音频缓冲区
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the audio buffer
     * @param[en] audioBuffer The audio buffer to bind
     * @return[en] this (for chaining)
     */
    public func setBuffer(audioBuffer: AudioBuffer): Audio {
        // 如果之前有源，先清理
        this.stop()
        this.disconnect()

        this.buffer = Some(audioBuffer)
        this.sourceType = "buffer"
        this.hasPlaybackControl = true

        // 创建 OpenAL 源
        this._createSource()

        if (this.autoplay) {
            this.play()
        }

        return this
    }

    /**
     * @brief[zh-cn] 播放音频（从当前位置或 0 开始）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Plays the audio (from the current position or 0)
     * @return[en] this (for chaining)
     */
    public func play(): Audio {
        return this.play(-1.0)
    }

    /**
     * @brief[zh-cn] 播放音频
     * @param[zh-cn] offset 播放起始偏移（秒），-1 表示从当前位置开始
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Plays the audio
     * @param[en] offset Playback start offset (seconds); -1 starts from the current position
     * @return[en] this (for chaining)
     */
    public open func play(offset: Float64): Audio {
        if (!this.context.initialized) { return this }

        match (this.buffer) {
            case Some(buf) =>
                if (this.isPlaying) { return this }
                if (!this.hasPlaybackControl) { return this }

                // 确保源已创建且缓冲已绑定
                if (this.sourceId == 0u32) {
                    this._createSource()
                }

                // 捕获闭包所需值（execAudio 闭包内不应访问可变 this 状态）
                let srcId = this.sourceId
                let gainVal = Float32(this.gain * this.listener.gain)
                let pitchVal = Float32(this.playbackRate)
                let loopVal = Int32(if (this.loop) { 1 } else { 0 })
                let offsetVal = Float32(if (offset >= 0.0) { offset } else { this.offset })

                this.isPlaying = true
                this.context.execAudio({ =>
                    alSourcef_cj(srcId, AL_GAIN, gainVal)
                    alSourcef_cj(srcId, AL_PITCH, pitchVal)
                    alSourcei_cj(srcId, AL_LOOPING, loopVal)
                    alSourcef_cj(srcId, AL_SEC_OFFSET, offsetVal)
                    alSourcePlay_cj(srcId)
                })

            case None => ()
        }

        return this
    }

    /**
     * @brief[zh-cn] 暂停播放
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Pauses playback
     * @return[en] this (for chaining)
     */
    public func pause(): Audio {
        if (!this.hasPlaybackControl) { return this }
        if (this.isPlaying && this.sourceId != 0u32) {
            let srcId = this.sourceId
            let offsetBox = Array<Float32>(1, { _ => 0.0f32 })
            this.context.execAudio({ =>
                let offsetBuf = unsafe { LibC.malloc<Float32>() }
                alGetSourcef_cj(srcId, AL_SEC_OFFSET, offsetBuf)
                offsetBox[0] = unsafe { offsetBuf.read() }
                unsafe { LibC.free(offsetBuf) }
                alSourcePause_cj(srcId)
            })
            this.offset = Float64(offsetBox[0])
            this.isPlaying = false
        }
        return this
    }

    /**
     * @brief[zh-cn] 停止播放并重置偏移
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Stops playback and resets the offset
     * @return[en] this (for chaining)
     */
    public open func stop(): Audio {
        if (!this.hasPlaybackControl) { return this }
        if (this.sourceId != 0u32) {
            let srcId = this.sourceId
            this.context.execAudio({ => alSourceStop_cj(srcId) })
        }
        this.isPlaying = false
        this.offset = 0.0
        return this
    }

    /**
     * @brief[zh-cn] 断开连接（清理 OpenAL 源）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Disconnects (releases the OpenAL source)
     * @return[en] this (for chaining)
     */
    public func disconnect(): Audio {
        if (this.sourceId != 0u32) {
            let srcId = this.sourceId
            this.context.execAudio({ =>
                alSourceStop_cj(srcId)
                let delPtr = unsafe { LibC.malloc<UInt32>() }
                unsafe { delPtr.write(srcId) }
                alDeleteSources_cj(1, delPtr)
                unsafe { LibC.free(delPtr) }
            })
            this.sourceId = 0u32
        }
        this.isPlaying = false
        return this
    }

    /**
     * @brief[zh-cn] 设置音量增益
     * @param[zh-cn] value 音量增益（0.0 及以上）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the volume gain
     * @param[en] value Volume gain (0.0 and above)
     * @return[en] this (for chaining)
     */
    public func setVolume(value: Float64): Audio {
        this.gain = value
        if (this.context.initialized && this.sourceId != 0u32) {
            alSourcef_cj(this.sourceId, AL_GAIN, Float32(value * this.listener.gain))
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取音量增益
     * @return[zh-cn] 当前音量增益
     *
     * @brief[en] Returns the volume gain
     * @return[en] The current volume gain
     */
    public func getVolume(): Float64 {
        return this.gain
    }

    /**
     * @brief[zh-cn] 设置循环
     * @param[zh-cn] value 是否循环播放
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets loop playback
     * @param[en] value Whether to loop playback
     * @return[en] this (for chaining)
     */
    public func setLoop(value: Bool): Audio {
        this.loop = value
        if (this.context.initialized && this.sourceId != 0u32) {
            alSourcei_cj(this.sourceId, AL_LOOPING, if (value) { 1 } else { 0 })
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取循环状态
     * @return[zh-cn] 当前是否循环播放
     *
     * @brief[en] Returns the loop state
     * @return[en] Whether loop playback is currently enabled
     */
    public func getLoop(): Bool {
        return this.loop
    }

    /**
     * @brief[zh-cn] 设置播放速率
     * @param[zh-cn] value 播放速率（1.0 为正常速度）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the playback rate
     * @param[en] value The playback rate (1.0 is normal speed)
     * @return[en] this (for chaining)
     */
    public func setPlaybackRate(value: Float64): Audio {
        this.playbackRate = value
        if (this.context.initialized && this.sourceId != 0u32) {
            alSourcef_cj(this.sourceId, AL_PITCH, Float32(value))
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取播放速率
     * @return[zh-cn] 当前播放速率
     *
     * @brief[en] Returns the playback rate
     * @return[en] The current playback rate
     */
    public func getPlaybackRate(): Float64 {
        return this.playbackRate
    }

    /**
     * @brief[zh-cn] 设置音调偏移
     * @param[zh-cn] value 音调偏移（cent，±100 为半音）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the detune
     * @param[en] value Detune in cents (100 cents = one semitone)
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] OpenAL 没有 detune 属性，通过 pitch 近似实现：
     * pitch = playbackRate * 2^(detune/1200)。
     * @note[en] OpenAL has no detune attribute; approximated via pitch:
     * pitch = playbackRate * 2^(detune/1200).
     */
    public func setDetune(value: Float64): Audio {
        this.detune = value
        // OpenAL 没有 detune 属性，通过 pitch 近似
        // detune 以 cent 为单位，100 cent = 半音 = pitch * 2^(1/12)
        // 简化实现：pitch = playbackRate * 2^(detune/1200)
        if (this.context.initialized && this.sourceId != 0u32) {
            let srcId = this.sourceId
            let pitch = Float32(this.playbackRate * pow(2.0, this.detune / 1200.0))
            this.context.execAudio({ => alSourcef_cj(srcId, AL_PITCH, pitch) })
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取音调偏移
     * @return[zh-cn] 当前音调偏移（cent）
     *
     * @brief[en] Returns the detune
     * @return[en] The current detune (cents)
     */
    public func getDetune(): Float64 {
        return this.detune
    }

    /**
     * @brief[zh-cn] 获取当前播放状态
     * @return[zh-cn] 源的播放状态（如 Playing / Paused / Stopped）
     *
     * @brief[en] Returns the current playback state
     * @return[en] The source's playback state (e.g. Playing / Paused / Stopped)
     */
    public func getSourceState(): SourceState {
        if (this.sourceId == 0u32) { return SourceState.Initial }
        let srcId = this.sourceId
        let valBox = Array<UInt32>(1, { _ => 0u32 })
        this.context.execAudio({ =>
            let stateBuf = unsafe { LibC.malloc<Int32>() }
            alGetSourcei_cj(srcId, AL_SOURCE_STATE, stateBuf)
            valBox[0] = UInt32(unsafe { stateBuf.read() })
            unsafe { LibC.free(stateBuf) }
        })
        return SourceState.fromValue(valBox[0])
    }

    /**
     * @brief[zh-cn] 创建 OpenAL 源并绑定缓冲区
     * @explain[zh-cn] 允许子类（如 PositionalAudio）重写以设置额外参数。
     * OpenAL 调用经 context.execAudio 在音频线程执行。
     *
     * @brief[en] Creates the OpenAL source and binds the buffer
     * @explain[en] Subclasses (e.g. PositionalAudio) may override to set extra parameters.
     * OpenAL calls run on the audio thread via context.execAudio.
     */
    protected open func _createSource(): Unit {
        if (!this.context.initialized) { return }

        match (this.buffer) {
            case Some(buf) =>
                let bufId = buf.bufferId
                this.context.execAudio({ =>
                    // 生成源
                    let srcPtr = unsafe { LibC.malloc<UInt32>() }
                    alGenSources_cj(1, srcPtr)
                    let id = unsafe { srcPtr.read() }
                    unsafe { LibC.free(srcPtr) }

                    // 绑定缓冲区
                    alSourcei_cj(id, AL_BUFFER, Int32(bufId))
                    // 设置默认距离模型为无衰减（非位置音频）
                    alSourcef_cj(id, AL_ROLLOFF_FACTOR, 0.0f32)
                    alSourcei_cj(id, AL_SOURCE_RELATIVE, 1)  // 相对监听器

                    this.sourceId = id
                })
            case None => ()
        }
    }

    // ===== EFX 效果接入（新增） =====
    // 以下方法将 EFX 效果/滤波器挂接到 OpenAL 源上，经 context.execAudio
    // 在音频线程执行。需先调用 initialize 确保 EFX 扩展可用。

    /**
     * @brief[zh-cn] 设置直接滤波器（作用于源直通路径的滤波）
     * @param[zh-cn] filter 滤波器对象（AudioFilter），传 filterId=0 的 AudioFilter 等效移除
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the direct filter (filters the source's direct path)
     * @param[en] filter The filter object (AudioFilter); an AudioFilter with filterId=0 removes it
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX: alSourcei(source, AL_DIRECT_FILTER, filterId)。
     * @note[en] Maps to EFX: alSourcei(source, AL_DIRECT_FILTER, filterId).
     */
    public func setDirectFilter(filter: AudioFilter): Audio {
        if (this.context.initialized && this.sourceId != 0u32) {
            let srcId = this.sourceId
            let fid = filter.filterId
            this.context.execAudio({ => alSourcei_cj(srcId, AL_DIRECT_FILTER, Int32(fid)) })
        }
        return this
    }

    /**
     * @brief[zh-cn] 移除直接滤波器
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Removes the direct filter
     * @return[en] this (for chaining)
     */
    public func removeDirectFilter(): Audio {
        if (this.context.initialized && this.sourceId != 0u32) {
            let srcId = this.sourceId
            this.context.execAudio({ => alSourcei_cj(srcId, AL_DIRECT_FILTER, 0) })
        }
        return this
    }

    /**
     * @brief[zh-cn] 将源连接到辅助效果槽（发送路径，使源的输出经效果槽处理后混合）
     * @param[zh-cn] slot 辅助效果槽（IAudioEffectSlot）
     * send 发送编号（通常为 0）
     * filter 发送路径上的可选滤波器，默认无滤波
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Connects the source to an auxiliary effect slot (send path; the source's
     * output is processed by the slot and mixed back)
     * @param[en] slot The auxiliary effect slot (IAudioEffectSlot)
     * send The send index (usually 0)
     * filter Optional filter on the send path; no filtering by default
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX: alSource3i(source, AL_AUXILIARY_SEND_FILTER, slotId, send, filterId)。
     * @note[en] Maps to EFX: alSource3i(source, AL_AUXILIARY_SEND_FILTER, slotId, send, filterId).
     */
    public func connectEffectSlot(slot: IAudioEffectSlot, send: Int32, filter!: Option<IAudioFilter> = None): Audio {
        if (this.context.initialized && this.sourceId != 0u32) {
            let srcId = this.sourceId
            let slotId = slot.getSlotId()
            let filterId = match (filter) {
                case Some(f) => f.getFilterId()
                case None => 0u32
            }
            this.context.execAudio({ =>
                alSource3i_cj(srcId, AL_AUXILIARY_SEND_FILTER, Int32(slotId), send, Int32(filterId))
            })
        }
        return this
    }

    /**
     * @brief[zh-cn] 断开指定发送编号的辅助效果槽连接
     * @param[zh-cn] send 发送编号
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Disconnects the auxiliary effect slot for the given send index
     * @param[en] send The send index
     * @return[en] this (for chaining)
     */
    public func disconnectEffectSlot(send: Int32): Audio {
        if (this.context.initialized && this.sourceId != 0u32) {
            let srcId = this.sourceId
            this.context.execAudio({ =>
                alSource3i_cj(srcId, AL_AUXILIARY_SEND_FILTER, 0, send, 0)
            })
        }
        return this
    }
}
