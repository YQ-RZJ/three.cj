/**
 * @file openalsoft4cj.efx 常量定义
 * @brief OpenAL EFX 扩展（efx.h）的核心参数常量
 * @explain 本文件包含 efx.h 中的效果/滤波器参数标识符常量（过滤 MIN/MAX/
 *         DEFAULT 范围常量，这些辅助常量如需可按同名在 efx.h 中查询）。
 * @note 效果类型取值见 types.cj 中的 EffectType / FilterType 枚举。
 */
protected package three._vendor.openalsoft4cj.efx

// =============================================================================
// EFX 扩展全局常量
// =============================================================================

/** @brief EFX 扩展名字符串（ALC_EXT_EFX_NAME = "ALC_EXT_EFX"） */
public const ALC_EXT_EFX_NAME: String = "ALC_EXT_EFX"
/** @brief EFX 主版本（ALC_EFX_MAJOR_VERSION = 0x20001） */
public const ALC_EFX_MAJOR_VERSION: UInt32 = 0x20001
/** @brief EFX 次版本（ALC_EFX_MINOR_VERSION = 0x20002） */
public const ALC_EFX_MINOR_VERSION: UInt32 = 0x20002
/** @brief 最大辅助发送数（ALC_MAX_AUXILIARY_SENDS = 0x20003） */
public const ALC_MAX_AUXILIARY_SENDS: UInt32 = 0x20003

// =============================================================================
// 源/监听器 EFX 参数
// =============================================================================

/** @brief 单位米数（AL_METERS_PER_UNIT = 0x20004） */
public const AL_METERS_PER_UNIT: UInt32 = 0x20004
/** @brief 直接滤波器（AL_DIRECT_FILTER = 0x20005） */
public const AL_DIRECT_FILTER: UInt32 = 0x20005
/** @brief 辅助发送滤波器（AL_AUXILIARY_SEND_FILTER = 0x20006） */
public const AL_AUXILIARY_SEND_FILTER: UInt32 = 0x20006
/** @brief 空气吸收因子（AL_AIR_ABSORPTION_FACTOR = 0x20007） */
public const AL_AIR_ABSORPTION_FACTOR: UInt32 = 0x20007
/** @brief 房间滚降因子（AL_ROOM_ROLLOFF_FACTOR = 0x20008） */
public const AL_ROOM_ROLLOFF_FACTOR: UInt32 = 0x20008
/** @brief 外锥高频增益（AL_CONE_OUTER_GAINHF = 0x20009） */
public const AL_CONE_OUTER_GAINHF: UInt32 = 0x20009
/** @brief 直接滤波器高频增益自动（AL_DIRECT_FILTER_GAINHF_AUTO = 0x2000A） */
public const AL_DIRECT_FILTER_GAINHF_AUTO: UInt32 = 0x2000A
/** @brief 辅助发送滤波器增益自动（AL_AUXILIARY_SEND_FILTER_GAIN_AUTO = 0x2000B） */
public const AL_AUXILIARY_SEND_FILTER_GAIN_AUTO: UInt32 = 0x2000B
/** @brief 辅助发送滤波器高频增益自动（AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO = 0x2000C） */
public const AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO: UInt32 = 0x2000C

// =============================================================================
// Reverb 效果参数（标准混响）
// =============================================================================

