/**
 * @file openalsoft4cj.efx 范围常量定义
 * @brief EFX 各效果的参数范围常量（efx.h 中 AL_*_MIN / MAX / DEFAULT 系列）
 * @explain 直接映射自 efx.h 的 #define 宏，供设置/查询效果参数时使用。
 *         值类型按 C 宏语义推断：浮点用 Float32，整数用 Int32，
 *         AL_TRUE/AL_FALSE 用 UInt32（0/1）。
 */
protected package three._vendor.openalsoft4cj.efx

// =============================================================================
// Autowah 自动哇音
// =============================================================================

/** @brief 起音时间默认值（0.06s） */
public const AL_AUTOWAH_DEFAULT_ATTACK_TIME: Float32 = 0.06f32
/** @brief 峰值增益默认值（11.22） */
public const AL_AUTOWAH_DEFAULT_PEAK_GAIN: Float32 = 11.22f32
/** @brief 释放时间默认值（0.06s） */
public const AL_AUTOWAH_DEFAULT_RELEASE_TIME: Float32 = 0.06f32
/** @brief 谐振默认值（1000.0） */
public const AL_AUTOWAH_DEFAULT_RESONANCE: Float32 = 1000.0f32
/** @brief 起音时间最大值（1.0s） */
public const AL_AUTOWAH_MAX_ATTACK_TIME: Float32 = 1.0f32
/** @brief 峰值增益最大值（31621.0） */
public const AL_AUTOWAH_MAX_PEAK_GAIN: Float32 = 31621.0f32
/** @brief 释放时间最大值（1.0s） */
public const AL_AUTOWAH_MAX_RELEASE_TIME: Float32 = 1.0f32
/** @brief 谐振最大值（1000.0） */
public const AL_AUTOWAH_MAX_RESONANCE: Float32 = 1000.0f32
/** @brief 起音时间最小值（0.0001s） */
public const AL_AUTOWAH_MIN_ATTACK_TIME: Float32 = 0.0001f32
/** @brief 峰值增益最小值（0.00003） */
public const AL_AUTOWAH_MIN_PEAK_GAIN: Float32 = 0.00003f32
/** @brief 释放时间最小值（0.0001s） */
public const AL_AUTOWAH_MIN_RELEASE_TIME: Float32 = 0.0001f32
/** @brief 谐振最小值（2.0） */
public const AL_AUTOWAH_MIN_RESONANCE: Float32 = 2.0f32

// =============================================================================
// Bandpass 带通滤波
// =============================================================================

/** @brief 增益默认值（1.0） */
public const AL_BANDPASS_DEFAULT_GAIN: Float32 = 1.0f32
/** @brief 高频增益默认值（1.0） */
public const AL_BANDPASS_DEFAULT_GAINHF: Float32 = 1.0f32
/** @brief 低频增益默认值（1.0） */
public const AL_BANDPASS_DEFAULT_GAINLF: Float32 = 1.0f32
/** @brief 增益最大值（1.0） */
public const AL_BANDPASS_MAX_GAIN: Float32 = 1.0f32
/** @brief 高频增益最大值（1.0） */
public const AL_BANDPASS_MAX_GAINHF: Float32 = 1.0f32
/** @brief 低频增益最大值（1.0） */
public const AL_BANDPASS_MAX_GAINLF: Float32 = 1.0f32
/** @brief 增益最小值（0.0） */
public const AL_BANDPASS_MIN_GAIN: Float32 = 0.0f32
/** @brief 高频增益最小值（0.0） */
public const AL_BANDPASS_MIN_GAINHF: Float32 = 0.0f32
/** @brief 低频增益最小值（0.0） */
public const AL_BANDPASS_MIN_GAINLF: Float32 = 0.0f32

// =============================================================================
// Chorus 合唱
// =============================================================================

/** @brief 延迟默认值（0.016s） */
public const AL_CHORUS_DEFAULT_DELAY: Float32 = 0.016f32
/** @brief 深度默认值（0.1） */
public const AL_CHORUS_DEFAULT_DEPTH: Float32 = 0.1f32
/** @brief 反馈默认值（0.25） */
public const AL_CHORUS_DEFAULT_FEEDBACK: Float32 = 0.25f32
/** @brief 相位默认值（90 度） */
public const AL_CHORUS_DEFAULT_PHASE: Int32 = 90
/** @brief 速率默认值（1.1 Hz） */
public const AL_CHORUS_DEFAULT_RATE: Float32 = 1.1f32
/** @brief 波形默认值（1 = 三角波） */
public const AL_CHORUS_DEFAULT_WAVEFORM: Int32 = 1
/** @brief 延迟最大值（0.016s） */
public const AL_CHORUS_MAX_DELAY: Float32 = 0.016f32
/** @brief 深度最大值（1.0） */
public const AL_CHORUS_MAX_DEPTH: Float32 = 1.0f32
/** @brief 反馈最大值（1.0） */
public const AL_CHORUS_MAX_FEEDBACK: Float32 = 1.0f32
/** @brief 相位最大值（180 度） */
public const AL_CHORUS_MAX_PHASE: Int32 = 180
/** @brief 速率最大值（10.0 Hz） */
public const AL_CHORUS_MAX_RATE: Float32 = 10.0f32
/** @brief 波形最大值（1） */
public const AL_CHORUS_MAX_WAVEFORM: Int32 = 1
/** @brief 延迟最小值（0.0s） */
public const AL_CHORUS_MIN_DELAY: Float32 = 0.0f32
/** @brief 深度最小值（0.0） */
public const AL_CHORUS_MIN_DEPTH: Float32 = 0.0f32
/** @brief 反馈最小值（-1.0） */
public const AL_CHORUS_MIN_FEEDBACK: Float32 = -1.0f32
/** @brief 相位最小值（-180 度） */
public const AL_CHORUS_MIN_PHASE: Int32 = -180
/** @brief 速率最小值（0.0 Hz） */
public const AL_CHORUS_MIN_RATE: Float32 = 0.0f32
/** @brief 波形最小值（0） */
public const AL_CHORUS_MIN_WAVEFORM: Int32 = 0

