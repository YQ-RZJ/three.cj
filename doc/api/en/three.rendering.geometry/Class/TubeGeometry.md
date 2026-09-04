# Class
## class TubeGeometry
```cj
public class TubeGeometry <: BufferGeometry
```
Tube geometry class, extruding a tube along a 3D curve

### func init\(Curve,Int64,Float64,Int64,Bool\)
```cj
public init(path: Curve, tubularSegments!: Int64 = 64, radius!: Float64 = 1.0, radialSegments!: Int64 = 8, closed!: Bool = false)
```
Constructs a tube geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|Curve|3D curve along which the tube is extrudedtubularSegments Tubular segments, default 64radius Tube radius, default 1.0radialSegments Radial segments, default 8closed Whether the tube is closed, default false|
|tubularSegments|Int64||
|radius|Float64||
|radialSegments|Int64||
|closed|Bool||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Construction parameters

