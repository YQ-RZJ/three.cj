# 类
## class AudioEffectSlot
```cj
public class AudioEffectSlot <: IAudioEffectSlot
```
EFX 辅助效果槽，封装 OpenAL AuxiliaryEffectSlot 句柄

### func clearEffect\(\)
```cj
public func clearEffect(): AudioEffectSlot
```
清除效果槽绑定的效果（解绑）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alAuxiliaryEffectSloti(slot, AL_EFFECTSLOT_EFFECT, AL_EFFECTSLOT_NULL)。</p>

返回: 

- this（便于链式调用）

### func create\(\)
```cj
public func create(): AudioEffectSlot
```
创建并生成 OpenAL 效果槽

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>在音频线程执行 alGenAuxiliaryEffectSlots；若已创建则跳过。</p>

返回: 

- this（便于链式调用）

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 OpenAL 效果槽

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alDeleteAuxiliaryEffectSlots；释放后句柄归零，重复调用安全。</p>

### func getSlotId\(\)
```cj
public func getSlotId(): UInt32
```
接口实现：获取 OpenAL 效果槽句柄

返回: 

- OpenAL 效果槽句柄（ALuint）

### func init\(AudioContext\)
```cj
public init(context!: AudioContext = AudioContext.context)
```
创建音频效果槽

参数: 

|名称|类型|描述|
|---|---|---|
|context|AudioContext|音频上下文（默认使用 AudioContext.context 单例）|

### func setEffect\(AudioEffect\)
```cj
public func setEffect(effect: AudioEffect): AudioEffectSlot
```
绑定效果到此效果槽

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alAuxiliaryEffectSloti(slot, AL_EFFECTSLOT_EFFECT, effectId)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|effect|AudioEffect|要绑定的 AudioEffect（需已 create 并 setType）|

返回: 

- this（便于链式调用）

### func setGain\(Float32\)
```cj
public func setGain(value: Float32): AudioEffectSlot
```
设置效果槽增益（控制效果输出的整体音量）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对应 EFX: alAuxiliaryEffectSlotf(slot, AL_EFFECTSLOT_GAIN, value)。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float32|增益（0.0~1.0）|

返回: 

- this（便于链式调用）

### var context
```cj
public var context: AudioContext
```
关联的音频上下文

### var slotId
```cj
public var slotId: UInt32
```
OpenAL 效果槽句柄

