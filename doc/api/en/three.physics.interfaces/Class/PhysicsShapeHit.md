# Class
## class PhysicsShapeHit
```cj
public class PhysicsShapeHit
```
Shape-collision/cast query result (collideShape/castShape, backend-agnostic)

### func init\(\)
```cj
public init()
```
Creates an empty shape-hit result

### var bodyID
```cj
public var bodyID: UInt32 = 0
```
The hit body's BodyID (0 = invalid)

### var fraction
```cj
public var fraction: Float32 = 0.0f32
```
Hit fraction 0..1 (castShape only; 0 for collideShape)

### var isBackFaceHit
```cj
public var isBackFaceHit: Bool = false
```
Whether the hit is on the back face (castShape only)

### var normal
```cj
public var normal: Vector3 = Vector3()
```
Penetration-axis direction (from the hit body toward the query shape)

### var penetrationDepth
```cj
public var penetrationDepth: Float32 = 0.0f32
```
Penetration depth (valid for collideShape)

### var point
```cj
public var point: Vector3 = Vector3()
```
Contact point (on the query shape's surface, world coordinates)

### var subShapeID1
```cj
public var subShapeID1: UInt32 = 0
```
The query shape's sub-shape ID

### var subShapeID2
```cj
public var subShapeID2: UInt32 = 0
```
The hit shape's sub-shape ID

