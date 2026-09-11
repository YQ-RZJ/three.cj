# 类
## class UiDragDropSource
```cj
public class UiDragDropSource <: UiWidget
```
拖拽源控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制拖拽源

返回: 

- 是否进入拖拽状态

### func init\(Int32,\(\)\->Unit\)
```cj
public init(flags!: Int32 = 0, content!:() -> Unit)
```
构造拖拽源

参数: 

|名称|类型|描述|
|---|---|---|
|flags|Int32|拖拽源标志（默认 0）|
|content|()->Unit|子内容绘制闭包|

