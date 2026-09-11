# 类
## class SkinInput
```cj
public class SkinInput
```
蒙皮输入数据

### func init\(Int,Array<Float32>,Int,?Array<Float32>,Int,?Array<Float32>,Int\)
```cj
public init(numVertices: Int, positions: Array < Float32 >, positionStride!: Int = 0, normals!:?Array < Float32 >= None, normalStride!: Int = 0, tangents!:?Array < Float32 >= None, tangentStride!: Int = 0)
```


参数: 

|名称|类型|描述|
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
法线 stride（字节）

### let normals
```cj
public let normals:?Array < Float32 >
```
法线输入缓冲区（可选）

### let numVertices
```cj
public let numVertices: Int
```
顶点数量

### let positionStride
```cj
public let positionStride: Int
```
位置 stride（字节）

### let positions
```cj
public let positions: Array < Float32 >
```
位置输入缓冲区

### let tangentStride
```cj
public let tangentStride: Int
```
切线 stride（字节）

### let tangents
```cj
public let tangents:?Array < Float32 >
```
切线输入缓冲区（可选）

