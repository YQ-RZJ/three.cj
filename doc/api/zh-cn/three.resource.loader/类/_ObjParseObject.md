# 类
## class \_ObjParseObject
```cj
public class _ObjParseObject
```
OBJ 解析对象（对应一个 o/g 声明）

### func init\(String\)
```cj
public init(name: String)
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func startMaterial\(String,ArrayList<String>\)
```cj
public func startMaterial(name: String, libraries: ArrayList < String >): Unit
```
开始新材质段

参数: 

|名称|类型|描述|
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


