# Class
## class KTXLoader
```cj
public class KTXLoader <: CompressedTextureLoader
```
KTX compressed texture loader

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
|buffer|Array<UInt8>|KTX file bytes|
|isCubemap|Bool|Whether to parse as cubemap|

Return: 

- texData (width/height/format/mipmaps/mipmapCount)解析 KTX 字节数据仓颉侧基于 bgfx4cj.bimg 的 parse_ktx 解析（复用 DDSLoader 的容器提取逻辑）。

