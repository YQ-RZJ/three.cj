# Class
## class MeshNormalMaterial
```cj
public class MeshNormalMaterial <: Material
```
Normal material, renders normal vectors as RGB colors

### func init\(\)
```cj
public init()
```
Construct a new normal material

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

### var displacementBias
```cj
public var displacementBias: Float64
```
Displacement map bias, default 0

### var displacementMap
```cj
public var displacementMap: Option < Texture >
```
Displacement map

### var displacementScale
```cj
public var displacementScale: Float64
```
Displacement map scale, default 1

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

