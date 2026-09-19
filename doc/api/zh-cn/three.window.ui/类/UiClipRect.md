# 类
## class UiClipRect
```cj
public class UiClipRect <: UiWidget
```
剪裁矩形容器

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染容器：在剪裁矩形内执行内容

返回: 

- 恒为 false（无交互）

### func init\(Vector2,Vector2,\(\)\->Unit\)
```cj
public init(min!: Vector2, max!: Vector2, content!:() -> Unit)
```
构造剪裁矩形容器

参数: 

|名称|类型|描述|
|---|---|---|
|min|Vector2|剪裁矩形左上角（最小点）|
|max|Vector2|剪裁矩形右下角（最大点）|
|content|()->Unit|容器内容闭包|

