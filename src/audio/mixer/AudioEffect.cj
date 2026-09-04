/**
 * @file[zh-cn] AudioEffect EFX 效果对象封装（混响/合唱/回声/均衡器等）
 * @brief[zh-cn] EFX 效果对象：封装 OpenAL Effect 句柄并提供常用效果预设工厂
 * @explain[zh-cn] 封装 OpenAL EFX 扩展的 Effect 对象（对应 openalsoft4cj 的 efx 模块）：
 * 通过 setType 指定效果类型，setParamf/setParami/setParamfv 配置参数，
 * 最后挂接到 AudioEffectSlot 上由源的辅助发送路径触发处理。
 * 用法：
 * let reverb = AudioEffect.createReverbEffect()
 * let slot = AudioEffectSlot()
 * slot.setEffect(reverb)
 * audio.connectEffectSlot(slot, 0)
 * 所有 OpenAL EFX 调用经 AudioContext.execAudio 序列化到音频线程；
 * 需先 AudioContext.initialize() 成功后方可使用。
 *
 * @file[en] AudioEffect  EFX effect object wrapper (reverb/chorus/echo/equalizer, etc.)
 * @brief[en] EFX effect object: wraps an OpenAL Effect handle and provides preset factories
 * @explain[en] Wraps the OpenAL EFX extension Effect object (matching the efx module of
 * openalsoft4cj). The effect type is set with setType and parameters are configured
 * via setParamf/setParami/setParamfv, then the effect is attached to an
 * AudioEffectSlot and processed through the source's auxiliary send path.
 * Usage:
 * let reverb = AudioEffect.createReverbEffect()
 * let slot = AudioEffectSlot()
 * slot.setEffect(reverb)
 * audio.connectEffectSlot(slot, 0)
 * All OpenAL EFX calls are serialized onto the audio thread via
 * AudioContext.execAudio; AudioContext.initialize() must succeed first.
 */
package three.audio.mixer

import openalsoft4cj.efx.*

import three.audio.device.*
import three.audio.interfaces.*

/**
 * @brief[zh-cn] EFX 效果对象，封装 OpenAL Effect 句柄
 * @explain[zh-cn] 一个 AudioEffect 代表一种音频效果（如混响、合唱、回声等），
 * 通过 setType 指定效果类型，再通过 setParamf/setParami 配置参数，
 * 最后挂接到 AudioEffectSlot 上由源的辅助发送路径触发处理。
 *
 * @brief[en] EFX effect object wrapping an OpenAL Effect handle
 * @explain[en] An AudioEffect represents one audio effect (reverb, chorus, echo, etc.).
 * Set the type with setType, configure parameters with setParamf/setParami, then
 * attach it to an AudioEffectSlot to be processed through the source's auxiliary
 * send path.
 */
public class AudioEffect <: IAudioEffect {
    /**
     * @brief[zh-cn] OpenAL 效果句柄
     *
     * @brief[en] The OpenAL effect handle
     */
    public var effectId: UInt32

    /**
     * @brief[zh-cn] 关联的音频上下文
     *
     * @brief[en] The associated audio context
     */
    public var context: AudioContext

    /**
     * @brief[zh-cn] 是否已释放
     */
    private var _disposed: Bool

    /**
     * @brief[zh-cn] 创建音频效果对象
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     *
     * @brief[en] Creates an audio effect object
     * @param[en] context The audio context (defaults to the AudioContext.context singleton)
     */
    public init(context!: AudioContext = AudioContext.context) {
        this.context = context
        this.effectId = 0u32
        this._disposed = false
    }

    /**
     * @brief[zh-cn] 接口实现：获取 OpenAL 效果句柄
     * @return[zh-cn] OpenAL 效果句柄（ALuint）
     *
     * @brief[en] Interface implementation: returns the OpenAL effect handle
     * @return[en] The OpenAL effect handle (ALuint)
     */
    public func getEffectId(): UInt32 { effectId }

    /**
     * @brief[zh-cn] 创建并生成 OpenAL 效果对象
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Creates and generates the OpenAL effect object
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 在音频线程执行 alGenEffects；若已创建则跳过。
     * @note[en] Runs alGenEffects on the audio thread; skips if already created.
     */
    public func create(): AudioEffect {
        if (this.effectId != 0u32) { return this }
        this.context.execAudio({ =>
            let ptr = unsafe { LibC.malloc<UInt32>() }
            alGenEffects_cj(1, ptr)
            this.effectId = unsafe { ptr.read() }
            unsafe { LibC.free(ptr) }
        })
        return this
    }

