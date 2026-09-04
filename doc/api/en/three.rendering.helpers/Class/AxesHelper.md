# Class
## class AxesHelper
```cj
public class AxesHelper <: LineSegments
```
Axes helper for visualizing X/Y/Z axes

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Float64\)
```cj
public init(size!: Float64 = 1.0)
```
Construct an axes helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|Float64|Axis line length, default 1|

### func setColors\(Color,Color,Color\)
```cj
public func setColors(xAxisColor: Color, yAxisColor: Color, zAxisColor: Color): AxesHelper
```
Set colors for each axis

Parameter: 

|Name|Type|Describe|
|---|---|---|
|xAxisColor|Color|X axis coloryAxisColor Y axis colorzAxisColor Z axis color|
|yAxisColor|Color||
|zAxisColor|Color||

Return: 

- Self reference

