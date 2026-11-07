# Class
## class GridHelper
```cj
public class GridHelper <: LineSegments & IReleasable
```
Grid helper that displays a 2D grid in the scene

### func init\(Float64,Int64,Color,Color\)
```cj
public init(size!: Float64 = 10.0, divisions!: Int64 = 10, color1!: Color = Color(0x444444), color2!: Color = Color(0x888888))
```
Construct a grid helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|Float64|Grid size, default 10divisions Number of divisions, default 10color1 Center line color, default dark gray 0x444444color2 Grid line color, default light gray 0x888888|
|divisions|Int64||
|color1|Color||
|color2|Color||

### func release\(\)
```cj
public func release(): Bool
```
Release GPU resources

