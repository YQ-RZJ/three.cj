# 类
## class SystemManager
```cj
public class SystemManager
```
系统管理类

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

异常: 

- EcsException 同 ID 系统已存在

### func clear\(\)
```cj
public func clear(): Unit
```
清理（析构全部系统）

### func delSystemById\(SystemId\)
```cj
public func delSystemById(id: SystemId):?System
```
删除系统（触发析构，ID 自动回收）

参数: 

|名称|类型|描述|
|---|---|---|
|id|SystemId|系统 ID|

返回: 

- 被删除的系统，不存在返回 None

### func init\(EntityManager,ISysEtyMapManager<System,Entity>\)
```cj
public init(etyMgr: EntityManager, sysMap: ISysEtyMapManager < System, Entity >)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|etyMgr|EntityManager|实体管理器sysMap 系统-实体映射管理器|
|sysMap|ISysEtyMapManager<System,Entity>||

### func onUpdate\(Float64\)
```cj
public func onUpdate(dt: Float64): Unit
```
更新所有系统

参数: 

|名称|类型|描述|
|---|---|---|
|dt|Float64|帧间隔（秒）|

### prop size: Int64
```cj
public prop size: Int64
```
内部管理的总量

### prop systems: HashMap < SystemId, System >
```cj
public prop systems: HashMap < SystemId, System >
```
所有系统

### let updateOrder
```cj
public let updateOrder: ArrayList < SystemId >= ArrayList < SystemId >()
```
系统遍历顺序（为空时按 sysId 升序）

