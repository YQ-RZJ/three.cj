# Class
## class PolarGridHelper
```cj
public class PolarGridHelper <: LineSegments
```
Polar grid helper displaying a polar coordinate grid on the XZ plane

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Float64,Int64,Int64,Int64,Color,Color\)
```cj
public init(radius!: Float64 = 10.0, sectors!: Int64 = 16, rings!: Int64 = 8, divisions!: Int64 = 64, color1!: Color = Color(0x444444), color2!: Color = Color(0x888888))
```
Construct a polar grid helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Radius, default 10sectors Number of sectors, default 16rings Number of rings, default 8divisions Ring segments, default 64color1 Radial line color, default dark gray 0x444444color2 Ring color, default light gray 0x888888|
|sectors|Int64||
|rings|Int64||
|divisions|Int64||
|color1|Color||
|color2|Color||

