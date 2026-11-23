# Class
## class ShapeGeometry
```cj
public class ShapeGeometry <: BufferGeometry
```
Shape geometry class, generating a plane mesh from a Shape via triangulation

### func init\(Shape,Int64\)
```cj
public init(shape: Shape, curveSegments!: Int64 = 12)
```
Constructs a shape geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|Shape|Shape object defining the outlinecurveSegments Curve segments, default 12|
|curveSegments|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Construction parameters

