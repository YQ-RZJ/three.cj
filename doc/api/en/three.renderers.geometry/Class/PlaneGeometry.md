# Class
## class PlaneGeometry
```cj
public class PlaneGeometry <: BufferGeometry
```
Plane geometry class

### func init\(Float64,Float64,Int64,Int64\)
```cj
public init(width!: Float64 = 1.0, height!: Float64 = 1.0, widthSegments!: Int64 = 1, heightSegments!: Int64 = 1)
```
Constructs a plane geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Float64|Plane width, default 1.0height Plane height, default 1.0widthSegments Width segments, default 1heightSegments Height segments, default 1|
|height|Float64||
|widthSegments|Int64||
|heightSegments|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Construction parameters

