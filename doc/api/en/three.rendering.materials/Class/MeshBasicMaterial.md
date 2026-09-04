# Class
## class MeshBasicMaterial
```cj
public class MeshBasicMaterial <: Material
```
Mesh basic material, renders geometry in a simple way (no lighting)

### func copy\(MeshBasicMaterial,Bool\)
```cj
public func copy(source: MeshBasicMaterial, recursive!: Bool = true): MeshBasicMaterial
```
Copy the properties from the given MeshBasicMaterial to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|MeshBasicMaterial|Source materialrecursive Whether to copy recursively|
|recursive|Bool||

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new mesh basic material

### var alphaMap
```cj
public var alphaMap: Option < Texture >
```
Alpha map

### var aoMapIntensity
```cj
public var aoMapIntensity: Float64
```
Ambient occlusion map intensity, default 1

### var aoMap
```cj
public var aoMap: Option < Texture >
```
Ambient occlusion map

### var combine
```cj
public var combine: Int64
```
Environment map and diffuse combination mode

### var lightMapIntensity
```cj
public var lightMapIntensity: Float64
```
Light map intensity, default 1

### var lightMap
```cj
public var lightMap: Option < Texture >
```
Light map

### var map
```cj
public var map: Option < Texture >
```
Diffuse color map

### var reflectivity
```cj
public var reflectivity: Float64
```
Environment map reflectivity, default 1

### var refractionRatio
```cj
public var refractionRatio: Float64
```
Refraction ratio, default 0.98

### var specularMap
```cj
public var specularMap: Option < Texture >
```
Specular highlight map

### var wireframeLinewidth
```cj
public var wireframeLinewidth: Float64
```
Wireframe line width, default 1

