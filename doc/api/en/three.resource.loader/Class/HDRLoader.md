# Class
## class HDRLoader
```cj
public open class HDRLoader <: DataTextureLoader
```
Radiance RGBE HDR loader

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
|buffer|Array<UInt8>|.hdr file bytes|

Return: 

- texData (width/height/data/header/gamma/exposure/type/colorSpace/filters)解析 RGBE HDR 字节数据

### func setDataType\(Int64\)
```cj
public func setDataType(value: Int64): HDRLoader
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
输出纹理数据类型（默认 FloatType；JS 默认 HalfFloatType，仓颉侧 DataTexture 用 Float64 字节流承载）

