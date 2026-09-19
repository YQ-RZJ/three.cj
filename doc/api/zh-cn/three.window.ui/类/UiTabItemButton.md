# 类
## class UiTabItemButton
```cj
public class UiTabItemButton <: UiWidget
```
标签栏按钮控件（如 "+" 按钮）

### func draw\(\)
```cj
public override func draw(): Bool
```
绘制标签栏按钮

返回: 

- 按钮是否被点击

### func init\(String,Int32\)
```cj
public init(label!: String, flags!: Int32 = 0)
```
构造标签栏按钮

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|按钮标签|
|flags|Int32|按钮标志（默认 0）|

