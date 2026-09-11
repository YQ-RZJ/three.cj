# Class
## class PhysicsCharacterDesc
```cj
public class PhysicsCharacterDesc
```
Character-controller description

### func init\(PhysicsShape,Vector3,Quaternion,UInt32,Float32,Float32\)
```cj
public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion(), layer!: UInt32 = 1, mass!: Float32 = 70.0f32, maxSlopeAngle!: Float32 = 0.7853982f32)
```
Creates a character description

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The collision shapeposition The initial positionrotation The initial rotationlayer The object layermass The mass (kilograms)maxSlopeAngle The maximum standable slope angle (radians)|
|position|Vector3||
|rotation|Quaternion||
|layer|UInt32||
|mass|Float32||
|maxSlopeAngle|Float32||

### var layer
```cj
public var layer: UInt32 = 1
```
The object layer (0 = NonMoving, 1 = Moving)

### var mass
```cj
public var mass: Float32 = 70.0f32
```
The mass (kilograms, used for impulse calculations)

### var maxSlopeAngle
```cj
public var maxSlopeAngle: Float32 = 0.7853982f32
```
The maximum standable slope angle (radians; default PI/4 = 45 deg)

### var position
```cj
public var position: Vector3 = Vector3()
```
The initial position (world space, three left-handed)

### var rotation
```cj
public var rotation: Quaternion = Quaternion()
```
The initial rotation

### let shape
```cj
public let shape: PhysicsShape
```
The character collision shape (usually a capsule)

