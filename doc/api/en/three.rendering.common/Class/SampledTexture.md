# Class
## class SampledTexture
```cj
public open class SampledTexture <: Sampler
```
Sampled texture class, associating a texture with sampler parameters

### func init\(Texture\)
```cj
public init(texture: Texture)
```
Construct a sampled texture with a texture object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture object|

### func init\(Texture,String\)
```cj
public init(texture: Texture, name: String)
```
Construct a sampled texture with a texture object and name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture objectname Texture name|
|name|String||

### var bindGroupIndex
```cj
public var bindGroupIndex: Int64
```
Bind group index

### var name
```cj
public var name: String
```
Texture name

### var texture
```cj
public var texture: Texture
```
Associated texture object

