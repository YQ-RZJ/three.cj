# 类
## class UiPlotLines
```cj
public class UiPlotLines <: UiWidget
```
折线图控件

### func draw\(\)
```cj
public override func draw(): Bool
```
渲染折线图

返回: 

- 恒为 false（无交互）

### func init\(String,PtrArray<Float32>,Int32,String,Float32,Float32,Vector2\)
```cj
public init(label!: String, values!: PtrArray < Float32 >, offset!: Int32 = 0, overlay!: String = "", scaleMin!: Float32 = 3.4028235e38, scaleMax!: Float32 = 3.4028235e38, size!: Vector2 = Vector2(0.0, 0.0))
```
构造折线图控件

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|图表标签文本|
|values|PtrArray<Float32>|数据点数组（PtrArray<Float32>）|
|offset|Int32|绘制数据的起始偏移（默认 0）|
|overlay|String|叠加显示的文本（默认空字符串表示不显示）|
|scaleMin|Float32|Y 轴最小值（默认 FLT_MAX 表示自动）|
|scaleMax|Float32|Y 轴最大值（默认 FLT_MAX 表示自动）|
|size|Vector2|图表尺寸（默认 (0,0) 表示自动计算）|

