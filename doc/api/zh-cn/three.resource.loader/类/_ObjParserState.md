# 类
## class \_ObjParserState
```cj
public class _ObjParserState
```
OBJ 解析状态机

### func addFace\(String,String,String,String,String,String,String,String,String\)
```cj
public func addFace(a: String, b: String, c: String, ua: String, ub: String, uc: String, na: String, nb: String, nc: String): Unit
```
添加三角面，解析顶点/UV/法线索引并累积到当前对象

参数: 

|名称|类型|描述|
|---|---|---|
|a|String||
|b|String||
|c|String||
|ua|String||
|ub|String||
|uc|String||
|na|String||
|nb|String||
|nc|String||

### func addLineGeometry\(ArrayList<String>\)
```cj
public func addLineGeometry(vertices: ArrayList < String >): Unit
```
添加线几何数据

参数: 

|名称|类型|描述|
|---|---|---|
|vertices|ArrayList<String>||

### func addPointGeometry\(ArrayList<String>\)
```cj
public func addPointGeometry(vertices: ArrayList < String >): Unit
```
添加点几何数据

参数: 

|名称|类型|描述|
|---|---|---|
|vertices|ArrayList<String>||

### func finalize\(\)
```cj
public func finalize(): Unit
```
完成解析，更新最后一个材质段的顶点计数

### func init\(\)
```cj
public init()
```


### func parseNormalIndex\(String,Int64\)
```cj
public func parseNormalIndex(value: String, len: Int64): Int64
```
解析法线索引（支持正/负索引）

参数: 

|名称|类型|描述|
|---|---|---|
|value|String||
|len|Int64||

### func parseUVIndex\(String,Int64\)
```cj
public func parseUVIndex(value: String, len: Int64): Int64
```
解析 UV 索引（支持正/负索引）

参数: 

|名称|类型|描述|
|---|---|---|
|value|String||
|len|Int64||

### func parseVertexIndex\(String,Int64\)
```cj
public func parseVertexIndex(value: String, len: Int64): Int64
```
解析顶点索引（支持正/负索引）

参数: 

|名称|类型|描述|
|---|---|---|
|value|String||
|len|Int64||

### func startMaterial\(String\)
```cj
public func startMaterial(name: String): Unit
```
开始新材质段（usemtl 声明时调用）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func startObject\(String,Bool\)
```cj
public func startObject(name: String, fromDeclaration!: Bool = true): Unit
```
开始新对象（o/g 声明时调用）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|fromDeclaration|Bool||

### var colors
```cj
public var colors: ArrayList < Float64 >
```


### var materialLibraries
```cj
public var materialLibraries: ArrayList < String >
```


### var normals
```cj
public var normals: ArrayList < Float64 >
```


### var objectSmooth
```cj
public var objectSmooth: Bool
```


### var objects
```cj
public var objects: ArrayList < _ObjParseObject >
```


### var uvs
```cj
public var uvs: ArrayList < Float64 >
```


### var vertices
```cj
public var vertices: ArrayList < Float64 >
```