// =============================================================================
// Compressor 压缩器
// =============================================================================

/** @brief 开关默认值（1 = 开） */
public const AL_COMPRESSOR_DEFAULT_ONOFF: Int32 = 1
/** @brief 开关最大值（1） */
public const AL_COMPRESSOR_MAX_ONOFF: Int32 = 1
/** @brief 开关最小值（0） */
public const AL_COMPRESSOR_MIN_ONOFF: Int32 = 0

// =============================================================================
// 全局 EFX 参数
// =============================================================================

/** @brief 空气吸收因子默认值（0.0） */
public const AL_DEFAULT_AIR_ABSORPTION_FACTOR: Float32 = 0.0f32
/** @brief 辅助发送滤波器高频增益自动默认值（真） */
public const AL_DEFAULT_AUXILIARY_SEND_FILTER_GAINHF_AUTO: UInt32 = 1
/** @brief 辅助发送滤波器增益自动默认值（真） */
public const AL_DEFAULT_AUXILIARY_SEND_FILTER_GAIN_AUTO: UInt32 = 1
/** @brief 外锥高频增益默认值（1.0） */
public const AL_DEFAULT_CONE_OUTER_GAINHF: Float32 = 1.0f32
/** @brief 直接滤波器高频增益自动默认值（真） */
public const AL_DEFAULT_DIRECT_FILTER_GAINHF_AUTO: UInt32 = 1
/** @brief 单位米数默认值（1.0） */
public const AL_DEFAULT_METERS_PER_UNIT: Float32 = 1.0f32
/** @brief 房间滚降因子默认值（0.0） */
public const AL_DEFAULT_ROOM_ROLLOFF_FACTOR: Float32 = 0.0f32
/** @brief 空气吸收因子最大值（10.0） */
public const AL_MAX_AIR_ABSORPTION_FACTOR: Float32 = 10.0f32
/** @brief 辅助发送滤波器高频增益自动最大值（真） */
public const AL_MAX_AUXILIARY_SEND_FILTER_GAINHF_AUTO: UInt32 = 1
/** @brief 辅助发送滤波器增益自动最大值（真） */
public const AL_MAX_AUXILIARY_SEND_FILTER_GAIN_AUTO: UInt32 = 1
/** @brief 外锥高频增益最大值（1.0） */
public const AL_MAX_CONE_OUTER_GAINHF: Float32 = 1.0f32
/** @brief 直接滤波器高频增益自动最大值（真） */
public const AL_MAX_DIRECT_FILTER_GAINHF_AUTO: UInt32 = 1
/** @brief 单位米数最大值（FLT_MAX） */
public const AL_MAX_METERS_PER_UNIT: Float32 = 3.4028235e38f32
/** @brief 房间滚降因子最大值（10.0） */
public const AL_MAX_ROOM_ROLLOFF_FACTOR: Float32 = 10.0f32
/** @brief 空气吸收因子最小值（0.0） */
public const AL_MIN_AIR_ABSORPTION_FACTOR: Float32 = 0.0f32
/** @brief 辅助发送滤波器高频增益自动最小值（假） */
public const AL_MIN_AUXILIARY_SEND_FILTER_GAINHF_AUTO: UInt32 = 0
/** @brief 辅助发送滤波器增益自动最小值（假） */
public const AL_MIN_AUXILIARY_SEND_FILTER_GAIN_AUTO: UInt32 = 0
/** @brief 外锥高频增益最小值（0.0） */
public const AL_MIN_CONE_OUTER_GAINHF: Float32 = 0.0f32
/** @brief 直接滤波器高频增益自动最小值（假） */
public const AL_MIN_DIRECT_FILTER_GAINHF_AUTO: UInt32 = 0
/** @brief 单位米数最小值（FLT_MIN） */
public const AL_MIN_METERS_PER_UNIT: Float32 = 1.1754944e-38f32
/** @brief 房间滚降因子最小值（0.0） */
public const AL_MIN_ROOM_ROLLOFF_FACTOR: Float32 = 0.0f32

// =============================================================================
// Distortion 失真
// =============================================================================

/** @brief 边缘默认值（0.2） */
public const AL_DISTORTION_DEFAULT_EDGE: Float32 = 0.2f32
/** @brief 均衡带宽默认值（3600 Hz） */
public const AL_DISTORTION_DEFAULT_EQBANDWIDTH: Float32 = 3600.0f32
/** @brief 均衡中心默认值（3600 Hz） */
public const AL_DISTORTION_DEFAULT_EQCENTER: Float32 = 3600.0f32
/** @brief 增益默认值（0.05） */
public const AL_DISTORTION_DEFAULT_GAIN: Float32 = 0.05f32
/** @brief 低通截止默认值（8000 Hz） */
public const AL_DISTORTION_DEFAULT_LOWPASS_CUTOFF: Float32 = 8000.0f32
/** @brief 边缘最大值（1.0） */
public const AL_DISTORTION_MAX_EDGE: Float32 = 1.0f32
/** @brief 均衡带宽最大值（24000 Hz） */
public const AL_DISTORTION_MAX_EQBANDWIDTH: Float32 = 24000.0f32
/** @brief 均衡中心最大值（24000 Hz） */
public const AL_DISTORTION_MAX_EQCENTER: Float32 = 24000.0f32
/** @brief 增益最大值（1.0） */
public const AL_DISTORTION_MAX_GAIN: Float32 = 1.0f32
/** @brief 低通截止最大值（24000 Hz） */
public const AL_DISTORTION_MAX_LOWPASS_CUTOFF: Float32 = 24000.0f32
/** @brief 边缘最小值（0.0） */
public const AL_DISTORTION_MIN_EDGE: Float32 = 0.0f32
/** @brief 均衡带宽最小值（80 Hz） */
public const AL_DISTORTION_MIN_EQBANDWIDTH: Float32 = 80.0f32
/** @brief 均衡中心最小值（80 Hz） */
public const AL_DISTORTION_MIN_EQCENTER: Float32 = 80.0f32
/** @brief 增益最小值（0.01） */
public const AL_DISTORTION_MIN_GAIN: Float32 = 0.01f32
/** @brief 低通截止最小值（80 Hz） */
public const AL_DISTORTION_MIN_LOWPASS_CUTOFF: Float32 = 80.0f32

