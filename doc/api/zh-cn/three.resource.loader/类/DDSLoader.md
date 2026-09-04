# 类
## class DDSLoader
```cj
public class DDSLoader <: CompressedTextureLoader
```
S3TC 压缩纹理加载器

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


### func parse\(Array<UInt8>,Bool\)
```cj
public override func parse(buffer: Array < UInt8 >, isCubemap: Bool): HashMap < String, Any >
```


参数: 

|名称|类型|描述|
|---|---|---|
|buffer|Array<UInt8>|DDS 文件字节|
|isCubemap|Bool|是否按立方体贴图解析（bimg parse_dds 自动识别 cubemap 面）|

返回: 

- texData（width/height/format/mipmaps/mipmapCount）

