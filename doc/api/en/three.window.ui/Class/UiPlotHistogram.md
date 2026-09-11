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


### func init\(String,CPointer<Float32>,Int32,Int32,String,Float32,Float32,Vector2\)
```cj
public init(label!: String, values!: CPointer < Float32 >, count!: Int32, offset!: Int32 = 0, overlay!: String = "", scaleMin!: Float32 = 3.4028235e38, scaleMax!: Float32 = 3.4028235e38, size!: Vector2 = Vector2(0.0, 0.0))
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|values|CPointer<Float32>||
|count|Int32||
|offset|Int32||
|overlay|String||
|scaleMin|Float32||
|scaleMax|Float32||
|size|Vector2||