// =============================================================================
// EAX Reverb EAX 混响
// =============================================================================

/** @brief 空气吸收高频增益默认值（0.994） */
public const AL_EAXREVERB_DEFAULT_AIR_ABSORPTION_GAINHF: Float32 = 0.994f32
/** @brief 衰减高频限制默认值（真） */
public const AL_EAXREVERB_DEFAULT_DECAY_HFLIMIT: UInt32 = 1
/** @brief 高频衰减比默认值（0.83） */
public const AL_EAXREVERB_DEFAULT_DECAY_HFRATIO: Float32 = 0.83f32
/** @brief 低频衰减比默认值（1.0） */
public const AL_EAXREVERB_DEFAULT_DECAY_LFRATIO: Float32 = 1.0f32
/** @brief 衰减时间默认值（1.49s） */
public const AL_EAXREVERB_DEFAULT_DECAY_TIME: Float32 = 1.49f32
/** @brief 密度默认值（1.0） */
public const AL_EAXREVERB_DEFAULT_DENSITY: Float32 = 1.0f32
/** @brief 扩散度默认值（1.0） */
public const AL_EAXREVERB_DEFAULT_DIFFUSION: Float32 = 1.0f32
/** @brief 回声深度默认值（0.0） */
public const AL_EAXREVERB_DEFAULT_ECHO_DEPTH: Float32 = 0.0f32
/** @brief 回声时间默认值（0.25s） */
public const AL_EAXREVERB_DEFAULT_ECHO_TIME: Float32 = 0.25f32
/** @brief 主增益默认值（0.32） */
public const AL_EAXREVERB_DEFAULT_GAIN: Float32 = 0.32f32
/** @brief 高频增益默认值（0.89） */
public const AL_EAXREVERB_DEFAULT_GAINHF: Float32 = 0.89f32
/** @brief 低频增益默认值（1.0） */
public const AL_EAXREVERB_DEFAULT_GAINLF: Float32 = 1.0f32
/** @brief 高频参考默认值（5000 Hz） */
public const AL_EAXREVERB_DEFAULT_HFREFERENCE: Float32 = 5000.0f32
/** @brief 晚期混响延迟默认值（0.011s） */
public const AL_EAXREVERB_DEFAULT_LATE_REVERB_DELAY: Float32 = 0.011f32
/** @brief 晚期混响增益默认值（1.26） */
public const AL_EAXREVERB_DEFAULT_LATE_REVERB_GAIN: Float32 = 1.26f32
/** @brief 晚期混响全景默认值（0.0） */
public const AL_EAXREVERB_DEFAULT_LATE_REVERB_PAN_XYZ: Float32 = 0.0f32
/** @brief 低频参考默认值（250 Hz） */
public const AL_EAXREVERB_DEFAULT_LFREFERENCE: Float32 = 250.0f32
/** @brief 调制深度默认值（0.0） */
public const AL_EAXREVERB_DEFAULT_MODULATION_DEPTH: Float32 = 0.0f32
/** @brief 调制时间默认值（0.25s） */
public const AL_EAXREVERB_DEFAULT_MODULATION_TIME: Float32 = 0.25f32
/** @brief 早期反射延迟默认值（0.007s） */
public const AL_EAXREVERB_DEFAULT_REFLECTIONS_DELAY: Float32 = 0.007f32
/** @brief 早期反射增益默认值（0.05） */
public const AL_EAXREVERB_DEFAULT_REFLECTIONS_GAIN: Float32 = 0.05f32
/** @brief 早期反射全景默认值（0.0） */
public const AL_EAXREVERB_DEFAULT_REFLECTIONS_PAN_XYZ: Float32 = 0.0f32
/** @brief 房间滚降因子默认值（0.0） */
public const AL_EAXREVERB_DEFAULT_ROOM_ROLLOFF_FACTOR: Float32 = 0.0f32
/** @brief 空气吸收高频增益最大值（1.0） */
public const AL_EAXREVERB_MAX_AIR_ABSORPTION_GAINHF: Float32 = 1.0f32
/** @brief 衰减高频限制最大值（真） */
public const AL_EAXREVERB_MAX_DECAY_HFLIMIT: UInt32 = 1
/** @brief 高频衰减比最大值（2.0） */
public const AL_EAXREVERB_MAX_DECAY_HFRATIO: Float32 = 2.0f32
/** @brief 低频衰减比最大值（2.0） */
public const AL_EAXREVERB_MAX_DECAY_LFRATIO: Float32 = 2.0f32
/** @brief 衰减时间最大值（20.0s） */
public const AL_EAXREVERB_MAX_DECAY_TIME: Float32 = 20.0f32
/** @brief 密度最大值（1.0） */
public const AL_EAXREVERB_MAX_DENSITY: Float32 = 1.0f32
/** @brief 扩散度最大值（1.0） */
public const AL_EAXREVERB_MAX_DIFFUSION: Float32 = 1.0f32
/** @brief 回声深度最大值（1.0） */
public const AL_EAXREVERB_MAX_ECHO_DEPTH: Float32 = 1.0f32
/** @brief 回声时间最大值（0.25s） */
public const AL_EAXREVERB_MAX_ECHO_TIME: Float32 = 0.25f32
/** @brief 主增益最大值（1.0） */
public const AL_EAXREVERB_MAX_GAIN: Float32 = 1.0f32
/** @brief 高频增益最大值（1.0） */
public const AL_EAXREVERB_MAX_GAINHF: Float32 = 1.0f32
/** @brief 低频增益最大值（1.0） */
public const AL_EAXREVERB_MAX_GAINLF: Float32 = 1.0f32
/** @brief 高频参考最大值（20000 Hz） */
public const AL_EAXREVERB_MAX_HFREFERENCE: Float32 = 20000.0f32
/** @brief 晚期混响延迟最大值（0.1s） */
public const AL_EAXREVERB_MAX_LATE_REVERB_DELAY: Float32 = 0.1f32
/** @brief 晚期混响增益最大值（10.0） */
public const AL_EAXREVERB_MAX_LATE_REVERB_GAIN: Float32 = 10.0f32
/** @brief 低频参考最大值（1000 Hz） */
public const AL_EAXREVERB_MAX_LFREFERENCE: Float32 = 1000.0f32
/** @brief 调制深度最大值（1.0） */
public const AL_EAXREVERB_MAX_MODULATION_DEPTH: Float32 = 1.0f32
/** @brief 调制时间最大值（4.0s） */
public const AL_EAXREVERB_MAX_MODULATION_TIME: Float32 = 4.0f32
/** @brief 早期反射延迟最大值（0.3s） */
public const AL_EAXREVERB_MAX_REFLECTIONS_DELAY: Float32 = 0.3f32
/** @brief 早期反射增益最大值（3.16） */
public const AL_EAXREVERB_MAX_REFLECTIONS_GAIN: Float32 = 3.16f32
/** @brief 房间滚降因子最大值（10.0） */
public const AL_EAXREVERB_MAX_ROOM_ROLLOFF_FACTOR: Float32 = 10.0f32
/** @brief 空气吸收高频增益最小值（0.892） */
public const AL_EAXREVERB_MIN_AIR_ABSORPTION_GAINHF: Float32 = 0.892f32
/** @brief 衰减高频限制最小值（假） */
public const AL_EAXREVERB_MIN_DECAY_HFLIMIT: UInt32 = 0
/** @brief 高频衰减比最小值（0.1） */
public const AL_EAXREVERB_MIN_DECAY_HFRATIO: Float32 = 0.1f32
/** @brief 低频衰减比最小值（0.1） */
public const AL_EAXREVERB_MIN_DECAY_LFRATIO: Float32 = 0.1f32
/** @brief 衰减时间最小值（0.1s） */
public const AL_EAXREVERB_MIN_DECAY_TIME: Float32 = 0.1f32
/** @brief 密度最小值（0.0） */
public const AL_EAXREVERB_MIN_DENSITY: Float32 = 0.0f32
/** @brief 扩散度最小值（0.0） */
public const AL_EAXREVERB_MIN_DIFFUSION: Float32 = 0.0f32
/** @brief 回声深度最小值（0.0） */
public const AL_EAXREVERB_MIN_ECHO_DEPTH: Float32 = 0.0f32
/** @brief 回声时间最小值（0.075s） */
public const AL_EAXREVERB_MIN_ECHO_TIME: Float32 = 0.075f32
/** @brief 主增益最小值（0.0） */
public const AL_EAXREVERB_MIN_GAIN: Float32 = 0.0f32
/** @brief 高频增益最小值（0.0） */
public const AL_EAXREVERB_MIN_GAINHF: Float32 = 0.0f32
/** @brief 低频增益最小值（0.0） */
public const AL_EAXREVERB_MIN_GAINLF: Float32 = 0.0f32
/** @brief 高频参考最小值（1000 Hz） */
public const AL_EAXREVERB_MIN_HFREFERENCE: Float32 = 1000.0f32
/** @brief 晚期混响延迟最小值（0.0s） */
public const AL_EAXREVERB_MIN_LATE_REVERB_DELAY: Float32 = 0.0f32
/** @brief 晚期混响增益最小值（0.0） */
public const AL_EAXREVERB_MIN_LATE_REVERB_GAIN: Float32 = 0.0f32
/** @brief 低频参考最小值（20 Hz） */
public const AL_EAXREVERB_MIN_LFREFERENCE: Float32 = 20.0f32
/** @brief 调制深度最小值（0.0） */
public const AL_EAXREVERB_MIN_MODULATION_DEPTH: Float32 = 0.0f32
/** @brief 调制时间最小值（0.04s） */
public const AL_EAXREVERB_MIN_MODULATION_TIME: Float32 = 0.04f32
/** @brief 早期反射延迟最小值（0.0s） */
public const AL_EAXREVERB_MIN_REFLECTIONS_DELAY: Float32 = 0.0f32
/** @brief 早期反射增益最小值（0.0） */
public const AL_EAXREVERB_MIN_REFLECTIONS_GAIN: Float32 = 0.0f32
/** @brief 房间滚降因子最小值（0.0） */
public const AL_EAXREVERB_MIN_ROOM_ROLLOFF_FACTOR: Float32 = 0.0f32

