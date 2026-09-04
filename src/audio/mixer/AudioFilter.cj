/**
 * @file[zh-cn] AudioFilter EFX 滤波器对象封装（低通/高通/带通）
 * @brief[zh-cn] EFX 滤波器对象：封装 OpenAL Filter 句柄并提供常用滤波器预设工厂
 * @explain[zh-cn] 封装 OpenAL EFX 扩展的 Filter 对象（对应 openalsoft4cj 的 efx 模块）。
 * 滤波器可挂接到两种路径：
 * - 直接路径：Audio.setDirectFilter(filter) — 滤波源直通输出
 * - 发送路径：Audio.connectEffectSlot(slot, send, filter) — 滤波发送到效果槽的信号
 * 用法：
 * let lowpass = createLowpassFilter(gain: 0.8f32, gainHF: 0.3f32)
 * audio.setDirectFilter(lowpass)
 * 所有 OpenAL EFX 调用经 AudioContext.execAudio 序列化到音频线程；
 * 需先 AudioContext.initialize() 成功后方可使用。
 *
 * @file[en] AudioFilter  EFX filter object wrapper (lowpass/highpass/bandpass)
 * @brief[en] EFX filter object: wraps an OpenAL Filter handle and provides preset filter factories
 * @explain[en] Wraps the OpenAL EFX extension Filter object (matching the efx module of
 * openalsoft4cj). Filters can be attached to two paths:
 * - Direct path: Audio.setDirectFilter(filter) — filters the source's direct output
 * - Send path: Audio.connectEffectSlot(slot, send, filter) — filters the signal
 * sent to the effect slot
 * Usage:
 * let lowpass = createLowpassFilter(gain: 0.8f32, gainHF: 0.3f32)
 * audio.setDirectFilter(lowpass)
 * All OpenAL EFX calls are serialized onto the audio thread via
 * AudioContext.execAudio; AudioContext.initialize() must succeed first.
 */
package three.audio.mixer

import openalsoft4cj.efx.*

import three.audio.device.*
import three.audio.interfaces.*

/**
 * @brief[zh-cn] EFX 滤波器对象，封装 OpenAL Filter 句柄
 * @explain[zh-cn] 支持三种滤波器类型：
 * - Lowpass：衰减高频，保留低频（模拟隔墙听音）
 * - Highpass：衰减低频，保留高频
 * - Bandpass：仅保留某频段
 *
 * @brief[en] EFX filter object wrapping an OpenAL Filter handle
 * @explain[en] Supports three filter types:
 * - Lowpass: attenuates high frequencies, keeps low frequencies (e.g. muffled sound)
 * - Highpass: attenuates low frequencies, keeps high frequencies
 * - Bandpass: keeps only a specific frequency band
 */
public class AudioFilter <: IAudioFilter {
    /**
     * @brief[zh-cn] OpenAL 滤波器句柄
     *
     * @brief[en] The OpenAL filter handle
     */
    public var filterId: UInt32

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
     * @brief[zh-cn] 创建音频滤波器对象
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     *
     * @brief[en] Creates an audio filter object
     * @param[en] context The audio context (defaults to the AudioContext.context singleton)
     */
    public init(context!: AudioContext = AudioContext.context) {
        this.context = context
        this.filterId = 0u32
        this._disposed = false
    }

    /**
     * @brief[zh-cn] 接口实现：获取 OpenAL 滤波器句柄
     * @return[zh-cn] OpenAL 滤波器句柄（ALuint）
     *
     * @brief[en] Interface implementation: returns the OpenAL filter handle
     * @return[en] The OpenAL filter handle (ALuint)
     */
    public func getFilterId(): UInt32 { filterId }

    /**
     * @brief[zh-cn] 创建并生成 OpenAL 滤波器对象
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Creates and generates the OpenAL filter object
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 在音频线程执行 alGenFilters；若已创建则跳过。
     * @note[en] Runs alGenFilters on the audio thread; skips if already created.
     */
    public func create(): AudioFilter {
        if (this.filterId != 0u32) { return this }
        this.context.execAudio({ =>
            let ptr = unsafe { LibC.malloc<UInt32>() }
            alGenFilters_cj(1, ptr)
            this.filterId = unsafe { ptr.read() }
            unsafe { LibC.free(ptr) }
        })
        return this
    }

    /**
     * @brief[zh-cn] 设置滤波器类型
     * @param[zh-cn] filterType 滤波器类型（FilterType.Lowpass / Highpass / Bandpass）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the filter type
     * @param[en] filterType Filter type (FilterType.Lowpass / Highpass / Bandpass)
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX: alFilteri(filter, AL_FILTER_TYPE, type)。
     * @note[en] Maps to EFX: alFilteri(filter, AL_FILTER_TYPE, type).
     */
    public func setType(filterType: FilterType): AudioFilter {
        if (this.filterId == 0u32) { this.create() }
        let fid = this.filterId
        let v = Int32(filterType.value())
        this.context.execAudio({ => alFilteri_cj(fid, AL_FILTER_TYPE, v) })
        return this
    }

