# 类
## class DataTexture
```cj
public open class DataTexture <: Texture
```
数据纹理类

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,String\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = NearestFilter, minFilter!: Int64 = NearestFilter, anisotropy!: Int64 = 1, colorSpace!: String = "")
```
构造一个新的数据纹理

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|像素数组width 纹理宽度（像素）height 纹理高度（像素）format 像素格式，默认 RGBAFormattype 像素数据类型，默认 UnsignedByteTypemapping UV 映射模式，默认 UVMappingwrapS 水平环绕模式，默认 ClampToEdgeWrappingwrapT 垂直环绕模式，默认 ClampToEdgeWrappingmagFilter 放大过滤器，默认 NearestFilterminFilter 缩小过滤器，默认 NearestFilteranisotropy 各向异性等级，默认 1colorSpace 颜色空间，默认空|
|width|Int64||
|height|Int64||
|format|Int64||
|`type`|Int64||
|mapping|Int64||
|wrapS|Int64||
|wrapT|Int64||
|magFilter|Int64||
|minFilter|Int64||
|anisotropy|Int64||
|colorSpace|String||

