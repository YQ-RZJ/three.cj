# 类
## class UiLabelText
```cj
public class UiLabelText <: UiWidget
```
标签+值文本控件（LabelText）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染标签与值文本

返回: 

- 恒为 false（该控件不返回交互状态）

### func init\(String,String\)
```cj
public init(label!: String, text!: String)
```
构造标签+值文本控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|左侧标签文本|
|text|String|右侧值文本|

