# 类
## class Attributes
```cj
public open class Attributes <: DataMap
```
管理顶点属性与后端缓冲区的映射

### func destroy\(BufferAttribute\)
```cj
public func destroy(attribute: BufferAttribute): Unit
```
销毁属性对应的缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|BufferAttribute|顶点属性|

### func get\(BufferAttribute\)
```cj
public func get(attribute: BufferAttribute): Int64
```
获取属性对应的后端缓冲区句柄

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|BufferAttribute|顶点属性|

返回: 

- 缓冲区句柄

### func init\(Backend\)
```cj
public init(backend: Backend)
```
构造属性管理器

参数: 

|名称|类型|描述|
|---|---|---|
|backend|Backend|渲染后端实例|

### func updateInstanced\(InstancedBufferAttribute\)
```cj
public func updateInstanced(attribute: InstancedBufferAttribute): Unit
```
更新实例化属性对应的缓冲区数据

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|InstancedBufferAttribute|实例化顶点属性|

### func update\(BufferAttribute\)
```cj
public func update(attribute: BufferAttribute): Unit
```
更新属性对应的缓冲区数据

参数: 

|名称|类型|描述|
|---|---|---|
|attribute|BufferAttribute|顶点属性|

### var backend
```cj
public var backend: Backend
```
后端引用

