# 类
## class RenderBundle
```cj
public open class RenderBundle
```
渲染束，包含一组渲染对象的集合

### func add\(RenderObject\)
```cj
public func add(obj: RenderObject): Unit
```
添加渲染对象到渲染束

参数: 

|名称|类型|描述|
|---|---|---|
|obj|RenderObject|渲染对象|

### func clear\(\)
```cj
public func clear(): Unit
```
清空渲染对象列表

### func init\(\)
```cj
public init()
```
构造默认渲染束

### var id
```cj
public var id: Int64
```
渲染束标识符

### var objects
```cj
public var objects: ArrayList < RenderObject >
```
渲染对象列表

