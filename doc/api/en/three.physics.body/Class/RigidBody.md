# Class
## class RigidBody
```cj
public class RigidBody
```
Convenience wrapper for a physics rigid body

### func addAngularImpulse\(Float64,Float64,Float64\)
```cj
public func addAngularImpulse(x: Float64, y: Float64, z: Float64): RigidBody
```
Applies an angular impulse

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Angular impulse about the X axisy Angular impulse about the Y axisz Angular impulse about the Z axis|
|y|Float64||
|z|Float64||

Return: 

- Returns itself (chainable)

### func addForceAtPosition\(Vector3,Vector3\)
```cj
public func addForceAtPosition(force: Vector3, point: Vector3): RigidBody
```
Applies a force at a specified world position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Vector3|The force vectorpoint The point of application (world coordinates)|
|point|Vector3||

Return: 

- Returns itself (chainable)

### func addForceV\(Vector3\)
```cj
public func addForceV(force: Vector3): RigidBody
```
Applies a force at the center of mass (Vector3)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Vector3|The force vector|

Return: 

- Returns itself (chainable)

### func addForce\(Float64,Float64,Float64\)
```cj
public func addForce(x: Float64, y: Float64, z: Float64): RigidBody
```
Applies a force at the center of mass (Newtons)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Force component along Xy Force component along Yz Force component along Z|
|y|Float64||
|z|Float64||

Return: 

- Returns itself (chainable)

### func addImpulse\(Float64,Float64,Float64\)
```cj
public func addImpulse(x: Float64, y: Float64, z: Float64): RigidBody
```
Applies an impulse at the center of mass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Impulse component along Xy Impulse component along Yz Impulse component along Z|
|y|Float64||
|z|Float64||

Return: 

- Returns itself (chainable)

