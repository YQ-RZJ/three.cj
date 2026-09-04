# 类
## class ArrSysEtyMapManager
```cj
public class ArrSysEtyMapManager <: ISysEtyMapManager < System, Entity >
```
系统-实体映射管理（哈希模式）

### func addEntity\(Entity\)
```cj
public func addEntity(ety: Entity): Unit
```
添加实体到匹配系统的记录区

参数: 

|名称|类型|描述|
|---|---|---|
|ety|Entity|实体|

### func addSystem\(System\)
```cj
public func addSystem(sys: System): Unit
```
添加系统到映射

参数: 

|名称|类型|描述|
|---|---|---|
|sys|System|系统|

### func bind\(HashMap<SystemId,System>,HashMap<EntityId,Entity>\)
```cj
public func bind(systems: HashMap < SystemId, System >, entitys: HashMap < EntityId, Entity >): Unit
```
绑定系统表与实体表

参数: 

|名称|类型|描述|
|---|---|---|
|systems|HashMap<SystemId,System>|系统表entitys 实体表|
|entitys|HashMap<EntityId,Entity>||

### func changeEntity\(Array<UInt8>,Entity\)
```cj
public func changeEntity(_oldMask: Array < UInt8 >, ety: Entity): Unit
```
实体组件变更后调整映射

参数: 

|名称|类型|描述|
|---|---|---|
|_oldMask|Array<UInt8>|旧组件掩码ety 变更的实体|
|ety|Entity||

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有映射

### func delEntity\(Entity\)
```cj
public func delEntity(ety: Entity): Unit
```
从所有系统记录区中移除实体

参数: 

|名称|类型|描述|
|---|---|---|
|ety|Entity|实体|

### func delSystem\(System\)
```cj
public func delSystem(sys: System): Unit
```
从映射中删除系统

参数: 

|名称|类型|描述|
|---|---|---|
|sys|System|系统|

### func getSystemEntitys\(System\)
```cj
public func getSystemEntitys(sys: System):(Int64, Iterator < Entity >)
```
获取系统关联的实体迭代器

参数: 

|名称|类型|描述|
|---|---|---|
|sys|System|系统|

返回: 

- (实体数量, 实体迭代器)

