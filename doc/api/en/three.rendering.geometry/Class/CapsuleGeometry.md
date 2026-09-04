# Class
## class CapsuleGeometry
```cj
public class CapsuleGeometry <: BufferGeometry
```
Capsule geometry class, composed of a cylindrical middle section and two hemispherical caps

### func init\(Float64,Float64,Int64,Int64,Int64\)
```cj
public init(radius!: Float64 = 1.0, length!: Float64 = 1.0, capSegments!: Int64 = 4, radialSegments!: Int64 = 8, heightSegments!: Int64 = 1)
```
Constructs a capsule geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Radius, default 1length Cylinder section length, default 1capSegments Cap segments, default 4radialSegments Radial segments, default 8heightSegments Height segments, default 1|
|length|Float64||
|capSegments|Int64||
|radialSegments|Int64||
|heightSegments|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Geometry generation parameters

