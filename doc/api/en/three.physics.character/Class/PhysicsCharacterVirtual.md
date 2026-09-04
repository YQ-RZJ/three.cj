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
Gets the ground state (GroundState enum value)

Return: 

- The GroundState enum value (0 = OnGround)

### func getLinearVelocity\(\)
```cj
public func getLinearVelocity(): Vector3
```
Gets the virtual character's linear velocity

Return: 

- The current linear velocity (world coordinates)

### func getPosition\(\)
```cj
public func getPosition(): Vector3
```
Gets the virtual character's position

Return: 

- The current position (world coordinates)

### func init\(CPointer<Unit>,Vector3,CPointer<Unit>,Quaternion,Float32,Float32\)
```cj
public init(shape: CPointer < Unit >, position: Vector3, system: CPointer < Unit >, rotation!: Quaternion = Quaternion(), mass!: Float32 = 70.0f32, maxSlopeAngle!: Float32 = 0.7853982f32)
```
Creates a virtual character

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|CPointer<Unit>|The character collision shape handle (a JPH_Shape handle created and kept by the caller)position The initial position (world coordinates)system The physics system handlerotation The initial rotation (quaternion)mass The mass (kilograms, used for impulse calculations)maxSlopeAngle The maximum standable slope angle (radians)|
|position|Vector3||
|system|CPointer<Unit>||
|rotation|Quaternion||
|mass|Float32||
|maxSlopeAngle|Float32||

### func isOnGround\(\)
```cj
public func isOnGround(): Bool
```
Whether the virtual character is on the ground (OnGround)

Return: 

- true if on the ground

### func isValid\(\)
```cj
public func isValid(): Bool
```
Whether the virtual character was created successfully (handle valid and not disposed)

Return: 

- true if valid

### func setLinearVelocity\(Vector3\)
```cj
public func setLinearVelocity(velocity: Vector3): Unit
```
Sets the virtual character's linear velocity (controls movement)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|velocity|Vector3|The target linear velocity (world-space direction)|

### func setPosition\(Vector3\)
```cj
public func setPosition(position: Vector3): Unit
```
Sets the virtual character's position (teleport)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|position|Vector3|The target position (world coordinates)|

### func update\(Float32,UInt32,CPointer<Unit>\)
```cj
public func update(deltaTime: Float32, layer: UInt32, system: CPointer < Unit >): Unit
```
Updates the virtual character (call every frame)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float32|The time step (seconds)layer The object layer (collision layer used while the character moves)system The physics system handle|
|layer|UInt32||
|system|CPointer<Unit>||

