# Class
## class \_ObjParseObject
```cj
public class _ObjParseObject
```
OBJ parse object (corresponding to an o/g declaration)

### func init\(String\)
```cj
public init(name: String)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func startMaterial\(String,ArrayList<String>\)
```cj
public func startMaterial(name: String, libraries: ArrayList < String >): Unit
```
开始新材质段

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|libraries|ArrayList<String>||

### var colors
```cj
public var colors: ArrayList < Float64 >
```


### var hasUVIndices
```cj
public var hasUVIndices: Bool
```


### var isLine
```cj
public var isLine: Bool
```


### var isPoints
```cj
public var isPoints: Bool
```


### var materials
```cj
public var materials: ArrayList < _ObjSourceMaterial >
```


### var name
```cj
public var name: String
```


### var normals
```cj
public var normals: ArrayList < Float64 >
```


### var uvs
```cj
public var uvs: ArrayList < Float64 >
```


### var vertices
```cj
public var vertices: ArrayList < Float64 >
```


