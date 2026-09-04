# Class
## class Audio
```cj
public open class Audio <: Object3D
```
Non-positional audio base class extending Object3D

### func connectEffectSlot\(IAudioEffectSlot,Int32,Option<IAudioFilter>\)
```cj
public func connectEffectSlot(slot: IAudioEffectSlot, send: Int32, filter!: Option < IAudioFilter >= None): Audio
```
Connects the source to an auxiliary effect slot (send path; the source's
output is processed by the slot and mixed back)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alSource3i(source, AL_AUXILIARY_SEND_FILTER, slotId, send, filterId).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|slot|IAudioEffectSlot|The auxiliary effect slot (IAudioEffectSlot)send The send index (usually 0)filter Optional filter on the send path; no filtering by default|
|send|Int32||
|filter|Option<IAudioFilter>||

Return: 

- this (for chaining)

### func disconnectEffectSlot\(Int32\)
```cj
public func disconnectEffectSlot(send: Int32): Audio
```
Disconnects the auxiliary effect slot for the given send index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|send|Int32|The send index|

Return: 

- this (for chaining)

### func disconnect\(\)
```cj
public func disconnect(): Audio
```
Disconnects (releases the OpenAL source)

Return: 

- this (for chaining)

### func getDetune\(\)
```cj
public func getDetune(): Float64
```
Returns the detune

Return: 

- The current detune (cents)

### func getLoop\(\)
```cj
public func getLoop(): Bool
```
Returns the loop state

Return: 

- Whether loop playback is currently enabled

### func getOutput\(\)
```cj
public func getOutput(): UInt32
```
Returns the output node (in OpenAL the source itself)

Return: 

- The OpenAL source ID

### func getPlaybackRate\(\)
```cj
public func getPlaybackRate(): Float64
```
Returns the playback rate

Return: 

- The current playback rate

### func getSourceState\(\)
```cj
public func getSourceState(): SourceState
```
Returns the current playback state

Return: 

- The source's playback state (e.g. Playing / Paused / Stopped)

### func getVolume\(\)
```cj
public func getVolume(): Float64
```
Returns the volume gain

Return: 

- The current volume gain

### func init\(AudioListener\)
```cj
public init(listener!: AudioListener)
```
Creates a non-positional audio source

Parameter: 

|Name|Type|Describe|
|---|---|---|
|listener|AudioListener|The associated audio listener|

### func pause\(\)
```cj
public func pause(): Audio
```
Pauses playback

Return: 

- this (for chaining)

### func play\(\)
```cj
public func play(): Audio
```
Plays the audio (from the current position or 0)

Return: 

- this (for chaining)

### func play\(Float64\)
```cj
public open func play(offset: Float64): Audio
```
Plays the audio

Parameter: 

|Name|Type|Describe|
|---|---|---|
|offset|Float64|Playback start offset (seconds); -1 starts from the current position|

Return: 

- this (for chaining)

### func removeDirectFilter\(\)
```cj
public func removeDirectFilter(): Audio
```
Removes the direct filter

Return: 

- this (for chaining)

### func setBuffer\(AudioBuffer\)
```cj
public func setBuffer(audioBuffer: AudioBuffer): Audio
```
Sets the audio buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|audioBuffer|AudioBuffer|The audio buffer to bind|

Return: 

- this (for chaining)

### func setDetune\(Float64\)
```cj
public func setDetune(value: Float64): Audio
```
Sets the detune

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>OpenAL has no detune attribute; approximated via pitch:
pitch = playbackRate * 2^(detune/1200).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Detune in cents (100 cents = one semitone)|

Return: 

- this (for chaining)

### func setDirectFilter\(AudioFilter\)
```cj
public func setDirectFilter(filter: AudioFilter): Audio
```
Sets the direct filter (filters the source's direct path)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Maps to EFX: alSourcei(source, AL_DIRECT_FILTER, filterId).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|filter|AudioFilter|The filter object (AudioFilter); an AudioFilter with filterId=0 removes it|

Return: 

- this (for chaining)

### func setLoop\(Bool\)
```cj
public func setLoop(value: Bool): Audio
```
Sets loop playback

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Bool|Whether to loop playback|

Return: 

- this (for chaining)

### func setPlaybackRate\(Float64\)
```cj
public func setPlaybackRate(value: Float64): Audio
```
Sets the playback rate

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|The playback rate (1.0 is normal speed)|

Return: 

- this (for chaining)

### func setVolume\(Float64\)
```cj
public func setVolume(value: Float64): Audio
```
Sets the volume gain

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Float64|Volume gain (0.0 and above)|

Return: 

- this (for chaining)

### func stop\(\)
```cj
public open func stop(): Audio
```
Stops playback and resets the offset

Return: 

- this (for chaining)

### var autoplay
```cj
public var autoplay: Bool
```
Whether to autoplay

### var buffer
```cj
public var buffer: Option < AudioBuffer >
```
The audio buffer

### var context
```cj
public var context: AudioContext
```
The audio context

### var detune
```cj
public var detune: Float64
```
Detune in cents (100 cents = one semitone)

### var gain
```cj
public var gain: Float64
```
Volume gain (0.0 and above)

### var hasPlaybackControl
```cj
public var hasPlaybackControl: Bool
```
Whether playback control is available

### var isAudio
```cj
public var isAudio: Bool
```
Whether this is an Audio object

### var isPlaying
```cj
public var isPlaying: Bool
```
Whether currently playing

### var listener
```cj
public var listener: AudioListener
```
The associated audio listener

### var loop
```cj
public var loop: Bool
```
Whether to loop playback

### var offset
```cj
public var offset: Float64
```
Playback offset (seconds)

### var playbackRate
```cj
public var playbackRate: Float64
```
Playback rate

### var sourceId
```cj
public var sourceId: UInt32
```
The OpenAL source ID

### var sourceType
```cj
public var sourceType: String
```
Source type: "empty" | "buffer"

