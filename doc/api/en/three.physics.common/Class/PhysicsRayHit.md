# Class
## class PhysicsRayHit
```cj
public class PhysicsRayHit
```
Ray-cast query result (backend-agnostic)

### func init\(\)
```cj
public init()
```
Creates an empty ray-hit result

### var bodyID
```cj
public var bodyID: UInt32 = 0
```
The hit body's BodyID (integer form of the backend's private handle; 0 = invalid)

### var fraction
```cj
public var fraction: Float32 = 0.0f32
```
Hit fraction 0..1 (along the ray direction)

### var normal
```cj
public var normal: Vector3 = Vector3()
```
The hit-surface normal (world space)

### var point
```cj
public var point: Vector3 = Vector3()
```
The hit point in world coordinates

