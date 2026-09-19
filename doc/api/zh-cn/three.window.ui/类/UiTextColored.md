# 类
## class UiTextColored
```cj
public class UiTextColored <: UiWidget
```
彩色文本控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染彩色文本

返回: 

- 控件交互结果，本控件恒为 false

### func init\(String,Color\)
```cj
public init(text!: String, color!: Color = Color(1.0, 1.0, 1.0))
```
构造彩色文本控件

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|要显示的文本|
|color|Color|文本颜色（RGB 分量范围 [0, 1]），默认白色|

