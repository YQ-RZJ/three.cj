# 类
## class Pipelines
```cj
public open class Pipelines <: DataMap
```
管线集合管理器

### func add\(Pipeline\)
```cj
public func add(pipeline: Pipeline): Unit
```
添加管线到集合

参数: 

|名称|类型|描述|
|---|---|---|
|pipeline|Pipeline|管线实例|

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有管线

### func get\(Int64\)
```cj
public func get(id: Int64): Pipeline
```
按 ID 获取管线

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|管线标识符|

返回: 

- 管线实例

### func init\(\)
```cj
public init()
```
构造默认管线集合

### func remove\(Int64\)
```cj
public func remove(id: Int64): Unit
```
按 ID 移除管线

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|管线标识符|

### var pipelines
```cj
public var pipelines: HashMap < Int64, Pipeline >
```
管线映射表

