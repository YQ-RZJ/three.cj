# 类
## class UiRadioButton
```cj
public class UiRadioButton <: UiWidget
```
单选按钮控件（布尔激活态形式）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染单选按钮

返回: 

- 本次是否被点击

### func init\(String,Bool\)
```cj
public init(label!: String, active!: Bool)
```
构造单选按钮

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|按钮标签|
|active|Bool|是否处于选中态|

