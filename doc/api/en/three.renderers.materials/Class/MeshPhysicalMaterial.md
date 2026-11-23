# Class
## class MeshPhysicalMaterial
```cj
public class MeshPhysicalMaterial <: Material
```
Physical material, extending Standard material with advanced PBR properties like clearcoat and transmission

### func init\(\)
```cj
public init()
```
Construct a new physical material

### var clearcoatRoughness
```cj
public var clearcoatRoughness: Float64
```
Clearcoat roughness, default 0

### var clearcoat
```cj
public var clearcoat: Float64
```
Clearcoat intensity, default 0

### var ior
```cj
public var ior: Float64
```
Index of refraction, default 1.5

### var metalness
```cj
public var metalness: Float64
```
Metalness, default 0

### var roughness
```cj
public var roughness: Float64
```
Roughness, default 1

### var sheen
```cj
public var sheen: Float64
```
Sheen intensity, default 0

### var thickness
```cj
public var thickness: Float64
```
Thickness, default 0

### var transmission
```cj
public var transmission: Float64
```
Transmission rate, default 0

