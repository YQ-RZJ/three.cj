# 类
## class DataArrayTexture
```cj
public open class DataArrayTexture <: Texture
```
数据数组纹理类

### func copy\(Texture\)
```cj
public override func copy(source: Texture): Texture
```
拷贝纹理

参数: 

|名称|类型|描述|
|---|---|---|
|source|Texture|源纹理|

返回: 

- 当前实例

### func init\(Array<UInt8>,Int64,Int64,Int64\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, depth: Int64)
```
构造一个新的数据数组纹理

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|像素数组width 纹理宽度（像素）height 纹理高度（像素）depth 层数量|
|width|Int64||
|height|Int64||
|depth|Int64||

### var wrapR
```cj
public var wrapR: Int64
```
沿 R 维（层维）的环绕模式，默认 ClampToEdgeWrapping