/** @brief 混响密度（AL_REVERB_DENSITY = 0x0001） */
public const AL_REVERB_DENSITY: UInt32 = 0x0001
/** @brief 混响扩散度（AL_REVERB_DIFFUSION = 0x0002） */
public const AL_REVERB_DIFFUSION: UInt32 = 0x0002
/** @brief 混响增益（AL_REVERB_GAIN = 0x0003） */
public const AL_REVERB_GAIN: UInt32 = 0x0003
/** @brief 混响高频增益（AL_REVERB_GAINHF = 0x0004） */
public const AL_REVERB_GAINHF: UInt32 = 0x0004
/** @brief 混响衰减时间（AL_REVERB_DECAY_TIME = 0x0005） */
public const AL_REVERB_DECAY_TIME: UInt32 = 0x0005
/** @brief 混响高频衰减比（AL_REVERB_DECAY_HFRATIO = 0x0006） */
public const AL_REVERB_DECAY_HFRATIO: UInt32 = 0x0006
/** @brief 混响早期反射增益（AL_REVERB_REFLECTIONS_GAIN = 0x0007） */
public const AL_REVERB_REFLECTIONS_GAIN: UInt32 = 0x0007
/** @brief 混响早期反射延迟（AL_REVERB_REFLECTIONS_DELAY = 0x0008） */
public const AL_REVERB_REFLECTIONS_DELAY: UInt32 = 0x0008
/** @brief 混响晚期混响增益（AL_REVERB_LATE_REVERB_GAIN = 0x0009） */
public const AL_REVERB_LATE_REVERB_GAIN: UInt32 = 0x0009
/** @brief 混响晚期混响延迟（AL_REVERB_LATE_REVERB_DELAY = 0x000A） */
public const AL_REVERB_LATE_REVERB_DELAY: UInt32 = 0x000A
/** @brief 混响空气吸收高频增益（AL_REVERB_AIR_ABSORPTION_GAINHF = 0x000B） */
public const AL_REVERB_AIR_ABSORPTION_GAINHF: UInt32 = 0x000B
/** @brief 混响房间滚降因子（AL_REVERB_ROOM_ROLLOFF_FACTOR = 0x000C） */
public const AL_REVERB_ROOM_ROLLOFF_FACTOR: UInt32 = 0x000C
/** @brief 混响衰减高频限制（AL_REVERB_DECAY_HFLIMIT = 0x000D） */
public const AL_REVERB_DECAY_HFLIMIT: UInt32 = 0x000D

// =============================================================================
// EAX Reverb 效果参数（EAX 混响）
// =============================================================================

/** @brief EAX 混响密度（AL_EAXREVERB_DENSITY = 0x0001） */
public const AL_EAXREVERB_DENSITY: UInt32 = 0x0001
/** @brief EAX 混响扩散度（AL_EAXREVERB_DIFFUSION = 0x0002） */
public const AL_EAXREVERB_DIFFUSION: UInt32 = 0x0002
/** @brief EAX 混响增益（AL_EAXREVERB_GAIN = 0x0003） */
public const AL_EAXREVERB_GAIN: UInt32 = 0x0003
/** @brief EAX 混响高频增益（AL_EAXREVERB_GAINHF = 0x0004） */
public const AL_EAXREVERB_GAINHF: UInt32 = 0x0004
/** @brief EAX 混响低频增益（AL_EAXREVERB_GAINLF = 0x0005） */
public const AL_EAXREVERB_GAINLF: UInt32 = 0x0005
/** @brief EAX 混响衰减时间（AL_EAXREVERB_DECAY_TIME = 0x0006） */
public const AL_EAXREVERB_DECAY_TIME: UInt32 = 0x0006
/** @brief EAX 混响高频衰减比（AL_EAXREVERB_DECAY_HFRATIO = 0x0007） */
public const AL_EAXREVERB_DECAY_HFRATIO: UInt32 = 0x0007
/** @brief EAX 混响低频衰减比（AL_EAXREVERB_DECAY_LFRATIO = 0x0008） */
public const AL_EAXREVERB_DECAY_LFRATIO: UInt32 = 0x0008
/** @brief EAX 混响早期反射增益（AL_EAXREVERB_REFLECTIONS_GAIN = 0x0009） */
public const AL_EAXREVERB_REFLECTIONS_GAIN: UInt32 = 0x0009
/** @brief EAX 混响早期反射延迟（AL_EAXREVERB_REFLECTIONS_DELAY = 0x000A） */
public const AL_EAXREVERB_REFLECTIONS_DELAY: UInt32 = 0x000A
/** @brief EAX 混响早期反射全景（AL_EAXREVERB_REFLECTIONS_PAN = 0x000B） */
public const AL_EAXREVERB_REFLECTIONS_PAN: UInt32 = 0x000B
/** @brief EAX 混响晚期混响增益（AL_EAXREVERB_LATE_REVERB_GAIN = 0x000C） */
public const AL_EAXREVERB_LATE_REVERB_GAIN: UInt32 = 0x000C
/** @brief EAX 混响晚期混响延迟（AL_EAXREVERB_LATE_REVERB_DELAY = 0x000D） */
public const AL_EAXREVERB_LATE_REVERB_DELAY: UInt32 = 0x000D
/** @brief EAX 混响晚期混响全景（AL_EAXREVERB_LATE_REVERB_PAN = 0x000E） */
public const AL_EAXREVERB_LATE_REVERB_PAN: UInt32 = 0x000E
/** @brief EAX 混响回声时间（AL_EAXREVERB_ECHO_TIME = 0x000F） */
public const AL_EAXREVERB_ECHO_TIME: UInt32 = 0x000F
/** @brief EAX 混响回声深度（AL_EAXREVERB_ECHO_DEPTH = 0x0010） */
public const AL_EAXREVERB_ECHO_DEPTH: UInt32 = 0x0010
/** @brief EAX 混响调制时间（AL_EAXREVERB_MODULATION_TIME = 0x0011） */
public const AL_EAXREVERB_MODULATION_TIME: UInt32 = 0x0011
/** @brief EAX 混响调制深度（AL_EAXREVERB_MODULATION_DEPTH = 0x0012） */
public const AL_EAXREVERB_MODULATION_DEPTH: UInt32 = 0x0012
/** @brief EAX 混响空气吸收高频增益（AL_EAXREVERB_AIR_ABSORPTION_GAINHF = 0x0013） */
public const AL_EAXREVERB_AIR_ABSORPTION_GAINHF: UInt32 = 0x0013
/** @brief EAX 混响高频参考（AL_EAXREVERB_HFREFERENCE = 0x0014） */
public const AL_EAXREVERB_HFREFERENCE: UInt32 = 0x0014
/** @brief EAX 混响低频参考（AL_EAXREVERB_LFREFERENCE = 0x0015） */
public const AL_EAXREVERB_LFREFERENCE: UInt32 = 0x0015
/** @brief EAX 混响房间滚降因子（AL_EAXREVERB_ROOM_ROLLOFF_FACTOR = 0x0016） */
public const AL_EAXREVERB_ROOM_ROLLOFF_FACTOR: UInt32 = 0x0016
/** @brief EAX 混响衰减高频限制（AL_EAXREVERB_DECAY_HFLIMIT = 0x0017） */
public const AL_EAXREVERB_DECAY_HFLIMIT: UInt32 = 0x0017

