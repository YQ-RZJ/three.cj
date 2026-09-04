# Class
## class DepthTexture
```cj
public open class DepthTexture <: Texture
```
Depth texture class

### func copy\(Texture\)
```cj
public override func copy(source: Texture): Texture
```
Copy values from the given depth texture instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Texture|Source texture|

Return: 

- This instance

### func init\(Int64,Int64,Int64\)
```cj
public init(width: Int64, height: Int64, `type`!: Int64 = UnsignedIntType)
```
Construct a new depth texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Texture width in pixelsheight Texture height in pixelstype Pixel data type, defaults to UnsignedIntType|
|height|Int64||
|`type`|Int64||

### var compareFunction
```cj
public var compareFunction: Option < Int64 >
```
Depth comparison function (WebGL compareFunction), None means no comparison

