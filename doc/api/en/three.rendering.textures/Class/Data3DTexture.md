# Class
## class Data3DTexture
```cj
public open class Data3DTexture <: Texture
```
Data 3D texture class

### func init\(Array<UInt8>,Int64,Int64,Int64\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, depth: Int64)
```
Construct a new 3D data texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Pixel arraywidth Texture width in pixelsheight Texture height in pixelsdepth Layer count|
|width|Int64||
|height|Int64||
|depth|Int64||

### var wrapR
```cj
public var wrapR: Int64
```
Wrap mode along R dimension (layer dimension), defaults to ClampToEdgeWrapping

