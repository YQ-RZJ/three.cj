# 类
## class GpuSkinningInput
```cj
public class GpuSkinningInput
```
GPU 蒙皮输入数据

### func init\(Int,Int,Int,Array<Float32>,?Array<Float32>,Array<Float32>,Array<Float32>,Array<Float32>\)
```cj
public init(numVertices: Int, numJoints: Int, numInfluences: Int, bindPositions: Array < Float32 >, bindNormals:?Array < Float32 >, jointIndices: Array < Float32 >, jointWeights: Array < Float32 >, jointMatrices: Array < Float32 >)
```


参数: 

|名称|类型|描述|
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
绑定姿势顶点法线（Float32 × 3 × numVertices，可选）

### let bindPositions
```cj
public let bindPositions: Array < Float32 >
```
绑定姿势顶点位置（Float32 × 3 × numVertices）

### let jointIndices
```cj
public let jointIndices: Array < Float32 >
```
关节索引（Int16 × numInfluences × numVertices，转为 Float32 上传）

### var jointMatrices
```cj
public var jointMatrices: Array < Float32 >
```
关节矩阵（Float32 × 16 × numJoints，列主序 4x4）

### let jointWeights
```cj
public let jointWeights: Array < Float32 >
```
关节权重（Float32 × numInfluences × numVertices）

### let numInfluences
```cj
public let numInfluences: Int
```
每顶点影响数（1-4）

### let numJoints
```cj
public let numJoints: Int
```
关节数量

### let numVertices
```cj
public let numVertices: Int
```
顶点数量

