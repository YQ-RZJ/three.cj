# 类
## class AudioBuffer
```cj
public class AudioBuffer <: ILoadResult
```
音频缓冲区，存储解码后的 PCM 数据

### func createChunk\(CPointer<Unit>,UInt64,UInt32,UInt32\)
```cj
public static func createChunk(pcmData: CPointer < Unit >, frameCount: UInt64, channels: UInt32, sampleRate: UInt32): AudioBuffer
```
创建流式分段缓冲区（用于 StreamingAudio 的队列缓冲）

参数: 

|名称|类型|描述|
|---|---|---|
|pcmData|CPointer<Unit>|该分段的 PCM 数据指针frameCount 该分段的帧数channels 声道数sampleRate 采样率|
|frameCount|UInt64||
|channels|UInt32||
|sampleRate|UInt32||

返回: 

- 创建的 AudioBuffer 实例（bufferId 已就绪）

### func create\(CPointer<Unit>,UInt64,UInt32,UInt32\)
```cj
public static func create(pcmData: CPointer < Unit >, frameCount: UInt64, channels: UInt32, sampleRate: UInt32): AudioBuffer
```
根据 PCM 数据创建并填充 OpenAL 缓冲区（静态缓冲）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>OpenAL 调用经 context.execAudio 在音频线程执行。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|pcmData|CPointer<Unit>|PCM 数据指针（16-bit 交错格式）frameCount 总帧数channels 声道数（1=单声道, 2=立体声）sampleRate 采样率|
|frameCount|UInt64||
|channels|UInt32||
|sampleRate|UInt32||

返回: 

- 创建的 AudioBuffer 实例

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 OpenAL 缓冲区资源

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>OpenAL 调用经 context.execAudio 在音频线程执行。</p>

### func init\(\)
```cj
public init()
```
创建空的音频缓冲区（随后由 create / createChunk 填充）

### var bufferId
```cj
public var bufferId: UInt32
```
OpenAL 缓冲区 ID

### var channels
```cj
public var channels: UInt32
```
声道数

### var dataSize
```cj
public var dataSize: Int32
```
PCM 数据字节大小

### var format
```cj
public var format: UInt32
```
采样格式（AL_FORMAT_MONO16 / AL_FORMAT_STEREO16 等）

### var frameCount
```cj
public var frameCount: UInt64
```
PCM 数据总帧数

### var sampleRate
```cj
public var sampleRate: UInt32
```
采样率

