# 类
## class EXRLoader
```cj
public class EXRLoader <: DataTextureLoader
```
EXR 加载器，加载 OpenEXR 格式的 HDR 纹理

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
|buffer|Array<UInt8>|.exr 文件字节|

返回: 

- texData（width/height/data/type），解析失败返回空 HashMap

### func setDataType\(Int64\)
```cj
public func setDataType(value: Int64): EXRLoader
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
输出数据类型（默认 FloatType；JS 侧支持 FloatType/HalfFloatType）

