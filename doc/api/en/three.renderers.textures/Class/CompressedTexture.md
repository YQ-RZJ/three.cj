# Class
## class CompressedTexture
```cj
public open class CompressedTexture <: Texture
```
Compressed texture class

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,String\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, anisotropy!: Int64 = 1, colorSpace!: String = "")
```
Construct a new compressed texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Compressed pixel arraywidth Texture width in pixelsheight Texture height in pixelsformat Pixel format (compressed format enum), defaults to RGBAFormattype Pixel data type, defaults to UnsignedByteTypemapping UV mapping mode, defaults to UVMappingwrapS Horizontal wrap mode, defaults to ClampToEdgeWrappingwrapT Vertical wrap mode, defaults to ClampToEdgeWrappingmagFilter Magnification filter, defaults to LinearFilterminFilter Minification filter, defaults to LinearMipmapLinearFilteranisotropy Anisotropy level, defaults to 1colorSpace Color space, defaults to empty|
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

