# Class
## class PhysicsCharacter
```cj
public class PhysicsCharacter
```
Rigid-body based character (corresponds to JPH_Character)

### func addToPhysicsSystem\(PhysicsActivation\)
```cj
public func addToPhysicsSystem(activation: PhysicsActivation): Unit
```
Adds the character to the physics system

Parameter: 

|Name|Type|Describe|
|---|---|---|
|activation|PhysicsActivation|Whether to activate the character (Activate/DontActivate)|

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes the character and frees the underlying handle

### func getGroundState\(\)
```cj
public func getGroundState(): UInt32
```
Gets the ground state (GroundState enum value)

Return: 

- The GroundState enum value (0 = OnGround)

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
Gets the character's linear velocity

Return: 

- The current linear velocity (world coordinates)

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
Gets the character's position

Return: 

- The current position (world coordinates)

### func init\(CPointer<Unit>,Vector3,CPointer<Unit>,Quaternion,UInt32,Float32,Float32\)
```cj
public init(shape: CPointer < Unit >, position: Vector3, system: CPointer < Unit >, rotation!: Quaternion = Quaternion(), layer!: UInt32 = 1, mass!: Float32 = 80.0f32, maxSlopeAngle!: Float32 = 0.7853982f32)
```
Creates a character

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|CPointer<Unit>|The character collision shape handle (a JPH_Shape handle created and kept by the caller)position The initial position (world coordinates)system The physics system handle (the internal PhysicsWorld system, passed via _getSystem)rotation The initial rotation (quaternion)layer The object layer (0 = NonMoving, 1 = Moving)mass The mass (kilograms)maxSlopeAngle The maximum standable slope angle (radians)|
|position|Vector3||
|system|CPointer<Unit>||
|rotation|Quaternion||
|layer|UInt32||
|mass|Float32||
|maxSlopeAngle|Float32||

### func isOnGround\(\)
```cj
public func isOnGround(): Bool
```
Whether the character is on the ground (OnGround)

Return: 

- true if on the ground

### func isValid\(\)
```cj
public func isValid(): Bool
```
Whether the character was created successfully (handle valid and not disposed)

Return: 

- true if valid

### func postSimulation\(Float32\)
```cj
public func postSimulation(maxSeparationDistance: Float32): Unit
```
Post-simulation processing (detects ground contact; call after PhysicsWorld.update)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maxSeparationDistance|Float32|Maximum separation distance (meters) used to decide whether the character is on the ground|

### func removeFromPhysicsSystem\(\)
```cj
public func removeFromPhysicsSystem(): Unit
```
Removes the character from the physics system

### func setLinearVelocity\(Vector3\)
```cj
public func setLinearVelocity(velocity: Vector3): Unit
```
Sets the character's linear velocity (controls movement)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|velocity|Vector3|The target linear velocity (world-space direction)|

### func setPosition\(Vector3,PhysicsActivation\)
```cj
public func setPosition(position: Vector3, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Sets the character's position (teleport)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|position|Vector3|The target position (world coordinates)activation Whether to activate the character (Activate/DontActivate)|
|activation|PhysicsActivation||

