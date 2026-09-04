# Class
## class DataTextureLoader
```cj
public open class DataTextureLoader <: Loader
```
Abstract base class for data texture loaders, loading RGBE, EXR, TGA binary texture formats

### func \_applyTexData\(DataTexture,HashMap<String,Any>\)
```cj
public func _applyTexData(texture: DataTexture, texData: HashMap < String, Any >): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|DataTexture|Target DataTexture|
|texData|HashMap<String,Any>|Parsed texture data (HashMap, returned by subclass parse)将解析出的纹理数据应用到 DataTexture应用字段：image/data、width/height、wrapS/wrapT、magFilter/minFilter、anisotropy、colorSpace、flipY、format、type、mipmaps、generateMipmaps|

### func createDataTexture\(Array<UInt8>\)
```cj
public func createDataTexture(buffer: Array < UInt8 >): DataTexture
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|Array<UInt8>|Raw binary data|

Return: 

- DataTexture object从内存中的二进制数据创建纹理

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
|onLoad|(ILoadResult)->Unit|Load complete callback, parameter is DataTexture|
|onProgress|(Int64)->Unit|Progress callback|
|onError|(String)->Unit|Error callback开始加载数据纹理使用 std.fs.File.readFrom 读取二进制纹理文件，并调用 parse 解析，然后通过 _applyTexData 将解析结果应用到 DataTexture。|

### func parse\(Array<UInt8>\)
```cj
public open func parse(buffer: Array < UInt8 >): HashMap < String, Any >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|Array<UInt8>|Raw binary data|

Return: 

- Parsed texture data解析二进制数据为纹理数据（子类实现）

