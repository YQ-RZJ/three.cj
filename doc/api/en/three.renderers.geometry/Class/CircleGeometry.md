# Class
## class CircleGeometry
```cj
public class CircleGeometry <: BufferGeometry
```
Circle geometry class

### func init\(Float64,Int64,Float64,Float64\)
```cj
public init(radius!: Float64 = 1.0, segments!: Int64 = 32, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```
Constructs a circle geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Radius, default 1segments Number of segments, default 32thetaStart Start angle, default 0thetaLength Angle length, default 2π|
|segments|Int64||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Geometry generation parameters

