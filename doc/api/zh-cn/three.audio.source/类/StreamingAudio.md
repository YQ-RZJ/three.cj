# 类
## class StreamingAudio
```cj
public open class StreamingAudio <: Audio
```
流式音频，继承 Audio

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放流式音频资源（解码器 + 流式缓冲 + 源）

### func init\(\)
```cj
public init()
```
创建流式音频实例

### func init\(AudioListener\)
```cj
public init(listener!: AudioListener)
```


参数: 

|名称|类型|描述|
|---|---|---|
|listener|AudioListener||

### func load\(String\)
```cj
public func load(filePath: String): StreamingAudio
```
加载音频文件并初始化流式解码器

参数: 

|名称|类型|描述|
|---|---|---|
|filePath|String|音频文件路径（mp3/flac/ogg/wav 等）|

返回: 

- this（便于链式调用）

### func play\(Float64\)
```cj
public override func play(offset: Float64): Audio
```
重写：播放流式音频

参数: 

|名称|类型|描述|
|---|---|---|
|offset|Float64|播放起始偏移（秒，流式播放时被忽略）|

返回: 

- this（Audio 类型）

### func stop\(\)
```cj
public override func stop(): Audio
```
重写：停止流式播放并重置解码器到起始位置

返回: 

- this（Audio 类型）

### func updateStream\(\)
```cj
public func updateStream(): StreamingAudio
```
更新流：出队已播放缓冲 → 重新填充 → 入队

返回: 

- this（便于链式调用）

