# Class
## class AudioFilter
```cj
public class AudioFilter <: IAudioFilter
```
EFX filter object wrapping an OpenAL Filter handle

### func createBandpassFilter\(AudioContext,Float32,Float32,Float32\)
```cj
public static func createBandpassFilter(context!: AudioContext = AudioContext.context, gain!: Float32 = 1.0f32, gainLF!: Float32 = 1.0f32, gainHF!: Float32 = 1.0f32): AudioFilter
```
Creates a bandpass filter (keeps only a certain frequency band)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|The audio context (defaults to the AudioContext.context singleton)gain Full-band gain (0.0~1.0), default 1.0gainLF Low-frequency gain (0.0~1.0), default 1.0gainHF High-frequency gain (0.0~1.0), default 1.0|
|gain|Float32||
|gainLF|Float32||
|gainHF|Float32||

Return: 

- The configured AudioFilter

### func createHighpassFilter\(AudioContext,Float32,Float32\)
```cj
public static func createHighpassFilter(context!: AudioContext = AudioContext.context, gain!: Float32 = 1.0f32, gainLF!: Float32 = 0.5f32): AudioFilter
```
Creates a highpass filter (attenuates low frequencies)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|The audio context (defaults to the AudioContext.context singleton)gain Full-band gain (0.0~1.0), default 1.0gainLF Low-frequency gain (0.0~1.0); smaller value means stronger low-frequency attenuation, default 0.5|
|gain|Float32||
|gainLF|Float32||

Return: 

- The configured AudioFilter

### func createLowpassFilter\(AudioContext,Float32,Float32\)
```cj
public static func createLowpassFilter(context!: AudioContext = AudioContext.context, gain!: Float32 = 1.0f32, gainHF!: Float32 = 0.5f32): AudioFilter
```
Creates a lowpass filter (attenuates high frequencies, e.g. muffled/wet sound)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|The audio context (defaults to the AudioContext.context singleton)gain Full-band gain (0.0~1.0), default 1.0gainHF High-frequency gain (0.0~1.0); smaller value means stronger high-frequency attenuation, default 0.5|
|gain|Float32||
|gainHF|Float32||

Return: 

- The configured AudioFilter

### func create\(\)
```cj
public func create(): AudioFilter
```
Creates and generates the OpenAL filter object

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Runs alGenFilters on the audio thread; skips if already created.</p>

Return: 

- this (for chaining)

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the OpenAL filter object

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alDeleteFilters; the handle is zeroed after release and repeated calls are safe.</p>

### func getFilterId\(\)
```cj
public func getFilterId(): UInt32
```
Interface implementation: returns the OpenAL filter handle

Return: 

- The OpenAL filter handle (ALuint)

### func init\(AudioContext\)
```cj
public init(context!: AudioContext = AudioContext.context)
```
Creates an audio filter object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|The audio context (defaults to the AudioContext.context singleton)|

### func setParamf\(UInt32,Float32\)
```cj
public func setParamf(param: UInt32, value: Float32): AudioFilter
```
Sets a floating-point parameter

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alFilterf(filter, param, value).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|param|UInt32|The parameter constant (e.g. AL_LOWPASS_GAIN / AL_LOWPASS_GAINHF)value The parameter value|
|value|Float32||

Return: 

- this (for chaining)

### func setType\(FilterType\)
```cj
public func setType(filterType: FilterType): AudioFilter
```
Sets the filter type

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alFilteri(filter, AL_FILTER_TYPE, type).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|filterType|FilterType|Filter type (FilterType.Lowpass / Highpass / Bandpass)|

Return: 

- this (for chaining)

### var context
```cj
public var context: AudioContext
```
The associated audio context

### var filterId
```cj
public var filterId: UInt32
```
The OpenAL filter handle

