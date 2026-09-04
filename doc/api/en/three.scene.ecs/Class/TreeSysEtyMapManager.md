# Class
## class TreeSysEtyMapManager
```cj
public class TreeSysEtyMapManager <: ISysEtyMapManager < System, Entity >
```
System-entity mapping manager (prefix tree mode)

### func addEntity\(Entity\)
```cj
public func addEntity(ety: Entity): Unit
```
Add entity to matching system records

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ety|Entity|Entity|

### func addSystem\(System\)
```cj
public func addSystem(sys: System): Unit
```
Add a system to the mapping

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sys|System|System|

### func bind\(HashMap<SystemId,System>,HashMap<EntityId,Entity>\)
```cj
public func bind(systems: HashMap < SystemId, System >, entitys: HashMap < EntityId, Entity >): Unit
```
Bind system and entity tables

Parameter: 

|Name|Type|Describe|
|---|---|---|
|systems|HashMap<SystemId,System>|System tableentitys Entity table|
|entitys|HashMap<EntityId,Entity>||

### func changeEntity\(Array<UInt8>,Entity\)
```cj
public func changeEntity(oldMask: Array < UInt8 >, ety: Entity): Unit
```
Adjust mapping after entity component change

Parameter: 

|Name|Type|Describe|
|---|---|---|
|oldMask|Array<UInt8>|Old component maskety Changed entity|
|ety|Entity||

### func clear\(\)
```cj
public func clear(): Unit
```
Clear all mappings

### func delEntity\(Entity\)
```cj
public func delEntity(ety: Entity): Unit
```
Remove entity from all system records

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ety|Entity|Entity|

### func delSystem\(System\)
```cj
public func delSystem(sys: System): Unit
```
Remove a system from the mapping

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sys|System|System|

### func getSystemEntitys\(System\)
```cj
public func getSystemEntitys(sys: System):(Int64, Iterator < Entity >)
```
Get entities associated with a system

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sys|System|System|

Return: 

- (entity count, entity iterator)

