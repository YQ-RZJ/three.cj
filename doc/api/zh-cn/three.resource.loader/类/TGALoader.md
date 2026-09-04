# 类
## class TGALoader
```cj
public class TGALoader <: DataTextureLoader
```
TGA 加载器，加载 Targa 格式图片为 DataTexture

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


### func parse\(Array<UInt8>\)
```cj
public override func parse(buffer: Array < UInt8 >): HashMap < String, Any >
```
解析 TGA 字节数据

参数: 

|名称|类型|描述|
|---|---|---|
|buffer|Array<UInt8>|.tga 文件字节|

返回: 

- texData（data=RGBA8/width/height/flipY/generateMipmaps/minFilter）

