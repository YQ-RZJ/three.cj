# Class
## class Entity
```cj
public open class Entity <: EcsObject
```
Base entity class

### func addComponent\(Component\)
```cj
public func addComponent(c: Component): Unit
```
Add a component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|c|Component|Component instance|

Exception: 

- EcsException Component not registered (no cptId) or duplicate component type in entity

### func getComponent\(ComponentId\)where T <: Component
```cj
public func getComponent < T >(cptId: ComponentId):?T where T <: Component
```
Get a component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cptId|ComponentId|Component class ID (typically XxxCpt.typeId())|

Return: 

- Component instance, or None if not found

### func hasComponent\(ComponentId\)
```cj
public func hasComponent(cptId: ComponentId): Bool
```
Whether the entity has a component

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cptId|ComponentId|Component class ID|

Return: 

- true if the component exists

### func init\(\)
```cj
public init()
```
Constructor; new allocates entity ID and sets _constructed

### func removeAllComponents\(\)
```cj
public func removeAllComponents(): Unit
```
Remove all components

### func removeComponentById\(ComponentId\)
```cj
public func removeComponentById(cptId: ComponentId):?Component
```
Remove a component by ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cptId|ComponentId|Component class ID|

Return: 

- The removed component (destructed), or None if not found

### func removeComponent\(ComponentId\)where T <: Component
```cj
public func removeComponent < T >(cptId: ComponentId):?T where T <: Component
```
Remove a component (generic convenience form)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cptId|ComponentId|Component class ID|

Return: 

- The removed component, or None if not found

### prop components: HashMap < ComponentId, Component >
```cj
public prop components: HashMap < ComponentId, Component >
```
All components (cptId -> component instance)

### prop cptMask: BitArray
```cj
public prop cptMask: BitArray
```
Component mask of all components owned by this entity

### prop etyId: EntityId
```cj
public prop etyId: EntityId
```
Entity ID

### var monitorComponentChanges
```cj
public var monitorComponentChanges:?(Array < UInt8 >, Entity) -> Unit = None
```
Component change listener (oldMask, entity), hooked by World.addEntity

