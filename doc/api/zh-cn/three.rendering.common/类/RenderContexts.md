# 类
## class RenderContexts
```cj
public open class RenderContexts
```
渲染上下文缓存管理器

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有上下文

### func get\(Scene,Camera\)
```cj
public func get(scene: Scene, camera: Camera): RenderContext
```
获取或创建 (scene, camera) 对应的 RenderContext

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|场景camera 相机|
|camera|Camera||

返回: 

- RenderContext 实例

### func init\(\)
```cj
public init()
```
构造默认渲染上下文缓存

