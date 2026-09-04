# Class
## class StreamingAudio
```cj
public open class StreamingAudio <: Audio
```
Streaming audio extending Audio

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases streaming audio resources (decoder + streaming buffers + source)

### func init\(AudioListener\)
```cj
public init(listener!: AudioListener)
```
Creates a streaming audio instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|listener|AudioListener|The associated audio listener|

### func load\(String\)
```cj
public func load(filePath: String): StreamingAudio
```
Loads an audio file and initializes the streaming decoder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|filePath|String|Audio file path (mp3/flac/ogg/wav, etc.)|

Return: 

- this (for chaining)

### func play\(Float64\)
```cj
public override func play(offset: Float64): Audio
```
Override: plays the streaming audio

Parameter: 

|Name|Type|Describe|
|---|---|---|
|offset|Float64|Playback start offset (seconds; ignored for streaming playback)|

Return: 

- this (of type Audio)

### func stop\(\)
```cj
public override func stop(): Audio
```
Override: stops streaming playback and resets the decoder to the start

Return: 

- this (of type Audio)

### func updateStream\(\)
```cj
public func updateStream(): StreamingAudio
```
Updates the stream: unqueues played buffers, refills them, and re-queues

Return: 

- this (for chaining)

