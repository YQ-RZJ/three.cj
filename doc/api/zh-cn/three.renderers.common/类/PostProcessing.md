# 类
## class PostProcessing
```cj
public class PostProcessing
```
后处理渲染器

### func init\(\)
```cj
public init()
```
构造默认后处理渲染器（禁用状态）

### func render\(Scene,Camera\)
```cj
public func render(scene: Scene, camera: Camera): Unit
```
执行后处理渲染

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|场景camera 相机|
|camera|Camera||

### var enabled
```cj
public var enabled: Bool
```
是否启用后处理

