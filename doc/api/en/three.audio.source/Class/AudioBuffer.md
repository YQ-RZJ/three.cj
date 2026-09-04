# Class
## class AudioBuffer
```cj
public class AudioBuffer <: ILoadResult
```
Audio buffer that stores decoded PCM data

### func createChunk\(CPointer<Unit>,UInt64,UInt32,UInt32\)
```cj
public static func createChunk(pcmData: CPointer < Unit >, frameCount: UInt64, channels: UInt32, sampleRate: UInt32): AudioBuffer
```
Creates a streaming chunk buffer (for StreamingAudio's queued buffers)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pcmData|CPointer<Unit>|The PCM data pointer of this chunkframeCount The frame count of this chunkchannels Number of channelssampleRate Sample rate|
|frameCount|UInt64||
|channels|UInt32||
|sampleRate|UInt32||

Return: 

- The created AudioBuffer instance (bufferId is ready)

### func create\(CPointer<Unit>,UInt64,UInt32,UInt32\)
```cj
public static func create(pcmData: CPointer < Unit >, frameCount: UInt64, channels: UInt32, sampleRate: UInt32): AudioBuffer
```
Creates and fills an OpenAL buffer from PCM data (static buffer)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>OpenAL calls run on the audio thread via context.execAudio.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pcmData|CPointer<Unit>|PCM data pointer (16-bit interleaved format)frameCount Total number of frameschannels Number of channels (1=mono, 2=stereo)sampleRate Sample rate|
|frameCount|UInt64||
|channels|UInt32||
|sampleRate|UInt32||

Return: 

- The created AudioBuffer instance

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the OpenAL buffer resource

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>OpenAL calls run on the audio thread via context.execAudio.</p>

### func init\(\)
```cj
public init()
```
Creates an empty audio buffer (filled later by create / createChunk)

### var bufferId
```cj
public var bufferId: UInt32
```
The OpenAL buffer ID

### var channels
```cj
public var channels: UInt32
```
Number of channels

### var dataSize
```cj
public var dataSize: Int32
```
PCM data size in bytes

### var format
```cj
public var format: UInt32
```
Sample format (AL_FORMAT_MONO16 / AL_FORMAT_STEREO16, etc.)

### var frameCount
```cj
public var frameCount: UInt64
```
Total number of PCM frames

### var sampleRate
```cj
public var sampleRate: UInt32
```
Sample rate

