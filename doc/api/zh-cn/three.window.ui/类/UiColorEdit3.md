# 类
## class UiColorEdit3
```cj
public class UiColorEdit3 <: UiWidget
```
三通道颜色编辑器控件（RGB）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染三通道颜色编辑器

返回: 

- 本次颜色是否发生变化

### func init\(String,PtrArray<Float32>,Int32\)
```cj
public init(label: String, col: PtrArray < Float32 >, flags!: Int32 = 0)
```
构造三通道颜色编辑器控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签文本|
|col|PtrArray<Float32>|颜色缓冲（PtrArray<Float32>，3 个分量 RGB，0.0~1.0）|
|flags|Int32|ImGui 颜色编辑标志（默认 0）|

