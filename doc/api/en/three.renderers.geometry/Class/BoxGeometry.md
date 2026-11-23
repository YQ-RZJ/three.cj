# Class
## class BoxGeometry
```cj
public class BoxGeometry <: BufferGeometry
```
Box geometry class

### func init\(Float64,Float64,Float64,Int64,Int64,Int64\)
```cj
public init(width!: Float64 = 1.0, height!: Float64 = 1.0, depth!: Float64 = 1.0, widthSegments!: Int64 = 1, heightSegments!: Int64 = 1, depthSegments!: Int64 = 1)
```
Constructs a box geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Float64|Width, default 1height Height, default 1depth Depth, default 1widthSegments Width segments, default 1heightSegments Height segments, default 1depthSegments Depth segments, default 1|
|height|Float64||
|depth|Float64||
|widthSegments|Int64||
|heightSegments|Int64||
|depthSegments|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Geometry generation parameters

