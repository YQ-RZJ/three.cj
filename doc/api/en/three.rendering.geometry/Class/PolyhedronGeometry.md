# Class
## class PolyhedronGeometry
```cj
public open class PolyhedronGeometry <: BufferGeometry
```
Polyhedron geometry class, projecting vertex arrays onto a sphere and subdividing to specified detail level

### func fromJSON\(HashMap<String,Any>\)
```cj
public static func fromJSON(data: HashMap < String, Any >): PolyhedronGeometry
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|HashMap<String,Any>|JSON object containing serialized geometry data|

Return: 

- New PolyhedronGeometry instanceFactory method to create an instance from JSON data

### func init\(Array<Float64>,Array<Int64>,Float64,Int64\)
```cj
public init(vertices!: Array < Float64 >= Array < Float64 >(), indices!: Array < Int64 >= Array < Int64 >(), radius!: Float64 = 1.0, detail!: Int64 = 0)
```
Constructs a polyhedron geometry

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vertices|Array<Float64>|Flattened vertex array describing the base shapeindices Flattened index array describing the base shaperadius Shape radius, default 1.0detail Subdivision level, default 0|
|indices|Array<Int64>||
|radius|Float64||
|detail|Int64||

### var parameters
```cj
public var parameters: HashMap < String, Any >
```
Stores construction parameters; modifying after instantiation does not affect the geometry

