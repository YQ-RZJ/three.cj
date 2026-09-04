# Class
## class AudioEffect
```cj
public class AudioEffect <: IAudioEffect
```
EFX effect object wrapping an OpenAL Effect handle

### func createAutowahEffect\(AudioContext,Float32,Float32,Float32,Float32\)
```cj
public static func createAutowahEffect(context!: AudioContext = AudioContext.context, attackTime!: Float32 = 0.06f32, releaseTime!: Float32 = 0.06f32, resonance!: Float32 = 1000.0f32, peakGain!: Float32 = 11.22f32): AudioEffect
```
Creates an autowah effect (Autowah, envelope-following filter, guitar wah pedal)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)attackTime Attack time (0.0001~1.0 s), default 0.06releaseTime Release time (0.0001~1.0 s), default 0.06resonance Resonance (2.0~1000.0), default 1000peakGain Peak gain (0.00003~31621), default 11.22|
|attackTime|Float32||
|releaseTime|Float32||
|resonance|Float32||
|peakGain|Float32||

Return: 

- The configured AudioEffect

### func createChorusEffect\(AudioContext\)
```cj
public static func createChorusEffect(context!: AudioContext = AudioContext.context): AudioEffect
```
Creates a chorus effect (Chorus)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)|

Return: 

- The configured AudioEffect

### func createCompressorEffect\(AudioContext,Int32\)
```cj
public static func createCompressorEffect(context!: AudioContext = AudioContext.context, onoff!: Int32 = 1): AudioEffect
```
Creates a compressor effect (Compressor, dynamic range compression)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)onoff On/off switch (0=Off / 1=On), default On|
|onoff|Int32||

Return: 

- The configured AudioEffect

### func createDistortionEffect\(AudioContext,Float32,Float32,Float32,Float32,Float32\)
```cj
public static func createDistortionEffect(context!: AudioContext = AudioContext.context, edge!: Float32 = 0.2f32, gain!: Float32 = 0.05f32, lowpassCutoff!: Float32 = 8000.0f32, eqCenter!: Float32 = 3600.0f32, eqBandwidth!: Float32 = 3600.0f32): AudioEffect
```
Creates a distortion effect (Distortion, simulating guitar/amp overload)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)edge Edge (0.0~1.0), default 0.2gain Distortion gain (0.01~1.0), default 0.05lowpassCutoff Low-pass cutoff (80~24000 Hz), default 8000eqCenter EQ center (80~24000 Hz), default 3600eqBandwidth EQ bandwidth (80~24000 Hz), default 3600|
|edge|Float32||
|gain|Float32||
|lowpassCutoff|Float32||
|eqCenter|Float32||
|eqBandwidth|Float32||

Return: 

- The configured AudioEffect

### func createEaxReverbEffect\(AudioContext,Float32,Float32,Float32,Float32\)
```cj
public static func createEaxReverbEffect(context!: AudioContext = AudioContext.context, density!: Float32 = 1.0f32, diffusion!: Float32 = 1.0f32, gain!: Float32 = 0.32f32, decayTime!: Float32 = 1.49f32): AudioEffect
```
Creates an EAX reverb effect (EaxReverb, with more parameters than standard Reverb)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)density Density, default 1.0diffusion Diffusion, default 1.0gain Gain, default 0.32decayTime Decay time, default 1.49|
|density|Float32||
|diffusion|Float32||
|gain|Float32||
|decayTime|Float32||

Return: 

- The configured AudioEffect

### func createEchoEffect\(AudioContext\)
```cj
public static func createEchoEffect(context!: AudioContext = AudioContext.context): AudioEffect
```
Creates an echo effect (Echo)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)|

Return: 

- The configured AudioEffect

### func createEqualizerEffect\(AudioContext\)
```cj
public static func createEqualizerEffect(context!: AudioContext = AudioContext.context): AudioEffect
```
Creates an equalizer effect (Equalizer)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)|

Return: 

- The configured AudioEffect

### func createFlangerEffect\(AudioContext,Float32,Float32,Float32,Float32\)
```cj
public static func createFlangerEffect(context!: AudioContext = AudioContext.context, rate!: Float32 = 0.27f32, depth!: Float32 = 1.0f32, delay!: Float32 = 0.002f32, feedback!: Float32 = - 0.5f32): AudioEffect
```
Creates a flanger effect (Flanger, swept comb filter)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)rate Sweep rate (0.0~10.0 Hz), default 0.27depth Depth (0.0~1.0), default 1.0delay Delay (0.0~0.004 s), default 0.002feedback Feedback (-1.0~1.0), default -0.5|
|rate|Float32||
|depth|Float32||
|delay|Float32||
|feedback|Float32||

Return: 

- The configured AudioEffect

### func createFrequencyShifterEffect\(AudioContext,Float32,Int32,Int32\)
```cj
public static func createFrequencyShifterEffect(context!: AudioContext = AudioContext.context, frequency!: Float32 = 0.0f32, leftDirection!: Int32 = 1, rightDirection!: Int32 = 1): AudioEffect
```
Creates a frequency shifter effect (FrequencyShifter, shifts frequency bands)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)frequency Shift amount (-24000~24000 Hz), default 0.0leftDirection Left channel direction (0=Down / 1=Up / 2=Off), default UprightDirection Right channel direction, default Up|
|frequency|Float32||
|leftDirection|Int32||
|rightDirection|Int32||

Return: 

