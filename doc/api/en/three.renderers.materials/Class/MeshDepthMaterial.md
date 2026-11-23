# Class
## class MeshDepthMaterial
```cj
public class MeshDepthMaterial <: Material
```
Material that renders geometry based on depth

### func copy\(MeshDepthMaterial\)
```cj
public func copy(source: MeshDepthMaterial): MeshDepthMaterial
```
Copy the properties from the given MeshDepthMaterial to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|MeshDepthMaterial|Source material|

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new mesh depth material

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
Alpha map, grayscale texture controlling surface transparency

### var depthPacking
```cj
public var depthPacking: Int64
```
Depth packing type, default BasicDepthPacking

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

### var wireframeLinewidth
```cj
public var wireframeLinewidth: Float64
```
Wireframe line width, default 1

