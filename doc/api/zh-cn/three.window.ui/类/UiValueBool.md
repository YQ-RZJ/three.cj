# 类
## class UiValueBool
```cj
public class UiValueBool <: UiWidget
```
布尔值显示控件（Value）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染布尔值显示

返回: 

- 恒为 false（该控件不返回交互状态）

### func init\(String,Bool\)
```cj
public init(prefix!: String, v!: Bool)
```
构造布尔值显示控件

参数: 

|名称|类型|描述|
|---|---|---|
|prefix|String|显示前缀文本|
|v|Bool|布尔值|