// =============================================================================
// Chorus 效果参数（合唱）
// =============================================================================

/** @brief 合唱波形（AL_CHORUS_WAVEFORM = 0x0001） */
public const AL_CHORUS_WAVEFORM: UInt32 = 0x0001
/** @brief 合唱相位（AL_CHORUS_PHASE = 0x0002） */
public const AL_CHORUS_PHASE: UInt32 = 0x0002
/** @brief 合唱速率（AL_CHORUS_RATE = 0x0003） */
public const AL_CHORUS_RATE: UInt32 = 0x0003
/** @brief 合唱深度（AL_CHORUS_DEPTH = 0x0004） */
public const AL_CHORUS_DEPTH: UInt32 = 0x0004
/** @brief 合唱反馈（AL_CHORUS_FEEDBACK = 0x0005） */
public const AL_CHORUS_FEEDBACK: UInt32 = 0x0005
/** @brief 合唱延迟（AL_CHORUS_DELAY = 0x0006） */
public const AL_CHORUS_DELAY: UInt32 = 0x0006

/** @brief 合唱波形：正弦（AL_CHORUS_WAVEFORM_SINUSOID = 0） */
public const AL_CHORUS_WAVEFORM_SINUSOID: UInt32 = 0
/** @brief 合唱波形：三角（AL_CHORUS_WAVEFORM_TRIANGLE = 1） */
public const AL_CHORUS_WAVEFORM_TRIANGLE: UInt32 = 1

// =============================================================================
// Distortion 效果参数（失真）
// =============================================================================

/** @brief 失真边缘（AL_DISTORTION_EDGE = 0x0001） */
public const AL_DISTORTION_EDGE: UInt32 = 0x0001
/** @brief 失真增益（AL_DISTORTION_GAIN = 0x0002） */
public const AL_DISTORTION_GAIN: UInt32 = 0x0002
/** @brief 失真低通截止（AL_DISTORTION_LOWPASS_CUTOFF = 0x0003） */
public const AL_DISTORTION_LOWPASS_CUTOFF: UInt32 = 0x0003
/** @brief 失真均衡中心（AL_DISTORTION_EQCENTER = 0x0004） */
public const AL_DISTORTION_EQCENTER: UInt32 = 0x0004
/** @brief 失真均衡带宽（AL_DISTORTION_EQBANDWIDTH = 0x0005） */
public const AL_DISTORTION_EQBANDWIDTH: UInt32 = 0x0005

// =============================================================================
// Echo 效果参数（回声）
// =============================================================================