// =============================================================================
// Echo 回声
// =============================================================================

/** @brief 阻尼默认值（0.5） */
public const AL_ECHO_DEFAULT_DAMPING: Float32 = 0.5f32
/** @brief 延迟默认值（0.1s） */
public const AL_ECHO_DEFAULT_DELAY: Float32 = 0.1f32
/** @brief 反馈默认值（0.5） */
public const AL_ECHO_DEFAULT_FEEDBACK: Float32 = 0.5f32
/** @brief 左右延迟默认值（0.1s） */
public const AL_ECHO_DEFAULT_LRDELAY: Float32 = 0.1f32
/** @brief 扩散默认值（-1.0） */
public const AL_ECHO_DEFAULT_SPREAD: Float32 = -1.0f32
/** @brief 阻尼最大值（0.99） */
public const AL_ECHO_MAX_DAMPING: Float32 = 0.99f32
/** @brief 延迟最大值（0.207s） */
public const AL_ECHO_MAX_DELAY: Float32 = 0.207f32
/** @brief 反馈最大值（1.0） */
public const AL_ECHO_MAX_FEEDBACK: Float32 = 1.0f32
/** @brief 左右延迟最大值（0.404s） */
public const AL_ECHO_MAX_LRDELAY: Float32 = 0.404f32
/** @brief 扩散最大值（1.0） */
public const AL_ECHO_MAX_SPREAD: Float32 = 1.0f32
/** @brief 阻尼最小值（0.0） */
public const AL_ECHO_MIN_DAMPING: Float32 = 0.0f32
/** @brief 延迟最小值（0.0s） */
public const AL_ECHO_MIN_DELAY: Float32 = 0.0f32
/** @brief 反馈最小值（0.0） */
public const AL_ECHO_MIN_FEEDBACK: Float32 = 0.0f32
/** @brief 左右延迟最小值（0.0s） */
public const AL_ECHO_MIN_LRDELAY: Float32 = 0.0f32
/** @brief 扩散最小值（-1.0） */
public const AL_ECHO_MIN_SPREAD: Float32 = -1.0f32

