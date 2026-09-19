# 类
## class UiSliderAngle
```cj
public class UiSliderAngle <: UiWidget
```
角度滑块控件（以弧度值显示，范围以度为单位）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染角度滑块

返回: 

- 本次值是否发生变化

### func init\(String,PtrArray<Float32>,Float32,Float32,String,Int32\)
```cj
public init(label: String, vRad: PtrArray < Float32 >, minDeg!: Float32 = - 360.0f32, maxDeg!: Float32 = 360.0f32, format!: String = "%.0f deg", flags!: Int32 = 0)
```
构造角度滑块控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|滑块标签文本|
|vRad|PtrArray<Float32>|角度值缓冲（弧度，PtrArray<Float32> 单元素）|
|minDeg|Float32|最小角度（度，默认 -360.0）|
|maxDeg|Float32|最大角度（度，默认 360.0）|
|format|String|角度显示格式（默认 "%.0f deg"）|
|flags|Int32|ImGui 滑块标志（默认 0）|

