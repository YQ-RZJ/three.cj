/**
 * @file openalsoft4cj.efx 类型定义
 * @brief OpenAL EFX 扩展（efx.h + efx-presets.h）的类型定义
 * @explain 本文件包含 efx.h 中的效果/滤波器类型枚举，以及 efx-presets.h
 *         中的 EFXEAXREVERBPROPERTIES 混响预设结构体。
 * @note 枚举字段在 foreign 函数中使用 UInt32 底层表示（见 ffi.cj），
 *         调用方通过 `EnumType.value()` / `EnumType.fromValue(u32)` 转换。
 */
protected package three._vendor.openalsoft4cj.efx

/**
 * @brief EFX 效果器类型（AL_EFFECT_TYPE 参数）
 * @explain 对应 efx.h 中 AL_EFFECT_NULL 至 AL_EFFECT_EAXREVERB。
 */
public enum EffectType {
    /** @brief 空效果（AL_EFFECT_NULL = 0x0000） */
    | Null
    /** @brief 混响（AL_EFFECT_REVERB = 0x0001） */
    | Reverb
    /** @brief 合唱（AL_EFFECT_CHORUS = 0x0002） */
    | Chorus
    /** @brief 失真（AL_EFFECT_DISTORTION = 0x0003） */
    | Distortion
    /** @brief 回声（AL_EFFECT_ECHO = 0x0004） */
    | Echo
    /** @brief 镶边（AL_EFFECT_FLANGER = 0x0005） */
    | Flanger
    /** @brief 移频器（AL_EFFECT_FREQUENCY_SHIFTER = 0x0006） */
    | FrequencyShifter
    /** @brief 声码器/语音变形（AL_EFFECT_VOCAL_MORPHER = 0x0007） */
    | VocalMorpher
    /** @brief 移调器（AL_EFFECT_PITCH_SHIFTER = 0x0008） */
    | PitchShifter
    /** @brief 环形调制器（AL_EFFECT_RING_MODULATOR = 0x0009） */
    | RingModulator
    /** @brief 自动哇音（AL_EFFECT_AUTOWAH = 0x000A） */
    | Autowah
    /** @brief 压缩器（AL_EFFECT_COMPRESSOR = 0x000B） */
    | Compressor
    /** @brief 均衡器（AL_EFFECT_EQUALIZER = 0x000C） */
    | Equalizer
    /** @brief EAX 混响（AL_EFFECT_EAXREVERB = 0x8000） */
    | EaxReverb

    public func value(): UInt32 {
        match (this) {
            case Null => 0x0000
            case Reverb => 0x0001
            case Chorus => 0x0002
            case Distortion => 0x0003
            case Echo => 0x0004
            case Flanger => 0x0005
            case FrequencyShifter => 0x0006
            case VocalMorpher => 0x0007
            case PitchShifter => 0x0008
            case RingModulator => 0x0009
            case Autowah => 0x000A
            case Compressor => 0x000B
            case Equalizer => 0x000C
            case EaxReverb => 0x8000
        }
    }

    public static func fromValue(v: UInt32): EffectType {
        match (v) {
            case 0x0000 => Null
            case 0x0001 => Reverb
            case 0x0002 => Chorus
            case 0x0003 => Distortion
            case 0x0004 => Echo
            case 0x0005 => Flanger
            case 0x0006 => FrequencyShifter
            case 0x0007 => VocalMorpher
            case 0x0008 => PitchShifter
            case 0x0009 => RingModulator
            case 0x000A => Autowah
            case 0x000B => Compressor
            case 0x000C => Equalizer
            case _ => EaxReverb
        }
    }
}

/**
 * @brief EFX 滤波器类型（AL_FILTER_TYPE 参数）
 * @explain 对应 efx.h 中 AL_FILTER_NULL 至 AL_FILTER_BANDPASS。
 */
