# 类
## class Bindings
```cj
public open class Bindings <: DataMap
```
管线绑定集合管理器

### func createBindGroup\(\)
```cj
public func createBindGroup(): BindGroup
```
创建绑定组

返回: 

- 新创建的绑定组

### func destroyBindGroup\(BindGroup\)
```cj
public func destroyBindGroup(group: BindGroup): Unit
```
销毁绑定组

参数: 

|名称|类型|描述|
|---|---|---|
|group|BindGroup|绑定组|

### func init\(Backend\)
```cj
public init(backend: Backend)
```
构造绑定集合管理器

参数: 

|名称|类型|描述|
|---|---|---|
|backend|Backend|渲染后端实例|

### func setupBindGroup\(BindGroup,RenderPipeline\)
```cj
public func setupBindGroup(group: BindGroup, pipeline: RenderPipeline): Unit
```
设置绑定组与管线的关联

参数: 

|名称|类型|描述|
|---|---|---|
|group|BindGroup|绑定组pipeline 渲染管线|
|pipeline|RenderPipeline||

### func updateBindGroup\(BindGroup\)
```cj
public func updateBindGroup(group: BindGroup): Unit
```
更新绑定组

参数: 

|名称|类型|描述|
|---|---|---|
|group|BindGroup|绑定组|

### var backend
```cj
public var backend: Backend
```
后端引用