// =============================================================================
// Equalizer 均衡器
// =============================================================================

/** @brief 高频截止默认值（6000 Hz） */
public const AL_EQUALIZER_DEFAULT_HIGH_CUTOFF: Float32 = 6000.0f32
/** @brief 高频增益默认值（1.0） */
public const AL_EQUALIZER_DEFAULT_HIGH_GAIN: Float32 = 1.0f32
/** @brief 低频截止默认值（200 Hz） */
public const AL_EQUALIZER_DEFAULT_LOW_CUTOFF: Float32 = 200.0f32
/** @brief 低频增益默认值（1.0） */
public const AL_EQUALIZER_DEFAULT_LOW_GAIN: Float32 = 1.0f32
/** @brief 中频 1 中心默认值（500 Hz） */
public const AL_EQUALIZER_DEFAULT_MID1_CENTER: Float32 = 500.0f32
/** @brief 中频 1 增益默认值（1.0） */
public const AL_EQUALIZER_DEFAULT_MID1_GAIN: Float32 = 1.0f32
/** @brief 中频 1 宽度默认值（1.0） */
public const AL_EQUALIZER_DEFAULT_MID1_WIDTH: Float32 = 1.0f32
/** @brief 中频 2 中心默认值（3000 Hz） */
public const AL_EQUALIZER_DEFAULT_MID2_CENTER: Float32 = 3000.0f32
/** @brief 中频 2 增益默认值（1.0） */
public const AL_EQUALIZER_DEFAULT_MID2_GAIN: Float32 = 1.0f32
/** @brief 中频 2 宽度默认值（1.0） */
public const AL_EQUALIZER_DEFAULT_MID2_WIDTH: Float32 = 1.0f32
/** @brief 高频截止最大值（16000 Hz） */
public const AL_EQUALIZER_MAX_HIGH_CUTOFF: Float32 = 16000.0f32
/** @brief 高频增益最大值（7.943） */
public const AL_EQUALIZER_MAX_HIGH_GAIN: Float32 = 7.943f32
/** @brief 低频截止最大值（800 Hz） */
public const AL_EQUALIZER_MAX_LOW_CUTOFF: Float32 = 800.0f32
/** @brief 低频增益最大值（7.943） */
public const AL_EQUALIZER_MAX_LOW_GAIN: Float32 = 7.943f32
/** @brief 中频 1 中心最大值（3000 Hz） */
public const AL_EQUALIZER_MAX_MID1_CENTER: Float32 = 3000.0f32
/** @brief 中频 1 增益最大值（7.943） */
public const AL_EQUALIZER_MAX_MID1_GAIN: Float32 = 7.943f32
/** @brief 中频 1 宽度最大值（1.0） */
public const AL_EQUALIZER_MAX_MID1_WIDTH: Float32 = 1.0f32
/** @brief 中频 2 中心最大值（8000 Hz） */
public const AL_EQUALIZER_MAX_MID2_CENTER: Float32 = 8000.0f32
/** @brief 中频 2 增益最大值（7.943） */
public const AL_EQUALIZER_MAX_MID2_GAIN: Float32 = 7.943f32
/** @brief 中频 2 宽度最大值（1.0） */
public const AL_EQUALIZER_MAX_MID2_WIDTH: Float32 = 1.0f32
/** @brief 高频截止最小值（4000 Hz） */
public const AL_EQUALIZER_MIN_HIGH_CUTOFF: Float32 = 4000.0f32
/** @brief 高频增益最小值（0.126） */
public const AL_EQUALIZER_MIN_HIGH_GAIN: Float32 = 0.126f32
/** @brief 低频截止最小值（50 Hz） */
public const AL_EQUALIZER_MIN_LOW_CUTOFF: Float32 = 50.0f32
/** @brief 低频增益最小值（0.126） */
public const AL_EQUALIZER_MIN_LOW_GAIN: Float32 = 0.126f32
/** @brief 中频 1 中心最小值（200 Hz） */
public const AL_EQUALIZER_MIN_MID1_CENTER: Float32 = 200.0f32
/** @brief 中频 1 增益最小值（0.126） */
public const AL_EQUALIZER_MIN_MID1_GAIN: Float32 = 0.126f32
/** @brief 中频 1 宽度最小值（0.01） */
public const AL_EQUALIZER_MIN_MID1_WIDTH: Float32 = 0.01f32
/** @brief 中频 2 中心最小值（1000 Hz） */
public const AL_EQUALIZER_MIN_MID2_CENTER: Float32 = 1000.0f32
/** @brief 中频 2 增益最小值（0.126） */
public const AL_EQUALIZER_MIN_MID2_GAIN: Float32 = 0.126f32
/** @brief 中频 2 宽度最小值（0.01） */
public const AL_EQUALIZER_MIN_MID2_WIDTH: Float32 = 0.01f32

