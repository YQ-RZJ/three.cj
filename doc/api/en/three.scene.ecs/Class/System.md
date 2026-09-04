# Class
## class System
```cj
public open class System <: EcsObject
```
Base system class

### func init\(\)
```cj
public init()
```
Constructor; new allocates system ID; component requirement mask lazily collected on first cptMask access

### func onUpdate\(Iterator<Entity>,Float64\)
```cj
public open func onUpdate(entities: Iterator < Entity >, dt: Float64): Unit
```
System update event

Parameter: 

|Name|Type|Describe|
|---|---|---|
|entities|Iterator<Entity>|Entity iterator matching the component mask (snapshot of current round)dt Frame interval (seconds)|
|dt|Float64||

### prop cptMask: BitArray
```cj
public prop cptMask: BitArray
```
All component flags required by the system

### prop sysId: SystemId
```cj
public prop sysId: SystemId
```
System ID

### var isActive
```cj
public var isActive: Bool = true
```
Whether the system is active (needs updating)

