# Class
## class MeshLambertMaterial
```cj
public class MeshLambertMaterial <: Material
```
Lambert material, supporting emissive, environment map, and flatShading

### func init\(\)
```cj
public init()
```
Construct a new Lambert material

### var combine
```cj
public var combine: Int64
```
Environment map and diffuse combination mode

### var emissiveIntensity
```cj
public var emissiveIntensity: Float64
```
Emissive intensity, default 1

### var emissiveMap
```cj
public var emissiveMap: Option < Texture >
```
Emissive map

### var emissive
```cj
public var emissive: Color
```
Emissive color, default 0x000000

### var map
```cj
public var map: Option < Texture >
```
Diffuse map

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

