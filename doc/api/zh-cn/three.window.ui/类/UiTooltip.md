# 类
## class UiTooltip
```cj
public class UiTooltip <: UiWidget
```
工具提示控件（悬停时显示）

### func draw\(\)
```cj
public override func draw(): Bool
```
悬停时显示工具提示内容

返回: 

- 恒为 false（无交互）

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
构造工具提示控件

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|悬停时显示的内容闭包|

