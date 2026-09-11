# Class
## class PhysicsWorld
```cj
public class PhysicsWorld
```
Physics-world facade

### func addAngularImpulse\(PhysicsBodyHandle,Vector3\)
```cj
public func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit
```
Applies an angular impulse

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleangularImpulse The angular impulse vector|
|angularImpulse|Vector3||

### func addForceAtPosition\(PhysicsBodyHandle,Vector3,Vector3\)
```cj
public func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit
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
public func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit
```
Applies a force at the body's center of mass (newtons)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleforce The force vector|
|force|Vector3||

### func addImpulse\(PhysicsBodyHandle,Vector3\)
```cj
public func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit
```
Applies an impulse at the body's center of mass (impulse = force × time)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleimpulse The impulse vector|
|impulse|Vector3||

### func addTorque\(PhysicsBodyHandle,Vector3\)
```cj
public func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit
```
Applies a torque (newton-meters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handletorque The torque vector|
|torque|Vector3||

### func bindObject\(Object3D,PhysicsBodyHandle,Bool\)
```cj
public func bindObject(object3d: Object3D, handle: PhysicsBodyHandle, syncToObj!: Bool = true): Unit
```
Binds an Object3D to an existing body: the body transform is auto-synced to the object after each step

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object3d|Object3D|The rendering object to bindhandle The physics body handlesyncToObj true = physics→render (Dynamic/Kinematic bodies);false = render→physics (optional when a Kinematic body is user-driven)|
|handle|PhysicsBodyHandle||
|syncToObj|Bool||

### func castShape\(PhysicsShape,Vector3,Quaternion,Vector3\)
```cj
public func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, direction: Vector3): ArrayList < PhysicsShapeHit >
```
Shape cast (sweeps shape along direction, detecting the first/all blockers)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The cast shape descriptionposition The cast start position (world coordinates)rotation The cast shape rotationdirection The cast direction (its length is the max sweep distance)|
|position|Vector3||
|rotation|Quaternion||
|direction|Vector3||

Return: 

- The hit list (sorted by fraction ascending; empty = no blocker)

### func collidePoint\(Vector3\)
```cj
public func collidePoint(point: Vector3): ArrayList < PhysicsPointHit >
```
World point collision test (which shapes contain or touch the point)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|point|Vector3|The test point in world coordinates|

Return: 

- The hit list

### func collideShape\(PhysicsShape,Vector3,Quaternion\)
```cj
public func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion): ArrayList < PhysicsShapeHit >
```
Shape-vs-world collision test (intersects the scene with the query shape placed at the pose)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|PhysicsShape|The query shape descriptionposition The query shape position (world coordinates)rotation The query shape rotation|
|position|Vector3||
|rotation|Quaternion||

Return: 

- The hit list

### func createBody\(PhysicsBodyDesc\)
```cj
public func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle
```
Creates a rigid body (single step)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|desc|PhysicsBodyDesc|The body creation description|

Return: 

- The body handle, or INVALID on failure

### func createConstraint\(PhysicsConstraintDesc,PhysicsBodyHandle,PhysicsBodyHandle\)
```cj
public func createConstraint(desc: PhysicsConstraintDesc, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraintHandle
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
public func destroyBody(handle: PhysicsBodyHandle): Unit
```
Destroys a body and unbinds any bindings

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

### func destroyConstraint\(PhysicsConstraintHandle\)
```cj
public func destroyConstraint(handle: PhysicsConstraintHandle): Unit
```
Destroys a constraint and removes it from the world (the handle becomes invalid immediately)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handle|

### func getAngularVelocity\(PhysicsBodyHandle\)
```cj
public func getAngularVelocity(handle: PhysicsBodyHandle): Vector3
```
Gets the body angular velocity (world space, rad/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current angular velocity

### func getBoundHandle\(Object3D\)
```cj
public func getBoundHandle(object3d: Object3D): PhysicsBodyHandle
```
Gets the body handle bound to an Object3D

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object3d|Object3D|The rendering object|

Return: 

- The body handle, or INVALID if not bound

### func getConstraintCurrentAngle\(PhysicsConstraintHandle\)
```cj
public func getConstraintCurrentAngle(handle: PhysicsConstraintHandle): Float64
```
Reads the hinge constraint current angle (radians)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handle|

Return: 

- The current angle

### func getFriction\(PhysicsBodyHandle\)
```cj
public func getFriction(handle: PhysicsBodyHandle): Float64
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
public func getGravityFactor(handle: PhysicsBodyHandle): Float64
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
public func getInverseInertia(handle: PhysicsBodyHandle): Matrix4
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
public func getLinearVelocity(handle: PhysicsBodyHandle): Vector3
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
public func getMass(handle: PhysicsBodyHandle): Float64
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
public func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType
```
Gets the body motion type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handle|

Return: 

- The body's current motion type

### func getPosition\(PhysicsBodyHandle\)
```cj
public func getPosition(handle: PhysicsBodyHandle): Vector3
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
public func getRestitution(handle: PhysicsBodyHandle): Float64
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
public func getRotation(handle: PhysicsBodyHandle): Quaternion
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
public func getSliderCurrentPosition(handle: PhysicsConstraintHandle): Float64
```
Reads the slider constraint current position (meters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handle|

Return: 

- The current position

### func init\(IPhysicsBackend\)
```cj
public init(backend!: IPhysicsBackend = JoltBackend())
```
Constructs the physics world

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|IPhysicsBackend|The physics backend instance (JoltBackend by default); any IPhysicsBackend implementation may be used|

### func isBodyActive\(PhysicsBodyHandle\)
```cj
public func isBodyActive(handle: PhysicsBodyHandle): Bool
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
public func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool
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
public func isInitialized(): Bool
```
Whether the backend is initialized

Return: 

- true if initialized

### func moveKinematic\(PhysicsBodyHandle,Vector3,Quaternion,Float32\)
```cj
public func moveKinematic(handle: PhysicsBodyHandle, position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit
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
public func optimizeBroadPhase(): Unit
```
Optimizes the BroadPhase bounding-volume tree

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Call once after bulk-inserting bodies and before the main simulation.</p>

### func raycastAll\(Vector3,Vector3\)
```cj
public func raycastAll(origin: Vector3, direction: Vector3): ArrayList < PhysicsRayHit >
```
World ray batch cast (collects all hits, sorted by distance ascending)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|origin|Vector3|The ray origin (world coordinates)direction The ray direction (its length is the max cast distance)|
|direction|Vector3||

Return: 

- The hit list (sorted by fraction ascending)

### func raycast\(Vector3,Vector3,PhysicsRayHit\)
```cj
public func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool
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
public func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit
```
Sets the body angular velocity (world space, rad/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleangularVelocity The angular velocity|
|angularVelocity|Vector3||

### func setBackend\(IPhysicsBackend\)
```cj
public func setBackend(newBackend: IPhysicsBackend): Unit
```
Replaces the backend (swaps the underlying physics engine at runtime)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The old backend must be shut down first; the new backend must be initialized before use.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|newBackend|IPhysicsBackend|The new backend instance|

### func setConstraintEnabled\(PhysicsConstraintHandle,Bool\)
```cj
public func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit
```
Sets whether the constraint is enabled

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleenabled Whether the constraint is enabled|
|enabled|Bool||

### func setConstraintMotorState\(PhysicsConstraintHandle,PhysicsMotorState\)
```cj
public func setConstraintMotorState(handle: PhysicsConstraintHandle, state: PhysicsMotorState): Unit
```
Sets the constraint motor state (Hinge/Slider: Off/Velocity/Position)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handlestate The motor state|
|state|PhysicsMotorState||

### func setConstraintTargetAngle\(PhysicsConstraintHandle,Float64\)
```cj
public func setConstraintTargetAngle(handle: PhysicsConstraintHandle, angle: Float64): Unit
```
Sets the hinge motor target angle (position mode, radians)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleangle The target angle|
|angle|Float64||

### func setConstraintTargetAngularVelocity\(PhysicsConstraintHandle,Float64\)
```cj
public func setConstraintTargetAngularVelocity(handle: PhysicsConstraintHandle, angularVelocity: Float64): Unit
```
Sets the hinge motor target angular velocity (velocity mode, rad/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleangularVelocity The target angular velocity|
|angularVelocity|Float64||

### func setContactListener\(Option<IPhysicsSensorListener>\)
```cj
public func setContactListener(listener: Option < IPhysicsSensorListener >): Unit
```
Registers a collision event listener (contact + activation/sleep callbacks)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|listener|Option<IPhysicsSensorListener>|The listener, or None to unregister|

### func setFriction\(PhysicsBodyHandle,Float64\)
```cj
public func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit
```
Sets the body friction coefficient (0~1)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlefriction The friction coefficient|
|friction|Float64||

### func setGravityFactor\(PhysicsBodyHandle,Float64\)
```cj
public func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit
```
Sets the body gravity factor (1 = normal gravity, 0 = no gravity)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlegravityFactor The gravity factor|
|gravityFactor|Float64||

### func setGravity\(Vector3\)
```cj
public func setGravity(gravity: Vector3): Unit
```
Sets the global gravity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|gravity|Vector3|The gravity vector (e.g. (0, -9.81, 0))|

### func setIsSensor\(PhysicsBodyHandle,Bool\)
```cj
public func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit
```
Sets whether a body is a sensor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleisSensor Whether the body is a sensor (collision-only, no physical response)|
|isSensor|Bool||

### func setLinearVelocity\(PhysicsBodyHandle,Vector3\)
```cj
public func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit
```
Sets the body linear velocity (world space, m/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlevelocity The linear velocity|
|velocity|Vector3||

### func setMass\(PhysicsBodyHandle,Float64\)
```cj
public func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit
```
Sets the body mass (kilograms)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlemass The target mass|
|mass|Float64||

### func setMotionType\(PhysicsBodyHandle,PhysicsMotionType,PhysicsActivation\)
```cj
public func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Sets the body motion type (switch Static/Kinematic/Dynamic at runtime)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlemotionType The target motion typeactivation The activation strategy (default Activate)|
|motionType|PhysicsMotionType||
|activation|PhysicsActivation||

### func setPosition\(PhysicsBodyHandle,Vector3,PhysicsActivation\)
```cj
public func setPosition(handle: PhysicsBodyHandle, position: Vector3, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Sets the body position (world coordinates)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handleposition The new positionactivation The activation strategy (default Activate)|
|position|Vector3||
|activation|PhysicsActivation||

### func setRestitution\(PhysicsBodyHandle,Float64\)
```cj
public func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit
```
Sets the body restitution coefficient (0~1)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlerestitution The restitution coefficient|
|restitution|Float64||

### func setRotation\(PhysicsBodyHandle,Quaternion,PhysicsActivation\)
```cj
public func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Sets the body rotation (quaternion)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsBodyHandle|The body handlerotation The new rotationactivation The activation strategy (default Activate)|
|rotation|Quaternion||
|activation|PhysicsActivation||

### func setSliderTargetPosition\(PhysicsConstraintHandle,Float64\)
```cj
public func setSliderTargetPosition(handle: PhysicsConstraintHandle, position: Float64): Unit
```
Sets the slider motor target position (position mode, meters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handleposition The target position|
|position|Float64||

### func setSliderTargetVelocity\(PhysicsConstraintHandle,Float64\)
```cj
public func setSliderTargetVelocity(handle: PhysicsConstraintHandle, velocity: Float64): Unit
```
Sets the slider motor target velocity (velocity mode, m/s)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|PhysicsConstraintHandle|The constraint handlevelocity The target velocity|
|velocity|Float64||

### func shutdown\(\)
```cj
public func shutdown(): Unit
```
Shuts down the physics world: destroys all bindings/bodies → backend.shutdown → notifies the physics thread to exit

### func start\(UInt32,Vector3\)
```cj
public func start(maxBodies!: UInt32 = 1024u32, gravity!: Vector3 = Vector3(0.0, - 9.81, 0.0)): Bool
```
Starts the physics world (initializes the backend + starts the physics thread)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maxBodies|UInt32|Maximum number of bodies in the world (default 1024)gravity The global gravity (default (0, -9.81, 0))|
|gravity|Vector3||

Return: 

- true on success

### func unbindObject\(Object3D\)
```cj
public func unbindObject(object3d: Object3D): Unit
```
Unbinds an Object3D from physics (does not destroy the body)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object3d|Object3D|The rendering object to unbind|

### func update\(Float32,Int32\)
```cj
public func update(deltaTime: Float32, collisionSteps!: Int32 = 1): UInt32
```
Steps the physics world by one frame + syncs body transforms to the bound Object3D

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float32|The time step (seconds), typically 1/60collisionSteps The number of collision substeps per step (1 for a 1/60s step)|
|collisionSteps|Int32||

Return: 

- The update error flags (0 = completed fully)

### prop backend: IPhysicsBackend
```cj
public prop backend: IPhysicsBackend
```
The current backend instance

