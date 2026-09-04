# 类
## class AudioEffect
```cj
public class AudioEffect <: IAudioEffect
```
EFX 效果对象，封装 OpenAL Effect 句柄

### func createAutowahEffect\(AudioContext,Float32,Float32,Float32,Float32\)
```cj
public static func createAutowahEffect(context!: AudioContext = AudioContext.context, attackTime!: Float32 = 0.06f32, releaseTime!: Float32 = 0.06f32, resonance!: Float32 = 1000.0f32, peakGain!: Float32 = 11.22f32): AudioEffect
```
创建自动哇音效果（Autowah，包络跟随滤波，吉他哇音踏板）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）attackTime 起音时间（0.0001~1.0 s），默认 0.06releaseTime 释音时间（0.0001~1.0 s），默认 0.06resonance 共鸣度（2.0~1000.0），默认 1000peakGain 峰值增益（0.00003~31621），默认 11.22|
|attackTime|Float32||
|releaseTime|Float32||
|resonance|Float32||
|peakGain|Float32||

返回: 

- 配置好的 AudioEffect

### func createChorusEffect\(AudioContext\)
```cj
public static func createChorusEffect(context!: AudioContext = AudioContext.context): AudioEffect
```
创建合唱效果（Chorus）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）|

返回: 

- 配置好的 AudioEffect

### func createCompressorEffect\(AudioContext,Int32\)
```cj
public static func createCompressorEffect(context!: AudioContext = AudioContext.context, onoff!: Int32 = 1): AudioEffect
```
创建压缩器效果（Compressor，动态范围压缩）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）onoff 开关（0=Off / 1=On），默认 On|
|onoff|Int32||

返回: 

- 配置好的 AudioEffect

