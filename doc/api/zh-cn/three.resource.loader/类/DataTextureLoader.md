# 类
## class DataTextureLoader
```cj
public open class DataTextureLoader <: Loader
```
数据纹理加载器抽象基类，加载 RGBE、EXR、TGA 等二进制纹理格式

### func \_applyTexData\(DataTexture,HashMap<String,Any>\)
```cj
public func _applyTexData(texture: DataTexture, texData: HashMap < String, Any >): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|texture|DataTexture|目标 DataTexture|
|texData|HashMap<String,Any>|解析出的纹理数据（HashMap，子类 parse 返回）|

### func createDataTexture\(Array<UInt8>\)
```cj
public func createDataTexture(buffer: Array < UInt8 >): DataTexture
```


参数: 

|名称|类型|描述|
|---|---|---|
|buffer|Array<UInt8>|原始二进制数据|

返回: 

- DataTexture 对象

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


参数: 

|名称|类型|描述|
|---|---|---|
|url|String|纹理文件路径|
|onLoad|(ILoadResult)->Unit|加载完成回调，参数为 DataTexture|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

### func parse\(Array<UInt8>\)
```cj
public open func parse(buffer: Array < UInt8 >): HashMap < String, Any >
```


参数: 

|名称|类型|描述|
|---|---|---|
|buffer|Array<UInt8>|原始二进制数据|

返回: 

- 解析后的纹理数据

