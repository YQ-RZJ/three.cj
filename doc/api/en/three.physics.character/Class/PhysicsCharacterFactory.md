# Class
## class PhysicsCharacterFactory
```cj
public class PhysicsCharacterFactory
```
Character factory

### func createCharacter\(PhysicsWorld\)
```cj
public func createCharacter(world: PhysicsWorld): PhysicsCharacter
```
Creates a rigid-body character (JPH_Character)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The target physics world|

Return: 

- The rigid-body character

### func createVirtualCharacter\(PhysicsWorld\)
```cj
public func createVirtualCharacter(world: PhysicsWorld): PhysicsCharacterVirtual
```
Creates a virtual character (JPH_CharacterVirtual)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The target physics world|

Return: 

- The virtual character

### func init\(PhysicsCharacterDesc\)
```cj
public init(desc!: PhysicsCharacterDesc)
```
Creates a character factory

Parameter: 

|Name|Type|Describe|
|---|---|---|
|desc|PhysicsCharacterDesc|The character description|