/** @brief 回声延迟（AL_ECHO_DELAY = 0x0001） */
public const AL_ECHO_DELAY: UInt32 = 0x0001
/** @brief 回声左右延迟（AL_ECHO_LRDELAY = 0x0002） */
public const AL_ECHO_LRDELAY: UInt32 = 0x0002
/** @brief 回声阻尼（AL_ECHO_DAMPING = 0x0003） */
public const AL_ECHO_DAMPING: UInt32 = 0x0003
/** @brief 回声反馈（AL_ECHO_FEEDBACK = 0x0004） */
public const AL_ECHO_FEEDBACK: UInt32 = 0x0004
/** @brief 回声扩散（AL_ECHO_SPREAD = 0x0005） */
public const AL_ECHO_SPREAD: UInt32 = 0x0005

// =============================================================================
// Flanger 效果参数（镶边）
// =============================================================================

/** @brief 镶边波形（AL_FLANGER_WAVEFORM = 0x0001） */
public const AL_FLANGER_WAVEFORM: UInt32 = 0x0001
/** @brief 镶边相位（AL_FLANGER_PHASE = 0x0002） */
public const AL_FLANGER_PHASE: UInt32 = 0x0002
/** @brief 镶边速率（AL_FLANGER_RATE = 0x0003） */
public const AL_FLANGER_RATE: UInt32 = 0x0003
/** @brief 镶边深度（AL_FLANGER_DEPTH = 0x0004） */
public const AL_FLANGER_DEPTH: UInt32 = 0x0004
/** @brief 镶边反馈（AL_FLANGER_FEEDBACK = 0x0005） */
public const AL_FLANGER_FEEDBACK: UInt32 = 0x0005
/** @brief 镶边延迟（AL_FLANGER_DELAY = 0x0006） */
public const AL_FLANGER_DELAY: UInt32 = 0x0006

/** @brief 镶边波形：正弦（AL_FLANGER_WAVEFORM_SINUSOID = 0） */
public const AL_FLANGER_WAVEFORM_SINUSOID: UInt32 = 0
/** @brief 镶边波形：三角（AL_FLANGER_WAVEFORM_TRIANGLE = 1） */
public const AL_FLANGER_WAVEFORM_TRIANGLE: UInt32 = 1

// =============================================================================
// Frequency Shifter 效果参数（移频器）
// =============================================================================

/** @brief 移频频率（AL_FREQUENCY_SHIFTER_FREQUENCY = 0x0001） */
public const AL_FREQUENCY_SHIFTER_FREQUENCY: UInt32 = 0x0001
/** @brief 左声道移频方向（AL_FREQUENCY_SHIFTER_LEFT_DIRECTION = 0x0002） */
public const AL_FREQUENCY_SHIFTER_LEFT_DIRECTION: UInt32 = 0x0002
/** @brief 右声道移频方向（AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION = 0x0003） */
public const AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION: UInt32 = 0x0003

/** @brief 移频方向：下移（AL_FREQUENCY_SHIFTER_DIRECTION_DOWN = 0） */
public const AL_FREQUENCY_SHIFTER_DIRECTION_DOWN: UInt32 = 0
/** @brief 移频方向：上移（AL_FREQUENCY_SHIFTER_DIRECTION_UP = 1） */
public const AL_FREQUENCY_SHIFTER_DIRECTION_UP: UInt32 = 1
/** @brief 移频方向：关闭（AL_FREQUENCY_SHIFTER_DIRECTION_OFF = 2） */
public const AL_FREQUENCY_SHIFTER_DIRECTION_OFF: UInt32 = 2

// =============================================================================
// Vocal Morpher 效果参数（语音变形器）
// =============================================================================

/** @brief 语音变形音素 A（AL_VOCAL_MORPHER_PHONEMEA = 0x0001） */
public const AL_VOCAL_MORPHER_PHONEMEA: UInt32 = 0x0001
/** @brief 语音变形音素 A 粗调（AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING = 0x0002） */
public const AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING: UInt32 = 0x0002
/** @brief 语音变形音素 B（AL_VOCAL_MORPHER_PHONEMEB = 0x0003） */
public const AL_VOCAL_MORPHER_PHONEMEB: UInt32 = 0x0003
/** @brief 语音变形音素 B 粗调（AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING = 0x0004） */
public const AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING: UInt32 = 0x0004
/** @brief 语音变形波形（AL_VOCAL_MORPHER_WAVEFORM = 0x0005） */
public const AL_VOCAL_MORPHER_WAVEFORM: UInt32 = 0x0005
/** @brief 语音变形速率（AL_VOCAL_MORPHER_RATE = 0x0006） */
public const AL_VOCAL_MORPHER_RATE: UInt32 = 0x0006

