# 类
## class CompressedCubeTexture
```cj
public open class CompressedCubeTexture <: CompressedTexture
```
压缩立方体纹理类

### func init\(Array<Array<UInt8>>,Int64,Int64,Int64\)
```cj
public init(images: Array < Array < UInt8 >>, width: Int64, height: Int64, format!: Int64 = RGBAFormat)
```
构造一个新的压缩立方体纹理

参数: 

|名称|类型|描述|
|---|---|---|
|images|Array<Array<UInt8>>|6 面压缩像素数组，按 ±X/±Y/±Z 顺序width 单面宽度（像素）height 单面高度（像素）format 像素格式（压缩格式枚举），默认 RGBAFormat|
|width|Int64||
|height|Int64||
|format|Int64||