// =============================================================================
// Flanger 镶边
// =============================================================================

/** @brief 延迟默认值（0.002s） */
public const AL_FLANGER_DEFAULT_DELAY: Float32 = 0.002f32
/** @brief 深度默认值（1.0） */
public const AL_FLANGER_DEFAULT_DEPTH: Float32 = 1.0f32
/** @brief 反馈默认值（-0.5） */
public const AL_FLANGER_DEFAULT_FEEDBACK: Float32 = -0.5f32
/** @brief 相位默认值（0 度） */
public const AL_FLANGER_DEFAULT_PHASE: Int32 = 0
/** @brief 速率默认值（0.27 Hz） */
public const AL_FLANGER_DEFAULT_RATE: Float32 = 0.27f32
/** @brief 波形默认值（1 = 三角波） */
public const AL_FLANGER_DEFAULT_WAVEFORM: Int32 = 1
/** @brief 延迟最大值（0.004s） */
public const AL_FLANGER_MAX_DELAY: Float32 = 0.004f32
/** @brief 深度最大值（1.0） */
public const AL_FLANGER_MAX_DEPTH: Float32 = 1.0f32
/** @brief 反馈最大值（1.0） */
public const AL_FLANGER_MAX_FEEDBACK: Float32 = 1.0f32
/** @brief 相位最大值（180 度） */
public const AL_FLANGER_MAX_PHASE: Int32 = 180
/** @brief 速率最大值（10.0 Hz） */
public const AL_FLANGER_MAX_RATE: Float32 = 10.0f32
/** @brief 波形最大值（1） */
public const AL_FLANGER_MAX_WAVEFORM: Int32 = 1
/** @brief 延迟最小值（0.0s） */
public const AL_FLANGER_MIN_DELAY: Float32 = 0.0f32
/** @brief 深度最小值（0.0） */
public const AL_FLANGER_MIN_DEPTH: Float32 = 0.0f32
/** @brief 反馈最小值（-1.0） */
public const AL_FLANGER_MIN_FEEDBACK: Float32 = -1.0f32
/** @brief 相位最小值（-180 度） */
public const AL_FLANGER_MIN_PHASE: Int32 = -180
/** @brief 速率最小值（0.0 Hz） */
public const AL_FLANGER_MIN_RATE: Float32 = 0.0f32
/** @brief 波形最小值（0） */
public const AL_FLANGER_MIN_WAVEFORM: Int32 = 0

// =============================================================================
// Frequency Shifter 移频器
// =============================================================================

/** @brief 频率默认值（0.0 Hz） */
public const AL_FREQUENCY_SHIFTER_DEFAULT_FREQUENCY: Float32 = 0.0f32
/** @brief 左声道方向默认值（0） */
public const AL_FREQUENCY_SHIFTER_DEFAULT_LEFT_DIRECTION: Int32 = 0
/** @brief 右声道方向默认值（0） */
public const AL_FREQUENCY_SHIFTER_DEFAULT_RIGHT_DIRECTION: Int32 = 0
/** @brief 频率最大值（24000 Hz） */
public const AL_FREQUENCY_SHIFTER_MAX_FREQUENCY: Float32 = 24000.0f32
/** @brief 左声道方向最大值（2） */
public const AL_FREQUENCY_SHIFTER_MAX_LEFT_DIRECTION: Int32 = 2
/** @brief 右声道方向最大值（2） */
public const AL_FREQUENCY_SHIFTER_MAX_RIGHT_DIRECTION: Int32 = 2
/** @brief 频率最小值（0.0 Hz） */
public const AL_FREQUENCY_SHIFTER_MIN_FREQUENCY: Float32 = 0.0f32
/** @brief 左声道方向最小值（0） */
public const AL_FREQUENCY_SHIFTER_MIN_LEFT_DIRECTION: Int32 = 0
/** @brief 右声道方向最小值（0） */
public const AL_FREQUENCY_SHIFTER_MIN_RIGHT_DIRECTION: Int32 = 0

// =============================================================================
// Highpass 高通滤波
// =============================================================================

/** @brief 增益默认值（1.0） */
public const AL_HIGHPASS_DEFAULT_GAIN: Float32 = 1.0f32
/** @brief 低频增益默认值（1.0） */
public const AL_HIGHPASS_DEFAULT_GAINLF: Float32 = 1.0f32
/** @brief 增益最大值（1.0） */
public const AL_HIGHPASS_MAX_GAIN: Float32 = 1.0f32
/** @brief 低频增益最大值（1.0） */
public const AL_HIGHPASS_MAX_GAINLF: Float32 = 1.0f32
/** @brief 增益最小值（0.0） */
public const AL_HIGHPASS_MIN_GAIN: Float32 = 0.0f32
/** @brief 低频增益最小值（0.0） */
public const AL_HIGHPASS_MIN_GAINLF: Float32 = 0.0f32

// =============================================================================
// Lowpass 低通滤波
// =============================================================================

/** @brief 增益默认值（1.0） */
public const AL_LOWPASS_DEFAULT_GAIN: Float32 = 1.0f32
/** @brief 高频增益默认值（1.0） */
public const AL_LOWPASS_DEFAULT_GAINHF: Float32 = 1.0f32
/** @brief 增益最大值（1.0） */
public const AL_LOWPASS_MAX_GAIN: Float32 = 1.0f32
/** @brief 高频增益最大值（1.0） */
public const AL_LOWPASS_MAX_GAINHF: Float32 = 1.0f32
/** @brief 增益最小值（0.0） */
public const AL_LOWPASS_MIN_GAIN: Float32 = 0.0f32
/** @brief 高频增益最小值（0.0） */
public const AL_LOWPASS_MIN_GAINHF: Float32 = 0.0f32

