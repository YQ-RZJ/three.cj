# 类
## class UiValue
```cj
public class UiValue <: UiWidget
```
值显示控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染值显示

返回: 

- 恒为 false（无交互）

### func getValue\(\)
```cj
public func getValue(): Float32
```
获取当前显示的值

返回: 

- 当前显示的值

### func init\(String,Float32,String\)
```cj
public init(prefix!: String, value!: Float32, format!: String = "")
```
构造值显示控件

参数: 

|名称|类型|描述|
|---|---|---|
|prefix|String|值前缀标签|
|value|Float32|要显示的数值|
|format|String|数值显示格式（默认空字符串表示使用 ImGui 默认格式）|

### func setValue\(Float32\)
```cj
public func setValue(v: Float32): Unit
```
设置要显示的值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|要显示的值|

