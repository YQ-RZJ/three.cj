# 类
## class MeshPhysicalMaterial
```cj
public class MeshPhysicalMaterial <: Material
```
物理材质，在Standard材质基础上增加清漆、透射等高级PBR属性

### func init\(\)
```cj
public init()
```
构造一个新的物理材质

### var clearcoatRoughness
```cj
public var clearcoatRoughness: Float64
```
清漆层粗糙度，默认0

### var clearcoat
```cj
public var clearcoat: Float64
```
清漆层强度，默认0

### var ior
```cj
public var ior: Float64
```
折射率，默认1.5

### var metalness
```cj
public var metalness: Float64
```
金属度，默认0

### var roughness
```cj
public var roughness: Float64
```
粗糙度，默认1

### var sheen
```cj
public var sheen: Float64
```
光泽强度，默认0

### var thickness
```cj
public var thickness: Float64
```
厚度，默认0

### var transmission
```cj
public var transmission: Float64
```
透射率，默认0

