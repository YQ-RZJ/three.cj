# Class
## class DataTexture
```cj
public open class DataTexture <: Texture
```
Data texture class

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,String\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = NearestFilter, minFilter!: Int64 = NearestFilter, anisotropy!: Int64 = 1, colorSpace!: String = "")
```
Construct a new data texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Pixel arraywidth Texture width in pixelsheight Texture height in pixelsformat Pixel format, defaults to RGBAFormattype Pixel data type, defaults to UnsignedByteTypemapping UV mapping mode, defaults to UVMappingwrapS Horizontal wrap mode, defaults to ClampToEdgeWrappingwrapT Vertical wrap mode, defaults to ClampToEdgeWrappingmagFilter Magnification filter, defaults to NearestFilterminFilter Minification filter, defaults to NearestFilteranisotropy Anisotropy level, defaults to 1colorSpace Color space, defaults to empty|
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

