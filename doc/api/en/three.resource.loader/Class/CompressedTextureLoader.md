# Class
## class CompressedTextureLoader
```cj
public open class CompressedTextureLoader <: Loader
```
Abstract base class for compressed texture loaders, for loading S3TC, ASTC, ETC compressed texture formats

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


### func load\(String,\(ILoadResult\)\->Unit,\(Int64\)\->Unit,\(String\)\->Unit\)
```cj
public override func load(url: String, onLoad:(ILoadResult) -> Unit, onProgress:(Int64) -> Unit, onError:(String) -> Unit): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Texture file path|
|onLoad|(ILoadResult)->Unit|Load complete callback|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback开始加载压缩纹理使用 std.fs.File.readFrom 读取压缩纹理文件，调用 parse 解析，并将解析结果（width/height/format/mipmaps 等）应用到 CompressedTexture。|

### func parse\(Array<UInt8>,Bool\)
```cj
public open func parse(buffer: Array < UInt8 >, isCubemap: Bool): HashMap < String, Any >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|Array<UInt8>|Raw binary data|
|isCubemap|Bool|Whether it is a cubemap|

Return: 

- Texture data object解析二进制数据为纹理数据（子类实现）

