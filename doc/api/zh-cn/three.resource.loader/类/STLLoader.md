# 类
## class STLLoader
```cj
public class STLLoader <: Loader
```
STL 加载器，加载 STL（STereoLithography）格式的 3D 模型

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


### func load\(String,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public override func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```
开始加载 STL 文件

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|模型文件路径onLoad 加载完成回调，参数为 BufferGeometryonProgress 进度回调onError 错误回调|
|onLoad|(ILoadResult)->Unit||
|onProgress|(Int64)->Unit||
|onError|(String)->Unit||

### func parse\(Array<UInt8>\)
```cj
public func parse(data: Array < UInt8 >): BufferGeometry
```
解析 STL 字节数据为 BufferGeometry

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|STL 文件字节|

返回: 

- BufferGeometry

