# 类
## class HDRLoader
```cj
public open class HDRLoader <: DataTextureLoader
```
Radiance RGBE HDR 加载器

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


参数: 

|名称|类型|描述|
|---|---|---|
|buffer|Array<UInt8>|.hdr 文件字节|

返回: 

- texData（width/height/data/header/gamma/exposure/type/colorSpace/filters）

### func setDataType\(Int64\)
```cj
public func setDataType(value: Int64): HDRLoader
```


参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64|FloatType 或 HalfFloatType|

返回: 

- 自身引用

### var \`type\`
```cj
public var `type`: Int64
```
输出纹理数据类型（默认 FloatType；JS 默认 HalfFloatType，仓颉侧 DataTexture 用 Float64 字节流承载）

