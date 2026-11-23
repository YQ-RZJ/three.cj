# Class
## class PhysicsBodyDesc
```cj
public class PhysicsBodyDesc
```
Rigid-body creation description (backend-agnostic)

### func init\(PhysicsShape,Vector3,Quaternion,PhysicsMotionType,PhysicsLayer,PhysicsActivation,Float64,Float64,Bool,Float64,Float64,Float64,Float64,Bool\)
```cj
public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion(), motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, layer!: PhysicsLayer = PhysicsLayer.Moving, activation!: PhysicsActivation = PhysicsActivation.Activate, friction!: Float64 = 0.2, restitution!: Float64 = 0.0, autoSync!: Bool = true, mass!: Float64 = - 1.0, gravityFactor!: Float64 = 1.0, linearDamping!: Float64 = 0.05, angularDamping!: Float64 = 0.05, isSensor!: Bool = false)
```
Creates a rigid-body description

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The collision shapeposition The initial position; origin by defaultrotation The initial rotation; identity by defaultmotionType The motion type; Dynamic by defaultlayer The physics layer; Moving by defaultactivation The activation strategy; Activate by defaultfriction The friction coefficient; 0.2 by defaultrestitution The restitution coefficient; 0 by defaultautoSync Whether to auto-sync the transform; true by defaultmass The mass; -1 by default (computed automatically)gravityFactor The gravity factor; 1 by defaultlinearDamping The linear damping; 0.05 by defaultangularDamping The angular damping; 0.05 by defaultisSensor Whether this is a sensor; false by default|
|position|Vector3||
|rotation|Quaternion||
|motionType|PhysicsMotionType||
|layer|PhysicsLayer||
|activation|PhysicsActivation||
|friction|Float64||
|restitution|Float64||
|autoSync|Bool||
|mass|Float64||
|gravityFactor|Float64||
|linearDamping|Float64||
|angularDamping|Float64||
|isSensor|Bool||

### var activation
```cj
public var activation: PhysicsActivation
```
The activation strategy

### var angularDamping
```cj
public var angularDamping: Float64
```
Angular damping (default 0.05)

### var autoSync
```cj
public var autoSync: Bool
```
Whether to auto-sync the transform to the bound Object3D

### var friction
```cj
public var friction: Float64
```
Friction coefficient (0~1, default 0.2)

### var gravityFactor
```cj
public var gravityFactor: Float64
```
Gravity factor (1 = normal gravity, 0 = no gravity, default 1)

### var isSensor
```cj
public var isSensor: Bool
```
Whether this is a sensor body (collision-only, no physical response; default false)

### var layer
```cj
public var layer: PhysicsLayer
```
The physics layer (collision grouping)

### var linearDamping
```cj
public var linearDamping: Float64
```
Linear damping (default 0.05)

### var mass
```cj
public var mass: Float64
```
Mass (kilograms; <= 0 lets the backend compute it from the shape, default -1 = automatic)

### var motionType
```cj
public var motionType: PhysicsMotionType
```
The motion type

### var position
```cj
public var position: Vector3
```
The initial position (world coordinates)

### var restitution
```cj
public var restitution: Float64
```
Restitution coefficient (0~1, default 0)

### var rotation
```cj
public var rotation: Quaternion
```
The initial rotation (quaternion; identity = no rotation)

### var shape
```cj
public var shape: PhysicsShape
```
The collision shape

