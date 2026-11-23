# Class
## class MeshMatcapMaterial
```cj
public class MeshMatcapMaterial <: Material
```
Matcap material, rendered using a material capture texture

### func init\(\)
```cj
public init()
```
Construct a new Matcap material

### var bumpMap
```cj
public var bumpMap: Option < Texture >
```
Bump map

### var bumpScale
```cj
public var bumpScale: Float64
```
Bump map scale, default 1

### var map
```cj
public var map: Option < Texture >
```
Diffuse map

### var matcap
```cj
public var matcap: Option < Texture >
```
Material capture texture

### var normalMap
```cj
public var normalMap: Option < Texture >
```
Normal map

### var normalScale
```cj
public var normalScale: Vector2
```
Normal map scale, default (1,1)

