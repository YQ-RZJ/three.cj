# Class
## class EntityManager
```cj
public class EntityManager
```
Entity manager class

### func addEntity\(Entity\)
```cj
public func addEntity(e: Entity): EntityId
```
Add an entity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|e|Entity|Entity|

Return: 

- Entity ID

### func clear\(\)
```cj
public func clear(): Unit
```
Clear (destruct all entities; all IDs released)

### func delEntity\(EntityId\)
```cj
public func delEntity(id: EntityId):?Entity
```
Delete an entity (triggers destruct; ID auto-released)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|EntityId|Entity ID|

Return: 

- The deleted entity, or None if not found

### func getEntity\(EntityId\)
```cj
public func getEntity(id: EntityId):?Entity
```
Get an entity by ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|EntityId|Entity ID|

Return: 

- Entity instance, or None if not found

### func removeEntity\(EntityId\)
```cj
public func removeEntity(id: EntityId):?Entity
```
Remove an entity (does not trigger destruct; ID not released)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|EntityId|Entity ID|

Return: 

- The removed entity, or None if not found

### prop entitys: HashMap < EntityId, Entity >
```cj
public prop entitys: HashMap < EntityId, Entity >
```
All entities (internal table reference for mapping manager binding)

### prop size: Int64
```cj
public prop size: Int64
```
Total managed count

