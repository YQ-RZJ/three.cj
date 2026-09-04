# Class
## class AudioListener
```cj
public open class AudioListener <: Object3D
```
Audio listener representing the "ears" in the scene

### func getMasterVolume\(\)
```cj
public func getMasterVolume(): Float64
```
Returns the master volume

Return: 

- The current master volume (0.0 ~ 1.0+)

### func init\(AudioContext\)
```cj
public init(context!: AudioContext = AudioContext.context)
```
Creates an audio listener

Parameter: 

|Name|Type|Describe|
|---|---|---|
|context|AudioContext|The audio context (defaults to the AudioContext.context singleton)|

### func setMasterVolume\(Float64\)
```cj
public func setMasterVolume(value: Float64): Unit
```
Sets the master volume

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>When the context is initialized, the AL_GAIN is pushed to the OpenAL
listener synchronously via execAudio.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Target volume (0.0 = mute, 1.0 = unity)|

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
Overrides updateMatrixWorld to sync the world transform to the OpenAL listener

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Decomposes the position and orientation from matrixWorld, converts them to
the OpenAL right-handed system and applies them to the listener.
LH → RH conversion:
- Position: (x, y, z) → (x, y, -z)
- Forward (at): (x, y, z) → (x, y, -z)
- Up: (upX, upY, upZ) → (upX, upY, -upZ)</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Bool|Whether to force updating the world matrix|

### var context
```cj
public var context: AudioContext
```
The audio context reference

### var gain
```cj
public var gain: Float64
```
Master volume (0.0 ~ 1.0+)

### var timeDelta
```cj
public var timeDelta: Float64
```
Time delta (for smooth interpolation; current implementation is simplified, no linearRampToValueAtTime)

