# Class
## class CubeTexture
```cj
public open class CubeTexture <: Texture
```
Cube texture class

### func init\(Array<Array<UInt8>>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,String\)
```cj
public init(images!: Array < Array < UInt8 >>= Array < Array < UInt8 >>(), mapping!: Int64 = CubeReflectionMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1, colorSpace!: String = "")
```
Construct a new cube texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|images|Array<Array<UInt8>>|6-face pixel arrays, in ±X/±Y/±Z ordermapping UV mapping mode, defaults to CubeReflectionMappingwrapS Horizontal wrap mode, defaults to ClampToEdgeWrappingwrapT Vertical wrap mode, defaults to ClampToEdgeWrappingmagFilter Magnification filter, defaults to LinearFilterminFilter Minification filter, defaults to LinearMipmapLinearFilterformat Pixel format, defaults to RGBAFormattype Pixel data type, defaults to UnsignedByteTypeanisotropy Anisotropy level, defaults to 1colorSpace Color space, defaults to empty|
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
6-face pixel arrays, in ±X/±Y/±Z order

