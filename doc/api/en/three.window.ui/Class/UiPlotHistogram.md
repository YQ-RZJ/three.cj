# Class
## class UiPlotHistogram
```cj
public class UiPlotHistogram <: UiWidget
```
Histogram plot widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the histogram plot

Return: 

- Always false (no interaction)

### func init\(String,PtrArray<Float32>,Int32,String,Float32,Float32,Vector2\)
```cj
public init(label!: String, values!: PtrArray < Float32 >, offset!: Int32 = 0, overlay!: String = "", scaleMin!: Float32 = 3.4028235e38, scaleMax!: Float32 = 3.4028235e38, size!: Vector2 = Vector2(0.0, 0.0))
```
Constructs a histogram plot widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Chart label text|
|values|PtrArray<Float32>|Data points (PtrArray<Float32>)|
|offset|Int32|Start offset into the data (default 0)|
|overlay|String|Overlay text (default empty means no overlay)|
|scaleMin|Float32|Y-axis minimum (default FLT_MAX means auto)|
|scaleMax|Float32|Y-axis maximum (default FLT_MAX means auto)|
|size|Vector2|Chart size (default (0,0) means auto-calculated)|

