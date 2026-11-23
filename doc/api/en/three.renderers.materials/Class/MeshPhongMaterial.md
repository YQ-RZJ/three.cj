# Class
## class MeshPhongMaterial
```cj
public class MeshPhongMaterial <: Material
```
Phong material, supporting specular highlights and shininess

### func init\(\)
```cj
public init()
```
Construct a new Phong material

### var combine
```cj
public var combine: Int64
```
Environment map and diffuse combination mode

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

### var shininess
```cj
public var shininess: Float64
```
Shininess, default 30

### var specularMap
```cj
public var specularMap: Option < Texture >
```
Specular highlight map

### var specular
```cj
public var specular: Color
```
Specular highlight color, default 0x111111

