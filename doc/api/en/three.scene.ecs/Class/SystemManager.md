# Class
## class SystemManager
```cj
public class SystemManager
```
System manager class

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

Exception: 

- EcsException System with same ID already exists

### func clear\(\)
```cj
public func clear(): Unit
```
Clear (destruct all systems)

### func delSystemById\(SystemId\)
```cj
public func delSystemById(id: SystemId):?System
```
Delete a system (triggers destruct; ID auto-released)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|SystemId|System ID|

Return: 

- The deleted system, or None if not found

### func init\(EntityManager,ISysEtyMapManager<System,Entity>\)
```cj
public init(etyMgr: EntityManager, sysMap: ISysEtyMapManager < System, Entity >)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|etyMgr|EntityManager|Entity managersysMap System-entity mapping manager|
|sysMap|ISysEtyMapManager<System,Entity>||

### func onUpdate\(Float64\)
```cj
public func onUpdate(dt: Float64): Unit
```
Update all systems

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dt|Float64|Frame interval (seconds)|

### prop size: Int64
```cj
public prop size: Int64
```
Total managed count

### prop systems: HashMap < SystemId, System >
```cj
public prop systems: HashMap < SystemId, System >
```
All systems

### let updateOrder
```cj
public let updateOrder: ArrayList < SystemId >= ArrayList < SystemId >()
```
System traversal order (ascending by sysId when empty)

