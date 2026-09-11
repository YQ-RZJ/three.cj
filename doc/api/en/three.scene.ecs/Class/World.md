# Class
## class World
```cj
public class World
```
World class, ECS top-level facade

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

### func addSystem\(System\)
```cj
public func addSystem(sys: System): SystemId
```
Add a system to the manager

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sys|System|System|

Return: 

- System ID

### func clear\(\)
```cj
public func clear(): Unit
```
Clear the entire world (component pools cleared; all entities/systems destructed; all IDs released)

### func createComponent\(ComponentId\)where T <: Component
```cj
public func createComponent < T >(cptId: ComponentId):?T where T <: Component
```
Create a component (pooled)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cptId|ComponentId|Component class ID (XxxCpt.typeId())|

Return: 

- Component instance, or None if component class not registered

### func createEntity\(\)
```cj
public func createEntity(): Entity
```
Create an entity (init auto-allocates entity ID)

Return: 

- The newly created entity

### func delEntity\(EntityId\)
```cj
public func delEntity(id: EntityId): Unit
```
Delete an entity (triggers destruct; ID auto-released; all components unloaded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|EntityId|Entity ID|

### func delSystemById\(SystemId\)
```cj
public func delSystemById(id: SystemId): Unit
```
Delete a system (triggers destruct; ID auto-released)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|SystemId|System ID|

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

### func init\(ISysEtyMapManager<System,Entity>\)
```cj
public init(sysMapMgr: ISysEtyMapManager < System, Entity >)
```
Constructor (custom mapping manager)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sysMapMgr|ISysEtyMapManager<System,Entity>|System-entity mapping manager implementation|

### func init\(\)
```cj
public init()
```
Constructor (default hash-mode mapping manager)

### func onUpdate\(Float64\)
```cj
public func onUpdate(dt: Float64): Unit
```
Update all systems

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dt|Float64|Frame interval (seconds)|

### func recycle\(Component\)
```cj
public func recycle(c: Component): Unit
```
Recycle a component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Component|Component instance|

### func removeEntity\(EntityId\)
```cj
public func removeEntity(id: EntityId): Unit
```
Remove an entity (does not trigger destruct; ID not released)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|EntityId|Entity ID|

### prop componentMgr: ComponentManager
```cj
public prop componentMgr: ComponentManager
```
Component manager

### prop entityMgr: EntityManager
```cj
public prop entityMgr: EntityManager
```
Entity manager

### prop systemMgr: SystemManager
```cj
public prop systemMgr: SystemManager
```
System manager

### prop updateOrder: ArrayList < SystemId >
```cj
public prop updateOrder: ArrayList < SystemId >
```
System traversal order (ascending by sysId when empty)

