# Class
## class MeshDistanceMaterial
```cj
public class MeshDistanceMaterial <: Material
```
Distance material used for point light shadow mapping

### func copy\(MeshDistanceMaterial\)
```cj
public func copy(source: MeshDistanceMaterial): MeshDistanceMaterial
```
Copy the properties from the given MeshDistanceMaterial to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|MeshDistanceMaterial|Source material|

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new mesh distance material

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
Alpha map, grayscale texture controlling surface transparency

### var displacementBias
```cj
public var displacementBias: Float64
```
Displacement map bias, default 0

### var displacementMap
```cj
public var displacementMap: Option < Texture >
```
Displacement map, affects mesh vertex positions

### var displacementScale
```cj
public var displacementScale: Float64
```
Displacement map influence strength, default 1

### var map
```cj
public var map: Option < Texture >
```
Color map

