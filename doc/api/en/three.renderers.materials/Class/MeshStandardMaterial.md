# Class
## class MeshStandardMaterial
```cj
public class MeshStandardMaterial <: Material
```
Standard PBR material, supporting metalness/roughness workflow

### func init\(\)
```cj
public init()
```
Construct a new standard PBR material

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
Ambient occlusion map (red channel, requires second UV set)

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

### var displacementScale
```cj
public var displacementScale: Float64
```
Displacement map scale, default 1

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

### var lightMapIntensity
```cj
public var lightMapIntensity: Float64
```
Light map intensity, default 1

### var lightMap
```cj
public var lightMap: Option < Texture >
```
Light map (requires second UV set)

### var map
```cj
public var map: Option < Texture >
```
Diffuse color map

### var metalnessMap
```cj
public var metalnessMap: Option < Texture >
```
Metalness map (blue channel)

### var metalness
```cj
public var metalness: Float64
```
Metalness, default 0

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

### var roughnessMap
```cj
public var roughnessMap: Option < Texture >
```
Roughness map (green channel)

### var roughness
```cj
public var roughness: Float64
```
Roughness, default 1

