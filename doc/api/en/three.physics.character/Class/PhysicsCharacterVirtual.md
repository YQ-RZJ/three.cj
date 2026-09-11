# Class
## class PhysicsCharacterVirtual
```cj
public class PhysicsCharacterVirtual
```
Virtual character (corresponds to JPH_CharacterVirtual)

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes the virtual character and frees the underlying handle

### func getGroundState\(\)
```cj
public func getGroundState(): UInt32
```
Gets the ground state (0 = OnGround, 1 = OnSteepGround, 2 = NotSupported, 3 = InAir)

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
Gets the virtual character's linear velocity

Return: 

- The current linear velocity (world space, three left-handed)

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
Gets the virtual character's position

Return: 

- The current position (world space, three left-handed)

### func isOnGround\(\)
```cj
public func isOnGround(): Bool
```
Whether the virtual character is on the ground (GroundState == OnGround)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The ground state is valid for this frame after update</p>

### func setLinearVelocity\(Vector3\)
```cj
public func setLinearVelocity(velocity: Vector3): Unit
```
Sets the virtual character's linear velocity (controls movement)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|velocity|Vector3|The target linear velocity (world space, three left-handed)|

### func setPosition\(Vector3\)
```cj
public func setPosition(position: Vector3): Unit
```
Sets the virtual character's position (teleport)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|position|Vector3|The target position (world space, three left-handed)|

### func update\(Float32,Vector3\)
```cj
public func update(deltaTime: Float32, gravity!: Vector3 = Vector3(0.0, - 9.81, 0.0)): Unit
```
Updates the virtual character (call every frame after PhysicsWorld.update)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float32|The time step (seconds)gravity The gravity vector (default (0,-9.81,0), matching the physics world; sethorizontal movement with setLinearVelocity beforehand — the vertical component ispreserved and gravity is added on top)|
|gravity|Vector3||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether the virtual character is valid (created successfully and not disposed)

