# Class
## class PhysicsCharacter
```cj
public class PhysicsCharacter
```
Rigid-body based character (corresponds to JPH_Character)

### func addToPhysicsSystem\(PhysicsActivation\)
```cj
public func addToPhysicsSystem(activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Adds the character to the physics system

Parameter: 

|Name|Type|Describe|
|---|---|---|
|activation|PhysicsActivation|Whether to activate immediately (default Activate)|

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes the character (auto-removes it from the physics system and frees the handle)

### func getGroundState\(\)
```cj
public func getGroundState(): UInt32
```
Gets the ground state (0 = OnGround, 1 = OnSteepGround, 2 = NotSupported, 3 = InAir)

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
Gets the character's linear velocity

Return: 

- The current linear velocity (world space, three left-handed)

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
Gets the character's position

Return: 

- The current position (world space, three left-handed)

### func isOnGround\(\)
```cj
public func isOnGround(): Bool
```
Whether the character is on the ground (GroundState == OnGround)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Call postSimulation first to refresh the ground state</p>

### func postSimulation\(Float32\)
```cj
public func postSimulation(maxSeparationDistance!: Float32 = 0.05f32): Unit
```
Post-simulation processing (ground-contact detection)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|maxSeparationDistance|Float32|Maximum separation distance (meters; default 0.05)|

### func removeFromPhysicsSystem\(\)
```cj
public func removeFromPhysicsSystem(): Unit
```
Removes the character from the physics system (can be re-added)

### func setLinearVelocity\(Vector3\)
```cj
public func setLinearVelocity(velocity: Vector3): Unit
```
Sets the character's linear velocity (controls movement)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|velocity|Vector3|The target linear velocity (world space, three left-handed)|

### func setPosition\(Vector3,PhysicsActivation\)
```cj
public func setPosition(position: Vector3, activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Sets the character's position (teleport)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|position|Vector3|The target position (world space, three left-handed)activation Whether to activate immediately (default Activate)|
|activation|PhysicsActivation||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether the character is valid (created successfully and not disposed)

