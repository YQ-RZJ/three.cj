# Class
## class PhysicsSoftBodyDesc
```cj
public class PhysicsSoftBodyDesc
```
Soft body description

### func init\(\)
```cj
public init()
```
Creates a soft-body description

### var bendType
```cj
public var bendType: UInt32 = 0
```
Bend constraint type (0 = none)

### var compliance
```cj
public var compliance: Float64 = 0.00001
```
Edge-constraint compliance (0 = rigid)

### var friction
```cj
public var friction: Float64 = 0.2
```
Friction coefficient

### var gravityFactor
```cj
public var gravityFactor: Float64 = 1.0
```
Gravity factor (1 = normal gravity)

### var indices
```cj
public var indices: ArrayList < UInt32 >= ArrayList < UInt32 >()
```
Triangle indices (groups of 3)

### var layer
```cj
public var layer: PhysicsLayer = PhysicsLayer.Moving
```
Object layer (Moving/Static)

### var linearDamping
```cj
public var linearDamping: Float64 = 0.1
```
Linear damping

### var numIterations
```cj
public var numIterations: UInt32 = 5
```
Solver iteration count

### var pinnedVertices
```cj
public var pinnedVertices: ArrayList < Int64 >= ArrayList < Int64 >()
```
Pinned vertex indices (inverse mass = 0)

### var pressure
```cj
public var pressure: Float64 = 0.0
```
Internal pressure (inflation for closed meshes)

### var restitution
```cj
public var restitution: Float64 = 0.0
```
Restitution coefficient

### var vertexRadius
```cj
public var vertexRadius: Float64 = 0.0
```
Vertex radius (collision thickness)

### var vertices
```cj
public var vertices: ArrayList < Vector3 >= ArrayList < Vector3 >()
```
Vertex positions (world space)