// =============================================================================
// Pitch Shifter 移调器
// =============================================================================

/** @brief 粗调默认值（12 半音） */
public const AL_PITCH_SHIFTER_DEFAULT_COARSE_TUNE: Int32 = 12
/** @brief 细调默认值（0 音分） */
public const AL_PITCH_SHIFTER_DEFAULT_FINE_TUNE: Int32 = 0
/** @brief 粗调最大值（12 半音） */
public const AL_PITCH_SHIFTER_MAX_COARSE_TUNE: Int32 = 12
/** @brief 细调最大值（50 音分） */
public const AL_PITCH_SHIFTER_MAX_FINE_TUNE: Int32 = 50
/** @brief 粗调最小值（-12 半音） */
public const AL_PITCH_SHIFTER_MIN_COARSE_TUNE: Int32 = -12
/** @brief 细调最小值（-50 音分） */
public const AL_PITCH_SHIFTER_MIN_FINE_TUNE: Int32 = -50

// =============================================================================
// Reverb 标准混响
// =============================================================================

/** @brief 空气吸收高频增益默认值（0.994） */
public const AL_REVERB_DEFAULT_AIR_ABSORPTION_GAINHF: Float32 = 0.994f32
/** @brief 衰减高频限制默认值（真） */
public const AL_REVERB_DEFAULT_DECAY_HFLIMIT: UInt32 = 1
/** @brief 高频衰减比默认值（0.83） */
public const AL_REVERB_DEFAULT_DECAY_HFRATIO: Float32 = 0.83f32
/** @brief 衰减时间默认值（1.49s） */
public const AL_REVERB_DEFAULT_DECAY_TIME: Float32 = 1.49f32
/** @brief 密度默认值（1.0） */
public const AL_REVERB_DEFAULT_DENSITY: Float32 = 1.0f32
/** @brief 扩散度默认值（1.0） */
public const AL_REVERB_DEFAULT_DIFFUSION: Float32 = 1.0f32
/** @brief 主增益默认值（0.32） */
public const AL_REVERB_DEFAULT_GAIN: Float32 = 0.32f32
/** @brief 高频增益默认值（0.89） */
public const AL_REVERB_DEFAULT_GAINHF: Float32 = 0.89f32
/** @brief 晚期混响延迟默认值（0.011s） */
public const AL_REVERB_DEFAULT_LATE_REVERB_DELAY: Float32 = 0.011f32
/** @brief 晚期混响增益默认值（1.26） */
public const AL_REVERB_DEFAULT_LATE_REVERB_GAIN: Float32 = 1.26f32
/** @brief 早期反射延迟默认值（0.007s） */
public const AL_REVERB_DEFAULT_REFLECTIONS_DELAY: Float32 = 0.007f32
/** @brief 早期反射增益默认值（0.05） */
public const AL_REVERB_DEFAULT_REFLECTIONS_GAIN: Float32 = 0.05f32
/** @brief 房间滚降因子默认值（0.0） */
public const AL_REVERB_DEFAULT_ROOM_ROLLOFF_FACTOR: Float32 = 0.0f32
/** @brief 空气吸收高频增益最大值（1.0） */
public const AL_REVERB_MAX_AIR_ABSORPTION_GAINHF: Float32 = 1.0f32
/** @brief 衰减高频限制最大值（真） */
public const AL_REVERB_MAX_DECAY_HFLIMIT: UInt32 = 1
/** @brief 高频衰减比最大值（2.0） */
public const AL_REVERB_MAX_DECAY_HFRATIO: Float32 = 2.0f32
/** @brief 衰减时间最大值（20.0s） */
public const AL_REVERB_MAX_DECAY_TIME: Float32 = 20.0f32
/** @brief 密度最大值（1.0） */
public const AL_REVERB_MAX_DENSITY: Float32 = 1.0f32
/** @brief 扩散度最大值（1.0） */
public const AL_REVERB_MAX_DIFFUSION: Float32 = 1.0f32
/** @brief 主增益最大值（1.0） */
public const AL_REVERB_MAX_GAIN: Float32 = 1.0f32
/** @brief 高频增益最大值（1.0） */
public const AL_REVERB_MAX_GAINHF: Float32 = 1.0f32
/** @brief 晚期混响延迟最大值（0.1s） */
public const AL_REVERB_MAX_LATE_REVERB_DELAY: Float32 = 0.1f32
/** @brief 晚期混响增益最大值（10.0） */
public const AL_REVERB_MAX_LATE_REVERB_GAIN: Float32 = 10.0f32
/** @brief 早期反射延迟最大值（0.3s） */
public const AL_REVERB_MAX_REFLECTIONS_DELAY: Float32 = 0.3f32
/** @brief 早期反射增益最大值（3.16） */
public const AL_REVERB_MAX_REFLECTIONS_GAIN: Float32 = 3.16f32
/** @brief 房间滚降因子最大值（10.0） */
public const AL_REVERB_MAX_ROOM_ROLLOFF_FACTOR: Float32 = 10.0f32
/** @brief 空气吸收高频增益最小值（0.892） */
public const AL_REVERB_MIN_AIR_ABSORPTION_GAINHF: Float32 = 0.892f32
/** @brief 衰减高频限制最小值（假） */
public const AL_REVERB_MIN_DECAY_HFLIMIT: UInt32 = 0
/** @brief 高频衰减比最小值（0.1） */
public const AL_REVERB_MIN_DECAY_HFRATIO: Float32 = 0.1f32
/** @brief 衰减时间最小值（0.1s） */
public const AL_REVERB_MIN_DECAY_TIME: Float32 = 0.1f32
/** @brief 密度最小值（0.0） */
public const AL_REVERB_MIN_DENSITY: Float32 = 0.0f32
/** @brief 扩散度最小值（0.0） */
public const AL_REVERB_MIN_DIFFUSION: Float32 = 0.0f32
/** @brief 主增益最小值（0.0） */
public const AL_REVERB_MIN_GAIN: Float32 = 0.0f32
/** @brief 高频增益最小值（0.0） */
public const AL_REVERB_MIN_GAINHF: Float32 = 0.0f32
/** @brief 晚期混响延迟最小值（0.0s） */
public const AL_REVERB_MIN_LATE_REVERB_DELAY: Float32 = 0.0f32
/** @brief 晚期混响增益最小值（0.0） */
public const AL_REVERB_MIN_LATE_REVERB_GAIN: Float32 = 0.0f32
/** @brief 早期反射延迟最小值（0.0s） */
public const AL_REVERB_MIN_REFLECTIONS_DELAY: Float32 = 0.0f32
/** @brief 早期反射增益最小值（0.0） */
public const AL_REVERB_MIN_REFLECTIONS_GAIN: Float32 = 0.0f32
/** @brief 房间滚降因子最小值（0.0） */
public const AL_REVERB_MIN_ROOM_ROLLOFF_FACTOR: Float32 = 0.0f32