    /**
     * @brief[zh-cn] 设置效果类型
     * @param[zh-cn] effectType 效果类型（EffectType.Reverb / Chorus / Echo / Equalizer 等）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the effect type
     * @param[en] effectType Effect type (EffectType.Reverb / Chorus / Echo / Equalizer, etc.)
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX 的 alEffecti(effect, AL_EFFECT_TYPE, type)。
     * @note[en] Maps to EFX alEffecti(effect, AL_EFFECT_TYPE, type).
     */
    public func setType(effectType: EffectType): AudioEffect {
        if (this.effectId == 0u32) { this.create() }
        let eid = this.effectId
        let v = Int32(effectType.value())
        this.context.execAudio({ => alEffecti_cj(eid, AL_EFFECT_TYPE, v) })
        return this
    }

    /**
     * @brief[zh-cn] 设置浮点参数
     * @param[zh-cn] param 参数常量（如 AL_REVERB_DENSITY）
     * value 参数值
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets a float parameter
     * @param[en] param Parameter constant (e.g. AL_REVERB_DENSITY)
     * value Parameter value
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX 的 alEffectf(effect, param, value)。
     * @note[en] Maps to EFX alEffectf(effect, param, value).
     */
    public func setParamf(param: UInt32, value: Float32): AudioEffect {
        if (this.effectId == 0u32) { return this }
        let eid = this.effectId
        this.context.execAudio({ => alEffectf_cj(eid, param, value) })
        return this
    }

    /**
     * @brief[zh-cn] 设置浮点向量参数
     * @param[zh-cn] param 参数常量
     * values Float32 数组指针（调用方负责分配和释放）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets a float vector parameter
     * @param[en] param Parameter constant
     * values Pointer to a Float32 array (caller is responsible for allocation/free)
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 用于 EAX Reverb 等需要多值参数的效果；对应 EFX 的 alEffectfv(effect, param, values)。
     * @note[en] Used by effects with multi-value parameters such as EAX Reverb; maps to
     * EFX alEffectfv(effect, param, values).
     */
    public func setParamfv(param: UInt32, values: CPointer<Float32>): AudioEffect {
        if (this.effectId == 0u32) { return this }
        let eid = this.effectId
        this.context.execAudio({ => alEffectfv_cj(eid, param, values) })
        return this
    }

    /**
     * @brief[zh-cn] 设置整数参数
     * @param[zh-cn] param 参数常量
     * value 参数值
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets an integer parameter
     * @param[en] param Parameter constant
     * value Parameter value
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX 的 alEffecti(effect, param, value)。
     * @note[en] Maps to EFX alEffecti(effect, param, value).
     */
    public func setParami(param: UInt32, value: Int32): AudioEffect {
        if (this.effectId == 0u32) { return this }
        let eid = this.effectId
        this.context.execAudio({ => alEffecti_cj(eid, param, value) })
        return this
    }

    /**
     * @brief[zh-cn] 释放 OpenAL 效果对象
     *
     * @brief[en] Releases the OpenAL effect object
     *
     * @note[zh-cn] 在音频线程执行 alDeleteEffects；重复调用无副作用。
     * @note[en] Runs alDeleteEffects on the audio thread; repeated calls have no effect.
     */
    public func dispose(): Unit {
        if (_disposed) { return }
        if (this.effectId != 0u32) {
            let eid = this.effectId
            this.context.execAudio({ =>
                let ptr = unsafe { LibC.malloc<UInt32>() }
                unsafe { ptr.write(eid) }
                alDeleteEffects_cj(1, ptr)
                unsafe { LibC.free(ptr) }
            })
            this.effectId = 0u32
        }
        _disposed = true
    }

    // ===== 便捷工厂函数 =====
    // 提供常用效果的预设创建，减少手动逐参数配置的样板代码。

