# Class
## class Textures
```cj
public open class Textures <: DataMap
```
Textures management class

### func createSampler\(Sampler\)
```cj
public func createSampler(sampler: Sampler): Unit
```
Create a sampler

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sampler|Sampler|Sampler object|

### func createTexture\(Texture\)
```cj
public func createTexture(texture: Texture): Unit
```
Create a texture, incrementing the texture memory count

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture object|

### func destroyTexture\(Texture\)
```cj
public func destroyTexture(texture: Texture): Unit
```
Destroy a texture, decrementing the texture memory count

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture object|

### func init\(Info\)
```cj
public init(info: Info)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|Info|renderers statistics info|

### func updateTexture\(Texture\)
```cj
public func updateTexture(texture: Texture): Unit
```
Update a texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture object|

### var info
```cj
public var info: Info
```
renderers statistics info

