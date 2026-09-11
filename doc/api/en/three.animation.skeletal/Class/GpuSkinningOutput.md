# Class
## class GpuSkinningOutput
```cj
public class GpuSkinningOutput
```
GPU skinning output data

### func init\(Int\)
```cj
public init(numVertices: Int)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|numVertices|Int||

### var skinnedNormals
```cj
public var skinnedNormals:?Array < Float32 >
```
Skinned vertex normals (Float32 × 3 × numVertices, optional)

### var skinnedPositions
```cj
public var skinnedPositions: Array < Float32 >
```
Skinned vertex positions (Float32 × 3 × numVertices)

