# Class
## class PhysicsHeightFieldDesc
```cj
public class PhysicsHeightFieldDesc
```
Height-field terrain description

### func init\(\)
```cj
public init()
```
Creates a height-field description

### var center
```cj
public var center: Vector3 = Vector3(0.0, 0.0, 0.0)
```
Terrain center in world space (center of the height-field plane)

### var friction
```cj
public var friction: Float64 = 0.5
```
Friction coefficient

### var restitution
```cj
public var restitution: Float64 = 0.0
```
Restitution coefficient

### var sampleCount
```cj
public var sampleCount: Int64 = 0
```
Sample count per side (N; grid is N×N)

### var samples
```cj
public var samples: ArrayList < Float64 >= ArrayList < Float64 >()
```
Height samples (row-major: index = y * count + x)

### var sizeX
```cj
public var sizeX: Float64 = 100.0
```
World-space extent along X (meters)

### var sizeZ
```cj
public var sizeZ: Float64 = 100.0
```
World-space extent along Z (meters)

