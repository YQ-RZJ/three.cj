# Class
## class ExternalTexture
```cj
public open class ExternalTexture <: Texture
```
External texture class

### func clone\(\)
```cj
public override func clone(): Texture
```
Return a new external texture instance with the same values as this instance

Return: 

- Cloned external texture instance

### func copy\(Texture\)
```cj
public override func copy(source: Texture): Texture
```
Copy values from the given external texture instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Texture|Source texture|

Return: 

- This instance

### func init\(?TextureHandle\)
```cj
public init(sourceTexture!:?TextureHandle = None)
```
Construct a new external texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sourceTexture|?TextureHandle|External source texture, defaults to None|

### var sourceTexture
```cj
public var sourceTexture: Option < TextureHandle >
```
External texture buffer reference (interpreted by platform in the renderer)

