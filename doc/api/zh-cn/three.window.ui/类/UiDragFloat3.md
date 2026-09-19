# 类
## class UiDragFloat3
```cj
public class UiDragFloat3 <: UiWidget
```
三通道浮点拖拽控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染三通道浮点拖拽控件

返回: 

- 本次值是否发生变化

### func init\(String,PtrArray<Float32>,Float32,Float32,Float32,String,Int32\)
```cj
public init(label: String, v: PtrArray < Float32 >, speed!: Float32 = 1.0f32, min!: Float32 = 0.0f32, max!: Float32 = 0.0f32, format!: String = "%.3f", flags!: Int32 = 0)
```
构造三通道浮点拖拽控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签文本|
|v|PtrArray<Float32>|值缓冲（PtrArray<Float32>，3 个分量）|
|speed|Float32|拖拽速度（默认 1.0）|
|min|Float32|最小值（默认 0.0）|
|max|Float32|最大值（默认 0.0 表示不限制）|
|format|String|数值显示格式（默认 "%.3f"）|
|flags|Int32|ImGui 拖拽标志（默认 0）|

