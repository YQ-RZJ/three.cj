# Class
## class LatheGeometry
```cj
public class LatheGeometry <: BufferGeometry
```
Lathe geometry class

### func init\(Array<Vector2>,Int64,Float64,Float64\)
```cj
public init(points: Array < Vector2 >, segments!: Int64 = 12, phiStart!: Float64 = 0.0, phiLength!: Float64 = PI * 2.0)
```
Constructs a lathe geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|points|Array<Vector2>|Array of 2D profile pointssegments Circumferential segments, default 12phiStart Start angle in radians, default 0phiLength Arc length in radians, default 2π|
|segments|Int64||
|phiStart|Float64||
|phiLength|Float64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Construction parameters

