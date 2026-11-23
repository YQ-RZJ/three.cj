# Class
## class TorusKnotGeometry
```cj
public class TorusKnotGeometry <: BufferGeometry
```
Torus knot geometry class

### func init\(Float64,Float64,Int64,Int64,Int64,Int64\)
```cj
public init(radius!: Float64 = 1.0, tube!: Float64 = 0.4, tubularSegments!: Int64 = 64, radialSegments!: Int64 = 8, p!: Int64 = 2, q!: Int64 = 3)
```
Constructs a torus knot geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Torus knot radius, default 1.0tube Tube radius, default 0.4tubularSegments Tubular segments, default 64radialSegments Radial segments, default 8p Winding number p, default 2q Winding number q, default 3|
|tube|Float64||
|tubularSegments|Int64||
|radialSegments|Int64||
|p|Int64||
|q|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Construction parameters

