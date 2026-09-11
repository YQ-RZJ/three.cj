# Class
## class GpuSkinningInput
```cj
public class GpuSkinningInput
```
GPU skinning input data

### func init\(Int,Int,Int,Array<Float32>,?Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(numVertices: Int, numJoints: Int, numInfluences: Int, bindPositions: Array < Float32 >, bindNormals:?Array < Float32 >, jointIndices: Array < Float32 >, jointWeights: Array < Float32 >, jointMatrices: Array < Float32 >)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|numVertices|Int||
|numJoints|Int||
|numInfluences|Int||
|bindPositions|Array<Float32>||
|bindNormals|?Array<Float32>||
|jointIndices|Array<Float32>||
|jointWeights|Array<Float32>||
|jointMatrices|Array<Float32>||

### let bindNormals
```cj
public let bindNormals:?Array < Float32 >
```
Bind-pose vertex normals (Float32 × 3 × numVertices, optional)

### let bindPositions
```cj
public let bindPositions: Array < Float32 >
```
Bind-pose vertex positions (Float32 × 3 × numVertices)

### let jointIndices
```cj
public let jointIndices: Array < Float32 >
```
Joint indices (Int16 × numInfluences × numVertices, uploaded as Float32)

### var jointMatrices
```cj
public var jointMatrices: Array < Float32 >
```
Joint matrices (Float32 × 16 × numJoints, column-major 4x4)

### let jointWeights
```cj
public let jointWeights: Array < Float32 >
```
Joint weights (Float32 × numInfluences × numVertices)

### let numInfluences
```cj
public let numInfluences: Int
```
Number of influences per vertex (1-4)

### let numJoints
```cj
public let numJoints: Int
```
Number of joints

### let numVertices
```cj
public let numVertices: Int
```
Number of vertices

