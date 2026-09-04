# 类
## class Audio
```cj
public open class Audio <: Object3D
```
非位置音频基类，继承 Object3D

### func connectEffectSlot\(IAudioEffectSlot,Int32,Option<IAudioFilter>\)
```cj
public func connectEffectSlot(slot: IAudioEffectSlot, send: Int32, filter!: Option < IAudioFilter >= None): Audio
```
将源连接到辅助效果槽（发送路径，使源的输出经效果槽处理后混合）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alSource3i(source, AL_AUXILIARY_SEND_FILTER, slotId, send, filterId)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|slot|IAudioEffectSlot|辅助效果槽（IAudioEffectSlot）send 发送编号（通常为 0）filter 发送路径上的可选滤波器，默认无滤波|
|send|Int32||
|filter|Option<IAudioFilter>||

返回: 

- this（便于链式调用）

### func disconnectEffectSlot\(Int32\)
```cj
public func disconnectEffectSlot(send: Int32): Audio
```
断开指定发送编号的辅助效果槽连接

参数: 

|名称|类型|描述|
|---|---|---|
|send|Int32|发送编号|

返回: 

- this（便于链式调用）

### func disconnect\(\)
```cj
public func disconnect(): Audio
```
断开连接（清理 OpenAL 源）

返回: 

- this（便于链式调用）

### func getDetune\(\)
```cj
public func getDetune(): Float64
```
获取音调偏移

返回: 

- 当前音调偏移（cent）

### func getLoop\(\)
```cj
public func getLoop(): Bool
```
获取循环状态

返回: 

- 当前是否循环播放

### func getOutput\(\)
```cj
public func getOutput(): UInt32
```
获取输出节点（OpenAL 中为源本身）

返回: 

- OpenAL 源 ID

### func getPlaybackRate\(\)
```cj
public func getPlaybackRate(): Float64
```
获取播放速率

返回: 

- 当前播放速率

### func getSourceState\(\)
```cj
public func getSourceState(): SourceState
```
获取当前播放状态

返回: 

- 源的播放状态（如 Playing / Paused / Stopped）

### func getVolume\(\)
```cj
public func getVolume(): Float64
```
获取音量增益

返回: 

- 当前音量增益

### func init\(AudioListener\)
```cj
public init(listener!: AudioListener)
```
创建非位置音频源

参数: 

|名称|类型|描述|
|---|---|---|
|listener|AudioListener|关联的音频监听器|

### func pause\(\)
```cj
public func pause(): Audio
```
暂停播放

返回: 

- this（便于链式调用）

### func play\(\)
```cj
public func play(): Audio
```
播放音频（从当前位置或 0 开始）

返回: 

- this（便于链式调用）

### func play\(Float64\)
```cj
public open func play(offset: Float64): Audio
```
播放音频

参数: 

|名称|类型|描述|
|---|---|---|
|offset|Float64|播放起始偏移（秒），-1 表示从当前位置开始|

返回: 

- this（便于链式调用）

### func removeDirectFilter\(\)
```cj
public func removeDirectFilter(): Audio
```
移除直接滤波器

返回: 

- this（便于链式调用）

### func setBuffer\(AudioBuffer\)
```cj
public func setBuffer(audioBuffer: AudioBuffer): Audio
```
设置音频缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|audioBuffer|AudioBuffer|要绑定的音频缓冲区|

返回: 

- this（便于链式调用）

### func setDetune\(Float64\)
```cj
public func setDetune(value: Float64): Audio
```
设置音调偏移

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>OpenAL 没有 detune 属性，通过 pitch 近似实现：
pitch = playbackRate * 2^(detune/1200)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|音调偏移（cent，±100 为半音）|

返回: 

- this（便于链式调用）

### func setDirectFilter\(AudioFilter\)
```cj
public func setDirectFilter(filter: AudioFilter): Audio
```
设置直接滤波器（作用于源直通路径的滤波）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alSourcei(source, AL_DIRECT_FILTER, filterId)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|filter|AudioFilter|滤波器对象（AudioFilter），传 filterId=0 的 AudioFilter 等效移除|

返回: 

- this（便于链式调用）

### func setLoop\(Bool\)
```cj
public func setLoop(value: Bool): Audio
```
设置循环

参数: 

|名称|类型|描述|
|---|---|---|
|value|Bool|是否循环播放|

返回: 

- this（便于链式调用）

### func setPlaybackRate\(Float64\)
```cj
public func setPlaybackRate(value: Float64): Audio
```
设置播放速率

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|播放速率（1.0 为正常速度）|

返回: 

- this（便于链式调用）

### func setVolume\(Float64\)
```cj
public func setVolume(value: Float64): Audio
```
设置音量增益

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|音量增益（0.0 及以上）|

返回: 

- this（便于链式调用）

### func stop\(\)
```cj
public open func stop(): Audio
```
停止播放并重置偏移

返回: 

- this（便于链式调用）

### var autoplay
```cj
public var autoplay: Bool
```
是否自动播放

### var buffer
```cj
public var buffer: Option < AudioBuffer >
```
音频缓冲区

### var context
```cj
public var context: AudioContext
```
音频上下文

### var detune
```cj
public var detune: Float64
```
音调偏移（cent，±100 为半音）

### var gain
```cj
public var gain: Float64
```
音量增益（0.0 及以上）

### var hasPlaybackControl
```cj
public var hasPlaybackControl: Bool
```
是否可控制播放

### var isAudio
```cj
public var isAudio: Bool
```
是否为 Audio 对象

### var isPlaying
```cj
public var isPlaying: Bool
```
是否正在播放

### var listener
```cj
public var listener: AudioListener
```
关联的监听器

### var loop
```cj
public var loop: Bool
```
是否循环播放

### var offset
```cj
public var offset: Float64
```
播放偏移（秒）

### var playbackRate
```cj
public var playbackRate: Float64
```
播放速率

### var sourceId
```cj
public var sourceId: UInt32
```
OpenAL 源 ID

### var sourceType
```cj
public var sourceType: String
```
源类型："empty" | "buffer"

