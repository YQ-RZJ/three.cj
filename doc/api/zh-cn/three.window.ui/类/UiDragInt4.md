# 类
## class UiDragInt4
```cj
public class UiDragInt4 <: UiWidget
```
四通道整数拖拽控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染四通道整数拖拽控件

返回: 

- 本次值是否发生变化

### func init\(String,PtrArray<Int32>,Float32,Int32,Int32,String,Int32\)
```cj
public init(label: String, v: PtrArray < Int32 >, speed!: Float32 = 1.0f32, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d", flags!: Int32 = 0)
```
构造四通道整数拖拽控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签文本|
|v|PtrArray<Int32>|值缓冲（PtrArray<Int32>，4 个分量）|
|speed|Float32|拖拽速度（默认 1.0）|
|min|Int32|最小值（默认 0）|
|max|Int32|最大值（默认 0 表示不限制）|
|format|String|数值显示格式（默认 "%d"）|
|flags|Int32|ImGui 拖拽标志（默认 0）|

