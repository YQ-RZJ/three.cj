# 类
## class CompressedArrayTexture
```cj
public open class CompressedArrayTexture <: CompressedTexture
```
压缩数组纹理类

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

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, depth: Int64, format!: Int64 = RGBAFormat)
```
构造一个新的压缩数组纹理

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|压缩像素数组width 纹理宽度（像素）height 纹理高度（像素）depth 层数量format 像素格式（压缩格式枚举），默认 RGBAFormat|
|width|Int64||
|height|Int64||
|depth|Int64||
|format|Int64||

### var wrapR
```cj
public var wrapR: Int64
```
沿 R 维（层维）的环绕模式，默认 ClampToEdgeWrapping

