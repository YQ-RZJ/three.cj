# Class
## class AudioEffectSlot
```cj
public class AudioEffectSlot <: IAudioEffectSlot
```
EFX auxiliary effect slot wrapping an OpenAL AuxiliaryEffectSlot handle

### func clearEffect\(\)
```cj
public func clearEffect(): AudioEffectSlot
```
Clears the effect bound to this effect slot (unbind)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alAuxiliaryEffectSloti(slot, AL_EFFECTSLOT_EFFECT, AL_EFFECTSLOT_NULL).</p>

Return: 

- this (for chaining)

### func create\(\)
```cj
public func create(): AudioEffectSlot
```
Creates and generates the OpenAL effect slot

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Runs alGenAuxiliaryEffectSlots on the audio thread; skips if already created.</p>

Return: 

- this (for chaining)

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the OpenAL effect slot

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alDeleteAuxiliaryEffectSlots; the handle is zeroed after release and repeated calls are safe.</p>

### func getSlotId\(\)
```cj
public func getSlotId(): UInt32
```
Interface implementation: returns the OpenAL effect slot handle

Return: 

- The OpenAL effect slot handle (ALuint)

### func init\(AudioContext\)
```cj
public init(context!: AudioContext = AudioContext.context)
```
Creates an audio effect slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|The audio context (defaults to the AudioContext.context singleton)|

### func setEffect\(AudioEffect\)
```cj
public func setEffect(effect: AudioEffect): AudioEffectSlot
```
Binds an effect to this effect slot

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alAuxiliaryEffectSloti(slot, AL_EFFECTSLOT_EFFECT, effectId).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|effect|AudioEffect|The AudioEffect to bind (must have been created and set a type)|

Return: 

- this (for chaining)

### func setGain\(Float32\)
```cj
public func setGain(value: Float32): AudioEffectSlot
```
Sets the effect slot gain (overall volume of the effect output)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alAuxiliaryEffectSlotf(slot, AL_EFFECTSLOT_GAIN, value).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float32|The gain (0.0~1.0)|

Return: 

- this (for chaining)

### var context
```cj
public var context: AudioContext
```
The associated audio context

### var slotId
```cj
public var slotId: UInt32
```
The OpenAL effect slot handle

