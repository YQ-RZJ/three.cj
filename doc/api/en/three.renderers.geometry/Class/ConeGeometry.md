# Class
## class ConeGeometry
```cj
public class ConeGeometry <: CylinderGeometry
```
Cone geometry class, a special case of CylinderGeometry (radiusTop = 0)

### func init\(Float64,Float64,Int64,Int64,Bool,Float64,Float64\)
```cj
public init(radius!: Float64 = 1.0, height!: Float64 = 1.0, radialSegments!: Int64 = 8, heightSegments!: Int64 = 1, openEnded!: Bool = false, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0)
```
Constructs a cone geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Bottom radius, default 1height Height, default 1radialSegments Radial segments, default 8heightSegments Height segments, default 1openEnded Whether the bottom is open, default falsethetaStart Start angle, default 0thetaLength Angle length, default 2π|
|height|Float64||
|radialSegments|Int64||
|heightSegments|Int64||
|openEnded|Bool||
|thetaStart|Float64||
|thetaLength|Float64||