/** @brief 语音变形波形：正弦（AL_VOCAL_MORPHER_WAVEFORM_SINUSOID = 0） */
public const AL_VOCAL_MORPHER_WAVEFORM_SINUSOID: UInt32 = 0
/** @brief 语音变形波形：三角（AL_VOCAL_MORPHER_WAVEFORM_TRIANGLE = 1） */
public const AL_VOCAL_MORPHER_WAVEFORM_TRIANGLE: UInt32 = 1
/** @brief 语音变形波形：锯齿（AL_VOCAL_MORPHER_WAVEFORM_SAWTOOTH = 2） */
public const AL_VOCAL_MORPHER_WAVEFORM_SAWTOOTH: UInt32 = 2

/** @brief 音素：A（AL_VOCAL_MORPHER_PHONEME_A = 0） */
public const AL_VOCAL_MORPHER_PHONEME_A: UInt32 = 0
/** @brief 音素：E（AL_VOCAL_MORPHER_PHONEME_E = 1） */
public const AL_VOCAL_MORPHER_PHONEME_E: UInt32 = 1
/** @brief 音素：I（AL_VOCAL_MORPHER_PHONEME_I = 2） */
public const AL_VOCAL_MORPHER_PHONEME_I: UInt32 = 2
/** @brief 音素：O（AL_VOCAL_MORPHER_PHONEME_O = 3） */
public const AL_VOCAL_MORPHER_PHONEME_O: UInt32 = 3
/** @brief 音素：U（AL_VOCAL_MORPHER_PHONEME_U = 4） */
public const AL_VOCAL_MORPHER_PHONEME_U: UInt32 = 4
/** @brief 音素：AA（AL_VOCAL_MORPHER_PHONEME_AA = 5） */
public const AL_VOCAL_MORPHER_PHONEME_AA: UInt32 = 5
/** @brief 音素：AE（AL_VOCAL_MORPHER_PHONEME_AE = 6） */
public const AL_VOCAL_MORPHER_PHONEME_AE: UInt32 = 6
/** @brief 音素：AH（AL_VOCAL_MORPHER_PHONEME_AH = 7） */
public const AL_VOCAL_MORPHER_PHONEME_AH: UInt32 = 7
/** @brief 音素：AO（AL_VOCAL_MORPHER_PHONEME_AO = 8） */
public const AL_VOCAL_MORPHER_PHONEME_AO: UInt32 = 8
/** @brief 音素：EH（AL_VOCAL_MORPHER_PHONEME_EH = 9） */
public const AL_VOCAL_MORPHER_PHONEME_EH: UInt32 = 9
/** @brief 音素：ER（AL_VOCAL_MORPHER_PHONEME_ER = 10） */
public const AL_VOCAL_MORPHER_PHONEME_ER: UInt32 = 10
/** @brief 音素：IH（AL_VOCAL_MORPHER_PHONEME_IH = 11） */
public const AL_VOCAL_MORPHER_PHONEME_IH: UInt32 = 11
/** @brief 音素：IY（AL_VOCAL_MORPHER_PHONEME_IY = 12） */
public const AL_VOCAL_MORPHER_PHONEME_IY: UInt32 = 12
/** @brief 音素：UH（AL_VOCAL_MORPHER_PHONEME_UH = 13） */
public const AL_VOCAL_MORPHER_PHONEME_UH: UInt32 = 13
/** @brief 音素：UW（AL_VOCAL_MORPHER_PHONEME_UW = 14） */
public const AL_VOCAL_MORPHER_PHONEME_UW: UInt32 = 14
/** @brief 音素：B（AL_VOCAL_MORPHER_PHONEME_B = 15） */
public const AL_VOCAL_MORPHER_PHONEME_B: UInt32 = 15
/** @brief 音素：D（AL_VOCAL_MORPHER_PHONEME_D = 16） */
public const AL_VOCAL_MORPHER_PHONEME_D: UInt32 = 16
/** @brief 音素：F（AL_VOCAL_MORPHER_PHONEME_F = 17） */
public const AL_VOCAL_MORPHER_PHONEME_F: UInt32 = 17
/** @brief 音素：G（AL_VOCAL_MORPHER_PHONEME_G = 18） */
public const AL_VOCAL_MORPHER_PHONEME_G: UInt32 = 18
/** @brief 音素：J（AL_VOCAL_MORPHER_PHONEME_J = 19） */
public const AL_VOCAL_MORPHER_PHONEME_J: UInt32 = 19
/** @brief 音素：K（AL_VOCAL_MORPHER_PHONEME_K = 20） */
public const AL_VOCAL_MORPHER_PHONEME_K: UInt32 = 20
/** @brief 音素：L（AL_VOCAL_MORPHER_PHONEME_L = 21） */
public const AL_VOCAL_MORPHER_PHONEME_L: UInt32 = 21
/** @brief 音素：M（AL_VOCAL_MORPHER_PHONEME_M = 22） */
public const AL_VOCAL_MORPHER_PHONEME_M: UInt32 = 22
/** @brief 音素：N（AL_VOCAL_MORPHER_PHONEME_N = 23） */
public const AL_VOCAL_MORPHER_PHONEME_N: UInt32 = 23
/** @brief 音素：P（AL_VOCAL_MORPHER_PHONEME_P = 24） */
public const AL_VOCAL_MORPHER_PHONEME_P: UInt32 = 24
/** @brief 音素：R（AL_VOCAL_MORPHER_PHONEME_R = 25） */
public const AL_VOCAL_MORPHER_PHONEME_R: UInt32 = 25
/** @brief 音素：S（AL_VOCAL_MORPHER_PHONEME_S = 26） */
public const AL_VOCAL_MORPHER_PHONEME_S: UInt32 = 26
/** @brief 音素：T（AL_VOCAL_MORPHER_PHONEME_T = 27） */
public const AL_VOCAL_MORPHER_PHONEME_T: UInt32 = 27
/** @brief 音素：V（AL_VOCAL_MORPHER_PHONEME_V = 28） */
public const AL_VOCAL_MORPHER_PHONEME_V: UInt32 = 28
/** @brief 音素：Z（AL_VOCAL_MORPHER_PHONEME_Z = 29） */
public const AL_VOCAL_MORPHER_PHONEME_Z: UInt32 = 29

