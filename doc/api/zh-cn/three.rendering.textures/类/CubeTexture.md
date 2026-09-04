# 类
## class CubeTexture
```cj
public open class CubeTexture <: Texture
```
立方体纹理类

### func init\(Array<Array<UInt8>>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,String\)
```cj
public init(images!: Array < Array < UInt8 >>= Array < Array < UInt8 >>(), mapping!: Int64 = CubeReflectionMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1, colorSpace!: String = "")
```
构造一个新的立方体纹理

参数: 

|名称|类型|描述|
|---|---|---|
|images|Array<Array<UInt8>>|6 面像素数组，按 ±X/±Y/±Z 顺序mapping UV 映射模式，默认 CubeReflectionMappingwrapS 水平环绕模式，默认 ClampToEdgeWrappingwrapT 垂直环绕模式，默认 ClampToEdgeWrappingmagFilter 放大过滤器，默认 LinearFilterminFilter 缩小过滤器，默认 LinearMipmapLinearFilterformat 像素格式，默认 RGBAFormattype 像素数据类型，默认 UnsignedByteTypeanisotropy 各向异性等级，默认 1colorSpace 颜色空间，默认空|
|mapping|Int64||
|wrapS|Int64||
|wrapT|Int64||
|magFilter|Int64||
|minFilter|Int64||
|format|Int64||
|`type`|Int64||
|anisotropy|Int64||
|colorSpace|String||

### var images
```cj
public var images: Array < Array < UInt8 >>
```
6 面像素数组，按 ±X/±Y/±Z 顺序

