# 类
## class UiColorPicker4
```cj
public class UiColorPicker4 <: UiWidget
```
颜色选择器控件（RGBA）

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染颜色选择器

返回: 

- 本次颜色是否发生变化

### func init\(String,PtrArray<Float32>,Int32\)
```cj
public init(label!: String, col!: PtrArray < Float32 >, flags!: Int32 = 0)
```
构造颜色选择器控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|标签文本|
|col|PtrArray<Float32>|颜色缓冲（PtrArray<Float32>，4 个分量 RGBA，0.0~1.0）|
|flags|Int32|ImGui 颜色选择标志（默认 0）|

