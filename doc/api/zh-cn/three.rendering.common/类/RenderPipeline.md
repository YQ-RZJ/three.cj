# 类
## class RenderPipeline
```cj
public open class RenderPipeline
```
TSL 渲染管线

### func \_update\(\)
```cj
public func _update(): Unit
```
检测配置变更并更新 contextData

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放渲染管线资源

### func init\(Renderer,Option<Any>\)
```cj
public init(renderer: Renderer, outputNode: Option < Any >)
```
构造渲染管线

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器实例outputNode TSL output 节点|
|outputNode|Option<Any>||

### func init\(\)
```cj
public init()
```
无参构造器（向后兼容）

### func renderAsync\(\)
```cj
public func renderAsync(): Unit
```
已废弃的异步渲染方法，请使用 render()

### func render\(\)
```cj
public func render(): Unit
```
执行渲染管线

### let isRenderPipeline
```cj
public let isRenderPipeline: Bool = true
```
类型测试标志

### var needsUpdate
```cj
public var needsUpdate: Bool = true
```
是否需要更新

### var outputColorTransform
```cj
public var outputColorTransform: Bool = true
```
是否启用 output 色彩变换

### var outputNode
```cj
public var outputNode: Option < Any >
```
TSL output 节点（占位 Option<Any>）

### let renderer
```cj
public let renderer: Renderer
```
渲染器引用

