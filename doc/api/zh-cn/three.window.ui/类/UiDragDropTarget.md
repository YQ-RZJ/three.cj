# 类
## class UiDragDropTarget
```cj
public class UiDragDropTarget <: UiWidget
```
拖放目标控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制拖放目标

返回: 

- 是否处于可接收拖放状态

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
构造拖放目标

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|子内容绘制闭包|

