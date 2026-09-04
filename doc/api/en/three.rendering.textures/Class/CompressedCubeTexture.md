# Class
## class CompressedCubeTexture
```cj
public open class CompressedCubeTexture <: CompressedTexture
```
Compressed cube texture class

### func init\(Array<Array<UInt8>>,Int64,Int64,Int64\)
```cj
public init(images: Array < Array < UInt8 >>, width: Int64, height: Int64, format!: Int64 = RGBAFormat)
```
Construct a new compressed cube texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|images|Array<Array<UInt8>>|6-face compressed pixel arrays, in ±X/±Y/±Z orderwidth Single face width in pixelsheight Single face height in pixelsformat Pixel format (compressed format enum), defaults to RGBAFormat|
|width|Int64||
|height|Int64||
|format|Int64||

