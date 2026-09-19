# 类
## class UiInputFloat
```cj
public class UiInputFloat <: UiWidget
```
浮点输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染浮点输入框

返回: 

- 本次值是否发生变化

### func getValue\(\)
```cj
public func getValue(): Float32
```
获取当前值

返回: 

- 输入框当前值

### func init\(String,PtrArray<Float32>,Float32,Float32,String\)
```cj
public init(label!: String, value!: PtrArray < Float32 >, step!: Float32 = 0.1, stepFast!: Float32 = 1.0, format!: String = "%.3f")
```
构造浮点输入框控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|输入框标签文本|
|value|PtrArray<Float32>|值缓冲（PtrArray<Float32> 单元素，随输入更新）|
|step|Float32|步进值（默认 0.1）|
|stepFast|Float32|按住 Shift 时的快进步进（默认 1.0）|
|format|String|数值显示格式（默认 "%.3f"）|

### func setValue\(Float32\)
```cj
public func setValue(v: Float32): Unit
```
设置当前值

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|要设置的值|

