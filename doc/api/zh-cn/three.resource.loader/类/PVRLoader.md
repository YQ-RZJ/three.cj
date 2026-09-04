# 类
## class PVRLoader
```cj
public class PVRLoader <: CompressedTextureLoader
```
PVR 压缩纹理加载器

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
解析 PVR 字节数据

参数: 

|名称|类型|描述|
|---|---|---|
|buffer|Array<UInt8>|PVR 文件字节isCubemap 是否按立方体贴图解析|
|isCubemap|Bool||

返回: 

- texData（width/height/format/mipmaps/mipmapCount）

