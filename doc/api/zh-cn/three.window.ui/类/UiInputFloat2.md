# 类
## class UiInputFloat2
```cj
public class UiInputFloat2 <: UiWidget
```
双通道浮点输入框控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染双通道浮点输入框

返回: 

- 本次值是否发生变化

### func init\(String,PtrArray<Float32>,String,Int32\)
```cj
public init(label: String, v: PtrArray < Float32 >, format!: String = "%.3f", flags!: Int32 = 0)
```
构造双通道浮点输入框控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|输入框标签文本|
|v|PtrArray<Float32>|值缓冲（PtrArray<Float32>，2 个分量）|
|format|String|数值显示格式（默认 "%.3f"）|
|flags|Int32|ImGui 输入框标志（默认 0）|

