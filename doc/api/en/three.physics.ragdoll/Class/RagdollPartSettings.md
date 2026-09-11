# Class
## class RagdollPartSettings
```cj
public class RagdollPartSettings
```
Description of a single ragdoll part (a physics body + optional parent joint)

### func init\(PhysicsShape,Vector3,Quaternion,PhysicsMotionType,UInt32,Float32,Option<RagdollJoint>\)
```cj
public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion(), motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, layer!: UInt32 = 1, mass!: Float32 = 0.0f32, toParent!: Option < RagdollJoint >= None)
```
Creates a part description

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The collision shape (PhysicsShape.box/sphere/capsule/...)position The initial positionrotation The initial rotationmotionType The motion typelayer The object layermass The mass (<=0 auto)toParent The parent joint|
|position|Vector3||
|rotation|Quaternion||
|motionType|PhysicsMotionType||
|layer|UInt32||
|mass|Float32||
|toParent|Option<RagdollJoint>||

### var layer
```cj
public var layer: UInt32 = 1
```
Object layer (0=NonMoving, 1=Moving)

### var mass
```cj
public var mass: Float32 = 0.0f32
```
Mass (kg); <=0 means auto-computed from the shape

### var motionType
```cj
public var motionType: PhysicsMotionType = PhysicsMotionType.Dynamic
```
Motion type (ragdoll parts are usually Dynamic)

### var position
```cj
public var position: Vector3 = Vector3()
```
The part initial position (world space, three left-handed)

### var rotation
```cj
public var rotation: Quaternion = Quaternion()
```
The part initial rotation

### let shape
```cj
public let shape: PhysicsShape
```
The part collision shape

### var toParent
```cj
public var toParent: Option < RagdollJoint >= None
```
The joint to the parent part; None for the root part

