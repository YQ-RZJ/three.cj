# 类
## class AudioFilter
```cj
public class AudioFilter <: IAudioFilter
```
EFX 滤波器对象，封装 OpenAL Filter 句柄

### func createBandpassFilter\(AudioContext,Float32,Float32,Float32\)
```cj
public static func createBandpassFilter(context!: AudioContext = AudioContext.context, gain!: Float32 = 1.0f32, gainLF!: Float32 = 1.0f32, gainHF!: Float32 = 1.0f32): AudioFilter
```
创建带通滤波器（仅保留某频段）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）gain 全频段增益（0.0~1.0），默认 1.0gainLF 低频增益（0.0~1.0），默认 1.0gainHF 高频增益（0.0~1.0），默认 1.0|
|gain|Float32||
|gainLF|Float32||
|gainHF|Float32||

返回: 

- 配置好的 AudioFilter

### func createHighpassFilter\(AudioContext,Float32,Float32\)
```cj
public static func createHighpassFilter(context!: AudioContext = AudioContext.context, gain!: Float32 = 1.0f32, gainLF!: Float32 = 0.5f32): AudioFilter
```
创建高通滤波器（衰减低频）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）gain 全频段增益（0.0~1.0），默认 1.0gainLF 低频增益（0.0~1.0），值越小低频衰减越强，默认 0.5|
|gain|Float32||
|gainLF|Float32||

返回: 

- 配置好的 AudioFilter

### func createLowpassFilter\(AudioContext,Float32,Float32\)
```cj
public static func createLowpassFilter(context!: AudioContext = AudioContext.context, gain!: Float32 = 1.0f32, gainHF!: Float32 = 0.5f32): AudioFilter
```
创建低通滤波器（衰减高频，模拟隔墙/水下音效）

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）gain 全频段增益（0.0~1.0），默认 1.0gainHF 高频增益（0.0~1.0），值越小高频衰减越强，默认 0.5|
|gain|Float32||
|gainHF|Float32||

返回: 

- 配置好的 AudioFilter

### func create\(\)
```cj
public func create(): AudioFilter
```
创建并生成 OpenAL 滤波器对象

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>在音频线程执行 alGenFilters；若已创建则跳过。</p>

返回: 

- this（便于链式调用）

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 OpenAL 滤波器对象

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alDeleteFilters；释放后句柄归零，重复调用安全。</p>

### func getFilterId\(\)
```cj
public func getFilterId(): UInt32
```
接口实现：获取 OpenAL 滤波器句柄

返回: 

- OpenAL 滤波器句柄（ALuint）

### func init\(AudioContext\)
```cj
public init(context!: AudioContext = AudioContext.context)
```
创建音频滤波器对象

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）|

### func setParamf\(UInt32,Float32\)
```cj
public func setParamf(param: UInt32, value: Float32): AudioFilter
```
设置浮点参数

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alFilterf(filter, param, value)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|param|UInt32|参数常量（如 AL_LOWPASS_GAIN / AL_LOWPASS_GAINHF）value 参数值|
|value|Float32||

返回: 

- this（便于链式调用）

### func setType\(FilterType\)
```cj
public func setType(filterType: FilterType): AudioFilter
```
设置滤波器类型

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alFilteri(filter, AL_FILTER_TYPE, type)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|filterType|FilterType|滤波器类型（FilterType.Lowpass / Highpass / Bandpass）|

返回: 

- this（便于链式调用）

### var context
```cj
public var context: AudioContext
```
关联的音频上下文

### var filterId
```cj
public var filterId: UInt32
```
OpenAL 滤波器句柄

