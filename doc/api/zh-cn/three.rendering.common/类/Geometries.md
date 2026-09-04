# 类
## class Geometries
```cj
public open class Geometries <: DataMap
```
几何体后端数据管理器

### func destroy\(BufferGeometry\)
```cj
public func destroy(geometry: BufferGeometry): Unit
```
销毁几何体对应的后端资源

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|几何体|

### func get\(BufferGeometry\)
```cj
public func get(geometry: BufferGeometry): Int64
```
获取几何体对应的后端句柄

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|几何体|

返回: 

- 后端句柄

### func init\(Backend\)
```cj
public init(backend: Backend)
```
构造几何体管理器

参数: 

|名称|类型|描述|
|---|---|---|
|backend|Backend|渲染后端实例|

### func updateForRender\(RenderObject\)
```cj
public func updateForRender(renderObject: RenderObject): Unit
```
根据渲染对象更新几何体缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|renderObject|RenderObject|渲染对象|

### func update\(BufferGeometry\)
```cj
public func update(geometry: BufferGeometry): Unit
```
更新几何体缓冲区数据

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|几何体|

### var backend
```cj
public var backend: Backend
```
后端引用

