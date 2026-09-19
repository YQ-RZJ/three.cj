# 类
## class UiOpenPopup
```cj
public class UiOpenPopup <: UiWidget
```
打开弹出窗口控件

### func draw\(\)
```cj
public override func draw(): Bool
```
打开指定弹出窗口

返回: 

- 是否发生交互（当前实现恒返回 false）

### func init\(String,Int32\)
```cj
public init(id!: String, flags!: Int32 = 0)
```
构造打开弹出窗口控件

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|弹出窗口 ID|
|flags|Int32|弹出窗口标志（默认 0）|

