# Class
## class Component
```cj
public open class Component <: EcsObject
```
Base component class, pure data carrier

### prop cptId: ComponentId
```cj
public open prop cptId: ComponentId
```
Component class ID

### var entity
```cj
public var entity:?Entity = None
```
Owning entity (maintained by Entity on mount/unmount)

