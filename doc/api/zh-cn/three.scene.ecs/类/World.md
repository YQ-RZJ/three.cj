# 类
## class World
```cj
public class World
```
世界类，ECS 顶层门面

### func addEntity\(Entity\)
```cj
public func addEntity(e: Entity): EntityId
```
添加实体

参数: 

|名称|类型|描述|
|---|---|---|
|e|Entity|实体|

返回: 

- 实体 ID

### func addSystem\(System\)
```cj
public func addSystem(sys: System): SystemId
```
添加系统到管理器中

参数: 

|名称|类型|描述|
|---|---|---|
|sys|System|系统|

返回: 

- 系统 ID

### func clear\(\)
```cj
public func clear(): Unit
```
清理整个世界（组件池清空，实体/系统全部析构，ID 全部回收）

### func createComponent\(ComponentId\)where T <: Component
```cj
public func createComponent < T >(cptId: ComponentId):?T where T <: Component
```
创建组件（池化）

参数: 

|名称|类型|描述|
|---|---|---|
|cptId|ComponentId|组件类 ID（XxxCpt.typeId()）|

返回: 

- 组件实例，组件类未注册返回 None

### func createEntity\(\)
```cj
public func createEntity(): Entity
```
创建一个实体（init 自动分配实体 ID）

返回: 

- 新建的实体

### func delEntity\(EntityId\)
```cj
public func delEntity(id: EntityId): Unit
```
删除实体（触发析构，ID 自动回收，组件全部卸载）

参数: 

|名称|类型|描述|
|---|---|---|
|id|EntityId|实体 ID|

### func delSystemById\(SystemId\)
```cj
public func delSystemById(id: SystemId): Unit
```
删除系统（触发析构，ID 自动回收）

参数: 

|名称|类型|描述|
|---|---|---|
|id|SystemId|系统 ID|

### func getEntity\(EntityId\)
```cj
public func getEntity(id: EntityId):?Entity
```
获取实体

参数: 

|名称|类型|描述|
|---|---|---|
|id|EntityId|实体 ID|

返回: 

- 实体实例，不存在返回 None

### func init\(\)
```cj
public init()
```
构造器（默认哈希模式映射管理器）

### func init\(ISysEtyMapManager<System,Entity>\)
```cj
public init(sysMapMgr: ISysEtyMapManager < System, Entity >)
```
构造器（自定义映射管理器）

参数: 

|名称|类型|描述|
|---|---|---|
|sysMapMgr|ISysEtyMapManager<System,Entity>|系统-实体映射管理器实现|

### func onUpdate\(Float64\)
```cj
public func onUpdate(dt: Float64): Unit
```
更新所有系统

参数: 

|名称|类型|描述|
|---|---|---|
|dt|Float64|帧间隔（秒）|

### func recycle\(Component\)
```cj
public func recycle(c: Component): Unit
```
回收组件

参数: 

|名称|类型|描述|
|---|---|---|
|c|Component|组件实例|

### func removeEntity\(EntityId\)
```cj
public func removeEntity(id: EntityId): Unit
```
移除实体（不触发析构，ID 不回收）

参数: 

|名称|类型|描述|
|---|---|---|
|id|EntityId|实体 ID|

### prop componentMgr: ComponentManager
```cj
public prop componentMgr: ComponentManager
```
组件管理器

### prop entityMgr: EntityManager
```cj
public prop entityMgr: EntityManager
```
实体管理器

### prop systemMgr: SystemManager
```cj
public prop systemMgr: SystemManager
```
系统管理器

### prop updateOrder: ArrayList < SystemId >
```cj
public prop updateOrder: ArrayList < SystemId >
```
系统遍历顺序（为空时按 sysId 升序）