// =============================================================================
// Pitch Shifter 效果参数（移调器）
// =============================================================================

/** @brief 移调粗调（AL_PITCH_SHIFTER_COARSE_TUNE = 0x0001） */
public const AL_PITCH_SHIFTER_COARSE_TUNE: UInt32 = 0x0001
/** @brief 移调细调（AL_PITCH_SHIFTER_FINE_TUNE = 0x0002） */
public const AL_PITCH_SHIFTER_FINE_TUNE: UInt32 = 0x0002

// =============================================================================
// Ring Modulator 效果参数（环形调制器）
// =============================================================================

/** @brief 环形调制频率（AL_RING_MODULATOR_FREQUENCY = 0x0001） */
public const AL_RING_MODULATOR_FREQUENCY: UInt32 = 0x0001
/** @brief 环形调制高通截止（AL_RING_MODULATOR_HIGHPASS_CUTOFF = 0x0002） */
public const AL_RING_MODULATOR_HIGHPASS_CUTOFF: UInt32 = 0x0002
/** @brief 环形调制波形（AL_RING_MODULATOR_WAVEFORM = 0x0003） */
public const AL_RING_MODULATOR_WAVEFORM: UInt32 = 0x0003

/** @brief 环形调制波形：正弦（AL_RING_MODULATOR_SINUSOID = 0） */
public const AL_RING_MODULATOR_SINUSOID: UInt32 = 0
/** @brief 环形调制波形：锯齿（AL_RING_MODULATOR_SAWTOOTH = 1） */
public const AL_RING_MODULATOR_SAWTOOTH: UInt32 = 1
/** @brief 环形调制波形：方波（AL_RING_MODULATOR_SQUARE = 2） */
public const AL_RING_MODULATOR_SQUARE: UInt32 = 2

// =============================================================================
// Autowah 效果参数（自动哇音）
// =============================================================================

/** @brief 自动哇音起音时间（AL_AUTOWAH_ATTACK_TIME = 0x0001） */
public const AL_AUTOWAH_ATTACK_TIME: UInt32 = 0x0001
/** @brief 自动哇音释放时间（AL_AUTOWAH_RELEASE_TIME = 0x0002） */
public const AL_AUTOWAH_RELEASE_TIME: UInt32 = 0x0002
/** @brief 自动哇音谐振（AL_AUTOWAH_RESONANCE = 0x0003） */
public const AL_AUTOWAH_RESONANCE: UInt32 = 0x0003
/** @brief 自动哇音峰值增益（AL_AUTOWAH_PEAK_GAIN = 0x0004） */
public const AL_AUTOWAH_PEAK_GAIN: UInt32 = 0x0004

