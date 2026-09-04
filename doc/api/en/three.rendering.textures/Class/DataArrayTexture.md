# Class
## class DataArrayTexture
```cj
public open class DataArrayTexture <: Texture
```
Data array texture class

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

### func init\(Array<UInt8>,Int64,Int64,Int64\)
```cj
public init(data: Array < UInt8 >, width: Int64, height: Int64, depth: Int64)
```
Construct a new data array texture

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

