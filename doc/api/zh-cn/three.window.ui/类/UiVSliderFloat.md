# 类
## class UiVSliderFloat
```cj
public class UiVSliderFloat <: UiWidget
```
垂直浮点滑块控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染垂直滑块并同步值

返回: 

- 本次值是否发生变化

### func getValue\(\)
```cj
public func getValue(): Float32
```
获取当前值

返回: 

- 滑块当前值

### func init\(String,PtrArray<Float32>,Vector2,Float32,Float32,String\)
```cj
public init(label!: String, value!: PtrArray < Float32 >, size!: Vector2 = Vector2(0.0, 0.0), min!: Float32 = 0.0, max!: Float32 = 1.0, format!: String = "%.3f")
```
构造垂直浮点滑块控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|滑块标签文本|
|value|PtrArray<Float32>|值缓冲（PtrArray<Float32> 单元素，随拖动更新）|
|size|Vector2|滑块尺寸（默认 (0,0) 表示自动计算）|
|min|Float32|最小值（默认 0.0）|
|max|Float32|最大值（默认 1.0）|
|format|String|数值显示格式（默认 "%.3f"）|

