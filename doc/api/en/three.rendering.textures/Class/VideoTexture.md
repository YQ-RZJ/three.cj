# Class
## class VideoTexture
```cj
public open class VideoTexture <: Texture
```
Video texture class

### func clone\(\)
```cj
public open override func clone(): Texture
```
Return a new Video texture instance with the same values as this instance

Return: 

- Cloned Video texture instance

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Release GPU-related resources allocated by this instance

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64,Int64,Int64,Int64,Int64\)
```cj
public init(video: Array < UInt8 >, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1)
```
Construct a new Video texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|video|Array<UInt8>|Video pixel datamapping UV mapping mode, defaults to UVMappingwrapS Horizontal wrap mode, defaults to ClampToEdgeWrappingwrapT Vertical wrap mode, defaults to ClampToEdgeWrappingmagFilter Magnification filter, defaults to LinearFilterminFilter Minification filter, defaults to LinearFilterformat Pixel format, defaults to RGBAFormattype Pixel data type, defaults to UnsignedByteTypeanisotropy Anisotropy level, defaults to 1|
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
Update texture content, stub under bgfx4cj (pixel data passed directly by callers via image field)

