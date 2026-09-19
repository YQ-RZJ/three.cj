# 类
## class UiValueUint
```cj
public class UiValueUint <: UiWidget
```
无符号整数值显示控件（Value）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染无符号整数值显示

返回: 

- 恒为 false（该控件不返回交互状态）

### func init\(String,UInt32\)
```cj
public init(prefix!: String, v!: UInt32)
```
构造无符号整数值显示控件

参数: 

|名称|类型|描述|
|---|---|---|
|prefix|String|显示前缀文本|
|v|UInt32|无符号整数值|

