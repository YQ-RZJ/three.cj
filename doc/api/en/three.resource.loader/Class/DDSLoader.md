# Class
## class DDSLoader
```cj
public class DDSLoader <: CompressedTextureLoader
```
S3TC compressed texture loader

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


### func parse\(Array<UInt8>,Bool\)
```cj
public override func parse(buffer: Array < UInt8 >, isCubemap: Bool): HashMap < String, Any >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|Array<UInt8>|DDS file bytes|
|isCubemap|Bool|Whether to parse as cubemap (bimg parse_dds auto-detects cubemap faces)|

Return: 

- texData (width/height/format/mipmaps/mipmapCount)解析 DDS 字节数据仓颉侧基于 bgfx4cj.bimg 的 parse_dds 解析：复用 GltfLoader 的 bimg 调用范式（allocator → parse → 读取 ImageContainer → free）。

