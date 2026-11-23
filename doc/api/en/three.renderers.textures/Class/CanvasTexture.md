# Class
## class CanvasTexture
```cj
public open class CanvasTexture <: Texture
```
Canvas texture class

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64\)
```cj
public init(canvas: Array < UInt8 >, width: Int64, height: Int64, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1)
```
Construct a new Canvas texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|canvas|Array<UInt8>|Pixel memory datawidth Texture width in pixelsheight Texture height in pixelsmapping UV mapping mode, defaults to UVMappingwrapS Horizontal wrap mode, defaults to ClampToEdgeWrappingwrapT Vertical wrap mode, defaults to ClampToEdgeWrappingmagFilter Magnification filter, defaults to LinearFilterminFilter Minification filter, defaults to LinearMipmapLinearFilterformat Pixel format, defaults to RGBAFormattype Pixel data type, defaults to UnsignedByteTypeanisotropy Anisotropy level, defaults to 1|
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
Update texture content, renderer re-uploads to GPU on next frame

