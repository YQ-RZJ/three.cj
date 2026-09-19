# 类
## class UiSliderFloat3
```cj
public class UiSliderFloat3 <: UiWidget
```
三通道浮点滑块控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染三通道浮点滑块

返回: 

- 本次值是否发生变化

### func init\(String,PtrArray<Float32>,Float32,Float32,String,Int32\)
```cj
public init(label: String, v: PtrArray < Float32 >, min: Float32, max: Float32, format!: String = "%.3f", flags!: Int32 = 0)
```
构造三通道浮点滑块控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|滑块标签文本|
|v|PtrArray<Float32>|值缓冲（PtrArray<Float32>，3 个分量）|
|min|Float32|最小值|
|max|Float32|最大值|
|format|String|数值显示格式（默认 "%.3f"）|
|flags|Int32|ImGui 滑块标志（默认 0）|

