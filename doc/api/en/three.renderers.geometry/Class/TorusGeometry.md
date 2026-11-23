# Class
## class TorusGeometry
```cj
public class TorusGeometry <: BufferGeometry
```
Torus geometry class

### func init\(Float64,Float64,Int64,Int64,Float64,Float64,Float64\)
```cj
public init(radius!: Float64 = 1.0, tube!: Float64 = 0.4, radialSegments!: Int64 = 12, tubularSegments!: Int64 = 48, arc!: Float64 = PI * 2.0, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```
Constructs a torus geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Ring radius (center to tube center), default 1.0tube Tube radius, default 0.4radialSegments Radial segments, default 12tubularSegments Tubular segments, default 48arc Arc length in radians, default 2πthetaStart Radial start angle, default 0thetaLength Radial arc length, default 2π|
|tube|Float64||
|radialSegments|Int64||
|tubularSegments|Int64||
|arc|Float64||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Construction parameters

