# 类
## class UiPopup
```cj
public class UiPopup <: UiWidget
```
普通弹出窗口控件

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制弹出窗口

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(String,Int32,\(\)\->Unit\)
```cj
public init(id!: String, flags!: Int32 = 0, content!:() -> Unit)
```
构造普通弹出窗口

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|弹出窗口 ID|
|flags|Int32|弹出窗口标志（默认 0）|
|content|()->Unit|子内容绘制闭包|

