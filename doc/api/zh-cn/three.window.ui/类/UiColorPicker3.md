# 类
## class UiColorPicker3
```cj
public class UiColorPicker3 <: UiWidget
```
三通道颜色选择器控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染三通道颜色选择器

返回: 

- 本次颜色值是否发生变化

### func init\(String,PtrArray<Float32>,Int32\)
```cj
public init(label!: String, col!: PtrArray < Float32 >, flags!: Int32 = 0)
```
构造三通道颜色选择器控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|选择器标签文本|
|col|PtrArray<Float32>|颜色值缓冲（PtrArray<Float32>，RGB 3 个分量，取值范围 0.0~1.0）|
|flags|Int32|ImGui 颜色选择器标志（默认 0）|