public enum FilterType {
    /** @brief 空滤波器（AL_FILTER_NULL = 0x0000） */
    | Null
    /** @brief 低通（AL_FILTER_LOWPASS = 0x0001） */
    | Lowpass
    /** @brief 高通（AL_FILTER_HIGHPASS = 0x0002） */
    | Highpass
    /** @brief 带通（AL_FILTER_BANDPASS = 0x0003） */
    | Bandpass

    public func value(): UInt32 {
        match (this) {
            case Null => 0x0000
            case Lowpass => 0x0001
            case Highpass => 0x0002
            case Bandpass => 0x0003
        }
    }

    public static func fromValue(v: UInt32): FilterType {
        match (v) {
            case 0x0000 => Null
            case 0x0001 => Lowpass
            case 0x0002 => Highpass
            case _ => Bandpass
        }
    }
}

/**
 * @brief EAX 混响预设结构体（efx-presets.h EFXEAXREVERBPROPERTIES）
 * @explain 与 C 结构体布局一致（@C），可直接作为 alEffectfv(AL_EAXREVERB_*)
 *         参数或初始化混响效果。
 */
@C
public struct EaxReverbProperties {
    /** @brief 混响密度（0.0 - 1.0） */
    public var flDensity: Float32 = 1.0f32
    /** @brief 扩散度（0.0 - 1.0） */
    public var flDiffusion: Float32 = 1.0f32
    /** @brief 主增益（0.0 - 1.0） */
    public var flGain: Float32 = 0.32f32
    /** @brief 高频增益（0.0 - 1.0） */
    public var flGainHF: Float32 = 0.89f32
    /** @brief 低频增益（0.0 - 1.0） */
    public var flGainLF: Float32 = 1.0f32
    /** @brief 衰减时间（秒，0.1 - 20.0） */
    public var flDecayTime: Float32 = 1.49f32
    /** @brief 高频衰减比（0.1 - 2.0） */
    public var flDecayHFRatio: Float32 = 0.83f32
    /** @brief 低频衰减比（0.1 - 2.0） */
    public var flDecayLFRatio: Float32 = 1.0f32
    /** @brief 早期反射增益（0.0 - 3.16） */
    public var flReflectionsGain: Float32 = 0.05f32
    /** @brief 早期反射延迟（秒，0.0 - 0.3） */
    public var flReflectionsDelay: Float32 = 0.007f32
    /** @brief 早期反射全景（3 通道） */
    public var flReflectionsPan = VArray<Float32, $3>(repeat: 0.0f32)
    /** @brief 晚期混响增益（0.0 - 10.0） */
    public var flLateReverbGain: Float32 = 1.26f32
    /** @brief 晚期混响延迟（秒，0.0 - 0.1） */
    public var flLateReverbDelay: Float32 = 0.011f32
    /** @brief 晚期混响全景（3 通道） */
    public var flLateReverbPan = VArray<Float32, $3>(repeat: 0.0f32)
    /** @brief 回声时间（0.075 - 0.25 秒） */
    public var flEchoTime: Float32 = 0.25f32
    /** @brief 回声深度（0.0 - 1.0） */
    public var flEchoDepth: Float32 = 0.0f32
    /** @brief 调制时间（0.04 - 4.0 秒） */
    public var flModulationTime: Float32 = 0.25f32
    /** @brief 调制深度（0.0 - 1.0） */
    public var flModulationDepth: Float32 = 0.0f32
    /** @brief 空气吸收高频增益（0.892 - 1.0） */
    public var flAirAbsorptionGainHF: Float32 = 0.994f32
    /** @brief 高频参考频率（1000 - 20000 Hz） */
    public var flHFReference: Float32 = 5000.0f32
    /** @brief 低频参考频率（20 - 1000 Hz） */
    public var flLFReference: Float32 = 250.0f32
    /** @brief 房间滚降因子（0.0 - 10.0） */
    public var flRoomRolloffFactor: Float32 = 0.0f32
    /** @brief 衰减高频限制标志（0/1） */
    public var iDecayHFLimit: Int32 = 1

    public init() {}
}
