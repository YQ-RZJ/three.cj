# 类
## class UiSetTooltip
```cj
public class UiSetTooltip <: UiWidget
```
文本工具提示控件

### func draw\(\)
```cj
public override func draw(): Bool
```
立即设置并显示文本工具提示

返回: 

- 恒为 false（无交互）

### func init\(String\)
```cj
public init(text!: String)
```
构造文本工具提示控件

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|提示文本|

