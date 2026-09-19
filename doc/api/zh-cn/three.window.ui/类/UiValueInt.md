# 类
## class UiValueInt
```cj
public class UiValueInt <: UiWidget
```
整数值显示控件（Value）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染整数值显示

返回: 

- 恒为 false（该控件不返回交互状态）

### func init\(String,Int32\)
```cj
public init(prefix!: String, v!: Int32)
```
构造整数值显示控件

参数: 

|名称|类型|描述|
|---|---|---|
|prefix|String|显示前缀文本|
|v|Int32|整数值|

