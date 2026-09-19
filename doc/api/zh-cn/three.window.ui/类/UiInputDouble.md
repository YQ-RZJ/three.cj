# 类
## class UiInputDouble
```cj
public class UiInputDouble <: UiWidget
```
双精度输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染双精度输入框

返回: 

- 本次值是否发生变化

### func getValue\(\)
```cj
public func getValue(): Float64
```
获取当前值

返回: 

- 输入框当前值

### func init\(String,PtrArray<Float64>,Float64,Float64,String\)
```cj
public init(label!: String, value!: PtrArray < Float64 >, step!: Float64 = 0.1, stepFast!: Float64 = 1.0, format!: String = "%.6f")
```
构造双精度输入框控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|输入框标签文本|
|value|PtrArray<Float64>|值缓冲（PtrArray<Float64> 单元素，随输入更新）|
|step|Float64|步进值（默认 0.1）|
|stepFast|Float64|按住 Shift 时的快进步进（默认 1.0）|
|format|String|数值显示格式（默认 "%.6f"）|