- The configured AudioEffect

### func createPitchShifterEffect\(AudioContext,Int32,Int32\)
```cj
public static func createPitchShifterEffect(context!: AudioContext = AudioContext.context, coarseTune!: Int32 = 0, fineTune!: Int32 = 0): AudioEffect
```
Creates a pitch shifter effect (PitchShifter, shifts pitch without changing playback rate)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)coarseTune Coarse tune (-12~12 semitones), default 0fineTune Fine tune (-50~50 cents), default 0|
|coarseTune|Int32||
|fineTune|Int32||

Return: 

- The configured AudioEffect

### func createReverbEffect\(AudioContext,Float32,Float32,Float32,Float32\)
```cj
public static func createReverbEffect(context!: AudioContext = AudioContext.context, density!: Float32 = 1.0f32, diffusion!: Float32 = 1.0f32, gain!: Float32 = 0.32f32, decayTime!: Float32 = 1.49f32): AudioEffect
```
Creates a standard reverb effect (Reverb)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)density Density (0.0~1.0), default 1.0diffusion Diffusion (0.0~1.0), default 1.0gain Gain (0.0~1.0), default 0.32decayTime Decay time in seconds (0.1~20.0), default 1.49|
|density|Float32||
|diffusion|Float32||
|gain|Float32||
|decayTime|Float32||

Return: 

- The configured AudioEffect

### func createRingModulatorEffect\(AudioContext,Float32,Float32,Int32\)
```cj
public static func createRingModulatorEffect(context!: AudioContext = AudioContext.context, frequency!: Float32 = 440.0f32, highpassCutoff!: Float32 = 800.0f32, waveform!: Int32 = 0): AudioEffect
```
Creates a ring modulator effect (RingModulator, carrier amplitude modulation)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)frequency Modulation frequency (0.0~8000 Hz), default 440highpassCutoff High-pass cutoff (0~24000 Hz), default 800waveform Waveform (0=Sinusoid / 1=Sawtooth / 2=Square), default Sinusoid|
|frequency|Float32||
|highpassCutoff|Float32||
|waveform|Int32||

Return: 

- The configured AudioEffect

### func createVocalMorpherEffect\(AudioContext,Int32,Int32,Float32\)
```cj
public static func createVocalMorpherEffect(context!: AudioContext = AudioContext.context, phonemeA!: Int32 = Int32(AL_VOCAL_MORPHER_PHONEME_A), phonemeB!: Int32 = Int32(AL_VOCAL_MORPHER_PHONEME_I), rate!: Float32 = 1.41f32): AudioEffect
```
Creates a vocal morpher effect (VocalMorpher, vocoder/voice morphing)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|Audio context (defaults to the AudioContext.context singleton)phonemeA Phoneme A (phoneme enum value, default AL_VOCAL_MORPHER_PHONEME_A)phonemeB Phoneme B (default AL_VOCAL_MORPHER_PHONEME_I)rate Morphing rate (0.0~10.0 Hz), default 1.41|
|phonemeA|Int32||
|phonemeB|Int32||
|rate|Float32||

Return: 

- The configured AudioEffect

### func create\(\)
```cj
public func create(): AudioEffect
```
Creates and generates the OpenAL effect object

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Runs alGenEffects on the audio thread; skips if already created.</p>

Return: 

- this (for chaining)

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the OpenAL effect object

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Runs alDeleteEffects on the audio thread; repeated calls have no effect.</p>

### func getEffectId\(\)
```cj
public func getEffectId(): UInt32
```
Interface implementation: returns the OpenAL effect handle

Return: 

- The OpenAL effect handle (ALuint)

### func init\(AudioContext\)
```cj
public init(context!: AudioContext = AudioContext.context)
```
Creates an audio effect object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|The audio context (defaults to the AudioContext.context singleton)|

### func setParamf\(UInt32,Float32\)
```cj
public func setParamf(param: UInt32, value: Float32): AudioEffect
```
Sets a float parameter

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX alEffectf(effect, param, value).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|param|UInt32|Parameter constant (e.g. AL_REVERB_DENSITY)value Parameter value|
|value|Float32||

Return: 

- this (for chaining)

### func setParamfv\(UInt32,CPointer<Float32>\)
```cj
public func setParamfv(param: UInt32, values: CPointer < Float32 >): AudioEffect
```
Sets a float vector parameter

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Used by effects with multi-value parameters such as EAX Reverb; maps to
EFX alEffectfv(effect, param, values).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|param|UInt32|Parameter constantvalues Pointer to a Float32 array (caller is responsible for allocation/free)|
|values|CPointer<Float32>||

Return: 

- this (for chaining)

### func setParami\(UInt32,Int32\)
```cj
public func setParami(param: UInt32, value: Int32): AudioEffect
```
Sets an integer parameter

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX alEffecti(effect, param, value).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|param|UInt32|Parameter constantvalue Parameter value|
|value|Int32||

Return: 

- this (for chaining)

### func setType\(EffectType\)
```cj
public func setType(effectType: EffectType): AudioEffect
```
Sets the effect type

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX alEffecti(effect, AL_EFFECT_TYPE, type).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|effectType|EffectType|Effect type (EffectType.Reverb / Chorus / Echo / Equalizer, etc.)|

Return: 

- this (for chaining)

### var context
```cj
public var context: AudioContext
```
The associated audio context

### var effectId
```cj
public var effectId: UInt32
```
The OpenAL effect handle