    /**
     * @brief[zh-cn] 设置浮点参数
     * @param[zh-cn] param 参数常量（如 AL_LOWPASS_GAIN / AL_LOWPASS_GAINHF）
     * value 参数值
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets a floating-point parameter
     * @param[en] param The parameter constant (e.g. AL_LOWPASS_GAIN / AL_LOWPASS_GAINHF)
     * value The parameter value
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 对应 EFX: alFilterf(filter, param, value)。
     * @note[en] Maps to EFX: alFilterf(filter, param, value).
     */
    public func setParamf(param: UInt32, value: Float32): AudioFilter {
        if (this.filterId == 0u32) { return this }
        let fid = this.filterId
        this.context.execAudio({ => alFilterf_cj(fid, param, value) })
        return this
    }

    /**
     * @brief[zh-cn] 释放 OpenAL 滤波器对象
     *
     * @brief[en] Releases the OpenAL filter object
     *
     * @note[zh-cn] 对应 EFX: alDeleteFilters；释放后句柄归零，重复调用安全。
     * @note[en] Maps to EFX: alDeleteFilters; the handle is zeroed after release and repeated calls are safe.
     */
    public func dispose(): Unit {
        if (_disposed) { return }
        if (this.filterId != 0u32) {
            let fid = this.filterId
            this.context.execAudio({ =>
                let ptr = unsafe { LibC.malloc<UInt32>() }
                unsafe { ptr.write(fid) }
                alDeleteFilters_cj(1, ptr)
                unsafe { LibC.free(ptr) }
            })
            this.filterId = 0u32
        }
        _disposed = true
    }

    // ===== 便捷工厂函数 =====

    /**
     * @brief[zh-cn] 创建低通滤波器（衰减高频，模拟隔墙/水下音效）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * gain 全频段增益（0.0~1.0），默认 1.0
     * gainHF 高频增益（0.0~1.0），值越小高频衰减越强，默认 0.5
     * @return[zh-cn] 配置好的 AudioFilter
     *
     * @brief[en] Creates a lowpass filter (attenuates high frequencies, e.g. muffled/wet sound)
     * @param[en] context The audio context (defaults to the AudioContext.context singleton)
     * gain Full-band gain (0.0~1.0), default 1.0
     * gainHF High-frequency gain (0.0~1.0); smaller value means stronger high-frequency attenuation, default 0.5
     * @return[en] The configured AudioFilter
     */
    public static func createLowpassFilter(
        context!: AudioContext = AudioContext.context,
        gain!: Float32 = 1.0f32,
        gainHF!: Float32 = 0.5f32
    ): AudioFilter {
        let f = AudioFilter(context: context)
        f.create()
        f.setType(FilterType.Lowpass)
        f.setParamf(AL_LOWPASS_GAIN, gain)
        f.setParamf(AL_LOWPASS_GAINHF, gainHF)
        return f
    }

    /**
     * @brief[zh-cn] 创建高通滤波器（衰减低频）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * gain 全频段增益（0.0~1.0），默认 1.0
     * gainLF 低频增益（0.0~1.0），值越小低频衰减越强，默认 0.5
     * @return[zh-cn] 配置好的 AudioFilter
     *
     * @brief[en] Creates a highpass filter (attenuates low frequencies)
     * @param[en] context The audio context (defaults to the AudioContext.context singleton)
     * gain Full-band gain (0.0~1.0), default 1.0
     * gainLF Low-frequency gain (0.0~1.0); smaller value means stronger low-frequency attenuation, default 0.5
     * @return[en] The configured AudioFilter
     */
    public static func createHighpassFilter(
        context!: AudioContext = AudioContext.context,
        gain!: Float32 = 1.0f32,
        gainLF!: Float32 = 0.5f32
    ): AudioFilter {
        let f = AudioFilter(context: context)
        f.create()
        f.setType(FilterType.Highpass)
        f.setParamf(AL_HIGHPASS_GAIN, gain)
        f.setParamf(AL_HIGHPASS_GAINLF, gainLF)
        return f
    }

    /**
     * @brief[zh-cn] 创建带通滤波器（仅保留某频段）
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     * gain 全频段增益（0.0~1.0），默认 1.0
     * gainLF 低频增益（0.0~1.0），默认 1.0
     * gainHF 高频增益（0.0~1.0），默认 1.0
     * @return[zh-cn] 配置好的 AudioFilter
     *
     * @brief[en] Creates a bandpass filter (keeps only a certain frequency band)
     * @param[en] context The audio context (defaults to the AudioContext.context singleton)
     * gain Full-band gain (0.0~1.0), default 1.0
     * gainLF Low-frequency gain (0.0~1.0), default 1.0
     * gainHF High-frequency gain (0.0~1.0), default 1.0
     * @return[en] The configured AudioFilter
     */
    public static func createBandpassFilter(
        context!: AudioContext = AudioContext.context,
        gain!: Float32 = 1.0f32,
        gainLF!: Float32 = 1.0f32,
        gainHF!: Float32 = 1.0f32
    ): AudioFilter {
        let f = AudioFilter(context: context)
        f.create()
        f.setType(FilterType.Bandpass)
        f.setParamf(AL_BANDPASS_GAIN, gain)
        f.setParamf(AL_BANDPASS_GAINLF, gainLF)
        f.setParamf(AL_BANDPASS_GAINHF, gainHF)
        return f
    }
}