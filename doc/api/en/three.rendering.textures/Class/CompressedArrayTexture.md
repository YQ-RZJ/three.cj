# Class
## class CompressedArrayTexture
```cj
public open class CompressedArrayTexture <: CompressedTexture
```
Compressed array texture class

### func copy\(Texture\)
```cj
public override func copy(source: Texture): Texture
```
Copy texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Texture|Source texture|

Return: 

- This instance

### func init\(Array<UInt8>,Int64,Int64,Int64,Int64\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, depth: Int64, format!: Int64 = RGBAFormat)
```
Construct a new compressed array texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Compressed pixel arraywidth Texture width in pixelsheight Texture height in pixelsdepth Layer countformat Pixel format (compressed format enum), defaults to RGBAFormat|
|width|Int64||
|height|Int64||
|depth|Int64||
|format|Int64||

### var wrapR
```cj
public var wrapR: Int64
```
Wrap mode along R dimension (layer dimension), defaults to ClampToEdgeWrapping