// =============================================================================
// Ring Modulator 环形调制器
// =============================================================================

/** @brief 频率默认值（440 Hz） */
public const AL_RING_MODULATOR_DEFAULT_FREQUENCY: Float32 = 440.0f32
/** @brief 高通截止默认值（800 Hz） */
public const AL_RING_MODULATOR_DEFAULT_HIGHPASS_CUTOFF: Float32 = 800.0f32
/** @brief 波形默认值（0 = 正弦） */
public const AL_RING_MODULATOR_DEFAULT_WAVEFORM: Int32 = 0
/** @brief 频率最大值（8000 Hz） */
public const AL_RING_MODULATOR_MAX_FREQUENCY: Float32 = 8000.0f32
/** @brief 高通截止最大值（24000 Hz） */
public const AL_RING_MODULATOR_MAX_HIGHPASS_CUTOFF: Float32 = 24000.0f32
/** @brief 波形最大值（2） */
public const AL_RING_MODULATOR_MAX_WAVEFORM: Int32 = 2
/** @brief 频率最小值（0.0 Hz） */
public const AL_RING_MODULATOR_MIN_FREQUENCY: Float32 = 0.0f32
/** @brief 高通截止最小值（0.0 Hz） */
public const AL_RING_MODULATOR_MIN_HIGHPASS_CUTOFF: Float32 = 0.0f32
/** @brief 波形最小值（0） */
public const AL_RING_MODULATOR_MIN_WAVEFORM: Int32 = 0

// =============================================================================
// Vocal Morpher 语音变形器
// =============================================================================

/** @brief 音素 A 默认值（0） */
public const AL_VOCAL_MORPHER_DEFAULT_PHONEMEA: Int32 = 0
/** @brief 音素 A 粗调默认值（0） */
public const AL_VOCAL_MORPHER_DEFAULT_PHONEMEA_COARSE_TUNING: Int32 = 0
/** @brief 音素 B 默认值（10） */
public const AL_VOCAL_MORPHER_DEFAULT_PHONEMEB: Int32 = 10
/** @brief 音素 B 粗调默认值（0） */
public const AL_VOCAL_MORPHER_DEFAULT_PHONEMEB_COARSE_TUNING: Int32 = 0
/** @brief 速率默认值（1.41 Hz） */
public const AL_VOCAL_MORPHER_DEFAULT_RATE: Float32 = 1.41f32
/** @brief 波形默认值（0） */
public const AL_VOCAL_MORPHER_DEFAULT_WAVEFORM: Int32 = 0
/** @brief 音素 A 最大值（29） */
public const AL_VOCAL_MORPHER_MAX_PHONEMEA: Int32 = 29
/** @brief 音素 A 粗调最大值（24） */
public const AL_VOCAL_MORPHER_MAX_PHONEMEA_COARSE_TUNING: Int32 = 24
/** @brief 音素 B 最大值（29） */
public const AL_VOCAL_MORPHER_MAX_PHONEMEB: Int32 = 29
/** @brief 音素 B 粗调最大值（24） */
public const AL_VOCAL_MORPHER_MAX_PHONEMEB_COARSE_TUNING: Int32 = 24
/** @brief 速率最大值（10.0 Hz） */
public const AL_VOCAL_MORPHER_MAX_RATE: Float32 = 10.0f32
/** @brief 波形最大值（2） */
public const AL_VOCAL_MORPHER_MAX_WAVEFORM: Int32 = 2
/** @brief 音素 A 最小值（0） */
public const AL_VOCAL_MORPHER_MIN_PHONEMEA: Int32 = 0
/** @brief 音素 A 粗调最小值（-24） */
public const AL_VOCAL_MORPHER_MIN_PHONEMEA_COARSE_TUNING: Int32 = -24
/** @brief 音素 B 最小值（0） */
public const AL_VOCAL_MORPHER_MIN_PHONEMEB: Int32 = 0
/** @brief 音素 B 粗调最小值（-24） */
public const AL_VOCAL_MORPHER_MIN_PHONEMEB_COARSE_TUNING: Int32 = -24
/** @brief 速率最小值（0.0 Hz） */
public const AL_VOCAL_MORPHER_MIN_RATE: Float32 = 0.0f32
/** @brief 波形最小值（0） */
public const AL_VOCAL_MORPHER_MIN_WAVEFORM: Int32 = 0
