# Class
## class EXRLoader
```cj
public class EXRLoader <: DataTextureLoader
```
EXR loader, loads OpenEXR format HDR textures

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


### func parse\(Array<UInt8>\)
```cj
public override func parse(buffer: Array < UInt8 >): HashMap < String, Any >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|Array<UInt8>|.exr file bytes|

Return: 

- texData (width/height/data/type), returns empty HashMap on parse failure解析 EXR 字节数据仓颉侧基于 bgfx4cj.tinyexr：ParseEXRHeaderFromMemory_cj 解析头 → 请求 FLOAT 像素类型 →LoadEXRImageFromMemory_cj 加载图像 → 各 planar 通道交织为 RGBA → Free* 释放。

### func setDataType\(Int64\)
```cj
public func setDataType(value: Int64): EXRLoader
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|FloatType or HalfFloatType|

Return: 

- Self reference设置纹理数据类型

### var \`type\`
```cj
public var `type`: Int64
```
输出数据类型（默认 FloatType；JS 侧支持 FloatType/HalfFloatType）

