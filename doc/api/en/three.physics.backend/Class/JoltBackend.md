# Class
## class JoltBackend
```cj
public class JoltBackend <: IPhysicsBackend
```
JoltPhysics backend implementation of IPhysicsBackend

### func addAngularImpulse\(PhysicsBodyHandle,Vector3\)
```cj
public func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit
```
Applies an angular impulse to the body

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handleangularImpulse Angular impulse (pseudo-vector, three left-handed coordinates)|
|angularImpulse|Vector3||

### func addForceAtPosition\(PhysicsBodyHandle,Vector3,Vector3\)
```cj
public func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit
```
Applies a force to the body at the specified point

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handleforce Applied force (three left-handed coordinates)point Application point (body local space, three left-handed coordinates)|
|force|Vector3||
|point|Vector3||

### func addForce\(PhysicsBodyHandle,Vector3\)
```cj
public func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit
```
Applies a force to the body (linear)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handleforce Applied force (three left-handed coordinates)|
|force|Vector3||

### func addImpulse\(PhysicsBodyHandle,Vector3\)
```cj
public func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit
```
Applies a linear impulse to the body (instant change of linear velocity)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handleimpulse Applied impulse (three left-handed coordinates)|
|impulse|Vector3||

### func addTorque\(PhysicsBodyHandle,Vector3\)
```cj
public func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit
```
Applies a torque to the body (pseudo-vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handletorque Applied torque (three left-handed coordinates)|
|torque|Vector3||

### func backendName\(\)
```cj
public func backendName(): String
```
Returns the backend name

Return: 

- Backend name string

### func castShape\(PhysicsShape,Vector3,Quaternion,Vector3,ArrayList<PhysicsShapeHit>\)
```cj
public func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, direction: Vector3, hits: ArrayList < PhysicsShapeHit >): Int64
```
Sweeps a shape along a direction and returns all shapes hit along the way (shape cast)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|Shape description to castposition Start position (three left-handed coordinates)rotation Shape rotation (three left-handed coordinates)direction Cast direction (three left-handed coordinates, need not be normalized)hits List receiving the hit results (cleared then filled)|
|position|Vector3||
|rotation|Quaternion||
|direction|Vector3||
|hits|ArrayList<PhysicsShapeHit>||

Return: 

- Number of hits

### func collidePoint\(Vector3,ArrayList<PhysicsPointHit>\)
```cj
public func collidePoint(point: Vector3, hits: ArrayList < PhysicsPointHit >): Int64
```
Finds all shapes overlapping a given point (point collision)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|Query point (three left-handed coordinates)hits List receiving the hit results (cleared then filled)|
|hits|ArrayList<PhysicsPointHit>||

Return: 

- Number of hits

### func collideShape\(PhysicsShape,Vector3,Quaternion,ArrayList<PhysicsShapeHit>\)
```cj
public func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, hits: ArrayList < PhysicsShapeHit >): Int64
```
Finds shapes in the world overlapping a shape at the given pose (shape collision)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|Query shape descriptionposition Shape position (three left-handed coordinates)rotation Shape rotation (three left-handed coordinates)hits List receiving the hit results (cleared then filled)|
|position|Vector3||
|rotation|Quaternion||
|hits|ArrayList<PhysicsShapeHit>||

Return: 

- Number of hits

### func createBody\(PhysicsBodyDesc\)
```cj
public func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle
```
Creates a body from the description and adds it to the world

Parameter: 

|Name|Type|Describe|
|---|---|---|
|desc|PhysicsBodyDesc|Body description (shape, mass, motion type, layer, initial pose, etc.)|

Return: 

- Body handle; PhysicsBodyHandle.INVALID on failure

### func createConstraint\(PhysicsConstraintDesc,PhysicsBodyHandle,PhysicsBodyHandle\)
```cj
public func createConstraint(desc: PhysicsConstraintDesc, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraintHandle
```
Creates a constraint between two bodies and adds it to the world

Parameter: 

|Name|Type|Describe|
|---|---|---|
|desc|PhysicsConstraintDesc|Constraint description (type, space, anchors, axes, limits, etc.)bodyA Body A handlebodyB Body B handle|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||

Return: 

- Constraint handle; PhysicsConstraintHandle.INVALID on failure

### func destroyBody\(PhysicsBodyHandle\)
```cj
public func destroyBody(handle: PhysicsBodyHandle): Unit
```
Removes and destroys the body from the world, releasing its shape handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

### func destroyConstraint\(PhysicsConstraintHandle\)
```cj
public func destroyConstraint(handle: PhysicsConstraintHandle): Unit
```
Removes and destroys the constraint from the world

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|Constraint handle|

### func getAngularVelocity\(PhysicsBodyHandle\)
```cj
public func getAngularVelocity(handle: PhysicsBodyHandle): Vector3
```
Gets the body angular velocity (pseudo-vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Angular velocity (three left-handed coordinates)

### func getFriction\(PhysicsBodyHandle\)
```cj
public func getFriction(handle: PhysicsBodyHandle): Float64
```
Gets the body friction coefficient

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Friction coefficient

### func getGravityFactor\(PhysicsBodyHandle\)
```cj
public func getGravityFactor(handle: PhysicsBodyHandle): Float64
```
Gets the body gravity factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Gravity factor (1.0 is normal gravity, 0.0 is weightless)

### func getInverseInertia\(PhysicsBodyHandle\)
```cj
public func getInverseInertia(handle: PhysicsBodyHandle): Matrix4
```
Gets the body inverse inertia tensor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Inverse inertia tensor (Matrix4 top-left 3x3, three left-handed coordinates)

### func getLinearVelocity\(PhysicsBodyHandle\)
```cj
public func getLinearVelocity(handle: PhysicsBodyHandle): Vector3
```
Gets the body linear velocity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Linear velocity (three left-handed coordinates)

### func getMass\(PhysicsBodyHandle\)
```cj
public func getMass(handle: PhysicsBodyHandle): Float64
```
Gets the body mass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Mass in kg; 0.0 for invalid handles or when unset

### func getMotionType\(PhysicsBodyHandle\)
```cj
public func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType
```
Gets the body motion type (static/kinematic/dynamic)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Motion type

### func getObjectLayer\(PhysicsBodyHandle\)
```cj
public func getObjectLayer(handle: PhysicsBodyHandle): PhysicsLayer
```
Gets the object layer of the body (determines collision filtering)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Object layer (NonMoving/Moving)

### func getPosition\(PhysicsBodyHandle\)
```cj
public func getPosition(handle: PhysicsBodyHandle): Vector3
```
Gets the body world position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- World position (three left-handed coordinates)

### func getRestitution\(PhysicsBodyHandle\)
```cj
public func getRestitution(handle: PhysicsBodyHandle): Float64
```
Gets the body restitution coefficient (bounciness)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Restitution coefficient

### func getRotation\(PhysicsBodyHandle\)
```cj
public func getRotation(handle: PhysicsBodyHandle): Quaternion
```
Gets the body rotation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Rotation quaternion (three left-handed coordinates)

### func init\(\)
```cj
public init()
```
Creates a Jolt backend instance (not yet initialized; call initialize)

### func initialize\(UInt32,Vector3\)
```cj
public func initialize(maxBodies: UInt32, gravity: Vector3): Bool
```
Initializes the physics system (creates the Jolt physics system, job system, collision filtering and listeners)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maxBodies|UInt32|Maximum number of bodies the system supportsgravity Initial gravity vector (three left-handed coordinates)|
|gravity|Vector3||

Return: 

- Returns true on success

### func isBodyActive\(PhysicsBodyHandle\)
```cj
public func isBodyActive(handle: PhysicsBodyHandle): Bool
```
Returns whether the body is active (being simulated)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handle|

Return: 

- Returns true if active

### func isConstraintEnabled\(PhysicsConstraintHandle\)
```cj
public func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool
```
Returns whether the constraint is enabled

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|Constraint handle|

Return: 

- Returns true if enabled

### func isInitialized\(\)
```cj
public func isInitialized(): Bool
```
Returns whether the physics system has been initialized

Return: 

- Returns true if initialized

### func moveKinematic\(PhysicsBodyHandle,Vector3,Quaternion,Float32\)
```cj
public func moveKinematic(handle: PhysicsBodyHandle, position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit
```
Moves a kinematic body to the given pose (interpolated by the physics system; call before update)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handleposition Target position (three left-handed coordinates)rotation Target rotation (three left-handed coordinates)deltaTime Time step of this frame (seconds)|
|position|Vector3||
|rotation|Quaternion||
|deltaTime|Float32||

### func optimizeBroadPhase\(\)
```cj
public func optimizeBroadPhase(): Unit
```
Optimizes the broad phase structure (call after dynamic bodies move to improve query performance)

### func raycastAll\(Vector3,Vector3,ArrayList<PhysicsRayHit>\)
```cj
public func raycastAll(origin: Vector3, direction: Vector3, hits: ArrayList < PhysicsRayHit >): Int64
```
Casts a batch ray and returns all hits sorted by distance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|Ray origin (three left-handed coordinates)direction Ray direction (three left-handed coordinates)hits List receiving the hit results (cleared then filled)|
|direction|Vector3||
|hits|ArrayList<PhysicsRayHit>||

Return: 

- Number of hits

### func raycast\(Vector3,Vector3,PhysicsRayHit\)
```cj
public func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool
```
Casts a single ray and returns the closest hit

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|Ray origin (three left-handed coordinates)direction Ray direction (three left-handed coordinates, need not be normalized)hit Hit result container (filled with bodyID/fraction/point/normal on hit)|
|direction|Vector3||
|hit|PhysicsRayHit||

Return: 

- Whether the ray hit anything

### func setAngularVelocity\(PhysicsBodyHandle,Vector3\)
```cj
public func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit
```
Sets the body angular velocity (pseudo-vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handleangularVelocity Angular velocity (three left-handed coordinates)|
|angularVelocity|Vector3||

### func setConstraintEnabled\(PhysicsConstraintHandle,Bool\)
```cj
public func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit
```
Enables or disables the constraint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|Constraint handleenabled Whether to enable the constraint|
|enabled|Bool||

### func setContactListener\(Option<IPhysicsSensorListener>\)
```cj
public func setContactListener(listener: Option < IPhysicsSensorListener >): Unit
```
Registers a collision event listener (contact/activation/deactivation callbacks)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|listener|Option<IPhysicsSensorListener>|Sensor listener; pass None to unregister|

### func setFriction\(PhysicsBodyHandle,Float64\)
```cj
public func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit
```
Sets the body friction coefficient

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handlefriction Friction coefficient (0.0 for no friction)|
|friction|Float64||

### func setGravityFactor\(PhysicsBodyHandle,Float64\)
```cj
public func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit
```
Sets the body gravity factor (scales the gravity applied to the body)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handlegravityFactor Gravity factor (1.0 is normal gravity, 0.0 is weightless)|
|gravityFactor|Float64||

### func setGravity\(Vector3\)
```cj
public func setGravity(gravity: Vector3): Unit
```
Sets the world gravity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|gravity|Vector3|Gravity vector (three left-handed coordinates)|

### func setIsSensor\(PhysicsBodyHandle,Bool\)
```cj
public func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit
```
Sets whether the body acts as a sensor (detects collisions only, produces no physical response)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handleisSensor Whether to act as a sensor|
|isSensor|Bool||

### func setLinearVelocity\(PhysicsBodyHandle,Vector3\)
```cj
public func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit
```
Sets the body linear velocity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handlevelocity Linear velocity (three left-handed coordinates)|
|velocity|Vector3||

### func setMass\(PhysicsBodyHandle,Float64\)
```cj
public func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit
```
Sets the body mass (dynamic bodies)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handlemass Mass in kilograms (must be greater than 0)|
|mass|Float64||

### func setMotionType\(PhysicsBodyHandle,PhysicsMotionType,PhysicsActivation\)
```cj
public func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType, activation: PhysicsActivation): Unit
```
Sets the body motion type (static/kinematic/dynamic)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handlemotionType Motion typeactivation Whether to activate the body at the same time|
|motionType|PhysicsMotionType||
|activation|PhysicsActivation||

### func setObjectLayer\(PhysicsBodyHandle,PhysicsLayer\)
```cj
public func setObjectLayer(handle: PhysicsBodyHandle, layer: PhysicsLayer): Unit
```
Sets the object layer of the body (determines collision filtering)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handlelayer Object layer (NonMoving/Moving)|
|layer|PhysicsLayer||

### func setPosition\(PhysicsBodyHandle,Vector3,PhysicsActivation\)
```cj
public func setPosition(handle: PhysicsBodyHandle, position: Vector3, activation: PhysicsActivation): Unit
```
Sets the body world position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handleposition World position (three left-handed coordinates)activation Whether to activate the body at the same time|
|position|Vector3||
|activation|PhysicsActivation||

### func setRestitution\(PhysicsBodyHandle,Float64\)
```cj
public func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit
```
Sets the body restitution coefficient (bounciness)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handlerestitution Restitution coefficient (0.0 fully inelastic, 1.0 fully elastic)|
|restitution|Float64||

### func setRotation\(PhysicsBodyHandle,Quaternion,PhysicsActivation\)
```cj
public func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion, activation: PhysicsActivation): Unit
```
Sets the body rotation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|Body handlerotation Rotation quaternion (three left-handed coordinates)activation Whether to activate the body at the same time|
|rotation|Quaternion||
|activation|PhysicsActivation||

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
Shuts down the physics system and releases all resources (shape handles, physics system, listeners)

### func update\(Float32,Int32\)
```cj
public func update(deltaTime: Float32, collisionSteps: Int32): UInt32
```
Steps the physics world by one time slice

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float32|Step time delta (seconds)collisionSteps Number of collision solver iterations per step|
|collisionSteps|Int32||

Return: 

- Number of collisions produced in this step

