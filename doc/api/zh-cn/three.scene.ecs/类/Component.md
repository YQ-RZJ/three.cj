# 类
## class Component
```cj
public open class Component <: EcsObject
```
组件基类，纯数据载体

### prop cptId: ComponentId
```cj
public open prop cptId: ComponentId
```
组件类 ID

### var entity
```cj
public var entity:?Entity = None
```
所属实体（挂载/卸载时由 Entity 维护）

