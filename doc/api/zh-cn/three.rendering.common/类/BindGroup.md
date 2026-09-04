# 类
## class BindGroup
```cj
public open class BindGroup
```
管线绑定组，包含一组 Binding 及其关联的渲染管线

### func addBinding\(Binding\)
```cj
public func addBinding(binding: Binding): Unit
```
添加绑定到绑定组

参数: 

|名称|类型|描述|
|---|---|---|
|binding|Binding|绑定对象|

### func getBinding\(String\)
```cj
public func getBinding(name: String): Option < Binding >
```
按名称获取绑定

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|绑定名称|

返回: 

- 匹配的绑定，未找到返回 None

### func init\(\)
```cj
public init()
```
构造默认绑定组

### var bindings
```cj
public var bindings: ArrayList < Binding >
```
绑定列表

### var id
```cj
public var id: Int64
```
绑定组标识符

### var pipeline
```cj
public var pipeline: RenderPipeline
```
关联的渲染管线