### func addTorque\(Float64,Float64,Float64\)
```cj
public func addTorque(x: Float64, y: Float64, z: Float64): RigidBody
```
Applies a torque (Newton·meters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Torque about the X axisy Torque about the Y axisz Torque about the Z axis|
|y|Float64||
|z|Float64||

Return: 

- Returns itself (chainable)

### func attach\(Object3D,Bool\)
```cj
public func attach(object3d: Object3D, syncToObj!: Bool = true): RigidBody
```
Creates the body and binds it to a render object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object3d|Object3D|The render object to bindsyncToObj true = physics→render (Dynamic/Kinematic)|
|syncToObj|Bool||

Return: 

- Returns itself (chainable)

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroys the body and unbinds it

### func getAngularVelocity\(\)
```cj
public func getAngularVelocity(): Vector3
```
Gets the angular velocity

Return: 

- The angular velocity (zero vector if not attached)

### func getGravityFactor\(\)
```cj
public func getGravityFactor(): Float64
```
Gets the gravity factor

Return: 

- The gravity factor (1.0 if not attached)

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
Gets the linear velocity

Return: 

- The linear velocity (zero vector if not attached)

### func getMass\(\)
```cj
public func getMass(): Float64
```
Gets the body mass (kilograms)

Return: 

- The body mass (0.0 if not attached)

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
Gets the current position

Return: 

- The current position

### func getRotation\(\)
```cj
public func getRotation(): Quaternion
```
Gets the current rotation

Return: 

- The current rotation quaternion

### func init\(PhysicsWorld,PhysicsShape,PhysicsLayer\)
```cj
public init(world!: PhysicsWorld, shape!: PhysicsShape = PhysicsShape(shapeType: PhysicsShapeType.Box, halfExtent: Vector3(0.5, 0.5, 0.5)), layer!: PhysicsLayer = PhysicsLayer.Moving)
```
Constructs a rigid-body builder

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldshape The initial shape (defaults to Box(0.5,0.5,0.5))layer The physics layer (defaults to Moving)|
|shape|PhysicsShape||
|layer|PhysicsLayer||

### func isActive\(\)
```cj
public func isActive(): Bool
```
Whether the body is active (being simulated)

Return: 

- Whether the body is active

### func moveKinematic\(Vector3,Quaternion,Float32\)
```cj
public func moveKinematic(position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit
```
Moves a kinematic body to the given position/rotation (call every frame)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|position|Vector3|The target positionrotation The target rotationdeltaTime Time since the previous frame (seconds)|
|rotation|Quaternion||
|deltaTime|Float32||

### func setActivation\(PhysicsActivation\)
```cj
public func setActivation(activation: PhysicsActivation): RigidBody
```
Sets the activation policy

Parameter: 

|Name|Type|Describe|
|---|---|---|
|activation|PhysicsActivation|The activation policy|

Return: 

- Returns itself (chainable)

### func setAngularVelocity\(Float64,Float64,Float64\)
```cj
public func setAngularVelocity(x: Float64, y: Float64, z: Float64): RigidBody
```
Sets the angular velocity (world space, radians/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Angular velocity about Xy Angular velocity about Yz Angular velocity about Z|
|y|Float64||
|z|Float64||

Return: 

- Returns itself (chainable)

### func setDynamic\(\)
```cj
public func setDynamic(): RigidBody
```
Marks the body as Dynamic (driven by gravity/collisions)

Return: 

- Returns itself (chainable)

### func setFriction\(Float64\)
```cj
public func setFriction(friction: Float64): RigidBody
```
Sets the friction coefficient (0~1)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|friction|Float64|The friction coefficient|

Return: 

- Returns itself (chainable)

### func setGravityFactor\(Float64\)
```cj
public func setGravityFactor(gravityFactor: Float64): RigidBody
```
Sets the gravity factor (1 = normal gravity, 0 = no gravity)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|gravityFactor|Float64|The gravity factor|

Return: 

- Returns itself (chainable)

### func setKinematic\(\)
```cj
public func setKinematic(): RigidBody
```
Marks the body as Kinematic (user-controlled, unaffected by forces)

Return: 

- Returns itself (chainable)

### func setLayer\(PhysicsLayer\)
```cj
public func setLayer(layer: PhysicsLayer): RigidBody
```
Sets the physics layer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|layer|PhysicsLayer|The physics layer|

Return: 

- Returns itself (chainable)

### func setLinearVelocity\(Float64,Float64,Float64\)
```cj
public func setLinearVelocity(x: Float64, y: Float64, z: Float64): RigidBody
```
Sets the linear velocity (world space, m/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Linear velocity along Xy Linear velocity along Yz Linear velocity along Z|
|y|Float64||
|z|Float64||

Return: 

- Returns itself (chainable)

### func setMass\(Float64\)
```cj
public func setMass(mass: Float64): RigidBody
```
Sets the body mass (kilograms)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mass|Float64|The new mass|

Return: 

- Returns itself (chainable)

### func setMotionTypeRuntime\(PhysicsMotionType,PhysicsActivation\)
```cj
public func setMotionTypeRuntime(motionType: PhysicsMotionType, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Switches the motion type (at runtime)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|motionType|PhysicsMotionType|The new motion typeactivation Activation policy, defaults to Activate|
|activation|PhysicsActivation||

### func setPositionRuntime\(Float64,Float64,Float64,PhysicsActivation\)
```cj
public func setPositionRuntime(x: Float64, y: Float64, z: Float64, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Sets the position (at runtime)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|World X coordinatey World Y coordinatez World Z coordinateactivation Activation policy, defaults to Activate|
|y|Float64||
|z|Float64||
|activation|PhysicsActivation||

### func setPosition\(Float64,Float64,Float64\)
```cj
public func setPosition(x: Float64, y: Float64, z: Float64): RigidBody
```
Sets the initial position (world coordinates)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|World X coordinatey World Y coordinatez World Z coordinate|
|y|Float64||
|z|Float64||

Return: 

- Returns itself (chainable)

### func setRestitution\(Float64\)
```cj
public func setRestitution(restitution: Float64): RigidBody
```
Sets the restitution coefficient (0~1)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|restitution|Float64|The restitution coefficient|

Return: 

- Returns itself (chainable)

### func setRotationEuler\(Float64,Float64,Float64\)
```cj
public func setRotationEuler(x: Float64, y: Float64, z: Float64): RigidBody
```
Sets the initial rotation (Euler angles, in radians)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|Rotation about the X axis (radians)y Rotation about the Y axis (radians)z Rotation about the Z axis (radians)|
|y|Float64||
|z|Float64||

Return: 

- Returns itself (chainable)

### func setRotationRuntime\(Quaternion,PhysicsActivation\)
```cj
public func setRotationRuntime(quat: Quaternion, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Sets the rotation (at runtime)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|quat|Quaternion|The target quaternionactivation Activation policy, defaults to Activate|
|activation|PhysicsActivation||

### func setRotation\(Quaternion\)
```cj
public func setRotation(quat: Quaternion): RigidBody
```
Sets the initial rotation (quaternion)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|quat|Quaternion|The initial quaternion|

Return: 

- Returns itself (chainable)

### func setSensor\(Bool\)
```cj
public func setSensor(sensor: Bool): RigidBody
```
Sets whether the body is a sensor (detects collisions only, no physical response)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sensor|Bool|Whether it is a sensor|

Return: 

- Returns itself (chainable)

### func setShape\(PhysicsShape\)
```cj
public func setShape(shape: PhysicsShape): RigidBody
```
Sets the collision shape

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The new collision shape|

Return: 

- Returns itself (chainable)

### func setStatic\(\)
```cj
public func setStatic(): RigidBody
```
Marks the body as Static (completely immobile, e.g. the ground)

Return: 

- Returns itself (chainable)

### prop attached: Bool
```cj
public prop attached: Bool
```
Whether it has been attached

### prop boundObject: Option < Object3D >
```cj
public prop boundObject: Option < Object3D >
```
Gets the bound render object

### prop handle: PhysicsBodyHandle
```cj
public prop handle: PhysicsBodyHandle
```
Gets the body handle (valid after attach)

### prop isSensor: Bool
```cj
public prop isSensor: Bool
```
Queries whether the body is a sensor

### prop world: PhysicsWorld
```cj
public prop world: PhysicsWorld
```
Gets the owning physics world