// =============================================================================
// Compressor 效果参数（压缩器）
// =============================================================================

/** @brief 压缩器开关（AL_COMPRESSOR_ONOFF = 0x0001） */
public const AL_COMPRESSOR_ONOFF: UInt32 = 0x0001

// =============================================================================
// Equalizer 效果参数（均衡器）
// =============================================================================

/** @brief 均衡器低频增益（AL_EQUALIZER_LOW_GAIN = 0x0001） */
public const AL_EQUALIZER_LOW_GAIN: UInt32 = 0x0001
/** @brief 均衡器低频截止（AL_EQUALIZER_LOW_CUTOFF = 0x0002） */
public const AL_EQUALIZER_LOW_CUTOFF: UInt32 = 0x0002
/** @brief 均衡器中频 1 增益（AL_EQUALIZER_MID1_GAIN = 0x0003） */
public const AL_EQUALIZER_MID1_GAIN: UInt32 = 0x0003
/** @brief 均衡器中频 1 中心（AL_EQUALIZER_MID1_CENTER = 0x0004） */
public const AL_EQUALIZER_MID1_CENTER: UInt32 = 0x0004
/** @brief 均衡器中频 1 宽度（AL_EQUALIZER_MID1_WIDTH = 0x0005） */
public const AL_EQUALIZER_MID1_WIDTH: UInt32 = 0x0005
/** @brief 均衡器中频 2 增益（AL_EQUALIZER_MID2_GAIN = 0x0006） */
public const AL_EQUALIZER_MID2_GAIN: UInt32 = 0x0006
/** @brief 均衡器中频 2 中心（AL_EQUALIZER_MID2_CENTER = 0x0007） */
public const AL_EQUALIZER_MID2_CENTER: UInt32 = 0x0007
/** @brief 均衡器中频 2 宽度（AL_EQUALIZER_MID2_WIDTH = 0x0008） */
public const AL_EQUALIZER_MID2_WIDTH: UInt32 = 0x0008
/** @brief 均衡器高频增益（AL_EQUALIZER_HIGH_GAIN = 0x0009） */
public const AL_EQUALIZER_HIGH_GAIN: UInt32 = 0x0009
/** @brief 均衡器高频截止（AL_EQUALIZER_HIGH_CUTOFF = 0x000A） */
public const AL_EQUALIZER_HIGH_CUTOFF: UInt32 = 0x000A

// =============================================================================
// 效果类型取值（AL_EFFECT_TYPE 参数）
// =============================================================================

/** @brief 效果参数起始（AL_EFFECT_FIRST_PARAMETER = 0x0000） */
public const AL_EFFECT_FIRST_PARAMETER: UInt32 = 0x0000
/** @brief 效果参数结束（AL_EFFECT_LAST_PARAMETER = 0x8000） */
public const AL_EFFECT_LAST_PARAMETER: UInt32 = 0x8000
/** @brief 效果类型（AL_EFFECT_TYPE = 0x8001） */
public const AL_EFFECT_TYPE: UInt32 = 0x8001
/** @brief 空效果（AL_EFFECT_NULL = 0x0000） */
public const AL_EFFECT_NULL: UInt32 = 0x0000
/** @brief 混响效果（AL_EFFECT_REVERB = 0x0001） */
public const AL_EFFECT_REVERB: UInt32 = 0x0001
/** @brief 合唱效果（AL_EFFECT_CHORUS = 0x0002） */
public const AL_EFFECT_CHORUS: UInt32 = 0x0002
/** @brief 失真效果（AL_EFFECT_DISTORTION = 0x0003） */
public const AL_EFFECT_DISTORTION: UInt32 = 0x0003
/** @brief 回声效果（AL_EFFECT_ECHO = 0x0004） */
public const AL_EFFECT_ECHO: UInt32 = 0x0004
/** @brief 镶边效果（AL_EFFECT_FLANGER = 0x0005） */
public const AL_EFFECT_FLANGER: UInt32 = 0x0005
/** @brief 移频器效果（AL_EFFECT_FREQUENCY_SHIFTER = 0x0006） */
public const AL_EFFECT_FREQUENCY_SHIFTER: UInt32 = 0x0006
/** @brief 语音变形效果（AL_EFFECT_VOCAL_MORPHER = 0x0007） */
public const AL_EFFECT_VOCAL_MORPHER: UInt32 = 0x0007
/** @brief 移调器效果（AL_EFFECT_PITCH_SHIFTER = 0x0008） */
public const AL_EFFECT_PITCH_SHIFTER: UInt32 = 0x0008
/** @brief 环形调制效果（AL_EFFECT_RING_MODULATOR = 0x0009） */
public const AL_EFFECT_RING_MODULATOR: UInt32 = 0x0009
/** @brief 自动哇音效果（AL_EFFECT_AUTOWAH = 0x000A） */
public const AL_EFFECT_AUTOWAH: UInt32 = 0x000A
/** @brief 压缩器效果（AL_EFFECT_COMPRESSOR = 0x000B） */
public const AL_EFFECT_COMPRESSOR: UInt32 = 0x000B
/** @brief 均衡器效果（AL_EFFECT_EQUALIZER = 0x000C） */
public const AL_EFFECT_EQUALIZER: UInt32 = 0x000C
/** @brief EAX 混响效果（AL_EFFECT_EAXREVERB = 0x8000） */
public const AL_EFFECT_EAXREVERB: UInt32 = 0x8000

