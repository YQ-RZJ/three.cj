# Class
## class SphereGeometry
```cj
public class SphereGeometry <: BufferGeometry
```
Sphere geometry class

### func init\(Float64,Int64,Int64,Float64,Float64,Float64,Float64\)
```cj
public init(radius!: Float64 = 1.0, widthSegments!: Int64 = 32, heightSegments!: Int64 = 16, phiStart!: Float64 = 0.0, phiLength!: Float64 = PI * 2.0, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI)
```
Constructs a sphere geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Sphere radius, default 1.0widthSegments Horizontal segments, default 32heightSegments Vertical segments, default 16phiStart Horizontal start angle, default 0phiLength Horizontal arc length, default 2πthetaStart Vertical start angle, default 0thetaLength Vertical arc length, default π|
|widthSegments|Int64||
|heightSegments|Int64||
|phiStart|Float64||
|phiLength|Float64||
|thetaStart|Float64||
|thetaLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Construction parameters

