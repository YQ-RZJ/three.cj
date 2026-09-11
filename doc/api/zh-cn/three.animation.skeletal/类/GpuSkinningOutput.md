# 类
## class GpuSkinningOutput
```cj
public class GpuSkinningOutput
```
GPU 蒙皮输出数据

### func init\(Int\)
```cj
public init(numVertices: Int)
```


参数: 

|名称|类型|描述|
|---|---|---|
|numVertices|Int||

### var skinnedNormals
```cj
public var skinnedNormals:?Array < Float32 >
```
蒙皮后顶点法线（Float32 × 3 × numVertices，可选）

### var skinnedPositions
```cj
public var skinnedPositions: Array < Float32 >
```
蒙皮后顶点位置（Float32 × 3 × numVertices）

