# Class
## class OctahedronGeometry
```cj
public class OctahedronGeometry <: PolyhedronGeometry
```
Octahedron geometry (polyhedron special case)

### func fromJSON\(HashMap<String,Any>\)
```cj
public static func fromJSON(data: HashMap < String, Any >): OctahedronGeometry
```
Factory method to create an instance from JSON data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|HashMap<String,Any>|JSON object containing serialized geometry data|

Return: 

- New OctahedronGeometry instance

### func init\(Float64,Int64\)
```cj
public init(radius!: Float64 = 1.0, detail!: Int64 = 0)
```
Constructs an octahedron geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Circumscribed sphere radius, default 1.0detail Subdivision level, default 0|
|detail|Int64||

