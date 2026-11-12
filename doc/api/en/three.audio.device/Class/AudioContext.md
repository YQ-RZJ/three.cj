# Class
## class AudioContext
```cj
public class AudioContext <: IReleasable
```
Audio context singleton managing the OpenAL device/context and a dedicated audio thread

### func execAudio\(\(\)\->Unit\)
```cj
public func execAudio(cmd:() -> Unit): Unit
```
Public thread-serialization entry point that submits an OpenAL API call
to the audio thread and executes it synchronously

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>External modules (e.g. AudioLoader/StreamingAudio/AudioRecorder) must queue
their OpenAL calls through this method to avoid data races; closures run on the
audio thread in submission order. Use this method when the result is needed
(e.g. handles filled by alGenBuffers); pure writes that do not care when they
take effect may use postAudio (never blocks the caller).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cmd|()->Unit|The closure to execute (raw OpenAL calls only)|

### func getError\(\)
```cj
public func getError(): UInt32
```
Returns the current OpenAL error code of the context

Return: 

- The AL error code (AL_NO_ERROR = 0 means no error)

### func getHrtfCount\(\)
```cj
public func getHrtfCount(): Int32
```
Returns the number of available HRTFs

Return: 

- Number of HRTFs (0 = device does not support HRTF)

### func getHrtfList\(\)
```cj
public func getHrtfList(): ArrayList < String >
```
Enumerates all available HRTF names into a list

Return: 

- List of HRTF names (may be empty = device does not support HRTF)

### func getHrtfName\(Int32\)
```cj
public func getHrtfName(index: Int32): String
```
Returns the HRTF name at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int32|HRTF index (0 ~ getHrtfCount()-1)|

Return: 

- The HRTF name string; empty string if the index is invalid

### func getHrtfStatus\(\)
```cj
public func getHrtfStatus(): Int32
```
Queries the current HRTF status

Return: 

- ALC_HRTF_DISABLED_SOFT(0) / ALC_HRTF_ENABLED_SOFT(1) /ALC_HRTF_DENIED_SOFT(2) / ALC_HRTF_REQUIRED_SOFT(3) /ALC_HRTF_HEADPHONES_DETECTED_SOFT(4) / ALC_HRTF_UNSUPPORTED_FORMAT_SOFT(5)

### func initialize\(\)
```cj
public func initialize(): Bool
```
Initializes the audio context (opens the device, creates the context and
makes it current on the audio thread)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>alcMakeContextCurrent must be called on the same thread (the audio thread)
that later issues OpenAL calls, so the whole initialization runs inside an
_execAudio closure.</p>

Return: 

- Whether initialization succeeded

### func postAudio\(\(\)\->Unit\)
```cj
public func postAudio(cmd:() -> Unit): Unit
```
Public post entry: queues an OpenAL call onto the audio thread **without waiting

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cmd|()->Unit|Closure to execute (raw OpenAL calls only; must not read back any result)|

### func postTransform\(AudioTransformSlot,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32,Float32\)
```cj
public func postTransform(slot: AudioTransformSlot, px: Float32, py: Float32, pz: Float32, ox: Float32, oy: Float32, oz: Float32, ux: Float32, uy: Float32, uz: Float32, gain: Float32): Unit
```
Asynchronously submits an audio object's transform (render thread, non-blocking)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|AudioTransformSlot|The transform slot|
|px|Float32|Position X|
|py|Float32|Position Y|
|pz|Float32|Position Z|
|ox|Float32|Orientation/direction X|
|oy|Float32|Orientation/direction Y|
|oz|Float32|Orientation/direction Z|
|ux|Float32|Up axis/velocity X|
|uy|Float32|Up axis/velocity Y|
|uz|Float32|Up axis/velocity Z|
|gain|Float32|Master gain (effective for listener slots only)|

### func registerTransformSlot\(AudioTransformSlot\)
```cj
public func registerTransformSlot(slot: AudioTransformSlot): Unit
```
Registers an audio transform slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|AudioTransformSlot|The transform slot (owned by the caller, must outlive the registration)|

### func release\(\)
```cj
public func release(): Bool
```
Shuts down the audio context and releases resources

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Cleanup runs on the audio thread to ensure OpenAL calls are issued on the
thread that owns the context; idempotent no-op when not initialized.</p>

### func selectHrtf\(Int32\)
```cj
public func selectHrtf(id: Int32): Unit
```
Selects a specific HRTF

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Takes effect after calling setHrtfEnabled(true); maps to the
ALC_HRTF_ID_SOFT setting of ALC_SOFT_HRTF.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int32|HRTF ID (0 ~ getHrtfCount()-1), -1 = restore automatic selection|

### func setDopplerFactor\(Float32\)
```cj
public func setDopplerFactor(factor: Float32): Unit
```
Sets the global Doppler factor

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The OpenAL default is 1.0; use together with PositionalAudio.setVelocity.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|factor|Float32|Doppler factor (0.0 = disables Doppler, 1.0 = physically correct,larger values exaggerate the effect)|

### func setDopplerVelocity\(Float32\)
```cj
public func setDopplerVelocity(velocity: Float32): Unit
```
Sets the Doppler velocity factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|velocity|Float32|Doppler velocity factor|

### func setHrtfEnabled\(Bool\)
```cj
public func setHrtfEnabled(enabled: Bool): Unit
```
Enables or disables HRTF (headphone spatial rendering)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to ALC_SOFT_HRTF: alcGetIntegerv(device, ALC_HRTF_SOFT, 1, &hrtf),
where hrtf = ALC_HRTF_ENABLED_SOFT / ALC_HRTF_DISABLED_SOFT.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|enabled|Bool|true = enabled, false = disabled|

### func setSpeedOfSound\(Float32\)
```cj
public func setSpeedOfSound(speed: Float32): Unit
```
Sets the reference speed of sound

Parameter: 

|Name|Type|Describe|
|---|---|---|
|speed|Float32|Speed of sound in m/s (default 343.3), used as the Doppler reference;larger values weaken the Doppler effect|

### func unregisterTransformSlot\(AudioTransformSlot\)
```cj
public func unregisterTransformSlot(slot: AudioTransformSlot): Unit
```
Unregisters an audio transform slot

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|AudioTransformSlot|The transform slot|

### prop context: AudioContext
```cj
public static prop context: AudioContext
```
Returns the singleton instance (lazily initialized)

### prop device: CPointer < Unit >
```cj
public prop device: CPointer < Unit >
```
Returns the OpenAL device handle

### prop initialized: Bool
```cj
public prop initialized: Bool
```
Whether the context has been initialized

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the resource is valid (initialized with a usable device handle)

