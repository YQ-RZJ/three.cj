# Class
## class AudioLoader
```cj
public class AudioLoader <: Loader
```
Audio file loader

### func init\(LoadingManager\)
```cj
public init(manager: LoadingManager)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|manager|LoadingManager||

### func init\(\)
```cj
public init()
```


### func loadFromBytes\(Array<UInt8>\)
```cj
public func loadFromBytes(data: Array < UInt8 >): AudioBuffer
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Complete byte data of the audio file|

Return: 

- Decoded AudioBuffer instance从内存字节数组加载音频并创建 AudioBuffer使用 miniaudio 的 ma_decode_memory_cj 解码（支持 mp3/flac/ogg/wav 等）。用途：OHOS 平台 rawfile 资源不能通过文件系统路径访问（FileIo.access 失败），需经 resourceManager.getRawFileContent 拿到字节后走内存解码；桌面平台亦可传 File.readFrom 读出的字节。

Exception: 

- Exception Thrown when decoding fails

### func load\(String\)
```cj
public func load(url: String): AudioBuffer
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Audio file path (local path)|

Return: 

- Decoded AudioBuffer instance加载音频文件并创建 AudioBuffer，使用 miniaudio 将音频文件解码为 16-bit PCM，然后创建 OpenAL Buffer。支持 mp3、flac、ogg、wav 等格式。

Exception: 

- Exception Thrown when file decoding fails

### func load\(String,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public override func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```
带回调的加载方式

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String||
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

