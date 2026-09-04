# Class
## class SpriteMaterial
```cj
public class SpriteMaterial <: Material
```
Sprite material, used for sprite rendering, supporting size attenuation and UV rotation

### func copy\(SpriteMaterial,Bool\)
```cj
public func copy(source: SpriteMaterial, recursive!: Bool = true): SpriteMaterial
```
Copy the values from the given sprite material instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|SpriteMaterial|Source materialrecursive Whether to copy recursively|
|recursive|Bool||

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new sprite material

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
Alpha map

### var map
```cj
public var map: Option < Texture >
```
Sprite texture map

### var rotation
```cj
public var rotation: Float64
```
UV rotation in radians, default 0

### var sizeAttenuation
```cj
public var sizeAttenuation: Bool
```
Whether to attenuate size with distance, default true

