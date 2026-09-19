# 类
## class UiSliderInt4
```cj
public class UiSliderInt4 <: UiWidget
```
四通道整数滑块控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染四通道整数滑块

返回: 

- 本次值是否发生变化

### func init\(String,PtrArray<Int32>,Int32,Int32,String,Int32\)
```cj
public init(label: String, v: PtrArray < Int32 >, min: Int32, max: Int32, format!: String = "%d", flags!: Int32 = 0)
```
构造四通道整数滑块控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|滑块标签文本|
|v|PtrArray<Int32>|值缓冲（PtrArray<Int32>，4 个分量）|
|min|Int32|最小值|
|max|Int32|最大值|
|format|String|数值显示格式（默认 "%d"）|
|flags|Int32|ImGui 滑块标志（默认 0）|

