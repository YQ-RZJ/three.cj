# 类
## class RenderLists
```cj
public open class RenderLists
```
渲染列表缓存管理器

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有渲染列表

### func get\(Scene,Camera\)
```cj
public func get(scene: Scene, camera: Camera): RenderList
```
获取或创建 (scene, camera) 对应的 RenderList

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|场景camera 相机|
|camera|Camera||

返回: 

- RenderList 实例

### func init\(\)
```cj
public init()
```
构造默认渲染列表缓存

