# 类
## class AudioLoader
```cj
public class AudioLoader <: Loader
```
音频文件加载器

### func init\(LoadingManager\)
```cj
public init(manager: LoadingManager)
```


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|音频文件的完整字节数据|

返回: 

- 解码后的 AudioBuffer 实例

异常: 

- Exception 解码失败时抛出异常

### func load\(String\)
```cj
public func load(url: String): AudioBuffer
```


参数: 

|名称|类型|描述|
|---|---|---|
|url|String|音频文件路径（本地路径）|

返回: 

- 解码后的 AudioBuffer 实例

异常: 

- Exception 文件解码失败时抛出异常

### func load\(String,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public override func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```
带回调的加载方式

参数: 

|名称|类型|描述|
|---|---|---|
|url|String||
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

