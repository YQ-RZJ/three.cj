# 类
## class CompressedTextureLoader
```cj
public open class CompressedTextureLoader <: Loader
```
压缩纹理加载器抽象基类，用于加载 S3TC、ASTC、ETC 等压缩纹理格式

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
|onLoad|(ILoadResult)->Unit|加载完成回调|
|onProgress|(Int64)->Unit|进度回调|
|onError|(String)->Unit|错误回调|

### func parse\(Array<UInt8>,Bool\)
```cj
public open func parse(buffer: Array < UInt8 >, isCubemap: Bool): HashMap < String, Any >
```


参数: 

|名称|类型|描述|
|---|---|---|
|buffer|Array<UInt8>|原始二进制数据|
|isCubemap|Bool|是否为立方体贴图|

返回: 

- 纹理数据对象