// =============================================================================
// EffectSlot 参数（辅助效果槽）
// =============================================================================

/** @brief 效果槽：效果（AL_EFFECTSLOT_EFFECT = 0x0001） */
public const AL_EFFECTSLOT_EFFECT: UInt32 = 0x0001
/** @brief 效果槽：增益（AL_EFFECTSLOT_GAIN = 0x0002） */
public const AL_EFFECTSLOT_GAIN: UInt32 = 0x0002
/** @brief 效果槽：辅助发送自动（AL_EFFECTSLOT_AUXILIARY_SEND_AUTO = 0x0003） */
public const AL_EFFECTSLOT_AUXILIARY_SEND_AUTO: UInt32 = 0x0003
/** @brief 效果槽：空（AL_EFFECTSLOT_NULL = 0x0000） */
public const AL_EFFECTSLOT_NULL: UInt32 = 0x0000

// =============================================================================
// Filter 参数（滤波器）
// =============================================================================

/** @brief 滤波器参数起始（AL_FILTER_FIRST_PARAMETER = 0x0000） */
public const AL_FILTER_FIRST_PARAMETER: UInt32 = 0x0000
/** @brief 滤波器参数结束（AL_FILTER_LAST_PARAMETER = 0x8000） */
public const AL_FILTER_LAST_PARAMETER: UInt32 = 0x8000
/** @brief 滤波器类型（AL_FILTER_TYPE = 0x8001） */
public const AL_FILTER_TYPE: UInt32 = 0x8001
/** @brief 空滤波器（AL_FILTER_NULL = 0x0000） */
public const AL_FILTER_NULL: UInt32 = 0x0000
/** @brief 低通滤波器（AL_FILTER_LOWPASS = 0x0001） */
public const AL_FILTER_LOWPASS: UInt32 = 0x0001
/** @brief 高通滤波器（AL_FILTER_HIGHPASS = 0x0002） */
public const AL_FILTER_HIGHPASS: UInt32 = 0x0002
/** @brief 带通滤波器（AL_FILTER_BANDPASS = 0x0003） */
public const AL_FILTER_BANDPASS: UInt32 = 0x0003

/** @brief 低通增益（AL_LOWPASS_GAIN = 0x0001） */
public const AL_LOWPASS_GAIN: UInt32 = 0x0001
/** @brief 低通高频增益（AL_LOWPASS_GAINHF = 0x0002） */
public const AL_LOWPASS_GAINHF: UInt32 = 0x0002
/** @brief 高通增益（AL_HIGHPASS_GAIN = 0x0001） */
public const AL_HIGHPASS_GAIN: UInt32 = 0x0001
/** @brief 高通低频增益（AL_HIGHPASS_GAINLF = 0x0002） */
public const AL_HIGHPASS_GAINLF: UInt32 = 0x0002
/** @brief 带通增益（AL_BANDPASS_GAIN = 0x0001） */
public const AL_BANDPASS_GAIN: UInt32 = 0x0001
/** @brief 带通低频增益（AL_BANDPASS_GAINLF = 0x0002） */
public const AL_BANDPASS_GAINLF: UInt32 = 0x0002
/** @brief 带通高频增益（AL_BANDPASS_GAINHF = 0x0003） */
public const AL_BANDPASS_GAINHF: UInt32 = 0x0003
