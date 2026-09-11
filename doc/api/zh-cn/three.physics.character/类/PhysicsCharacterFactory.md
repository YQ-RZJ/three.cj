# 类
## class PhysicsCharacterFactory
```cj
public class PhysicsCharacterFactory
```
角色工厂

### func createCharacter\(PhysicsWorld\)
```cj
public func createCharacter(world: PhysicsWorld): PhysicsCharacter
```
创建基于刚体的角色（JPH_Character）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|目标物理世界|

返回: 

- 刚体角色

### func createVirtualCharacter\(PhysicsWorld\)
```cj
public func createVirtualCharacter(world: PhysicsWorld): PhysicsCharacterVirtual
```
创建虚拟角色（JPH_CharacterVirtual）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|目标物理世界|

返回: 

- 虚拟角色

### func init\(PhysicsCharacterDesc\)
```cj
public init(desc!: PhysicsCharacterDesc)
```
构造角色工厂

参数: 

|名称|类型|描述|
|---|---|---|
|desc|PhysicsCharacterDesc|角色描述|

