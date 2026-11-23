# 类
## class CanvasTexture
```cj
public open class CanvasTexture <: Texture
```
Canvas 纹理类

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64\)
```cj
public init(canvas: Array < UInt8 >, width: Int64, height: Int64, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1)
```
构造一个新的 Canvas 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|canvas|Array<UInt8>|像素内存数据width 纹理宽度（像素）height 纹理高度（像素）mapping UV 映射模式，默认 UVMappingwrapS 水平环绕模式，默认 ClampToEdgeWrappingwrapT 垂直环绕模式，默认 ClampToEdgeWrappingmagFilter 放大过滤器，默认 LinearFilterminFilter 缩小过滤器，默认 LinearMipmapLinearFilterformat 像素格式，默认 RGBAFormattype 像素数据类型，默认 UnsignedByteTypeanisotropy 各向异性等级，默认 1|
|width|Int64||
|height|Int64||
|mapping|Int64||
|wrapS|Int64||
|wrapT|Int64||
|magFilter|Int64||
|minFilter|Int64||
|format|Int64||
|`type`|Int64||
|anisotropy|Int64||

### func update\(\)
```cj
public func update(): Unit
```
更新纹理内容，渲染器下一帧重传 GPU

