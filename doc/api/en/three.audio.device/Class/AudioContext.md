# Class
## class AudioContext
```cj
public class AudioContext
```
Audio context singleton managing the OpenAL device/context and a dedicated audio thread

### func execAudio\(\(\)\->Unit\)
```cj
public func execAudio(cmd:() -> Unit): Unit
```
Public thread-serialization entry point that submits an OpenAL API call
to the audio thread and executes it synchronously

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>External modules (e.g. AudioLoader/StreamingAudio/EffectComposer) must queue
their OpenAL calls through this method to avoid data races. Closures run on the
audio thread in submission order; calling other _execAudio-based methods
(e.g. initialize) from inside the closure self-deadlocks.</p>

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

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
Shuts down the audio context and releases resources

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Cleanup runs on the audio thread to ensure OpenAL calls are issued on the
thread that owns the context.</p>

### prop alcContext: CPointer < Unit >
```cj
public prop alcContext: CPointer < Unit >
```
Returns the OpenAL context handle

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

