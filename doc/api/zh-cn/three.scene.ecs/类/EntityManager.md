# 类
## class EntityManager
```cj
public class EntityManager
```
实体管理类

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

### func clear\(\)
```cj
public func clear(): Unit
```
清理（析构全部实体，ID 全部回收）

### func delEntity\(EntityId\)
```cj
public func delEntity(id: EntityId):?Entity
```
删除实体（触发析构，ID 自动回收）

参数: 

|名称|类型|描述|
|---|---|---|
|id|EntityId|实体 ID|

返回: 

- 被删除的实体，不存在返回 None

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

### func removeEntity\(EntityId\)
```cj
public func removeEntity(id: EntityId):?Entity
```
移除实体（不触发析构，ID 不回收）

参数: 

|名称|类型|描述|
|---|---|---|
|id|EntityId|实体 ID|

返回: 

- 被移除的实体，不存在返回 None

### prop entitys: HashMap < EntityId, Entity >
```cj
public prop entitys: HashMap < EntityId, Entity >
```
所有实体（内部表引用，供映射管理器挂接）

### prop size: Int64
```cj
public prop size: Int64
```
内部管理的总量

