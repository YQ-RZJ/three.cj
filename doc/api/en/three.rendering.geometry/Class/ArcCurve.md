# Class
## class ArcCurve
```cj
public class ArcCurve <: EllipseCurve
```
Arc curve class, extending EllipseCurve

### func init\(Float64,Float64,Float64,Float64,Float64,Bool\)
```cj
public init(aX!: Float64 = 0.0, aY!: Float64 = 0.0, aRadius!: Float64 = 1.0, aStartAngle!: Float64 = 0.0, aEndAngle!: Float64 = 2.0 * PI, aClockwise!: Bool = false)
```
Constructs a new arc curve

Parameter: 

|Name|Type|Describe|
|---|---|---|
|aX|Float64|X coordinate of the ellipse center, default 0aY Y coordinate of the ellipse center, default 0aRadius Radius, default 1aStartAngle Start angle, default 0aEndAngle End angle, default Math.PI*2aClockwise Whether clockwise, default false|
|aY|Float64||
|aRadius|Float64||
|aStartAngle|Float64||
|aEndAngle|Float64||
|aClockwise|Bool||

