# Class
## class SkinInput
```cj
public class SkinInput
```
Skinning input data

### func init\(Int,Array<Float32>,Int,?Array<Float32>,Int,?Array<Float32>,Int\)
```cj
public init(numVertices: Int, positions: Array < Float32 >, positionStride!: Int = 0, normals!:?Array < Float32 >= None, normalStride!: Int = 0, tangents!:?Array < Float32 >= None, tangentStride!: Int = 0)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|numVertices|Int||
|positions|Array<Float32>||
|positionStride|Int||
|normals|?Array<Float32>||
|normalStride|Int||
|tangents|?Array<Float32>||
|tangentStride|Int||

### let normalStride
```cj
public let normalStride: Int
```
Normal stride in bytes

### let normals
```cj
public let normals:?Array < Float32 >
```
Normal input buffer (optional)

### let numVertices
```cj
public let numVertices: Int
```
Number of vertices

### let positionStride
```cj
public let positionStride: Int
```
Position stride in bytes

### let positions
```cj
public let positions: Array < Float32 >
```
Position input buffer

### let tangentStride
```cj
public let tangentStride: Int
```
Tangent stride in bytes

### let tangents
```cj
public let tangents:?Array < Float32 >
```
Tangent input buffer (optional)

