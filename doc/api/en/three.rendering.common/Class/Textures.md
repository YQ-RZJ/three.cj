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

### func getMaxAnisotropy\(\)
```cj
public func getMaxAnisotropy(): Int64
```
Get the maximum anisotropy filtering value

Return: 

- Maximum anisotropy filtering value

### func init\(Backend,Info\)
```cj
public init(backend: Backend, info: Info)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|Backend|Rendering backend instanceinfo Rendering statistics info|
|info|Info||

### func updateTexture\(Texture\)
```cj
public func updateTexture(texture: Texture): Unit
```
Update a texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texture|Texture|Texture object|

### var backend
```cj
public var backend: Backend
```
Rendering backend reference

### var info
```cj
public var info: Info
```
Rendering statistics info