    /**
     * @brief[zh-cn] 创建标准混响效果（Reverb）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * density 密度（0.0~1.0），默认 1.0
     * diffusion 扩散度（0.0~1.0），默认 1.0
     * gain 增益（0.0~1.0），默认 0.32
     * decayTime 衰减时间（秒，0.1~20.0），默认 1.49
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a standard reverb effect (Reverb)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * density Density (0.0~1.0), default 1.0
     * diffusion Diffusion (0.0~1.0), default 1.0
     * gain Gain (0.0~1.0), default 0.32
     * decayTime Decay time in seconds (0.1~20.0), default 1.49
     * @return[en] The configured AudioEffect
     */
    public static func createReverbEffect(
        context!: AudioContext = AudioContext.context,
        density!: Float32 = 1.0f32,
        diffusion!: Float32 = 1.0f32,
        gain!: Float32 = 0.32f32,
        decayTime!: Float32 = 1.49f32
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.Reverb)
        e.setParamf(AL_REVERB_DENSITY, density)
        e.setParamf(AL_REVERB_DIFFUSION, diffusion)
        e.setParamf(AL_REVERB_GAIN, gain)
        e.setParamf(AL_REVERB_DECAY_TIME, decayTime)
        return e
    }

    /**
     * @brief[zh-cn] 创建 EAX 混响效果（EaxReverb，比标准 Reverb 参数更丰富）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * density 密度，默认 1.0
     * diffusion 扩散度，默认 1.0
     * gain 增益，默认 0.32
     * decayTime 衰减时间，默认 1.49
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates an EAX reverb effect (EaxReverb, with more parameters than standard Reverb)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * density Density, default 1.0
     * diffusion Diffusion, default 1.0
     * gain Gain, default 0.32
     * decayTime Decay time, default 1.49
     * @return[en] The configured AudioEffect
     */
    public static func createEaxReverbEffect(
        context!: AudioContext = AudioContext.context,
        density!: Float32 = 1.0f32,
        diffusion!: Float32 = 1.0f32,
        gain!: Float32 = 0.32f32,
        decayTime!: Float32 = 1.49f32
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.EaxReverb)
        e.setParamf(AL_EAXREVERB_DENSITY, density)
        e.setParamf(AL_EAXREVERB_DIFFUSION, diffusion)
        e.setParamf(AL_EAXREVERB_GAIN, gain)
        e.setParamf(AL_EAXREVERB_DECAY_TIME, decayTime)
        return e
    }

    /**
     * @brief[zh-cn] 创建合唱效果（Chorus）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a chorus effect (Chorus)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * @return[en] The configured AudioEffect
     */
    public static func createChorusEffect(context!: AudioContext = AudioContext.context): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.Chorus)
        return e
    }

    /**
     * @brief[zh-cn] 创建回声效果（Echo）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates an echo effect (Echo)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * @return[en] The configured AudioEffect
     */
    public static func createEchoEffect(context!: AudioContext = AudioContext.context): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.Echo)
        return e
    }

    /**
     * @brief[zh-cn] 创建均衡器效果（Equalizer）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates an equalizer effect (Equalizer)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * @return[en] The configured AudioEffect
     */
    public static func createEqualizerEffect(context!: AudioContext = AudioContext.context): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.Equalizer)
        return e
    }

    /**
     * @brief[zh-cn] 创建失真效果（Distortion，模拟吉他/功放过载）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * edge 边缘度（0.0~1.0），默认 0.2
     * gain 失真增益（0.01~1.0），默认 0.05
     * lowpassCutoff 低通截止（80~24000 Hz），默认 8000
     * eqCenter 均衡中心（80~24000 Hz），默认 3600
     * eqBandwidth 均衡带宽（80~24000 Hz），默认 3600
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a distortion effect (Distortion, simulating guitar/amp overload)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * edge Edge (0.0~1.0), default 0.2
     * gain Distortion gain (0.01~1.0), default 0.05
     * lowpassCutoff Low-pass cutoff (80~24000 Hz), default 8000
     * eqCenter EQ center (80~24000 Hz), default 3600
     * eqBandwidth EQ bandwidth (80~24000 Hz), default 3600
     * @return[en] The configured AudioEffect
     */
    public static func createDistortionEffect(
        context!: AudioContext = AudioContext.context,
        edge!: Float32 = 0.2f32,
        gain!: Float32 = 0.05f32,
        lowpassCutoff!: Float32 = 8000.0f32,
        eqCenter!: Float32 = 3600.0f32,
        eqBandwidth!: Float32 = 3600.0f32
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.Distortion)
        e.setParamf(AL_DISTORTION_EDGE, edge)
        e.setParamf(AL_DISTORTION_GAIN, gain)
        e.setParamf(AL_DISTORTION_LOWPASS_CUTOFF, lowpassCutoff)
        e.setParamf(AL_DISTORTION_EQCENTER, eqCenter)
        e.setParamf(AL_DISTORTION_EQBANDWIDTH, eqBandwidth)
        return e
    }

    /**
     * @brief[zh-cn] 创建镶边效果（Flanger，梳状滤波扫频）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * rate 扫频速率（0.0~10.0 Hz），默认 0.27
     * depth 深度（0.0~1.0），默认 1.0
     * delay 延迟（0.0~0.004 s），默认 0.002
     * feedback 反馈（-1.0~1.0），默认 -0.5
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a flanger effect (Flanger, swept comb filter)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * rate Sweep rate (0.0~10.0 Hz), default 0.27
     * depth Depth (0.0~1.0), default 1.0
     * delay Delay (0.0~0.004 s), default 0.002
     * feedback Feedback (-1.0~1.0), default -0.5
     * @return[en] The configured AudioEffect
     */
    public static func createFlangerEffect(
        context!: AudioContext = AudioContext.context,
        rate!: Float32 = 0.27f32,
        depth!: Float32 = 1.0f32,
        delay!: Float32 = 0.002f32,
        feedback!: Float32 = -0.5f32
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.Flanger)
        e.setParamf(AL_FLANGER_RATE, rate)
        e.setParamf(AL_FLANGER_DEPTH, depth)
        e.setParamf(AL_FLANGER_DELAY, delay)
        e.setParamf(AL_FLANGER_FEEDBACK, feedback)
        e.setParami(AL_FLANGER_WAVEFORM, Int32(AL_FLANGER_WAVEFORM_SINUSOID))
        return e
    }

    /**
     * @brief[zh-cn] 创建移频器效果（FrequencyShifter，频段整体搬移）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * frequency 移频量（-24000~24000 Hz），默认 0.0
     * leftDirection 左声道方向（0=Down / 1=Up / 2=Off），默认 Up
     * rightDirection 右声道方向，默认 Up
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a frequency shifter effect (FrequencyShifter, shifts frequency bands)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * frequency Shift amount (-24000~24000 Hz), default 0.0
     * leftDirection Left channel direction (0=Down / 1=Up / 2=Off), default Up
     * rightDirection Right channel direction, default Up
     * @return[en] The configured AudioEffect
     */
    public static func createFrequencyShifterEffect(
        context!: AudioContext = AudioContext.context,
        frequency!: Float32 = 0.0f32,
        leftDirection!: Int32 = 1,
        rightDirection!: Int32 = 1
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.FrequencyShifter)
        e.setParamf(AL_FREQUENCY_SHIFTER_FREQUENCY, frequency)
        e.setParami(AL_FREQUENCY_SHIFTER_LEFT_DIRECTION, leftDirection)
        e.setParami(AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION, rightDirection)
        return e
    }

    /**
     * @brief[zh-cn] 创建移调器效果（PitchShifter，音高搬移，不改播放速率）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * coarseTune 粗调（-12~12 半音），默认 0
     * fineTune 微调（-50~50 音分），默认 0
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a pitch shifter effect (PitchShifter, shifts pitch without changing playback rate)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * coarseTune Coarse tune (-12~12 semitones), default 0
     * fineTune Fine tune (-50~50 cents), default 0
     * @return[en] The configured AudioEffect
     */
    public static func createPitchShifterEffect(
        context!: AudioContext = AudioContext.context,
        coarseTune!: Int32 = 0,
        fineTune!: Int32 = 0
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.PitchShifter)
        e.setParami(AL_PITCH_SHIFTER_COARSE_TUNE, coarseTune)
        e.setParami(AL_PITCH_SHIFTER_FINE_TUNE, fineTune)
        return e
    }

    /**
     * @brief[zh-cn] 创建环形调制器效果（RingModulator，载波振幅调制）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * frequency 调制频率（0.0~8000 Hz），默认 440
     * highpassCutoff 高通截止（0~24000 Hz），默认 800
     * waveform 波形（0=Sinusoid / 1=Sawtooth / 2=Square），默认 Sinusoid
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a ring modulator effect (RingModulator, carrier amplitude modulation)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * frequency Modulation frequency (0.0~8000 Hz), default 440
     * highpassCutoff High-pass cutoff (0~24000 Hz), default 800
     * waveform Waveform (0=Sinusoid / 1=Sawtooth / 2=Square), default Sinusoid
     * @return[en] The configured AudioEffect
     */
    public static func createRingModulatorEffect(
        context!: AudioContext = AudioContext.context,
        frequency!: Float32 = 440.0f32,
        highpassCutoff!: Float32 = 800.0f32,
        waveform!: Int32 = 0
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.RingModulator)
        e.setParamf(AL_RING_MODULATOR_FREQUENCY, frequency)
        e.setParamf(AL_RING_MODULATOR_HIGHPASS_CUTOFF, highpassCutoff)
        e.setParami(AL_RING_MODULATOR_WAVEFORM, waveform)
        return e
    }

    /**
     * @brief[zh-cn] 创建自动哇音效果（Autowah，包络跟随滤波，吉他哇音踏板）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * attackTime 起音时间（0.0001~1.0 s），默认 0.06
     * releaseTime 释音时间（0.0001~1.0 s），默认 0.06
     * resonance 共鸣度（2.0~1000.0），默认 1000
     * peakGain 峰值增益（0.00003~31621），默认 11.22
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates an autowah effect (Autowah, envelope-following filter, guitar wah pedal)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * attackTime Attack time (0.0001~1.0 s), default 0.06
     * releaseTime Release time (0.0001~1.0 s), default 0.06
     * resonance Resonance (2.0~1000.0), default 1000
     * peakGain Peak gain (0.00003~31621), default 11.22
     * @return[en] The configured AudioEffect
     */
    public static func createAutowahEffect(
        context!: AudioContext = AudioContext.context,
        attackTime!: Float32 = 0.06f32,
        releaseTime!: Float32 = 0.06f32,
        resonance!: Float32 = 1000.0f32,
        peakGain!: Float32 = 11.22f32
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.Autowah)
        e.setParamf(AL_AUTOWAH_ATTACK_TIME, attackTime)
        e.setParamf(AL_AUTOWAH_RELEASE_TIME, releaseTime)
        e.setParamf(AL_AUTOWAH_RESONANCE, resonance)
        e.setParamf(AL_AUTOWAH_PEAK_GAIN, peakGain)
        return e
    }

    /**
     * @brief[zh-cn] 创建压缩器效果（Compressor，动态范围压缩）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * onoff 开关（0=Off / 1=On），默认 On
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a compressor effect (Compressor, dynamic range compression)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * onoff On/off switch (0=Off / 1=On), default On
     * @return[en] The configured AudioEffect
     */
    public static func createCompressorEffect(
        context!: AudioContext = AudioContext.context,
        onoff!: Int32 = 1
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.Compressor)
        e.setParami(AL_COMPRESSOR_ONOFF, onoff)
        return e
    }

    /**
     * @brief[zh-cn] 创建声码器/语音变形效果（VocalMorpher）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * phonemeA 音素 A（音素枚举值，默认 AL_VOCAL_MORPHER_PHONEME_A）
     * phonemeB 音素 B（默认 AL_VOCAL_MORPHER_PHONEME_I）
     * rate 变形速率（0.0~10.0 Hz），默认 1.41
     * @return[zh-cn] 配置好的 AudioEffect
     *
     * @brief[en] Creates a vocal morpher effect (VocalMorpher, vocoder/voice morphing)
     * @param[en] context Audio context (defaults to the AudioContext.context singleton)
     * phonemeA Phoneme A (phoneme enum value, default AL_VOCAL_MORPHER_PHONEME_A)
     * phonemeB Phoneme B (default AL_VOCAL_MORPHER_PHONEME_I)
     * rate Morphing rate (0.0~10.0 Hz), default 1.41
     * @return[en] The configured AudioEffect
     */
    public static func createVocalMorpherEffect(
        context!: AudioContext = AudioContext.context,
        phonemeA!: Int32 = Int32(AL_VOCAL_MORPHER_PHONEME_A),
        phonemeB!: Int32 = Int32(AL_VOCAL_MORPHER_PHONEME_I),
        rate!: Float32 = 1.41f32
    ): AudioEffect {
        let e = AudioEffect(context: context)
        e.create()
        e.setType(EffectType.VocalMorpher)
        e.setParami(AL_VOCAL_MORPHER_PHONEMEA, phonemeA)
        e.setParami(AL_VOCAL_MORPHER_PHONEMEB, phonemeB)
        e.setParamf(AL_VOCAL_MORPHER_RATE, rate)
        return e
    }
}