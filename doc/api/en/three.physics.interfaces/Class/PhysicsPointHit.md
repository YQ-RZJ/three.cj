# Class
## class PhysicsPointHit
```cj
public class PhysicsPointHit
```
Point-collision query result (collidePoint, backend-agnostic)

### func init\(\)
```cj
public init()
```
Creates an empty point-hit result

### var bodyID
```cj
public var bodyID: UInt32 = 0
```
The hit body's BodyID (0 = invalid)

### var subShapeID
```cj
public var subShapeID: UInt32 = 0
```
The sub-shape ID of the hit shape

