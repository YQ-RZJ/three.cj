# Class
## class RingGeometry
```cj
public class RingGeometry <: BufferGeometry
```
Ring geometry class

### func init\(Float64,Float64,Int64,Int64,Float64,Float64\)
```cj
public init(innerRadius!: Float64 = 0.5, outerRadius!: Float64 = 1.0, thetaSegments!: Int64 = 32, phiSegments!: Int64 = 1, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```
Constructs a ring geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|innerRadius|Float64|Inner radius, default 0.5outerRadius Outer radius, default 1.0thetaSegments Circumferential segments, default 32phiSegments Radial segments, default 1thetaStart Start angle in radians, default 0thetaLength Arc length in radians, default 2π|
|outerRadius|Float64||
|thetaSegments|Int64||
|phiSegments|Int64||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Construction parameters

