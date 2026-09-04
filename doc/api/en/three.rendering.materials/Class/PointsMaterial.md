# Class
## class PointsMaterial
```cj
public class PointsMaterial <: Material
```
Points material, used for point cloud rendering, supporting point size and distance attenuation

### func copy\(PointsMaterial,Bool\)
```cj
public func copy(source: PointsMaterial, recursive!: Bool = true): PointsMaterial
```
Copy the values from the given points material instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|PointsMaterial|Source materialrecursive Whether to copy recursively|
|recursive|Bool||

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new points material

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
Alpha map

### var map
```cj
public var map: Option < Texture >
```
Point texture map

### var sizeAttenuation
```cj
public var sizeAttenuation: Bool
```
Whether to attenuate with distance, default true

### var size
```cj
public var size: Float64
```
Point size, default 1

