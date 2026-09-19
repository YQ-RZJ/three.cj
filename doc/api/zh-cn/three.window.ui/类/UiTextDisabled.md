# 类
## class UiTextDisabled
```cj
public class UiTextDisabled <: UiWidget
```
禁用样式文本控件（灰色）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染灰色禁用文本

返回: 

- 控件交互结果，本控件恒为 false

### func init\(String\)
```cj
public init(text!: String)
```
构造禁用样式文本控件

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|要显示的文本|

