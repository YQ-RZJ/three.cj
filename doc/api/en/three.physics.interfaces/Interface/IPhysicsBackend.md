# Interface
## interface IPhysicsBackend
```cj
public interface IPhysicsBackend
```
Pluggable physics backend interface

### func addAngularImpulse\(PhysicsBodyHandle,Vector3\)
```cj
func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit
```
Applies an angular impulse

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleangularImpulse The angular impulse vector|
|angularImpulse|Vector3||

### func addForceAtPosition\(PhysicsBodyHandle,Vector3,Vector3\)
```cj
func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit
```
Applies a force at a specified world position on the body (newtons)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleforce The force vectorpoint The point of application (world coordinates)|
|force|Vector3||
|point|Vector3||

### func addForce\(PhysicsBodyHandle,Vector3\)
```cj
func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit
```
Applies a force at the body's center of mass (newtons)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleforce The force vector|
|force|Vector3||

### func addImpulse\(PhysicsBodyHandle,Vector3\)
```cj
func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit
```
Applies an impulse at the body's center of mass (impulse = force × time)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleimpulse The impulse vector|
|impulse|Vector3||

### func addTorque\(PhysicsBodyHandle,Vector3\)
```cj
func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit
```
Applies a torque (newton-meters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handletorque The torque vector|
|torque|Vector3||

### func backendName\(\)
```cj
func backendName(): String
```
The backend name (e.g. "JoltPhysics"), for logging/debugging

Return: 

- The backend name string

### func castShape\(PhysicsShape,Vector3,Quaternion,Vector3,ArrayList<PhysicsShapeHit>\)
```cj
func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, direction: Vector3, hits: ArrayList < PhysicsShapeHit >): Int64
```
Shape cast (sweeps shape along direction, detecting the first/all blockers)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The cast shape descriptionposition The cast start position (world coordinates)rotation The cast shape rotationdirection The cast direction (its length is the max sweep distance)hits The hit-result output (sorted by fraction ascending)|
|position|Vector3||
|rotation|Quaternion||
|direction|Vector3||
|hits|ArrayList<PhysicsShapeHit>||

Return: 

- The number of hits

### func collidePoint\(Vector3,ArrayList<PhysicsPointHit>\)
```cj
func collidePoint(point: Vector3, hits: ArrayList < PhysicsPointHit >): Int64
```
World point collision test (which shapes contain or touch the point)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|The test point in world coordinateshits The hit-result output (filled by the backend)|
|hits|ArrayList<PhysicsPointHit>||

Return: 

- The number of hits

### func collideShape\(PhysicsShape,Vector3,Quaternion,ArrayList<PhysicsShapeHit>\)
```cj
func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, hits: ArrayList < PhysicsShapeHit >): Int64
```
Shape-vs-world collision test (intersects the scene with the query shape placed at the pose)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The query shape descriptionposition The query shape position (world coordinates)rotation The query shape rotationhits The hit-result output (filled by the backend)|
|position|Vector3||
|rotation|Quaternion||
|hits|ArrayList<PhysicsShapeHit>||

Return: 

- The number of hits

### func createBody\(PhysicsBodyDesc\)
```cj
func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle
```
Creates a body and adds it to the physics world (single step)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|desc|PhysicsBodyDesc|The body creation description|

Return: 

- The body handle, or INVALID on failure

### func createConstraint\(PhysicsConstraintDesc,PhysicsBodyHandle,PhysicsBodyHandle\)
```cj
func createConstraint(desc: PhysicsConstraintDesc, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraintHandle
```
Creates a constraint and adds it to the world (connecting two bodies)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|desc|PhysicsConstraintDesc|The constraint creation descriptionbodyA The first constrained bodybodyB The second constrained body|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||

Return: 

- The constraint handle, or INVALID on failure

### func destroyBody\(PhysicsBodyHandle\)
```cj
func destroyBody(handle: PhysicsBodyHandle): Unit
```
Removes and destroys a body (single step; the handle becomes invalid immediately)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

### func destroyConstraint\(PhysicsConstraintHandle\)
```cj
func destroyConstraint(handle: PhysicsConstraintHandle): Unit
```
Destroys a constraint and removes it from the world (the handle becomes invalid immediately)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handle|

### func getAngularVelocity\(PhysicsBodyHandle\)
```cj
func getAngularVelocity(handle: PhysicsBodyHandle): Vector3
```
Gets the body angular velocity (world space, rad/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current angular velocity

### func getConstraintCurrentAngle\(PhysicsConstraintHandle\)
```cj
func getConstraintCurrentAngle(handle: PhysicsConstraintHandle): Float64
```
Gets the hinge constraint current angle (radians)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handle|

Return: 

- The current angle (radians); 0 for an invalid handle

### func getFriction\(PhysicsBodyHandle\)
```cj
func getFriction(handle: PhysicsBodyHandle): Float64
```
Gets the body friction coefficient

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current friction coefficient

### func getGravityFactor\(PhysicsBodyHandle\)
```cj
func getGravityFactor(handle: PhysicsBodyHandle): Float64
```
Gets the body gravity factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current gravity factor

### func getInverseInertia\(PhysicsBodyHandle\)
```cj
func getInverseInertia(handle: PhysicsBodyHandle): Matrix4
```
Gets the body inverse inertia (3x3, in the top-left of the returned 4x4)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current inverse-inertia matrix

### func getLinearVelocity\(PhysicsBodyHandle\)
```cj
func getLinearVelocity(handle: PhysicsBodyHandle): Vector3
```
Gets the body linear velocity (world space, m/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current linear velocity

### func getMass\(PhysicsBodyHandle\)
```cj
func getMass(handle: PhysicsBodyHandle): Float64
```
Gets the body mass (kilograms)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current mass

### func getMotionType\(PhysicsBodyHandle\)
```cj
func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType
```
Gets the body motion type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current motion type

### func getObjectLayer\(PhysicsBodyHandle\)
```cj
func getObjectLayer(handle: PhysicsBodyHandle): PhysicsLayer
```
Gets the body object layer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current object layer

### func getPosition\(PhysicsBodyHandle\)
```cj
func getPosition(handle: PhysicsBodyHandle): Vector3
```
Gets the body position (world coordinates)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current position

### func getRestitution\(PhysicsBodyHandle\)
```cj
func getRestitution(handle: PhysicsBodyHandle): Float64
```
Gets the body restitution coefficient

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current restitution coefficient

### func getRotation\(PhysicsBodyHandle\)
```cj
func getRotation(handle: PhysicsBodyHandle): Quaternion
```
Gets the body rotation (quaternion)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current rotation

### func getSliderCurrentPosition\(PhysicsConstraintHandle\)
```cj
func getSliderCurrentPosition(handle: PhysicsConstraintHandle): Float64
```
Gets the slider constraint current position (meters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handle|

Return: 

- The current position (meters); 0 for an invalid handle

### func initialize\(UInt32,Vector3\)
```cj
func initialize(maxBodies: UInt32, gravity: Vector3): Bool
```
Initializes the backend (global init + creates the physics system/job system/layer filter)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maxBodies|UInt32|Maximum number of bodies in the worldgravity The global gravity vector (e.g. (0, -9.81, 0))|
|gravity|Vector3||

Return: 

- true on success

### func isBodyActive\(PhysicsBodyHandle\)
```cj
func isBodyActive(handle: PhysicsBodyHandle): Bool
```
Queries whether a body is in the active (simulating) state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- true if active

### func isConstraintEnabled\(PhysicsConstraintHandle\)
```cj
func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool
```
Whether the constraint is enabled

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handle|

Return: 

- true if enabled

### func isInitialized\(\)
```cj
func isInitialized(): Bool
```
Whether the backend is initialized

Return: 

- true if initialized

### func moveKinematic\(PhysicsBodyHandle,Vector3,Quaternion,Float32\)
```cj
func moveKinematic(handle: PhysicsBodyHandle, position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit
```
Moves a kinematic body to the given position/rotation

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Call every frame; driven by the deltaTime step.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleposition The target position (world coordinates)rotation The target rotationdeltaTime The time step (seconds)|
|position|Vector3||
|rotation|Quaternion||
|deltaTime|Float32||

### func optimizeBroadPhase\(\)
```cj
func optimizeBroadPhase(): Unit
```
Optimizes the BroadPhase bounding-volume tree

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Call once after bulk-inserting bodies and before the main simulation.</p>

### func raycastAll\(Vector3,Vector3,ArrayList<PhysicsRayHit>\)
```cj
func raycastAll(origin: Vector3, direction: Vector3, hits: ArrayList < PhysicsRayHit >): Int64
```
World ray batch cast (collects all hits, sorted by distance ascending)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|The ray origin (world coordinates)direction The ray direction (its length is the max cast distance)hits The hit-result output (pass an empty list; the backend fills it sorted by distance)|
|direction|Vector3||
|hits|ArrayList<PhysicsRayHit>||

Return: 

- The number of hits

### func raycast\(Vector3,Vector3,PhysicsRayHit\)
```cj
func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool
```
World ray cast (closest hit)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|The ray origin (world coordinates)direction The ray direction (its length is the max cast distance)hit The hit-result output (valid when a hit occurs)|
|direction|Vector3||
|hit|PhysicsRayHit||

Return: 

- true if anything was hit

### func setAngularVelocity\(PhysicsBodyHandle,Vector3\)
```cj
func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit
```
Sets the body angular velocity (world space, rad/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleangularVelocity The angular velocity|
|angularVelocity|Vector3||

### func setConstraintEnabled\(PhysicsConstraintHandle,Bool\)
```cj
func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit
```
Sets whether the constraint is enabled

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleenabled Whether to enable the constraint|
|enabled|Bool||

### func setConstraintLimits\(PhysicsConstraintHandle,Float64,Float64\)
```cj
func setConstraintLimits(handle: PhysicsConstraintHandle, limitMin: Float64, limitMax: Float64): Unit
```
Updates constraint limits at runtime (Hinge/Slider, radians or meters)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Only valid for Hinge/Slider constraints</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handlelimitMin The minimum limitlimitMax The maximum limit|
|limitMin|Float64||
|limitMax|Float64||

### func setConstraintMaxFriction\(PhysicsConstraintHandle,Float64\)
```cj
func setConstraintMaxFriction(handle: PhysicsConstraintHandle, friction: Float64): Unit
```
Sets the constraint max friction (torque for Hinge, force for Slider)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handlefriction The maximum friction value|
|friction|Float64||

### func setConstraintMotorState\(PhysicsConstraintHandle,PhysicsMotorState\)
```cj
func setConstraintMotorState(handle: PhysicsConstraintHandle, state: PhysicsMotorState): Unit
```
Sets the constraint motor state (Hinge/Slider)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Only valid for Hinge/Slider constraints; use the SixDOF-specific API for SixDOF</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handlestate The motor state (Off/Velocity/Position)|
|state|PhysicsMotorState||

### func setConstraintTargetAngle\(PhysicsConstraintHandle,Float64\)
```cj
func setConstraintTargetAngle(handle: PhysicsConstraintHandle, angle: Float64): Unit
```
Sets the hinge constraint target angle (motor position mode, radians)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleangle The target angle (radians)|
|angle|Float64||

### func setConstraintTargetAngularVelocity\(PhysicsConstraintHandle,Float64\)
```cj
func setConstraintTargetAngularVelocity(handle: PhysicsConstraintHandle, angularVelocity: Float64): Unit
```
Sets the hinge constraint target angular velocity (motor velocity mode, rad/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleangularVelocity The target angular velocity (rad/s)|
|angularVelocity|Float64||

### func setContactListener\(Option<IPhysicsSensorListener>\)
```cj
func setContactListener(listener: Option < IPhysicsSensorListener >): Unit
```
Registers a collision event listener (contact + activation/sleep callbacks)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|listener|Option<IPhysicsSensorListener>|The listener, or None to unregister|

### func setFriction\(PhysicsBodyHandle,Float64\)
```cj
func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit
```
Sets the body friction coefficient (0~1)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlefriction The friction coefficient|
|friction|Float64||

### func setGravityFactor\(PhysicsBodyHandle,Float64\)
```cj
func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit
```
Sets the body gravity factor (1 = normal gravity, 0 = no gravity)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlegravityFactor The gravity factor|
|gravityFactor|Float64||

### func setGravity\(Vector3\)
```cj
func setGravity(gravity: Vector3): Unit
```
Sets the global gravity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|gravity|Vector3|The gravity vector (e.g. (0, -9.81, 0))|

### func setIsSensor\(PhysicsBodyHandle,Bool\)
```cj
func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit
```
Sets whether a body is a sensor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleisSensor Whether the body is a sensor (collision-only, no physical response)|
|isSensor|Bool||

### func setLinearVelocity\(PhysicsBodyHandle,Vector3\)
```cj
func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit
```
Sets the body linear velocity (world space, m/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlevelocity The linear velocity|
|velocity|Vector3||

### func setMass\(PhysicsBodyHandle,Float64\)
```cj
func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit
```
Sets the body mass (kilograms)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlemass The target mass|
|mass|Float64||

### func setMotionType\(PhysicsBodyHandle,PhysicsMotionType,PhysicsActivation\)
```cj
func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType, activation: PhysicsActivation): Unit
```
Sets the body motion type (switch Static/Kinematic/Dynamic at runtime)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlemotionType The target motion typeactivation The activation strategy|
|motionType|PhysicsMotionType||
|activation|PhysicsActivation||

### func setObjectLayer\(PhysicsBodyHandle,PhysicsLayer\)
```cj
func setObjectLayer(handle: PhysicsBodyHandle, layer: PhysicsLayer): Unit
```
Sets the body object layer (changes the collision grouping at runtime)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlelayer The target object layer|
|layer|PhysicsLayer||

### func setPosition\(PhysicsBodyHandle,Vector3,PhysicsActivation\)
```cj
func setPosition(handle: PhysicsBodyHandle, position: Vector3, activation: PhysicsActivation): Unit
```
Sets the body position (world coordinates)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleposition The new positionactivation The activation strategy|
|position|Vector3||
|activation|PhysicsActivation||

### func setRestitution\(PhysicsBodyHandle,Float64\)
```cj
func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit
```
Sets the body restitution coefficient (0~1)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlerestitution The restitution coefficient|
|restitution|Float64||

### func setRotation\(PhysicsBodyHandle,Quaternion,PhysicsActivation\)
```cj
func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion, activation: PhysicsActivation): Unit
```
Sets the body rotation (quaternion)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlerotation The new rotationactivation The activation strategy|
|rotation|Quaternion||
|activation|PhysicsActivation||

### func setSixDOFMotorState\(PhysicsConstraintHandle,Int64,PhysicsMotorState\)
```cj
func setSixDOFMotorState(handle: PhysicsConstraintHandle, axis: Int64, state: PhysicsMotorState): Unit
```
Sets the motor state of one axis of a SixDOF constraint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleaxis The axis index (0=X translation, 1=Y, 2=Z, 3=X rotation, 4=Y, 5=Z)state The motor state|
|axis|Int64||
|state|PhysicsMotorState||

### func setSixDOFTargetPosition\(PhysicsConstraintHandle,Vector3\)
```cj
func setSixDOFTargetPosition(handle: PhysicsConstraintHandle, target: Vector3): Unit
```
Sets the SixDOF constraint-space target position (translation motors)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handletarget The target position in constraint space|
|target|Vector3||

### func setSixDOFTargetVelocity\(PhysicsConstraintHandle,Vector3\)
```cj
func setSixDOFTargetVelocity(handle: PhysicsConstraintHandle, target: Vector3): Unit
```
Sets the SixDOF constraint-space target velocity (translation motors)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handletarget The target velocity in constraint space|
|target|Vector3||

### func setSliderTargetPosition\(PhysicsConstraintHandle,Float64\)
```cj
func setSliderTargetPosition(handle: PhysicsConstraintHandle, position: Float64): Unit
```
Sets the slider constraint target position (motor position mode, meters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleposition The target position (meters)|
|position|Float64||

### func setSliderTargetVelocity\(PhysicsConstraintHandle,Float64\)
```cj
func setSliderTargetVelocity(handle: PhysicsConstraintHandle, velocity: Float64): Unit
```
Sets the slider constraint target velocity (motor velocity mode, m/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handlevelocity The target velocity (m/s)|
|velocity|Float64||

### func shutdown\(\)
```cj
func shutdown(): Unit
```
Shuts down the backend (destroys the physics system + global teardown)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The instance must not be used again after this call.</p>

### func update\(Float32,Int32\)
```cj
func update(deltaTime: Float32, collisionSteps: Int32): UInt32
```
Steps the physics world by one frame

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float32|The time step (seconds), typically 1/60collisionSteps The number of collision substeps per step (1 for a 1/60s step)|
|collisionSteps|Int32||

Return: 

- The update error flags (0 = completed fully)

