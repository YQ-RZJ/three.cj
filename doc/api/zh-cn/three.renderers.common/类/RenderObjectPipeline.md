# 类
## class RenderObjectPipeline
```cj
public open class RenderObjectPipeline <: Pipeline
```
渲染对象与管线的关联对

### func init\(RenderObject,RenderPipeline\)
```cj
public init(renderObject: RenderObject, pipeline: RenderPipeline)
```
构造渲染对象管线关联

参数: 

|名称|类型|描述|
|---|---|---|
|renderObject|RenderObject|渲染对象pipeline 渲染管线|
|pipeline|RenderPipeline||

### var pipeline
```cj
public var pipeline: RenderPipeline
```
渲染管线

### var renderObject
```cj
public var renderObject: RenderObject
```
渲染对象

