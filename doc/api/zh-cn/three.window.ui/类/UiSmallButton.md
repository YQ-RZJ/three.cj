# 类
## class UiSmallButton
```cj
public class UiSmallButton <: UiWidget
```
小按钮控件（无边框，适合工具栏）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染小按钮，点击时触发回调

返回: 

- 本次点击是否发生

### func init\(String\)
```cj
public init(label!: String)
```
构造小按钮控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|按钮标签文本|

### func onClick\(\(\)\->Unit\)
```cj
public func onClick(callback:() -> Unit): UiSmallButton
```
设置点击回调

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|点击时执行的闭包|

返回: 

- this（链式调用）