### func createDistortionEffect\(AudioContext,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func createDistortionEffect(context!: AudioContext = AudioContext.context, edge!: Float32 = 0.2f32, gain!: Float32 = 0.05f32, lowpassCutoff!: Float32 = 8000.0f32, eqCenter!: Float32 = 3600.0f32, eqBandwidth!: Float32 = 3600.0f32): AudioEffect
```
创建失真效果（Distortion，模拟吉他/功放过载）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）edge 边缘度（0.0~1.0），默认 0.2gain 失真增益（0.01~1.0），默认 0.05lowpassCutoff 低通截止（80~24000 Hz），默认 8000eqCenter 均衡中心（80~24000 Hz），默认 3600eqBandwidth 均衡带宽（80~24000 Hz），默认 3600|
|edge|Float32||
|gain|Float32||
|lowpassCutoff|Float32||
|eqCenter|Float32||
|eqBandwidth|Float32||

返回: 

- 配置好的 AudioEffect

### func createEaxReverbEffect\(AudioContext,Float32,Float32,Float32,Float32\)
```cj
public static func createEaxReverbEffect(context!: AudioContext = AudioContext.context, density!: Float32 = 1.0f32, diffusion!: Float32 = 1.0f32, gain!: Float32 = 0.32f32, decayTime!: Float32 = 1.49f32): AudioEffect
```
创建 EAX 混响效果（EaxReverb，比标准 Reverb 参数更丰富）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）density 密度，默认 1.0diffusion 扩散度，默认 1.0gain 增益，默认 0.32decayTime 衰减时间，默认 1.49|
|density|Float32||
|diffusion|Float32||
|gain|Float32||
|decayTime|Float32||

返回: 

- 配置好的 AudioEffect

### func createEchoEffect\(AudioContext\)
```cj
public static func createEchoEffect(context!: AudioContext = AudioContext.context): AudioEffect
```
创建回声效果（Echo）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）|

返回: 

- 配置好的 AudioEffect

### func createEqualizerEffect\(AudioContext\)
```cj
public static func createEqualizerEffect(context!: AudioContext = AudioContext.context): AudioEffect
```
创建均衡器效果（Equalizer）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）|

返回: 

- 配置好的 AudioEffect

### func createFlangerEffect\(AudioContext,Float32,Float32,Float32,Float32\)
```cj
public static func createFlangerEffect(context!: AudioContext = AudioContext.context, rate!: Float32 = 0.27f32, depth!: Float32 = 1.0f32, delay!: Float32 = 0.002f32, feedback!: Float32 = - 0.5f32): AudioEffect
```
创建镶边效果（Flanger，梳状滤波扫频）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）rate 扫频速率（0.0~10.0 Hz），默认 0.27depth 深度（0.0~1.0），默认 1.0delay 延迟（0.0~0.004 s），默认 0.002feedback 反馈（-1.0~1.0），默认 -0.5|
|rate|Float32||
|depth|Float32||
|delay|Float32||
|feedback|Float32||

返回: 

- 配置好的 AudioEffect

### func createFrequencyShifterEffect\(AudioContext,Float32,Int32,Int32\)
```cj
public static func createFrequencyShifterEffect(context!: AudioContext = AudioContext.context, frequency!: Float32 = 0.0f32, leftDirection!: Int32 = 1, rightDirection!: Int32 = 1): AudioEffect
```
创建移频器效果（FrequencyShifter，频段整体搬移）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）frequency 移频量（-24000~24000 Hz），默认 0.0leftDirection 左声道方向（0=Down / 1=Up / 2=Off），默认 UprightDirection 右声道方向，默认 Up|
|frequency|Float32||
|leftDirection|Int32||
|rightDirection|Int32||

返回: 

- 配置好的 AudioEffect

### func createPitchShifterEffect\(AudioContext,Int32,Int32\)
```cj
public static func createPitchShifterEffect(context!: AudioContext = AudioContext.context, coarseTune!: Int32 = 0, fineTune!: Int32 = 0): AudioEffect
```
创建移调器效果（PitchShifter，音高搬移，不改播放速率）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）coarseTune 粗调（-12~12 半音），默认 0fineTune 微调（-50~50 音分），默认 0|
|coarseTune|Int32||
|fineTune|Int32||

返回: 

- 配置好的 AudioEffect

### func createReverbEffect\(AudioContext,Float32,Float32,Float32,Float32\)
```cj
public static func createReverbEffect(context!: AudioContext = AudioContext.context, density!: Float32 = 1.0f32, diffusion!: Float32 = 1.0f32, gain!: Float32 = 0.32f32, decayTime!: Float32 = 1.49f32): AudioEffect
```
创建标准混响效果（Reverb）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）density 密度（0.0~1.0），默认 1.0diffusion 扩散度（0.0~1.0），默认 1.0gain 增益（0.0~1.0），默认 0.32decayTime 衰减时间（秒，0.1~20.0），默认 1.49|
|density|Float32||
|diffusion|Float32||
|gain|Float32||
|decayTime|Float32||

返回: 

- 配置好的 AudioEffect

### func createRingModulatorEffect\(AudioContext,Float32,Float32,Int32\)
```cj
public static func createRingModulatorEffect(context!: AudioContext = AudioContext.context, frequency!: Float32 = 440.0f32, highpassCutoff!: Float32 = 800.0f32, waveform!: Int32 = 0): AudioEffect
```
创建环形调制器效果（RingModulator，载波振幅调制）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）frequency 调制频率（0.0~8000 Hz），默认 440highpassCutoff 高通截止（0~24000 Hz），默认 800waveform 波形（0=Sinusoid / 1=Sawtooth / 2=Square），默认 Sinusoid|
|frequency|Float32||
|highpassCutoff|Float32||
|waveform|Int32||

返回: 

- 配置好的 AudioEffect

### func createVocalMorpherEffect\(AudioContext,Int32,Int32,Float32\)
```cj
public static func createVocalMorpherEffect(context!: AudioContext = AudioContext.context, phonemeA!: Int32 = Int32(AL_VOCAL_MORPHER_PHONEME_A), phonemeB!: Int32 = Int32(AL_VOCAL_MORPHER_PHONEME_I), rate!: Float32 = 1.41f32): AudioEffect
```
创建声码器/语音变形效果（VocalMorpher）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）phonemeA 音素 A（音素枚举值，默认 AL_VOCAL_MORPHER_PHONEME_A）phonemeB 音素 B（默认 AL_VOCAL_MORPHER_PHONEME_I）rate 变形速率（0.0~10.0 Hz），默认 1.41|
|phonemeA|Int32||
|phonemeB|Int32||
|rate|Float32||

返回: 

- 配置好的 AudioEffect

### func create\(\)
```cj
public func create(): AudioEffect
```
创建并生成 OpenAL 效果对象

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>在音频线程执行 alGenEffects；若已创建则跳过。</p>

返回: 

- this（便于链式调用）

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 OpenAL 效果对象

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>在音频线程执行 alDeleteEffects；重复调用无副作用。</p>

### func getEffectId\(\)
```cj
public func getEffectId(): UInt32
```
接口实现：获取 OpenAL 效果句柄

返回: 

- OpenAL 效果句柄（ALuint）

### func init\(AudioContext\)
```cj
public init(context!: AudioContext = AudioContext.context)
```
创建音频效果对象

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）|

### func setParamf\(UInt32,Float32\)
```cj
public func setParamf(param: UInt32, value: Float32): AudioEffect
```
设置浮点参数

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX 的 alEffectf(effect, param, value)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|param|UInt32|参数常量（如 AL_REVERB_DENSITY）value 参数值|
|value|Float32||

返回: 

- this（便于链式调用）

### func setParamfv\(UInt32,CPointer<Float32>\)
```cj
public func setParamfv(param: UInt32, values: CPointer < Float32 >): AudioEffect
```
设置浮点向量参数

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>用于 EAX Reverb 等需要多值参数的效果；对应 EFX 的 alEffectfv(effect, param, values)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|param|UInt32|参数常量values Float32 数组指针（调用方负责分配和释放）|
|values|CPointer<Float32>||

返回: 

- this（便于链式调用）

### func setParami\(UInt32,Int32\)
```cj
public func setParami(param: UInt32, value: Int32): AudioEffect
```
设置整数参数

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX 的 alEffecti(effect, param, value)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|param|UInt32|参数常量value 参数值|
|value|Int32||

返回: 

- this（便于链式调用）

### func setType\(EffectType\)
```cj
public func setType(effectType: EffectType): AudioEffect
```
设置效果类型

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX 的 alEffecti(effect, AL_EFFECT_TYPE, type)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|effectType|EffectType|效果类型（EffectType.Reverb / Chorus / Echo / Equalizer 等）|

返回: 

- this（便于链式调用）

### var context
```cj
public var context: AudioContext
```
关联的音频上下文

### var effectId
```cj
public var effectId: UInt32
```
OpenAL 效果句柄

