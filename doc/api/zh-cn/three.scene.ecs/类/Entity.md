# 类
## class Entity
```cj
public open class Entity <: EcsObject
```
实体基类

### func addComponent\(Component\)
```cj
public func addComponent(c: Component): Unit
```
添加组件

参数: 

|名称|类型|描述|
|---|---|---|
|c|Component|组件实例|

异常: 

- EcsException 组件未注册（无 cptId）或实体内已存在同类型组件

### func getComponent\(ComponentId\)where T <: Component
```cj
public func getComponent < T >(cptId: ComponentId):?T where T <: Component
```
获取组件

参数: 

|名称|类型|描述|
|---|---|---|
|cptId|ComponentId|组件类 ID（通常为 XxxCpt.typeId()）|

返回: 

- 组件实例，不存在返回 None

### func hasComponent\(ComponentId\)
```cj
public func hasComponent(cptId: ComponentId): Bool
```
是否包含组件

参数: 

|名称|类型|描述|
|---|---|---|
|cptId|ComponentId|组件类 ID|

返回: 

- 包含返回 true

### func init\(\)
```cj
public init()
```
构造器，new 即分配实体 ID 并置位 _constructed

### func removeAllComponents\(\)
```cj
public func removeAllComponents(): Unit
```
删除所有组件

### func removeComponentById\(ComponentId\)
```cj
public func removeComponentById(cptId: ComponentId):?Component
```
删除组件

参数: 

|名称|类型|描述|
|---|---|---|
|cptId|ComponentId|组件类 ID|

返回: 

- 被删除的组件（已析构），不存在返回 None

### func removeComponent\(ComponentId\)where T <: Component
```cj
public func removeComponent < T >(cptId: ComponentId):?T where T <: Component
```
删除组件（泛型便捷形式）

参数: 

|名称|类型|描述|
|---|---|---|
|cptId|ComponentId|组件类 ID|

返回: 

- 被删除的组件，不存在返回 None

### prop components: HashMap < ComponentId, Component >
```cj
public prop components: HashMap < ComponentId, Component >
```
所有组件（cptId -> 组件实例）

### prop cptMask: BitArray
```cj
public prop cptMask: BitArray
```
实体拥有的所有组件掩码

### prop etyId: EntityId
```cj
public prop etyId: EntityId
```
实体 ID

### var monitorComponentChanges
```cj
public var monitorComponentChanges:?(Array < UInt8 >, Entity) -> Unit = None
```
组件变更监听（oldMask, entity），由 World.addEntity 挂接

